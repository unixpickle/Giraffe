//
//  ANMutableColorArray.h
//  GifPro
//
//  Created by Alex Nichol on 11/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANColorTable.h"

@interface ANMutableColorArray : NSObject {
	ANGifColor * _colors;
	NSUInteger _entryCount;
	NSUInteger _totalAlloced;
}

- (NSUInteger)count;
- (void)addColor:(ANGifColor)color;
- (void)removeAtIndex:(NSUInteger)index;
- (ANGifColor)colorAtIndex:(NSUInteger)index;

- (void)sortByBrightness;
- (ANMutableColorArray *)colorArrayByAveragingSplit:(NSUInteger)numColors;
- (void)removeDuplicates;
- (ANGifColor)averagePopFirst;

@end
