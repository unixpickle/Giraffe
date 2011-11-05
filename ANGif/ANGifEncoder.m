//
//  ANGifEncoder.m
//  GifPro
//
//  Created by Alex Nichol on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
//  Converted to Non-ARC 11/4/11

#import "ANGifEncoder.h"

@implementation ANGifEncoder

- (id)initWithFileHandle:(NSFileHandle *)handle size:(CGSize)aSize
		globalColorTable:(ANColorTable *)gct {
	if ((self = [super init])) {
		if (!handle) return nil;
#if __has_feature(objc_arc)
		globalColorTable = gct;
		fileHandle = handle;
#else
		globalColorTable = [gct retain];
		fileHandle = [handle retain];
#endif
		screenWidth = round(aSize.width);
		screenHeight = round(aSize.height);
		
		[handle writeData:[NSData dataWithBytes:kGifHeader length:strlen(kGifHeader)]];
		
		// logical screen descriptor
		ANGifLogicalScreenDesc * screenDesc = [[ANGifLogicalScreenDesc alloc] init];
		screenDesc.screenWidth = (UInt16)screenWidth;
		screenDesc.screenHeight = (UInt16)screenHeight;
		if (gct) {
			screenDesc.globalColorTable = YES;
			screenDesc.gctSize = 7;
		}
		[handle writeData:[screenDesc encodeBlock]];
#if !__has_feature(objc_arc)
		[screenDesc release];
#endif
		
		if (gct) {
			// write blank GCT, which will be re-written when the file
			// is closed
			gctOffset = [handle offsetInFile];
			[handle writeData:[gct encodeRawColorTableCount:256]];
		}
	}
	return self;
}

- (id)initWithOutputFile:(NSString *)fileName size:(CGSize)aSize
		globalColorTable:(ANColorTable *)gct {
	if (![[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
		[[NSFileManager defaultManager] createFileAtPath:fileName contents:[NSData data] attributes:nil];
	}
	self = [self initWithFileHandle:[NSFileHandle fileHandleForWritingAtPath:fileName]
							   size:aSize globalColorTable:gct];
	return self;
}

- (void)addApplicationExtension:(ANGifAppExtension *)ext {
	[fileHandle writeData:[ext encodeBlock]];
}

- (void)addImageFrame:(ANGifImageFrame *)imageFrame {
	ANColorTable * colorTable = nil;
	NSData * imageData;
	
	if ([imageFrame localColorTable]) {
		colorTable = imageFrame.localColorTable;
	} else {
		colorTable = globalColorTable;
	}
	if (!colorTable) {
#if __has_feature(objc_arc)
		imageFrame.localColorTable = [[ANAvgColorTable alloc] init];
#else
		imageFrame.localColorTable = [[[ANAvgColorTable alloc] init] autorelease];
#endif
		colorTable = imageFrame.localColorTable;
	}
	
	// - graphics control extension
	
	ANGifGraphicControlExt * gfxControl = [[ANGifGraphicControlExt alloc] init];
	gfxControl.delayTime = imageFrame.delayTime;
	gfxControl.userInputFlag = NO;
	gfxControl.transparentColorFlag = [colorTable hasTransparentFirst];
	gfxControl.transparentColorIndex = [colorTable transparentIndex];
	[fileHandle writeData:[gfxControl encodeBlock]];
#if !__has_feature(objc_arc)
	[gfxControl release];
#endif
	
	// - image descriptor
	
	// calculate image data and re-arrange color table
	imageData = [imageFrame encodeImageUsingColorTable:colorTable];
	
	ANGifImageDescriptor * descriptor = [[ANGifImageDescriptor alloc] initWithImageFrame:imageFrame];
	[fileHandle writeData:[descriptor encodeBlock]];
#if !__has_feature(objc_arc)
	[descriptor release];
#endif
	
	// - local color table
	if (imageFrame.localColorTable) {
		// [colorTable sortByPriority];
		[fileHandle writeData:[colorTable encodeRawColorTable]];
	}
	
	// - and image itself
	UInt8 lzwSize = 8;
	[fileHandle writeData:[NSData dataWithBytes:&lzwSize length:1]];
	
	NSData * lzwCompressed = [LZWSpoof lzwExpandData:imageData];
	NSArray * imageBlocks = [ANGifDataSubblock dataSubblocksForData:lzwCompressed];
	for (ANGifDataSubblock * subblock in imageBlocks) {
		[subblock writeToFileHandle:fileHandle];
	}
	
	lzwSize = 0;
	[fileHandle writeData:[NSData dataWithBytes:&lzwSize length:1]]; // NULL terminator
}

- (void)finishDataStream {
	// write gif trailer
	[fileHandle writeData:[NSData dataWithBytes:kGifTrailer length:1]];
	// rewrite GCT
	if (globalColorTable) {
		// [globalColorTable sortByPriority];
		[fileHandle seekToFileOffset:gctOffset];
		[fileHandle writeData:[globalColorTable encodeRawColorTableCount:256]];
	}
}

- (void)closeFile {
	[self finishDataStream];
	[fileHandle closeFile];
#if !__has_feature(objc_arc)
	[fileHandle release];
#endif
	fileHandle = nil;
}

#if !__has_feature(objc_arc)

- (void)dealloc {
	[globalColorTable release];
	[fileHandle release];
	[super dealloc];
}

#endif

@end
