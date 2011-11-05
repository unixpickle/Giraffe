//
//  PixelSource.h
//  GifPro
//
//  Created by Alex Nichol on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ANGifImageFramePixelSource <NSObject>

- (NSUInteger)pixelsWide;
- (NSUInteger)pixelsHigh;
- (void)getPixel:(NSUInteger *)pixel atX:(NSInteger)x y:(NSInteger)y;
- (BOOL)hasTransparency;

@end
