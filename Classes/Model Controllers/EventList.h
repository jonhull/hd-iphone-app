//
//  EventList.h
//  Hacker Dojo
//
//  Created by Jonathan Hull on 11/18/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Event;

@interface EventList : NSObject {
    NSArray *eventsByDay;//Holds an array of events for each day with events
    NSMutableDictionary *scheduledEvents;//Holds events that the user is hosting or attending (key = id, value = event)
    NSURL *url;
    BOOL checkingNow;
    
    dispatch_queue_t backgroundQueue;
}
@property (retain,nonatomic) NSURL *url;
@property (retain,nonatomic) NSArray *eventsByDay;
@property (readonly,nonatomic) BOOL checkingNow;

-(void)fetch;
-(void)fetchDetailForEvent:(Event*)anEvent;

-(NSArray*)eventsInProgress;

-(NSArray*)scheduledEventsByDay;//Returns array of arrays of events by day
-(void)addScheduledEvent:(Event*)anEvent;
-(void)removeScheduledEvent:(Event*)anEvent;

-(void)saveScheduleToDisk;
-(NSMutableArray*)readScheduleFromDisk;

@end
