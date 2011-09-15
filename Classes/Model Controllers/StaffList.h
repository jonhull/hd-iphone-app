//
//  StaffList.h
//  Hacker Dojo Test
//
//  Created by Jonathan Hull on 12/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Staff.h"
//#import "JSON/JSON.h"


@interface StaffList : NSObject {
	NSArray *currentStaff;
	NSURL *url;
	NSMutableData *responseData;
	NSURLConnection *currentConnection;
	BOOL checkingNow;
}
@property (retain,nonatomic) NSArray *currentStaff;
@property (retain,nonatomic) NSURL *url;
@property (retain,nonatomic) NSMutableData *responseData;
@property (retain,nonatomic) NSURLConnection *currentConnection;

-(void)fetch;

-(void)makeFakeArray;

-(Staff*)staffWithEmail:(NSString*)emailStr;

@end
