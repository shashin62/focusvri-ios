//
//  MVRIInterPreterViewController.m
//  MVRI
//
//  Created by Murali Gorantla on 16/08/15.
//  Copyright (c) 2015 mac. All rights reserved.
//

#import "MVRIInterPreterViewController.h"
#import "SWRevealViewController.h"
#import "MVRIActivityTableViewCell.h"
#import "LogInVC.h"
#import "UIButton+Color.h"



@interface MVRIInterPreterViewController ()
@property (strong, nonatomic) NSArray *activities;
@property (nonatomic, strong) NSTimer *callStatusTimer;
@property (weak, nonatomic) IBOutlet UIButton *availableButton;
@property (weak, nonatomic) IBOutlet UIButton *awayButton;

@end

@implementation MVRIInterPreterViewController

#pragma mark - Server Calls

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

- (void)requestForAllInterpretersActivities {
    NSString *_urlString = [NSString stringWithFormat:@"http://qa.focusvri.com/api/GetActivity/%@",[MVRIGlobalData sharedInstance].userID];
    NSURL *url = [NSURL URLWithString:_urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:@"Token" value:[[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
    //[request start];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)requestForGetCallAnswerStatusLitsByContactId {
    //NSString *_urlString = [NSString stringWithFormat:@"http://qa.focusvri.com/api/GetCallAnswerStatusByContactId/%@",[MVRIGlobalData sharedInstance].userID];
    NSString *_urlString = [NSString stringWithFormat:@"http://qa.focusvri.com/api/GetConferenceRoomDetailsByContactId/%@",[MVRIGlobalData sharedInstance].userID];
    NSURL *url = [NSURL URLWithString:_urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    request.userInfo = [NSDictionary dictionaryWithObject:@"GetCallAnswerStatus" forKey:@"type"];
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:@"Token" value:[[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
    //[request start];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)requestForSaveCallAnswerStatus:(NSInteger)statusID {
    NSString *_urlString = [NSString stringWithFormat:@"http://qa.focusvri.com/api/SaveConferenceRoomDetails?"];
    NSURL *url = [NSURL URLWithString:_urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    request.userInfo = [NSDictionary dictionaryWithObject:@"SaveCallAnswerStatus" forKey:@"type"];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Token" value:[[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    NSDictionary *jsonDictionary = @{
                                     @"ConferenceID" : [MVRIGlobalData sharedInstance].conferenceID,
                                     @"CallStatusId" : @(statusID),
                                     @"InterpreterID": @([[MVRIGlobalData sharedInstance].userID integerValue]),
                                     @"ClaimantID": [MVRIGlobalData sharedInstance].conferenceID,
                                     @"InitiativeContactId": @([[MVRIGlobalData sharedInstance].userID integerValue])
                                     };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    
    [request appendPostData:jsonData];
    [request setDelegate:self];
    [request startAsynchronous];
}


#pragma - mark ASIHTTP delegate methods

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // fetch key
    //NSString *responseString = [[request responseHeaders] objectForKey:@"key"];
    NSString *response = [request responseString];
    NSData *responseData = [response dataUsingEncoding:NSUTF8StringEncoding];
    if ([[request.userInfo objectForKey:@"type"] isEqualToString:@"GetCallAnswerStatus"]) {
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        //NSDictionary *dictionary = [answerStatus firstObject];
        if ([dictionary[@"CallStatusId"] isEqual:@(114)] && [[NSString stringWithFormat:@"%@",dictionary[@"InterpreterID"]] isEqualToString:[NSString stringWithFormat:@"%@",[MVRIGlobalData sharedInstance].userID]]) {
            [MVRIGlobalData sharedInstance].conferenceID = [NSString stringWithFormat:@"%@",dictionary[@"ConferenceID"]];
            self.callButton.alpha = 1.0;
            self.callDisConnectButton.alpha = 1.0;
            [self play];
            [self.callStatusTimer invalidate];
            self.callStatusTimer = nil;
//            [request cancel];
//            [request setDelegate:nil];
        } else if ([dictionary[@"CallStatusId"] isEqual:@(115)] && [[NSString stringWithFormat:@"%@",dictionary[@"InterpreterID"]] isEqualToString:[NSString stringWithFormat:@"%@",[MVRIGlobalData sharedInstance].userID]]) {
            [self.callStatusTimer invalidate];
            self.callStatusTimer = nil;
            if ([self.avAudioPlayer isPlaying]) {
                [self.avAudioPlayer stop];
            }
            [self startTimer];
        }
        
    } else if ([[request.userInfo objectForKey:@"type"] isEqualToString:@"SaveCallAnswerStatus"]) {
        [self.callStatusTimer invalidate];
        self.callStatusTimer = nil;
        NSLog(@"Status = %@",[request userInfo]);
        [self startTimer];
    } else {
        self.activities = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        [self.callDetailsTableView reloadData];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"login failed:%@", [error description]);
}

#pragma mark - Life Cycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor FVRIWhileColor];
    //self.navigationController.navigationBarHidden = YES;
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.welcomeLabel setText:[NSString stringWithFormat:@"Welcome, %@", [MVRIGlobalData sharedInstance].Firstname]];
    self.callDetailsTableView.estimatedRowHeight = 73.0;
    self.callDetailsTableView.rowHeight = UITableViewAutomaticDimension;
    self.callDetailsTableView.backgroundColor = [UIColor clearColor];
    UIImage *img = [UIImage imageNamed:@"focus"];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
    [imgView setImage:img];
    [imgView setContentMode:UIViewContentModeScaleAspectFit];
    self.navigationItem.titleView = imgView;
    
    UIColor *color = [UIColor FVRIGreenColor];
    self.availableButton.layer.cornerRadius = 2;
    self.availableButton.layer.borderWidth = 1;
    self.availableButton.layer.borderColor = color.CGColor;
   [self.availableButton setColor:color forState:UIControlStateSelected ];
    [self.availableButton setTitleColor:color forState:UIControlStateNormal];
    [self.availableButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    self.awayButton.layer.cornerRadius = 2;
    self.awayButton.layer.borderWidth = 1;
    self.awayButton.layer.borderColor = color.CGColor;
   [self.awayButton setColor:color forState:UIControlStateSelected ];
    [self.awayButton setTitleColor:color forState:UIControlStateNormal];
    [self.awayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
//    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.segmentControl
//                                                                  attribute:NSLayoutAttributeHeight
//                                                                  relatedBy:NSLayoutRelationEqual
//                                                                     toItem:nil
//                                                                  attribute:NSLayoutAttributeNotAnAttribute
//                                                                 multiplier:1
//                                                                   constant:48.0];
//    [self.segmentControl addConstraint:constraint];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.callButton.alpha = 0.0;
    self.callDisConnectButton.alpha = 0.0;
    [self loadAudioPlayer];
    [self requestForAllInterpretersActivities];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.avAudioPlayer stop];
    [self.callStatusTimer invalidate];
    self.callStatusTimer = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startTimer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper Methods

- (NSDateFormatter *)formatter {
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MM/dd/yy";
        NSTimeZone *utc = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        [formatter setTimeZone:utc];
    });
    return formatter;
}

- (void)loadAudioPlayer {
    NSString *sound_file;
    if ((sound_file = [[NSBundle mainBundle] pathForResource:@"home_ringtone" ofType:@"mp3"])){
        
        NSURL *url = [[NSURL alloc] initFileURLWithPath:sound_file];
        self.avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        self.avAudioPlayer.delegate = self;
        [self.avAudioPlayer setNumberOfLoops:-1];
        [self.avAudioPlayer prepareToPlay];
    }

}

- (void)play {
    [self.avAudioPlayer play];
}

- (void)stop {
    [self.avAudioPlayer stop];
}

- (void)startTimer {
    self.callStatusTimer = [NSTimer
                            scheduledTimerWithTimeInterval:5
                            target:self selector:@selector(checkCallStatus:)
                            userInfo:nil repeats:YES];
}

- (void)checkCallStatus:(NSTimer *)timer {
    [self requestForGetCallAnswerStatusLitsByContactId];
}

#pragma mark - IBAction

- (IBAction)performMenuButtonAction:(id)sender {
    [self.revealViewController revealToggle:sender];
}

- (IBAction)call:(id)sender {
    self.callButton.alpha = 0.0;
    self.callDisConnectButton.alpha = 0.0;
    if ([self.avAudioPlayer isPlaying]) {
        [self stop];
    }
    UIButton *button = (UIButton *)sender;
    if (button.tag == 116) {
        [self requestForSaveCallAnswerStatus:button.tag];
        [MVRIGlobalData sharedInstance].callStartDate = [NSDate date];
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Video" bundle:nil];
        LogInVC *ooVooLogin = [storyBoard instantiateViewControllerWithIdentifier:@"ooVooVideoIdentifier"];
        [self.navigationController pushViewController:ooVooLogin animated:YES];
        
    } else {
        //[self startTimer];
        [self requestForSaveCallAnswerStatus:button.tag];
    }
}

- (IBAction)segmentClicked:(id)sender {
    UIButton *control = (UIButton *)sender;
    NSInteger integer = 0;
    control.selected = YES;
    if (control.tag == kAVAILABLE) {
        self.awayButton.selected = NO;
        integer = kAVAILABLE;
    } else {
        self.availableButton.selected = NO;
        integer = kAWAY;
    }
    [self requestForChangeAvailabilityWithStatusId:integer];
}

#pragma mark - Tableview Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.activities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MVRIActivityTableViewCell *cell = (MVRIActivityTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"activityIdentifier"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MVRIActivityTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    if (indexPath.row % 2) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:232.0/255.0 green:232.0/255.0 blue:232.0/255.0 alpha:1.0];
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    NSDateFormatter *formatter = [self formatter];
    NSDate *dateTemp = [[NSDate alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
    dateTemp = [formatter dateFromString:self.activities[indexPath.row][@"ActivityDate"]];
    [formatter setDateFormat:@"MMM/dd/yyyy"];
    cell.activityDateLabel.text = [formatter stringFromDate:dateTemp];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSDate *startDate = [formatter dateFromString:self.activities[indexPath.row][@"StartTime"]];
    NSDate *endDate = [formatter dateFromString:self.activities[indexPath.row][@"EndTime"]];
    [formatter setDateFormat:@"hh:mm a"];
    cell.activityTimeLabel.text = [NSString stringWithFormat:@"%@ - %@",[formatter stringFromDate:startDate],[formatter stringFromDate:endDate]];
    cell.claimantName.text = [NSString stringWithFormat:@"%@.",self.activities[indexPath.row][@"ClientContactName"]];
    cell.activityTotalTimeLabel.text = self.activities[indexPath.row][@"TotalTime"];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 73;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
