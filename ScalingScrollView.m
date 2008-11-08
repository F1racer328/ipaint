// Copyright 2008 Mac-Fun
//
// This file is part of iPaint.
//
// iPaint is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// iPaint is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with iPaint; if not, write to the Free Software
// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

#import "ScalingScrollView.h"
#import "CenteringClipView.h"

static NSString *scaleMenuLabels[] = { @"25%", @"50%", @"100%", @"200%", @"400%", @"800%", @"1600%"};
static float scaleMenuFactors[] = { 0.25, 0.5, 1.0, 2.0, 4.0, 8.0, 16.0};
static unsigned defaultIndex = 2;
//static float _NSScaleMenuFontSize = 12.0;

@implementation ScalingScrollView

- (id)initWithFrame:(NSRect)rect {
    if ((self = [super initWithFrame:rect])) {
        scaleFactor = 1.0;
    }
    return self;
}

- (void)makeScalePopUpButton {
    if (scalePopUpButton == nil) {
        unsigned cnt, numberOfDefaultItems = (sizeof(scaleMenuLabels) / sizeof(NSString *));
        id curItem;
		
        // create it
		scalePopUpButton = [[NSPopUpButton allocWithZone:[self zone]] initWithFrame:NSMakeRect(0.0, 0.0, 1.0, 1.0) pullsDown:NO];
		[(NSPopUpButtonCell *)[scalePopUpButton cell] setBezelStyle:NSShadowlessSquareBezelStyle];
		[[scalePopUpButton cell] setArrowPosition:NSPopUpArrowAtBottom];
        
        // fill it
        for (cnt = 0; cnt < numberOfDefaultItems; cnt++) {
            [scalePopUpButton addItemWithTitle:NSLocalizedStringFromTable(scaleMenuLabels[cnt], @"ZoomValues", nil)];
            curItem = [scalePopUpButton itemAtIndex:cnt];
            if (scaleMenuFactors[cnt] != 0.0) {
                [curItem setRepresentedObject:[NSNumber numberWithFloat:scaleMenuFactors[cnt]]];
            }
        }
        [scalePopUpButton selectItemAtIndex:defaultIndex];
		
        // hook it up
        [scalePopUpButton setTarget:self];
        [scalePopUpButton setAction:@selector(scalePopUpAction:)];
		
        // set a suitable font - choosing 0 results in the default value
        [scalePopUpButton setFont:[NSFont controlContentFontOfSize:0]];
		
        // Make sure the popup is big enough to fit the cells.
        [scalePopUpButton sizeToFit];
		
		// don't let it become first responder
		[scalePopUpButton setRefusesFirstResponder:YES];
		
        // put it in the scrollview
        [self addSubview:scalePopUpButton];
        [scalePopUpButton release];
    }
}

- (void)tile {
    // Let the superclass do most of the work.
    [super tile];
	
    if (![self hasHorizontalScroller]) {
        if (scalePopUpButton) [scalePopUpButton removeFromSuperview];
        scalePopUpButton = nil;
    } else {
		NSScroller *horizScroller;
		NSRect horizScrollerFrame, buttonFrame;
		
		if (!scalePopUpButton) {
			[self makeScalePopUpButton];
		}
		
		horizScroller = [self horizontalScroller];
		horizScrollerFrame = [horizScroller frame];
		buttonFrame = [scalePopUpButton frame];
		
		// Now we'll just adjust the horizontal scroller size and set the button size and location.
		horizScrollerFrame.size.width = horizScrollerFrame.size.width - buttonFrame.size.width;
		horizScrollerFrame.origin.x = buttonFrame.size.width;
		[horizScroller setFrame:horizScrollerFrame];

		// Puts it on the right
//		buttonFrame.origin.x = NSMaxX(horizScrollerFrame);
//		buttonFrame.size.height = horizScrollerFrame.size.height + 1.0;
//		buttonFrame.origin.y = [self bounds].size.height - buttonFrame.size.height + 1.0;
//		[scalePopUpButton setFrame:buttonFrame];
		
		// Puts it on the left
		buttonFrame.origin.x = 0;
		buttonFrame.size.height = horizScrollerFrame.size.height + 1.0;
		buttonFrame.origin.y = [self bounds].size.height - buttonFrame.size.height + 1.0;
		[scalePopUpButton setFrame:buttonFrame];
	}
}

- (void)scalePopUpAction:(id)sender {
    NSNumber *selectedFactorObject = [[sender selectedCell] representedObject];
    
    if (selectedFactorObject == nil) {
        NSLog(@"Scale popup action: setting arbitrary zoom factors is not yet supported.");
        return;
    } else {
        [self setScaleFactor:[selectedFactorObject floatValue] adjustPopup:NO];
		//[(NSClipView *)[[self documentView] superview] scrollToPoint:[self bounds].origin];
    }
}

- (float)scaleFactor {
    return scaleFactor;
}

- (void)setScaleFactor:(float)newScaleFactor adjustPopup:(BOOL)flag {
    if (scaleFactor != newScaleFactor) {
		NSSize curDocFrameSize, newDocBoundsSize, curDocBoundsSize;
		NSPoint newDocBoundsOrigin;
		CenteringClipView *clipView = (CenteringClipView *)[[self documentView] superview];
		
        if (flag) {	// Coming from elsewhere, first validate it
            unsigned cnt = 0, numberOfDefaultItems = (sizeof(scaleMenuFactors) / sizeof(float));
			
            // We only work with the preset zoom values, so choose one of the appropriate values 
			//  (Fudge a little for floating point == to work)
            while (cnt < numberOfDefaultItems && newScaleFactor * .99 > scaleMenuFactors[cnt]) {
				cnt++;
			}
            if (cnt == numberOfDefaultItems) {
				cnt--;
			}
            [scalePopUpButton selectItemAtIndex:cnt];
            scaleFactor = scaleMenuFactors[cnt];
        } else {
            scaleFactor = newScaleFactor;
        }
				
		// Get the frame.  The frame must stay the same.
		curDocFrameSize = [clipView frame].size;
		
		// Get the size for fun calculations
		curDocBoundsSize = [clipView bounds].size;
		
		// The new bounds will be frame divided by scale factor
		newDocBoundsSize.width = curDocFrameSize.width / scaleFactor;
		newDocBoundsSize.height = curDocFrameSize.height / scaleFactor;
				
		// Likewise, adjust the bottom-left corner to maintain centered-ness
		newDocBoundsOrigin.x = [clipView bounds].origin.x + (curDocBoundsSize.width / 2) - (newDocBoundsSize.width / 2);
		newDocBoundsOrigin.y = [clipView bounds].origin.y + (curDocBoundsSize.height / 2) - (newDocBoundsSize.height / 2);

		// Finally, inform the clip view of the changes we've made
		[clipView setBoundsSize:newDocBoundsSize];
		[clipView setBoundsOrigin:newDocBoundsOrigin];
    }
}

/*- (void)drawRect:(NSRect)rect {
    NSRect verticalLineRect;
	
	NSLog(@"%f %f", rect.size.width, rect.size.height);
    
    [super drawRect:rect];
	
    if ([scalePopUpButton superview]) {
        verticalLineRect = [scalePopUpButton frame];
        verticalLineRect.origin.x -= 1.0;
        verticalLineRect.size.width = 1.0;
        if (NSIntersectsRect(rect, verticalLineRect)) {
            [[NSColor redColor] set];
            NSRectFill(verticalLineRect);
        }
    }
}

- (void)setHasHorizontalScroller:(BOOL)flag {
    if (!flag) [self setScaleFactor:1.0 adjustPopup:NO];
    [super setHasHorizontalScroller:flag];
}*/

@end
