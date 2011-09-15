//
//  JONListViewController.h
//  JONListViewController Example
//
//  Created by Jonathan Hull on 11/24/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JONListItem;

typedef void (^JONListItemBlock)(JONListItem *item);
typedef void (^JONListSectionBlock)(NSArray* list, NSInteger selection);
typedef UITableViewCell* (^JONListCellBlock)(id item, BOOL isSelected);

/*
 JONListItem - 
 */
@interface JONListItem : NSObject {
    UIImage *image;
    NSString *title;
    JONListItemBlock selectionBlock;
}
@property (retain, nonatomic) UIImage *image;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) JONListItemBlock selectionBlock;//itemBlock;

-(id)initWithTitle:(NSString*)aTitle image:(UIImage*)anImage block:(JONListItemBlock)aSelectionBlock;
-(id)initWithTitle:(NSString *)aTitle image:(UIImage*)anImage;

@end

/*
 JONListSection -
 */
@interface JONListSection : NSObject {
    NSString *title;
    NSArray *items;//Holds a mixture of NSStrings and JONListItems
    JONListSectionBlock sectionBlock;
    NSMutableDictionary *titlePaths;
    NSMutableDictionary *imagePaths;
    JONListCellBlock cellBlock;
}
@property (copy,nonatomic) NSString *title;
@property (retain,nonatomic) NSArray *items;
@property (copy, nonatomic) JONListSectionBlock selectionBlock;
@property (copy, nonatomic) JONListCellBlock cellBlock;

-(id)initWithTitle:(NSString*)aTitle list:(NSArray*)itemList block:(JONListSectionBlock)aBlock;
-(id)initWithList:(NSArray*)itemList block:(JONListSectionBlock)aBlock;

-(NSUInteger)count;
-(NSString*)titleForItem:(id)item;
-(NSString*)titleForItemAtIndex:(NSUInteger)index;
-(UIImage*)imageForItem:(id)item;
-(UIImage*)imageForItemAtIndex:(NSUInteger)index;

-(NSInteger)indexForItemWithTitle:(NSString*)aTitle;

-(void)setTitlePath:(NSString*)aPath forClass:(Class)aClass;
-(NSString*)titlePathForClass:(Class)aClass;
-(void)setImagePath:(NSString*)aPath forClass:(Class)aClass;//***Needs Imp
-(NSString*)imagePathForClass:(Class)aClass;//***Needs Imp

@end


/*
 JONListViewController
 */
@interface JONListViewController : UITableViewController {
    NSMutableArray *sections;
    NSString *title;
    NSIndexPath *startingSelection;
    JONListCellBlock cellBlock;
}
@property (copy,nonatomic) NSString *title;
@property (retain,nonatomic) NSIndexPath *startingSelection;
@property (copy,nonatomic) JONListCellBlock cellBlock;

-(id)initWithStyle:(UITableViewStyle)style; //(designated initializer)
-(id)initWithList:(NSArray*)listItems selection:(NSInteger)selection block:(JONListSectionBlock)aBlock;
-(id)initWithList:(NSArray*)listItems block:(JONListSectionBlock)aBlock;//Simplest - inits as plain style with single section

-(NSInteger)addSection:(JONListSection*)aSection;
-(NSInteger)addSectionWithTitle:(NSString*)aTitle list:(NSArray*)listItems block:(JONListSectionBlock)aBlock;
-(NSInteger)addSection:(JONListSection*)aSection withSelection:(NSInteger)selection;
-(JONListSection*)sectionForSectionId:(NSInteger)index;
-(JONListSection*)lastSection;

-(void)setSelection:(NSInteger)selection inSectionWithId:(NSInteger)sectionId;
-(void)setSelectionInLastSection:(NSInteger)selection;
-(void)setSelectionToItemWithTitle:(NSString*)itemTitle;

@end

