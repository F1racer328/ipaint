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
#import "PaintView.h"
#import "Tools.h"
#import "ScalingScrollView.h"
#import "CenteringClipView.h"
#import "ToolboxController.h"
#import "TextToolWindowController.h"
#import "SizeWindowController.h"

@interface MyDocument : NSDocument
{
	IBOutlet PaintView *paintView;
	IBOutlet NSWindow *window;
	IBOutlet ScalingScrollView *scrollView;	/* ScrollView containing document */
	
	// A bunch of controllers and one view
	ToolboxController *toolboxController;
	CenteringClipView *clipView;
	TextToolWindowController *textController;
	SizeWindowController *sizeController;
	NSImage *openedImage;
	NSColor *frontColor;
	NSColor *backColor;
	Tool *currentTool;
	NSString *currentFill;
	NSNotificationCenter *nc;
	NSRect openingRect;
	int i;
}

// Methods called by menu items
- (IBAction)flipHorizontal:(id)sender;
- (IBAction)flipVertical:(id)sender;
- (IBAction)cut:(id)sender;
- (IBAction)copy:(id)sender;
- (IBAction)paste:(id)sender;
- (IBAction)zoomIn:(id)sender;
- (IBAction)zoomOut:(id)sender;
- (IBAction)actualSize:(id)sender;
//- (IBAction)fullScreen:(id)sender;

// Access the document's view (and provide access to the image)
- (PaintView *)paintView;

// Sheets for size!
- (void)sizeSheetDidEnd:(NSWindow *)sheet
			 returnCode:(int)returnCode
			contextInfo:(void *)contextInfo;
- (IBAction)raiseSizeSheet:(id)sender;

// For copy-and-paste
- (void)writeImageToPasteboard:(NSPasteboard *)pb;
- (BOOL)readImageFromPasteboard:(NSPasteboard *)pb;


@end
