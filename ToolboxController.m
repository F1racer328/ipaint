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

#import "ToolboxController.h"

@implementation ToolboxController

+ (id)sharedToolboxPanelController {
	// Static ensures that only one will exist
    static ToolboxController *sharedToolboxPanelController = nil;
	
    if (!sharedToolboxPanelController) {
        sharedToolboxPanelController = [[ToolboxController allocWithZone:NULL] init];
    }
	
    return sharedToolboxPanelController;
}

- (id)init
{
	if(self = [super initWithWindowNibName:@"Toolbox"]) {
		// Lots o' tools
		toolList = [[NSMutableDictionary alloc] init];
		[toolList setObject:[[PencilTool alloc] init] forKey:@"Pencil"];
		[toolList setObject:[[RectangleTool alloc] init] forKey:@"Rectangle"];
		[toolList setObject:[[EllipseTool alloc] init] forKey:@"Ellipse"];
		[toolList setObject:[[LineTool alloc] init] forKey:@"Line"];
		[toolList setObject:[[CurveTool alloc] init] forKey:@"Curve"];
		[toolList setObject:[[EraserTool alloc] init] forKey:@"Eraser"];
		[toolList setObject:[[FillTool alloc] init] forKey:@"Fill"];
		[toolList setObject:[[SelectionTool alloc] init] forKey:@"Selection"];
		[toolList setObject:[[TextTool alloc] init] forKey:@"Text"];
		[toolList setObject:[[BombTool alloc] init] forKey:@"Bomb"];
		
		// It's a panel, not a real window
		[(NSPanel *)[super window] setBecomesKeyOnlyIfNeeded:YES];
		
//		[foregroundColorWell setIgnoresMultiClick:YES];
//		[backgroundColorWell setIgnoresMultiClick:YES];
		
	}
	return self;
}

- (void)awakeFromNib
{
	[lineSlider setIntValue:3];
	[self changeForegroundColor:foregroundColorWell];
	[self changeBackgroundColor:backgroundColorWell];
	[self changeTool:toolMatrix];
	[self changeFill:fillMatrix];
	//	if (NSAppKitVersionNumber < 949) {
	//		// Leopard's version number is 949. We only want this change to occur on 
	//		// Tiger machines, so make sure that NSAppKitVersionNumber is less than
	//		// that of Leopard (Tiger's is generally around 824)
	//		[[toolMatrix window] setBackgroundColor:[NSColor colorWithDeviceWhite:0.9098 alpha:1.0]];
	//	}
}

- (void)windowDidLoad
{
	//NSLog(@"Nib file is loaded"); 
}


////////////////////////////////////////////////////////////////////////////////
//////////		Accessors, aka "Getters"
////////////////////////////////////////////////////////////////////////////////


- (Tool *)currentTool
{
	return currentTool;
}

- (NSColor *)foregroundColor
{
	return foregroundColor;
}

- (NSColor *)backgroundColor
{
	return backgroundColor;
}

- (int)lineWidth
{
	return lineWidth;
}


////////////////////////////////////////////////////////////////////////////////
//////////		Tool changing
////////////////////////////////////////////////////////////////////////////////


- (IBAction)changeForegroundColor:(id)sender
{
	foregroundColor = [sender color];

	[currentTool setFrontColor:foregroundColor];
}

- (IBAction)changeBackgroundColor:(id)sender
{
	backgroundColor = [sender color];
	
	[currentTool setBackColor:backgroundColor];
}

// Called whenever one of the buttons in the tool matrix is pressed
- (IBAction)changeTool:(id)sender
{
	[currentTool tieUpLooseEnds];
	currentTool = [toolList objectForKey:[[sender selectedCell] title]];
	
	[currentTool setFrontColor:foregroundColor
					 backColor:backgroundColor
					 lineWidth:2 * [lineSlider intValue] - 1
					shouldFill:shouldFill
				  shouldStroke:shouldStroke];
	
	// Handle resizing of tool palette, based on which tool is selected
	NSRect aRect = [[super window] frame];
	if ([currentTool shouldShowFillOptions]) {
		aRect.origin.y += (aRect.size.height - 400);
		aRect.size.height = 400;
		[[super window] setFrame:aRect display:YES animate:YES];
		[fillMatrix setHidden:NO];	
	} else {
		aRect.origin.y += (aRect.size.height - 300);
		aRect.size.height = 300;
		[fillMatrix setHidden:YES];
		[[super window] setFrame:aRect display:YES animate:YES];
	}
}

// The bonus NSMatrix, only for ovals and rectangles
- (IBAction)changeFill:(id)sender
{
	if ([[[fillMatrix selectedCell] title] isEqualToString:@"No Fill"]) {
		shouldFill = NO;
		shouldStroke = YES;
	} else if ([[[fillMatrix selectedCell] title] isEqualToString:@"No Border"]) {
		shouldFill = YES;
		shouldStroke = NO;
	} else {
		shouldFill = YES;
		shouldStroke = YES;
	}
	[currentTool shouldFill:shouldFill stroke:shouldStroke];
}

// The slider moved, meaning the line width should change
- (IBAction)changeLineWidth:(id)sender
{
	// Allows for more line widths with less tick marks
	lineWidth = 2 * [sender intValue] - 1;
	[currentTool setLineWidth:lineWidth];
}


////////////////////////////////////////////////////////////////////////////////
//////////		Other miscellaneous methods
////////////////////////////////////////////////////////////////////////////////

// If "Paste" or "Select All" is chosen, we should switch to the scissors tool
- (void)switchToScissors:(id)sender
{
	//currentTool = [toolList objectForKey:name];
	[toolMatrix selectCellWithTag:2];
	[self changeTool:toolMatrix];
}

- (IBAction)showWindow:(id)sender {
	[[self window] orderFront:sender];
}

- (IBAction)hideWindow:(id)sender {
	[[self window] orderOut:sender];
}

// Replaces the front color with the back, and vice-versa
- (IBAction)flipColors:(id)sender {
	[foregroundColorWell setColor:backgroundColor];
	[backgroundColorWell setColor:foregroundColor];
	[self changeForegroundColor:foregroundColorWell];
	[self changeBackgroundColor:backgroundColorWell];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

@end
