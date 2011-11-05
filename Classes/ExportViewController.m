//
//  ExportViewController.m
//  Giraffe
//
//  Created by Alex Nichol on 11/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ExportViewController.h"

@interface ExportViewController (Background)

- (void)setProgressLabel:(NSString *)label;
- (void)setProgressPercent:(NSNumber *)percent;
- (void)informCallbackDone:(NSString *)file;

- (void)exportThread:(NSString *)fileOutput;
- (ANGifImageFrame *)imageFrameWithImage:(UIImage *)anImage fitting:(CGSize)imageSize;

@end

@implementation ExportViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithImages:(NSArray *)imageArray {
	if ((self = [super init])) {
#if __has_feature(objc_arc)
		images = imageArray;
#else
		images = [imageArray retain];
#endif
		self.view.backgroundColor = [UIColor whiteColor];
	}
	return self;
}

- (void)encodeToFile:(NSString *)fileName callback:(void (^)(NSString * file))callback {
#if __has_feature(objc_arc)
	doneCallback = callback;
#else
	if (doneCallback) Block_release(doneCallback);
	doneCallback = Block_copy(callback);
#endif
	[NSThread detachNewThreadSelector:@selector(exportThread:) toTarget:self withObject:fileName];
}

#pragma mark - View lifecycle -

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	// progressStatus, progressView
	progressStatus = [[UILabel alloc] initWithFrame:CGRectMake(10, 120, 300, 20)];
	progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(10, 160, 300, 20)];
	[progressStatus setBackgroundColor:[UIColor clearColor]];
	[progressStatus setTextAlignment:UITextAlignmentCenter];
	[self.view addSubview:progressStatus];
	[self.view addSubview:progressView];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Background Thread -

- (void)exportThread:(NSString *)fileOutput {
	@autoreleasepool {
		// statements here
		[self setProgressLabel:@"Opening file ..."];
		[self setProgressPercent:[NSNumber numberWithFloat:0]];
		UIImage * firstImage = nil;
		if ([images count] > 0) {
			firstImage = [images objectAtIndex:0];
		}
		CGSize canvasSize = (firstImage ? firstImage.size : CGSizeZero);
		ANGifEncoder * encoder = [[ANGifEncoder alloc] initWithOutputFile:fileOutput size:canvasSize globalColorTable:nil];
		ANGifNetscapeAppExtension * extension = [[ANGifNetscapeAppExtension alloc] init];
		[encoder addApplicationExtension:extension];
#if !__has_feature(objc_arc)
		[extension release];
#endif
		[self setProgressLabel:@"Writing frames ..."];
		[self setProgressPercent:[NSNumber numberWithFloat:0.1]];
		float numberOfFrames = (float)[images count];
		for (int i = 0; i < [images count]; i++) {
			float progress = 0.1 + ((0.9 / (float)numberOfFrames) * (float)i);
			[self setProgressPercent:[NSNumber numberWithFloat:progress]];
			[self setProgressLabel:[NSString stringWithFormat:@"Resizing Frame (%d/%d)", i + 1, (int)[images count]]];
			UIImage * image = [images objectAtIndex:i];
			ANGifImageFrame * theFrame = [self imageFrameWithImage:image fitting:canvasSize];
			[self setProgressLabel:[NSString stringWithFormat:@"Encoding Frame (%d/%d)", i + 1, (int)[images count]]];
			[encoder addImageFrame:theFrame];
		}
		[encoder closeFile];
#if !__has_feature(objc_arc)
		[encoder release];
#endif
		[self performSelectorOnMainThread:@selector(informCallbackDone:) withObject:fileOutput waitUntilDone:NO];
	}
}

- (ANGifImageFrame *)imageFrameWithImage:(UIImage *)anImage fitting:(CGSize)imageSize {
	UIImage * scaledImage = anImage;
	if (!CGSizeEqualToSize(anImage.size, imageSize)) {
		scaledImage = [anImage imageFittingFrame:imageSize];
	}

	UIImagePixelSource * pixelSource = [[UIImagePixelSource alloc] initWithImage:scaledImage];
	ANCutColorTable * colorTable = [[ANCutColorTable alloc] initWithTransparentFirst:YES pixelSource:pixelSource];
	ANGifImageFrame * frame = [[ANGifImageFrame alloc] initWithPixelSource:pixelSource colorTable:colorTable delayTime:1];
#if !__has_feature(objc_arc)
	[colorTable release];
	[pixelSource release];
	[frame autorelease];
#endif
	return frame;
}

#pragma mark Background Callbacks

- (void)setProgressLabel:(NSString *)label {
	if ([[NSThread currentThread] isMainThread]) {
		[progressStatus setText:label];
	} else {
		[self performSelectorOnMainThread:@selector(setProgressLabel:)
							   withObject:label waitUntilDone:NO];
	}
}

- (void)setProgressPercent:(NSNumber *)percent {
	if ([[NSThread currentThread] isMainThread]) {
		[progressView setProgress:[percent floatValue]];
	} else {
		[self performSelectorOnMainThread:@selector(setProgressPercent:)
							   withObject:percent waitUntilDone:NO];
	}
}

- (void)informCallbackDone:(NSString *)file {
	if (doneCallback) doneCallback(file);
}

#pragma mark - Memory Management -

#if !__has_feature(objc_arc)

- (void)dealloc {
	[images release];
	[progressView release];
	[progressStatus release];
	if (doneCallback) Block_release(doneCallback);
	[super dealloc];
}

#endif

@end
