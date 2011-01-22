//
//  ANGifBitmap.h
//  Giraffe
//
//  Created by Alex Nichol on 1/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANImageBitmapRep.h"

@interface ANGifBitmap : NSObject {
	ANImageBitmapRep * imageBitmap;
}

- (id)initWithImage:(UIImage *)image;
- (CGSize)size;
- (UInt32)getPixel:(CGPoint)pt;
- (NSData *)smallBitmapData;

@end
