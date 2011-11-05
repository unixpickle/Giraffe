//
//  ANGifLogicalScreenDescriptor.h
//  GifPro
//
//  Created by Alex Nichol on 11/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANGifLogicalScreenDesc : NSObject {
	UInt16 screenWidth;
	UInt16 screenHeight;
	BOOL globalColorTable;
	UInt8 gtcSize;
	UInt8 backgroundColor;
}

@property (readwrite) UInt16 screenWidth;
@property (readwrite) UInt16 screenHeight;
@property (readwrite) BOOL globalColorTable;
@property (readwrite) UInt8 gctSize;
@property (readwrite) UInt8 backgroundColor;

- (NSData *)encodeBlock;

@end
