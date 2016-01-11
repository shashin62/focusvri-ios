//
//  MVRIConferenceViewController.h
//  MVRI
//
//  Created by mac on 12/26/13.
//  Copyright (c) 2013 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "ConferenceViewController.h"
#import "ParticipantsController.h"
#import "LogsController.h"

@interface MVRIConferenceViewController : UIViewController <ParticipantsControllerDelegate,UICollectionViewDataSource, UICollectionViewDelegate, UITextViewDelegate>{
	
}


@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIView *confVCHolder, *buttonHolder, *datePickerHolder;
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;


@property (nonatomic, strong) ParticipantsController *participantsController;
@property (nonatomic, strong) LogsController *logsController;
@property (nonatomic, copy) NSString *conferenceId;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *viewScrollViewBott, *viewCollViewBtw;
@property (nonatomic, strong) IBOutlet UITextView *details;
@property (nonatomic, strong) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, assign) BOOL isDatePickerVisible;
@property (nonatomic, strong) NSString *selectedDate;
@property (nonatomic, strong) IBOutlet UIButton *setDateButton, *leaveButton, *resButton, *saveButton, *doneButton, *speakerButton, *micButton, *cameraButton;


@property (nonatomic, strong) IBOutlet UIButton *TopLeftArrowButton, *BottomLeftArrowButton, *BottomRightArrowButton, *TopRightArrowButton;


@property (nonatomic, copy) NSString *apptId;

-(void) setConfParameters;

- (IBAction)MoveToTopLeftArrow:(id)sender;
- (IBAction)MoveToBottomLeftArrow:(id)sender;
- (IBAction)MoveToBottomRightArrow:(id)sender;
- (IBAction)MoveToTopRightArrow:(id)sender;


- (IBAction)resButtonPressed:(id)sender;
- (IBAction)endCallButtonPressed:(id)sender;
- (IBAction)submitButtonPressed:(id)sender;
- (IBAction)saveButtonPressed:(id)sender;
- (IBAction)setFollowupDatePressed:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)muteMicPressed:(id)sender;
- (IBAction)muteSpeakerPressed:(id)sender;
- (IBAction)cameraPressed:(id)sender;


@end
