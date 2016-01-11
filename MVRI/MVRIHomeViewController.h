//
//  MVRIHomeViewController.h
//  MVRI
//
//  Created by mac on 11/18/13.
//  Copyright (c) 2013 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MVRIAppointsViewViewController.h"

@interface MVRIHomeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *sidebarButton;
@property (weak, nonatomic) IBOutlet UIView *clientView;
@property (weak, nonatomic) IBOutlet UILabel *user;
@property (weak, nonatomic) IBOutlet UIButton *getAppointments;
//ib actions
-(IBAction)revelMenuPressed:(id)sender;
-(IBAction)getAppointments:(id)sender;
@end
