//
//  Staff.m
//  Hacker Dojo Test
//
//  Created by Jonathan Hull on 12/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Staff.h"


@implementation Staff

static UIImage *placeholderImage = nil;

@synthesize responseData;

@synthesize name;
@synthesize email;
@synthesize loginTime;
@synthesize picture;
@synthesize imageURL;
@synthesize keyholder;

+ (void)initialize
{
	if(self == [Staff class]){
		NSString *path=[[NSBundle mainBundle]pathForResource:@"icon" ofType:@"png"];
		placeholderImage = [[UIImage alloc] initWithContentsOfFile:path];
	}
}

-(void)dealloc
{
	[name release];
	[email release];
	[loginTime release];
	[picture release];
	[imageURL release];
	[responseData release];
	[super dealloc];
}

-(id)init
{
	if (self = [super init]) {
		picture = nil;
		self.responseData = [NSMutableData data];
		imageRequestSent = NO;
	}
	return self;
}

-(NSString*)time
{
	if (![self loginTime]) {
		return nil;
	}
	//NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
	
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSUInteger unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;
	
	NSDateComponents *components = [gregorian components:unitFlags
												fromDate:[self loginTime]
												  toDate:[NSDate date] options:0];
	
	if ([components hour]>1)
		return [NSString stringWithFormat:@"%d hours ago",[components hour]];
	if ([components hour]>0) 
		return [NSString stringWithFormat:@"%d hour %d min ago",[components hour],[components minute]];
	return [NSString stringWithFormat:@"%d minutes ago",[components minute]];
	
}

-(UIImage*)picture{
	if (picture==nil) {
		if(!imageRequestSent && (self.imageURL != nil)){
			NSURL *pictUrl = [NSURL URLWithString:self.imageURL];
			NSURLRequest *request = [NSURLRequest requestWithURL:pictUrl];
			[[NSURLConnection alloc] initWithRequest:request delegate:self];
			imageRequestSent = YES;
		}
		//Lookup picture online
		return placeholderImage;
	}
	return picture;
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"Connection Failed: %@",[error description]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[connection release];
	
	self.picture=[UIImage imageWithData:responseData];
	self.responseData=nil;
	
	[[NSNotificationCenter defaultCenter]postNotificationName:@"StaffImageUpdatedNotification" object:self];	
}


@end
