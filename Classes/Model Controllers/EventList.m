//
//  EventList.m
//  Hacker Dojo
//
//  Created by Jonathan Hull on 11/18/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "EventList.h"
#import "Event.h"
#import "JSON.h"
#import <dispatch/dispatch.h>
@implementation EventList
@synthesize url,eventsByDay,checkingNow;


-(id)init
{
	if(self=[super init]){
        backgroundQueue = dispatch_queue_create("eventBackgroundQueue", NULL);
		checkingNow = NO;
		self.url = [NSURL URLWithString:jsonEventListURL];
        scheduledEvents = [[self readScheduleFromDisk]retain];
        if(scheduledEvents == nil){
            scheduledEvents = [[NSMutableDictionary alloc] init];
		}
        [self fetch];
	}
	return self;
}


- (void)dealloc {
    if(backgroundQueue){
        dispatch_release(backgroundQueue);
        backgroundQueue = NULL;
    }
    [url release];
    [super dealloc];
}


-(void)fetch
{
    checkingNow = YES;
    NSLog(@"Fetching... Use blocks");
    
    //dispatch_queue_t queue = dispatch_get_global_queue(0,0);
    dispatch_async(backgroundQueue,^{
        NSError *error = nil;
        NSURLResponse  *response = nil;
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:jsonEventListURL]];
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if(error){
            NSLog(@"Error fetching eventList:%@",[error localizedDescription]);
        }else{
            
            NSString *responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
            
            //NSLog(@"Event Response:%@",responseString);
            
            NSError *jsonError;
            SBJSON *json = [[SBJSON new] autorelease];
            NSArray *jsonArray = [json objectWithString:responseString error:&jsonError];
            [responseString release];
            
            if(jsonArray == nil){
                
            }
            
            NSArray *eventsArray = [NSArray array];
            NSArray *dayArray = nil;
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
            
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSInteger lastDay = 0;
            NSInteger lastMonth = 0;
            NSInteger lastYear = 0;
            
            
            for(NSDictionary *eventData in jsonArray){
                NSNumber *newEventId = [eventData objectForKey:@"id"];
                Event *event = [scheduledEvents objectForKey:newEventId];
                if(event == nil){
                    event = [[Event alloc]init];
                    event.eventId = [newEventId integerValue];
                }
                //event.eventId = [[eventData objectForKey:@"id"]integerValue];
                event.title = [eventData objectForKey:@"name"];
                event.startTime = [formatter dateFromString:[eventData objectForKey:@"start_time"]];
                event.endTime = [formatter dateFromString:[eventData objectForKey:@"end_time"]];
                event.size = [[eventData objectForKey:@"estimated_size"]integerValue];
                event.eventType = [eventData objectForKey:@"type"];
                event.creator = [eventData objectForKey:@"member"];
                event.rooms = [eventData objectForKey:@"rooms"];
                event.status = [eventData objectForKey:@"status"];
                //More event details here
                
                [event calculateSearchString];
                
                [self fetchDetailForEvent:event];
                
                NSDateComponents *components = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:event.startTime];
                NSInteger newDay = [components day];
                NSInteger newMonth = [components month];
                NSInteger newYear = [components year];
                if(newDay!=lastDay || newMonth!=lastMonth || newYear!=lastYear){
                    if(dayArray){
                        eventsArray = [eventsArray arrayByAddingObject:dayArray];
                    }
                    dayArray = [NSArray array];
                }
                dayArray = [dayArray arrayByAddingObject:event];
                
                lastDay = newDay;
                lastMonth = newMonth;
                lastYear = newYear;
                
            }
            if(dayArray){
                eventsArray = [eventsArray arrayByAddingObject:dayArray];
            }
            [formatter release];
            [gregorian release];
            
            //Back on main thread
            dispatch_async(dispatch_get_main_queue(),^{
                self.eventsByDay = eventsArray;
                [[NSNotificationCenter defaultCenter]postNotificationName:@"EventsListUpdatedNotification" object:nil];
            });
        }
        
                           
        checkingNow = NO;
    });
}

-(void)fetchDetailForEvent:(Event*)anEvent
{
    if(anEvent == nil){
        return;
    }
    
    //dispatch_queue_t queue = dispatch_get_global_queue(0,0);
    dispatch_async(backgroundQueue,^{
        NSError *error = nil;
        NSURLResponse  *response = nil;
        NSString *urlString = [NSString stringWithFormat:jsonEventDetailFormat,anEvent.eventId];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if(error){
            NSLog(@"Error fetching event detail:%@ for event:%@",[error localizedDescription],anEvent);
        }else{
            
            NSString *responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
            
            //NSLog(@"Event Response:%@",responseString);
            
            NSError *jsonError;
            SBJSON *json = [[SBJSON new] autorelease];
            NSDictionary *jsonDict = [json objectWithString:responseString error:&jsonError];
            [responseString release];
            
            NSLog(@"Decoded Event:%@",[jsonDict objectForKey:@"name"]);
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
            NSDate *endDate = [formatter dateFromString:[jsonDict objectForKey:@"end_time"]];
            [formatter release];
            
        
            //Back on main thread
            dispatch_async(dispatch_get_main_queue(),^{
                anEvent.details = [jsonDict objectForKey:@"details"];
                anEvent.cost = [jsonDict objectForKey:@"fee"];
                anEvent.rooms = [jsonDict objectForKey:@"rooms"];
                anEvent.status = [jsonDict objectForKey:@"status"];
                anEvent.staff = [jsonDict objectForKey:@"staff"];
                anEvent.endTime = endDate;
                //set event stuff
                [[NSNotificationCenter defaultCenter]postNotificationName:@"EventUpdatedNotification" object:anEvent];
            });
        }
    });
}

-(NSArray*)eventsInProgress
{
    //Replace with actual events in progress
    if([eventsByDay count]){
        NSArray *inProgress = [NSArray array];
        for(Event *event in [eventsByDay objectAtIndex:0]){
            if([event isHappeningNow]){
                inProgress = [inProgress arrayByAddingObject:event];
            }
        }
        return inProgress;
    }
    return nil;
}

#pragma mark Sheduled Events
-(NSArray*)scheduledEventsByDay
{
    NSArray *sortedArray = [[scheduledEvents allValues] sortedArrayUsingComparator:^(id a, id b){
        return [[a startTime] compare:[b startTime]];
    }];
    
    NSArray *eventsArray = [NSArray array];
    NSArray *dayArray = nil;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger lastDay = 0;
    NSInteger lastMonth = 0;
    NSInteger lastYear = 0;
    
    for(Event *event in sortedArray){
        NSDateComponents *components = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:event.startTime];
        NSInteger newDay = [components day];
        NSInteger newMonth = [components month];
        NSInteger newYear = [components year];
        if(newDay!=lastDay || newMonth!=lastMonth || newYear!=lastYear){
            if(dayArray){
                eventsArray = [eventsArray arrayByAddingObject:dayArray];
            }
            dayArray = [NSArray array];
        }
        dayArray = [dayArray arrayByAddingObject:event];
        
        lastDay = newDay;
        lastMonth = newMonth;
        lastYear = newYear;
    }
    if(dayArray){
        eventsArray = [eventsArray arrayByAddingObject:dayArray];
    }
    [gregorian release];
    return eventsArray;
}

-(void)addScheduledEvent:(Event*)anEvent
{
    if(anEvent == nil){
        return;
    }
    NSInteger eventId = anEvent.eventId;
    NSNumber *key = [NSNumber numberWithInteger:eventId];
    if(key){
        [scheduledEvents setObject:anEvent forKey:key];
        [self saveScheduleToDisk];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"ScheduledEventsUpdatedNotification" object:anEvent];
    }
}

-(void)removeScheduledEvent:(Event*)anEvent
{
    NSInteger eventId = anEvent.eventId;
    NSNumber *key = [NSNumber numberWithInteger:eventId];
    if(key){
        [scheduledEvents removeObjectForKey:key];
        [self saveScheduleToDisk];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"ScheduledEventsUpdatedNotification" object:anEvent];
    }
}

-(NSString*)scheduleFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:@"schedule"];// the path to write file
}

-(void)saveScheduleToDisk
{
    NSString *filePath = [self scheduleFilePath];
    NSMutableData *data = [[NSMutableData alloc]init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:scheduledEvents forKey:@"scheduledEvents"];
    [archiver finishEncoding];
    [data writeToFile:filePath atomically:YES];
    [archiver release];
    [data release];
}

-(NSMutableArray*)readScheduleFromDisk
{
    NSString *filePath = [self scheduleFilePath];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if(data){
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
        NSMutableArray *schedule = [unarchiver decodeObjectForKey:@"scheduledEvents"];
        [unarchiver finishDecoding];
        [unarchiver release];
        return schedule;
    }
    return nil;
}




@end
