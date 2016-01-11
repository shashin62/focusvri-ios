//
//  MVRICalenderContainerViewController.m
//  MVRI
//
//  Created by mac on 11/26/13.
//  Copyright (c) 2013 mac. All rights reserved.
//

#import "MVRICalenderContainerViewController.h"
#import "SWRevealViewController.h"
#import "MVRIGlobalData.h"

@interface MVRICalenderContainerViewController ()

@end

@implementation MVRICalenderContainerViewController

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
//    MVRICalenderViewController *_cv = [[_containerView subviews] objectAtIndex:0];
    // Set the gesture
    //[_user setText:[NSString stringWithFormat:@"Welcome, %@", [MVRIGlobalData sharedInstance].username]];
    //[_user setText:[NSString stringWithFormat:@"Welcome, %@ (%@)", [MVRIGlobalData sharedInstance].Firstname, [MVRIGlobalData sharedInstance].username]];
    [_user setText:[NSString stringWithFormat:@"Welcome, %@", [MVRIGlobalData sharedInstance].Firstname]];
    
    _btnAddEvent.hidden = true;
    NSString *userRole=[MVRIGlobalData sharedInstance].UsrRole;
    if([userRole  isEqual: @"InterpreterFirm"])
    {
        _btnAddEvent.hidden = false;
    }
    
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)revelMenuPressed:(id)sender{
    [self.revealViewController revealToggle:sender];
    
    
}


@end
