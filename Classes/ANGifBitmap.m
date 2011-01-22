//
//  ANGifBitmap.m
//  Giraffe
//
//  Created by Alex Nichol on 1/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ANGifBitmap.h"

static UInt8 make3 (UInt8 m) {
	if (m >= 4) m = 3;
	return m;
}

@implementation ANGifBitmap

- (id)initWithImage:(UIImage *)image {
	if (self = [super init]) {
		imageBitmap = [[ANImageBitmapRep alloc] initWithImage:image];
	}
	return self;
}
- (CGSize)size {
	return [imageBitmap size];
}
- (UInt32)getPixel:(CGPoint)pt {
	UInt32 pixel = 0;
	[imageBitmap get255Pixel:(char *)(&pixel) atX:(int)(pt.x) y:(int)(pt.y)];
	return pixel;
}

- (NSData *)smallBitmapData {
	// go through and get every single pixel, 
	// then turn it into one byte/pixel
	NSMutableData * returnData = [NSMutableData data];
	CGSize s = [self size];
	int width = (int)s.width;
	int height = (int)s.height;
	for (int y = 0; y < height; y++) {
		for (int x = 0; x < width; x++) {
			// read the information
			NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
			//NSLog(@"Reading: %d, %d", x, y);
			UInt32 pixel = [self getPixel:CGPointMake(x,y)];
			unsigned char * pxlData = (unsigned char *)&pixel;
			//NSLog(@"Done.");
			// now we need to compress the pixel
			UInt8 small = 0;
			small |= make3((int)round((float)pxlData[1] / 64.0f));
			small |= make3((int)round((float)pxlData[2] / 64.0f)) << 2;
			small |= make3((int)round((float)pxlData[3] / 64.0f)) << 4;
			small |= make3((int)round((float)pxlData[0] / 64.0f)) << 6;
			if (small == 0) small = 128;
			if (pxlData[0] < 10) small = 0;
			[returnData appendBytes:&small length:1];
			//NSLog(@"Size: %d", [returnData length]);
			[pool drain];
			//NSLog(@"Done freepool.");
		}
	}
	
	NSLog(@"Done conversion.");
	
	return returnData;
}

- (void)dealloc {
	[imageBitmap release];
	[super dealloc];
}

@end
