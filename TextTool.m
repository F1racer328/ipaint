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

#import "TextTool.h"

@implementation TextTool

- (id)init
{
	if (self = [super init]) {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(insertText:)
													 name:@"SWTextEntered"
												   object:nil];
		image = [NSImage alloc];
	}
	return self;
}

- (NSBezierPath *)pathFromPoint:(NSPoint)begin toPoint:(NSPoint)end
{
	return nil;
}

- (void)performDrawAtPoint:(NSPoint)point withMainImage:(NSImage *)anImage secondImage:(NSImage *)secondImage mouseEvent:(int)event
{
	image = anImage;
	
	if (event == MOUSE_DOWN) {
		[NSApp sendAction:@selector(prepUndo:)
					   to:nil
					 from:nil];
		aPoint = point;
		if (canInsert) {
			[anImage lockFocus];
			
			[stringToInsert drawAtPoint:point];
			[anImage unlockFocus];
			canInsert = NO;
			[[NSNotificationCenter defaultCenter] postNotificationName:@"SWRefresh" object:nil];
		} else {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"SWText" object:frontColor];
		} 
	}
}

// Summoned by the NSNotificationCenter when the user clicks "OK" in the sheet
- (void)insertText:(NSNotification *)note
{
	if (stringToInsert) {
		[stringToInsert release];
	}
	stringToInsert = [[NSAttributedString alloc] initWithAttributedString:[[note userInfo] objectForKey:@"newText"]];
	canInsert = YES;
	[self performDrawAtPoint:aPoint withMainImage:image secondImage:nil mouseEvent:MOUSE_DOWN];
}

- (NSString *)name
{
	return @"Text";
}

- (NSCursor *)cursor
{
	return [NSCursor IBeamCursor];
}

- (BOOL)shouldShowFillOptions
{
	return NO;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

@end
