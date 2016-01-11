//
//  SidebarViewController.m
//  SidebarDemo
//
//  Created by Simon on 29/6/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "SidebarViewController.h"
//#import "PhotoViewController.h"
#import "SWRevealViewController.h"
#import "ASIFormDataRequest.h"

@interface SidebarViewController ()

@property (nonatomic, strong) NSArray *menuItems;
@end

@implementation SidebarViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor FVRIWhileColor];

    self.tableView.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    self.tableView.separatorColor = [UIColor colorWithWhite:0.15f alpha:0.2f];
    
   // _menuItems = @[@"title", @"Home", @"Calender", @"Feedback", @"MobileVRI", @"Settings", @"AboutMVRI", @"Logout"];
   // _menuItems = @[@"title", @"Home", @"Calender", @"Feedback", @"MobileVRI", @"AboutMVRI", @"Logout"];
  
//    _menuItems = @[@"title", @"Home", @"Logout"];
    if ([[MVRIGlobalData sharedInstance].UsrRole  isEqual: @(4)]) {
        _menuItems = @[@"title", @"Home", @"Call Activity", @"TermsOfConditions", @"Logout"];
    } else {
        _menuItems = @[@"title", @"InterPreterHome", @"TermsOfConditions", @"Logout"];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [request start];
    NSError *error = [request error];
    if (!error) {
        NSString *response = [request responseString];
        NSLog(@"buffer time: %@", response);
    }
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.menuItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [self.menuItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%ld",(long)indexPath.row);
    if ([_menuItems[indexPath.row] isEqualToString:@"Logout"]) {
        //NSString *_urlString = [NSString stringWithFormat:@"http://login.mobilevri.com/api/vri/logout?key=%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
        //NSString *_urlString = [NSString stringWithFormat:@"http://mobilevri.com/api/vri/logout?key=%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
        NSString *_urlString = [NSString stringWithFormat:@"http://qa.focusvri.com/api/Logout"];
        NSURL *url = [NSURL URLWithString:_urlString];
        //create form request for fetching appointments
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request setRequestMethod:@"GET"];
        [request addRequestHeader:@"Token" value:[[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
        [request start];
        NSError *error = [request error];
        if (!error) {
            [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"MVRISessionID"];
            [self requestForChangeAvailabilityWithStatusId:kAWAY];
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else {
            [[[UIAlertView alloc]initWithTitle:@"Failure" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
        }
        
    } else if ([_menuItems[indexPath.row] isEqualToString:@"Home"]) {
        [self performSegueWithIdentifier:@"Home" sender:self];
    } else if ([_menuItems[indexPath.row] isEqualToString:@"InterPreterHome"]) {
        [self performSegueWithIdentifier:@"InterPreterHome" sender:self];
    } else if ([_menuItems[indexPath.row] isEqualToString:@"Call Activity"]) {
        [self performSegueWithIdentifier:@"Call Activity" sender:self];
    }

}

- (void)prepareForSegue:(UIStoryboardSegue *) segue sender: (id) sender
{
    // Set the title of navigation bar by using the menu items
//    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//    UINavigationController *destViewController = (UINavigationController*)segue.destinationViewController;
//    destViewController.title = [[_menuItems objectAtIndex:indexPath.row] capitalizedString];
//    
//    // Set the photo if it navigates to the PhotoView
//    if ([segue.identifier isEqualToString:@"Feedback"]) {
//        
//    }
    
    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] ) {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue*) segue;
        
        swSegue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc) {
            
            UINavigationController* navController = (UINavigationController *)self.revealViewController.frontViewController;
            [navController setViewControllers: @[dvc] animated: NO ];
            [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
        };
        
    }
    
}

@end
