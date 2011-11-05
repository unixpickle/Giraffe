//
//  ANGifGraphicControlExtension.m
//  GifPro
//
//  Created by Alex Nichol on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
//  Converted to Non-ARC 11/4/11

#import "ANGifGraphicControlExt.h"

@implementation ANGifGraphicControlExt

@synthesize userInputFlag;
@synthesize transparentColorFlag;
@synthesize transparentColorIndex;
@synthesize delayTime;

- (NSData *)encodeBlock {
	NSMutableData * encoded = [NSMutableData data];
	UInt8 aByte = 0x21;
	UInt16 doubleByte;
	
	[encoded appendBytes:&aByte length:1]; // extension introducer
	aByte = kGraphicControlLabel;
	[encoded appendBytes:&aByte length:1]; // graphic control label
	aByte = 4;
	[encoded appendBytes:&aByte length:1]; // block length (fixed)
	
	// <Packed Fields> w/ disposal method #3
	aByte = (3 << 2) | (userInputFlag << 1) | transparentColorFlag;
	[encoded appendBytes:&aByte length:1];
	
	doubleByte = (UInt16)round(delayTime * 100);
	[encoded appendBytes:&doubleByte length:2]; // delay time
	[encoded appendBytes:&transparentColorIndex length:1];
	
	// terminator block
	aByte = 0;
	[encoded appendBytes:&aByte length:1];
	
	return [NSData dataWithData:encoded];
}

@end
