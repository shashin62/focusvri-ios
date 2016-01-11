//
//  MVRIAboutUsContainerViewController.h
//  MVRI
//
//  Created by mac on 12/2/13.
//  Copyright (c) 2013 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MVRIAboutUsContainerViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *user;
@property (weak, nonatomic) IBOutlet UITextView *abtUs;
@property (weak, nonatomic) IBOutlet UILabel *lblUsrEmail;

-(IBAction)revelMenuPressed:(id)sender;

@end
