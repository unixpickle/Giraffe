//
//  ANMutableColorArray.m
//  GifPro
//
//  Created by Alex Nichol on 11/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
//  Converted to Non-ARC 11/4/11

#import "ANMutableColorArray.h"
#define kColorBufferSize 256

int CompareColorQSort (const void * ent1, const void * ent2);

@implementation ANMutableColorArray

- (id)init {
	if ((self = [super init])) {
		_colors = (ANGifColor *)malloc(sizeof(ANGifColor) * kColorBufferSize);
		_totalAlloced = kColorBufferSize;
	}
	return self;
}

- (NSUInteger)count {
	return _entryCount;
}

- (void)addColor:(ANGifColor)color {
	for (NSUInteger i = 0; i < _entryCount; i++) {
		ANGifColor aColor = [self colorAtIndex:i];
		if (ANGifColorVariance(color, aColor) < 5) return;
	}
	if (_entryCount + 1 == _totalAlloced) {
		_totalAlloced += kColorBufferSize;
		_colors = (ANGifColor *)realloc(_colors, sizeof(ANGifColor) * _totalAlloced);
	}
	_colors[_entryCount++] = color;
}

- (void)removeAtIndex:(NSUInteger)index {
	NSUInteger assignIndex = 0;
	for (NSUInteger i = 0; i < _entryCount; i++) {
		if (i != index) {
			_colors[assignIndex++] = _colors[i];
		}
	}
	_entryCount = assignIndex;
	if (_totalAlloced - kColorBufferSize >= _entryCount && _totalAlloced > kColorBufferSize) {
		_totalAlloced -= kColorBufferSize;
		_colors = (ANGifColor *)realloc(_colors, sizeof(ANGifColor) * _totalAlloced);
	}
}

- (ANGifColor)colorAtIndex:(NSUInteger)index {
	if (index >= _entryCount) {
		@throw [NSException exceptionWithName:ANGifColorIndexOutOfBoundsException
									   reason:@"The specified color index is beyond the bounds of the array."
									 userInfo:nil];
	}
	return _colors[index];
}

#pragma mark Averaging

- (void)sortByBrightness {
	qsort(_colors, _entryCount, sizeof(ANGifColor), CompareColorQSort);
}

- (ANMutableColorArray *)colorArrayByAveragingSplit:(NSUInteger)numColors {
	ANMutableColorArray * newArray = [[ANMutableColorArray alloc] init];
	
	// calculate number of colors per sector
	NSUInteger colorsPerSect = _entryCount / numColors;
	NSUInteger colorsRemaining = _entryCount % numColors;
	NSUInteger startIndex = 0;
	
	for (NSUInteger i = 0; i < numColors; i++) {
		NSUInteger size = colorsPerSect;
		if (colorsRemaining > 0) {
			size += 1;
			colorsRemaining--;
		}
		
		if (size == 0) break;
		
		double red = 0, green = 0, blue = 0;
		
		// average <size> colors
		for (NSUInteger j = startIndex; j < startIndex + size; j++) {
			ANGifColor aColor = _colors[j];
			red += (double)aColor.red;
			green += (double)aColor.green;
			blue += (double)aColor.blue;
		}
		
		red /= (double)size;
		green /= (double)size;
		blue /= (double)size;
		
		ANGifColor genColor = ANGifColorMake((UInt8)red, (UInt8)green, (UInt8)blue);
		[newArray addColor:genColor];
		
		startIndex += size;
	}
#if __has_feature(objc_arc)
	return newArray;
#else
	return [newArray autorelease];
#endif
}

- (void)removeDuplicates {
	return;
	for (NSUInteger i = 0; i < _entryCount; i++) {
		ANGifColor currentColor = _colors[i];
		for (NSUInteger j = i + 1; j < _entryCount; j++) {
			ANGifColor anotherColor = _colors[j];
			if (ANGifColorIsEqual(currentColor, anotherColor)) {
				[self removeAtIndex:j];
				j--;
			}
		}
	}
}

- (ANGifColor)averagePopFirst {
	if (_entryCount == 1) {
		ANGifColor color = [self colorAtIndex:0];
		[self removeAtIndex:0];
		return color;
	}
	NSUInteger bestFit = 1;
	NSUInteger variance = 255*3;
	ANGifColor firstColor = [self colorAtIndex:0];
	
	for (NSUInteger i = 1; i < _entryCount; i++) {
		ANGifColor color = [self colorAtIndex:i];
		NSUInteger lvariance = ANGifColorVariance(firstColor, color);
		if (lvariance < variance) {
			bestFit = i;
			variance = lvariance;
			if (variance == 0) {
				break;
			}
		}
	}
	
	ANGifColor selectedColor = [self colorAtIndex:bestFit];
	[self removeAtIndex:bestFit];
	[self removeAtIndex:0];
	return ANGifColorAverage(selectedColor, firstColor);
}

#pragma mark Memory Management

- (void)dealloc {
	free(_colors);
#if !__has_feature(objc_arc)
	[super dealloc];
#endif
}

@end

int CompareColorQSort (const void * ent1, const void * ent2) {
	ANGifColor * color1 = (ANGifColor *)ent1;
	ANGifColor * color2 = (ANGifColor *)ent2;
	return ((int)(color1->red + color1->green + color1->blue) -
			(int)(color2->red + color2->green + color2->blue));
}
