//
//  MVRIViewController.m
//  MVRI
//
//  Created by mac on 11/9/13.
//  Copyright (c) 2013 mac. All rights reserved.
//

#import "MVRIViewController.h"
#import "ASIFormDataRequest.h"
#import "MVRIoovooMainviewController.h"
#import "MVRIGlobalData.h"
#import <QuartzCore/QuartzCore.h>
#import "MVRIInterPreterViewController.h"

@interface MVRIViewController ()

@end

@implementation MVRIViewController
//synthesize all properties
@synthesize username = _username;
@synthesize password = _password;
@synthesize rememberMe = _rememberMe;
@synthesize wrongID_Pass = _wrongID_Pass;
@synthesize scrollView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor FVRIWhileColor];

    [self registerForKeyboardNotifications];
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"MVRIUsername"] != nil) {
        _username.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"MVRIUsername"];
        _password.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"MVRIPassword"];
        CALayer *btnLayer = [_loginButton layer];
        [btnLayer setMasksToBounds:YES];
        [btnLayer setCornerRadius:5.0f];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark ibaction metods
-(IBAction) loginPressed:(id)sender{
    //NSURL *url = [NSURL URLWithString:@"http://mobilevri.com/api/vri?key=login"];
   /* NSURL *url = [NSURL URLWithString:@"http://login.mobilevri.com/api/vri?key=login"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:_username.text forKey:@"uid"];
    [request setPostValue:_password.text forKey:@"pwd"];
    [request setDelegate:self];
    [request startAsynchronous];
    _wrongID_Pass.hidden = YES;*/
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSURL *url = [NSURL URLWithString:@"http://qa.focusvri.com/api/Login?"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    request.userInfo = [NSDictionary dictionaryWithObject:@"login" forKey:@"type"];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    NSDictionary *jsonDictionary = @{
                                     @"UserName" :  _username.text,
                                     @"Password" : _password.text
                                     };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary
                   options:NSJSONWritingPrettyPrinted
                     error:nil];
    
    [request appendPostData:jsonData];
    [request setDelegate:self];
    [request startAsynchronous];
    _wrongID_Pass.hidden = YES;
        
}

- (void)requestForChangeAvailabilityWithStatusId:(NSInteger)statusID {
    NSString *_urlString = [NSString stringWithFormat:@"http://qa.focusvri.com/api/ChangeAvailability?"];
    NSURL *url = [NSURL URLWithString:_urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Token" value:[[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    NSDictionary *jsonDictionary = @{
                                     @"ContactId": [MVRIGlobalData sharedInstance].userID,
                                     @"AvailibilityStatusId": @(statusID),
                                     };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    
    [request appendPostData:jsonData];
    [request setDelegate:self];
    [request startAsynchronous];
}


#pragma - mark asihttp delegate methods
- (void)requestFinished:(ASIHTTPRequest *)request
{
    // fetch key
    //NSString *responseString = [[request responseHeaders] objectForKey:@"key"];
    NSString *response = [request responseString];
    NSData *responseData = [response dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
    if ([[request.userInfo objectForKey:@"type"] isEqualToString:@"login"]) {
        NSString *responseString = responseDictionary[@"TokenString"];
        if (responseString != NULL) {
            _wrongID_Pass.hidden = YES;
            NSLog(@"Login Successful, key : %@", responseString);
            [MVRIGlobalData sharedInstance].userID = responseDictionary[@"UserId"];
            [MVRIGlobalData sharedInstance].username = _username.text;
            if ([_rememberMe isOn]) {
                [[NSUserDefaults standardUserDefaults] setValue:_username.text forKey:@"MVRIUsername"];
                [[NSUserDefaults standardUserDefaults] setValue:_password.text forKey:@"MVRIPassword"];
            }else{
                [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"MVRIUsername"];
                [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"MVRIPassword"];
            }
            [[NSUserDefaults standardUserDefaults] setValue:responseString forKey:@"MVRISessionID"];
            [self requestForContactDetails];
            
            //[self performSegueWithIdentifier:@"SuccessfulLogin" sender:self];
            //[self performSegueWithIdentifier:@"clientHomeScreen" sender:self];
          /*  if ([responseDictionary[@"UserId"]  isEqual: @2]) {
                [self performSegueWithIdentifier:@"clientHomeScreen" sender:self];
            }
            else {
                [self performSegueWithIdentifier:@"interpreterLogin" sender:self];
            }
           
           */
            
            //        [self.navigationController pushViewController:[[MVRIoovooMainviewController alloc] initWithStyle:UITableViewStyleGrouped] animated:YES];
        }else {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            _wrongID_Pass.hidden = NO;
        }

    } else if ([[request.userInfo objectForKey:@"type"] isEqualToString:@"contactDetails"]) {
        [MVRIGlobalData sharedInstance].Firstname = responseDictionary[@"FirstName"];
        [MVRIGlobalData sharedInstance].UsrRole = responseDictionary[@"ContactType"];
        if ([responseDictionary[@"ContactType"]  isEqual: @4]) {
            [MVRIGlobalData sharedInstance].conferenceID = [NSString stringWithFormat:@"%@",responseDictionary[@"ContactID"]];
            [self performSegueWithIdentifier:@"clientHomeScreen" sender:self];
        }
        else if ([responseDictionary[@"ContactType"]  isEqual: @3] || [responseDictionary[@"ContactType"]  isEqual: @1]){
            [self requestForChangeAvailabilityWithStatusId:kAVAILABLE];
            [self performSegueWithIdentifier:@"interpreterLogin" sender:self];
        }
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    } else {
        NSLog(@"reponse = %@",[request responseString]);
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSError *error = [request error];
    NSLog(@"login failed:%@", [error description]);
    [[[UIAlertView alloc]initWithTitle:@"Failure" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
}

- (void)requestForContactDetails {
    NSString *_urlString = [NSString stringWithFormat:@"http://qa.focusvri.com/api/GetContactDetails/%@",[MVRIGlobalData sharedInstance].userID];
    NSURL *url = [NSURL URLWithString:_urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    request.userInfo = [NSDictionary dictionaryWithObject:@"contactDetails" forKey:@"type"];
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:@"Token" value:[[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
    //[request start];
    [request setDelegate:self];
    [request startAsynchronous];
    
//    NSError *error = [request error];
//    if (!error) {
//        NSString *response = [request responseString];
//        NSData *responseData = [response dataUsingEncoding:NSUTF8StringEncoding];
//        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
//        [MVRIGlobalData sharedInstance].Firstname = dictionary[@"FirstName"];
//        [MVRIGlobalData sharedInstance].UsrRole = dictionary[@"ContactType"];
//    }

}

#pragma - mark keyboard notifications
// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
}

#pragma - mark keyboard delegate methods
// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWillShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:activeField.frame animated:YES];
    }
    
}


- (void)keyboardWasShown:(NSNotification*)aNotification
{
//    NSDictionary* info = [aNotification userInfo];
//    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    
//    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
//    scrollView.contentInset = contentInsets;
//    scrollView.scrollIndicatorInsets = contentInsets;
//    
//    // If active text field is hidden by keyboard, scroll it so it's visible
//    // Your app might not need or want this behavior.
//    CGRect aRect = self.view.frame;
//    aRect.size.height -= kbSize.height;
//    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
//        [self.scrollView scrollRectToVisible:activeField.frame animated:YES];
//    }

}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

#pragma - mark uitextfield delegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    activeField = textField;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
