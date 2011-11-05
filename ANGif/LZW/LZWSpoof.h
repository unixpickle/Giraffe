//
//  LZWSpoof.h
//  GifPro
//
//  Created by Alex Nichol on 11/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BitOutOfRangeException @"BitOutOfRangeException"

@interface LZWSpoof : NSObject {
	UInt8 * _bytePool;
	NSUInteger _totalSize;
	NSUInteger numBits;
}

@property (readonly) NSUInteger numBits;

+ (NSData *)lzwExpandData:(NSData *)existingData;

- (id)initWithData:(NSData *)initialData;
- (void)addBit:(BOOL)flag;
- (BOOL)getBitAtIndex:(NSUInteger)bitIndex;
- (NSData *)convertToData;

@end
