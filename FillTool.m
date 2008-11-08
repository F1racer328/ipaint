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

#import "FillTool.h"
//#import "SelectionBuilder.h"

@interface FillTool (Private)

- (CGImageRef) floodFillSelect:(NSPoint)point tolerance:(float)tolerance;
- (void) fillMask:(CGImageRef)mask withColor:(NSColor *)color;

@end


@implementation FillTool

- (NSBezierPath *)pathFromPoint:(NSPoint)begin toPoint:(NSPoint)end
{
	return nil;
}

- (void)performDrawAtPoint:(NSPoint)point withMainImage:(NSImage *)anImage secondImage:(NSImage *)secondImage mouseEvent:(int)event;
{	
	if (event == MOUSE_DOWN) {
		
		// Prep an undo - we're about to change things!
		[NSApp sendAction:@selector(prepUndo:)
					   to:nil
					 from:nil];
		
		if (secondImage) {
			[secondImage release];
		}
		secondImage = [[NSImage alloc] initWithSize:[anImage size]];		
		
		// Get the width and height of the image
		w = (int)[anImage size].width;
		h = (int)[anImage size].height;
		
		int rowBytes = ((int)(ceil(w)) * 4 + 0x0000000F) & ~0x0000000F; // 16-byte aligned is good
		
		// Create a new NSBitmapImageRep for filling
		// Note: the method varies for Leopard and Tiger, so here's a nice little if statement
		if (NSAppKitVersionNumber < 949) {
			// Tiger!
			imageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:nil 
															   pixelsWide:w
															   pixelsHigh:h 
															bitsPerSample:8 
														  samplesPerPixel:4 
																 hasAlpha:YES 
																 isPlanar:NO 
														   colorSpaceName:NSCalibratedRGBColorSpace 
															 bitmapFormat:NSAlphaNonpremultipliedBitmapFormat 
															  bytesPerRow:rowBytes
															 bitsPerPixel:32];
		} else {
			// Leopard!
			imageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:nil 
															   pixelsWide:w
															   pixelsHigh:h 
															bitsPerSample:8 
														  samplesPerPixel:4 
																 hasAlpha:YES 
																 isPlanar:NO 
														   colorSpaceName:NSCalibratedRGBColorSpace 
															 bitmapFormat:NSAlphaFirstBitmapFormat 
															  bytesPerRow:rowBytes
															 bitsPerPixel:32];
		}
		
		// Get the graphics context associated with the new ImageRep so we can draw to it
		NSGraphicsContext* imageContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:imageRep];
		[NSGraphicsContext saveGraphicsState];
		[NSGraphicsContext setCurrentContext:imageContext];
		
		// Draw the current image to the ImageRep
		[anImage drawAtPoint:NSZeroPoint
					fromRect:NSMakeRect(0, 0, [anImage size].width, [anImage size].height)
				   operation:NSCompositeSourceOver
					fraction:1.0];
		[NSGraphicsContext restoreGraphicsState];
		
		// Check to make sure if we should even bother trying to fill - 
		// if it's the same color, there's nothing to do
		if (![[imageRep colorAtX:point.x y:(h - point.y - 1)] isEqualTo:frontColor]) {
			// Create the image mask we will be using to fill the selected region
			CGImageRef mask = [self floodFillSelect:point tolerance:0.0];
			
			// And then fill it!
			[self fillMask:mask withColor:frontColor];
			
			[anImage lockFocus];
			[imageRep drawAtPoint:NSZeroPoint];
			[anImage unlockFocus];
			
			[builder release];
		}
		
		[imageRep release];
	}
}	

- (NSString *)name
{
	return @"Fill";
}

- (NSCursor *)cursor
{
	return [NSCursor crosshairCursor];
}

- (BOOL)shouldShowFillOptions
{
	return NO;
}	

@end

@implementation FillTool (Private)

- (CGImageRef) floodFillSelect:(NSPoint)point tolerance:(float)tolerance
{
	// Building up a selection mask is pretty involved, so we're going to pass
	//	the task to a helper class that can build up temporary state.
	builder = [[SelectionBuilder alloc] initWithBitmapImageRep:imageRep point:point tolerance:tolerance];
	return [builder mask];
}

- (void) fillMask:(CGImageRef)mask withColor:(NSColor *)color
{
	// We want to render the image into our bitmap image rep, so create a
	//	NSGraphicsContext from it.
	NSGraphicsContext *imageContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:imageRep];
	CGContextRef cgContext = [imageContext graphicsPort];
	
	// "Focus" our image rep so the NSImage will use it to draw into
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:imageContext];
	
	// Clip out everything that we don't want to fill with the new color
	//NSLog(@"%f, %f", canvasSize.width, canvasSize.height);
	CGContextClipToMask(cgContext, CGRectMake(0, 0, w, h), mask);
	
	// Set the color and fill
	[frontColor set];
	[NSBezierPath fillRect: NSMakeRect(0, 0, w, h)];
	
	[NSGraphicsContext restoreGraphicsState];
}

@end