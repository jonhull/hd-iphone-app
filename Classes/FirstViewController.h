//
//  FirstViewController.h
//  Hacker Dojo
//
//  Created by Jonathan Hull on 11/17/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"
#import "PullRefreshTableViewController.h"
@class StaffList;
@class Staff;

#define dojoNewsSection 0
#define currentStaffSection 2
#define currentEventsSection 1

#define actionSheetStaffBtn 0
#define actionSheetMemberBtn 1
#define actionSheetSettingsBtn 2

@interface FirstViewController : PullRefreshTableViewController <UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,settingsViewControllerDelegate> {
    IBOutlet UITableView *mainTableView;
    //IBOutlet UIViewController *settingsViewController;
	IBOutlet UIBarButtonItem *loginButton;
    
    StaffList *staffList;
    NSArray* eventsInProgress;

    BOOL isLoadingCurrentStaff;
	BOOL noCurrentStaff;
	BOOL connectionErrorStaff;
    
    BOOL isLoadingEvents;
    BOOL noEventsInProgress;
    BOOL connectionErrorEvents;
    
    BOOL isLoggingInOrOut;
}
@property (retain,nonatomic) UITableView *mainTableView;
@property (retain,nonatomic) UIBarButtonItem *loginButton;

@property (retain,nonatomic) StaffList *staffList;
@property (retain,nonatomic) NSArray *eventsInProgress;

@property (assign,nonatomic) BOOL isLoadingCurrentStaff;
@property (assign,nonatomic) BOOL noCurrentStaff;

#pragma mark Notifications
-(void)staffItemUpdatedNotification:(NSNotification*)aNote;//an individual staff item has changed (most likely picture downloaded)
-(void)staffListUpdatedNotification:(NSNotification*)aNote;//staff list has been reloaded
-(void)staffNetworkProblemNotification:(NSNotification*)aNote;
-(void)eventsListUpdatedNotification:(NSNotification*)aNote;


#pragma mark Login
-(Staff*)staffForUser;
-(BOOL)isLoggedIn;
-(BOOL)postLogin:(NSString*)emailStr ofType:(NSInteger)loginType;
-(BOOL)postLogout:(NSString*)emailStr;
-(IBAction)loginHit:(id)sender;

#pragma mark Settings

-(void)showSettingsView;


@end
