//
//  SecondViewController.h
//  Hacker Dojo
//
//  Created by Jonathan Hull on 11/17/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRefreshTableViewController.h"

#define allEventsSegment 0
#define scheduledEventsSegment 1

@interface EventViewController : PullRefreshTableViewController <UITableViewDelegate,UITableViewDataSource>{
    IBOutlet UITableView *eventTableView;
    IBOutlet UISegmentedControl *scheduleSwitch;
    
    NSMutableArray *searchResults;
    NSString *savedSearchTerm;
    
    NSArray *eventsByDay;
    NSArray *scheduledEvents;
    NSArray *sourceArray;
}
@property (retain,nonatomic) UITableView *eventTableView;
@property (retain,nonatomic) NSMutableArray *searchResults;
@property (copy,nonatomic) NSString *savedSearchTerm;

@property (retain,nonatomic) NSArray *eventsByDay;
@property (retain,nonatomic) NSArray *scheduledEvents;
@property (retain,nonatomic) NSArray *sourceArray;

//-(void)handleSearchForTerm:(NSString*)searchTerm;

-(IBAction)addEventHit:(id)sender;

@end
