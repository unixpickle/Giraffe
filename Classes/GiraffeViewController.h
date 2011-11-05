//
//  GiraffeViewController.h
//  Giraffe
//
//  Created by Alex Nichol on 1/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "PhotoEntry.h"
#import "NSMutableArray+Move.h"
#import "ExportViewController.h"

@interface GiraffeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate> {
	IBOutlet UIBarButtonItem * doneButton;
	IBOutlet UIBarButtonItem * editButton;
	NSMutableArray * imageFrames;
	UIImagePickerController * imagePicker;
	NSUInteger itemID;
	IBOutlet UINavigationItem * navItem;
	IBOutlet UITableView * tableView;
}

- (IBAction)addFrame:(id)sender;
- (IBAction)doneEditing:(id)sender;
- (IBAction)edit:(id)sender;
- (IBAction)exportVideo:(id)sender;

- (void)showViewController:(UIViewController *)controller;

@end

