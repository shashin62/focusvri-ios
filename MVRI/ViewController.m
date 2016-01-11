
#include <sys/sysctl.h>

#import <ooVooSDK/ooVooSDK.h>

#import "ViewController.h"
#import "UIView-Extensions.h"
#import "ActiveUserManager.h"
#import "UserDefaults.h"
#import "InfoViewController.h"
#import "EffectSampleFactoryIOS.h"
#import "UIActionSheet+Extensions.h"
#import "TableListVC.h"

#import "InternetActivityVC.h"
#import "MVRICallActivityTableViewController.h"

#define kUserId @"kUserId"
#define Segue_ToCustomToolBar @"ToCustomToolBar"
#define UserDefaults_ConferenceId @"ConferenceID"
#define Segue_Info @"Segue_Info"
#define Segue_EffectList @"Segue_EffectList"

#define User_isInVideoView @"User_isInVideoView"
#define String_Empty @""

#define space 4

@interface ViewController () <CustomToolBarVC_DELEGATE, UIActionSheetDelegate,UserVideoPanelDELEGATE,InfoViewController_DELEGATE,TableList_DELEGATE> {
    
    
    NSMutableArray *arrDefultConstrain;
    NSMutableArray *arrBackupConstrain;
    
    __weak IBOutlet UIActivityIndicatorView *spinner;
    
    bool isViewInTransmitMode;
    bool isCameraStateOn;
    CustomToolbarVC *toolBar;
    NSString * defaultRes;
    NSString * currentRes;
    NSMutableArray *arrTakenSlot;
    NSMutableDictionary *ParticipentState;
    InfoViewController *infoVC;
    InternetActivityVC *InternetActivityView;
    NSArray *arrEffectList;
    NSMutableDictionary *resolutionsHeaders;
    NSMutableDictionary *participants;

    UserVideoPanel *currentFullScreenPanel;
    
    NSString *conferenceID;
    
}
- (void)clear_error;
- (void)show_error:(NSString *)error;
- (void)setVisibleOfJoinPage:(BOOL)state;
- (NSString *)randomUser;


@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    UIImage *img = [UIImage imageNamed:@"focus"];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
    [imgView setImage:img];
    [imgView setContentMode:UIViewContentModeScaleAspectFit];
    self.navigationItem.titleView = imgView;
    [self initFirstInitialize];     // UI and first settings ....
    [self initSDKInitializer];      // SDK init and settings
    [self initConferenceTextField]; // set the conference id if was set by the user before .
    /*Murali Commented
    [self setBackButton];           // set the back button selector.
    
     [self setNavigationBarProfileButtonShow:NO]; // shows the join Button .*/
     self.defaultCameraId = [self.sdk.AVChat.VideoController getConfig:ooVooVideoControllerConfigKeyCaptureDeviceId];
     currentRes = defaultRes = [self.sdk.AVChat.VideoController getConfig:ooVooVideoControllerConfigKeyResolution];
    
    //[ActiveUserManager activeUser].userId = @"123456";
    conferenceID = [NSString stringWithFormat:@"%@",[MVRIGlobalData sharedInstance].conferenceID];
    
    //conferenceID = @"1234567890";
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [UserDefaults setBool:NO ToKey:User_isInVideoView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self isIpad])
        [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
        if ([self isIpad])
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [UserDefaults setBool:YES ToKey:User_isInVideoView];
  //  self.btn_JoinConference.hidden = NO;
    [self saveMaxFrameSize];
    infoVC=nil;
    [self act_joinConference:nil];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
}

- (BOOL)shouldAutorotate {
    return NO;
}


// Works or ipad only !
- (void)orientationChanged:(NSNotification *)notification{

    if (!isViewInTransmitMode) {
        return;
    }
    
 NSLock  *theLock=[NSLock new] ;
    
    [theLock lock];
    
    [self animateViewsForState:true];
    [self animateViewsForState:false];
    
    for (int i=1 ; i<[arrTakenSlot count]; i++) {
        if (![arrTakenSlot[i]isEqualToString:String_Empty]) {
            UserVideoPanel *panel = self.videoPanels[arrTakenSlot[i]];
            [self setPanel:panel inPosition:i Animated:NO];
        }
    }
    

    
    if (self.navigationItem.rightBarButtonItems) {
        [self setNavigationBarProfileButtonShow:YES];

    }
       [theLock unlock];

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)dealloc {
    NSLog(@"Dealloc Conference Creator");
     [_videoPanelView removeFromSuperview];
    arrDefultConstrain = nil;
    arrBackupConstrain = nil;
    spinner=nil;
    toolBar=nil;
    currentRes=nil;
    
    arrTakenSlot=nil;
    ParticipentState=nil;
    infoVC=nil;
    InternetActivityView=nil;
    arrEffectList=nil;
    currentFullScreenPanel=nil;
    
    _videoPanelView=nil;
    _videoPanels=nil;
    _ParticipentShowOrHide=nil;
 //   alertController=nil;
}

-(void)removeDelegates{
    self.sdk.AVChat.delegate = nil;
    self.sdk.AVChat.VideoController.delegate = nil;
    self.videoPanelView.delegate=nil;
    infoVC.delegate=nil;
    toolBar.delgate = nil;
}

- (void)requestForSaveCallHistory {
    NSString *_urlString = [NSString stringWithFormat:@"http://qa.focusvri.com/api/SaveCallAnswerStatus?"];
    NSURL *url = [NSURL URLWithString:_urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    request.userInfo = [NSDictionary dictionaryWithObject:@"SaveCallAnswerStatus" forKey:@"type"];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Token" value:[[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    NSDictionary *jsonDictionary = @{
                                     @"ConferenceId" : @([[MVRIGlobalData sharedInstance].userID integerValue]),
                                     @"CallAnswerStatusId" : @115,
                                     @"InterpreterId": @([[MVRIGlobalData sharedInstance].getInterPreterIDWhenClaimantcalled integerValue])
                                     };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    
    [request appendPostData:jsonData];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)requestForSaveCallAnswerStatus {
    NSString *_urlString = [NSString stringWithFormat:@"http://qa.focusvri.com/api/SaveActivity?"];
    NSURL *url = [NSURL URLWithString:_urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    request.userInfo = [NSDictionary dictionaryWithObject:@"SaveCallHistory" forKey:@"type"];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Token" value:[[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm:ss"];
    NSTimeZone *utc = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    [df setTimeZone:utc];
    NSString *startTime = [df stringFromDate:[MVRIGlobalData sharedInstance].callStartDate];
    NSString *endTime = [df stringFromDate:[NSDate date]];
    NSDictionary *jsonDictionary = @{
                                     
                                     @"StartTime" : startTime,
                                     @"Endtime":endTime,
                                     @"ClientContactID":@([[MVRIGlobalData sharedInstance].conferenceID integerValue]),
                                     @"InterpreterContactID":@([[MVRIGlobalData sharedInstance].userID integerValue])
                                     };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    
    [request appendPostData:jsonData];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    // Use when fetching binary data
    //NSData *responseData = [request responseData];
    if ([[request.userInfo objectForKey:@"type"] isEqualToString:@"SaveCallAnswerStatus"]) {
        [self checkAndGoBack];// Murali Added
    } else if ([[request.userInfo objectForKey:@"type"] isEqualToString:@"SaveCallHistory"]) {
        NSLog(@"SaveCallHistory response = %@",[request responseString]);
    }
}

#pragma mark - Private Methods

- (void)initFirstInitialize {

    participants = [NSMutableDictionary new];

    [self initResolutionHeaders];
    [self resetArraySlots];
    
    isViewInTransmitMode = NO;
    isCameraStateOn = NO;
    self.isLoggedIn = NO;

    self.lbl_error.hidden = YES;
    
    self.videoPanels = [NSMutableDictionary new];
    [self.videoPanels setObject:self.videoPanelView forKey:[ActiveUserManager activeUser].userId];
    
    self.ParticipentShowOrHide=[NSMutableDictionary new];
    ParticipentState=[NSMutableDictionary new];
    
    self.videoPanelView.strUserId = @"Me";
    self.viewCustomTollbar_container.hidden = true;
    
    rectMaxSize=self.videoPanelView.frame;
    
    _lblSdkVersion.text =    [ooVooClient getSdkVersion];
    
}

- (void)initSDKInitializer {
  
    self.sdk = [ooVooClient sharedInstance];
    self.sdk.AVChat.delegate = self;
    self.sdk.AVChat.VideoController.delegate = self;
    
    self.videoPanelView.delegate=self;
    currentRes = [self.sdk.AVChat.VideoController getConfig:ooVooVideoControllerConfigKeyResolution];
    
    PluginWrapper* pl_wrapper = [[PluginWrapper alloc] init ];
    [self.sdk.AVChat registerPlugin: pl_wrapper];
//    [self.sdk.AVChat.VideoController bindVideoRender:nil/*[ActiveUserManager activeUser].userId*/ render:self.videoPanelView];
    [self.sdk.AVChat.VideoController bindVideoRender:[ActiveUserManager activeUser].userId render:self.videoPanelView];
    [self.sdk.AVChat.VideoController openCamera];
    
    arrEffectList = [self.sdk.AVChat.VideoController getEffectsList];
}

- (void)initResolutionHeaders {
    resolutionsHeaders = [NSMutableDictionary new];
    [resolutionsHeaders setObject:@"Not Specified" forKey:[NSNumber numberWithInt:0]];
    [resolutionsHeaders setObject:@"Low" forKey:[NSNumber numberWithInt:1]];
    [resolutionsHeaders setObject:@"Medium" forKey:[NSNumber numberWithInt:2]];
    [resolutionsHeaders setObject:@"High" forKey:[NSNumber numberWithInt:3]];
    [resolutionsHeaders setObject:@"HD" forKey:[NSNumber numberWithInt:4]];
}



- (void)setBackButton {
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(checkAndGoBack)];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = item;
}

- (void)checkAndGoBack {
    
    if (!isViewInTransmitMode) {
        
        [self.sdk.AVChat.VideoController closeCamera];
        [self removeDelegates];
        [self.sdk.AVChat leave];
        [self.sdk.Account logout];
        
        if ([[MVRIGlobalData sharedInstance].UsrRole  isEqual: @4]) {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
            MVRICallActivityTableViewController *callActivity = [storyBoard instantiateViewControllerWithIdentifier:@"callActivityController"];
            [self.navigationController pushViewController:callActivity animated:YES];
        } else {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
    else {
        
        [self onHangUp:nil];
    }
}

- (void)setNavigationBarProfileButtonShow:(BOOL)show {
    
    if (!show) {
        self.navigationItem.rightBarButtonItems=nil ;
        
        UIBarButtonItem *btnJoin = [[UIBarButtonItem alloc] initWithTitle:@"Join" style:UIBarButtonItemStylePlain target:self action:@selector(act_joinConference:)];
        
        self.navigationItem.rightBarButtonItem=btnJoin;
        return;
    }
    
    // want's to show
    
    UIBarButtonItem *btnEditUserInfo = [[UIBarButtonItem alloc] initWithTitle:@"Info" style:UIBarButtonItemStylePlain target:self action:@selector(pushToEditUserInfo)];
    btnEditUserInfo.tag =100;

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Video" bundle:nil];
    
    int score=-1;
    if (InternetActivityView) {
       score = InternetActivityView.score;
    }
    
    
    InternetActivityView=nil;
        InternetActivityView = [storyboard instantiateViewControllerWithIdentifier:@"InternetActivityVC"];
        InternetActivityView.view.frame=CGRectMake(0, 0, 26, 25);
        InternetActivityView.view.backgroundColor=[UIColor clearColor];
  
    if (score>0)
        [InternetActivityView setInternetActivityLevel:[NSNumber numberWithInt:score]];
    
    UIBarButtonItem *btnInternetConnection = [[UIBarButtonItem alloc] initWithCustomView:InternetActivityView.view];
    self.navigationItem.rightBarButtonItems = @[ btnEditUserInfo, /* fixedSpaceBarButtonItem,  */ btnInternetConnection];
    
}

- (void)initConferenceTextField {
    if ([UserDefaults getObjectforKey:UserDefaults_ConferenceId]) {
        //_txt_conferenceId.text = [UserDefaults getObjectforKey:UserDefaults_ConferenceId];
    }
}


-(NSString *)currentEffect{
    NSLog(@"current effect %@",[self.sdk.AVChat.VideoController getConfig:ooVooVideoControllerConfigKeyEffectId]);
    return [self.sdk.AVChat.VideoController getConfig:ooVooVideoControllerConfigKeyEffectId];
}

#pragma mark Panel Slots

-(int)getSelectedUidIndex:(NSString*)uid{
    for (int i=0; i<[arrTakenSlot count]; i++) {
        if ([arrTakenSlot[i]isEqualToString:uid]) {
            return i;
        }
        
    }
    return 0; // will not reach here
}

-(int)getFirstemptySlot{
    for (int i=0; i<[arrTakenSlot count]; i++) {
        if ([arrTakenSlot[i]isEqualToString:String_Empty]) {
            return i;
        }
        
    }
    return 0; // will not reach here
}

-(void)resetArraySlots{
    arrTakenSlot=[[NSMutableArray alloc]initWithObjects:[ActiveUserManager activeUser].userId,String_Empty,String_Empty,String_Empty, nil];
}


#pragma mark spinner

- (void)showAndRunSpinner:(BOOL)wait {
    if (wait) {
        [spinner startAnimating];
        [self setJoinButtonEnable:false];

    } else {
        [spinner stopAnimating];
        [self setJoinButtonEnable:true];

    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqual:Segue_ToCustomToolBar]) {
        toolBar = segue.destinationViewController;
        toolBar.delgate = self;
    }
    
    if ([segue.identifier isEqual:Segue_Info]) {
        infoVC = segue.destinationViewController;
        if (!infoVC.delegate) {
            infoVC.delegate=self;
        }
        infoVC.arrParticipants = [self getParticipantsNameList];
//        infoVC.strConferenceId = _txt_conferenceId.text;
        infoVC.strConferenceId = conferenceID;
    }
    
    if ([segue.identifier isEqual:Segue_EffectList]) {
        TableListVC *tableVC=segue.destinationViewController;
        tableVC.delegate=self;
        tableVC.arrList=(NSArray*)sender;
        
        for (int i=0; i<[arrEffectList count]; i++) {
            id<ooVooEffect> effect = arrEffectList[i];
            if ([effect.effectID isEqualToString:[self currentEffect]]) {
                tableVC.selectedIndex=i;
                return;
            }
        } //for
        tableVC.selectedIndex=0;
    }
}

- (void)pushToEditUserInfo {
    
    [self performSegueWithIdentifier:Segue_Info sender:nil]; // add participants
}

#pragma mark - IBAction

-(void)setJoinButtonEnable:(BOOL)enable{
    UIBarButtonItem *btn=self.navigationItem.rightBarButtonItem;
    btn.enabled=enable;

}

- (IBAction)act_joinConference:(id)sender {
    
    [self.view endEditing:YES];
    [self showAndRunSpinner:YES];
    
    //[UserDefaults setObject:_txt_conferenceId.text ForKey:UserDefaults_ConferenceId];
    // Here conference ID is User ID
    [UserDefaults setObject:conferenceID ForKey:UserDefaults_ConferenceId];
    [self clear_error];
    
    
    [self setJoinButtonEnable:false];
   
    
    [self.sdk.AVChat.AudioController initAudio:^(SdkResult *result) {
        [self.sdk.AVChat.VideoController setConfig:currentRes forKey:ooVooVideoControllerConfigKeyResolution];
        
        if([self currentEffect])
            [self.sdk.AVChat.VideoController setConfig:[self currentEffect] forKey:ooVooVideoControllerConfigKeyEffectId];
        
        NSLog(@"result %d description %@ ", result.Result, result.description);
        
        [self.sdk updateConfig:^(SdkResult *result){
            //[self.sdk.AVChat join:self.txt_conferenceId.text user_data:self.txtDisplayName.text];
            [self.sdk.AVChat join:conferenceID user_data:[MVRIGlobalData sharedInstance].Firstname];
        }];
    }];
}

- (IBAction)user_id_touch:(id)sender {
    [self clear_error];
}

#pragma mark - VideoControllerDelegate

- (void)didRemoteVideoStateChange:(NSString *)uid state:(ooVooAVChatRemoteVideoState)state width:(const int)width height:(const int)height error:(sdk_error)code
{
    
    if (state == (ooVooAVChatRemoteVideoStateStopped | ooVooAVChatRemoteVideoStatePaused))
    {
        [ParticipentState setObject:[NSNumber numberWithBool:false] forKey:uid];
    }
    else
    {
        [ParticipentState setObject:[NSNumber numberWithBool:true] forKey:uid];
        if ([_ParticipentShowOrHide[uid] integerValue]==0) {
            UserVideoPanel *panel = _videoPanels[uid];
            panel.isAllowedToChangeImage=false;
            [panel showAvatar:true];
            
        }
    }
    
    UserVideoPanel* panel = [self.videoPanels objectForKey:uid];
    
    if(state == ooVooAVChatRemoteVideoStatePaused && panel){
        [panel showVideoAlert:YES] ;
    }
    
    if(state == ooVooAVChatRemoteVideoStateResumed && panel){
        [panel showVideoAlert:NO] ;
    }
    
    if (infoVC)
    {
        [infoVC.table reloadData];
    }
}

- (void)didCameraStateChange:(BOOL)state devId:(NSString *)devId width:(const int)width height:(const int)height fps:(const int)fps error:(sdk_error)code {
    NSLog(@"didCameraStateChange -> state [%@], code = [%d]", state ? @"Opened" : @"Fail", code);
    if (state) {
        //[self.sdk.AVChat.VideoController startTransmitVideo];
        //[self.sdk.AVChat.VideoController openPreview];
    }
}

- (void)didVideoTransmitStateChange:(BOOL)state devId:(NSString *)devId error:(sdk_error)code {
    NSLog(@"didVideoTransmitStateChanged -> state [%@], code = [%d]", state ? @"Opened" : @"Fail", code);

    [self showAndRunSpinner:NO];
}

- (void)didVideoPreviewStateChange:(BOOL)state devId:(NSString *)devId error:(sdk_error)code {
    NSLog(@"didVideoPreviewStateChange -> state [%@], code = [%d]", state ? @"Opened" : @"Fail", code);
    
    isCameraStateOn = state;
    
}

#pragma mark - ANIMATION  Video view Proccess


- (void)restoreVideoConstrains {
    // text box constrain
    self.contrainTopViewText.constant = [arrDefultConstrain[0] integerValue];
    [self animateConstraints];
    // video constrain
    self.constrainRightViewVideo.constant = [arrDefultConstrain[1] integerValue];
    self.constrainBottomViewVideo.constant = [arrDefultConstrain[2] integerValue];
    self.constrainLeftViewVideo.constant = [arrDefultConstrain[3] integerValue];
}

- (void)animateViewsForState:(BOOL)state {
    
    // saving the initial constrain to return it back when needed
    
    if (!arrDefultConstrain) {
        arrDefultConstrain = [[NSMutableArray alloc] initWithCapacity:3];
        [arrDefultConstrain addObject:[NSNumber numberWithInt:self.contrainTopViewText.constant]];      // 0
        [arrDefultConstrain addObject:[NSNumber numberWithInt:self.constrainRightViewVideo.constant]];  // 1
        [arrDefultConstrain addObject:[NSNumber numberWithInt:self.constrainBottomViewVideo.constant]]; // 2
        [arrDefultConstrain addObject:[NSNumber numberWithInt:self.constrainLeftViewVideo.constant]]; // 2
    }
    
    if (!state) {
        
        // text box constrain
        self.contrainTopViewText.constant -= self.viewTextBox.frame.size.height;
        [self animateConstraints];
        
        // video constrain
        self.constrainRightViewVideo.constant += self.videoPanelView.frame.size.width / 2 + space;
        self.constrainBottomViewVideo.constant += (self.videoPanelView.frame.size.height +36 )/ 2 + space;
        isViewInTransmitMode = true;
        
        // saving the small size video constrains
       // if (!arrBackupConstrain)
       
            arrBackupConstrain=nil;
            arrBackupConstrain = [[NSMutableArray alloc] initWithCapacity:4];
            [arrBackupConstrain addObject:[NSNumber numberWithInt:self.contrainTopViewText.constant]];      // 0
            [arrBackupConstrain addObject:[NSNumber numberWithInt:self.constrainRightViewVideo.constant]];  // 1
            [arrBackupConstrain addObject:[NSNumber numberWithInt:self.constrainBottomViewVideo.constant]]; // 2
            [arrBackupConstrain addObject:[NSNumber numberWithInt:self.constrainLeftViewVideo.constant]]; // 2
        
    } else {
        [self restoreVideoConstrains];
        
        isViewInTransmitMode = false;
    }
    
    [self animateConstraints];
    [self.lbl_error setHidden:!state];
    [self.viewCustomTollbar_container setHidden:state];
}


-(void)animateVideoBack{
    
    self.contrainTopViewText.constant=[arrBackupConstrain[0]integerValue];
    self.constrainRightViewVideo.constant=[arrBackupConstrain[1]integerValue];
    self.constrainBottomViewVideo.constant=[arrBackupConstrain[2]integerValue];
    self.constrainLeftViewVideo.constant=[arrBackupConstrain[3]integerValue];
    [self animateConstraints];
}

-(void)animateVideoToFullSize{
    //self.contrainTopViewText.constant = 0;
    [self animateConstraints];
    // video constrain
    self.constrainRightViewVideo.constant = 0;
    self.constrainBottomViewVideo.constant = 0;
    self.constrainLeftViewVideo.constant=0;
    [self animateConstraints];
}

- (void)animateConstraints {
    [UIView animateWithDuration:0.1
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
}


#pragma mark - ConferenceToolbarDelegate

- (NSArray *)getParticipantsNameList {
    
    NSMutableArray *arrUidsName = [NSMutableArray new];
    // get all panel uid names which are not me !
    for (NSString *uid in [participants allKeys]) {
        if (![uid isEqualToString:[ActiveUserManager activeUser].userId]) {
            NSString* displayName = [participants objectForKey:uid];
            [arrUidsName addObject:displayName];
        }
    }
    return [arrUidsName mutableCopy];
}

- (void)onHangUp:(id)sender {
    
    NSArray *arrUidsName =[participants allKeys];
    
    [self resetArraySlots];
    // remove all of the video panel which are not me .
    for (NSString *uid in arrUidsName) {
        UserVideoPanel *panel = self.videoPanels[uid];
        [self.videoPanels removeObjectForKey:uid];
        [self.ParticipentShowOrHide removeObjectForKey:uid];
        [self.sdk.AVChat.VideoController unbindVideoRender:uid render:panel];
        [self.sdk.AVChat.VideoController unRegisterRemoteVideo:uid];
        panel.hidden = true;
        [self killPanel:panel];
    }

    // reset toolbar
    [toolBar resetButtons];
    // rest internet conectivity
    [self resetAndShowNavigationBarbuttons:NO];

    [self.sdk.AVChat.VideoController unbindVideoRender:nil render:_videoPanelView];
    [self.sdk.AVChat leave];
    [self requestForSaveCallHistory];
    
    /*Murali Commented
    [self.navigationItem.leftBarButtonItem setTitle:@"Logout"];*/
    [self requestForSaveCallAnswerStatus];
}

-(void)resetAndShowNavigationBarbuttons:(BOOL)show{
    
    if (show)
    {
        //[InternetActivityView setInternetActivityLevel:0];
        InternetActivityView.view.hidden=false;
        /*Murali Commented
        [self setNavigationBarProfileButtonShow:YES];*/

    }
    else
    {
        [InternetActivityView setInternetActivityLevel:0];
        InternetActivityView.view.hidden=true;
        /*Murali Commented
        [self setNavigationBarProfileButtonShow:NO];*/

    }
   }

#pragma mark - AVChatDelegate

- (void)didParticipantLeave:(id<ooVooParticipant>)participant;
{
    NSLog(@"participant %@",participant.participantID);
    NSLog(@"arr taken slot %@",arrTakenSlot);
    [participants removeObjectForKey:participant.participantID];

    UserVideoPanel *panel = [self.videoPanels objectForKey:participant.participantID];
    
    if (panel) {
        
        
        if (panel==currentFullScreenPanel) {
            [self animate:panel ToFrame:rectLast];
            currentFullScreenPanel = NULL;
        }

        
        
        [self.videoPanels removeObjectForKey:participant.participantID];
        [self.ParticipentShowOrHide removeObjectForKey:participant.participantID];
        int newEmptySlot= [self getSelectedUidIndex:participant.participantID];
        
        CGRect rectPanel=panel.frame;
        
        [arrTakenSlot replaceObjectAtIndex:[ self getSelectedUidIndex:participant.participantID] withObject:String_Empty];
        
        panel.hidden = true; // animate instead
        [self.sdk.AVChat.VideoController unbindVideoRender: participant.participantID render:panel];
        [self.sdk.AVChat.VideoController unRegisterRemoteVideo:participant.participantID];
        
        
     
        
        
        
        [self killPanel:panel];
        

        
        // remove open panel to the first empty one
        for (int i = newEmptySlot+1; i<[arrTakenSlot count]; i++) {
            
            if (![arrTakenSlot[i] isEqualToString:String_Empty])
            {
                UserVideoPanel *panel =   [self.videoPanels objectForKey:arrTakenSlot[i]];
                CGRect rectInner = panel.frame;
                
                [UIView animateWithDuration:0.1 animations:^{
                    [panel setFrame:rectPanel];
                }];
                
                [arrTakenSlot replaceObjectAtIndex:newEmptySlot withObject:arrTakenSlot[i]];
                [arrTakenSlot replaceObjectAtIndex:i withObject:String_Empty];
                newEmptySlot=i;
                NSLog(@"arr taken slot %@",arrTakenSlot);
               
                if (CGRectEqualToRect(rectMaxSize, rectInner)) {
                    rectInner = rectLast;
                    currentFullScreenPanel = NULL;
                }
                
                rectPanel=rectInner;
                
            }
        }
    }
}

- (void)didParticipantJoin:(id<ooVooParticipant>)participant user_data:(NSString *)user_data;
{
    
    UserVideoPanel *panel;
    
    NSLog(@"participans Name %@\nuser data %@", participant.participantID,user_data);
    
    if (self.constrainBottomViewVideo.constant==0){
        [self animateVideoBack];
    }
    
    int emptySlot =[self getFirstemptySlot] ; // 0 | 1
    // 2 | 3
    
    NSString *strName = [self removeWhiteSpacesFromStartAndEnd:user_data];
    if ([strName isEqualToString:String_Empty]||!strName) {
        strName=participant.participantID;
    }
    [participants setValue:strName forKey:participant.participantID];

    
    panel = [[UserVideoPanel alloc] initWithFrame:self.videoPanelView.frame WithName:strName];
    
    [self setPanel:panel inPosition:emptySlot Animated:YES];
    
    [self.sdk.AVChat.VideoController registerRemoteVideo:participant.participantID];
    [self.sdk.AVChat.VideoController bindVideoRender:participant.participantID render:panel];
    [self.videoPanels setObject:panel forKey:participant.participantID];
    [arrTakenSlot replaceObjectAtIndex:emptySlot withObject:participant.participantID];
    [self.ParticipentShowOrHide setObject:[NSNumber numberWithBool:true] forKey:participant.participantID]; // default should show user video
    
}


-(void)setPanel:(UserVideoPanel*)panel inPosition:(int)emptySlot Animated:(BOOL)animated{
    
    int position;

    panel.frame=self.videoPanelView.frame;
    
    switch (emptySlot) {
        case 1: {
            panel.y=self.videoPanelView.y;
            panel.x += panel.width + space; // set the x at the end of the first
            position = panel.x;                  // save the real location
            panel.x = _viewForVideoSizeAdjest.width; // take the panel to the right for animation
            
        } break;
            
        case 2: {
            panel.y = self.videoPanelView.y + self.videoPanelView.height + space;
            position = self.videoPanelView.x;                   // save the real location
            panel.x = -_viewForVideoSizeAdjest.width; // take the panel to the Left for animation
            //      panel.strUserId = participant.participantID;
        } break;
            
        case 3: {
            panel.y = self.videoPanelView.y + self.videoPanelView.height  + space;
            panel.x += panel.width + space; // set the x at the end of the first
            position = panel.x;                  // save the real location
            panel.x = _viewForVideoSizeAdjest.width; // take the panel to the Left for animation
            //      panel.strUserId = participant.participantID;
        } break;
    }//switch
    
    if (!panel.delegate) {
        panel.delegate=self;
        panel.clipsToBounds=YES;
    }
    
    if(currentFullScreenPanel == NULL)
        [self.view addSubview:panel];
    else
        [self.view insertSubview:panel belowSubview:currentFullScreenPanel];
    
    if (animated) {
        
        [UIView animateWithDuration:0.1
                         animations:^{
                             panel.x = position;
                         }];

    }
    else
    {
        panel.x = position;
    }
    
    
}

+(NSString*)getErrorDescription:(sdk_error)code
{
    NSString * des;
    switch (code) {
            
        case sdk_error_InvalidParameter:                // Invalid Parameter
            des = @"Invalid Parameter.";
            break;
        case sdk_error_InvalidOperation:               // Invalid Operation
            des = @"Invalid Operation.";
            break;
        case sdk_error_DeviceNotFound:
            des = @"Device not found.";
            break;
        case sdk_error_AlreadyInSession:
            des = @"Already in session.";
            break;
        case sdk_error_DuplicateParticipantId:
            des = @"Duplicate Participant Id.";
            break;
        case sdk_error_ConferenceIdNotValid:
            des = @"Conference id not valid.";
            break;
        case sdk_error_ClientIdNotValid:
            des = @"client id not valid.";
            break;
        case sdk_error_ParticipantIdNotValid:
            des = @"Participant id not valid.";
            break;
        case sdk_error_CameraIdNotValid:
            des = @"Camera ID Not Valid.";
            break;
        case sdk_error_MicrophoneIdNotValid:
            des = @"Mic. ID Not Valid.";
            break;
        case sdk_error_SpeakerIdNotValid:
            des = @"Speaker ID Not Valid.";
            break;
        case sdk_error_VolumeNotValid:
            des = @"Volume Not Valid.";
            break;
        case sdk_error_ServerAddressNotValid:
            des = @"Server Address Not Valid.";
            break;
        case sdk_error_GroupQuotaExceeded:
            des = @"Group Quota Exceeded.";
            break;
        case sdk_error_NotInitialized:
            des = @" Not Initialized.";
            break;
        case sdk_error_Error:
            des = @"Conference Error.";
            break;
        case sdk_error_NotAuthorized:
            des = @"Not Authorized.";
            break;
        case sdk_error_ConnectionTimeout:
            des = @"Connection Timeout.";
            break;
        case sdk_error_DisconnectedByPeer:
            des = @"Disconnected by peer.";
            break;
        case sdk_error_InvalidToken:
            des = @"Invalid Token.";
            break;
        case sdk_error_ExpiredToken:
            des = @"Expired Token.";
            break;
        case sdk_error_PreviousOperationNotCompleted:
            des = @"Previous Operation Not Completed.";
            break;
        case sdk_error_AppIdNotValid:
            des = @"AppId Not Valid.";
            break;
        case sdk_error_NoAvs:
            des = @"No AVS.";
            break;
        case sdk_error_ActionNotPermitted:
            des = @"Action Not Permitted.";
            break;
        case sdk_error_DeviceNotInitialized:
            des = @"Device Not Initialized.";
            break;
        case sdk_error_Reconnecting:
            des = @"Network Is Reconnecting.";
            break;
        case sdk_error_Held:
            des = @"Application on hold.";
            break;
        case sdk_error_SSLCertificateVerificationFailed:
            des = @"SSL Certificates Verification Failed.";
            break;
        case sdk_error_ParameterAlreadySet:
            des = @"Parameter Already Set.";
            break;
        case sdk_error_AccessDenied:
            des = @"Access Denied.";
            break;
        case sdk_error_ConnectionLost:
            des = @"Connection Lost.";
            break;
        case sdk_error_NotEnoughMemory:
            des = @"Not Enough Memory.";
            break;
        case sdk_error_ResolutionNotSupported:
            des = @"Resolution not supported.";
            break;
        default:
            des = [NSString stringWithFormat:@"Error Code %d", code];
            break;
    }
    return des;
}

- (void)didConferenceStateChange:(ooVooAVChatState)state error:(sdk_error)code {
    [self showAndRunSpinner:NO];
    
    NSLog(@"state %d code %d", state, code);
    
  
    
    if (state == ooVooAVChatStateJoined && code == sdk_error_OK)
    {
        [UIApplication sharedApplication].idleTimerDisabled = (code == sdk_error_OK);
        [self.sdk.AVChat.AudioController setRecordMuted:NO];
        [self.sdk.AVChat.AudioController setPlaybackMute:NO];
        [self setVisibleOfJoinPage:state != ooVooAVChatStateJoined];
        /*Murali Commented
        [self.navigationItem.leftBarButtonItem setTitle:@"Leave"];*/
        [self resetAndShowNavigationBarbuttons:YES];
        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self onHangUp:self];
//            
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [self act_joinConference:self];
//            });
//            
//        });
    }
    else if (state == ooVooAVChatStateJoined || state == ooVooAVChatStateDisconnected)
    {
        if (state == ooVooAVChatStateJoined && code != sdk_error_OK)
        {
           UIAlertView *alert =  [[UIAlertView alloc] initWithTitle:@"Join Error" message:[ViewController getErrorDescription:code] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
        
        if (state == ooVooAVChatStateDisconnected)
        {
            currentRes = defaultRes;
            [self animateViewsForState:true]; // return to first view ....
            //[self.sdk.AVChat.VideoController bindVideoRender:nil/*[ActiveUserManager activeUser].userId*/ render:self.videoPanelView];
            [self.sdk.AVChat.VideoController bindVideoRender:[ActiveUserManager activeUser].userId render:self.videoPanelView];
            [self.sdk.AVChat.VideoController setConfig:self.defaultCameraId forKey:ooVooVideoControllerConfigKeyCaptureDeviceId];
            [self.sdk.AVChat.VideoController openCamera];
        }
        
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        [self resetAndShowNavigationBarbuttons:NO];
        
       
    }
}

- (void)didReceiveData:(NSString *)uid data:(NSData *)data {
}

- (void)didConferenceError:(sdk_error)code {
    [self.sdk.AVChat leave];
    [self showAndRunSpinner:NO];
}

- (void)didNetworkReliabilityChange:(NSNumber*)score{
    NSLog(@"Reliability = %@",score);
    [InternetActivityView setInternetActivityLevel:score];
}

- (void)didPhonePstnCallStateChange:(NSString *)participant_id state:(ooVooPstnState)state {
}

// related methods
-(void)killPanel:(UserVideoPanel*)panel{
    
    [panel removeFromSuperview];
    panel.delegate=nil;
    panel=nil;
    
}


- (void)setVisibleOfJoinPage:(BOOL)state {
    [self animateViewsForState:state];
}



#pragma mark - Private Methods

- (void)clear_error {
    self.lbl_error.hidden = YES;
}

- (void)show_error:(NSString *)error {
    self.lbl_error.text = error;
    self.lbl_error.hidden = NO;
}

-(NSString*)removeWhiteSpacesFromStartAndEnd:(NSString*)str{
    // comes @"    ddd  ddd       "
    //returns@"ddd  ddd"
    return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}


#pragma mark - CustomToolbarVC DELEGATE

- (void)CustomToolBarVC_didClickOnButtonTag:(int)tagNumber {
    
    switch (tagNumber) {
        case toolbar_mic:
            
            [self.sdk.AVChat.AudioController setRecordMuted:![self.sdk.AVChat.AudioController isRecordMuted]];
            
            NSLog(@"record muted %d", [self.sdk.AVChat.AudioController isRecordMuted]);
            break;
            
        case toolbar_speaker:
            
            [self.sdk.AVChat.AudioController setPlaybackMute:![self.sdk.AVChat.AudioController isPlaybackMuted]];
            
            break;
            
        case toolbar_camera:
            
            // open action sheet
            [self createActionSheetForCamera];
            
            break;
            
        case toolbar_hangUp:
//            [self.sdk.AVChat leave];
            [self onHangUp:nil];
            break;
            
        case toolbar_Effects:
        {
            [self createActionSheetForEffects];
         
   break;
        }
        case toolbar_resolution:
            [self createActionSheetForResolution];
            break;
            
        case toolbar_routingSound:
            
            break;
            
        default:
            break;
    }
}

#pragma mark - ACTION SHEET

typedef enum {
    actionSheet_camera = 100,
    actionSheet_effects = 200,
    actionSheet_Resolution = 300
} actionSheetType;

- (void)createActionSheetForCamera {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Camera:"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    NSArray *arr_dev = [self.sdk.AVChat.VideoController getDevicesList];
    
    NSLog(@"get device list %@", [self.sdk.AVChat.VideoController getDevicesList]);
    NSLog(@"get current camera device  %@", [self.sdk.AVChat.VideoController getConfig:ooVooVideoControllerConfigKeyCaptureDeviceId]);
    
    for (id<ooVooDevice> device in arr_dev) {
        
        NSString *strDeviceName = [NSString stringWithFormat:@"%@", device];
        
        // adding only camera which is nt the current
        if (![strDeviceName isEqualToString:[self getSelectedDeviceName]]) {
            [actionSheet addButtonWithTitle:strDeviceName];
        }
        
        NSLog(@"\ndevice name:%@,device ID:%@", device.deviceName, device.deviceID);
    }
    
#warning if user mute the camera , we need to change the mute to un mute !!!
    if (isCameraStateOn) {
        [actionSheet addButtonWithTitle:@"Mute"];
    } else {
        [actionSheet addButtonWithTitle:@"Unmute"];
    }
    
    if ([self isIpadMini]) {
        [actionSheet addButtonWithTitle:@""];
    }
    
    
    [actionSheet showInView:self.view];
    actionSheet.tag = actionSheet_camera;
    
    if ([arr_dev count] > 1) {
        SEL selector = NSSelectorFromString(@"_alertController");
        if ([actionSheet respondsToSelector:selector])
        {
            UIAlertController *alertController = [actionSheet valueForKey:@"_alertController"];
            if ([alertController isKindOfClass:[UIAlertController class]])
            {
                UIAlertAction *action = alertController.actions[1];
                isCameraStateOn ? [action setEnabled:YES] : [action setEnabled:NO];
            }
        }
        else
        {
            // use other methods for iOS 7 or older.
            isCameraStateOn ? [actionSheet setButton:1 Enabled:YES] : [actionSheet setButton:1 Enabled:NO];
        }
    }
}

-(void) handleEffectSelection:(UIAlertAction *) action effectId:(NSString *) effectId{
    
    
    [self.sdk.AVChat.VideoController setConfig:effectId forKey:ooVooVideoControllerConfigKeyEffectId];
    //  currentEffect =  effectId;
}

- (void)createActionSheetForEffects {

        NSMutableArray *arrListEffectNames=[NSMutableArray new];
        for  (id<ooVooEffect> effect in arrEffectList){
            [arrListEffectNames addObject:effect.effectName];
        }
        
        [self performSegueWithIdentifier:Segue_EffectList sender:arrListEffectNames];
    
}


-(void)handleResSelection:(UIAlertAction *)action withResolution: (NSNumber*) resolution {
    
    currentRes = [resolution stringValue];
    [self.sdk.AVChat.VideoController setConfig:currentRes forKey:ooVooVideoControllerConfigKeyResolution];
    
}


- (void)openAlertController:(NSArray*) resolutions {
    currentRes = [self.sdk.AVChat.VideoController getConfig:ooVooVideoControllerConfigKeyResolution];
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Choose Resolution:"
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (NSNumber* resolution in resolutions) {
        NSString* header = [resolutionsHeaders objectForKey:resolution];
        
        UIAlertActionStyle style = UIAlertActionStyleDefault;
        
        if ([currentRes isEqualToString:[resolution stringValue]]) {
            style = UIAlertActionStyleDestructive;
        }
        UIAlertAction *action = [UIAlertAction
                                 actionWithTitle:header
                                 style:style
                                 handler:^(UIAlertAction *action)
                                 {
                                     [self handleResSelection:action withResolution:resolution];
                                 }];
        [alertController addAction:action];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                   }];
    
    [alertController addAction:cancelAction];
    
    alertController.popoverPresentationController.sourceView = _viewCustomTollbar_container;
    alertController.popoverPresentationController.sourceRect=self.view.bounds;
    [alertController.popoverPresentationController setPermittedArrowDirections:UIPopoverArrowDirectionDown];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
-(void) openActionSheet:(NSArray*) resolutions {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Resolution:"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    actionSheet.tag = actionSheet_Resolution;
    for (NSNumber* resolution in resolutions) {
        NSString* header = [resolutionsHeaders objectForKey:resolution];
        
        NSLog(@"header is %@",header);
        
        [actionSheet addButtonWithTitle:header];
        
        if ([currentRes isEqualToString:[resolution stringValue]])
        { // Selected
            [[[actionSheet valueForKey:@"_buttons"] lastObject] setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
        
    }
    if ([self isIpadMini]) {
        [actionSheet addButtonWithTitle:@""];
    }
    
    [actionSheet showInView:self.view];
    //[actionSheet showInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    
}

- (void)createActionSheetForResolution {
    
    NSMutableArray *allowedResolutions = [NSMutableArray new];
    NSArray* resolutions = [self.sdk.AVChat.VideoController.activeDevice getAvailableResolutions];
    
    if(resolutions)
    {
        for(NSNumber* resolution in resolutions)
        {
            if ([self.sdk.AVChat isResolutionSuported:[resolution integerValue]]) {
                [allowedResolutions addObject:resolution];
            }
        }
    }
    
    
    
    
    
    if ([UIAlertController class]) {
        [self openAlertController:allowedResolutions];
    }
    else {
        [self openActionSheet:allowedResolutions];
    }
}

-(BOOL)isIpadMini{
    
    
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size + 1);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    machine[size] = 0;
    
    if (strcmp(machine, "iPad2,5") == 0) {
        return true;
    }
    
    free(machine);
    return false;
    
}

-(BOOL)isIpad{
#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad
    
    if ( IDIOM == IPAD ) {
        return true;
    } else {
        return  false;
    }
}


#pragma mark -

- (NSString *)getIdForName:(NSString *)strName FromArray:(NSArray *)array {
    
    if ([NSStringFromClass([array[0] class]) isEqualToString:@"ooVooDeviceWrap"]) {
        
        NSLog(@"device wrap");
        
        for (id<ooVooDevice> device in array) {
            
            if ([device.deviceName isEqualToString:strName]) {
                return device.deviceID;
            }
        }
        
    } else {
        NSLog(@"effect wrap");
        
        for (id<ooVooEffect> effect in array) {
            
            if ([effect.effectName isEqualToString:strName]) {
                return effect.effectID;
            }
        }
    }
    
    return nil;
}

- (NSString *)getNameForId:(NSString *)strID FromArray:(NSArray *)array {
    
    if ([NSStringFromClass([array[0] class]) isEqualToString:@"ooVooDeviceWrap"]) {
        
        NSLog(@"device wrap");
        
        for (id<ooVooDevice> device in array) {
            
            if ([device.deviceID isEqualToString:strID]) {
                return device.deviceName;
            }
        }
        
    } else {
        NSLog(@"ooVooeffect wrap");
        
        for (id<ooVooEffect> effect in array) {
            
            if ([effect.effectID isEqualToString:strID]) {
                return effect.effectName;
            }
        }
    }
    
    return nil;
}

- (NSString *)getSelectedDeviceName {
    NSString *iid = [self.sdk.AVChat.VideoController getConfig:ooVooVideoControllerConfigKeyCaptureDeviceId]; // getting the id of the current selected
    NSString *strName = [self getNameForId:iid FromArray:[self.sdk.AVChat.VideoController getDevicesList]];
    return strName;
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
//    NSLog(@"isvideotransmited %@", [self.sdk.AVChat.VideoController isVideoTransmited]);
    NSLog(@"Index = %ld - Title = %@", (long)buttonIndex, [actionSheet buttonTitleAtIndex:buttonIndex]);
    
    //check cancel button
    if (buttonIndex == 0) {
        return;
    }
    
    // GET THE ID OF THE SELECTED CAMERA OR EFFECT
    NSString *strID;
    
    if (actionSheet.tag == actionSheet_camera) {
        NSLog(@"Camera action sheet selected");
        
        strID = [self getIdForName:[actionSheet buttonTitleAtIndex:buttonIndex] FromArray:[self.sdk.AVChat.VideoController getDevicesList]];
        
        if (strID) {
            [self.sdk.AVChat.VideoController setConfig:strID forKey:ooVooVideoControllerConfigKeyCaptureDeviceId];
        } else // user want's to mute camera
        {
            if (isCameraStateOn) {
                [self.videoPanelView showAvatar:YES];
                //[self.sdk.AVChat.VideoController closePreview];
                [self.sdk.AVChat.VideoController closeCamera];
                [toolBar setCameraImageForButtonIsOn:false];
                
            } else {
                // remove avatar
                [self.videoPanelView showAvatar:false];
                [self.sdk.AVChat.VideoController openCamera];
                [toolBar setCameraImageForButtonIsOn:true];
                //[self.sdk.AVChat.VideoController openPreview];
            }
            
#warning add avatar mhen muted
            NSLog(@"user want's to mute camera");
        }
        
    }
    
    else if (actionSheet.tag == actionSheet_effects){
        id <ooVooEffect> effect = arrEffectList[buttonIndex-1];
        [self handleEffectSelection:nil effectId:effect.effectID];
        
    }
    else // it's resolution action sheet
    {
        currentRes = [NSString stringWithFormat:@"%ld", (long)buttonIndex];
        [self.sdk.AVChat.VideoController setConfig:currentRes forKey:ooVooVideoControllerConfigKeyResolution];
    }
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - User Panel Delegate


CGRect rectLast;
-(void)UserVideoPanel_Touched:(UserVideoPanel *)videoPanel{
    
    // if its my video
    if ([videoPanel isEqual:_videoPanelView]) {
        NSLog(@"it's the big view");
        
        if (self.constrainBottomViewVideo.constant==0)
        {
            [self animateVideoBack];
            currentFullScreenPanel = NULL;
        }
        else if (self.constrainBottomViewVideo.constant==-36) // default size before conference Dont resize
            return;
        else
        {
            [self animateVideoToFullSize];
            [self.view bringSubviewToFront:_videoPanelView];
            currentFullScreenPanel = _videoPanelView;
        }
        return;
    }
    
    
    // if its other user video
    if (CGRectEqualToRect(rectMaxSize, videoPanel.frame)) {
        NSLog(@"it's on max turn to saved rect");
        [self animate:videoPanel ToFrame:rectLast];
        currentFullScreenPanel = NULL;
    }
    else{
        rectLast=videoPanel.frame;
        [self animate:videoPanel ToFrame:rectMaxSize];
        [self.view bringSubviewToFront:videoPanel];
        currentFullScreenPanel = videoPanel;
    }
}

CGRect rectMaxSize;

#define TopSpace 10
-(void)saveMaxFrameSize{
    
    rectMaxSize.origin.x=0;
    rectMaxSize.origin.y=TopSpace;
    rectMaxSize.size.width=self.view.width;
    rectMaxSize.size.height=self.view.height-_viewCustomTollbar_container.height-TopSpace;
    
}

-(void)animate:(UserVideoPanel*)panel ToFrame:(CGRect)frame{
    // [panel animateImageFrame:frame];
    //  [UIView animateWithDuration:0.5 animations:^{
    panel.frame=frame;
    //    view.imgView.frame=frame;
    
    //  }];
    
}


#pragma  mark - Info view controller DELEGATE

-(void)InfoViewController_DidChangeVisualToUid:(NSString *)strUid{
    
    BOOL value=[_ParticipentShowOrHide[strUid]boolValue ];
    [_ParticipentShowOrHide setObject:[NSNumber numberWithBool:!value] forKey:strUid]; // setting the opposite value
    
    
    
    if ([_ParticipentShowOrHide[strUid] integerValue]==1) {
        UserVideoPanel *panel = _videoPanels[strUid];
        panel.isAllowedToChangeImage=true;
        
    }
    
    
    
    // get the selected panel - Un/register put/remove avatar
    UserVideoPanel *panel = _videoPanels[strUid];
    
    if (value){
        //  [self.sdk.AVChat.VideoController unRegisterRemoteVideo:strUid];
        [panel showAvatar:true];
        
    }else{
        //   [self.sdk.AVChat.VideoController registerRemoteVideo:strUid];
        [panel showAvatar:false];
    }
}
-(NSNumber*)InfoViewController_GetVisualListForId:(NSString*)strID{
    return _ParticipentShowOrHide[strID];
}
-(NSNumber*)isAllowedToChangeUserStateForId:(NSString *)strID{
    return ParticipentState[strID];
}

#pragma mark - TABLE LIST DELEGATE

-(void)tableListDidSelect:(int)index{
    
    id <ooVooEffect> effect = arrEffectList[index];
    [self handleEffectSelection:nil effectId:effect.effectID];
    
    
}


@end
