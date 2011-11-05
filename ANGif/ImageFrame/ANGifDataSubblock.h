//
//  ANGifDataSubblock.h
//  GifPro
//
//  Created by Alex Nichol on 11/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANGifDataSubblock : NSObject {
	NSData * subblockData;
}

+ (NSArray *)dataSubblocksForData:(NSData *)largeData;

- (id)initWithBlockData:(NSData *)theData;
- (NSData *)encodeBlock;
- (void)writeToFileHandle:(NSFileHandle *)fileHandle;

@end
