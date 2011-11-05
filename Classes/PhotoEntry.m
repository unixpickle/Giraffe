//
//  PhotoEntry.m
//  Giraffe
//
//  Created by Alex Nichol on 11/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PhotoEntry.h"

@implementation PhotoEntry

@synthesize image;
@synthesize imageName;

- (id)initWithName:(NSString *)name image:(UIImage *)anImage {
	if ((self = [super init])) {
#if __has_feature(objc_arc)
		imageName = name;
#else
		imageName = [name retain];
#endif
		if (anImage.size.width > 640 || anImage.size.height > 480) {
			BitmapContextRep * bitmap = [[BitmapContextRep alloc] initWithImage:anImage];
			BitmapScaleManipulator * scale = [[BitmapScaleManipulator alloc] initWithContext:bitmap];
			[scale setSizeFittingFrame:BMPointMake(640, 480)];
			anImage = [[UIImage alloc] initWithCGImage:[scale CGImage]];
#if !__has_feature(objc_arc)
			[scale release];
			[bitmap release];
#endif
		} else {
#if __has_feature(objc_arc)
			image = anImage;
#else
			image = [anImage retain];
#endif
		}
	}
	return self;
}

#if !__has_feature(objc_arc)

- (void)dealloc {
	[image release];
	[imageName release];
	[super dealloc];
}

#endif

@end
