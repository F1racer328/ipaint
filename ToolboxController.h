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
#import "Tools.h"
#import "SWColorWell.h"

@interface ToolboxController : NSWindowController {
	IBOutlet SWColorWell *foregroundColorWell;
	IBOutlet SWColorWell *backgroundColorWell;
	IBOutlet NSMatrix *toolMatrix;
	IBOutlet NSMatrix *fillMatrix;
	IBOutlet NSSlider *lineSlider;
	NSColor *foregroundColor;
	NSColor *backgroundColor;
	Tool *currentTool;
	int lineWidth;
	BOOL shouldFill;
	BOOL shouldStroke;
	NSMutableDictionary *toolList;
	NSNotificationCenter *nc;
}

+ (id)sharedToolboxPanelController;

// Accessors
- (Tool *)currentTool;
- (NSColor *)foregroundColor;
- (NSColor *)backgroundColor;
- (int)lineWidth;

// Mutators
- (IBAction)changeForegroundColor:(id)sender;
- (IBAction)changeBackgroundColor:(id)sender;
- (IBAction)changeTool:(id)sender;
- (IBAction)changeFill:(id)sender;
- (IBAction)changeLineWidth:(id)sender;

// Other stuff
- (void)switchToScissors:(id)sender;
- (IBAction)showWindow:(id)sender;
- (IBAction)hideWindow:(id)sender;
- (IBAction)flipColors:(id)sender;


@end
