//
//  MVRIClientHomeScreenViewController.m
//  MVRI
//
//  Created by Murali Gorantla on 05/08/15.
//  Copyright (c) 2015 mac. All rights reserved.
//

#import "MVRIClientHomeScreenViewController.h"
#import "SBPickerSelector.h"
#import "MVRIGlobalData.h"
#import "SWRevealViewController.h"

@interface MVRIClientHomeScreenViewController () <SBPickerSelectorDelegate> {
    NSArray *languages;
    NSArray *skills;
    NSArray *genderTypes;
}

@end

@implementation MVRIClientHomeScreenViewController

@synthesize types;

- (NSDateFormatter *)formatter {
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/YYYY"];
        NSTimeZone *utc = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        [formatter setTimeZone:utc];
    });
    return formatter;
}

#pragma mark - Server Calls

- (void)requestForListOfLanguages {
   // NSString *_urlString = [NSString stringWithFormat:@"http://login.mobilevri.com/api/vri/GetLanguages?key=%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
    NSString *_urlString = [NSString stringWithFormat:@"http://qa.focusvri.com/api/GetLanguages?"];
    NSURL *url = [NSURL URLWithString:_urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:@"Token" value:[[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
    request.userInfo = [NSDictionary dictionaryWithObject:@"GetLanguages" forKey:@"type"];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)requestForListOfSkills {
    NSString *_urlString = [NSString stringWithFormat:@"http://qa.focusvri.com/api/GetInterpreterTypes?"];
    NSURL *url = [NSURL URLWithString:_urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:@"Token" value:[[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
    request.userInfo = [NSDictionary dictionaryWithObject:@"GetInterpreterTypes" forKey:@"type"];
    [request setDelegate:self];
    [request startAsynchronous];
//    [request start];
//    NSError *error = [request error];
//    if (!error) {
//        NSString *response = [request responseString];
//        NSLog(@"buffer time: %@", response);
//        NSData *responseData = [response dataUsingEncoding:NSUTF8StringEncoding];
//        skills = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
//    }

}

- (void)requestForSaveSearchCriteria {
    
    NSString *_urlString = [NSString stringWithFormat:@"http://qa.focusvri.com/api/SaveSeachCriteria?"];
    NSURL *url = [NSURL URLWithString:_urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Token" value:[[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    NSString *dateString = [[self formatter] stringFromDate:[NSDate date]];
    NSInteger interPreterId = [[MVRIGlobalData sharedInstance].skillDictionary[@"ID"] integerValue];
    NSInteger languageID = [[MVRIGlobalData sharedInstance].languageDictionary[@"ID"] integerValue];
    NSDictionary *jsonDictionary = @{
                                     @"ContactID" : [MVRIGlobalData sharedInstance].userID,
                                     
                                     @"Date" : dateString,
                                     
                                     @"InterpreterTypeID" : @(interPreterId),
                                     
                                     @"Gender" : [MVRIGlobalData sharedInstance].genderType,
                                     
                                     @"LanguageID":@(languageID)
                                     };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    
    [request appendPostData:jsonData];
    request.userInfo = [NSDictionary dictionaryWithObject:@"SaveSeachCriteria" forKey:@"type"];
    [request setDelegate:self];
    [request startAsynchronous];
    
//    [request start];
//    NSError *error = [request error];
//    if (!error) {
//        NSString *response = [request responseString];
//        NSLog(@"response: %@", response);
//        [self performSegueWithIdentifier:@"allInterPreters" sender:self];
//    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSData *responseData = [request responseData];
    if ([[request.userInfo objectForKey:@"type"] isEqualToString:@"GetInterpreterTypes"]) {
        skills = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
    } else if ([[request.userInfo objectForKey:@"type"] isEqualToString:@"GetLanguages"]) {
        languages = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
    } else if ([[request.userInfo objectForKey:@"type"] isEqualToString:@"SaveSeachCriteria"]) {
        NSLog(@"response: %@", [request responseString]);
    }
}
#pragma mark - Life Cycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Set the gesture
    self.title = @"Interpreter Search";
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    self.view.backgroundColor = [UIColor FVRIWhileColor];
    //self.navigationController.navigationBarHidden = YES;
    //self.view.backgroundColor = [UIColor colorWithRed:0.84 green:0.84 blue:0.84 alpha:1.0];
    genderTypes = @[@{@"Value":@"Male"},
                    @{@"Value":@"Female"}];
//    self.searchButton.layer.cornerRadius = 10.0f;
//    self.searchButton.layer.masksToBounds = YES;
//    self.searchButton.layer.borderWidth = 2.0f;
//    self.searchButton.clipsToBounds = YES;
//    //self.layer.borderColor = [[UIColor colorWithRed:83.0f/255.0f green:152.0f/255.0f blue:232.0f/255.0f alpha:1.0f] CGColor];
//    self.searchButton.layer.borderColor = [[UIColor blackColor] CGColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //self.navigationController.navigationBarHidden = YES;
    [self requestForListOfLanguages];
    [self requestForListOfSkills];
//    UIImage *img = [UIImage imageNamed:@"titleView"];
//    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 30)];
//    [imgView setImage:img];
//    [imgView setContentMode:UIViewContentModeScaleAspectFit];
//    self.navigationItem.titleView = imgView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Picker Delegates

- (void)pickerSelector:(SBPickerSelector *)selector selectedValue:(NSString *)value index:(NSInteger)idx
{
    if (self.types == MVRILanguages) {
        self.languageTextField.text = value;
        [MVRIGlobalData sharedInstance].languageDictionary = languages[idx];
    } else if (self.types == MVRISkills) {
        self.skillTextField.text = value;
        [MVRIGlobalData sharedInstance].skillDictionary = skills[idx];
    } else {
        self.genderTextField.text = value;
        [MVRIGlobalData sharedInstance].genderType = [value substringToIndex:1];
    }
}

- (void) pickerSelector:(SBPickerSelector *)selector cancelPicker:(BOOL)cancel {
    NSLog(@"press cancel");
}

- (void)pickerSelector:(SBPickerSelector *)selector intermediatelySelectedValue:(id)value atIndex:(NSInteger)idx {
    if ([value isMemberOfClass:[NSDate class]]) {
        [self pickerSelector:selector dateSelected:value];
    }else{
        [self pickerSelector:selector selectedValue:value index:idx];
    }
}

#pragma mark - Validation

- (void)showAlertWithMessage:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Validation Error" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark - IBActions

- (IBAction)performSearchButtonAction:(id)sender {
    if (self.languageTextField.text.length == 0) {
        [self showAlertWithMessage:@"Please select language"];
        return;
        
    } else if (self.skillTextField.text.length == 0) {
        [self showAlertWithMessage:@"Please select skill"];
        return;
    } else if (self.genderTextField.text.length == 0) {
       [self showAlertWithMessage:@"Please select gender"];
        return;
    }
    [self requestForSaveSearchCriteria];
    [self performSegueWithIdentifier:@"allInterPreters" sender:self];
}

- (void)showPicker:(UITextField *)sender {
    SBPickerSelector *picker = [SBPickerSelector picker];
    picker.delegate = self;
    picker.pickerType = SBPickerSelectorTypeText;
    picker.doneButtonTitle = @"Done";
    picker.cancelButtonTitle = @"Cancel";
    if (sender == self.languageTextField) {
        picker.pickerData = [languages mutableCopy];
        self.types = MVRILanguages;
    } else if (sender == self.skillTextField) {
        picker.pickerData = [skills mutableCopy];
        self.types = MVRISkills;
    } else {
        picker.pickerData = [genderTypes mutableCopy];
        self.types = MVRISex;
    }
    CGPoint point = [self.view convertPoint:[sender frame].origin fromView:[sender superview]];
    CGRect frame = [sender frame];
    frame.origin = point;
    [picker showPickerIpadFromRect:frame inView:self.view];
}

- (IBAction)menuButtonAction:(id)sender {
    [self.revealViewController revealToggle:sender];
}

#pragma mark - TextField Delegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self showPicker:textField];
    return NO;  // Hide both keyboard and blinking cursor.
}

//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
//    return YES;
//}

@end
