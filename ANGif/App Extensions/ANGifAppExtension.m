//
//  ANGifAppExtension.m
//  GifPro
//
//  Created by Alex Nichol on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
//  Converted to Non-ARC 11/4/11

#import "ANGifAppExtension.h"

@implementation ANGifAppExtension

@synthesize applicationIdentifier;
@synthesize applicationAuthCode;
@synthesize applicationData;

- (NSData *)encodeBlock {
	NSMutableData * data = [NSMutableData data];
	
	UInt8 aByte = 0x21;
	[data appendBytes:&aByte length:1]; // extension introducer
	aByte = 0xFF;
	[data appendBytes:&aByte length:1]; // extension label
	aByte = [applicationIdentifier length] + [applicationAuthCode length];
	[data appendBytes:&aByte length:1]; // block length
	[data appendData:applicationIdentifier];
	[data appendData:applicationAuthCode];
	[data appendData:applicationData];
	aByte = 0;
	[data appendBytes:&aByte length:1]; // application terminator
	
	return [NSData dataWithData:data];
}

#if !__has_feature(objc_arc)

- (void)dealloc {
	self.applicationIdentifier = nil;
	self.applicationAuthCode = nil;
	self.applicationData = nil;
	[super dealloc];
}

#endif

@end
