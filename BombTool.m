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

#import "BombTool.h"

@implementation BombTool

- (NSBezierPath *)pathFromPoint:(NSPoint)begin toPoint:(NSPoint)end
{
	return nil;
}

- (void)performDrawAtPoint:(NSPoint)point withMainImage:(NSImage *)anImage secondImage:(NSImage *)secondImage mouseEvent:(int)event;
{	
	if (event == MOUSE_DOWN) {
		i = 0;
		rect = NSZeroRect;
		p = point;
		image = secondImage;
		mainImage = anImage;
		r = [backColor redComponent];
		g = [backColor greenComponent];
		b = [backColor blueComponent];
		if (shift) {
			bombSpeed = 1; //bomb speed for shift clicking.  Default is 2
		} else {
			bombSpeed = 50; //bomb speed for regular clicking.  Default is 25
		}
		max = sqrt([anImage size].width*[anImage size].width + [anImage size].height*[anImage size].height);
		bombTimer = [NSTimer scheduledTimerWithTimeInterval:0.000001
													 target:self
												   selector:@selector(drawNewCircle:)
												   userInfo:nil
													repeats:YES];
		isExploding = YES;
	}
}


- (void)drawNewCircle:(NSTimer *)timer
{
	if (i < max) {
		[image lockFocus];
		rect.origin.x = p.x - i;
		rect.origin.y = p.y - i;
		rect.size.width = 2*i;
		rect.size.height = 2*i;
		[[NSColor colorWithCalibratedRed:r
								   green:g
									blue:b
								   alpha:1.0] set];		
		[[NSBezierPath bezierPathWithOvalInRect:rect] fill];
		[image unlockFocus];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SWRefresh" object:nil];
		i += bombSpeed;
	} else {
		[self endExplosion:timer];
	}
}

- (void)endExplosion:(NSTimer *)timer
{
	[timer invalidate];
	[NSApp sendAction:@selector(prepUndo:)
				   to:nil
				 from:nil];
	[mainImage lockFocus];
	[[NSColor colorWithCalibratedRed:r
							   green:g
								blue:b
							   alpha:1.0] set];
	[[NSBezierPath bezierPathWithRect:NSMakeRect(0, 0, [mainImage size].width, [mainImage size].height)] fill];
	
	[mainImage unlockFocus];
	[image release];
	image = [[NSImage alloc] initWithSize:[mainImage size]];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SWRefresh" object:nil];
	isExploding = NO;
}

- (NSString *)name
{
	return @"Bomb";
}

- (NSCursor *)cursor
{
	return [NSCursor pointingHandCursor];
}

- (BOOL)shouldShowFillOptions
{
	return NO;
}

// Overwrite
- (void)tieUpLooseEnds
{
	if (isExploding) {
		[self endExplosion:bombTimer];
	}
}
@end
