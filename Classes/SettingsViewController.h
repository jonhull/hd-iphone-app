//
//  SettingsViewController.h
//  Hacker Dojo
//
//  Created by Jonathan Hull on 11/18/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SettingsViewControllerDismissedCancel 0
#define SettingsViewControllerDismissedDone 1

@class SettingsViewController;
@protocol settingsViewControllerDelegate <NSObject>
-(void)settingsViewController:(SettingsViewController*)contoller wasDismissed:(NSUInteger)dismissalType;
@end

@interface SettingsViewController : UIViewController {
    IBOutlet UITextField *emailField;
    id<settingsViewControllerDelegate> delegate;
}

@property (retain,nonatomic) UITextField *emailField;
@property (assign,nonatomic) id<settingsViewControllerDelegate> delegate;

-(IBAction)cancelHit:(id)sender;
-(IBAction)doneHit:(id)sender;



@end
