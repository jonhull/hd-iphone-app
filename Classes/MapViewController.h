//
//  MapViewController.h
//  Hacker Dojo
//
//  Created by Jonathan Hull on 12/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MapViewController : UIViewController {
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIImageView *imageView;
}
@property (retain,nonatomic) UIScrollView *scrollView;
@property (retain,nonatomic) UIImageView *imageView;

@end
