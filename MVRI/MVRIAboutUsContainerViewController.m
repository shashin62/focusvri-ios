//
//  MVRIAboutUsContainerViewController.m
//  MVRI
//
//  Created by mac on 12/2/13.
//  Copyright (c) 2013 mac. All rights reserved.
//

#import "MVRIAboutUsContainerViewController.h"
#import "SWRevealViewController.h"
#import "ASIFormDataRequest.h"
#import "MVRIGlobalData.h"

@interface MVRIAboutUsContainerViewController ()

@end

@implementation MVRIAboutUsContainerViewController

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
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    //[_user setText:[NSString stringWithFormat:@"Welcome, %@", [MVRIGlobalData sharedInstance].username]];
    //[_user setText:[NSString stringWithFormat:@"Welcome, %@ (%@)", [MVRIGlobalData sharedInstance].Firstname, [MVRIGlobalData sharedInstance].username]];
    
    [_user setText:[NSString stringWithFormat:@"Welcome, %@", [MVRIGlobalData sharedInstance].Firstname]];
    [_lblUsrEmail setText:[NSString stringWithFormat:@" (%@)", [MVRIGlobalData sharedInstance].username]];
    
    //NSString *_urlString = [NSString stringWithFormat:@"http://mobilevri.com/api/vri/GetAboutUs?key=%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
    NSString *_urlString = [NSString stringWithFormat:@"http://login.mobilevri.com/api/vri/GetAboutUs?key=%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
    NSURL *url = [NSURL URLWithString:_urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    [request start];
    NSError *error = [request error];
    if (!error) {
        NSString *response = [request responseString];
//        NSLog(@"aboutUS: %@", response);
        [_abtUs setText:response];
    }else{
        NSLog(@"error fetching AboutUS:%@",[error description]);
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark reveal menu
-(IBAction)revelMenuPressed:(id)sender{
    [self.revealViewController revealToggle:sender];
    
    
}

@end
