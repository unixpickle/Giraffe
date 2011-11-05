//
//  ANGifImageDescriptor.m
//  GifPro
//
//  Created by Alex Nichol on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
//  Converted to Non-ARC 11/4/11

#import "ANGifImageDescriptor.h"

@implementation ANGifImageDescriptor

- (id)initWithImageFrame:(ANGifImageFrame *)anImage {
	if ((self = [super init])) {
		imageFrame = anImage;
	}
	return self;
}

- (NSData *)encodeBlock {
	NSMutableData * encoded = [NSMutableData data];
	
	UInt8 aByte = kImageSeparator;
	UInt16 doubleByte;
	
	[encoded appendBytes:&aByte length:1];
	doubleByte = (UInt16)[imageFrame offsetX];
	[encoded appendBytes:&doubleByte length:2];
	doubleByte = (UInt16)[imageFrame offsetY];
	[encoded appendBytes:&doubleByte length:2];
	doubleByte = (UInt16)[[imageFrame pixelSource] pixelsWide];
	[encoded appendBytes:&doubleByte length:2];
	doubleByte = (UInt16)[[imageFrame pixelSource] pixelsHigh];
	[encoded appendBytes:&doubleByte length:2];
	
	UInt8 packedInfo = 0;
	if ([imageFrame localColorTable]) {
		UInt8 lctSize = [[imageFrame localColorTable] colorTableSizeValue];
		packedInfo |= 128;
		packedInfo |= lctSize;
		// packedInfo |= (1 << 3); // sort flag
	}
	[encoded appendBytes:&packedInfo length:1];
	
	return [NSData dataWithData:encoded];
}

@end
