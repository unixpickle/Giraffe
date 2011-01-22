//
//  ANGifEncoder.m
//  Giraffe
//
//  Created by Alex Nichol on 1/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ANGifEncoder.h"

@interface ANGifEncoder ()

- (NSData *)gifHeader;
- (NSData *)globalColorTable;
- (NSData *)graphicsControlExtension;
- (NSData *)applicationPlugin;

// lzw compression
- (NSData *)nineBitData:(const char *)originalBytes length:(int)l;
- (NSData *)lzwCompression:(NSData *)original;

@end

@implementation ANGifEncoder

- (id)initWithFile:(NSString *)fileName animated:(BOOL)animated {
	if (self = [super init]) {
		_fileName = [[NSString stringWithString:fileName] retain];
		_animated = animated;
	}
	return self;
}
- (void)beginFile:(CGSize)size delayTime:(float)delay {
	_size = size;
	_delay = delay;
	FILE * fp = fopen([_fileName UTF8String], "w");
	fclose(fp);
	_fileHandle = [[NSFileHandle fileHandleForWritingAtPath:_fileName] retain];
	// write the header information later
	[_fileHandle writeData:[self gifHeader]];
	// write logical screen descriptor
	//  extraInfo = 256 colors at 3 * 8 bits/primary
	char extraInfo = 0xF7;
	[_fileHandle writeLittleShort:(UInt16)(size.width)];
	[_fileHandle writeLittleShort:(UInt16)(size.height)];
	[_fileHandle writeLittleChar:(UInt8)extraInfo];
	//  background color #0
	[_fileHandle writeLittleChar:0];
	//  pixel aspect ratio (set at zereo)
	[_fileHandle writeLittleChar:0];
	
	// WRITE GLOBAL COLOUR TABLE
	[_fileHandle writeData:[self globalColorTable]];
	
	// WRITE THE APPLICATION PLUGIN FOR ANIMATION
	if (_animated) {
		[_fileHandle writeData:[self applicationPlugin]];
	}
	
	// the next data that will be written
	// should be images, compressed by LZW
	
}
- (void)addImage:(ANGifBitmap *)bitmap {
	
	// WRITE THE GRAPHICS CONTROL EXTENSION
	[_fileHandle writeData:[self graphicsControlExtension]];
	
	// end of the header
	[_fileHandle writeLittleChar:0];
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	// add an image frame here
	[_fileHandle writeLittleChar:(UInt8)(',')];
	// coordinates of top left image
	[_fileHandle writeLittleInt:0];
	// size
	[_fileHandle writeLittleShort:(UInt16)(_size.width)];
	[_fileHandle writeLittleShort:(UInt16)(_size.height)];
	// no local color table
	[_fileHandle writeLittleChar:0];
	// LZW data
	//  LZW min. code size (symbol width)
	[_fileHandle writeLittleChar:8];
	// write a ton of code
	
	NSData * bmp = [bitmap smallBitmapData];
	const char * bitmapData = [bmp bytes];
	int bmplength = [bmp length];
	NSData * lzwdata = [self nineBitData:bitmapData length:bmplength];
	NSLog(@"LZW Length: %d", [lzwdata length]);
	int index = 0;
	int totalLength = 0;
	while (index < [lzwdata length]) {
		NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
		UInt8 blockLength = 10;
		if ([lzwdata length] - index < blockLength) {
			blockLength = [lzwdata length] - index;
		}
		totalLength += blockLength;
		const char * data = &((const char *)[lzwdata bytes])[index];
		[_fileHandle writeLittleChar:blockLength];
		
		NSData * blockBytes = [NSData dataWithBytes:data
											 length:blockLength];
		[_fileHandle writeData:blockBytes];
		index += blockLength;
		[pool drain];
	}
	NSLog(@"%d", totalLength);
	// terminating sub-block
	[_fileHandle writeLittleChar:0];
	
	[pool drain];
}
- (void)endFile {
	// close off the file with any bytes needed
	// update any data in the headers
	
	char c = ';';
	[_fileHandle writeLittleChar:(UInt8)c];
	
	// then end the writing session
	[_fileHandle closeFile];
	[_fileHandle release];
	_fileHandle = nil;
}

- (void)dealloc {
	if (_fileHandle) {
		// close the file without finishing it off
		[_fileHandle closeFile];
		[_fileHandle release];
		_fileHandle = nil;
	}
	[super dealloc];
}

#pragma mark Private

- (NSData *)gifHeader {
	// six characters that start every gif image.
	// the version is 89a.
	return [@"GIF89a" dataUsingEncoding:NSASCIIStringEncoding];
}

- (NSData *)globalColorTable {
	// create a color table
	// containing a set of
	// 256 different colors.
	UInt8 bytes[3];
	NSMutableData * colorTable = [NSMutableData data];
	for (UInt8 i = 0; true; i++) {
		// get bytes
		UInt8 red = (i & 3) * 64;
		UInt8 green = ((i >> 2) & 3) * 64;
		UInt8 blue = ((i >> 4) & 3) * 64;
		
		//NSLog(@"%d %d %d", red, green, blue);
		//NSLog(@"Shift: %d", (i >> 2));
		
		bytes[0] = red;
		bytes[1] = green;
		bytes[2] = blue;
		// create the RGB
		[colorTable appendBytes:bytes length:3];
		if (i == 255) break;
	}
	return colorTable;
}

- (NSData *)graphicsControlExtension {
	NSMutableData * gce = [[NSMutableData alloc] init];
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	// sentinel and GCE label (F9)
	char sentinelData[2];
	sentinelData[0] = '!';
	sentinelData[1] = 0xF9;
	[gce appendData:[NSData dataWithBytes:sentinelData 
								   length:2]];
	// four bytes of extension data
	UInt8 extensionLength = 4;
	[gce appendData:[NSData dataWithBytes:&extensionLength
								   length:1]];
	
	// there is a transparent color
	UInt8 transColor = 1;
	[gce appendData:[NSData dataWithBytes:&transColor
								   length:1]];
	
	// animation delay (hundreths of a second)
	UInt16 delayTime = (UInt16)((int)_delay * 100);
	[gce appendData:[NSData dataWithBytes:&delayTime length:2]];
	
	// transparent color index (0)
	UInt8 transparentColor = 0;
	[gce appendData:[NSData dataWithBytes:&transparentColor
								   length:1]];
	
	[pool drain];
	return [gce autorelease];
	
}

- (NSData *)applicationPlugin {
	NSMutableData * d = [[NSMutableData alloc] init];
	
	[d appendBytes:"\x21\xFF\x0B" length:3];
	[d appendBytes:"\x4E\x45\x54" length:3];
	[d appendBytes:"\x53\x43\x41" length:3];
	[d appendBytes:"\x50\x45\x32" length:3];
	[d appendBytes:"\x2E\x30" length:2]; // NETSCAPE2.0
	[d appendBytes:"\x03\x01" length:2];
	[d appendBytes:"\xFF\xFF" length:2]; // Loop animation
	[d appendBytes:"\x00" length:1];
	
	return [d autorelease];
}

- (NSData *)nineBitData:(const char *)originalBytes length:(int)l {
	NSLog(@"Original bytes");
	for (int i = 0; i < l; i++) {
		// NSLog(@"%02x", (unsigned char)originalBytes[i]);
	}
	BitBuffer orig = BitBufferNewBytes((Byte *)originalBytes, l);
	// create the new data from this
	UInt32 nBits = l*9 + (l*9) + 9;
	UInt8 overhead = (UInt8)(nBits % 8);
	BitBuffer compressed = BitBufferNew(nBits / 8 + 2);
	for (int i = 0; i < 8 - overhead; i++) {
		//BitBufferAddBit(compressed, 0);
	}
	// loop through and set the bytes
	for (int i = 0; i < orig->bitCount; i++) {
		if (i % 8 == 0) {
			// here we will write the clear character
			for (int j = 0; j < 8; j++) {
				BitBufferAddBit(compressed, 0);
			}	
			BitBufferAddBit(compressed, 1);
			// here we write the first bit of
			// our new byte (padding to nine bits/byte).
			
		}
		BitBufferAddBit(compressed, BitBufferGetBit(orig, (UInt32)i));
		if ((i + 1) % 8 == 0) BitBufferAddBit(compressed, 0);
	}
	
	
	
	// finish our data off
	// with a termination nine-bit code
	BitBufferAddBit(compressed, 1);
	for (int i = 0; i < 7; i++) {
		BitBufferAddBit(compressed, 0);
	}
	BitBufferAddBit(compressed, 1);
	
	printf("\n");
	
	UInt32 length = 0;
	char * returnData = (char *)BitBufferGetBytes(compressed, &length);
	BitBufferFree(compressed, 0);
	BitBufferFree(orig, 1);
	return [NSData dataWithBytesNoCopy:returnData
								length:length freeWhenDone:YES];
}

@end

@implementation NSFileHandle (numbers)

- (void)writeASCII:(NSString *)asciiString {
	[self writeData:[asciiString dataUsingEncoding:NSASCIIStringEncoding]];
}
- (void)writeLittleChar:(UInt8)tinyInt {
	[self writeData:[NSData dataWithBytes:&tinyInt length:1]];
}
- (void)writeLittleShort:(UInt16)shortInt {
	[self writeData:[NSData dataWithBytes:&shortInt length:2]];
}
- (void)writeLittleInt:(UInt32)regInt {
	[self writeData:[NSData dataWithBytes:&regInt length:4]];
}
- (void)writeLittleLong:(UInt64)longInt {
	[self writeData:[NSData dataWithBytes:&longInt length:8]];
}

@end
