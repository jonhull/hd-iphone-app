//
//  EventDetailViewController.m
//  Hacker Dojo
//
//  Created by Jonathan Hull on 11/22/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "EventDetailViewController.h"
#import "Event.h"
#import "JONListViewController.h"
#import "EventStaffViewController.h"
#import "MapViewController.h"
#import "Hacker_DojoAppDelegate.h"
#import "EventList.h"


@implementation EventDetailViewController
@synthesize event;
@synthesize detailTable;
@synthesize titleView,lengthView;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleView.font = [UIFont boldSystemFontOfSize:18.0];
    self.lengthView.font = [UIFont systemFontOfSize:12.0];
    
    [self.navigationItem setTitle:@"Event Detail"];
    
    self.titleView.text = event.title;
    
    self.lengthView.text = [NSString stringWithFormat:@"%@ - %@",[event length],event.eventType];
    
    
    //Resize title view
    CGRect titleFrame = self.titleView.frame;
    CGSize size = [self.titleView.text sizeWithFont:self.titleView.font
                                     constrainedToSize:CGSizeMake(titleFrame.size.width, titleFrame.size.height)
                                         lineBreakMode:UILineBreakModeWordWrap];
    if(size.height > 30){//If it wont fit on a single line, use a smaller font
        self.titleView.font = [UIFont boldSystemFontOfSize:14.0];
        size = [self.titleView.text sizeWithFont:self.titleView.font
                                   constrainedToSize:CGSizeMake(titleFrame.size.width, titleFrame.size.height)
                                       lineBreakMode:UILineBreakModeWordWrap];
    }
    CGFloat delta = size.height - titleFrame.size.height;
    titleFrame.size.height = size.height;
    [self.titleView setFrame:titleFrame];
    
    //move lengthView under resized titleView
    [self.lengthView setFrame:CGRectOffset(self.lengthView.frame, 0, delta)];
    
}

/*
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

#pragma mark -
-(NSString*)humanStringForDate:(NSDate*)aDate
{
    NSDateFormatter *formatter = [[[NSDateFormatter alloc]init]autorelease];
    
    if([event isHappeningNow]){
        [formatter setDateFormat:@"h:mma"];
        return [NSString stringWithFormat:@"Now (until %@)",[formatter stringFromDate:event.endTime]];
    }
       
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    //We have to test the difference from midnight instead of the current time (otherwise things under 24 hours away will show as today).
    NSDateComponents *todayComponents = [gregorian components:(NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit) fromDate:[NSDate date]];
    NSDate *midnight = [gregorian dateFromComponents:todayComponents];
    
    NSDateComponents *components = [gregorian components:NSDayCalendarUnit fromDate:midnight toDate:aDate options:0];
    NSInteger daysFromToday = [components day];
    
    
	if (daysFromToday==0){
        [formatter setDateFormat:@"h:mma"];
		return [NSString stringWithFormat:@"Today @ %@",[formatter stringFromDate:aDate]];
    }
    if (daysFromToday==1){
        [formatter setDateFormat:@"h:mma"];
		return [NSString stringWithFormat:@"Tomorrow @ %@",[formatter stringFromDate:aDate]];//@"Tomorrow";
	}
    
	//NSDateFormatter *formatter = [[[NSDateFormatter alloc]init]autorelease];
	[formatter setDateFormat:@"EEE, MMM d @ h:mma"];
	
	if (daysFromToday < 7)
		[formatter setDateFormat:@"EEEE @ h:mma"];
	
	return [formatter stringFromDate:aDate];
}

-(BOOL)isHosting
{
    NSUserDefaults *prefs=[NSUserDefaults standardUserDefaults];
	NSString *loginEmail = [prefs stringForKey:@"loginEmail"];
    return [event.creator isEqualToString:loginEmail];
}

#pragma mark TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){//InfoSection
        return 2;
    }
    if(section == 1){//Attending Section
        return 1;
    }
    if(section == 2){//Description Section
        return 3;
    }
    if(section == 3){//Staff Section
        return 0;
    }
    return 0;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    
    if(indexPath.section == 0){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventDetailItemCell"];
        if (cell==nil) {
            cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EventDetailItemCell"]autorelease];
        }
        
        if(indexPath.row == 0){//Event Time
            NSString *dateStr = [self humanStringForDate:event.startTime];
            if([event isCancelled]){
                cell.textLabel.text = [NSString stringWithFormat:@"(Cancelled) %@",dateStr];
            }else{
                cell.textLabel.text = dateStr;//@"Sat, Dec 4 @ 7:30PM";//@"Time";
            }
            //cell.textLabel.text = @"(Cancelled) Sat, Dec 4 @ 7:30PM";//@"Time";
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.imageView.image = [UIImage imageNamed:@"clock"];
            //cell.imageView.image = [UIImage imageNamed:@"EventCalendar"];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }else if(indexPath.row == 1){
            cell.textLabel.text =  [event roomString];//@"Savannah";//@"Location";
                                               //cell.detailTextLabel.text = @"Savannah";
                                               //cell.imageView.image = [UIImage imageNamed:@"53-house"];
            cell.imageView.image = [UIImage imageNamed:@"map-pin"];
            //cell.imageView.image = [UIImage imageNamed:@"103x-map"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }
        
        return cell;
    }
    
    if(indexPath.section == 1){//RSVP Section
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventDetailItemCell"];
        if (cell==nil) {
            cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EventDetailItemCell"]autorelease];
        }
        if(indexPath.row == 0){
            if([self isHosting]){
                cell.textLabel.text = @"Hosting (Attending)";
                cell.imageView.image = [UIImage imageNamed:@"RSVP"];
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }else{
                switch(event.rsvp){
                    case eventRSVPStaffing:
                        cell.textLabel.text = @"Staffing (Attending)";break;
                    case eventRSVPMightAttend:
                        cell.textLabel.text = @"Might Attend";break;
                    case eventRSVPAttending:
                        cell.textLabel.text = @"Attending";break;
                    default:
                        cell.textLabel.text = @"Not Attending";
                }
                cell.imageView.image = [UIImage imageNamed:@"RSVP"];
                //cell.imageView.image = [UIImage imageNamed:@"category_icon_festival"];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            }
            return cell;
        }else if(indexPath.row == 1){
            cell.textLabel.text = @"No Reminder";
            cell.imageView.image = [UIImage imageNamed:@"alarm"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            return cell;
        }
    }
    
    if(indexPath.section == 2){
        if(indexPath.row == 0){
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"longTextCell"];
            if (cell==nil) {
                cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"longTextCell"]autorelease];
            }
            if([event.details isEqualToString:@""]){
                cell.textLabel.text = @"No description for this event.";
                cell.textLabel.textColor = [UIColor lightGrayColor];
            }else{
                cell.textLabel.text = event.details;
                cell.textLabel.textColor = [UIColor darkTextColor];
            }
            
            //cell.imageView.image = [UIImage imageNamed:@"chat"];
            cell.textLabel.font = [UIFont systemFontOfSize:14.0];
            cell.textLabel.numberOfLines = 0;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }else if(indexPath.row == 1){
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventDetailItemCell"];
            if (cell==nil) {
                cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EventDetailItemCell"]autorelease];
            }
            cell.textLabel.text = [event creatorName];//event.creator;
            cell.imageView.image = [UIImage imageNamed:@"smallPerson"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            return cell;
        }else{
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventDetailItemCell"];
            if (cell==nil) {
                cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EventDetailItemCell"]autorelease];
            }
            if([event.cost isEqualToString:@""] || event.cost == nil){
                cell.textLabel.text = @"Free";
            }else{
                cell.textLabel.text = event.cost;
            }
            cell.imageView.image = [UIImage imageNamed:@"smallDollar"];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventDetailCell"];
    if (cell==nil) {
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"EventDetailCell"]autorelease];
    }
    return cell;
}


- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 1){
        return @"RSVP";
    }
    if(section == 2){
        return @"Details";
    }
    if(section == 3){
        //return @"Staff";
    }


    return nil;
}

/*
- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if(section==2){
        return @"Members may attend any event for free, but must pay to recieve food or materials.";
    }
    return nil;
}
 */

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 2 && indexPath.row == 0){
        if([event.details isEqualToString:@""]){
            return 44.0;
        }
        CGFloat width = 280;//320 - cell buffer(20) - label buffer(20)
        CGSize size = [event.details sizeWithFont:[UIFont systemFontOfSize:14.0]
                                constrainedToSize:CGSizeMake(width, 9999)
                                    lineBreakMode:UILineBreakModeWordWrap];
        return (size.height > 23.0) ? size.height + 20.0 : 44.0;
    }
    return 44.0;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && indexPath.row == 1){
        MapViewController *vc = [[MapViewController alloc]initWithNibName:@"MapViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    }else if(indexPath.section == 1 && ![self isHosting]){
        Hacker_DojoAppDelegate *appDel = (Hacker_DojoAppDelegate*)[[UIApplication sharedApplication]delegate];
        EventList *eventList = [appDel eventList];
        
        JONListItem *staffingItem = [[JONListItem alloc]initWithTitle:@"Staffing" image:nil block:^(JONListItem *item){
            NSLog(@"Do Special Stuff for staffing");
            if(event.rsvp == eventRSVPNotAttending){
                event.rsvp = eventRSVPStaffing;
                [event createMatchingCalendarEvent];
                [eventList addScheduledEvent:event];
            }else{
                event.rsvp = eventRSVPStaffing;
            }
            [tableView reloadData];
        }];
        NSArray *choices = [NSArray arrayWithObjects:staffingItem,@"Attending",@"Might Attend",@"Not Attending",nil];
        JONListViewController *listVC = [[JONListViewController alloc]initWithList:choices selection:event.rsvp block:^(NSArray *list,NSInteger selection){
            
            if(event.rsvp == eventRSVPNotAttending && selection != eventRSVPNotAttending){//If notAttending -> Anything else
                event.rsvp = selection;
                [event createMatchingCalendarEvent];                                      //Add event to calendar
                [eventList addScheduledEvent:event];
            }else if(event.rsvp != eventRSVPNotAttending && selection == eventRSVPNotAttending){//else if Anything else -> notAttending
                event.rsvp = selection;
                [event removeMatchingCelendarEvent];                                            //Remove event from calendar
                [eventList removeScheduledEvent:event];
            }
            [tableView reloadData];
            NSLog(@"Selected:%@",[list objectAtIndex:selection]);
        }];
        listVC.title = @"RSVP";
        [self.navigationController pushViewController:listVC animated:YES];
        [listVC release];
    }else if(indexPath.section == 2 && indexPath.row == 1){
        EventStaffViewController *vc = [[EventStaffViewController alloc]initWithNibName:@"EventStaffViewController" bundle:nil];
        vc.event = self.event;
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    }
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
