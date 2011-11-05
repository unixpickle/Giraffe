//
//  ANGifImageFrame.h
//  GifPro
//
//  Created by Alex Nichol on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANColorTable.h"
#import "ANGifImageFramePixelSource.h"

@interface ANGifImageFrame : NSObject {
	id<ANGifImageFramePixelSource> pixelSource;
	ANColorTable * localColorTable;
	UInt16 offsetX;
	UInt16 offsetY;
	NSTimeInterval delayTime;
}

@property (nonatomic, retain) id<ANGifImageFramePixelSource> pixelSource;
@property (nonatomic, retain) ANColorTable * localColorTable;
@property (readwrite) UInt16 offsetX, offsetY;
@property (readwrite) NSTimeInterval delayTime;

/**
 * Create an ANGifImageFrame with an image source, a local color table (should be empty), and a delay.
 * @param aSource A non-nil pixel data source from which image data will come.
 * @param table The local color table that will be used by this image. If this is nil, the global color table
 * will be used for this image.
 * @param delay The delay in seconds before the next frame will be shown. This is accurate to the millisecond.
 */
- (id)initWithPixelSource:(id<ANGifImageFramePixelSource>)aSource colorTable:(ANColorTable *)table delayTime:(NSTimeInterval)delay;

/**
 * Create an ANGifImageFrame with an image source and a delay.
 * @param aSource A non-nil pixel data source from which image data will come.
 * @param delay The delay in seconds before the next frame will be shown. This is accurate to the millisecond.
 * @discussion Despite the fact that no color table was provided, the encoder may chose to use
 * a local color table if no global color table has been created.
 */
- (id)initWithPixelSource:(id<ANGifImageFramePixelSource>)aSource delayTime:(NSTimeInterval)delay;

/**
 * Encodes each pixel using the specified color table, adding colors as it goes along.
 * @param colorTable Either a local color table or a global color table. This will be mutated
 * only by calling the addColor: method. This may not be nil.
 * @return The encoded data of the image, or nil upon error.
 */
- (NSData *)encodeImageUsingColorTable:(ANColorTable *)colorTable;

@end
