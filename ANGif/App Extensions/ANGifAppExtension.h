//
//  ANGifAppExtension.h
//  GifPro
//
//  Created by Alex Nichol on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANGifAppExtension : NSObject {
	NSData * applicationIdentifier;
	NSData * applicationAuthCode;
	NSData * applicationData;
}

@property (nonatomic, retain) NSData * applicationIdentifier;
@property (nonatomic, retain) NSData * applicationAuthCode;
@property (nonatomic, retain) NSData * applicationData;

- (NSData *)encodeBlock;

@end
