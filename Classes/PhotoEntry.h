//
//  PhotoEntry.h
//  Giraffe
//
//  Created by Alex Nichol on 11/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BitmapScaleManipulator.h"

@interface PhotoEntry : NSObject {
	NSString * imageName;
	UIImage * image;
}

@property (readonly) UIImage * image;
@property (readonly) NSString * imageName;

- (id)initWithName:(NSString *)name image:(UIImage *)anImage;

@end
