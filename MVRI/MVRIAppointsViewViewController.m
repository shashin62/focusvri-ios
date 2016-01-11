//
//  MVRIAppointsViewViewController.m
//  MVRI
//
//  Created by mac on 11/9/13.
//  Copyright (c) 2013 mac. All rights reserved.
//

#import "MVRIAppointsViewViewController.h"
#import "MVRIGlobalData.h"
//#import "MVRIoovooMainviewController.h"
#import "ConferenceViewController.h"
#import "ConferenceLayout.h"
#import "SettingsViewController.h"
#import "TextFieldCell.h"

#import <ooVooSDK/ooVooSDK.h>
#import "ParticipantsController.h"
#import "LogsController.h"
#include "LoginParameters.h"
#import "MVRIConferenceViewController.h"
#import "ASIFormDataRequest.h"

@interface MVRIAppointsViewViewController ()
@property (nonatomic, strong) ParticipantsController *participantsController;
@property (nonatomic, strong) LogsController *logsController;

@property (nonatomic, strong) NSIndexPath *selectedRow;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@end

NSString * mPreValue;
NSString * mPostValue;
double intmValue;

@implementation MVRIAppointsViewViewController

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
//    self.navigationController.navigationBarHidden = NO;
//    self.navigationController.navigationBar.backItem.hidesBackButton = YES;
    // Change button color
   
    [self activityIndicator];

//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(conferenceDidBegin:)
//                                                 name:OOVOOConferenceDidBeginNotification
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(conferenceDidFail:)
//                                                 name:OOVOOConferenceDidFailNotification
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(conferenceDidEnd:)
//                                                 name:OOVOOConferenceDidEndNotification
//                                               object:nil];
   //GetSettingsList  GetCallBufferDuration
    NSString *_urlString = [NSString stringWithFormat:@"http://login.mobilevri.com/api/vri/GetSettingsList?key=%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
  
    NSURL *url = [NSURL URLWithString:_urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    //[request setPostValue:str_date forKey:@"fd"];
    //[request setPostValue:end_date forKey:@"td"];
    //NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [request setRequestMethod:@"Post"];
    [request start];

                             NSError *error = [request error];
    if (!error) {
        NSString *response = [request responseString];
                NSLog(@"buffer time: %@", response);
       
        NSData *responseData=[response dataUsingEncoding:NSUTF8StringEncoding];
        //NSLog(@"buffer time: %@", responseData);
       /* NSDictionary *jsonArry = [NSJSONSerialization
                              JSONObjectWithData:responseData //1
                              
                              options:NSJSONReadingMutableContainers
                              error:&error];*/
        NSArray *jsonArry = [NSJSONSerialization
                                  JSONObjectWithData:responseData //1
                                  
                                  options:NSJSONReadingMutableContainers
                                  error:&error];
        
        NSLog(@"%@",jsonArry);
        for(NSDictionary *json in jsonArry)
        {
            if([json[@"mkey"] isEqual: @"PreCallBuffer"])
            {
                mPreValue=json[@"mvalue"];
                NSLog(@"mValue : %@", mPreValue);NSLog(@"mValue : %d", [mPreValue intValue]*60);
            }
            else if([json[@"mkey"] isEqual: @"PostCallBuffer"])
            {
                mPostValue=json[@"mvalue"];
                NSLog(@"mValue : %@", mPostValue);NSLog(@"mValue : %d", [mPostValue intValue]*60);
            }
        }
        
        /*mValue = [jsonArry objectForKey:@"mvalue"];
        NSLog(@"mValue : %@", mValue);
        intmValue=[mValue intValue];
        intmValue=intmValue*60;
        NSLog(@"intmValue : %f", intmValue);*/
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [[[MVRIGlobalData sharedInstance] clientList]count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Appointments";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    MVRIGlobalData *_dataSource = [MVRIGlobalData sharedInstance];
    NSDictionary *_currentObject = (NSDictionary*)[_dataSource.clientList objectAtIndex:indexPath.row];
    
    // Configure the cell...
    UILabel *_claim = (UILabel*)[cell viewWithTag:1];
    [_claim setText:[NSString stringWithFormat:@"Claim :%@, %@, %@", [_currentObject objectForKey:@"claimno"], [_currentObject objectForKey:@"interpreterName"], [_currentObject objectForKey:@"clientName"] ]];
    
    UILabel *_start = (UILabel*)[cell viewWithTag:2];
    [_start setText:[NSString stringWithFormat:@"Start :%@", [_currentObject objectForKey:@"start"] ]];
    
    UILabel *_lang = (UILabel*)[cell viewWithTag:3];
    [_lang setText:[NSString stringWithFormat:@"Language :%@", [_currentObject objectForKey:@"language"] ]];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */

    _selectedRow = indexPath;
    MVRIGlobalData *_dataSource = [MVRIGlobalData sharedInstance];
    NSDictionary *_currentObject = (NSDictionary*)[_dataSource.clientList objectAtIndex:_selectedRow.row];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"M/d/yyyy hh:mm:ssa"];
    //            NSLog(@"----start---------d:%@", [_tempDict valueForKey:@"start"]);
    NSDate *myDate = [df dateFromString: [_currentObject valueForKey:@"start"]];
    NSDate *myEndDate = [df dateFromString: [_currentObject valueForKey:@"end"]];
     //            NSLog(@"----start---------d:%@", [_tempDict valueForKey:@"start"]);
    if ([myDate timeIntervalSinceNow] < ([mPreValue intValue]*60) && [myEndDate timeIntervalSinceNow] > -([mPostValue intValue]*60)) {
    //if ( [myDate timeIntervalSinceNow] > -1) {
        //alret view
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Video Call" message: @"Would you like to start a video call?" delegate: self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
        alert.tag = 5;
        [alert show];
    }
    else if ([myDate timeIntervalSinceNow] > intmValue) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Video Call" message: @"You are not elegible for placing the call at this moment" delegate: self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
        alert.tag = 1;
        [alert show];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Video Call" message: @"Appointment selected is in the past. Please select a current appointment." delegate: self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
        alert.tag = 1;
        [alert show];
    }

    
   
    
    /*    ---------------------------------------------------------------------------------
    //alret view
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Video Call" message: @"Would you like to start a video call?" delegate: self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
    alert.tag = 5;
    [alert show];
      --------------------------------------------------------------------------------- */
}


#pragma mark - uialertview Delegate functions
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 5) {
        
        
        if (buttonIndex == 0) {
            NSLog(@"user pressed Cancel");
        } else {
            NSLog(@"user pressed OK");
            MVRIGlobalData *_dataSource = [MVRIGlobalData sharedInstance];
            NSDictionary *_currentObject = (NSDictionary*)[_dataSource.clientList objectAtIndex:_selectedRow.row];
            NSLog(@"_currentobj:%@", [_currentObject objectForKey:@"conferenceid"]);
            //    NSLog(@"_currentobj:%@", [_dataSource.clientList description]);
            //    [self.navigationController pushViewController:[[MVRIoovooMainviewController alloc] initWithStyle:UITableViewStyleGrouped] animated:YES];
            //        MVRIoovooMainviewController *_oovooVideoController = [[MVRIoovooMainviewController alloc] initWithStyle:UITableViewStyleGrouped];
            //        [self.navigationController pushViewController:_oovooVideoController animated:YES];
            //        _oovooVideoController.conferenceId =[_currentObject objectForKey:@"conferenceid"];
            //        _oovooVideoController.opaqueString = [_currentObject objectForKey:@"clientName"];
            //        [_oovooVideoController.tableView reloadData];
            
            [self showActivityIndicator];
            self.participantsController = [[ParticipantsController alloc] init];
            self.logsController = [[LogsController alloc] init];
            self.logsController.participantsController = self.participantsController;
            
//            [[ooVooController sharedController] joinConference:[_currentObject objectForKey:@"conferenceid"]
//                                              applicationToken:@"MDAxMDAxAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAClOUOFcujXSpQMqu8VxcjVSQiN5w2RoFvfqV3Yak8Lzcn9+WSsfvUjJ7NzERzuQxNcSbVwy6uauJzSjahmUn68mdElPV0QqbXlRNQ62zb+s967W7J1G3BB9JQDJ+twmPc="
//                                                 applicationId:@"2113043454"
//                                               participantInfo:[_currentObject objectForKey:@"clientName"]];
            
        }
    }
}

#pragma mark - Notifications
- (void)conferenceDidBegin:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MVRIGlobalData *_dataSource = [MVRIGlobalData sharedInstance];
        NSDictionary *_currentObject = (NSDictionary*)[_dataSource.clientList objectAtIndex:_selectedRow.row];
        
        //Conf_VC
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        MVRIConferenceViewController * conferenceVC = (MVRIConferenceViewController *)[sb instantiateViewControllerWithIdentifier:@"Conf_VC"];
        
        
//        ConferenceViewController *conferenceVC = [[ConferenceViewController alloc] initWithCollectionViewLayout:[ConferenceLayout new]];
       
        conferenceVC.logsController = self.logsController;
        conferenceVC.participantsController = self.participantsController;
        conferenceVC.conferenceId = [_currentObject objectForKey:@"conferenceid"];
        conferenceVC.apptId = [_currentObject objectForKey:@"id"];
        
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:conferenceVC]
                           animated:YES
                         completion:^{ [self hideActivityIndicator]; }];
        
    });
}


- (void)conferenceDidEnd:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.participantsController = nil;
        self.logsController = nil;
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    });
}

- (void)conferenceDidFail:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //NSString *reason = [notification.userInfo objectForKey:OOVOOConferenceFailureReasonKey];
        [self hideActivityIndicator];
//        [self displayAlertMessage:reason];
        
        self.logsController = nil;
        self.participantsController = nil;
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    });
}

#pragma mark - Activity indicator
- (UIActivityIndicatorView *)activityIndicator
{
    if (!_activityIndicator)
    {
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    _activityIndicator.frame = CGRectMake(300.0, 300.0, 100.0, 100.0);
    
    return _activityIndicator;
}

- (void)showActivityIndicator
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
//        self.joinButton.hidden = YES;
        [self.activityIndicator startAnimating];
        
    });
}

- (void)hideActivityIndicator
{
    [self.activityIndicator stopAnimating];
//    self.joinButton.hidden = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation

{
    
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    
}
/*- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window

{
    
    return UIInterfaceOrientationMaskAllButUpsideDown;
    
}

- (NSUInteger)supportedInterfaceOrientations

{
    
    return UIInterfaceOrientationMaskLandscape;
    
}*/
@end
