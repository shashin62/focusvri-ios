//
//  VideoConferenceVC.h
//  ooVooSample
//
//  Created by Udi on 8/2/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>
#import <ooVooSDK/ooVooSDK.h>

#import "UserVideoPanel.h"
#import "CustomToolbarVC.h"

//#import <YapPlugin/YapPlugin.h>


@interface VideoConferenceVC : UIViewController <ooVooAVChatDelegate, ooVooVideoControllerDelegate, UITextFieldDelegate>

@property (retain, nonatomic) ooVooClient *sdk;
@property (weak, nonatomic) IBOutlet UIScrollView *viewScroll;
@property (nonatomic, retain) UIPageControl* pageControl;

//@property (weak,nonatomic)  NSString *currentEffect;
@property (weak, nonatomic) IBOutlet UIView *viewTextBox;

@property (weak, nonatomic) IBOutlet UITextField *txt_conferenceId;

@property (weak, nonatomic) IBOutlet UILabel *lbl_error;
//@property (weak, nonatomic) IBOutlet UIButton *btn_JoinConference;

@property (nonatomic, retain) UserVideoPanel *previewPanel;

@property (retain, nonatomic) IBOutlet UserVideoPanel *videoPanelView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrainTopViewVideo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrainRightViewVideo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrainBottomViewVideo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrainLeftViewVideo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contrainTopViewText;

@property (weak, nonatomic) IBOutlet UIView *viewForVideoSizeAdjest;
@property (weak, nonatomic) IBOutlet UILabel *lblSdkVersion;


@property (atomic, assign) BOOL isLoggedIn;
@property (atomic, retain) NSMutableDictionary *videoPanels;
@property (atomic, retain) NSMutableDictionary *ParticipentShowOrHide;
@property (nonatomic, retain) NSString *defaultCameraId;

@property (weak, nonatomic) IBOutlet UIView *viewCustomTollbar_container; // container
@property (assign) bool isViewInTransmitMode;  // Flag to know if we are transmiting this user video.


- (IBAction)user_id_touch:(id)sender;

+ (NSString*)getErrorDescription:(sdk_error)code;
- (IBAction)act_joinConference:(id)sender;
- (void)animateViewsForState:(BOOL)state;

@property (weak, nonatomic) IBOutlet UIButton *topLeftBtn;
@property (weak, nonatomic) IBOutlet UIButton *topRightBtn;
@property (weak, nonatomic) IBOutlet UIButton *bottomLeftBtn;
@property (weak, nonatomic) IBOutlet UIButton *bottomRightBtn;

- (IBAction)MoveToTopLeftArrow:(id)sender;
- (IBAction)MoveToBottomLeftArrow:(id)sender;
- (IBAction)MoveToBottomRightArrow:(id)sender;
- (IBAction)MoveToTopRightArrow:(id)sender;



@end

