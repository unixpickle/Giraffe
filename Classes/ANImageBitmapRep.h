//
//  ANImageBitmapRep.h
//  ANImageBitmapRep
//
//  Created by Alex Nichol on 5/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>


@interface ANImageBitmapRep : NSObject {
	CGContextRef ctx;
	CGImageRef img;
	BOOL changed;
	char * bitmapData;
}
- (id)initWithSize:(CGSize)sz;
- (void)setNeedsUpdate;
- (void)setQuality:(float)percent;
- (void)setBrightness:(float)percent;
+ (CGContextRef)CreateARGBBitmapContextWithSize:(CGSize)size;
+ (CGContextRef)CreateARGBBitmapContextWithImage:(CGImageRef)image;
- (id)initWithImage:(UIImage *)_img;
+ (id)imageBitmapRepWithImage:(UIImage *)_img;
+ (id)imageBitmapRepNamed:(NSString *)_resourceName;
- (void)getPixel:(CGFloat *)pxl atX:(int)x y:(int)y;
- (void)setPixel:(CGFloat *)pxl atX:(int)x y:(int)y;
- (void)get255Pixel:(char *)pxl atX:(int)x y:(int)y;
- (void)set255Pixel:(char *)pxl atX:(int)x y:(int)y;
- (CGImageRef)CGImage;
- (UIImage *)image;
- (void)setSize:(CGSize)size;
- (CGSize)size;
- (void)drawInRect:(CGRect)r;
- (CGContextRef)graphicsContext;
- (void)invertColors;
@end

@interface UIImage (ANImageBitmapRep)

- (ANImageBitmapRep *)imageBitmapRep;

@end
