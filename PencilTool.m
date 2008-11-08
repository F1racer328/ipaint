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

#import "PencilTool.h"

@implementation PencilTool

// Generates the path to be drawn to the image
- (NSBezierPath *)pathFromPoint:(NSPoint)begin toPoint:(NSPoint)end
{
	if (path) {
		[path release];
	}
	path = [[NSBezierPath alloc] init];
	[path setLineWidth:lineWidth];
	[path setLineCapStyle:NSRoundLineCapStyle];
	[path moveToPoint:begin];
	[path lineToPoint:end];

	return path;
}

- (void)performDrawAtPoint:(NSPoint)point withMainImage:(NSImage *)anImage secondImage:(NSImage *)secondImage mouseEvent:(int)event
{
	if (event == MOUSE_UP) {
		[NSApp sendAction:@selector(prepUndo:)
					   to:nil
					 from:nil];
		[anImage lockFocus];
		[secondImage drawAtPoint:NSZeroPoint
						fromRect:NSZeroRect
					   operation:NSCompositeSourceOver 
						fraction:1.0];
		[anImage unlockFocus];
		if (secondImage) {
			[secondImage release];
		}
		secondImage = [[NSImage alloc] initWithSize:[anImage size]];		
	} else {
		[secondImage lockFocus]; 
		
		[[NSGraphicsContext currentContext] setShouldAntialias:NO];
		[frontColor setStroke];
		[[self pathFromPoint:savedPoint toPoint:point] stroke];
		
		savedPoint = point;
		
		[secondImage unlockFocus];
	}
}

- (NSString *)name
{
	return @"Pencil";
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
