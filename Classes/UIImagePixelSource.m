//
//  UIImagePixelSource.m
//  Giraffe
//
//  Created by Alex Nichol on 11/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UIImagePixelSource.h"

@implementation UIImagePixelSource

- (id)initWithImage:(UIImage *)anImage {
	if ((self = [super init])) {
		imageRep = [[ANImageBitmapRep alloc] initWithImage:anImage];
	}
	return self;
}

+ (UIImagePixelSource *)pixelSourceWithImage:(UIImage *)anImage {
#if __has_feature(objc_arc)
	return [[UIImagePixelSource alloc] initWithImage:anImage];
#else
	return [[[UIImagePixelSource alloc] initWithImage:anImage] autorelease];
#endif
}

- (NSUInteger)pixelsWide {
	return [imageRep bitmapSize].x;
}

- (NSUInteger)pixelsHigh {
	return [imageRep bitmapSize].y;
}

- (void)getPixel:(NSUInteger *)pixel atX:(NSInteger)x y:(NSInteger)y {
	BMPixel bpixel = [imageRep getPixelAtPoint:BMPointMake(x, y)];
	pixel[0] = (NSUInteger)round(bpixel.red * 255.0);
	pixel[1] = (NSUInteger)round(bpixel.green * 255.0);
	pixel[2] = (NSUInteger)round(bpixel.blue * 255.0);
	pixel[3] = (NSUInteger)round(bpixel.alpha * 255.0);
}

- (BOOL)hasTransparency {
	return YES;
}

#if !__has_feature(objc_arc)
- (void)dealloc {
	[imageRep release];
	[super dealloc];
}
#endif

@end
