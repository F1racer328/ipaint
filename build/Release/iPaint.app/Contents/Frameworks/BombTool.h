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
#import "Tool.h"


@interface BombTool : Tool {
	NSRect rect;
	int max;
	int i;
	int bombSpeed;
	BOOL isExploding;
	NSPoint p;
	NSImage *image;
	NSImage *mainImage;
	NSTimer *bombTimer;
	float r,g,b;
}

- (void)drawNewCircle:(NSTimer *)timer;
- (void)endExplosion:(NSTimer *)timer;


@end
