//
//  StaffList.m
//  Hacker Dojo Test
//
//  Created by Jonathan Hull on 12/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "StaffList.h"
#import "JSON.h"

@implementation StaffList
@synthesize currentStaff;
@synthesize url;
@synthesize responseData;
@synthesize currentConnection;

-(void)dealloc
{
	[currentStaff release];
	[url release];
	[super dealloc];
}

-(id)init
{
	if(self=[super init]){
		checkingNow = NO;
		self.url = [NSURL URLWithString:jsonURL];
		//[self makeFakeArray];
		//[self fetch];
	}
	return self;
}

-(void)makeFakeArray
{
	Staff *fakeStaff = [[[Staff alloc]init]autorelease];
	fakeStaff.name = @"Mellisalynn Perkins";
	fakeStaff.email = @"email@domain.com";
	fakeStaff.loginTime = [NSDate date];
	fakeStaff.keyholder = NO;
	
	NSString *path=[[NSBundle mainBundle]pathForResource:@"melissa" ofType:@"jpg"];
	fakeStaff.picture = [[[UIImage alloc] initWithContentsOfFile:path] autorelease];
	
	Staff *otherStaff = [[[Staff alloc]init]autorelease];
	otherStaff.name = @"Jeff Lindsay";
	otherStaff.email = @"email@domain.com";
	otherStaff.loginTime = [NSDate date];
	otherStaff.keyholder = YES;
	
	NSString *otherPath=[[NSBundle mainBundle]pathForResource:@"jeff" ofType:@"jpeg"];
	otherStaff.picture = [[[UIImage alloc] initWithContentsOfFile:otherPath] autorelease];
	
	
	Staff *thirdStaff = [[[Staff alloc]init]autorelease];
	thirdStaff.name = @"Joe Biden";
	thirdStaff.email = @"email@domain.com";
	thirdStaff.loginTime = [NSDate date];
	thirdStaff.keyholder = NO;
	
	
	
	NSArray *fakeArray = [NSArray arrayWithObjects:fakeStaff,otherStaff,thirdStaff,nil];
	self.currentStaff = fakeArray;
}

-(Staff*)staffWithEmail:(NSString*)emailStr
{
	for(Staff *member in self.currentStaff){
		if ([emailStr isEqualToString:member.email]) 
			return member;
	}
	return nil;
}

-(void)fetch
{
	NSLog(@"Fetch Called");
	if (!checkingNow) {
		checkingNow = YES;
		self.responseData = [NSMutableData data];
		NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
		self.currentConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	if ([connection isEqual:currentConnection]) {
		[responseData appendData:data];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"Connection Failed: %@",[error description]);
	checkingNow = NO;
	[[NSNotificationCenter defaultCenter]postNotificationName:@"StaffNetworkFailureNotification" object:self];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (![connection isEqual:currentConnection])
		return;

	[connection release];
	
	NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	self.responseData=nil;

	NSLog(@"Response:%@",responseString);
	
	NSError *error;
	SBJSON *json = [[SBJSON new] autorelease];
	NSArray *memberArray = [json objectWithString:responseString error:&error];
	[responseString release];
	
	if(memberArray == nil){
		
	}
	NSLog(@"Decoded:%@",memberArray);
	
	NSArray *staffArray =[NSArray array];
	for(NSDictionary *dict in memberArray){
		Staff *staffmember = [[[Staff alloc]init]autorelease];
		staffmember.name = [[dict valueForKey:@"name"]capitalizedString];
		staffmember.email = [dict valueForKey:@"email"];
		
		Staff *oldStaff=[self staffWithEmail:staffmember.email];
		if (oldStaff) {//If already in list
			staffArray = [staffArray arrayByAddingObject:oldStaff];//Add the already instantiated one so we don't have to download the image again
			continue;// then move on to the next staffmember
		}
		staffmember.imageURL = [dict valueForKey:@"image_url"];
		staffmember.keyholder = [[dict valueForKey:@"type"]isEqualToString:@"StaffKey"];
		
		NSDateFormatter *formatter = [[[NSDateFormatter alloc]init]autorelease];
		[formatter setDateFormat:@"MM-dd-yyyy HH:mm:ss"];
		
		NSDate *rawlogin = [formatter dateFromString:[dict valueForKey:@"created"]];
		NSDate *refTime = [formatter dateFromString:[dict valueForKey:@"refTime"]];//Server time was off so we have to adjust
		NSTimeInterval timeDiff = [[NSDate date]timeIntervalSinceDate:refTime];
		staffmember.loginTime = [rawlogin dateByAddingTimeInterval:timeDiff];
		
		staffArray = [staffArray arrayByAddingObject:staffmember];
	}
	checkingNow = NO;
	
	if (![staffArray isEqual:self.currentStaff]) {
		self.currentStaff = staffArray;
	
		[[NSNotificationCenter defaultCenter]postNotificationName:@"StaffListUpdatedNotification" object:nil];
	}
	
}



@end
