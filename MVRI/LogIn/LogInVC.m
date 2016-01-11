//
//  LogInVC.m
//  ooVooSdkSampleShow
//
//  Created by Udi on 3/30/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import "LogInVC.h"
#import "UIView-Extensions.h"
#import "ActiveUserManager.h"
#import "UserDefaults.h"
#import "SettingBundle.h"
#import "FileLogger.h"

#define User_isInVideoView @"User_isInVideoView"

#define Segue_Authorization @"ToAuthorizationView"
#define Segue_PushTo_ConferenceVC @"ConferenceVC"

#define UserDefault_UserId @"UserID"
#define Segue_VideoConference @"Segue_VideoConferenceVC"


@interface LogInVC () {
  
    __weak IBOutlet UIActivityIndicatorView *spinner;
    NSString *oovooUserID;
}

@end

@implementation LogInVC

- (NSMutableArray *)getRandomNumberforSpecificDigits:(NSInteger)digit {
    NSMutableArray *uniqueNumbers = [[NSMutableArray alloc] init];
    int r;
    while ([uniqueNumbers count] < digit) {
        r = arc4random() % digit; // ADD 1 TO GET NUMBERS BETWEEN 1 AND M RATHER THAN 0 and M-1
        if (![uniqueNumbers containsObject:[NSNumber numberWithInt:r]]) {
            [uniqueNumbers addObject:[NSNumber numberWithInt:r]];
        }
    }
    return uniqueNumbers;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    //oovooUserID = @"123456";
    oovooUserID = [[self getRandomNumberforSpecificDigits:6]componentsJoinedByString:@""];;

    self.sdk = [ooVooClient sharedInstance];
    self.sdk.Account.delegate = self;
    self.sdk.AVChat.delegate = self;
    int logLevel = [[[SettingBundle sharedSetting] getSettingForKey:@"settingBundle_SDK_LogLevel"]intValue];
    [ooVooClient setLogLevel:logLevel];
    
    //[ooVooClient setLogLevel:LogLevelTrace];
    [ooVooClient setLogger:self];
    [self autorize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)autorize {
    NSString *token = [[SettingBundle sharedSetting] getSettingForKey:@"settingBundle_AppToken"];
    [spinner startAnimating];
    [self.sdk authorizeClient:token
                   completion:^(SdkResult *result) {
                       if (result) {
                           NSLog(@"good autorization");
                           // animate autorization view move in login view
                           
                           // just for showing the spinner for sasha
                           [self loginWithUserID];
                       } else {
                           
                           NSLog(@"fail  autorization");
                        double delayInSeconds = 0.75;
                           dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                           dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                               
                               [[[UIAlertView alloc] initWithTitle:@"FocusVRI"
                                                           message:[NSString stringWithFormat:NSLocalizedString(@"Error: %@", nil), @"App Token probably invalid or might be empty.\n\nGet your App Token at http://developer.oovoo.com.\nGo to Settings->ooVooSample screen and set the values, or set @APP_TOKEN constants in code."]
                                                          delegate:nil
                                                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                 otherButtonTitles:nil] show];
                           });
                           //[_spinner stopAnimating];
                           
                       }

                   }];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
    [super viewWillAppear:animated];
    //self.navigationItem.title = @"Login";
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}


#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:Segue_Authorization]) {
        if ([UserDefaults getBoolForToKey:User_isInVideoView]) {
            [self performSegueWithIdentifier:Segue_PushTo_ConferenceVC sender:nil];
            return NO;
        }
    }
    return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    if ([segue.identifier isEqualToString:Segue_Authorization]) {
//        AuthorizationLoaderVc *authoVC = segue.destinationViewController;
//        authoVC.delegate = self;
    }
}

#pragma mark - IBAction

- (void)loginWithUserID {
    
    if ([self isUserIdEmpty])
        return;
    [UserDefaults setObject:oovooUserID ForKey:UserDefault_UserId];
    
    
    [self.sdk.Account login:oovooUserID
                 completion:^(SdkResult *result) {
                     NSLog(@"result code=%d result description %@", result.Result, result.description);
                     [spinner stopAnimating];
                     if (result.Result){
                         [[[UIAlertView alloc] initWithTitle:@"Login Error" message:result.description delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
                     }
                     else
                         [self onLogin:result.Result];
                 }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self loginWithUserID];
}


#pragma mark - private methods

- (BOOL)isUserIdEmpty {

    // removing white space from start and end
    if ([[oovooUserID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"UserId Missing" message:@"Please enter userId " delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];

        return true;
    }

    if (oovooUserID.length < 6) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Characters Missing" message:@"UserId Must contain at least 6 characters " delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];

        return true;
    }

    return false;
}


- (void)onLogin:(BOOL)error {
    if (!error) {
        [ActiveUserManager activeUser].userId = oovooUserID;
        //[self performSegueWithIdentifier:Segue_PushTo_ConferenceVC sender:nil];
        [self performSegueWithIdentifier:Segue_VideoConference sender:nil];
    }else{
        //[self.loginButton setEnabled:true];
    }

    //
    //    [self.sdk.AVChat.VideoController bindVideoRender:self.userId render:self.videoView];
    //
    //    [self.sdk.AVChat.VideoController openCamera];
    //    self.btn_JoinConference.hidden   = NO ;
    //    self.txt_userId.text = @"" ;
}

- (NSString *)randomUser {
    
    if ([UserDefaults getObjectforKey:UserDefault_UserId]) {
        return [UserDefaults getObjectforKey:UserDefault_UserId];
    }
    
//    
//    uint32_t num = 6;
//    NSMutableString *string = [NSMutableString stringWithCapacity:num];
//
//    [string appendFormat:@"%@_", [[UIDevice currentDevice] name]];
//    for (int i = 0; i < num; i++) {
//        [string appendFormat:@"%C", (unichar)('a' + arc4random_uniform(25))];
//    }
    return @"";
}

#pragma mark - ooVoo Account delegate

- (void)didAccountLogIn:(id<ooVooAccount>)account {
    
}
- (void)didAccountLogOut:(id<ooVooAccount>)account {
    
}

- (void)onLog:(LogLevel)level log:(NSString *)log {
    [[FileLogger sharedInstance] log:level message:log];
}


@end
