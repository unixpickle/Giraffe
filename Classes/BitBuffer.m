/*
 *  BitBuffer.m
 *  Giraffe
 *
 *  Created by Alex Nichol on 1/21/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#import "BitBuffer.h"

BitBuffer BitBufferNew (UInt32 initialBytes) {
	BitBuffer buffer = (BitBuffer)malloc(sizeof(struct _BitBuffer));
	bzero(buffer, sizeof(struct _BitBuffer));
	buffer->bytes = (UInt8 *)malloc(initialBytes);
	bzero(buffer->bytes, initialBytes);
	buffer->byteCount = initialBytes;
	buffer->bitCount = 0;
	return buffer;
}

BitBuffer BitBufferNewBytes (Byte * bytes, UInt32 length) {
	BitBuffer bb = BitBufferNew(length);
	memcpy(bb->bytes, bytes, length);
	bb->bitCount = length * 8;
	return bb;
}

void BitBufferAddBit (BitBuffer bb, UInt8 isOn) {
	UInt32 startByte = bb->bitCount / 8;
	// check if startByte is
	// over or equal to the byte
	// limit, if so we allocate
	// a new buffer
	if (startByte >= bb->byteCount) {
		Byte * newBuffer = (Byte *)malloc(bb->byteCount + kByteAdd);
		bzero(&newBuffer[bb->byteCount], kByteAdd);
		memcpy(newBuffer, bb->bytes, bb->byteCount);
		// free the old one
		free(bb->bytes);
		bb->bytes = newBuffer;
		bb->byteCount += kByteAdd;
	}
	
	UInt32 startBit = bb->bitCount % 8;
	Byte c = bb->bytes[startByte];
	// set the flag
	if (kReverseEndian)
		c |= isOn << startBit;
	else
		c |= (isOn << 7) >> startBit;
	bb->bytes[startByte] = c;
	bb->bitCount += 1;
}

UInt8 BitBufferGetBit (BitBuffer bb, UInt32 _bitIndex) {
	UInt32 byteIndex = _bitIndex / 8;
	UInt32 bitIndex = _bitIndex % 8;
	// make a mask
	if (kReverseEndian) bitIndex = 7 - bitIndex;
	UInt8 mask = (1 << 7) >> bitIndex;
	
	// get the byte from the mask
	UInt8 flag = bb->bytes[byteIndex] & mask;
	flag = (flag << bitIndex) >> 7;
	return flag;
}

const Byte * BitBufferGetBytes (BitBuffer bb, UInt32 * length) {
	// get the total length of bytes USED,
	// not the bytes allocated
	*length = bb->bitCount / 8 + (bb->bitCount % 8 == 0 ? 0 : 1);
	return bb->bytes;
}

void BitBufferFree (BitBuffer bb, UInt8 deleteBuffer) {
	if (deleteBuffer) free(bb->bytes);
	// zero the memory so that it
	// is clean for the next allocator :)
	bzero(bb, sizeof(struct _BitBuffer));
	free(bb);
}