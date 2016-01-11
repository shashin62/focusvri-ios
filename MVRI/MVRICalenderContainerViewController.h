//
//  MVRICalenderContainerViewController.h
//  MVRI
//
//  Created by mac on 11/26/13.
//  Copyright (c) 2013 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MVRICalenderViewController.h"

@interface MVRICalenderContainerViewController : UIViewController
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *sidebarButton;
@property (weak, nonatomic) IBOutlet UILabel *user;

@property (weak, nonatomic) IBOutlet UIButton *btnAddEvent;
//-(IBAction)btnAddEventPressed:(id)sender;


-(IBAction)revelMenuPressed:(id)sender;
@end
