//
//  VideoPanelWithLabel.h
//  ooVooSdkSampleShow
//
//  Created by Udi on 4/6/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import <ooVooSDK/ooVooSDK.h>

@protocol UserVideoPanelDELEGATE;


@interface UserVideoPanel : ooVooVideoPanel <UIGestureRecognizerDelegate> {
    UILabel *lblUserName;
    UIImageView *imgView;
    UILabel *lblVideoAlert;
    
}

@property (nonatomic, strong) NSString *strUserId;
@property (nonatomic,weak)id<UserVideoPanelDELEGATE>delegate;
@property (assign) bool isAllowedToChangeImage;

- (instancetype)initWithFrame:(CGRect)frame WithName:(NSString *)strUserName;
-(void)showAvatar:(bool)show;
-(void)showVideoAlert:(bool)show;
-(void)animateImageFrame:(CGRect)frame;

@end

@protocol UserVideoPanelDELEGATE <NSObject>

-(void)UserVideoPanel_Touched:(UserVideoPanel*)videoPanel;


@end

