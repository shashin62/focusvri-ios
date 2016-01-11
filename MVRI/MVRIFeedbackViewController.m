//
//  MVRIFeedbackViewController.m
//  MVRI
//
//  Created by mac on 11/18/13.
//  Copyright (c) 2013 mac. All rights reserved.
//

#import "MVRIFeedbackViewController.h"
#import "SWRevealViewController.h"
#import "MVRIGlobalData.h"
#import "ASIFormDataRequest.h"

@interface MVRIFeedbackViewController ()

@end

@implementation MVRIFeedbackViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    //[_user setText:[NSString stringWithFormat:@"Welcome, %@", [MVRIGlobalData sharedInstance].username]];
    //[_user setText:[NSString stringWithFormat:@"Welcome, %@ (%@)", [MVRIGlobalData sharedInstance].Firstname, [MVRIGlobalData sharedInstance].username]];
    [_user setText:[NSString stringWithFormat:@"Welcome, %@", [MVRIGlobalData sharedInstance].Firstname]];

    CALayer *btnLayer = [_submitButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    CALayer *fdblayer = [_feedback layer];
    [fdblayer setMasksToBounds:YES];
    [fdblayer setCornerRadius:5.0f];
    _lblMsg.hidden=YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)revelMenuPressed:(id)sender{
    [self.revealViewController revealToggle:sender];
    
    
}

#pragma - mark uitextfield delegate methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    activeField = textView;
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    activeField = nil;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
//    [textView resignFirstResponder];
    return YES;
}

- (BOOL)textView:(UITextView *)txtView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if( [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound ) {
        return YES;
    }
    
    [txtView resignFirstResponder];
    return NO;
}

-(IBAction)submitFeedbackPressed:(id)sender{
    if(_feedback.text && _feedback.text.length>0)
    {
    NSString *_urlString = [NSString stringWithFormat:@"http://login.mobilevri.com/api/vri/SaveFeedback?key=%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
    //NSString *_urlString = [NSString stringWithFormat:@"http://mobilevri.com/api/vri/SaveFeedback?key=%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
    NSURL *url = [NSURL URLWithString:_urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:_feedback.text forKey:@"feedback"];
    [request start];
    NSError *error = [request error];
    if (!error) {
        NSString *response = [request responseString];
        NSLog(@"all appointments: %@", response);
    }else{
        NSLog(@"error submitting feedback:%@",[error description]);
    }
    _lblMsg.hidden=NO;
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Please enter text"
                                                       delegate:sender cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    }
}

@end
