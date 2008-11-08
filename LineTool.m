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

#import "LineTool.h"

@implementation LineTool

- (NSBezierPath *)pathFromPoint:(NSPoint)begin toPoint:(NSPoint)end
{
	if (path) {
		[path release];
	}
	path = [[NSBezierPath alloc] init];
	[path setLineWidth:lineWidth];
	[path setLineCapStyle:NSRoundLineCapStyle];
	[path moveToPoint:begin];
	if (shift) {
		// Here comes the crazy math. First, we find the length of the hypotenuse of the
		// imaginary triangle formed by the line
		double hypotenuse = sqrt(pow((end.x-begin.x),2)+pow((end.y-begin.y),2));
		
		// Size is the base/height of the 45¼ triangle
		double size = hypotenuse/sqrt(2);
		
		// x and y are either positive or negative 1
		int x = (end.x-begin.x) / abs(end.x-begin.x);
		int y = (end.y-begin.y) / abs(end.y-begin.y);
		
		// Theta is the angle formed by the mouse, in degrees (rad * 180/¹)
		// atan()'s result is in radians
		double theta = 180*atan((end.y-begin.y)/(end.x-begin.x)) / 3.1415926535;
		
		// Deciding whether it should be horizontal, vertical, or at 45¼
		if (abs(theta) <= 67.5 && abs(theta) >= 22.5) {
			[path relativeLineToPoint:NSMakePoint(size*x, size*y)];
		} else if (abs(theta) > 67.5) {
			[path relativeLineToPoint:NSMakePoint(0, (end.y-begin.y))];
		} else {
			[path relativeLineToPoint:NSMakePoint((end.x - begin.x), 0)];
		}
	} else {
		[path lineToPoint:end];
	}
	
	return path;
}

- (void)performDrawAtPoint:(NSPoint)point withMainImage:(NSImage *)anImage secondImage:(NSImage *)secondImage mouseEvent:(int)event
{	
	if (secondImage) {
		[secondImage release];
	}
	secondImage = [[NSImage alloc] initWithSize:[anImage size]];
	
	if (event == MOUSE_UP) {
		[NSApp sendAction:@selector(prepUndo:)
					   to:nil
					 from:nil];		
		drawToMe = anImage;
	} else {
		drawToMe = secondImage;
	}
	
	[drawToMe lockFocus]; 
	[[NSGraphicsContext currentContext] setShouldAntialias:NO];
	
	[frontColor setStroke];
	[[self pathFromPoint:savedPoint toPoint:point] stroke];
	
	[drawToMe unlockFocus];
	return;
	
}


- (NSString *)name
{
	return @"Line";
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
