//
//  Hacker_DojoAppDelegate.m
//  Hacker Dojo
//
//  Created by Jonathan Hull on 11/17/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "Hacker_DojoAppDelegate.h"
#import "EventList.h"

@implementation Hacker_DojoAppDelegate


@synthesize window;

@synthesize tabBarController;
@synthesize eventNavController;
@synthesize eventList;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Override point for customization after application launch.
    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];
    [window makeKeyAndVisible];
    
    self.eventList = [[EventList alloc]init];
    //[eventList readScheduleFromDisk];//read schedule from disk if available
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [eventList saveScheduleToDisk];
    // Save data if appropriate.
}

- (void)dealloc {
    [eventList release];
    eventList = nil;
    [window release];
    [tabBarController release];
    [super dealloc];
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/

@end
