//
//  Event.h
//  Hacker Dojo Test
//
//  Created by Jonathan Hull on 12/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

#define eventRSVPNotAttending 3
#define eventRSVPMightAttend 2
#define eventRSVPAttending 1
#define eventRSVPStaffing 0

@interface Event : NSObject {
	NSString *title;
    NSDate *startTime;
	NSString *creator;
    NSString *eventType;
    NSInteger size;
    NSInteger eventId;
    
    NSString *status;
    
    
    //Details
    NSDate *endTime;
	NSArray *rooms;
	NSString *details;
    NSString *cost;
    NSArray *staff;
    
    BOOL hasDetails;
    
    //Search
    NSString *searchString;
    
    NSUInteger rsvp;
    
    NSString *calendarEventId;
}
@property (copy,nonatomic) NSString *title;
@property (copy,nonatomic) NSArray *rooms;
@property (copy,nonatomic) NSString *details;
@property (retain,nonatomic) NSDate *startTime;
@property (retain,nonatomic) NSDate *endTime;
@property (copy,nonatomic) NSString *creator;
@property (copy,nonatomic) NSString *eventType;
@property (assign,nonatomic) NSInteger size;
@property (assign,nonatomic) NSInteger eventId;
@property (copy,nonatomic) NSString *searchString;
@property (copy,nonatomic) NSString *cost;
@property (copy,nonatomic) NSString *status;
@property (retain,nonatomic) NSArray *staff;

@property (assign,nonatomic) BOOL hasDetails;
@property (assign,nonatomic) NSUInteger rsvp;

@property (copy,nonatomic) NSString *calendarEventId;

-(void)calculateSearchString;
-(NSString*)roomString;
-(NSString*)shortRoomString;
-(NSString*)creatorName;
-(NSString*)length;
-(BOOL)isHappeningNow;

-(BOOL)isCancelled;

-(BOOL)createMatchingCalendarEvent;
-(BOOL)removeMatchingCelendarEvent;


@end
