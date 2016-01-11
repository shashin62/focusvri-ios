//
//  MVRIFeedbackViewController.h
//  MVRI
//
//  Created by mac on 11/18/13.
//  Copyright (c) 2013 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MVRIFeedbackViewController : UIViewController<UITextViewDelegate>{
    UITextView *activeField;
    CGRect _defaultFrame;
}

@property (weak, nonatomic) IBOutlet UILabel *user;
@property (weak, nonatomic) IBOutlet UITextView *feedback;
@property (weak, nonatomic) IBOutlet UILabel *lblMsg;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

-(IBAction)revelMenuPressed:(id)sender;
-(IBAction)submitFeedbackPressed:(id)sender;
@end
