//
//  LZWSpoof.m
//  GifPro
//
//  Created by Alex Nichol on 11/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
//  Converted to Non-ARC 11/4/11

#import "LZWSpoof.h"

#define kAllocBufferSize 512

@implementation LZWSpoof

@synthesize numBits;

#pragma mark LZW

+ (NSData *)lzwExpandData:(NSData *)existingData {
	LZWSpoof * destinationBuffer = [[LZWSpoof alloc] init];
	LZWSpoof * existingBuffer = [[LZWSpoof alloc] initWithData:existingData];
	
	// loop through every byte, write it, and then write a clear code.
	for (NSUInteger byteIndex = 0; byteIndex < [existingData length]; byteIndex++) {
		// insert NULL start bit
//		for (NSUInteger bitIndex = byteIndex * 8; bitIndex < (byteIndex + 1) * 8; bitIndex++) {
//			// NSUInteger bitIndexFlip = (bitIndex - (bitIndex % 8)) + (7 - (bitIndex % 8));
//			[destinationBuffer addBit:[existingBuffer getBitAtIndex:bitIndex]];
//		}
		[destinationBuffer addByte:(byteIndex * 8) fromBuffer:existingBuffer];
		[destinationBuffer addBit:NO];
		// add clear code (TODO: make this less frequent)
		[destinationBuffer addLZWClearCode];
	}
	
	// LZW "STOP" directive
	[destinationBuffer addBit:YES];
	for (int i = 0; i < 7; i++) {
		[destinationBuffer addBit:NO];
	}
	[destinationBuffer addBit:YES];
	
#if !__has_feature(objc_arc)
	[existingBuffer release];
	NSData * theData = [destinationBuffer convertToData];
	[destinationBuffer release];
	return theData;
#else
	return [destinationBuffer convertToData];
#endif
}

#pragma mark Bit Buffer

- (id)initWithData:(NSData *)initialData {
	if ((self = [super init])) {
		_totalSize = [initialData length];
		_bytePool = (UInt8 *)malloc(_totalSize);
		memcpy(_bytePool, (const char *)[initialData bytes], _totalSize);
		numBits = _totalSize * 8;
	}
	return self;
}

- (id)init {
	if ((self = [super init])) {
		_totalSize = kAllocBufferSize;
		_bytePool = (UInt8 *)malloc(_totalSize);
		numBits = 0;
	}
	return self;
}

- (void)addBit:(BOOL)flag {
	LZWDataAddBit(&_bytePool, &_totalSize, &numBits, flag);
}

- (BOOL)getBitAtIndex:(NSUInteger)bitIndex {
	if (bitIndex >= numBits) {
		@throw [NSException exceptionWithName:BitOutOfRangeException
									   reason:@"The specified bit index is beyond the bounds of the buffer."
									 userInfo:nil];
	}
	return LZWDataGetBit(_bytePool, bitIndex);
}

#pragma mark LZW

- (void)addLZWClearCode {
	for (int i = 0; i < 8; i++) {
		LZWDataAddBit(&_bytePool, &_totalSize, &numBits, NO);
	}
	LZWDataAddBit(&_bytePool, &_totalSize, &numBits, YES);
}

- (void)addByte:(NSUInteger)startBit fromBuffer:(LZWSpoof *)source {
	for (NSUInteger bitIndex = startBit; bitIndex < startBit + 8; bitIndex++) {
		LZWDataAddBit(&_bytePool, &_totalSize, &numBits, [source getBitAtIndex:bitIndex]);
	}
}

#pragma mark Data

- (NSData *)convertToData {
	NSUInteger numBytes = numBits / 8 + (numBits % 8 == 0 ? 0 : 1);
	return [NSData dataWithBytes:_bytePool length:numBytes];
}

- (void)dealloc {
	free(_bytePool);
#if !__has_feature(objc_arc)
	[super dealloc];
#endif
}

@end

void LZWDataAddBit (UInt8 ** _bytePool, NSUInteger * _totalSize, NSUInteger * numBits, BOOL flag) {
	NSUInteger endNumber = *numBits + 1;
	if (endNumber / 8 + (endNumber % 8 == 0 ? 0 : 1) > *_totalSize) {
		*_totalSize += kAllocBufferSize;
		*_bytePool = (UInt8 *)realloc(*_bytePool, *_totalSize);
	}
	NSUInteger byteIndex = (*numBits) / 8;
	UInt8 byteMask = (1 << ((*numBits) % 8));
	if (flag) {
		(*_bytePool)[byteIndex] |= byteMask;
	} else {
		(*_bytePool)[byteIndex] &= (0xff ^ byteMask);
	}
	*numBits += 1;
}

BOOL LZWDataGetBit (UInt8 * _bytePool, NSUInteger bitIndex) {
	NSUInteger byteIndex = bitIndex / 8;
	UInt8 byteMask = (1 << (bitIndex % 8));
	return (((_bytePool[byteIndex] & byteMask) == 0) ? NO : YES);
}
