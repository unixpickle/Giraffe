//
//  ANGifNetscapeAppExtension.h
//  GifPro
//
//  Created by Alex Nichol on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ANGifAppExtension.h"

@interface ANGifNetscapeAppExtension : ANGifAppExtension {
	UInt16 numberOfRepeats;
}

@property (readonly) UInt16 numberOfRepeats;

- (id)initWithRepeatCount:(UInt16)repeats;

@end
