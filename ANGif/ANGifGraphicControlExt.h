//
//  ANGifGraphicControlExtension.h
//  GifPro
//
//  Created by Alex Nichol on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kGraphicControlLabel 0xF9

@interface ANGifGraphicControlExt : NSObject {
	BOOL userInputFlag;
	BOOL transparentColorFlag;
	UInt8 transparentColorIndex;
	NSTimeInterval delayTime;
}

@property (readwrite) BOOL userInputFlag;
@property (readwrite) BOOL transparentColorFlag;
@property (readwrite) UInt8 transparentColorIndex;
@property (readwrite) NSTimeInterval delayTime;

- (NSData *)encodeBlock;

@end
