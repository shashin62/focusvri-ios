//
//  MVRIInterPreterViewController.h
//  MVRI
//
//  Created by Murali Gorantla on 16/08/15.
//  Copyright (c) 2015 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface MVRIInterPreterViewController : UIViewController <AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;

@property (weak, nonatomic) IBOutlet UIButton *menuButton;
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIButton *callDisConnectButton;

@property (weak, nonatomic) IBOutlet UITableView *callDetailsTableView;

//@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;


@property (nonatomic, strong) AVAudioPlayer* avAudioPlayer;

- (IBAction)performMenuButtonAction:(id)sender;

- (IBAction)performChangeAvailability:(id)sender;
- (IBAction)call:(id)sender;

- (IBAction)segmentClicked:(id)sender;

@end
