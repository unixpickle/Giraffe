//
//  ANGifNetscapeAppExtension.m
//  GifPro
//
//  Created by Alex Nichol on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
//  Converted to Non-ARC 11/4/11

#import "ANGifNetscapeAppExtension.h"

@implementation ANGifNetscapeAppExtension

@synthesize numberOfRepeats;

- (id)init {
	if ((self = [self initWithRepeatCount:0xffff])) {
	}
	return self;
}

- (id)initWithRepeatCount:(UInt16)repeats {
	if ((self = [super init])) {
		numberOfRepeats = repeats;
		// calculate application data
		NSMutableData * appData = [NSMutableData data];
		[appData appendBytes:"\x03\x01" length:2];
		[appData appendBytes:&numberOfRepeats length:2];
		self.applicationData = [NSData dataWithData:appData];
		// app ID and signature
		self.applicationIdentifier = [NSData dataWithBytes:"\x4E\x45\x54\x53\x43\x41\x50\x45" length:8];
		self.applicationAuthCode = [NSData dataWithBytes:"\x32\x2E\x30" length:3];
	}
	return self;
}

@end
