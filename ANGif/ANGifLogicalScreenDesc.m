//
//  ANGifLogicalScreenDescriptor.m
//  GifPro
//
//  Created by Alex Nichol on 11/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
//  Converted to Non-ARC 11/4/11

#import "ANGifLogicalScreenDesc.h"

@implementation ANGifLogicalScreenDesc

@synthesize screenWidth;
@synthesize screenHeight;
@synthesize globalColorTable;
@synthesize gctSize;
@synthesize backgroundColor;

- (NSData *)encodeBlock {
	NSMutableData * encoded = [NSMutableData data];
	
	UInt8 aByte;
	
	[encoded appendBytes:&screenWidth length:2];
	[encoded appendBytes:&screenHeight length:2];
	// packed flags with 3*8 bits/pixel, GCT present, and GCT size
	aByte = (globalColorTable << 7) | (3 << 4) | (gctSize & 7);
	if (globalColorTable) {
		// aByte |= (1 << 3); // global color table sorted
	}
	[encoded appendBytes:&aByte length:1]; // flags
	[encoded appendBytes:&backgroundColor length:1];
	aByte = 0;
	[encoded appendBytes:&aByte length:1]; // pixel aspect ratio
	
	return [NSData dataWithData:encoded];
}

@end
