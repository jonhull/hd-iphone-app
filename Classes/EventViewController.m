//
//  SecondViewController.m
//  Hacker Dojo
//
//  Created by Jonathan Hull on 11/17/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "EventViewController.h"
#import "Hacker_DojoAppDelegate.h"
#import "EventList.h"
#import "Event.h"
#import "EventDetailViewController.h"
#import "EventTableViewCell.h"

@implementation EventViewController
@synthesize eventTableView;
@synthesize searchResults,savedSearchTerm;
@synthesize eventsByDay,scheduledEvents,sourceArray;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchResults = [NSMutableArray array];
    
    //This is a bit of a hack, I really should find a better place to keep the eventList.
    Hacker_DojoAppDelegate *appDel = (Hacker_DojoAppDelegate*)[[UIApplication sharedApplication]delegate];
    self.eventsByDay = [[appDel eventList]eventsByDay];
    self.scheduledEvents = [[appDel eventList]scheduledEventsByDay];

    self.sourceArray = self.eventsByDay;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(eventListUpdatedNotification:) name:@"EventsListUpdatedNotification" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(scheduledEventsUpdatedNotification:) name:@"ScheduledEventsUpdatedNotification" object:nil];
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
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [eventsByDay release];
    [scheduledEvents release];
    [sourceArray release];
    [searchResults release];
    [savedSearchTerm release];
    [eventTableView release];
    [super dealloc];
}

#pragma mark -

- (void)refresh {
    Hacker_DojoAppDelegate *appDel = (Hacker_DojoAppDelegate*)[[UIApplication sharedApplication]delegate];
    [[appDel eventList]fetch];

    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:2.0];
}

#pragma mark -

-(NSString*)humanStringForDate:(NSDate*)aDate
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    //We have to test the difference from midnight instead of the current time (otherwise things under 24 hours away will show as today).
    NSDateComponents *todayComponents = [gregorian components:(NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit) fromDate:[NSDate date]];
    NSDate *midnight = [gregorian dateFromComponents:todayComponents];
    
    NSDateComponents *components = [gregorian components:NSDayCalendarUnit fromDate:midnight toDate:aDate options:0];
    NSInteger daysFromToday = [components day];
    
	if (daysFromToday==0)
		return @"Today";
	if (daysFromToday==1)
		return @"Tomorrow";
	
	NSDateFormatter *formatter = [[[NSDateFormatter alloc]init]autorelease];
	[formatter setDateFormat:@"EEEE, MMM d"];
	
	if (daysFromToday < 7 && daysFromToday > 0)
		[formatter setDateFormat:@"EEEE"];
	
	return [formatter stringFromDate:aDate];
}

#pragma mark Actions
-(IBAction)addEventHit:(id)sender
{
    NSLog(@"Add Event Hit!!!");
}

-(IBAction)scheduleSwitchHit:(id)sender
{
    if([scheduleSwitch selectedSegmentIndex]==allEventsSegment){
        self.sourceArray = self.eventsByDay;
    }else{
        self.sourceArray = self.scheduledEvents;
    }
    [eventTableView reloadData];
}

#pragma mark Search
//-(void)handleSearchForTerm:(NSString*)searchTerm
-(void)filterContentForSearchText:(NSString*)searchTerm scope:(NSString*)scope
{
    [self setSavedSearchTerm:searchTerm];
    NSLog(@"Handling search for Term:%@",searchTerm);
    
    
    NSPredicate *pred = nil;
    
    NSMutableString *searchText = [NSMutableString stringWithString:searchTerm];
	
	// Remove extraenous whitespace
	while ([searchText rangeOfString:@"  "].location != NSNotFound) {
		[searchText replaceOccurrencesOfString:@"  " withString:@" " options:0 range:NSMakeRange(0, [searchText length])];
	}
	
	//Remove leading space
	if ([searchText length] != 0) [searchText replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange(0,1)];
	
	//Remove trailing space
	if ([searchText length] != 0) [searchText replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange([searchText length]-1, 1)];
	
	
    
    //We split words into separate searches in case they match against different fields ("iOS Dec" would match iOS events in December).
	NSArray *searchTerms = [searchText componentsSeparatedByString:@" "];
	
	if ([searchTerms count] == 1) {
		pred = [NSPredicate predicateWithFormat:@"(SELF.searchString contains[cd] %@) OR (SELF.details contains[cd] %@)", searchText,searchText];
	} else {
		NSMutableArray *subPredicates = [[NSMutableArray alloc] init];
		for (NSString *term in searchTerms) {
			NSPredicate *p = [NSPredicate predicateWithFormat:@"(SELF.searchString contains[cd] %@) OR (SELF.details contains[cd] %@)", term, term];
			[subPredicates addObject:p];
		}
		pred = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
	}
        
    //NSPredicate *pred = [NSPredicate predicateWithFormat:@"(SELF.searchString contains[cd] %@)", searchTerm]; 
    [searchResults removeAllObjects];
    
    for(NSArray *dayArray in eventsByDay){
        NSArray *filteredArray = [dayArray filteredArrayUsingPredicate:pred];
        if([filteredArray count]){
            [searchResults addObject:filteredArray];
        }
    }
}

#pragma mark Notifications
-(void)eventListUpdatedNotification:(NSNotification*)aNote
{
    Hacker_DojoAppDelegate *appDel = (Hacker_DojoAppDelegate*)[[UIApplication sharedApplication]delegate];
    self.eventsByDay = [[appDel eventList]eventsByDay];
    if([scheduleSwitch selectedSegmentIndex]==allEventsSegment){
        self.sourceArray = self.eventsByDay;
    }
    [eventTableView reloadData];
}

-(void)scheduledEventsUpdatedNotification:(NSNotification*)aNote
{
    Hacker_DojoAppDelegate *appDel = (Hacker_DojoAppDelegate*)[[UIApplication sharedApplication]delegate];
    self.scheduledEvents = [[appDel eventList]scheduledEventsByDay];
    if([scheduleSwitch selectedSegmentIndex]==scheduledEventsSegment){
        self.sourceArray = self.scheduledEvents;
        [eventTableView reloadData];
    }
}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView){
        return [searchResults count];
    }
	return [sourceArray count];//[eventsByDay count];
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView){
        if([searchResults count]>section){
            return [[searchResults objectAtIndex:section]count];
        }
        return 0;
    }
    
    if([sourceArray count]>section){
        return [[sourceArray objectAtIndex:section]count];
    }
    //if([eventsByDay count]>section){
    //    return [[eventsByDay objectAtIndex:section]count];
    //}
    return 0;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    Event *event=nil;
    if (tableView == self.searchDisplayController.searchResultsTableView){
       event = [[searchResults objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
    }else{
       event = [[sourceArray objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
    }
    
    EventTableViewCell *cell = (EventTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"EventItemCell"];
    if (cell==nil) {
        cell = (EventTableViewCell*)[[[EventTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EventItemCell"]autorelease];
    }
    cell.title = event.title;
    cell.time = event.startTime;
    cell.location = [event shortRoomString];//@"Location";
    cell.isCancelled = [event isCancelled];
    if(cell.isCancelled){
        cell.detail = @"CANCELLED";
    }else{
        cell.detail = [NSString stringWithFormat:@"%@ - %@",[event length],event.eventType]; //@"1 hour - workshop";
    }
    
    return cell;
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *eventArray = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView){
        eventArray = searchResults;
    }else{
        eventArray = sourceArray;//eventsByDay;
    }
    
    if(section >= [eventArray count]){
        return @"Ruh-Row";
    }
    
    NSArray *sectionArray = [eventArray objectAtIndex:section];
    if([sectionArray count]==0){
        return @"Ruh-Row";
    }
    
    Event *event = [sectionArray objectAtIndex:0];
    return [self humanStringForDate:event.startTime];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *eventArray = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView){
        eventArray = searchResults;
    }else{
        eventArray = sourceArray;//eventsByDay;
    }
    
    //if (tableView == self.searchDisplayController.searchResultsTableView){
        
    //}else{
        EventDetailViewController *vc = [[EventDetailViewController alloc]initWithNibName:@"EventDetailView" bundle:nil];
        vc.event = [[eventArray objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    //}
    /*
	if([indexPath section]>=[[self eventsList]numberOfDaysLoaded]){
		self.isLoadingEvents=YES;
		[self.eventsList.eventFeed fetchNumberOfDays:7];
		[self.eventTableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
	}
     */
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}



@end
