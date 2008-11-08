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
#import "ToolboxController.h"

@interface PaintView : NSView {
	NSImage *mainImage;
	NSImage *secondImage;
	NSPoint downPoint;
	NSPoint currentPoint;
	NSPoint endPoint;
	NSPoint cornerPoint;
	NSColor *frontColor;
	NSColor *backColor;
	NSBitmapImageRep *imageRep;
	NSData *undoData;
	Tool *currentTool;

	BOOL isPayingAttention;
	BOOL hasRun;
	BOOL hasOpened;
	BOOL shouldFill;
	BOOL shouldStroke;
	double lineWidth;
	
	// Grid related
	BOOL _showsGrid;
	float _gridSpacing;
	NSColor *_gridColor;
}

- (id)initWithFrame:(NSRect)frameRect color:(NSColor *)backgroundColor;
- (IBAction)selectAll:(id)sender;
- (void)setImage:(NSImage *)newImage;
- (void)undoImage:(NSData *)imageData;
- (void)setHasOpened:(BOOL)opened;
- (void)pasteData:(NSData *)data;
- (void)prepUndo:(id)sender;
- (void)clearOverlay;
- (BOOL)hasRun;
- (NSImage *)mainImage;
- (NSImage *)secondImage;

// Grid related
- (void)setShowsGrid:(BOOL)showGrid;
- (void)setGridSpacing:(float)spacing;
- (void)setGridColor:(NSColor *)color;
- (BOOL)showsGrid;
- (float)gridSpacing;
- (NSColor *)gridColor;

@end

void DrawGridWithSettingsInRect(float spacing, NSColor *color, NSRect rect, NSPoint gridOrigin);