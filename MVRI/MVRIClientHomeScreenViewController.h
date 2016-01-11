//
//  MVRIClientHomeScreenViewController.h
//  MVRI
//
//  Created by Murali Gorantla on 05/08/15.
//  Copyright (c) 2015 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MVRISearchTypes) {
    MVRILanguages = 0,
    MVRISkills,
    MVRISex,
};

@interface MVRIClientHomeScreenViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, assign) MVRISearchTypes types;

@property (weak, nonatomic) IBOutlet UITextField *languageTextField;
@property (weak, nonatomic) IBOutlet UITextField *skillTextField;
@property (weak, nonatomic) IBOutlet UITextField *genderTextField;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@property (nonatomic, strong) NSDateFormatter *formatter;
- (IBAction)performSearchButtonAction:(id)sender;
- (IBAction)showPicker:(id)sender;

- (IBAction)menuButtonAction:(id)sender;

@end
