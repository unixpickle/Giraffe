//
//  GiraffeAppDelegate.h
//  Giraffe
//
//  Created by Alex Nichol on 1/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GiraffeViewController;

@interface GiraffeAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    GiraffeViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet GiraffeViewController *viewController;

@end

