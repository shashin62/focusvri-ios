//
//  MVRIConferenceViewController.m
//  MVRI
//
//  Created by mac on 12/26/13.
//  Copyright (c) 2013 mac. All rights reserved.
//

#import "MVRIConferenceViewController.h"
#import "ConferenceLayout.h"
#import "InformationViewController.h"
#import "AlertsViewController.h"
#import "VideoCollectionViewCell.h"
//#import <ooVooSDK/ooVooSDK.h>
#import "MVRIConferenceViewController.h"
#import "ASIFormDataRequest.h"

#import "MVRIGlobalData.h"

@interface MVRIConferenceViewController ()<UIPopoverControllerDelegate>
{
    BOOL mic;
    BOOL speaker;
    BOOL camera;
    NSUInteger currentCamera;
    UITextView *activeField;
    NSDate *callStartTime;
    NSDate *callEndTime;
    NSTimeInterval callDurationSec;
}

@property (nonatomic, copy) NSString *zoomedParticipantID;
//@property (nonatomic, strong) ooVooVideoView *fullScreenVideoView;
@property (nonatomic, strong) UIPopoverController *infoPopoverController;
@property (nonatomic, strong) UIPopoverController *alertsPopoverController;
@property (nonatomic, strong) NSBlockOperation *blockOperation;

@property (nonatomic, strong) ooVooClient *sdk;

@end

static NSString *kCellIdentifier = @"VIDEO_CELL";

@implementation MVRIConferenceViewController

- (void)dealloc
{
    self.infoPopoverController.delegate = self.alertsPopoverController.delegate = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        ConferenceViewController *conferenceVC = [[ConferenceViewController alloc] initWithCollectionViewLayout:[ConferenceLayout new]];
    }
    return self;
}

CGSize scrSize;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Conference";
    self.view.backgroundColor = [UIColor blackColor];
    
	[_collectionView registerClass:[VideoCollectionViewCell class] forCellWithReuseIdentifier:kCellIdentifier];
    _collectionView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    /*
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Alerts"
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(showAlertsView:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Info"
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(navigateToInformation:)];
    */
    
    callStartTime=[NSDate date];
    NSLog(@"%@", callStartTime);
    
    //self.navigationController.navigationBarHidden = YES;
//    speaker = [ooVooClient sharedInstance].speakerEnabled = YES;
//    mic = [ooVooController sharedController].microphoneEnabled = YES;
    //currentCamera = [ooVooController sharedController].currentCamera;
    //[[ooVooController sharedController] setCameraResolutionLevel:2];
    
    [self.sdk.AVChat.AudioController setRecordMuted:![self.sdk.AVChat.AudioController isRecordMuted]];
    mic = ![self.sdk.AVChat.AudioController isRecordMuted];
    NSLog(@"record muted %d", [self.sdk.AVChat.AudioController isRecordMuted]);
    [self.sdk.AVChat.AudioController setPlaybackMute:![self.sdk.AVChat.AudioController isPlaybackMuted]];
    speaker = ![self.sdk.AVChat.AudioController isPlaybackMuted];
    
    NSArray *arr_dev = [self.sdk.AVChat.VideoController getDevicesList];
    
    NSLog(@"get device list %@", [self.sdk.AVChat.VideoController getDevicesList]);
    NSLog(@"get current camera device  %@", [self.sdk.AVChat.VideoController getConfig:ooVooVideoControllerConfigKeyCaptureDeviceId]);
    
    for (id<ooVooDevice> device in arr_dev) {
        
        NSString *strDeviceName = [NSString stringWithFormat:@"%@", device];
        
//        // adding only camera which is nt the current
//        if (![strDeviceName isEqualToString:[self getSelectedDeviceName]]) {
//            [actionSheet addButtonWithTitle:strDeviceName];
//        }
        
        NSLog(@"\ndevice name:%@,device ID:%@", device.deviceName, device.deviceID);
    }


    //scrSize = [[UIScreen mainScreen] bounds].size;
    //_collectionView.frame=CGRectMake(0,60,scrSize.width,scrSize.height);
    
    _BottomLeftArrowButton.hidden = true;
    _BottomRightArrowButton.hidden = true;
    _TopRightArrowButton.hidden = true;
    _TopLeftArrowButton.hidden = true;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
//    UIBarButtonItem *micBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_mic"]
//                                                                         style:mic?UIBarButtonItemStyleBordered:UIBarButtonItemStyleDone
//                                                                        target:self
//                                                                        action:@selector(muteMicPressed:)];
    
//    UIBarButtonItem *spkBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_speaker"]
//                                                                         style:speaker?UIBarButtonItemStyleBordered:UIBarButtonItemStyleDone
//                                                                        target:self
//                                                                        action:@selector(muteSpeakerPressed:)];
    
//    UIBarButtonItem *endBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"  LEAVE  "
//                                                                         style:UIBarButtonItemStyleDone
//                                                                        target:self
//                                                                        action:@selector(endCallButtonPressed:)];
    
//    UIBarButtonItem *camBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_camera"]
//                                                                         style:currentCamera?UIBarButtonItemStyleBordered:UIBarButtonItemStyleDone
//                                                                        target:self
//                                                                        action:@selector(cameraPressed:)];
    
//    UIBarButtonItem *resBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[self resolutionText]
//                                                                         style:UIBarButtonItemStyleBordered
//                                                                        target:self
//                                                                        action:@selector(resButtonPressed:)];
    
//    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
//    {
//        [self setToolbarItems:@[flexibleItem, micBarButtonItem, spkBarButtonItem, endBarButtonItem, camBarButtonItem, resBarButtonItem, flexibleItem] animated:NO];
//    }
//    else
//    {
//        [self setToolbarItems:@[micBarButtonItem, flexibleItem, spkBarButtonItem, flexibleItem, endBarButtonItem, flexibleItem, camBarButtonItem, flexibleItem, resBarButtonItem] animated:NO];
//    }
//    
    
    self.navigationController.toolbarHidden = YES;
    
    _datePickerHolder.hidden=YES;  //--bt003 new addition

    
    CALayer *btnLayer = [_saveButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];

    btnLayer = [_resButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    
    btnLayer = [_setDateButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    
    btnLayer = [_leaveButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    
    btnLayer = [_doneButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    
    [self registerForKeyboardNotifications];
    
    //scrSize = [[UIScreen mainScreen] bounds].size;
    //_collectionView.frame=CGRectMake(0,60,scrSize.width,scrSize.height);

}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_collectionView reloadData];
    self.participantsController.delegate = self;
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(participantDidLeave:) name:OOVOOParticipantDidLeaveNotification object:nil];
    _viewScrollViewBott.constant = 0.0;
    _viewCollViewBtw.constant = 1.0;
    [self.view layoutIfNeeded];
	
//	[self.view bringSubviewToFront:_datePicker];
//	_datePicker.hidden = NO;

    
    scrSize = [[UIScreen mainScreen] bounds].size;
    _collectionView.frame=CGRectMake(0,60,scrSize.width,scrSize.height);
     //[_datePickerHolder setCenter:CGPointMake( 0+ (_datePickerHolder.bounds.size.width/2.0), scrSize.height-(_datePickerHolder.bounds.size.height/2.0))];
    
        //[_datePickerHolder setCenter:CGPointMake(scrSize.width/2.0, scrSize.height - (_datePickerHolder.bounds.size.height/2.0))];
   
    
	//[_datePickerHolder setCenter:CGPointMake(scrSize.width/2.0, scrSize.height + (_datePickerHolder.bounds.size.height/2.0))];
     // [_datePickerHolder setCenter:CGPointMake( scrSize.width/2.0, scrSize.height/2.0)];
    //_datePickerHolder.hidden=YES;
   // _datePickerHolder.autoresizingMask =(UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin);
    
    
    _isDatePickerVisible = NO;
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.participantsController.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (IBAction)saveButtonPressed:(id)sender{
    //http://24.120.25.158/callinga/api/vri/SaveNote?key=a0d63808-5c6a-467c-a78f-ccc3be886787
	//http://24.120.25.158/callinga/api/vri/SaveFollowUp ?key=dad1acd3-8a07-4f10-9805-72032bbeb934
    NSString *_urlString = [NSString stringWithFormat:@"http://login.mobilevri.com/api/vri/SaveFollowUp?key=%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
	//NSString *_urlString = [NSString stringWithFormat:@"http://mobilevri.com/api/vri/SaveFollowUp?key=%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
    NSURL *url = [NSURL URLWithString:_urlString];
	//create form request for fetching appointments
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	//apptid=1003&note=hello%20world
    [request setPostValue:_conferenceId forKey:@"apptid"];
//	NSString *sampleString = [_details.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
    [request setPostValue:_details.text forKey:@"followupreason"];
    
//	[request setPostValue:@"9/13/2013%2010:59%20AM" forKey:@"followupdate"];
    [request setPostValue:[_selectedDate stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"followupdate"];
    [request start];
    
    NSError *error = [request error];
    if (!error) {
        
        //process the reply
        NSString *response = [request responseString];
        NSLog(@"all appointments: %@", response);
	}
}

- (IBAction)setFollowupDatePressed:(id)sender{
    if (!_isDatePickerVisible) {
        [UIView animateWithDuration:0.5 animations:^{
            CGSize scrSize = [[UIScreen mainScreen] bounds].size;
            //[_datePickerHolder setCenter:CGPointMake(scrSize.width/2.0, scrSize.height - (_datePickerHolder.bounds.size.height/2.0))];
            [_datePickerHolder setCenter:CGPointMake( scrSize.width/2.0, scrSize.height-(_datePickerHolder.bounds.size.height/2.0))];
            NSLog(@"Center of Date %f, %f, %f",_datePickerHolder.center.x , _datePickerHolder.center.y,scrSize.height  );
            if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
            {
                // code for landscape orientation
               //[_datePickerHolder setCenter:CGPointMake(0+_datePickerHolder.bounds.size.width/2,scrSize.width- (_datePickerHolder.bounds.size.height/2))];
                [_datePickerHolder setCenter:CGPointMake(scrSize.height/2,scrSize.width- (_datePickerHolder.bounds.size.height/2))];
            }
            _datePickerHolder.hidden=NO;
            _isDatePickerVisible = YES;
            NSLog(@"Center %f, %f, %f",_datePickerHolder.bounds.size.height, scrSize.width,scrSize.height  );
            [self.view bringSubviewToFront:_datePickerHolder];
           // _datePickerHolder.hidden = NO;
            /*if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                [_datePickerHolder setCenter:CGPointMake(scrSize.width/2.0, scrSize.height/2.0)];
            }*/
           // _datePickerHolder.autoresizingMask =            (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin);
            
        }];
        
    }else{
        [UIView animateWithDuration:0.5 animations:^{
            CGSize scrSize = [[UIScreen mainScreen] bounds].size;
            //[_datePickerHolder setCenter:CGPointMake(scrSize.width/2.0, scrSize.height + (_datePickerHolder.bounds.size.height/2.0))];
            [_datePickerHolder setCenter:CGPointMake( scrSize.width/2.0, scrSize.height+(_datePickerHolder.bounds.size.height/2.0))];
            if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
            {
                // code for landscape orientation
                //[_datePickerHolder setCenter:CGPointMake(0-_datePickerHolder.bounds.size.width/2,scrSize.height+ 0-_datePickerHolder.bounds.size.height/2-200)];
                [_datePickerHolder setCenter:CGPointMake(scrSize.height/2+_datePickerHolder.bounds.size.width/2,scrSize.width- (_datePickerHolder.bounds.size.height/2))];
                //[_datePickerHolder setCenter:CGPointMake(0, 0)];
            }
             _datePickerHolder.hidden=YES;
            _isDatePickerVisible = NO;
              NSLog(@"Center else %f, %f",_datePickerHolder.bounds.size.height, scrSize.width );
            [self.view bringSubviewToFront:_datePickerHolder];
            //_datePickerHolder.autoresizingMask =(UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin);
           // _datePickerHolder.hidden = YES;
        }];

    }
}

- (IBAction)doneButtonPressed:(id)sender{
    //set date format
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"M/d/yyyy hh:mma"];//Wed, Dec 14 2011 1:50 PM
    _selectedDate = [dateFormat stringFromDate:[_datePicker date]];
    [_setDateButton setTitle:_selectedDate forState:UIControlStateNormal];
    NSLog(@"%@", [_selectedDate stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
    [self setFollowupDatePressed:Nil];
}

- (void)navigateToInformation:(id)sender
{
    InformationViewController *infoViewController = [[InformationViewController alloc] initWithStyle:UITableViewStyleGrouped];
    infoViewController.participantsController = self.participantsController;
    infoViewController.conferenceId = self.conferenceId;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        if (!self.infoPopoverController)
        {
            self.infoPopoverController = [[UIPopoverController alloc] initWithContentViewController:infoViewController];
            self.infoPopoverController.delegate = self;
            [self.infoPopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        }
        else
        {
            [self.infoPopoverController dismissPopoverAnimated:YES];
            self.infoPopoverController = nil;
        }
    }
    else
    {
        infoViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:infoViewController animated:YES];
    }
}

- (void)showAlertsView:(id)sender
{
    AlertsViewController *alertsViewController = [[AlertsViewController alloc] init];
    alertsViewController.logsController = self.logsController;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        if (!self.alertsPopoverController)
        {
            self.alertsPopoverController = [[UIPopoverController alloc] initWithContentViewController:alertsViewController];
            self.alertsPopoverController.delegate = self;
            [self.alertsPopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        }
        else
        {
            [self.alertsPopoverController dismissPopoverAnimated:YES];
            self.alertsPopoverController = nil;
        }
    }
    else
    {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:alertsViewController];
        [self presentViewController:navigationController animated:YES completion: nil];
    }
}

- (IBAction)endCallButtonPressed:(id)sender
{
    callEndTime=[NSDate date];
    callDurationSec=[callEndTime timeIntervalSinceDate:callStartTime];
    NSLog(@"Call Time %f", callDurationSec);
    
    //[[ooVooController sharedController] leaveConference];
    [self.sdk.AVChat leave];
    
    NSString *_urlString = [NSString stringWithFormat:@"http://login.mobilevri.com/api/vri/SetAppointmentCallDuration?key=%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
    
    NSURL *url = [NSURL URLWithString:_urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setPostValue:_apptId  forKey:@"apptid"];
    [request setPostValue:callStartTime forKey:@"startdate"];
    NSLog(@"ApptId %@",_apptId);
    //NSInteger doubleTimeInterval = round(callDurationSec);
    [request setPostValue:[NSNumber numberWithDouble:round(callDurationSec)] forKey:@"noofsecs"];
     NSLog(@"callDurationSec %@",[NSNumber numberWithDouble:round(callDurationSec)]);
    //NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [request setRequestMethod:@"Post"];
    //[request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    [request start];
    
    NSError *error = [request error];
    if (!error) {
        NSString *response = [request responseString];
        NSLog(@"buffer time: %@", response);
        
        NSData *responseData=[response dataUsingEncoding:NSUTF8StringEncoding];
        
        NSArray *jsonArry = [NSJSONSerialization
                             JSONObjectWithData:responseData //1
                             
                             options:NSJSONReadingMutableContainers
                             error:&error];
        
        NSLog(@"response - %@",jsonArry);
    }
}

- (IBAction)muteMicPressed:(id)sender
{
    mic = !mic;
    [self.sdk.AVChat.AudioController setRecordMuted:![self.sdk.AVChat.AudioController isRecordMuted]];
//    ((UIBarButtonItem *)sender).style = mic?UIBarButtonItemStyleBordered:UIBarButtonItemStyleDone;
    if (!mic) {
        [_micButton setBackgroundImage:[UIImage imageNamed:@"sdk_ic_mic_selected_tap.png"] forState:UIControlStateNormal];
    }else{
        [_micButton setBackgroundImage:[UIImage imageNamed:@"sdk_ic_mic_tap.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)muteSpeakerPressed:(id)sender
{
    speaker = !speaker;
    [self.sdk.AVChat.AudioController setPlaybackMute:![self.sdk.AVChat.AudioController isPlaybackMuted]];
//    ((UIBarButtonItem *)sender).style = speaker?UIBarButtonItemStyleBordered:UIBarButtonItemStyleDone;
    if (!speaker) {
        [_speakerButton setBackgroundImage:[UIImage imageNamed:@"sdk_ic_speaker_selected_tap.png"] forState:UIControlStateNormal];
    }else{
        [_speakerButton setBackgroundImage:[UIImage imageNamed:@"sdk_ic_speaker_tap.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)cameraPressed:(id)sender
{
    currentCamera = !currentCamera;
    //[[ooVooController sharedController] selectCamera:currentCamera];
//    ((UIBarButtonItem *)sender).style = currentCamera?UIBarButtonItemStyleBordered:UIBarButtonItemStyleDone;
    NSLog(@"_cameraButton: %d",_cameraButton.state);
    if (!currentCamera) {
        [_cameraButton setBackgroundImage:[UIImage imageNamed:@"sdk_ic_camera_selected_tap.png"] forState:UIControlStateNormal];
    }else{
        [_cameraButton setBackgroundImage:[UIImage imageNamed:@"sdk_ic_camera_tap.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)resButtonPressed:(id)sender
{
//    ooVooController *ooVoo = [ooVooController sharedController];
//    if ([ooVoo cameraResolutionLevel] == ooVooCameraResolutionLow)
//    {
//        [ooVoo setCameraResolutionLevel:ooVooCameraResolutionMedium];
//        ((UIBarButtonItem *)sender).title = @"Med";
//    }
//    else if ([ooVoo cameraResolutionLevel] == ooVooCameraResolutionMedium)
//    {
//        [ooVoo setCameraResolutionLevel:ooVooCameraResolutionLow];
//        ((UIBarButtonItem *)sender).title = @"Low";
//    }
}

- (IBAction)submitButtonPressed:(id)sender{
    /*
    //http://24.120.25.158/callinga/api/vri/SaveFollowUp?key=dad1acd3-8a07-4f10-9805-72032bbeb934
    NSString *_urlString = [NSString stringWithFormat:@"http://mobilevri.com/api/vri/GetAppointmentsRange?key=%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
    NSURL *url = [NSURL URLWithString:_urlString];
    
    //fetch current system date
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"M/d/yyyy hh:mma"];//Wed, Dec 14 2011 1:50 PM
    NSString *str_date = [dateFormat stringFromDate:start];
    NSLog(@"str_date = %@",str_date);
    
    
    NSString *end_date = [dateFormat stringFromDate:end];
    NSLog(@"end_date = %@",end_date);
    
    //create form request for fetching appointments
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:str_date forKey:@"fd"];
    [request setPostValue:end_date forKey:@"td"];
    [request start];
    
    NSError *error = [request error];
    if (!error) {
        
        //process the reply
        NSString *response = [request responseString];
        NSLog(@"all appointments: %@", response);
        [self parseData:[response dataUsingEncoding:NSUTF8StringEncoding]];
        
        //reset arrays
        self.dataArray = [NSMutableArray array];
        self.dataDictionary = [NSMutableDictionary dictionary];
        
        NSLog(@"difference:%d",[start daysBetweenDate:end]);
        
        for (int i = 0; i<[start daysBetweenDate:end]; i++) {
            [self.dataArray addObject:@NO];
        }
        
        
        for (NSDictionary *_tempDict in _allResults) {
            //        [_clientList addObject:[[NSDictionary alloc] initWithDictionary:_tempDict copyItems:YES]];
            
            //convert string to nsdate
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"M/d/yyyy hh:mm:ssa"];
            //            NSLog(@"----start---------d:%@", [_tempDict valueForKey:@"start"]);
            NSDate *myDate = [df dateFromString: [_tempDict valueForKey:@"start"]];
            
            NSDateComponents *info = [myDate dateComponentsWithTimeZone:self.monthView.timeZone];
            info.hour = 0;
            info.minute = 0;
            info.second = 0;
            
            NSDate *_manupulatedDate = [NSDate dateWithDateComponents:info];
            
            if ((self.dataDictionary) [_manupulatedDate] == Nil) {
                (self.dataDictionary) [_manupulatedDate] = [NSMutableArray array];
            }
            
            
            
            //            [((NSMutableArray*) (self.dataDictionary) [_manupulatedDate]) addObject:[NSString stringWithFormat:@"Claim :%@, %@, %@", [_tempDict objectForKey:@"claimno"], [_tempDict objectForKey:@"interpreterName"], [_tempDict objectForKey:@"clientName"] ]];
            
            [((NSMutableArray*) (self.dataDictionary) [_manupulatedDate]) addObject:_tempDict];
            
            int diffInDays = [start daysBetweenDate:_manupulatedDate];
            [_dataArray replaceObjectAtIndex:diffInDays withObject:@YES];
            
        }
        //    [_clientList addObjectsFromArray:latestLoans];
    }
*/
}

- (NSString*)resolutionText
{
    //ooVooController *ooVoo = [ooVooController sharedController];
    NSString* resolutionText = @"";
//    if ([ooVoo cameraResolutionLevel] == ooVooCameraResolutionLow)
//    {
//        resolutionText = @"Low";
//    }
//    else if ([ooVoo cameraResolutionLevel] == ooVooCameraResolutionMedium)
//    {
//        resolutionText = @"Med";
//    }
//    
    return resolutionText;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return [self.participantsController numberOfParticipants];
}

VideoCollectionViewCell *cell, *cell1;

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
     cell = (VideoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(VideoCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Participant *participant = [self.participantsController participantAtIndex:indexPath.row];
    cell.avatarImgView.image = [UIImage imageNamed:@"user.png"];
    cell.userNameLabel.text = participant.displayName;
    
    //scrSize = [[UIScreen mainScreen] bounds].size;
    //_collectionView.frame =CGRectMake( 0,60,scrSize.width,scrSize.height);  //-- bt003 add
    /*
    ooVooVideoView *videoView;
    if ([self.zoomedParticipantID isEqualToString:participant.participantID])
    {
        videoView = self.fullScreenVideoView;
    }
    else
    {
        videoView = cell.videoView;
    }
    
    switch (participant.state)
    {
        case ooVooVideoUninitialized:
            [cell showAvatar];
            [cell hideState];
            [[ooVooController sharedController] receiveParticipantVideo:YES forParticipantID:participant.participantID];
            break;
        case ooVooVideoOn:
        {
            NSUInteger maskUI  = [self supportedInterfaceOrientations];
            NSUInteger maskApp = [[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.view.window];
            NSUInteger mask = maskUI & maskApp;
            BOOL isRotationSupported = !( UIDeviceOrientationIsPortrait(mask) || UIDeviceOrientationIsLandscape(mask));
            BOOL isPreview = (indexPath.row == 0);
            
            videoView.preview  = isPreview;
            videoView.mirrored = (isPreview && currentCamera);
            videoView.supportOrientation = (isRotationSupported ? isPreview : !isPreview);
            
            [videoView associateToID:participant.participantID];
            //videoView = self.fullScreenVideoView;
            [cell hideAvatar];
            [cell hideState];
        }
            break;
        case ooVooVideoOff:
            [cell showAvatar];
            [videoView clear];
            [cell hideState];
            if (videoView == self.fullScreenVideoView) { [self zoomOut:nil]; }
            break;
        case ooVooVideoPaused:
            [cell showAvatar];
            [videoView clear];
            [cell showState:@"Video cannot be viewed"];
            if (videoView == self.fullScreenVideoView) { [self zoomOut:nil]; }
        default:
            break;
    }*/
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Participant *participant = [self.participantsController participantAtIndex:indexPath.row];
    [self zoomIn:participant];
    
    //scrSize = [[UIScreen mainScreen] bounds].size;
    //_collectionView.frame =CGRectMake( 0,60,scrSize.width,scrSize.height);
    
    // lets ensure it's actually visible (yes we got here from a touch event so it must be... just more info)
    /*if ([self.collectionView.indexPathsForVisibleItems containsObject:indexPath]) {
        
        // get a ref to the UICollectionViewCell at indexPath
        cellView =(UICollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        
        //finally get the rect for the cell
        CGRect frame = cellView.frame;
        
        // do your processing here... a ref to the cell will allow you to drill down to the image without the headache!!
        
        frame.origin.x=70;
        frame.origin.y=100;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        cell.frame=frame;
        [UIView commitAnimations];
    }*/
}

/*-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //UIViewController *currentVC = self.navigationController.visibleViewController;
    if ([[self.view subviews] containsObject:self.fullScreenVideoView])//[self.fullScreenVideoView removeGestureRecognizer:gestureRecognizer];
    {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:touch.view];
    cell.center = location;
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesBegan:touches withEvent:event];

}*/

-(void)MoveToTopLeftArrow:(id)send
{
    
    CGRect frame= _collectionView.frame;
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation))
    {
        frame.origin.x= 40;
        frame.origin.y= 40;
    }
    else
    {
        frame.origin.x= 40;
        frame.origin.y= 40;
    }
    
    if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
    {
        frame.origin.x= 0;
        frame.origin.y= 20;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    //_collectionView.frame=frame;
    cell.frame=frame;
    [UIView commitAnimations];
}

-(void)MoveToBottomLeftArrow:(id)send
{
    
    CGRect frame= _collectionView.frame;
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation))
    {
        frame.origin.x= 40;
        frame.origin.y=scrSize.height - 200;
    }
    else
    {
        frame.origin.x= 40;
        frame.origin.y= scrSize.width - 200;
    }
    
    if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
    {
        frame.origin.x= 0;
        frame.origin.y= scrSize.height - 250;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    //_collectionView.frame=frame;
    cell.frame=frame;
    [UIView commitAnimations];
}

- (IBAction)MoveToBottomRightArrow:(id)sender
{
    CGRect frame= _collectionView.frame;
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation))
    {
        frame.origin.x= scrSize.width - 200;
        frame.origin.y= scrSize.height - 200;
    }
    else
    {
        frame.origin.x= scrSize.height - 200;
        frame.origin.y= scrSize.width - 200;
    }
    
    if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
    {
        frame.origin.x= scrSize.width - 155;
        frame.origin.y= scrSize.height - 250;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    //_collectionView.frame=frame;
    cell.frame=frame;
    [UIView commitAnimations];
}

- (IBAction)MoveToTopRightArrow:(id)sender
{
    CGRect frame= _collectionView.frame;
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation))
    {
        frame.origin.x= scrSize.width - 200;
        frame.origin.y = 40;
    }
    else
    {
        frame.origin.x=scrSize.height - 200;
        frame.origin.y = 40;
    }
    
    if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
    {
        frame.origin.x= scrSize.width - 155;
        frame.origin.y= 20;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    //_collectionView.frame=frame;
    cell.frame=frame;
    [UIView commitAnimations];
}

#pragma mark - ParticipantsControllerDelegate
- (void)controllerWillChangeContent:(ParticipantsController *)controller
{
    self.blockOperation = [NSBlockOperation new];
}

- (void)controller:(ParticipantsController *)controller didChangeParticipant:(Participant *)aParticipant atIndexPath:(NSIndexPath *)indexPath forChangeType:(ParticipantChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    __weak UICollectionView *collectionView = _collectionView;
    
    //scrSize = [[UIScreen mainScreen] bounds].size;
    //_collectionView.frame =CGRectMake( 0,60,scrSize.width,scrSize.height);
    
    
    switch (type)
    {
        case ParticipantChangeInsert:
        {
            [self.blockOperation addExecutionBlock:^{ [collectionView insertItemsAtIndexPaths:@[newIndexPath]]; }];
            break;
        }
            
        case ParticipantChangeDelete:
        {
            [self.blockOperation addExecutionBlock:^{ [collectionView deleteItemsAtIndexPaths:@[indexPath]]; }];
            break;
        }
            
        case ParticipantChangeUpdate:
        {
            [self.blockOperation addExecutionBlock:^{ [collectionView reloadItemsAtIndexPaths:@[indexPath]]; }];
            break;
        }
            
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(ParticipantsController *)controller
{
    [_collectionView performBatchUpdates:^{ [self.blockOperation start]; }
                                  completion:nil];
    
    //scrSize = [[UIScreen mainScreen] bounds].size;
    //_collectionView.frame =CGRectMake( 0,60,scrSize.width,scrSize.height);
}

Participant *participantOther ;

#pragma mark - Zoom
- (void)zoomIn:(Participant *)participant
{
    //if (participant.state != ooVooVideoOn) return;
    
    
    //NSUInteger currentRow = [self.participantsController indexOfParticipantWithId:self.zoomedParticipantID];
    //= [self.participantsController participantAtIndex:currentRow];

    //for(UICollectionViewCell *cell in self.collectionView.visibleCells)
    //{
        
    //}
     for(int i=0 ;i<self.participantsController.numberOfParticipants;i++)
    //for(int i=0, j=0 ;i<self.participantsController.numberOfParticipants, j<= currentRow;i++, j++)
    {
        
        if([self.participantsController participantAtIndex:i].participantID != participant.participantID)
        {
            participantOther=[self.participantsController participantAtIndex:i];
    /*
            ooVooVideoView *videoView1;
            [videoView1 associateToID:participantOther];
            
            NSUInteger index = [self.participantsController indexOfParticipantWithId:participantOther.participantID];
            NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:index inSection:0];
            cell1.videoView=videoView1;
            [self configureCell:cell1 atIndexPath:indexPath1];
            [self.view addSubview:cell1];
     */
            
            
            
            
     /*ooVooVideoView *videoView;
            if ([self.zoomedParticipantID isEqualToString:participant.participantID])
            {
                videoView = self.fullScreenVideoView;
            }
            else
            {
                [videoView associateToID:participantOther];
                videoView = cell.videoView;
            }*/
            
            
            //cell = (VideoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
          //NSIndexPath *Path = [self.collectionView indexPathForCell:cell];
            
            /*if([[self.collectionView indexPathForCell].cellIndex] != currentRow)
            {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:0];
           // [_collectionView reloadItemsAtIndexPaths:@[indexPath]];
            
                [self configureCell:cell atIndexPath:cellIndex];
            }*/
        }
    }
    
    self.zoomedParticipantID = participant.participantID;
    NSUInteger index = [self.participantsController indexOfParticipantWithId:self.zoomedParticipantID];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomOut:)];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;

    
    UICollectionViewLayoutAttributes *attributes = [_collectionView layoutAttributesForItemAtIndexPath:indexPath];
    CGRect cellRect = attributes.frame;
    cellRect = [_collectionView convertRect:cellRect toView:self.view];
    
    /*CGRect aRect;
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation))
    {
     //aRect = CGRectMake(-180, 80, scrSize.width+500 , scrSize.height-280);
    aRect = CGRectMake(0, 80, 750, 750);
        NSLog(@"width = %f", scrSize.width);
        NSLog(@"height = %f", scrSize.height);
        
       
   
    aRect = [_collectionView convertRect:aRect toView:self.view];
    }
    else
    {
        //aRect = CGRectMake(0, 0, scrSize.height+300 , scrSize.width-60);
        aRect = CGRectMake(0, 100, 1000 , 450);
        NSLog(@"Landwidth = %f", scrSize.width);
        NSLog(@"Landheight = %f", scrSize.height);
        // cellRect = [_collectionView convertRect:cellRect toView:self.view];
        aRect = [_collectionView convertRect:aRect toView:self.view];
    }*/
    
    NSUInteger maskUI  = [self supportedInterfaceOrientations];
    NSUInteger maskApp = [[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.view.window];

    NSUInteger mask = maskUI & maskApp;
    
    
    BOOL isRotationSupported = !( UIDeviceOrientationIsPortrait(mask) || UIDeviceOrientationIsLandscape(mask));
    //BOOL isRotationSupported = !( UIDeviceOrientationPortrait || UIDeviceOrientationLandscapeLeft || UIDeviceOrientationLandscapeRight);
    BOOL isPreview = participant.isMe;
   /*
    self.fullScreenVideoView = [[ooVooVideoView alloc] initWithFrame:cellRect];
    self.fullScreenVideoView.fitVideoMode = YES;
    
    /*self.fullScreenVideoView = [[ooVooVideoView alloc] initWithFrame:aRect];
    self.fullScreenVideoView.fitVideoMode = NO;
    
    self.fullScreenVideoView.supportOrientation = (isRotationSupported ? isPreview : !isPreview);
    self.fullScreenVideoView.mirrored =(isPreview && currentCamera);
    self.fullScreenVideoView.preview = isPreview;
    
    self.fullScreenVideoView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin;
    
    [self.fullScreenVideoView addGestureRecognizer:singleTapGestureRecognizer];
    
    
    [self.view addSubview:self.fullScreenVideoView];
    //[self.view addSubview:self];
    [self.fullScreenVideoView associateToID:self.zoomedParticipantID];*/
  
    
    
    NSUInteger currentRow2 = [self.participantsController indexOfParticipantWithId:participantOther.participantID];
    NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:currentRow2 inSection:0];
    if (currentRow2 != NSNotFound)
    {
        [_collectionView cellForItemAtIndexPath:indexPath2];
        [self configureCell:cell atIndexPath:indexPath2];
    }
    //--Bt003 new addition
    [self.view addSubview:cell]; //--for thumbnail video on big video screen
    
    
    [self.view addSubview:self.TopLeftArrowButton];
    _TopLeftArrowButton.hidden = false;
    [self.view addSubview:self.BottomLeftArrowButton];
    _BottomLeftArrowButton.hidden = false;
    [self.view addSubview:self.BottomRightArrowButton];
    _BottomRightArrowButton.hidden = false;
    [self.view addSubview:self.TopRightArrowButton];
    _TopRightArrowButton.hidden = false;
    //--Bt003 new addition
    
    
   /* CGRect frame= _collectionView.frame;
    frame.origin.x=70;
    frame.origin.y=100;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    _collectionView.frame=frame;
    [UIView commitAnimations];*/
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    
    [UIView animateWithDuration:0.25 animations:^{
        
        [self.navigationController setToolbarHidden:YES animated:YES];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        
        //self.fullScreenVideoView.frame = self.view.frame;
        //self.fullScreenVideoView.frame = [_collectionView convertRect:aRect toView:self.view];
        
        [self.view addSubview:self.buttonHolder];  //--Bt003 new addition
        
    }];
}

- (void)zoomOut:(UITapGestureRecognizer *)gestureRecognizer
{
    CGRect cellRect = CGRectZero;
    NSUInteger row = [self.participantsController indexOfParticipantWithId:self.zoomedParticipantID];
    
    if (row != NSNotFound)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        UICollectionViewLayoutAttributes *attributes = [_collectionView layoutAttributesForItemAtIndexPath:indexPath];
        cellRect = attributes.frame;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        
        //[self.navigationController setToolbarHidden:NO animated:YES];  //--Bt003
        //[self.navigationController setNavigationBarHidden:NO animated:YES];
        
        //self.fullScreenVideoView.frame = cellRect;
        
    } completion:^(BOOL finished){
        
//        if (gestureRecognizer) [self.fullScreenVideoView removeGestureRecognizer:gestureRecognizer];
//        [self.fullScreenVideoView clear];
//        [self.fullScreenVideoView removeFromSuperview];
//        self.fullScreenVideoView = nil;
//        

        //--Bt003 new addition
       _BottomLeftArrowButton.hidden = true;
        _BottomRightArrowButton.hidden = true;
        _TopRightArrowButton.hidden = true;
        _TopLeftArrowButton.hidden = true;
        //--Bt003 new addition
        
        NSUInteger currentRow = [self.participantsController indexOfParticipantWithId:self.zoomedParticipantID];
        self.zoomedParticipantID = nil;
        
        NSUInteger currentRow2 = [self.participantsController indexOfParticipantWithId:participantOther.participantID];
        
        
        if (currentRow != NSNotFound)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentRow inSection:0];
            [_collectionView reloadItemsAtIndexPaths:@[indexPath]];
            if (currentRow2 != NSNotFound)
            {
                NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:currentRow2 inSection:0];
                [_collectionView reloadItemsAtIndexPaths:@[indexPath2]];
            }
        }
    }];
}

- (void)participantDidLeave:(NSNotification *)notification
{
   /* CGRect cellRect = CGRectZero;
    NSString *ParticipantID = [notification.userInfo objectForKey:OOVOOParticipantIdKey];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.fullScreenVideoView != nil){
            if ([ParticipantID isEqualToString:self.zoomedParticipantID]){
                [UIView animateWithDuration:0.25 animations:^{
                    
                    [self.navigationController setToolbarHidden:NO animated:YES];
                    [self.navigationController setNavigationBarHidden:NO animated:YES];
                    
                    self.fullScreenVideoView.frame = cellRect;
                    
                } completion:^(BOOL finished){
                    [self.fullScreenVideoView clear];
                    [self.fullScreenVideoView removeFromSuperview];
                    self.zoomedParticipantID = nil;
                    self.fullScreenVideoView = nil;
                }];
            }
        }
    });*/
}

#pragma mark - UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if (popoverController == self.infoPopoverController)
    {
        self.infoPopoverController = nil;
    }
    else if (popoverController == self.alertsPopoverController)
    {
        self.alertsPopoverController = nil;
    }
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

#pragma mark - keyboard functions
// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWillShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, _buttonHolder.frame.origin) ) {
        [self.scrollView scrollRectToVisible:_buttonHolder.frame animated:YES];
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
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

#pragma - mark uitextfield delegate methods

-(BOOL) textViewShouldBeginEditing:(UITextView *)textView{
    activeField = textView;
    if([textView.text isEqualToString:@"Notes"])
        [textView setText:@""];

    return YES;
}

//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
//    activeField = textField;
//    return YES;
//}

//- (void)textFieldDidBeginEditing:(UITextField *)textField
//{
//    
//}

-(void) textViewDidEndEditing:(UITextView *)textView{
     activeField = nil;
}
//- (void)textFieldDidEndEditing:(UITextField *)textField
//{
//    activeField = nil;
//}


//- (BOOL)textFieldShouldReturn:(UITextField *)textField{
//    [textField resignFirstResponder];
//    return YES;
//}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"]) {
        
        [textView resignFirstResponder];
        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    // For any other character return TRUE so that the text gets added to the view
    return YES;
}

@end
