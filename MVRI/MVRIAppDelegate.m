//
//  MVRIAppDelegate.m
//  MVRI
//
//  Created by mac on 11/9/13.
//  Copyright (c) 2013 mac. All rights reserved.
//

#import "MVRIAppDelegate.h"
#import <ooVooSDK/ooVooSDK.h>
#import "UserDefaults.h"
#import "SettingBundle.h"
#define User_isInVideoView @"User_isInVideoView"



#define APP_TOKEN_SETTINGS_KEY    @"APP_TOKEN_SETTINGS_KEY"
#define LOG_LEVEL_SETTINGS_KEY    @"LOG_LEVEL_SETTINGS_KEY"

@interface MVRIAppDelegate ()
{
    BOOL cameraWasStoppedByEnteringBackground;
}
@end


@implementation MVRIAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [UserDefaults setBool:NO ToKey:User_isInVideoView];
    
    [self setupConnectionParameters];
    [self navigationBarCustomAppearence];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    ooVooClient *sdk = [ooVooClient sharedInstance];
    [sdk.AVChat.VideoController stopTransmitVideo];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    ooVooClient *sdk = [ooVooClient sharedInstance];
    [sdk.AVChat.VideoController startTransmitVideo];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


/*- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeLeft;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return (UIInterfaceOrientationMaskLandscape);
}*/

/*- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    //NSLog(@"PlayWithWSWithLibAppDelegate -- supportedInterfaceOrientationsForWindow");
    if([UICommonUtils isiPad]){
        return UIInterfaceOrientationMaskAll;
    }else if(flagOrientationAll == YES){
        return UIInterfaceOrientationMaskAll;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape;
}
*/

- (void)navigationBarCustomAppearence {
    
    [UINavigationBar appearance].barTintColor = [UIColor FVRIWhileColor];

//    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    [UINavigationBar appearance].translucent = NO;
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor blackColor],
      NSForegroundColorAttributeName,
      nil]];
}


#pragma mark - Configuration
- (void)setupConnectionParameters
{
    NSDictionary *curParameters =
    @{
      APP_TOKEN_SETTINGS_KEY   : [[SettingBundle sharedSetting] getSettingForKey:@"settingBundle_AppToken"],
      LOG_LEVEL_SETTINGS_KEY   : [[SettingBundle sharedSetting] getSettingForKey:@"settingBundle_SDK_LogLevel"]
      };
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:curParameters];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *curAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:APP_TOKEN_SETTINGS_KEY];
    NSInteger curLogLevel = [[NSUserDefaults standardUserDefaults]  integerForKey:LOG_LEVEL_SETTINGS_KEY];
    
    NSString *appToken = curAppToken;
    NSNumber *logLevel = [NSNumber numberWithInt:(int)curLogLevel];
    
    [[SettingBundle sharedSetting] setSettingKey:@"settingBundle_AppToken" WithValue:appToken];
    [[SettingBundle sharedSetting] setSettingKey:@"settingBundle_SDK_LogLevel" WithValue:[logLevel stringValue]];
    
    [[NSUserDefaults standardUserDefaults] setValue:appToken forKey:APP_TOKEN_SETTINGS_KEY];
    [[NSUserDefaults standardUserDefaults] setValue:logLevel forKey:LOG_LEVEL_SETTINGS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

@end
