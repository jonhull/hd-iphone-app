//
//  Staff.h
//  Hacker Dojo Test
//
//  Created by Jonathan Hull on 12/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Staff : NSObject {
	NSString *name;
	NSString *email;
	NSDate *loginTime;
	NSString *imageURL;
	UIImage *picture;
	BOOL keyholder;
	BOOL imageRequestSent;
	NSMutableData *responseData;//data for download of image
}
@property (retain, nonatomic) NSMutableData *responseData;

@property (retain, nonatomic) NSString *name;
@property (retain, nonatomic) NSString *email;
@property (retain, nonatomic) NSDate *loginTime;
@property (retain, nonatomic) NSString *imageURL;
@property (retain, nonatomic) UIImage *picture;
@property (assign, nonatomic) BOOL keyholder;

-(NSString*)time;

@end
