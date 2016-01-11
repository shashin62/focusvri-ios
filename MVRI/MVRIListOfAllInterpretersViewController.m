//
//  MVRIListOfAllInterpretersViewController.m
//  MVRI
//
//  Created by Murali Gorantla on 08/08/15.
//  Copyright (c) 2015 mac. All rights reserved.
//

#import "MVRIListOfAllInterpretersViewController.h"
#import "SWRevealViewController.h"
#import "TableHeaderView.h"
#import "TableFooterView.h"
#import "MVRIInterPretersTableViewCell.h"
#import "MVRIGlobalData.h"
#import "ParticipantsController.h"
#import "LogsController.h"
#import "MVRIConferenceViewController.h"
#import "LogInVC.h"
#include <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface MVRIListOfAllInterpretersViewController () <UIAlertViewDelegate,AVAudioPlayerDelegate>

@property (strong, nonatomic) NSArray *allInterpreters;
@property (nonatomic, strong) ParticipantsController *participantsController;
@property (nonatomic, strong) LogsController *logsController;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) AVAudioPlayer* avAudioPlayer;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSTimer *callStatusTimer;
@property (nonatomic, assign) BOOL state;

@end

@implementation MVRIListOfAllInterpretersViewController

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

#pragma mark - Notifications
- (void)conferenceDidBegin:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //MVRIGlobalData *_dataSource = [MVRIGlobalData sharedInstance];
        //NSDictionary *_currentObject = (NSDictionary*)[_dataSource.clientList objectAtIndex:_selectedRow.row];
        NSString *conferenceid = [NSString stringWithFormat:@"%@",self.allInterpreters[self.selectedIndexPath.row][@"ContactID"]];
        
        //Conf_VC
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        MVRIConferenceViewController * conferenceVC = (MVRIConferenceViewController *)[sb instantiateViewControllerWithIdentifier:@"Conf_VC"];
        
        
        //        ConferenceViewController *conferenceVC = [[ConferenceViewController alloc] initWithCollectionViewLayout:[ConferenceLayout new]];
        
        conferenceVC.logsController = self.logsController;
        conferenceVC.participantsController = self.participantsController;
        conferenceVC.conferenceId = conferenceid;
        // Need to check what is the use of apptID
        //conferenceVC.apptId = [_currentObject objectForKey:@"id"];
        
        conferenceVC.apptId = [NSString stringWithFormat:@"%ld",self.selectedIndexPath.row + 1];
        
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


#pragma mark - UI

- (void)navigationBarCustomAppearence {
    UIImage *img = [UIImage imageNamed:@"focus.png"];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [imgView setImage:img];
    [imgView setContentMode:UIViewContentModeScaleAspectFit];
    imgView.center = self.navigationItem.titleView.center;
    self.navigationItem.titleView = imgView;
}

#pragma mark - Server Methods

- (void)requestForGetInterpreters {
    NSString *_urlString = [NSString stringWithFormat:@"http://qa.focusvri.com/api/GetInterpreters?"];
    NSURL *url = [NSURL URLWithString:_urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    request.userInfo = [NSDictionary dictionaryWithObject:@"GetInterpreters" forKey:@"type"];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Token" value:[[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    NSInteger interPreterId = [[MVRIGlobalData sharedInstance].skillDictionary[@"ID"] integerValue];
    NSInteger languageID = [[MVRIGlobalData sharedInstance].languageDictionary[@"ID"] integerValue];
    NSInteger contactID = [[MVRIGlobalData sharedInstance].userID integerValue];
    NSDictionary *jsonDictionary = @{
        @"Gender" : [MVRIGlobalData sharedInstance].genderType,
        @"LanguageID" : @(languageID),
        @"InterpreterTypeID" : @(interPreterId),
        @"LoggedInContactId": @(contactID)
    };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary
                   options:NSJSONWritingPrettyPrinted
                     error:nil];

    [request appendPostData:jsonData];
    [request setDelegate:self];
    [request startAsynchronous];
//    NSError *error = [request error];
//    if (!error) {
//        NSString *response = [request responseString];
//        NSData *responseData = [response dataUsingEncoding:NSUTF8StringEncoding];
//        self.allInterpreters = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
//        [self.interPretersTableView reloadData];
//    }

}

- (void)requestForSaveCallAnswerStatus:(NSInteger)callAnswerStatusID {
    NSString *_urlString = [NSString stringWithFormat:@"http://qa.focusvri.com/api/SaveConferenceRoomDetails?"];
    NSURL *url = [NSURL URLWithString:_urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    request.userInfo = [NSDictionary dictionaryWithObject:@"SaveCallAnswerStatus" forKey:@"type"];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Token" value:[[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [MVRIGlobalData sharedInstance].getInterPreterIDWhenClaimantcalled = self.allInterpreters[self.selectedIndexPath.row][@"ContactID"];
    NSDictionary *jsonDictionary =    @{
      @"ConferenceID" : @([[MVRIGlobalData sharedInstance].userID integerValue]),
      @"CallStatusId" : @(callAnswerStatusID),
      @"InterpreterID": @([[MVRIGlobalData sharedInstance].getInterPreterIDWhenClaimantcalled integerValue]),
      @"ClaimantID": @([[MVRIGlobalData sharedInstance].userID integerValue]),
      @"InitiativeContactId": @([[MVRIGlobalData sharedInstance].userID integerValue])
      };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    
    [request appendPostData:jsonData];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)requestForGetCallAnswerStatusLitsByInterPreterID:(NSNumber *)number {
   // NSString *_urlString = [NSString stringWithFormat:@"http://qa.focusvri.com/api/GetCallAnswerStatusByContactId/%@",number];
    NSString *_urlString = [NSString stringWithFormat:@"http://qa.focusvri.com/api/GetConferenceRoomDetailsByContactId/%@",number];
    NSURL *url = [NSURL URLWithString:_urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    request.userInfo = [NSDictionary dictionaryWithObjects:@[@"GetCallAnswerStatus",number] forKeys:@[@"type",@"InterpreterId"]];
    
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:@"Token" value:[[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
    //[request start];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    // Use when fetching binary data
    NSData *responseData = [request responseData];
    if ([[request.userInfo objectForKey:@"type"] isEqualToString:@"SaveCallAnswerStatus"]) {
        NSLog(@"response = %@",[request responseString]);
        
    } else if ([[request.userInfo objectForKey:@"type"] isEqualToString:@"GetCallAnswerStatus"]) {
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        //NSDictionary *dictionary = [answerStatus firstObject];
        if ([dictionary[@"CallStatusId"] isEqual:@(116)] && [dictionary[@"InterpreterID"] isEqual:request.userInfo[@"InterpreterId"]]) {
            if ([self.avAudioPlayer isPlaying]) {
                [self.avAudioPlayer stop];
            }
            [self.callStatusTimer invalidate];
            self.callStatusTimer = nil;
            [MVRIGlobalData sharedInstance].callStartDate = [NSDate date];
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Video" bundle:nil];
            LogInVC *ooVooLogin = [storyBoard instantiateViewControllerWithIdentifier:@"ooVooVideoIdentifier"];
            [self.navigationController pushViewController:ooVooLogin animated:YES];
        } else if([dictionary[@"CallStatusId"] isEqual:@(115)] && [dictionary[@"InterpreterID"] isEqual:request.userInfo[@"InterpreterId"]]) {
            if ([self.avAudioPlayer isPlaying]) {
                [self.avAudioPlayer stop];
            }
            [self.callStatusTimer invalidate];
            self.callStatusTimer = nil;
        }
        
    } else {
        self.allInterpreters = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
        [self.interPretersTableView reloadData];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"Error Message = %@",[error localizedDescription]);
//    UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Alert" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    [alerView show];
}

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               } else{
                                   completionBlock(NO,nil);
                               }
                           }];
}

#pragma mark - Life Cycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [self navigationBarCustomAppearence];
    self.view.backgroundColor = [UIColor FVRIWhileColor];
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.interPretersTableView registerNib:[UINib nibWithNibName:@"TableHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"TableHeaderView"];
    self.interPretersTableView.sectionHeaderHeight = 193.0;
   // [self.interPretersTableView registerNib:[UINib nibWithNibName:@"TableFooterView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"TableFooterView"];
    //self.interPretersTableView.sectionFooterHeight = 48.0;
    self.interPretersTableView.estimatedRowHeight = 67.0;
    self.interPretersTableView.rowHeight = UITableViewAutomaticDimension;
    self.interPretersTableView.backgroundColor = [UIColor clearColor];
    
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self requestForGetInterpreters];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.avAudioPlayer stop];
    [self.timer invalidate];
    self.timer = nil;
    [self.callStatusTimer invalidate];
    self.callStatusTimer = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Actions

- (IBAction)performMenuButtonAction:(id)sender {
   [self.revealViewController revealToggle:sender];
}

- (IBAction)performSeachButtonAction:(id)sender {
    [self performSegueWithIdentifier:@"searchInterpreter" sender:self];
}

- (void)performVideoCall:(id)sender {
    if ([self.avAudioPlayer isPlaying]) {
        [self.avAudioPlayer stop];
    }
    NSInteger statusID = 0;
//    UIButton *button = (UIButton *)sender;
//    button.selected = !button.selected;
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.interPretersTableView];
    NSIndexPath *indexPath = [self.interPretersTableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        self.selectedIndexPath = indexPath;
    }
    if([sender isSelected]) {
        [sender setSelected:NO];
        self.state = NO;
        statusID = 115;
    } else {
        [sender setSelected:YES];
        self.state = YES;
        statusID = 114;
        [self loadAudioPlayer];
        [self startTimer];
    }
    [self.interPretersTableView reloadData];
    [self requestForSaveCallAnswerStatus:statusID];
    
    
    
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Video Call" message: @"Would you like to start a video call?" delegate: self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
    //    [alert show];
}

- (void)timerFired:(NSTimer *)timer
{
    [self.avAudioPlayer stop];
    [self.timer invalidate];
    self.timer = nil;
    self.selectedIndexPath = nil;
    [self.interPretersTableView reloadData];
}

- (void)checkCallStatus:(NSTimer *)timer {
    [self requestForGetCallAnswerStatusLitsByInterPreterID:self.allInterpreters[self.selectedIndexPath.row][@"ContactID"]];
}

- (void)startTimer {
    self.callStatusTimer = [NSTimer
                            scheduledTimerWithTimeInterval:5
                            target:self selector:@selector(checkCallStatus:)
                            userInfo:nil repeats:YES];
}

- (void)loadAudioPlayer {
    NSString *sound_file;
    if ((sound_file = [[NSBundle mainBundle] pathForResource:@"home_ringtone" ofType:@"mp3"])){
        
        NSURL *url = [[NSURL alloc] initFileURLWithPath:sound_file];
        self.avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        self.avAudioPlayer.delegate = self;
        [self.avAudioPlayer setNumberOfLoops:-1];
        [self.avAudioPlayer prepareToPlay];
        [self.avAudioPlayer play];
        self.timer = [NSTimer
                      scheduledTimerWithTimeInterval:60
                      target:self selector:@selector(timerFired:)
                      userInfo:nil repeats:YES];
        
    }
}


#pragma mark - AVAudioPalyer Delegates

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
}
-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
}
-(void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
}
-(void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
}

#pragma mark - uialertview Delegate functions
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
        if (buttonIndex == 0) {
            NSLog(@"user pressed Cancel");
        } else {
            NSLog(@"user pressed OK");
//            NSString *conferenceid = [NSString stringWithFormat:@"%@",self.allInterpreters[self.selectedIndexPath.row][@"ContactID"]];
//            NSString *clientName = [NSString stringWithFormat:@"%@ %@",self.allInterpreters[self.selectedIndexPath.row][@"FirstName"],self.allInterpreters[self.selectedIndexPath.row][@"LastName"]];
//            [self showActivityIndicator];
//            self.participantsController = [[ParticipantsController alloc] init];
//            self.logsController = [[LogsController alloc] init];
//            self.logsController.participantsController = self.participantsController;
//            
//            [[ooVooController sharedController] joinConference:conferenceid
//                                              applicationToken:@"MDAxMDAxAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAClOUOFcujXSpQMqu8VxcjVSQiN5w2RoFvfqV3Yak8Lzcn9+WSsfvUjJ7NzERzuQxNcSbVwy6uauJzSjahmUn68mdElPV0QqbXlRNQ62zb+s967W7J1G3BB9JQDJ+twmPc="
//                                                 applicationId:@"2113043454"
//                                               participantInfo:clientName];
//
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Video" bundle:nil];
            LogInVC *ooVooLogin = [storyBoard instantiateViewControllerWithIdentifier:@"ooVooVideoIdentifier"];
            [self.navigationController pushViewController:ooVooLogin animated:YES];
        }
}

#pragma mark - Tableview Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allInterpreters.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MVRIInterPretersTableViewCell *cell = (MVRIInterPretersTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"interpretersIdentifier"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MVRIInterPretersTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.interpreterNameLabel.text = [NSString stringWithFormat:@"%@ %@",self.allInterpreters[indexPath.row][@"FirstName"],self.allInterpreters[indexPath.row][@"LastName"]];
    cell.statusLabel.text = @"Video Agent";
    [self downloadImageWithURL:[NSURL URLWithString:self.allInterpreters[indexPath.row][@"ImageUrl"]] completionBlock:^(BOOL succeeded, UIImage *image) {
        cell.avatharImageView.image = image;
    }];
    if ([indexPath isEqual:self.selectedIndexPath] && self.state) {
        cell.callButton.selected = YES;
    } else {
        cell.callButton.selected = NO;
    }
    [cell.callButton addTarget:self action:@selector(performVideoCall:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

#pragma mark - TableView Delegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        TableHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"TableHeaderView"];
        NSURL *imageURL = [NSURL URLWithString:@"http://qa.focusvri.com/ContactImage/1/profile1.png"];
        [self downloadImageWithURL:imageURL completionBlock:^(BOOL succeeded, UIImage *image) {
            if (succeeded) {
                // change the image in the cell
                header.avatarImageView.image = image;
            }
        }];
        header.descriptionLabel.text = [NSString stringWithFormat:@"%ld Interpreters matching %@ / %@",(unsigned long)self.allInterpreters.count,[MVRIGlobalData sharedInstance].languageDictionary[@"Value"],[MVRIGlobalData sharedInstance].skillDictionary[@"Value"]];
        return header;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 193.0f;
}

/*
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
        TableFooterView *footer = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"TableFooterView"];
        footer.footerViewDescriptionLabel.text = [NSString stringWithFormat:@"Call first available interpreter"];
        footer.footerViewDescriptionLabel.textColor = [UIColor whiteColor];
        //footer.footerViewTotalAmountLabel.font = [UIFont TTTableViewFooterFont];
        return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 48.0f;
}*/


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
