//
//  MVRIAddEventViewController.h
//  MVRI
//
//  Created by Addya on 03/05/14.
//  Copyright (c) 2014 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MVRIAddEventViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>
{
    UIPickerView *pickerView;
    NSMutableArray * pickItems;
    
    UIPickerView *pickerViewInterpreter;
    NSMutableArray * pickItemsInterpreter;
    
    UIPickerView *pickerViewLanguage;
    NSMutableArray * pickItemsLanguage;

    UIPickerView *pickerViewCategory;
    NSMutableArray *pickItemsCategory;
    
    IBOutlet UITextField *txtClientName;
    IBOutlet UITextField *txtInterpreterName;
    IBOutlet UITextField *txtStartDt;
    IBOutlet UITextField *txtEndDt;
    IBOutlet UITextField *txtClaim;
    IBOutlet UITextField *txtLanguage;
    IBOutlet UITextField *txtCategory;
    IBOutlet UIScrollView *scrollView1;
    
    IBOutlet UIBarButtonItem *btnBack;
}

@property (retain, nonatomic) UIPickerView *pickerView;
@property (retain, nonatomic) NSMutableArray *pickItems;
@property (retain, nonatomic) NSMutableArray *pickItemsId;

@property (retain, nonatomic) UIPickerView *pickerViewInterpreter;
@property (retain, nonatomic) NSMutableArray *pickItemsInterpreter;
@property (retain, nonatomic) NSMutableArray *pickItemsIdInterpreter;

@property (retain, nonatomic) UIPickerView *pickerViewLanguage;
@property (retain, nonatomic) NSMutableArray *pickItemsLanguage;
@property (retain, nonatomic) NSMutableArray *pickItemsIdLanguage;


@property (retain, nonatomic) UIPickerView *pickerViewCategory;
@property (retain, nonatomic) NSMutableArray *pickItemsCategory;
@property (retain, nonatomic) NSMutableArray *pickItemsIdCategory;

- (IBAction)btnAppointSubmit:(UIButton *)sender;
//- (IBAction)btnAppointSubmit:(id)sender;

@end
