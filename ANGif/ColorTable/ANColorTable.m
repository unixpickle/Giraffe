//
//  ANGifColorTable.m
//  GifPro
//
//  Created by Alex Nichol on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
//  Converted to Non-ARC 11/4/11

#import "ANColorTable.h"

@implementation ANColorTable

@synthesize maxColors;
@synthesize hasTransparentFirst;

- (id)initWithTransparentFirst:(BOOL)transparentFirst {
	if ((self = [self init])) {
		ANGifColor myColor;
		myColor.red = 0;
		myColor.green = 0;
		myColor.blue = 0;
		[self addColor:myColor];
		hasTransparentFirst = transparentFirst;
	}
	return self;
}

- (id)init {
	if ((self = [super init])) {
		_entries = (ANGifColorTableEntry *)malloc(sizeof(ANGifColorTableEntry));
		_totalAlloced = 1;
		maxColors = 256;
	}
	return self;
}

- (NSUInteger)numberOfEntries {
	return _entryCount;
}

- (void)setColor:(ANGifColor)color atIndex:(UInt8)index {
	if (index >= _entryCount) {
		@throw [NSException exceptionWithName:ANGifColorIndexOutOfBoundsException
									   reason:@"The specified color index was beyond the bounds of the color table."
									 userInfo:nil];
	}
	_entries[index].color = color;
	_entries[index].priority = 1;
}

- (UInt8)addColor:(ANGifColor)aColor {
	for (NSUInteger i = (self.hasTransparentFirst ? 1 : 0); i < _entryCount; i++) {
		if (ANGifColorIsEqual(_entries[i].color, aColor)) {
			_entries[i].priority += 1;
			return (UInt8)i;
		}
	}
	if (_entryCount >= maxColors) {
		@throw [NSException exceptionWithName:ANGifColorTableFullException reason:nil userInfo:nil];
	}
	if (_entryCount == _totalAlloced) {
		_totalAlloced += 3;
		if (_totalAlloced > maxColors) _totalAlloced = maxColors;
		_entries = (ANGifColorTableEntry *)realloc(_entries, sizeof(ANGifColorTableEntry) * _totalAlloced);
	}
	_entries[_entryCount].color = aColor;
	_entries[_entryCount].priority = 1;
	return _entryCount++;
}

- (ANGifColor)colorAtIndex:(UInt8)index {
	if (index >= _entryCount) {
		@throw [NSException exceptionWithName:ANGifColorIndexOutOfBoundsException
									   reason:@"The specified color index was beyond the bounds of the color table."
									 userInfo:nil];
	}
	return _entries[index].color;
}

- (UInt8)transparentIndex {
	return 0;
}

- (void)dealloc {
	free(_entries);
#if !__has_feature(objc_arc)
	[super dealloc];
#endif
}

#pragma mark - Sorting -

- (void)sortByPriority {
	while ([self singleSortStep]);
}

- (BOOL)singleSortStep {
	if (_entryCount == (self.hasTransparentFirst ? 1 : 0)) return NO;
	ANGifColorTableEntry lastEntry = _entries[(self.hasTransparentFirst ? 1 : 0)];
	for (NSUInteger i = (self.hasTransparentFirst ? 2 : 1); i < _entryCount; i++) {
		ANGifColorTableEntry entry = _entries[i];
		if (entry.priority > lastEntry.priority) {
			// swap order
			_entries[i] = lastEntry;
			_entries[i - 1] = entry;
			return YES;
		}
		lastEntry = entry;
	}
	return NO;
}

#pragma mark Encoding

- (UInt8)colorTableSizeValue {
	for (NSUInteger x = 0; x < 8; x++) {
		// test the value
		NSUInteger countValue = 1 << (x + 1);
		if (countValue >= _entryCount) {
			return x;
		}
	}
	return 7;
}

- (NSData *)encodeRawColorTable {	
	UInt8 tableSize = [self colorTableSizeValue];
	NSUInteger numEntries = 1 << ((NSUInteger)tableSize + 1);
	return [self encodeRawColorTableCount:numEntries];
}

- (NSData *)encodeRawColorTableCount:(NSUInteger)numEntries {
	NSMutableData * encoded = [NSMutableData data];
	
	UInt8 byte;
	for (NSUInteger i = 0; i < numEntries; i++) {
		if (i >= _entryCount) {
			// add empty entry
			byte = 0;
			[encoded appendBytes:&byte length:1];
			[encoded appendBytes:&byte length:1];
			[encoded appendBytes:&byte length:1];
		} else {
			ANGifColor color = [self colorAtIndex:(UInt8)i];
			[encoded appendBytes:&color.red length:1];
			[encoded appendBytes:&color.green length:1];
			[encoded appendBytes:&color.blue length:1];
		}
	}
	
	return [NSData dataWithData:encoded];
}

@end

BOOL ANGifColorIsEqual (ANGifColor color1, ANGifColor color2) {
	if (color1.red == color2.red && color1.green == color2.green && color1.blue == color2.blue) {
		return YES;
	}
	return NO;
}

NSUInteger ANGifColorVariance (ANGifColor color1, ANGifColor color2) {
	NSUInteger v = 0;
	v += abs((int)color1.red - (int)color2.red);
	v += abs((int)color1.green - (int)color2.green);
	v += abs((int)color1.blue - (int)color2.blue);
	return v;
}

ANGifColor ANGifColorAverage (ANGifColor color1, ANGifColor color2) {
	ANGifColor median;
	median.red = (UInt8)round(((double)color1.red + (double)color2.red) / 2.0);
	median.green = (UInt8)round(((double)color1.green + (double)color2.green) / 2.0);
	median.blue = (UInt8)round(((double)color1.blue + (double)color2.blue) / 2.0);
	return median;
}

ANGifColor ANGifColorMake (UInt8 red, UInt8 green, UInt8 blue) {
	ANGifColor color;
	color.red = red;
	color.green = green;
	color.blue = blue;
	return color;
}
