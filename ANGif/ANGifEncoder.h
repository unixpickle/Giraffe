//
//  ANGifEncoder.h
//  GifPro
//
//  Created by Alex Nichol on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANGifGraphicControlExt.h"
#import "ANGifImageDescriptor.h"
#import "ANGifLogicalScreenDesc.h"
#import "ANAvgColorTable.h"
#import "LZWSpoof.h"
#import "ANGifDataSubblock.h"
#import "ANGifAppExtension.h"

#define kGifHeader "GIF89a"
#define kGifTrailer "\x3B"

@interface ANGifEncoder : NSObject {
	NSFileHandle * fileHandle;
	ANColorTable * globalColorTable;
	NSUInteger screenWidth;
	NSUInteger screenHeight;
	NSUInteger gctOffset;
}

/**
 * Creates a new ANGifEncoder with a given file handle, a canvas size,
 * and a global color table.
 * @param handle The output file handle that will be written to.
 * @param aSize The dimensions of the "virtual screen" created by
 * the gif decoder.
 * @param gct The global descriptor table, or nil if no GCT should be used.
 */
- (id)initWithFileHandle:(NSFileHandle *)handle size:(CGSize)aSize
		globalColorTable:(ANColorTable *)gct;

/**
 * A call to this method is equivalent to a call to
 * initWithFileHandle:size:globalColorTable: with a valid file descriptor
 * opened for writing to fileName.
 */
- (id)initWithOutputFile:(NSString *)fileName size:(CGSize)aSize
		globalColorTable:(ANColorTable *)gct;

/**
 * Add an application extension to the GIF file.
 */
- (void)addApplicationExtension:(ANGifAppExtension *)ext;

/**
 * Add an image to the image sequence contained in the GIF file.
 */
- (void)addImageFrame:(ANGifImageFrame *)imageFrame;

/**
 * Writes any headers and terminators that may need to get written.
 * @discussion This does not close the file handle.
 */
- (void)finishDataStream;

/**
 * Calls finishDataStream before closing the underlying file handle.
 */
- (void)closeFile;

@end
