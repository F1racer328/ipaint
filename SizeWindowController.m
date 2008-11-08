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

#import "SizeWindowController.h"


@implementation SizeWindowController

- (id)init
{
	self = [super initWithWindowNibName:@"SizeWindow"];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(textDidChange:)
												 name:NSControlTextDidChangeNotification
											   object:nil];
	return self;
}

- (void)awakeFromNib
{
	// Read the defaults for width and height
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSNumber *width = [defaults objectForKey:@"HorizontalSize"];
	NSNumber *height = [defaults objectForKey:@"VerticalSize"];
	[widthField setIntValue:[width intValue]];
	[heightField setIntValue:[height intValue]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NSControlTextDidChangeNotification 
														object:nil];
}

// If the user changes the size of the image using the NSPopUpButton,
// change the two text fields to stay synchronized with it
- (IBAction)changeSizeButton:(id)sender
{
	NSString *newSize = [sizeButton titleOfSelectedItem];
	
	if ([newSize isEqualToString:@"640 x 480"]) {
		[widthField setIntValue:640];
		[heightField setIntValue:480];
	} else if ([newSize isEqualToString:@"800 x 600"]) {
		[widthField setIntValue:800];
		[heightField setIntValue:600];
	} else if ([newSize isEqualToString:@"1024 x 768"]) {
		[widthField setIntValue:1024];
		[heightField setIntValue:768];
	} else if ([newSize isEqualToString:@"1280 x 1024"]) {
		[widthField setIntValue:1280];
		[heightField setIntValue:1024];
	}
}

// Each time the user types in the width or height field, check to see if it's
// one of the preset values in the popup button
- (void)textDidChange:(NSNotification *)aNotification
{
	if ([widthField intValue] == 640 && [heightField intValue] == 480) {
		[sizeButton selectItemWithTitle:@"640 x 480"];
	} else if ([widthField intValue] == 800 && [heightField intValue] == 600) {
		[sizeButton selectItemWithTitle:@"800 x 600"];
	} else if ([widthField intValue] == 1024 && [heightField intValue] == 768) {
		[sizeButton selectItemWithTitle:@"1024 x 768"];
	} else if ([widthField intValue] == 1280 && [heightField intValue] == 1024) {
		[sizeButton selectItemWithTitle:@"1280 x 1024"];
	} else {
		[sizeButton selectItemWithTitle:@"Custom"];
	}
}

// After they click OK or Cancel
- (IBAction)endSheet:(id)sender
{
	if ([[sender title] isEqualTo:@"OK"]){
		if ([widthField intValue] > 0 && [heightField intValue] > 0) {
			
			// Save entered values as defaults
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			NSNumber *width = [NSNumber numberWithInt:[widthField intValue]];
			NSNumber *height = [NSNumber numberWithInt:[heightField intValue]];
			[defaults setObject:width forKey:@"HorizontalSize"];
			[defaults setObject:height forKey:@"VerticalSize"];
			
			[[self window] orderOut:sender];
			[NSApp endSheet:[self window] returnCode:NSOKButton];
		} else {
			NSBeep();
		}
	} else {
		[[self window] orderOut:sender];
		[NSApp endSheet:[self window] returnCode:NSCancelButton];
	}	
}

- (int)width
{
	return [widthField intValue];
}

- (int)height
{
	return [heightField intValue];
}


@end
