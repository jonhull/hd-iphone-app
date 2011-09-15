//
//  Hacker_DojoAppDelegate.h
//  Hacker Dojo
//
//  Created by Jonathan Hull on 11/17/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EventList;

@interface Hacker_DojoAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
    UINavigationController *eventNavController;
    
    EventList *eventList;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet UINavigationController *eventNavController;

@property (nonatomic,retain) EventList *eventList;


@end
