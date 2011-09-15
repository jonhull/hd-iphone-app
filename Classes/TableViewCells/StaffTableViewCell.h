//
//  StaffTableViewCell.h
//  Hacker Dojo Test
//
//  Created by Jonathan Hull on 12/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABTableViewCell.h"

#define StaffCell_Buffer 10
//#define StaffCell_Buffer 16
#define StaffCell_PictSize 64
#define StaffCell_Space 8
#define StaffCell_TextStart (StaffCell_Buffer+StaffCell_PictSize+StaffCell_Space)
#define StaffCell_Leading 0
#define StaffCell_Width 320
#define StaffCell_TextHeight 20
#define StaffCell_TextWidth (StaffCell_Width - (StaffCell_TextStart + StaffCell_Buffer))
#define StaffCell_Height StaffCell_Buffer + StaffCell_PictSize



@interface StaffTableViewCell : ABTableViewCell {
	NSString *name;
	NSString *email;
	NSString *time;
	UIImage *picture;
	BOOL keyholder;
}
@property (copy,nonatomic) NSString *name;
@property (copy,nonatomic) NSString *email;
@property (copy,nonatomic) NSString *time;
@property (copy,nonatomic) UIImage *picture;
@property (assign,nonatomic) BOOL keyholder;


@end
