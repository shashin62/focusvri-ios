//
// ParticipantsController.m
// 
// Created by ooVoo on July 22, 2013
//
// © 2013 ooVoo, LLC.  Used under license. 
//

#import "ParticipantsController.h"
#import <ooVooSDK/ooVooSDK.h>

@implementation Participant
@end

@interface ParticipantsController()<ooVooAVChatDelegate, ooVooVideoControllerDelegate>
@property (strong, nonatomic) ooVooClient *sdk;
@property (nonatomic, strong) NSMutableArray *participants;
@property (nonatomic, strong) NSMutableDictionary *participantsByID;
@end

@implementation ParticipantsController

- (id)init
{
    if ((self = [super init]))
    {
        _participants = [NSMutableArray array];
        _participantsByID = [NSMutableDictionary dictionary];
        self.sdk = [ooVooClient sharedInstance];
        self.sdk.AVChat.delegate = self;
        self.sdk.AVChat.VideoController.delegate = self;
        
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(conferenceDidBegin:)
//                                                     name:OOVOOConferenceDidBeginNotification
//                                                   object:nil];
//        
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(participantDidJoin:)
//                                                     name:OOVOOParticipantDidJoinNotification
//                                                   object:nil];
//        
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(participantDidLeave:)
//                                                     name:OOVOOParticipantDidLeaveNotification
//                                                   object:nil];
//        
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(participantDidChange:)
//                                                     name:OOVOOParticipantVideoStateDidChangeNotification
//                                                   object:nil];
//        
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(videoDidStop:)
//                                                     name:OOVOOVideoDidStopNotification
//                                                   object:nil];
//        
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(videoDidStart:)
//                                                     name:OOVOOVideoDidStartNotification
//                                                   object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSInteger)numberOfParticipants
{
 	return [self.participants count];
}

- (Participant *)participantAtIndex:(NSUInteger)index
{
    return [self.participants objectAtIndex:index];
}


- (Participant *)participantWithId:(NSString *)participantId
{
    return [self.participantsByID valueForKey:participantId];
}

- (NSUInteger)indexOfParticipantWithId:(NSString *)participantId
{
    NSUInteger index = NSNotFound;
    Participant *participant = [self participantWithId:participantId];
    if (participant)
    {
        index = [self.participants indexOfObject:participant];
    }
    
    return index;
}

#pragma mark - VideoControllerDelegate

- (void)didRemoteVideoStateChange:(NSString *)uid state:(ooVooAVChatRemoteVideoState)state width:(const int)width height:(const int)height error:(sdk_error)code
{
    
    if (state == (ooVooAVChatRemoteVideoStateStopped | ooVooAVChatRemoteVideoStatePaused)) {
        [self.participantsByID setObject:[NSNumber numberWithBool:false] forKey:uid];
    }
    else {
        [self.participantsByID setObject:[NSNumber numberWithBool:true] forKey:uid];
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
    
    //[self showAndRunSpinner:NO];
}

- (void)didVideoPreviewStateChange:(BOOL)state devId:(NSString *)devId error:(sdk_error)code {
    NSLog(@"didVideoPreviewStateChange -> state [%@], code = [%d]", state ? @"Opened" : @"Fail", code);
    
    //isCameraStateOn = state;
    
}

#pragma mark - AVChatDelegate

- (void)didParticipantLeave:(id<ooVooParticipant>)participant;
{
    NSLog(@"participant %@",participant.participantID);
    [self.participantsByID removeObjectForKey:participant.participantID];
    //[self.sdk.AVChat.VideoController unbindVideoRender: participant.participantID render:panel];
    [self.sdk.AVChat.VideoController unRegisterRemoteVideo:participant.participantID];
}

- (void)didParticipantJoin:(id<ooVooParticipant>)participant user_data:(NSString *)user_data;
{
    
    NSLog(@"participans Name %@\nuser data %@", participant.participantID,user_data);
    [self.sdk.AVChat.VideoController registerRemoteVideo:participant.participantID];
    //[self.sdk.AVChat.VideoController bindVideoRender:participant.participantID render:panel];
    NSString *participantID = participant.participantID;
    Participant *participantToAdd = self.participantsByID[participantID];
    if (participantToAdd == nil)
    {
        [self.delegate controllerWillChangeContent:self];
        
        Participant *participant = [[Participant alloc] init];
        participant.participantID = participant.participantID;
        participant.displayName = user_data;
        participant.state = ooVooAVChatStateDisconnected;
        [self.participants addObject:participant];
        self.participantsByID[participantID] = participant;
        
        NSUInteger index = [self.participants indexOfObject:participant];
        [self.delegate controller:self didChangeParticipant:participant atIndexPath:nil forChangeType:ParticipantChangeInsert newIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        [self.delegate controllerDidChangeContent:self];
    }

}

- (NSString*)getErrorDescription:(sdk_error)code
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

    NSLog(@"state %d code %d", state, code);
    if (state == ooVooAVChatStateJoined && code == sdk_error_OK)
    {
        [UIApplication sharedApplication].idleTimerDisabled = (code == sdk_error_OK);
        [self.sdk.AVChat.AudioController setRecordMuted:NO];
        [self.sdk.AVChat.AudioController setPlaybackMute:NO];
    }
    else if (state == ooVooAVChatStateJoined || state == ooVooAVChatStateDisconnected)
    {
        if (state == ooVooAVChatStateJoined && code != sdk_error_OK)
        {
            UIAlertView *alert =  [[UIAlertView alloc] initWithTitle:@"Join Error" message:[self getErrorDescription:code] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
        
        if (state == ooVooAVChatStateDisconnected)
        {
            //[self.sdk.AVChat.VideoController bindVideoRender:nil/*[ActiveUserManager activeUser].userId*/ render:self.videoPanelView];
            //[self.sdk.AVChat.VideoController setConfig:self.defaultCameraId forKey:ooVooVideoControllerConfigKeyCaptureDeviceId];
            [self.sdk.AVChat.VideoController openCamera];
        }
        
        [UIApplication sharedApplication].idleTimerDisabled = NO;
    }
}

- (void)didReceiveData:(NSString *)uid data:(NSData *)data {
}

- (void)didConferenceError:(sdk_error)code {
    [self.sdk.AVChat leave];
}

- (void)didNetworkReliabilityChange:(NSNumber*)score{
    NSLog(@"Reliability = %@",score);
}

- (void)didPhonePstnCallStateChange:(NSString *)participant_id state:(ooVooPstnState)state {
}


#pragma mark - State
- (void)setState:(ooVooAVChatState)state forParticipant:(NSString*)participantId
{
    Participant *participant = [self participantWithId:participantId];
    participant.state = state;
}

/*
#pragma mark - Notifications
- (void)conferenceDidBegin:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSString *myParticipantID = userInfo[OOVOOParticipantIdKey];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate controllerWillChangeContent:self];
        
        Participant *me = [[Participant alloc] init];
        me.displayName = @"Me";
        me.participantID = myParticipantID;
        me.state = ooVooAVChatStateDisconnected;
        me.isMe = YES;
        
        [self.participants addObject:me];
        self.participantsByID[myParticipantID] = me;
        
        NSUInteger index = [self.participants indexOfObject:me];
        [self.delegate controller:self didChangeParticipant:me atIndexPath:nil forChangeType:ParticipantChangeInsert newIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        [self.delegate controllerDidChangeContent:self];
    });
}

- (void)participantDidJoin:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSDictionary *userInfo = notification.userInfo;
        NSString *participantID = userInfo[OOVOOParticipantIdKey];
        
        Participant *participantToAdd = self.participantsByID[participantID];
        
        
        if (participantToAdd == nil)
        {
            [self.delegate controllerWillChangeContent:self];
            
            Participant *participant = [[Participant alloc] init];
            participant.participantID = userInfo[OOVOOParticipantIdKey];
            participant.displayName = userInfo[OOVOOParticipantInfoKey];
            participant.state = ooVooVideoUninitialized;
            
            [self.participants addObject:participant];
            self.participantsByID[userInfo[OOVOOParticipantIdKey]] = participant;
            
            NSUInteger index = [self.participants indexOfObject:participant];
            [self.delegate controller:self didChangeParticipant:participant atIndexPath:nil forChangeType:ParticipantChangeInsert newIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            [self.delegate controllerDidChangeContent:self];
        }
        
    });
}

- (void)participantDidLeave:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSDictionary *userInfo = notification.userInfo;
        NSString *removedParticipantID = userInfo[OOVOOParticipantIdKey];
        
        Participant *participantToRemove = self.participantsByID[removedParticipantID];
        
        if (participantToRemove)
        {
            [self.delegate controllerWillChangeContent:self];
            
            NSUInteger index = [self.participants indexOfObject:participantToRemove];
            [self.participants removeObject:participantToRemove];
            //            [self.participantsByID removeObjectForKey:removedParticipantID];
            [self.delegate controller:self didChangeParticipant:participantToRemove atIndexPath:[NSIndexPath indexPathForRow:index inSection:0] forChangeType:ParticipantChangeDelete newIndexPath:nil];
            [self.delegate controllerDidChangeContent:self];
        }
        
    });
}

- (void)participantDidChange:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSDictionary *userInfo = notification.userInfo;
        NSString *changedParticipantID = userInfo[OOVOOParticipantIdKey];
        ooVooVideoState state = (ooVooVideoState)[userInfo[OOVOOParticipantStateKey] integerValue];
        
        Participant *participant = self.participantsByID[changedParticipantID];
        
        if (participant)
        {
            [self.delegate controllerWillChangeContent:self];
            
            participant.state = state;
            NSUInteger index = [self.participants indexOfObject:participant];
            [self.delegate controller:self didChangeParticipant:participant atIndexPath:[NSIndexPath indexPathForRow:index inSection:0] forChangeType:ParticipantChangeUpdate newIndexPath:nil];
            
            
            [self.delegate controllerDidChangeContent:self];
        }
        
    });
    
}

- (void)videoDidStop:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.participants.count > 0)
        {
            Participant *participant = [self.participants objectAtIndex:0];
            [self.delegate controllerWillChangeContent:self];
            
            participant.state = ooVooVideoOff;
            [self.delegate controller:self didChangeParticipant:participant atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] forChangeType:ParticipantChangeUpdate newIndexPath:nil];
            
            [self.delegate controllerDidChangeContent:self];
        }
    });
}

- (void)videoDidStart:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.participants.count>0)
        {
            Participant *participant = [self.participants objectAtIndex:0];
            [self.delegate controllerWillChangeContent:self];
            
            participant.state = ooVooVideoOn;
            [self.delegate controller:self didChangeParticipant:participant atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] forChangeType:ParticipantChangeUpdate newIndexPath:nil];
            
            [self.delegate controllerDidChangeContent:self];
        }
    });
}*/


@end

