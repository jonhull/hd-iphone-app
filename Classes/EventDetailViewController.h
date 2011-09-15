//
//  EventDetailViewController.h
//  Hacker Dojo
//
//  Created by Jonathan Hull on 11/22/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Event;

@interface EventDetailViewController : UIViewController <UITableViewDelegate,UITableViewDataSource> {
    Event *event;
    IBOutlet UILabel *titleView;
    IBOutlet UILabel *lengthView;
    
    UITableView *detailTable;
}
@property (retain,nonatomic) Event *event;
@property (retain,nonatomic) UITableView *detailTable;
@property (retain,nonatomic) UILabel *titleView;
@property (retain,nonatomic) UILabel *lengthView;

-(BOOL)isHosting;

@end
