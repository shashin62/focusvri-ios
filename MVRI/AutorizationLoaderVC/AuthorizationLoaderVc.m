//
//  AutorizationLoaderVc.m
//  ooVooSdkSampleShow
//
//  Created by Udi on 3/30/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import "AuthorizationLoaderVc.h"
#import "SettingBundle.h"
#import "FileLogger.h"

static NSString * const FOCUSVRIAPPTOKEN = @"MDAxMDAxAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD6dksiFYCuO5gnzelHYQMSctCH4GXen%2F44tKL5hlSY26oZLjvYYtJjNYInR73kvcUZ6YADfXSig8xLTmzC06%2FW0G%2B62GKr8xttn%2BkgzuU%2BXm0kXov8qGUdFmTtmhBhBQ%2F%2FeSN1HkVndI8vMwnshrVG"
;
@interface AuthorizationLoaderVc ()
{

}
- (void)autorize;
- (void)onAutorize:(BOOL)error;
@end

@implementation AuthorizationLoaderVc

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.sdk = [ooVooClient sharedInstance];
    self.sdk.AVChat.delegate = self;
    NSLog(@"SdkLog %@",[[SettingBundle sharedSetting] getSettingForKey:@"settingBundle_SDK_LogLevel"]);
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

#pragma mark - Authorization ...

- (void)autorize {
    NSString* token = [[SettingBundle sharedSetting] getSettingForKey:@"settingBundle_AppToken"];
    NSLog(@"Token %@",token);

    [self.sdk authorizeClient:token
                   completion:^(SdkResult *result) {
                       [self onAutorize:result.Result == 0];
                   }];
}

- (void)onAutorize:(BOOL)result {

    //  self.btn_JoinConference.hidden   = NO          ;
    if (result) {
        NSLog(@"good autorization");
        // animate autorization view move in login view

        // just for showing the spinner for sasha
        sleep(0.5);

        [_delegate AuthorizationDelegate_DidAuthorized];

    } else {

        NSLog(@"fail  autorization");
        self.btn_Authorizate.hidden = false;
        self.lbl_Status.font=[UIFont systemFontOfSize:13];
        self.lbl_Status.text = @"Authorization Failed.";

        double delayInSeconds = 0.75;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

            [[[UIAlertView alloc] initWithTitle:@"Failure"
                                        message:[NSString stringWithFormat:NSLocalizedString(@"Error: %@", nil), @"App Token probably invalid or might be empty."]
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                              otherButtonTitles:nil] show];
        });
        [_spinner stopAnimating];

    }
}

#pragma mark - IBActions

- (IBAction)act_Authorizate:(id)sender {

    self.lbl_Status.font = [UIFont systemFontOfSize:17];
    _lbl_Status.text = @"Authorization ....  ";
    self.btn_Authorizate.hidden = true;
    [self autorize];
}

- (void)onLog:(LogLevel)level log:(NSString *)log {
    [[FileLogger sharedInstance] log:level message:log];
}

@end
