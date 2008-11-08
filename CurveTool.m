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

#import "CurveTool.h"

@implementation CurveTool

- (id)init
{
	if (self = [super init]) {
		numberOfClicks = 0;
	}
	return self;
}

- (NSBezierPath *)pathFromPoint:(NSPoint)begin toPoint:(NSPoint)end
{
	if (path) {
		[path release];
	}
	path = [[NSBezierPath alloc] init];
	[path setLineWidth:lineWidth];
	[path setLineCapStyle:NSRoundLineCapStyle];
	[path moveToPoint:beginPoint];
	
	// Shift should only affect the line on the first click
	if (shift && numberOfClicks == 1) {

		// Here comes the crazy math. First, we find the length of the hypotenuse of the
		// imaginary triangle formed by the line
		double hypotenuse = sqrt(pow((endPoint.x-beginPoint.x),2)+pow((endPoint.y-beginPoint.y),2));
		
		// Size is the base/height of the 45º triangle
		double size = hypotenuse/sqrt(2);
		
		// x and y are either positive or negative 1
		int x = (endPoint.x-beginPoint.x) / abs(endPoint.x-beginPoint.x);
		int y = (endPoint.y-beginPoint.y) / abs(endPoint.y-beginPoint.y);
		
		// Theta is the angle formed by the mouse, in degrees (rad * 180/π)
		// atan()'s result is in radians
		double theta = 180*atan((endPoint.y-beginPoint.y)/(endPoint.x-beginPoint.x)) / 3.1415926535;
		
		// Deciding whether it should be horizontal, vertical, or at 45º
		if (abs(theta) <= 67.5 && abs(theta) >= 22.5) {
			endPoint = NSMakePoint(size*x + beginPoint.x, size*y + beginPoint.y);
		} else if (abs(theta) > 67.5) {
			endPoint = NSMakePoint(0+beginPoint.x, (endPoint.y-beginPoint.y)+beginPoint.y);
		} else {
			endPoint = NSMakePoint((endPoint.x - beginPoint.x)+beginPoint.x, 0+beginPoint.y);
		}
		
		// Gotta keep it from curving too early - we changed endPoint, so we change cp2 on click 1
		cp2 = endPoint;

	}
	[path curveToPoint:endPoint controlPoint1:cp1 controlPoint2:cp2];
	
	return path;
}


- (void)performDrawAtPoint:(NSPoint)point withMainImage:(NSImage *)anImage secondImage:(NSImage *)secondImage mouseEvent:(int)event
{	
	if (event == MOUSE_DOWN) {
		numberOfClicks++;
	}
	if (secondImage) {
		[secondImage release];
	}
	secondImage = [[NSImage alloc] initWithSize:[anImage size]];
	drawToMe = secondImage;
	
	_secondImage = secondImage;
	_anImage = anImage;
	
	switch(numberOfClicks) {
		case 1:
			beginPoint = cp1 = savedPoint;
			endPoint = cp2 = point;
			break;
		case 2:
			cp1 = point;
			break;
		case 3:
			cp2 = point;
			if (event == MOUSE_UP) {
				[NSApp sendAction:@selector(prepUndo:)
							   to:nil
							 from:nil];				
				drawToMe = anImage;
				numberOfClicks = 0;
			}
			break;
		default:
			break;
	}
	
	[drawToMe lockFocus]; 
	[[NSGraphicsContext currentContext] setShouldAntialias:NO];
	
	[frontColor setStroke];
	[[self pathFromPoint:savedPoint toPoint:point] stroke];
	
	[drawToMe unlockFocus];
	return;
}

- (void)setNumberOfClicks:(int)clicks
{
	numberOfClicks = clicks;
}

- (int)numberOfClicks
{
	return numberOfClicks;
}

- (void)tieUpLooseEnds
{
	[super tieUpLooseEnds];
	
	// Checking to see if references have been made; otherwise causes strange drawing bugs
	if (_secondImage && _anImage && numberOfClicks > 0) {
		
		[NSApp sendAction:@selector(prepUndo:)
					   to:nil
					 from:nil];	
		
		[_anImage lockFocus];
		[_secondImage drawAtPoint:NSZeroPoint
						 fromRect:NSZeroRect
						operation:NSCompositeSourceOver
						 fraction:1.0];
		[_anImage unlockFocus];
	}
	
	numberOfClicks = 0;
}

- (NSString *)name
{
	return @"Curve";
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
