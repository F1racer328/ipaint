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

#import "Tool.h"

@implementation Tool

- (id)init
{
	if(self = [super init]) {
		path = [[NSBezierPath alloc] init];
	}
	return self;
}

- (NSString *)type
{
	return @"Tool";
}

- (double)lineWidth
{
	return lineWidth;
}

- (void)setFrontColor:(NSColor *)front
{
	frontColor = front;
}

- (void)setBackColor:(NSColor *)back
{
	backColor = back;
}

- (void)setLineWidth:(double)width
{
	lineWidth = width;
}

- (void)shouldFill:(BOOL)fill stroke:(BOOL)stroke
{
	shouldFill = fill;
	shouldStroke = stroke;
}

- (void)setFrontColor:(NSColor *)front 
			backColor:(NSColor *)back 
			lineWidth:(double)width 
		   shouldFill:(BOOL)fill 
		 shouldStroke:(BOOL)stroke
{
	frontColor = front;
	backColor = back;
	lineWidth = width;
	shouldFill = fill;
	shouldStroke = stroke;
}

- (NSPoint)savedPoint
{
	return savedPoint;
}

- (void)setSavedPoint:(NSPoint)aPoint
{
	savedPoint = aPoint;
}

- (void)setShiftModifier:(int)isShifted
{
	shift = !(isShifted == 0);
}

- (void)tieUpLooseEnds
{
	// Must be overridden if you want something more interesting to happen
	//NSLog(@"%@ tool is tying up loose ends", [self name]);
}

- (BOOL)isEqualToTool:(Tool *)aTool
{
	return ([[self name] isEqualTo:[aTool name]]);
}

- (void)createImageRep:(NSImage *)anImage
{
	//imageRep = [[NSBitmapImageRep alloc] initWithData:[anImage TIFFRepresentation]];
}

@end
