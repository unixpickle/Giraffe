/*
 *  BitBuffer.h
 *  Giraffe
 *
 *  Created by Alex Nichol on 1/21/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

#define kByteAdd 512
#define kReverseEndian 1

struct _BitBuffer {
	UInt8 * bytes;
	int byteCount;
	int bitCount;
};

typedef struct _BitBuffer *BitBuffer;

BitBuffer BitBufferNew (UInt32 initialBytes);
BitBuffer BitBufferNewBytes (Byte * bytes, UInt32 length);
void BitBufferAddBit (BitBuffer bb, UInt8 isOn);
UInt8 BitBufferGetBit (BitBuffer bb, UInt32 _bitIndex);
const Byte * BitBufferGetBytes (BitBuffer bb, UInt32 * length);
void BitBufferFree (BitBuffer bb, UInt8 deleteBuffer);
