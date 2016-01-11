//
//  MVRIViewController.h
//  MVRI
//
//  Created by mac on 11/9/13.
//  Copyright (c) 2013 mac. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MVRIViewController : UIViewController <UITextFieldDelegate>{
    UITextField *activeField;
    CGRect _defaultFrame;
}


@property (nonatomic, strong) IBOutlet UITextField *username;
@property (nonatomic, strong) IBOutlet UITextField *password;
@property (nonatomic, strong) IBOutlet UISwitch *rememberMe;
@property (nonatomic, strong) IBOutlet UILabel *wrongID_Pass;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIButton *loginButton;

-(IBAction) loginPressed:(id)sender;

@end
