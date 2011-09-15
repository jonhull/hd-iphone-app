//
//  EventTableViewCell.m
//  Hacker Dojo
//
//  Created by Jonathan Hull on 11/21/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "EventTableViewCell.h"


@implementation EventTableViewCell
@synthesize title,location,time,detail,isCancelled;

static UIFont *titleTextFont = nil;
static UIFont *smallTitleTextFont = nil;
static UIFont *locationTextFont = nil;
static UIFont *detailTextFont = nil;
static UIFont *dateTextFont = nil;
static NSDateFormatter *dateFormatter = nil;
static UIImage *selectedImage = nil;

+ (void)initialize
{
	if(self == [EventTableViewCell class])
	{
		titleTextFont = [[UIFont boldSystemFontOfSize:16] retain];
        smallTitleTextFont = [[UIFont boldSystemFontOfSize:14] retain];
		locationTextFont = [[UIFont systemFontOfSize:12] retain];//12
		detailTextFont = [[UIFont systemFontOfSize:12] retain];
        dateTextFont = [[UIFont boldSystemFontOfSize:18] retain];
        dateFormatter = [[NSDateFormatter alloc]init];
        selectedImage = [[UIImage imageNamed:@"BlueBackground"] retain];
	}
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [title release];
    [location release];
    [time release];
    [detail release];
    [super dealloc];
}


-(NSString*)timeTextForDate:(NSDate*)aDate
{
    [dateFormatter setDateFormat:@"a"];
    NSString *ampm = [[dateFormatter stringFromDate:aDate]substringToIndex:1];
	[dateFormatter setDateFormat:@"h:mm"];
	return [NSString stringWithFormat:@"%@%@",[dateFormatter stringFromDate:aDate],ampm];
}


#pragma mark Drawing
- (void)drawContentView:(CGRect)r highlighted:(BOOL)isHighlighted
{
	CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *backgroundColor = [UIColor whiteColor];
	UIColor *textColor = [UIColor darkTextColor];//[UIColor blackColor];
    UIColor *timeColor = [UIColor colorWithRed:0.260 green:0.335 blue:0.483 alpha:1.000];
    UIColor *detailColor = [UIColor darkGrayColor];//[UIColor grayColor];
    
    if(isHighlighted){
        textColor = [UIColor whiteColor];
        timeColor = [UIColor whiteColor];
        detailColor = [UIColor whiteColor];
        
        [selectedImage drawAsPatternInRect:r];
    }else{
        [backgroundColor set];
        CGContextFillRect(context, r);
    }
    
    if(isCancelled){
        textColor = [UIColor grayColor];//[UIColor whiteColor];
        timeColor = [UIColor lightGrayColor];//[UIColor whiteColor];
        detailColor = [UIColor lightGrayColor];//[UIColor whiteColor];
    }
    
    
	CGRect rect;
    NSString *tmp;
    
    //Title
    [textColor set];
    rect = CGRectMake(DateCell_TextStart, 6, DateCell_TextWidth, 22);
    [title drawInRect:rect withFont:smallTitleTextFont lineBreakMode:UILineBreakModeTailTruncation];
    
    //Detail
    [detailColor set];
	rect = CGRectMake(DateCell_TextStart, 23, DateCell_TextWidth, 16);
    //rect = CGRectMake(DateCell_TextStart, 22, DateCell_TextWidth, 16);
	tmp = self.detail;
    [tmp drawInRect:rect withFont:detailTextFont lineBreakMode:UILineBreakModeTailTruncation];
    
    [timeColor set];
    
    //Location
    //rect = CGRectMake(DateCell_Buffer, 23, DateCell_DateWidth, 14);
	rect = CGRectMake(DateCell_Buffer, 7, DateCell_DateWidth, 14);//5
	tmp = self.location;
	[tmp drawInRect:rect withFont:locationTextFont lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
    
    //Time
	//rect = CGRectMake(DateCell_Buffer, 4, DateCell_DateWidth, 22);
    rect = CGRectMake(DateCell_Buffer, 19, DateCell_DateWidth, 22);
	tmp = [self timeTextForDate:self.time];
	[tmp drawInRect:rect withFont:dateTextFont lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
    
    
    
    
}


@end
