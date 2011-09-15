//
//  FirstViewController.m
//  Hacker Dojo
//
//  Created by Jonathan Hull on 11/17/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "FirstViewController.h"

#import "StaffList.h"
#import "EventList.h"
#import "Event.h"

#import "LoadingTableViewCell.h"
#import "StaffTableViewCell.h"
//#import "DateTableViewCell.h"
#import "EventTableViewCell.h"

#import "SettingsViewController.h"
#import "EventDetailViewController.h"

#import "Hacker_DojoAppDelegate.h"

@implementation FirstViewController
@synthesize mainTableView,loginButton;
@synthesize staffList,eventsInProgress;
@synthesize isLoadingCurrentStaff,noCurrentStaff;


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"button:%@",loginButton);
    self.staffList = [[[StaffList alloc]init]autorelease];
	loginButton.possibleTitles = [NSSet setWithObjects:@"Sign Out",@"Sign In",@"       ",nil];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(staffListUpdatedNotification:) name:@"StaffListUpdatedNotification" object:nil];
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(staffItemUpdatedNotification:) name:@"StaffImageUpdatedNotification" object:nil];
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(staffNetworkProblemNotification:) name:@"StaffNetworkFailureNotification" object:self.staffList];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(eventsListUpdatedNotification:) name:@"EventsListUpdatedNotification" object:nil];
    
    isLoadingCurrentStaff = YES;
	connectionErrorStaff = NO;

    isLoadingEvents = YES;
    //isLoggingInOrOut = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[staffList fetch];//reload the list when the view becomes active
    //Hacker_DojoAppDelegate *appDel = (Hacker_DojoAppDelegate*)[[UIApplication sharedApplication]delegate];
    //self.eventsInProgress = [[appDel eventList]eventsInProgress];
    //[[self mainTableView] reloadSections:[NSIndexSet indexSetWithIndex:currentEventsSection] withRowAnimation:UITableViewRowAnimationNone];
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
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    [mainTableView release];
    [loginButton release];
    self.eventsInProgress = nil;
    self.staffList = nil;
    
    [super dealloc];
}

#pragma mark Notifications

/*
 //an individual staff item has changed (most likely picture downloaded)
 */
-(void)staffItemUpdatedNotification:(NSNotification*)aNote
{
    Staff *updatedStaff = [aNote object];
	
	int i = 0;
	for(Staff *member in [[self staffList]currentStaff]){
		if ([member isEqual:updatedStaff]) {
			[[self mainTableView] reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:currentStaffSection]] withRowAnimation:UITableViewRowAnimationNone];
			return;
		}
		i++;
	}
}


/*
 staff list has been reloaded

 */
-(void)staffListUpdatedNotification:(NSNotification*)aNote
{
    isLoadingCurrentStaff = NO;
    connectionErrorStaff = NO;
    
    if ([self isLoggedIn] ) {
        loginButton.title = [loginButton.possibleTitles member:@"Sign Out"];
    }else {
        loginButton.title = [loginButton.possibleTitles member:@"Sign In"];
    }

    [[self mainTableView] reloadSections:[NSIndexSet indexSetWithIndex:currentStaffSection] withRowAnimation:UITableViewRowAnimationFade];
    //[self stopLoading];
}

-(void)staffNetworkProblemNotification:(NSNotification*)aNote
{
	isLoadingCurrentStaff = NO;
	connectionErrorStaff = YES;
	[[self mainTableView] reloadSections:[NSIndexSet indexSetWithIndex:currentStaffSection] withRowAnimation:UITableViewRowAnimationFade];
    //[self stopLoading];
}

-(void)eventsListUpdatedNotification:(NSNotification*)aNote
{
    Hacker_DojoAppDelegate *appDel = (Hacker_DojoAppDelegate*)[[UIApplication sharedApplication]delegate];
    self.eventsInProgress = [[appDel eventList]eventsInProgress];
    isLoadingEvents = NO;
    noEventsInProgress = ([eventsInProgress count]==0);
    connectionErrorEvents = NO;
    [[self mainTableView] reloadSections:[NSIndexSet indexSetWithIndex:currentEventsSection] withRowAnimation:UITableViewRowAnimationFade];
    //[self stopLoading];
}

#pragma mark Pull Refresh

- (void)refresh {
    //Hacker_DojoAppDelegate *appDel = (Hacker_DojoAppDelegate*)[[UIApplication sharedApplication]delegate];
    //[[appDel eventList]fetch];
    [staffList fetch];
    Hacker_DojoAppDelegate *appDel = (Hacker_DojoAppDelegate*)[[UIApplication sharedApplication]delegate];
    self.eventsInProgress = [[appDel eventList]eventsInProgress];
    noEventsInProgress = ([eventsInProgress count]==0);
    [[self mainTableView] reloadSections:[NSIndexSet indexSetWithIndex:currentEventsSection] withRowAnimation:UITableViewRowAnimationFade];
    
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:2.0];
}

//-(void)refresh
//{
//    [staffList fetch];
//}

#pragma mark Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return 0;
    }
    if(section == currentStaffSection){
        if(connectionErrorStaff || isLoadingCurrentStaff){
            return 1;
        }
        NSInteger cnt = [[staffList currentStaff]count];
        if(cnt == 0){
            return 1;
        }
        return cnt;
    }
    if(section == currentEventsSection){
        if(isLoadingEvents || noEventsInProgress || connectionErrorEvents){
            return 1;
        }
        return [eventsInProgress count];
    }
	return 0;	
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if(indexPath.section == currentStaffSection){
        if(isLoadingCurrentStaff || [[staffList currentStaff]count] == 0){
            LoadingTableViewCell *loadingCell = (LoadingTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
            if(loadingCell == nil){
                loadingCell = [[[LoadingTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LoadingCell"]autorelease];
            }
            if (isLoadingCurrentStaff){
                loadingCell.textLabel.text=@"Loading...";
                loadingCell.imageView.image = nil;
                loadingCell.selectionStyle=UITableViewCellSelectionStyleNone;
            }else if (connectionErrorStaff) {
                loadingCell.textLabel.text=@"Unable to Connect";
                loadingCell.textLabel.adjustsFontSizeToFitWidth=YES;
                loadingCell.imageView.image = [UIImage imageNamed:@"Error.png"];
                UIImageView *imageView = [[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"refreshIcon.png"] highlightedImage:[UIImage imageNamed:@"refreshSelected.png"]]autorelease];
                loadingCell.accessoryView = imageView;
                loadingCell.selectionStyle=UITableViewCellSelectionStyleGray;
            }else {
                loadingCell.textLabel.text=@"No Current Staff";
                loadingCell.imageView.image = [UIImage imageNamed:@"noStaff.png"];
                loadingCell.selectionStyle=UITableViewCellSelectionStyleNone;
            }
            loadingCell.isLoading = isLoadingCurrentStaff;
            return loadingCell;
        }
        
        StaffTableViewCell *staffCell = (StaffTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"StaffCell"];
        if(staffCell == nil){
            staffCell = [[[StaffTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"StaffCell"]autorelease];
        }
        Staff *staffMember = [[[self staffList]currentStaff] objectAtIndex:indexPath.row];
		staffCell.name = [staffMember name];
		staffCell.email = [staffMember email];
		staffCell.time = [staffMember time];
		staffCell.picture = [staffMember picture];
		staffCell.keyholder = [staffMember keyholder];
		staffCell.selectionStyle=UITableViewCellSelectionStyleNone;
        return staffCell;
    }
	
    if(indexPath.section == currentEventsSection){
        if(isLoadingEvents || noEventsInProgress || connectionErrorEvents){
            LoadingTableViewCell *loadingCell = (LoadingTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
            if(loadingCell == nil){
                loadingCell = [[[LoadingTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LoadingCell"]autorelease];
            }
            if (isLoadingEvents){
                loadingCell.textLabel.text=@"Loading...";
                loadingCell.imageView.image = nil;
                loadingCell.selectionStyle=UITableViewCellSelectionStyleNone;
            }else if (connectionErrorEvents) {
                loadingCell.textLabel.text=@"Unable to Connect";
                loadingCell.textLabel.adjustsFontSizeToFitWidth=YES;
                loadingCell.imageView.image = [UIImage imageNamed:@"Error.png"];
                UIImageView *imageView = [[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"refreshIcon.png"] highlightedImage:[UIImage imageNamed:@"refreshSelected.png"]]autorelease];
                loadingCell.accessoryView = imageView;
                loadingCell.selectionStyle=UITableViewCellSelectionStyleGray;
            }else {
                loadingCell.textLabel.text=@"No Events In Progress";
                loadingCell.textLabel.adjustsFontSizeToFitWidth = YES;
                loadingCell.imageView.image = [UIImage imageNamed:@"noEvents.png"];
                loadingCell.selectionStyle=UITableViewCellSelectionStyleNone;
            }
            loadingCell.isLoading = isLoadingEvents;
            return loadingCell;
        }
        
        EventTableViewCell *cell = (EventTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"EventItemCell"];
        if (cell==nil) {
            cell = [[[EventTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EventItemCell"]autorelease];
        }
        Event *event = [eventsInProgress objectAtIndex:indexPath.row];
        cell.title = event.title;
        cell.time = event.startTime;
        cell.location = [event shortRoomString];//@"Location";
        cell.detail = [NSString stringWithFormat:@"%@ - %@",[event length],event.eventType];//@"1 hour - workshop";
        return cell;

        
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"blankCell"];
    if (cell==nil) {
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"blankCell"]autorelease];
    }
    cell.textLabel.text = @"Ruh Row - Something is Wrong!";
    return cell;
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == dojoNewsSection) {
		return nil;
        //return @"Dojo News";
	}
    if (section == currentStaffSection) {
		return @"Staff";
	}
	if (section == currentEventsSection) {
		return @"Events In Progress";
	}
	return nil;
}


- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([indexPath section]==currentStaffSection) {
        NSInteger cnt = [[[self staffList]currentStaff]count];
        if(isLoadingCurrentStaff || connectionErrorStaff || cnt == 0){
            return 44;
        }
        if ([indexPath row]==(cnt-1)) {//add extra space after the last staffCell
            return StaffCell_Height + StaffCell_Buffer;
        }
        return StaffCell_Height;
    }
    
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == currentEventsSection){
        if([eventsInProgress count]){
            EventDetailViewController *vc = [[EventDetailViewController alloc]initWithNibName:@"EventDetailView" bundle:nil];
            vc.event = [eventsInProgress objectAtIndex:indexPath.row];
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Login

-(Staff*)staffForUser
{
	NSUserDefaults *prefs=[NSUserDefaults standardUserDefaults];
	NSString *loginEmail = [prefs stringForKey:@"loginEmail"];
	
	return [staffList staffWithEmail:loginEmail];
}

-(BOOL)isLoggedIn
{
	NSUserDefaults *prefs=[NSUserDefaults standardUserDefaults];
	NSString *loginEmail = [prefs stringForKey:@"loginEmail"];
	
	return ([staffList staffWithEmail:loginEmail] != nil);
}

-(BOOL)postLogin:(NSString*)emailStr ofType:(NSInteger)loginType
{
	if (emailStr == nil) {
		return NO;
	}
	
	NSString *typeStr = nil;
    switch (loginType) {
		case actionSheetStaffBtn:
			typeStr = @"StaffKey";
			break;
		case actionSheetMemberBtn:
			typeStr = @"Member";
			break;
		default:
			break;
	}
	
	NSString *requestString = [NSString stringWithFormat:@"email=%@&type=%@",emailStr,typeStr, nil];
	NSLog(@"ReqStr:%@",requestString);
	NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:signInURL]];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
	[request setHTTPMethod: @"POST"];
	[request setHTTPBody: requestData];
	
	NSError *error = nil;
	[NSURLConnection sendSynchronousRequest: request returningResponse: nil error:&error];//Just posting so no need for return data
    
	return (error==nil);
}

-(BOOL)postLogout:(NSString*)emailStr
{
	NSString *requestString = [NSString stringWithFormat:@"email=%@",emailStr, nil];
	NSLog(@"ReqStr:%@",requestString);
	NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:signOutURL]];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
	[request setHTTPMethod: @"POST"];
	[request setHTTPBody: requestData];
	
	NSError *error = nil;// = [[NSError alloc] init];
	NSData *returnData = [ NSURLConnection sendSynchronousRequest: request returningResponse: nil error:&error];
	NSString *returnString = [[NSString alloc] initWithData:returnData encoding: NSUTF8StringEncoding];
	NSLog(@"url:%@ returnStr:%@ returnData:%@ error:%@",signOutURL,returnString,returnData,error);
	return (error==nil);
}


-(IBAction)loginHit:(id)sender
{
    if(isLoggingInOrOut){
        return;
    }
    
	NSUserDefaults *prefs=[NSUserDefaults standardUserDefaults];
	NSString *loginEmail = [prefs stringForKey:@"loginEmail"];
	
	if ([self isLoggedIn]) {
        isLoggingInOrOut = YES;
		loginButton.title = [loginButton.possibleTitles member:@"       "];
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        UINavigationBar* navbar = self.navigationController.navigationBar;
        spinner.frame = CGRectMake(281, 12, 20, 20);
        [navbar addSubview:spinner];
        [spinner startAnimating];
        
        dispatch_async(dispatch_get_global_queue(0,0),^{
            BOOL success=[self postLogout:loginEmail];
            dispatch_async(dispatch_get_main_queue(),^{
                [spinner stopAnimating];
                [spinner removeFromSuperview];
                [spinner release];
                
                if (success) {
                    [staffList fetch];
                    UIAlertView *welcomeAlert = [[UIAlertView alloc]initWithTitle:@"Thank You!" message:@"You have successfully signed out" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [welcomeAlert show];
                    [welcomeAlert release];
                    loginButton.title = [loginButton.possibleTitles member:@"Sign In"];
                }else{
                    NSString *msg = @"Check your network settings and try again";
                    UIAlertView *failAlert = [[UIAlertView alloc]initWithTitle:@"Unable to Connect" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [failAlert show];
                    [failAlert release];
                    loginButton.title = [loginButton.possibleTitles member:@"Sign Out"];
                }
                isLoggingInOrOut = NO;
            });
        });
	}else{
		if (loginEmail) {
            NSString *title = [NSString stringWithFormat:@"Sign in using\n%@",loginEmail];
			UIActionSheet *sheet = [[[UIActionSheet alloc]initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"as Staff",@"as Member",@"Settings...",nil]autorelease];
            
			sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
			[sheet showInView:self.tabBarController.view];
		}else {
            [self showSettingsView];
		}
        
	}
}

#pragma mark Settings

-(void)showSettingsView
{
	SettingsViewController *viewController = [[SettingsViewController alloc]initWithNibName:@"SettingsViewController" bundle:nil];
    viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    viewController.delegate = self;
    [self presentModalViewController:viewController animated:YES];
    [viewController release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheetSettingsBtn) {
		[self showSettingsView];
		
	}
    
	if (buttonIndex==actionSheetStaffBtn || buttonIndex==actionSheetMemberBtn) {
		NSUserDefaults *prefs=[NSUserDefaults standardUserDefaults];
		NSString *loginEmail = [prefs stringForKey:@"loginEmail"];
        //NSInteger loginType = [prefs integerForKey:@"loginType"];
		
		if (loginEmail) {//Should test to make sure it is a valid email
            isLoggingInOrOut = YES;//Make sure we don't post twice
            
            loginButton.title = [loginButton.possibleTitles member:@"       "];
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            UINavigationBar* navbar = self.navigationController.navigationBar;
            spinner.frame = CGRectMake(281, 12, 20, 20);//Should really calc this based on window width
            [navbar addSubview:spinner];
            [spinner startAnimating];
            
            dispatch_async(dispatch_get_global_queue(0,0),^{
                BOOL success=[self postLogin:loginEmail ofType:buttonIndex];
                dispatch_async(dispatch_get_main_queue(),^{
                    [spinner stopAnimating];
                    [spinner removeFromSuperview];
                    [spinner release];
                
                    if (success) {
                        [staffList fetch];//update with new login
                        NSString *msg = [NSString stringWithFormat:@"You have signed in as %@",loginEmail];
                        UIAlertView *welcomeAlert = [[UIAlertView alloc]initWithTitle:@"Welcome to the Hacker Dojo!" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [welcomeAlert show];
                        [welcomeAlert release];
                        loginButton.title = [loginButton.possibleTitles member:@"Sign Out"];
                        
                    }else{
                        NSString *msg = @"Check your network settings and try again";
                        UIAlertView *failAlert = [[UIAlertView alloc]initWithTitle:@"Unable to Connect" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [failAlert show];
                        [failAlert release];
                        loginButton.title = [loginButton.possibleTitles member:@"Sign In"];
                    }
                    isLoggingInOrOut = NO;
                });
            });
		}
	}
	
}


-(void)settingsViewController:(SettingsViewController*)contoller wasDismissed:(NSUInteger)dismissalType
{
    NSUserDefaults *prefs=[NSUserDefaults standardUserDefaults];
	NSString *loginEmail = [prefs stringForKey:@"loginEmail"];
    
    if (loginEmail) {
        NSString *title = [NSString stringWithFormat:@"Sign in using\n%@",loginEmail];
        UIActionSheet *sheet = [[[UIActionSheet alloc]initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"as Staff",@"as Member",@"Settings...",nil]autorelease];
        
        sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [sheet showInView:self.tabBarController.view];
    }
    
}

@end
