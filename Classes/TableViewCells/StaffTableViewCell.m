//
//  StaffTableViewCell.m
//  Hacker Dojo Test
//
//  Created by Jonathan Hull on 12/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "StaffTableViewCell.h"


@implementation StaffTableViewCell
@synthesize name;
@synthesize email;
@synthesize time;
@synthesize picture;
@synthesize keyholder;


static UIFont *nameTextFont = nil;
static UIFont *emailTextFont = nil;
//static UIImage *keyImage = nil;
//static UIImage *noKeyImage = nil;
static UIImage *roundedImage = nil;

+ (void)initialize
{
	if(self == [StaffTableViewCell class])
	{
		nameTextFont = [[UIFont boldSystemFontOfSize:20] retain];
		emailTextFont = [[UIFont systemFontOfSize:17] retain];

		NSString *path=[[NSBundle mainBundle]pathForResource:@"crop3" ofType:@"png"];
		roundedImage = [[UIImage alloc] initWithContentsOfFile:path];

		// this is a good spot to load any graphics you might be drawing in -drawContentView:
		// just load them and retain them here (ONLY if they're small enough that you don't care about them wasting memory)
		// the idea is to do as LITTLE work (e.g. allocations) in -drawContentView: as possible
	}
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		self.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    return self;
}


/*
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
*/


- (void)dealloc {
	[name release];
	[email release];
	[time release];
	[picture release];
    [super dealloc];
}

#pragma mark accessors

-(void)setName:(NSString *)newName
{
	if (name != newName) {
		[name release];
		name = [newName copy];
		[self setNeedsDisplay];
	}
}

-(void)setEmail:(NSString *)newEmail
{
	if (email != newEmail) {
		[email release];
		email = [newEmail copy];
		[self setNeedsDisplay];
	}
}

-(void)setTime:(NSString *)newTime
{
	if (time != newTime) {
		[time release];
		time = [newTime copy];
		[self setNeedsDisplay];
	}
}

-(void)setPicture:(UIImage *)newPicture
{
	if (picture != newPicture) {
		[picture release];
		picture = [newPicture retain];
		[self setNeedsDisplay];
	}
}

#pragma mark Drawing
- (void)drawContentView:(CGRect)r highlighted:(BOOL)isHighlighted
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	UIColor *backgroundColor = [UIColor whiteColor];
	UIColor *textColor = [UIColor blackColor];
	
	[backgroundColor set];
	CGContextFillRect(context, r);
	
	CGRect rect = CGRectMake(StaffCell_Buffer, StaffCell_Buffer, StaffCell_PictSize, StaffCell_PictSize);
	[[self picture] drawInRect:rect];
	[roundedImage drawInRect:rect];
	
	[textColor set];
	rect = CGRectMake(StaffCell_TextStart, StaffCell_Buffer-3, StaffCell_TextWidth, StaffCell_TextHeight);
	[name drawInRect:rect withFont:nameTextFont lineBreakMode:UILineBreakModeTailTruncation];
	
	rect = CGRectMake(StaffCell_TextStart, StaffCell_Buffer+StaffCell_TextHeight-3, StaffCell_TextWidth, StaffCell_TextHeight);
	[email drawInRect:rect withFont:emailTextFont lineBreakMode:UILineBreakModeTailTruncation];

	[[UIColor grayColor]set];
	//rect = CGRectMake(StaffCell_TextStart + 15, StaffCell_Height - StaffCell_TextHeight-5, StaffCell_TextWidth, StaffCell_TextHeight);
    rect = CGRectMake(StaffCell_TextStart, StaffCell_Height - StaffCell_TextHeight-5, StaffCell_TextWidth, StaffCell_TextHeight);

	[time drawInRect:rect withFont:emailTextFont lineBreakMode:UILineBreakModeTailTruncation];
}

@end
