//
//  GiraffeViewController.m
//  Giraffe
//
//  Created by Alex Nichol on 1/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GiraffeViewController.h"
#import "ANGifEncoder.h"
#import "ANGifBitmap.h"

@implementation GiraffeViewController



/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



- (void)convert {
	NSString * fileName = [NSString stringWithFormat:@"%@/Documents/foo.gif", NSHomeDirectory()];
	ANGifBitmap * bmp = [[ANGifBitmap alloc] initWithImage:[UIImage imageNamed:@"ball.png"]];
	ANGifBitmap * bmp2 = [[ANGifBitmap alloc] initWithImage:[UIImage imageNamed:@"ball2.png"]];
	ANGifBitmap * bmp3 = [[ANGifBitmap alloc] initWithImage:[UIImage imageNamed:@"ball3.png"]];
	ANGifEncoder * enc = [[ANGifEncoder alloc] initWithFile:fileName animated:YES];
	[enc beginFile:bmp.size
		 delayTime:0.5];
	[enc addImage:bmp];
	[enc addImage:bmp2];
	[enc addImage:bmp3];
	[enc endFile];
	[enc release];
	NSLog(@"%@", fileName);
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self performSelector:@selector(convert) withObject:nil afterDelay:0.1];
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
