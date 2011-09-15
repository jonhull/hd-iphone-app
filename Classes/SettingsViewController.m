//
//  SettingsViewController.m
//  Hacker Dojo
//
//  Created by Jonathan Hull on 11/18/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"


@implementation SettingsViewController
@synthesize emailField;
@synthesize delegate;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor viewFlipsideBackgroundColor]];
    
    NSUserDefaults *prefs=[NSUserDefaults standardUserDefaults];
    emailField.text = [prefs stringForKey:@"loginEmail"];
    
    [emailField becomeFirstResponder];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark TextField
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[self doneHit:self]; 
	return YES;
}

#pragma mark Actions
-(IBAction)cancelHit:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
    [self.delegate settingsViewController:self wasDismissed:SettingsViewControllerDismissedCancel];
}

-(IBAction)doneHit:(id)sender
{
    NSUserDefaults *prefs=[NSUserDefaults standardUserDefaults];
	[prefs setObject:emailField.text forKey:@"loginEmail"];
    
    [self dismissModalViewControllerAnimated:YES];
    [self.delegate settingsViewController:self wasDismissed:SettingsViewControllerDismissedDone];
}


@end
