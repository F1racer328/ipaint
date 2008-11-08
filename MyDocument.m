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

#import "MyDocument.h"

@implementation MyDocument

- (id)init
{
    if (self = [super init]) {
		
		// Observers for the toolbox
		nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self
			   selector:@selector(showTextSheet:)
				   name:@"SWText"
				 object:nil];
		
		// Alert the toolbox that a new document has been created
		NSNotification *n = [NSNotification notificationWithName:@"SWNewDocument"
														  object:self];
		[nc postNotification:n];
	}
    return self;
}

- (NSString *)windowNibName
{
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];

	if (!sizeController) {
		sizeController = [[SizeWindowController alloc] init];
	}
	toolboxController = [ToolboxController sharedToolboxPanelController];
	
	clipView = [[CenteringClipView alloc] initWithFrame:[[scrollView contentView] frame]];
//	[clipView setBackgroundColor:[NSColor windowBackgroundColor]];
	[clipView setBackgroundColor:[NSColor colorWithDeviceWhite:0.9098 alpha:1.0]]; // The stripes don't zoom well, so solid color it is
	[scrollView setContentView:(NSClipView *)clipView];
	[clipView setDocumentView:paintView];
	[scrollView setScaleFactor:1.0 adjustPopup:YES];
	
	// If the user opened an image
	if (openedImage) {
		openingRect.origin = NSZeroPoint;
		openingRect.size = [openedImage size];
		[paintView setHasOpened:YES];
		[paintView initWithFrame:openingRect color:[toolboxController backgroundColor]];
		[paintView setImage:openedImage];
		[openedImage release];
	} else {
		[super showWindows];
		[self raiseSizeSheet:aController];
	}
}

- (void)canCloseDocumentWithDelegate:(id)delegate shouldCloseSelector:(SEL)shouldCloseSelector contextInfo:(void *)contextInfo
{
	[super canCloseDocumentWithDelegate:delegate
					shouldCloseSelector:shouldCloseSelector
							contextInfo:contextInfo];
}


////////////////////////////////////////////////////////////////////////////////
//////////		Sheets - Size and Text
////////////////////////////////////////////////////////////////////////////////


// Called when a new document is made
- (IBAction)raiseSizeSheet:(id)sender
{	
    [NSApp beginSheet:[sizeController window]
	   modalForWindow:[super windowForSheet]
		modalDelegate:self
	   didEndSelector:@selector(sizeSheetDidEnd:returnCode:contextInfo:)
		  contextInfo:NULL];
}


// After the sheet ends, this takes over. If the user clicked "OK", a new
// PaintView is initialized. Otherwise, the window closes.
- (void)sizeSheetDidEnd:(NSWindow *)sheet
		 returnCode:(int)returnCode
		contextInfo:(void *)contextInfo
{
	if (returnCode == NSOKButton) {
		openingRect.origin = NSZeroPoint;
		openingRect.size.width = [sizeController width];
		openingRect.size.height = [sizeController height];
		if (![paintView hasRun]) {
			[paintView initWithFrame:openingRect color:[toolboxController backgroundColor]];
		}
	} else if (returnCode == NSCancelButton) {
		// Close the document - they obviously don't want to play
		[[super windowForSheet] close];
	}
}

- (IBAction)showTextSheet:(id)sender
{
	if ([[super windowForSheet] isKeyWindow]) {
		if (!textController) {
			textController = [[TextToolWindowController alloc] init];
		}

		if (frontColor) {
			[frontColor release];
		}
		frontColor = [sender object];
		
		// Orders the font manager to the front
		[NSApp beginSheet:[textController window]
		   modalForWindow:[super windowForSheet]
			modalDelegate:self
		   didEndSelector:@selector(textSheetDidEnd:string:)
			  contextInfo:NULL];
		
		[[NSFontManager sharedFontManager] orderFrontFontPanel:self];
		
		// Assigns the current front color (according to the sharedColorPanel) 
		// to the frontColor reference
		[[NSColorPanel sharedColorPanel] setColor:frontColor];
		
	}
}

- (void)textSheetDidEnd:(NSWindow *)sheet
				 string:(NSString *)string
{
	// Orders the font manager to exit
	[[[NSFontManager sharedFontManager] fontPanel:NO] orderOut:self];
}

- (PaintView *)paintView {
	return paintView;
}


////////////////////////////////////////////////////////////////////////////////
//////////		Menu actions (Open, Save, Cut, Print, et cetera)
////////////////////////////////////////////////////////////////////////////////


// Saving data: returns the correctly-formatted image data
- (NSData *)dataOfType:(NSString *)aType error:(NSError *)anError
{
	NSData *data;
	NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithData:[[paintView mainImage] TIFFRepresentation]];
	if ([aType isEqualToString:@"BMP"]) {
		data = [bitmap representationUsingType: NSBMPFileType
								  properties: nil];
	} else if ([aType isEqualToString:@"PNG"]) {
		data = [bitmap representationUsingType: NSPNGFileType
								  properties: nil];
	} else if ([aType isEqualToString:@"JPEG"]) {
		data = [bitmap representationUsingType: NSJPEGFileType
								  properties: nil];
	} else if ([aType isEqualToString:@"GIF"]) {
		data = [bitmap representationUsingType: NSGIFFileType
								  properties: nil];
	} else if ([aType isEqualToString:@"TIFF"]) {
		data = [bitmap representationUsingType: NSTIFFFileType
									properties: nil];
	}
	return data;
}

// By overwriting this, we can force files saved by Paintbrush to open with Paintbrush
// in the future when double-clicked
- (NSDictionary *)fileAttributesToWriteToURL:(NSURL *)absoluteURL
									  ofType:(NSString *)typeName
							forSaveOperation:(NSSaveOperationType)saveOperation
						 originalContentsURL:(NSURL *)absoluteOriginalContentsURL
									   error:(NSError **)outError
{
    NSMutableDictionary *fileAttributes = 
	[[super fileAttributesToWriteToURL:absoluteURL
								ofType:typeName forSaveOperation:saveOperation
				   originalContentsURL:absoluteOriginalContentsURL
								 error:outError] mutableCopy];
    [fileAttributes setObject:[NSNumber numberWithUnsignedInt:'Pbsh']
					   forKey:NSFileHFSCreatorCode];
    return [fileAttributes autorelease];
}

// Opening an image
- (BOOL)readFromURL:(NSURL *)URL ofType:(NSString *)aType error:(NSError *)anError
{
	NSBitmapImageRep *tempRep = [NSImageRep imageRepWithContentsOfURL:URL];
	//NSLog(@"%d by %d", [tempRep pixelsWide], [tempRep pixelsHigh]);
	openedImage = [[NSImage alloc] initWithSize:NSMakeSize([tempRep pixelsWide], [tempRep pixelsHigh])];
	[openedImage addRepresentation:tempRep];
	//openedImage = [[NSImage alloc] initWithContentsOfURL:URL];
	return (openedImage != nil);
}

// Printing: Cocoa makes it easy!
- (void)printDocument:(id)sender
{
    NSPrintOperation *op = [NSPrintOperation printOperationWithView:paintView
														  printInfo:[self printInfo]];
	
    [op runOperationModalForWindow:[super windowForSheet]
						  delegate:self
					didRunSelector:NULL
					   contextInfo:NULL];
}

// Called whenever Copy or Cut are called (copies the overlay image to the pasteboard)
- (void)writeImageToPasteboard:(NSPasteboard *)pb
{
	NSRect rect = [(SelectionTool *)currentTool clippingRect];
	NSImage *writeToMe = [[NSImage alloc] initWithSize:rect.size];
	[writeToMe lockFocus];
	[[paintView secondImage] drawInRect:NSMakeRect(0,0,rect.size.width, rect.size.height)
							   fromRect:rect
							  operation:NSCompositeSourceOver
							   fraction:1.0];
	[writeToMe unlockFocus];
	[pb declareTypes:[NSArray arrayWithObject:NSTIFFPboardType] owner:self];

	[pb setData:[writeToMe TIFFRepresentation] forType:NSTIFFPboardType];
	[writeToMe release];
}

// Used by Paste to retrieve an image from the pasteboard
- (BOOL)readImageFromPasteboard:(NSPasteboard *)pb
{
	NSString *type;
	NSData *data;
	
	type = [pb availableTypeFromArray:[NSArray arrayWithObject:NSTIFFPboardType]];
	if (type) {
		data = [pb dataForType:NSTIFFPboardType];
		[paintView pasteData:data];
		[type release];
		return YES;
	}
	[type release];
	return NO;
}

//- (IBAction)fullScreen:(id)sender
//{
//	NSRect screenRect;
//	// Capture the main display
//	if (CGDisplayCapture( kCGDirectMainDisplay ) != kCGErrorSuccess) {
//		NSLog( @"Couldn't capture the main display!" );
//		// Note: you'll probably want to display a proper error dialog here
//	}
//	// Get the shielding window level
//	//windowLevel = CGShieldingWindowLevel();
//	// Get the screen rect of our main display
//	screenRect = [[NSScreen mainScreen] frame];
//	// Put up a new window
//	NSWindow *mainWindow = [[NSWindow alloc] initWithContentRect:screenRect
//													   styleMask:NSBorderlessWindowMask
//														 backing:NSBackingStoreBuffered
//														   defer:NO 
//														  screen:[NSScreen mainScreen]];
//	[[super windowForSheet] setLevel:CGShieldingWindowLevel()];
//	[[super windowForSheet] setFrame:screenRect display:YES];
//	//[mainWindow setBackgroundColor:[NSColor blackColor]];
//	//[mainWindow makeKeyAndOrderFront:nil];
//}

// Cut: same as copy, but clears the overlay
- (IBAction)cut:(id)sender
{
	[self copy:sender];
	[paintView clearOverlay];
}

// Copy
- (IBAction)copy:(id)sender
{
	[self writeImageToPasteboard:[NSPasteboard generalPasteboard]];
}

// Paste
- (IBAction)paste:(id)sender
{
	[self readImageFromPasteboard:[NSPasteboard generalPasteboard]];
}

- (IBAction)zoomIn:(id)sender
{
	[scrollView setScaleFactor:([scrollView scaleFactor] * 2) adjustPopup:YES];
}

- (IBAction)zoomOut:(id)sender
{
	[scrollView setScaleFactor:([scrollView scaleFactor] / 2) adjustPopup:YES];
}

- (IBAction)actualSize:(id)sender
{
	[scrollView setScaleFactor:1 adjustPopup:YES];
}

// Decides which menu items to enable, and which to disable (and when)
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	currentTool = [toolboxController currentTool];
	if (([menuItem action] == @selector(copy:)) || 
		([menuItem action] == @selector(cut:))) {
		return ([[currentTool name] isEqualToString:@"Selection"] && 
				[(SelectionTool *)currentTool isSelected]);
	} else if ([menuItem action] == @selector(paste:)) {
		NSArray *array = [[NSPasteboard generalPasteboard] types];
		BOOL paste = NO;
		NSEnumerator *enumerator = [array objectEnumerator];
		id object;
		while ((object = [enumerator nextObject])) {
			if ([object isEqualToString:NSTIFFPboardType]) {
				paste = YES;
			}
		}
		return paste;
	} else if ([menuItem action] == @selector(zoomIn:)) {
		return [scrollView scaleFactor] < 16;
	} else if ([menuItem action] == @selector(zoomOut:)) {
		return [scrollView scaleFactor] > 0.25;
	} else {
		return YES;
	}
}


////////////////////////////////////////////////////////////////////////////////
//////////		Handling notifications from the toolbox, application controller
////////////////////////////////////////////////////////////////////////////////


- (IBAction)flipHorizontal:(id)sender
{
	if ([[super windowForSheet] isKeyWindow]) {
		NSRect aRect;
		aRect.size = [[paintView mainImage] size];
		aRect.origin = NSZeroPoint;
		NSAffineTransform *transform = [NSAffineTransform transform];
		NSImage *tempImage = [[NSImage alloc] initWithSize:aRect.size];
		
		[transform scaleXBy:-1.0 yBy:1.0];
		[transform translateXBy:-aRect.size.width yBy:0];	
		
		[tempImage lockFocus];
		[transform concat];
		[[paintView mainImage] drawInRect:aRect
								 fromRect:NSZeroRect
								operation:NSCompositeSourceOver
								 fraction:1.0];
		[tempImage unlockFocus];
		[paintView prepUndo:nil];
		[paintView setImage:tempImage];
	}
}

- (IBAction)flipVertical:(id)sender
{
	if ([[super windowForSheet] isKeyWindow]) {
		NSRect aRect;
		aRect.size = [[paintView mainImage] size];
		aRect.origin = NSZeroPoint;
		NSAffineTransform *transform = [NSAffineTransform transform];
		NSImage *tempImage = [[NSImage alloc] initWithSize:aRect.size];
		
		[transform scaleXBy:1.0 yBy:-1.0];
		[transform translateXBy:0 yBy:-aRect.size.height];		
		
		[tempImage lockFocus];
		[transform concat];
		[[paintView mainImage] drawInRect:aRect
								 fromRect:NSZeroRect
								operation:NSCompositeSourceOver
								 fraction:1.0];
		[tempImage unlockFocus];
		[paintView prepUndo:nil];
		[paintView setImage:tempImage];
	}
}

- (void)dealloc
{	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

@end
