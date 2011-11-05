//
//  GiraffeViewController.m
//  Giraffe
//
//  Created by Alex Nichol on 1/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GiraffeViewController.h"

@implementation GiraffeViewController

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		if (!imageFrames) {
			imageFrames = [[NSMutableArray alloc] init];
		}
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super initWithCoder:aDecoder])) {
		if (!imageFrames) {
			imageFrames = [[NSMutableArray alloc] init];
		}
	}
	return self;
}

- (id)init {
	if ((self = [super init])) {
		if (!imageFrames) {
			imageFrames = [[NSMutableArray alloc] init];
		}
	}
	return self;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}


#pragma mark Actions

- (IBAction)addFrame:(id)sender {
	if (!imagePicker) {
		imagePicker = [[UIImagePickerController alloc] init];
		imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:
								   UIImagePickerControllerSourceTypePhotoLibrary];
		[imagePicker setDelegate:self];
		[imagePicker setAllowsEditing:NO];
	}
	[self presentModalViewController:imagePicker animated:YES];
}

- (IBAction)doneEditing:(id)sender {
	[navItem setRightBarButtonItem:editButton animated:YES];
	[tableView setEditing:NO animated:YES];
}

- (IBAction)edit:(id)sender {
	[navItem setRightBarButtonItem:doneButton animated:YES];
	[tableView setEditing:YES animated:YES];
}

- (IBAction)exportVideo:(id)sender {
	NSString * tempFile = [NSString stringWithFormat:@"%@/%ld", NSTemporaryDirectory(), time(NULL)];
	NSMutableArray * images = [NSMutableArray array];
	for (PhotoEntry * entry in imageFrames) {
		[images addObject:entry.image];
	}
	ExportViewController * export = [[ExportViewController alloc] initWithImages:images];
	[self presentModalViewController:export animated:YES];
	[export encodeToFile:tempFile callback:^(NSString * aFile) {
		NSData * attachmentData = [NSData dataWithContentsOfFile:aFile];
		NSLog(@"Path: %@", aFile);
		//[[NSFileManager defaultManager] removeItemAtPath:aFile error:nil];
		MFMailComposeViewController * compose = [[MFMailComposeViewController alloc] init];
		[compose setSubject:@"Gif Image"];
		[compose setMessageBody:@"I have kindly attached a GIF image to this E-mail. I made this GIF using ANGif, an open source Objective-C library for exporting animated GIFs." isHTML:NO];
		[compose addAttachmentData:attachmentData mimeType:@"image/gif" fileName:@"image.gif"];
		[compose setMailComposeDelegate:self];
		[self performSelector:@selector(showViewController:) withObject:compose afterDelay:1];
#if !__has_feature(objc_arc)
		[compose release];
#endif
		[self dismissModalViewControllerAnimated:YES];
	}];
#if !__has_feature(objc_arc)
	[export release];
#endif
}

- (void)showViewController:(UIViewController *)controller {
	[self presentModalViewController:controller animated:YES];
}

#pragma mark View Lifecycle


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

#pragma mark - Table View -

#pragma mark Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [imageFrames count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell * imageCell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
	if (!imageCell) {
		imageCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
#if !__has_feature(objc_arc)
		[imageCell autorelease];
#endif
	}
	imageCell.imageView.image = [[imageFrames objectAtIndex:indexPath.row] image];
	imageCell.imageView.contentMode = UIViewContentModeScaleAspectFit;
	imageCell.textLabel.text = (NSString *)[[imageFrames objectAtIndex:indexPath.row] imageName];
	return imageCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 70;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[imageFrames removeObjectAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
						 withRowAnimation:UITableViewRowAnimationFade];
	}
}

- (void)tableView:(UITableView *)aTableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
	[imageFrames swapValueAtIndex:[sourceIndexPath row] withValueAtIndex:[destinationIndexPath row]];
	[tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
}

#pragma mark - Delegates -

#pragma mark Image Picker

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	PhotoEntry * entry = [[PhotoEntry alloc] initWithName:[NSString stringWithFormat:@"Image %d", ++itemID]
													image:[info objectForKey:UIImagePickerControllerOriginalImage]];
	[imageFrames addObject:entry];
#if !__has_feature(objc_arc)
	[entry release];
#endif
	[tableView reloadData];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark Navigation Controller

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Memory Management -

#if !__has_feature(objc_arc)
- (void)dealloc {
	[imageFrames release];
	[imagePicker release];
    [super dealloc];
}
#endif

@end
