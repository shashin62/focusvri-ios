//
//  LogInVC.h
//  ooVooSdkSampleShow
//
//  Created by Udi on 3/30/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ooVooSDK/ooVooSDK.h>

@interface LogInVC : UIViewController <ooVooAccount,ooVooClientLogger,ooVooAVChatDelegate>

@property (retain, nonatomic) ooVooClient *sdk;

@end
