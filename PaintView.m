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

#import "PaintView.h"

static int undoSize = 10;

@implementation PaintView

- (id)initWithFrame:(NSRect)frameRect color:(NSColor *)backgroundColor
{	
	if (self = [super initWithFrame:frameRect]) {
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(refreshImage:)
													 name:@"SWRefresh"
												   object:nil];
				
		// Only 10 levels of undo, for the time being
		[[self undoManager] setLevelsOfUndo:undoSize];
		backColor = backgroundColor;
		isPayingAttention = YES;
		if (!hasRun) {
			cornerPoint = NSZeroPoint;
			mainImage = [[NSImage alloc] initWithSize:frameRect.size];
		}
		secondImage = [[NSImage alloc] initWithSize:frameRect.size];	
		
		// Set the window's maximum size to the size of the screen
		// Does not seem to work all the time
		NSRect screenRect = [[NSScreen mainScreen] frame];
		[[super window] setMaxSize:screenRect.size];
		
		// Center the shrunken/enlarged window with respect to its initial location
		NSRect newRect = [[super window] frame];
		newRect.origin.y = newRect.origin.y + (0.5 * (newRect.size.height - frameRect.size.height));
		newRect.origin.x = newRect.origin.x + (0.5 * (newRect.size.width - frameRect.size.width));
		
		// Ensures that the document is never wider than the screen
		if (frameRect.size.width + 15 <= screenRect.size.width) {
			newRect.size.width = frameRect.size.width + 15;
		} else {
			newRect.size.width = screenRect.size.width;
		}
		
		// Or taller, for that matter
		newRect.size.height = frameRect.size.height + 36;
		if (newRect.origin.x < 0) {
			newRect.origin.x = 0;
		}
		
		// Apply the changes to the new document
		if (!hasRun) {
			[[super window] setFrame:newRect display:YES animate:YES];
		}
				
		// Grid related
		_showsGrid = NO;
		_gridSpacing = 8;
		_gridColor = nil;
		
		[self setNeedsDisplay:YES];
	}
	return self;
}

- (void)drawRect:(NSRect)rect
{		
	// Cursors! Set the current cursor to the selection cursor
	NSCursor *cursor = [NSCursor crosshairCursor];
	[cursor setOnMouseEntered:YES];
	[self addCursorRect:rect cursor:cursor];
	
	// If you don't do this, the image looks blurry when zoomed in
	[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];

	// New document, not an opened image: gotta paint the background color
	if (!hasRun && !hasOpened) {
		[mainImage lockFocus];
		[backColor set];
		
		[NSBezierPath fillRect:[self bounds]];
		hasRun = YES;
		[mainImage unlockFocus];
	}
	
	// Draw the NSImage to the view
	if (mainImage) {
		[mainImage drawInRect:rect
					 fromRect:rect
					operation:NSCompositeSourceOver
					 fraction:1.0];
	}
	
	// If there's an overlay image being used at the moment, draw it
	if (secondImage) {
		[secondImage drawInRect:rect
					   fromRect:rect
					  operation:NSCompositeSourceOver
					   fraction:1.0];
	}
	
	// If the grid is turned on, draw that too
	if (_showsGrid) {
		DrawGridWithSettingsInRect([self gridSpacing], [self gridColor], rect, NSZeroPoint);
	}
}

////////////////////////////////////////////////////////////////////////////////
//////////		Mouse/keyboard events: the cornerstone of the drawing process
////////////////////////////////////////////////////////////////////////////////


- (void)rightMouseDown:(NSEvent *)event
{
	//NSLog(@"Right click!");
	// Eventually, I want a contextual menu here for copy/paste
}

- (void)mouseDown:(NSEvent *)event
{
	isPayingAttention = YES;
	NSPoint p = [event locationInWindow];
	downPoint = [self convertPoint:p fromView:nil];
	
	// Necessary for when the view is zoomed above 100%
	currentPoint.x = floor(downPoint.x) + 0.5;
	currentPoint.y = floor(downPoint.y) + 0.5;
	
	// Since it's the click, let's confirm which tool we're dealing with
	currentTool = [[ToolboxController sharedToolboxPanelController] currentTool];
	
	[currentTool setSavedPoint:currentPoint];
	
	// If it's shifted, do something about it
	[currentTool setShiftModifier:([event modifierFlags] & NSShiftKeyMask)];
	[currentTool performDrawAtPoint:currentPoint withMainImage:mainImage secondImage:secondImage mouseEvent:MOUSE_DOWN];
	
	[self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)event
{
	if (isPayingAttention) {
		NSPoint p = [event locationInWindow];
		NSPoint dragPoint = [self convertPoint:p fromView:nil];
		
		// Necessary for when the view is zoomed above 100%
		dragPoint.x = floor(dragPoint.x) + 0.5;
		dragPoint.y = floor(dragPoint.y) + 0.5;
		
		[currentTool setShiftModifier:([event modifierFlags] & NSShiftKeyMask)];
		[currentTool performDrawAtPoint:dragPoint withMainImage:mainImage secondImage:secondImage mouseEvent:MOUSE_DRAGGED];
		
		currentPoint = dragPoint;
		[self setNeedsDisplay:YES];
	}
}

- (void)mouseUp:(NSEvent *)event
{
	if (isPayingAttention) {
		
		NSPoint p = [event locationInWindow];
		downPoint = [self convertPoint:p fromView:nil];
		
		// Necessary for when the view is zoomed above 100%
		downPoint.x = floor(downPoint.x) + 0.5;
		downPoint.y = floor(downPoint.y) + 0.5;
		[currentTool setShiftModifier:([event modifierFlags] & NSShiftKeyMask)];
		[currentTool performDrawAtPoint:downPoint withMainImage:mainImage secondImage:secondImage mouseEvent:MOUSE_UP];
		currentPoint = downPoint;
		
		[self setNeedsDisplay:YES];
	}
}

// Handles keyboard events
- (void)keyDown:(NSEvent *)event
{
	// Escape key
	if ([event keyCode] == 53){
		isPayingAttention = NO;
		[currentTool tieUpLooseEnds];
		if (secondImage) {
			[secondImage release];
		}
		secondImage = [[NSImage alloc] initWithSize:[mainImage size]];
		[self setNeedsDisplay:YES];
		
	// Delete keys (back and forward)
	} else if ([event keyCode] == 51 || [event keyCode] == 117) {
		[self clearOverlay];
		
	} else {
		//NSLog(@"%@", [event charactersIgnoringModifiers]);
		//[[ToolboxController sharedToolboxPanelController] dealWithLetter:[event charactersIgnoringModifiers]];
	}
}


////////////////////////////////////////////////////////////////////////////////
//////////		MyDocument tells PaintView this information from the Toolbox
////////////////////////////////////////////////////////////////////////////////


- (void)setImage:(NSImage *)newImage
{	
	[newImage retain];
	[mainImage release];
	mainImage = newImage;
	[self setNeedsDisplay:YES];
}


////////////////////////////////////////////////////////////////////////////////
//////////		Handling undo: a "prep" and then the actual method
////////////////////////////////////////////////////////////////////////////////


- (void)prepUndo:(id)sender
{
	NSUndoManager *undo = [self undoManager];
	[undo setLevelsOfUndo:undoSize];
	if (sender) {
		//NSLog(@"Received an object");
		[[undo prepareWithInvocationTarget:self] undoImage:(NSData *)sender];
	} else {
		[[undo prepareWithInvocationTarget:self] undoImage:[mainImage TIFFRepresentation]];
	}
	if (![undo isUndoing]) {
		[undo setActionName:@"Drawing"];
	}
}

// Undo mainImages are made for every mouseDown:
- (void)undoImage:(NSData *)mainImageData
{
	NSUndoManager *undo = [self undoManager];
	[[undo prepareWithInvocationTarget:self] undoImage:[[self mainImage] TIFFRepresentation]];
	if (![undo isUndoing]) {
		[undo setActionName:@"Drawing"];
	}
	if (imageRep) {
		[imageRep release];
	}
	imageRep = [[NSBitmapImageRep alloc] initWithData:mainImageData];
	
	[mainImage lockFocus];
	[imageRep drawAtPoint:NSZeroPoint];
	[mainImage unlockFocus];
	[self clearOverlay];
	//[self setNeedsDisplay:YES];
}

////////////////////////////////////////////////////////////////////////////////
//////////      Grid-Related Methods
////////////////////////////////////////////////////////////////////////////////

// Switch the grid, if it isn't already the same as the parameter
- (void)setShowsGrid:(BOOL)showsGrid {
	if (showsGrid != _showsGrid) {
		_showsGrid = showsGrid;
		[self setNeedsDisplay: YES];
	}
}

// Change the spacing of the grid, based off the slider in the GridController
- (void)setGridSpacing:(float)gridSpacing {
	if (gridSpacing != _gridSpacing) {
		_gridSpacing = gridSpacing;
		[self setNeedsDisplay: YES];
	}
}

// Change the color of the grid from the default gray
- (void)setGridColor:(NSColor *)gridColor {
	if (_gridColor != gridColor) {
		[_gridColor release];
		_gridColor = [gridColor retain];
		[self setNeedsDisplay: YES];
	}
}

// Should the grid be shown? Hmm...
- (BOOL)showsGrid {
	return _showsGrid;
}

// Returns the spacing of the grid
- (float)gridSpacing {
	return _gridSpacing;
}

// If there is a grid color, return it... otherwise, go with light gray
- (NSColor *)gridColor {
	return (_gridColor ? _gridColor : [NSColor lightGrayColor]);
}

////////////////////////////////////////////////////////////////////////////////
//////////		Miscellaneous
////////////////////////////////////////////////////////////////////////////////


// Releases the overlay image, then tells the tool about it
- (void)clearOverlay
{
	if (secondImage) {
		[secondImage release];
	}
	secondImage = [[NSImage alloc] initWithSize:[mainImage size]];
	[currentTool tieUpLooseEnds];
	[self setNeedsDisplay:YES];
}

// Pastes data as an image
- (void)pasteData:(NSData *)data
{
	[currentTool tieUpLooseEnds];
	[[ToolboxController sharedToolboxPanelController] switchToScissors:nil];
	currentTool = [[ToolboxController sharedToolboxPanelController] currentTool];
	NSPoint origin = NSMakePoint([[self superview] bounds].origin.x, [[self superview] bounds].origin.y);
	
	if (origin.x < 0)
		origin.x = 0;
	if (origin.y < 0)
		origin.y = 0;
	origin.x++;
	origin.y++;
	
	NSImage *temp = [[NSImage alloc] initWithData:data];
	if (secondImage) {
		[secondImage release];
	}
	secondImage = [[NSImage alloc] initWithSize:[mainImage size]];	
	[secondImage lockFocus];
	[temp drawAtPoint:origin
			 fromRect:NSZeroRect
			operation:NSCompositeSourceOver
			 fraction:1.0];
	[secondImage unlockFocus];
	
	// Use ceiling because pixels can be decimals, but the tool assumes integer values
	[(SelectionTool *)currentTool setClippingRect:NSMakeRect(origin.x,origin.y,ceil([temp size].width)+2,ceil([temp size].height)+2) 
										 forImage:secondImage];
	[temp release];
	[self setNeedsDisplay:YES];
}

- (IBAction)selectAll:(id)sender
{
	[[ToolboxController sharedToolboxPanelController] switchToScissors:nil];
	currentTool = [[ToolboxController sharedToolboxPanelController] currentTool];
	
	[currentTool setSavedPoint:NSMakePoint(0.5,0.5)];
	[currentTool performDrawAtPoint:NSMakePoint([self bounds].size.width-1, [self bounds].size.height-1)
					  withMainImage:mainImage 
						secondImage:secondImage 
						 mouseEvent:MOUSE_UP];
}

// Returns the mainImage
- (NSImage *)mainImage
{
	return mainImage;
}

// Returns the overlay
- (NSImage *)secondImage
{
	return secondImage;
}

- (void)setHasOpened:(BOOL)opened
{
	hasOpened = opened;
}

// Tells the mainImage to refresh itself. Can be called from anywhere in the application.
- (void)refreshImage:(NSNotification *)note
{
	[self setNeedsDisplay:YES];
}

// Optimizes speed a bit
- (BOOL)isOpaque
{
	return YES;
}

- (BOOL)hasRun
{
	return hasRun;
}

// Necessary to allow keyboard events and stuff
- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (void)dealloc
{
	if (undoData) {
		[undoData release];
	}
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[frontColor release];
	[backColor release];
	[mainImage release];
	[imageRep release];
	[[self undoManager] removeAllActions]; 
	// Note: do NOT release the current tool, as it is just a pointer to the
	// object inherited from ToolboxController
	
	[super dealloc];
}

@end

void DrawGridWithSettingsInRect(float spacing, NSColor *color, NSRect rect, NSPoint gridOrigin) {
    int curLine, endLine;
    NSBezierPath *gridPath = [NSBezierPath bezierPath];
	
    [color set];
	
    // Columns
    curLine = ceil((NSMinX(rect) - gridOrigin.x) / spacing);
    endLine = floor((NSMaxX(rect) - gridOrigin.x) / spacing);
    for (; curLine<=endLine; curLine++) {
        [gridPath moveToPoint:NSMakePoint((curLine * spacing) + gridOrigin.x, NSMinY(rect))];
        [gridPath lineToPoint:NSMakePoint((curLine * spacing) + gridOrigin.x, NSMaxY(rect))];
    }
	
    // Rows
    curLine = ceil((NSMinY(rect) - gridOrigin.y) / spacing);
    endLine = floor((NSMaxY(rect) - gridOrigin.y) / spacing);
    for (; curLine<=endLine; curLine++) {
        [gridPath moveToPoint:NSMakePoint(NSMinX(rect), (curLine * spacing) + gridOrigin.y)];
        [gridPath lineToPoint:NSMakePoint(NSMaxX(rect), (curLine * spacing) + gridOrigin.y)];
    }
	
    [gridPath setLineWidth:0.0];
    [gridPath stroke];
}