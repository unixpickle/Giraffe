//
//  ANCutColorTable.m
//  GifPro
//
//  Created by Alex Nichol on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
//  Converted to Non-ARC 11/4/11

#import "ANCutColorTable.h"

@implementation ANCutColorTable

- (id)initWithTransparentFirst:(BOOL)hasAlpha pixelSource:(id<ANGifImageFramePixelSource>)pixelSource {
	if ((self = [super initWithTransparentFirst:hasAlpha])) {
		ANMutableColorArray * colorArray = [[ANMutableColorArray alloc] init];
		NSUInteger color[4];
		NSUInteger numberOfPoints = 512;
		NSUInteger totalPixels = [pixelSource pixelsWide] * [pixelSource pixelsHigh];
		double pixelsPerSample = (double)totalPixels / (double)numberOfPoints;
		if (pixelsPerSample < 1) pixelsPerSample = 1;
		double pixelIndex = 0;
		BOOL hasTransparency = [pixelSource hasTransparency];
		for (NSUInteger y = 0; y < [pixelSource pixelsHigh]; y++) {
			for (NSUInteger x = 0; x < [pixelSource pixelsWide]; x++) {
				pixelIndex += 1.0;
				if (pixelIndex >= pixelsPerSample) {
					pixelIndex -= pixelsPerSample;
					ANGifColor aColor;
					[pixelSource getPixel:color atX:x y:y];
					if (!(color[3] < 0x20 && hasTransparency && hasAlpha)) {
						aColor.red = color[0];
						aColor.green = color[1];
						aColor.blue = color[2];
						[colorArray addColor:aColor];
					}
				}
			}
		}
		[colorArray sortByBrightness];
		// split colorArray up if needed, create new color array
		NSUInteger maxGenColors = (hasAlpha ? 254 : 255);
		if ([colorArray count] > maxGenColors) {
#if !__has_feature(objc_arc)
			[colorArray autorelease];
#endif
			colorArray = [colorArray colorArrayByAveragingSplit:maxGenColors];
#if !__has_feature(objc_arc)
			[colorArray retain];
#endif
		}
		for (NSUInteger i = 0; i < [colorArray count]; i++) {
			[super addColor:[colorArray colorAtIndex:i]];
		}
		
#if !__has_feature(objc_arc)
		[colorArray release];
#endif
		
		finishedInit = YES;
	}
	return self;
}

- (UInt8)addColor:(ANGifColor)aColor {
	if (!finishedInit) {
		return [super addColor:aColor];
	}
	
	UInt8 firstIndex = (self.hasTransparentFirst ? 1 : 0);
	NSUInteger variance = INT_MAX;
	UInt8 selectedColor = firstIndex;
	for (NSUInteger i = firstIndex; i < _entryCount; i++) {
		ANGifColor color = [self colorAtIndex:i];
		NSUInteger lvariance = ANGifColorVariance(color, aColor);
		if (lvariance < variance) {
			variance = lvariance;
			selectedColor = i;
		}
	}
	
	return selectedColor;
}

@end
