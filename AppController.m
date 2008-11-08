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

#import "AppController.h"

@implementation AppController


- (id)init
{
	// Tiger's AppKit version is ³ 824, while older versions of the OS hae a lower number. This 
	// program requires 10.4 or higher, so this checks to make sure. I'm sure there's an easier
	// way to do this, but whatever - this works fine
	
	if (NSAppKitVersionNumber < 949) {
		// Pop up a warning dialog, 
		NSRunAlertPanel(@"Sorry, this program requires Mac OS X 10.5.5 or later", @"You are running %@", 
						@"OK", nil, nil, [[NSProcessInfo alloc] operatingSystemVersionString]);
		
		// then quit the program
		[NSApp terminate:self]; 
		
	} else if (self = [super init]) {
		
		// Create a dictionary
		NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
		
		// Put defaults in the dictionary
		[defaultValues setObject:[NSNumber numberWithInt:640] forKey:@"HorizontalSize"];
		[defaultValues setObject:[NSNumber numberWithInt:480] forKey:@"VerticalSize"];
		
		// Register the dictionary of defaults
		[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];		
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(killTheSheet:) 
													 name:SUUpdaterWillRestartNotification 
												   object:nil];

		[NSColorPanel setPickerMode:NSCrayonModeColorPanel];
		[[ToolboxController sharedToolboxPanelController] showWindow:self];
	}
	
	return self;
}

// Makes the toolbox panel appear and disappear
- (IBAction)showToolboxPanel:(id)sender
{
	ToolboxController *toolboxPanel = [ToolboxController sharedToolboxPanelController];
	if ([[toolboxPanel window] isVisible]) {
		[toolboxPanel hideWindow:self];
	} else {
		[toolboxPanel showWindow:self];
	}
}

// Makes the grid panel appear and disappear
- (IBAction)showGridPanel:(id)sender {
	GridPanelController *gridPanel = [GridPanelController sharedGridPanelController];
	if ([[gridPanel window] isVisible]) {
		[gridPanel hideWindow:self];
	} else {
		[gridPanel showWindow:self];
	}
}

- (IBAction)showPreferencePanel:(id)sender
{
	if (!preferenceController) {
		preferenceController = [[PreferenceController alloc] init];
	}
	[preferenceController showWindow:self];
}

- (void)killTheSheet:(id)sender
{
	NSEnumerator *enumerator = [[NSApp windows] objectEnumerator];
	id element;
	
	while(element = [enumerator nextObject])
    {
		//[element orderOut:nil];
		[NSApp endSheet:element returnCode:NSCancelButton];
    }
}

- (IBAction)quit:(id)sender
{
	[self killTheSheet:nil];
	[NSApp terminate:self];
}


////////////////////////////////////////////////////////////////////////////////
//////////		URLs to web pages/email addresses
////////////////////////////////////////////////////////////////////////////////

- (IBAction)donate:(id)sender
{
	NSURL *url = [NSURL URLWithString:@"http://sourceforge.net/project/project_donations.php?group_id=191288"];
	
	// Open the URL.
	(void) [[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction)forums:(id)sender
{
	NSURL *url = [NSURL URLWithString:@"http://sourceforge.net/forum/?group_id=191288"];
	
	// Open the URL.
	(void) [[NSWorkspace sharedWorkspace] openURL:url];
	
}

- (IBAction)contact:(id)sender
{
	NSURL *url = [NSURL URLWithString:@"mailto:soggywaffles@gmail.com"];
	
	// Open the URL.
	(void) [[NSWorkspace sharedWorkspace] openURL:url];
}

- (void)dealloc
{
	[preferenceController release];
	[super dealloc];
}

@end
