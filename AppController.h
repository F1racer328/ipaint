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
#import <Sparkle/Sparkle.h>
#import "PreferenceController.h"
#import "ToolboxController.h"
#import "GridPanelController.h"

@interface AppController : NSObject
{
	PreferenceController *preferenceController;
}
- (IBAction)showPreferencePanel:(id)sender;
- (IBAction)showToolboxPanel:(id)sender;
- (IBAction)showGridPanel:(id)sender;

// A few methods to open a web page in the user's browser of choice
- (IBAction)donate:(id)sender;
- (IBAction)forums:(id)sender;
- (IBAction)contact:(id)sender;

// Overrides "Quit" to remove a sheet, if present
- (IBAction)quit:(id)sender;


@end
