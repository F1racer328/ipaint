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

#import "SelectionTool.h"

@implementation SelectionTool

- (id)init
{
	if (self = [super init]) {
		deltax = deltay = 0;
		isSelected = NO;
	}
	return self;
}

- (NSBezierPath *)pathFromPoint:(NSPoint)begin toPoint:(NSPoint)end
{
	if (path) {
		[path release];
	}
	path = [[NSBezierPath alloc] init];
	[path setLineWidth:0.0];
	float array[2];
	array[0] = 5.0;
	array[1] = 3.0;
	[path setLineDash:array count:2 phase:5.0];
	[path setLineCapStyle:NSSquareLineCapStyle];	

	//if (shift) {
		// double size = fmin(abs(end.x-begin.x),abs(end.y-begin.y));
		// We need something here! It's trickier than it looks.
	//} else {
		clippingRect = NSMakeRect(fmin(begin.x, end.x) + 0.5, fmin(begin.y, end.y) + 0.5, abs(end.x - begin.x), abs(end.y - begin.y));
	//}
	
	[path appendBezierPathWithRect:
		NSMakeRect(clippingRect.origin.x-1, clippingRect.origin.y-1, clippingRect.size.width+1.5, clippingRect.size.height+1.5)];

	return path;	
}

- (void)performDrawAtPoint:(NSPoint)point withMainImage:(NSImage *)anImage secondImage:(NSImage *)secondImage mouseEvent:(int)event
{	
	_secondImage = secondImage;
	_anImage = anImage;
	
	// If the rectangle has already been drawn
	if (isSelected) {
		if ([[NSBezierPath bezierPathWithRect:clippingRect] containsPoint:point] || event == MOUSE_DRAGGED) {
			if (event == MOUSE_DOWN) {
				previousPoint = point;
			}
			
			if (shift) {				
				// Are we already moving horizontally/vertically?
				if (isAlreadyShifting) {
					if (direction == 'X') {
						deltay = 0;
						deltax += point.x - previousPoint.x;
					} else if (direction == 'Y') {
						deltax = 0;
						deltay += point.y - previousPoint.y;
					} else {
						NSLog(@"Houston, we have a problem");
					}
				} else {
					isAlreadyShifting = YES;
					int dx = abs(point.x - previousPoint.x);
					int dy = abs(point.y - previousPoint.y);
					
					if (dx > dy) {
						direction = 'X';
					} else {
						direction = 'Y';
					}
				}			
			} else {
				isAlreadyShifting = NO;
				deltax += point.x - previousPoint.x;
				deltay += point.y - previousPoint.y;
			}
			
			previousPoint = point;
			
			// Do the moving thing
			
			[secondImage release];
			secondImage = [[NSImage alloc] initWithSize:[anImage size]];
			[secondImage lockFocus];
			[thirdImage drawAtPoint:NSMakePoint(deltax, deltay)
						   fromRect:NSZeroRect
						  operation:NSCompositeSourceOver
						   fraction:1.0];
			[secondImage unlockFocus];
			
			clippingRect.origin.x = oldOrigin.x + deltax;
			clippingRect.origin.y = oldOrigin.y + deltay;
			
		} else {
			[self tieUpLooseEnds];
		}
		
	} else {
		deltax = deltay = 0;
		if (event == MOUSE_DOWN) {
			[anImage lockFocus];
			[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
			[secondImage drawInRect:clippingRect
						   fromRect:clippingRect
						  operation:NSCompositeSourceOver
						   fraction:1.0];
			[anImage unlockFocus];
		}
		if (secondImage) {
			[secondImage release];
		}
		secondImage = [[NSImage alloc] initWithSize:[anImage size]];
		
		// Taking care of the outer bounds of the image
		if (point.x <= 0)
			point.x = 1;
		if (point.y <= 0)
			point.y = 1;
		if (point.x >= [anImage size].width)
			point.x = [anImage size].width - 1;
		if (point.y >= [anImage size].height)
			point.y = [anImage size].height - 1;
		
		[secondImage lockFocus]; 
		[[NSGraphicsContext currentContext] setShouldAntialias:NO];
		[[NSColor darkGrayColor] setStroke];
		[[self pathFromPoint:savedPoint toPoint:point] stroke];
		[secondImage unlockFocus];
				
		if ((event == MOUSE_UP) && (point.x != savedPoint.x) && (point.y != savedPoint.y)) {
			// Copy the rectangle's contents to the second image
			[secondImage lockFocus];
			[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
			[secondImage lockFocus];

			// This is without transparency
			[anImage drawInRect:clippingRect
					   fromRect:clippingRect
					  operation:NSCompositeSourceOver 
					   fraction:1.0];

			[secondImage unlockFocus];
			
			thirdImage = [[NSImage alloc] initWithSize:[anImage size]];
			[thirdImage lockFocus];
			[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
			[secondImage drawAtPoint:NSZeroPoint
							fromRect:NSZeroRect
						   operation:NSCompositeSourceOver
							fraction:1.0];
			[thirdImage unlockFocus];
			
			if (imageRep) {
				[imageRep release];
			}
			imageRep = [[NSBitmapImageRep alloc] initWithData:[anImage TIFFRepresentation]];
			
			// Delete it from the main image
			[anImage lockFocus];
			[backColor set];
			[NSBezierPath fillRect:clippingRect];
			[anImage unlockFocus];
			
			oldOrigin = clippingRect.origin;
			
			isSelected = YES;
		}
	}
}

- (void)tieUpLooseEnds
{
	[super tieUpLooseEnds];
	
	[NSApp sendAction:@selector(prepUndo:)
				   to:nil
				 from:[imageRep TIFFRepresentation]];
	
	// Checking to see if references have been made; otherwise causes strange drawing bugs
	if (_secondImage && _anImage) {
		//NSLog(@"Yep, they exist");
		[_anImage lockFocus];
		//[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
		
		[_secondImage drawInRect:clippingRect
						fromRect:clippingRect
					   operation:NSCompositeSourceOver
						fraction:1.0];
		[_anImage unlockFocus];
	}
	
	
	isSelected = NO;
	clippingRect = NSZeroRect;
}

- (NSRect)clippingRect
{
	return clippingRect;
}

// Called from the PaintView when an image is pasted
- (void)setClippingRect:(NSRect)rect forImage:(NSImage *)image
{	
	_secondImage = image;
	deltax = deltay = 0;
	[image lockFocus];
	[[NSGraphicsContext currentContext] setShouldAntialias:NO];
	
	clippingRect = rect;
	oldOrigin = rect.origin;
	
	isSelected = YES;
	[[NSColor darkGrayColor] setStroke];
	[[self pathFromPoint:rect.origin
				 toPoint:NSMakePoint(rect.size.width+rect.origin.x-3,rect.size.height+rect.origin.y-3)] stroke];
	[image unlockFocus];
	
	if (thirdImage) {
		[thirdImage release];
	}
	thirdImage = [[NSImage alloc] initWithSize:[image size]];
	[thirdImage lockFocus];
	[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
	[image drawAtPoint:NSZeroPoint
			  fromRect:NSZeroRect
			 operation:NSCompositeSourceOver
			  fraction:1.0];
	[thirdImage unlockFocus];
}

- (NSData *)imageData
{
	return [imageRep TIFFRepresentation];
}

- (BOOL)isSelected
{
	return isSelected;
}

- (NSString *)name
{
	return @"Selection";
}

- (NSCursor *)cursor
{
	return [NSCursor crosshairCursor];
}

- (BOOL)shouldShowFillOptions
{
	return NO;
}

@end
