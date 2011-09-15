//
//  EventTableViewCell.h
//  Hacker Dojo
//
//  Created by Jonathan Hull on 11/21/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABTableViewCell.h"

#define DateCell_Buffer 10
//#define DateCell_Buffer 16
//#define DateCell_DateWidth 54
#define DateCell_DateWidth 64
#define DateCell_Space 7
//#define DateCell_Space 8
#define DateCell_TextStart (DateCell_Buffer+DateCell_DateWidth+DateCell_Space)
#define DateCell_Width 320
#define DateCell_TextHeight 20
#define DateCell_TextWidth (320 - DateCell_TextStart - DateCell_Buffer)
//#define DateCell_TextWidth 215


@interface EventTableViewCell : ABTableViewCell {
    NSString *title;
    NSString *location;
    NSDate *time;
    NSString *detail;
    BOOL isCancelled;
}
@property (copy,nonatomic) NSString *title;
@property (copy,nonatomic) NSString *location;
@property (retain,nonatomic) NSDate *time;
@property (copy,nonatomic) NSString *detail;
@property (assign,nonatomic) BOOL isCancelled;

@end
