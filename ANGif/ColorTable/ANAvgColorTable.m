//
//  ANGifBasicColorTable.m
//  GifPro
//
//  Created by Alex Nichol on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
//  Converted to Non-ARC 11/4/11

#import "ANAvgColorTable.h"

@implementation ANAvgColorTable

- (UInt8)addColor:(ANGifColor)aColor {
	NSUInteger firstIndex = (self.hasTransparentFirst ? 1 : 0);
	UInt8 bestToCut = firstIndex;
	NSUInteger variance = UINT_MAX;
	
	for (NSUInteger index = firstIndex; index < _entryCount; index++) {
		NSUInteger lvariance = 0;
		ANGifColor color = [self colorAtIndex:index];
		lvariance += abs((int)color.red - (int)aColor.red);
		lvariance += abs((int)color.green - (int)aColor.green);
		lvariance += abs((int)color.blue - (int)aColor.blue);
		lvariance *= _entries[index].priority;
		if (lvariance < variance) {
			bestToCut = index;
			variance = lvariance;
			if (lvariance == 0) return bestToCut;
		}
	}
	
	if (_entryCount < maxColors && variance > 10) {
		return [super addColor:aColor];
	}
	
	// do a cut
	ANGifColor cutColor = [self colorAtIndex:bestToCut];
	cutColor = ANGifColorAverage(cutColor, aColor);
	_entries[bestToCut].color = cutColor;
	
	_entries[bestToCut].priority += 1;
	return bestToCut;
}

@end
