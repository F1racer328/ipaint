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

#import <Cocoa/Cocoa.h>

#define MOUSE_DOWN 0
#define MOUSE_DRAGGED 1
#define MOUSE_UP 2

@interface Tool : NSObject {
	NSColor *frontColor;
	NSColor *backColor;
	NSImage *drawToMe;
	NSImage *_anImage;
	NSImage *_secondImage;
	NSBezierPath *path;
	double lineWidth;
	BOOL shouldFill;
	BOOL shouldStroke;
	BOOL shift;
	NSPoint savedPoint;
}

// Some setters
- (void)setFrontColor:(NSColor *)front;
- (void)setBackColor:(NSColor *)back;
- (void)setLineWidth:(double)width;
- (void)shouldFill:(BOOL)fill stroke:(BOOL)stroke;


- (NSPoint)savedPoint;
- (NSString *)type;
- (void)setFrontColor:(NSColor *)front backColor:(NSColor *)back lineWidth:(double)width shouldFill:(BOOL)fill shouldStroke:(BOOL)stroke;
- (void)setShiftModifier:(int)isShifted;
- (void)setSavedPoint:(NSPoint)aPoint;
- (void)tieUpLooseEnds;
- (BOOL)isEqualToTool:(Tool *)aTool;

@end

@interface Tool (Abstract)

- (NSBezierPath *)pathFromPoint:(NSPoint)begin toPoint:(NSPoint)end;
- (void)performDrawAtPoint:(NSPoint)point withMainImage:(NSImage *)anImage secondImage:(NSImage *)secondImage mouseEvent:(int)event;
- (NSString *)name;
- (NSCursor *)cursor;
- (BOOL)shouldShowFillOptions;
- (void)createImageRep:(NSImage *)anImage;

@end
