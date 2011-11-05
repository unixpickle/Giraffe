//
//  ANGifImageDescriptor.h
//  GifPro
//
//  Created by Alex Nichol on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANGifImageFrame.h"

#define kImageSeparator 0x2C

@interface ANGifImageDescriptor : NSObject {
#if __has_feature(objc_arc)
	__weak ANGifImageFrame * imageFrame;
#else
	ANGifImageFrame * imageFrame;
#endif
}

- (id)initWithImageFrame:(ANGifImageFrame *)anImage;
- (NSData *)encodeBlock;

@end
