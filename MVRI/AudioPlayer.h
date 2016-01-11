//
//  AudioPlayer.h
//  NewWave
//
//  Created by Murali Gorantla on 13/09/15.
//  Copyright (c) 2015 Murali Gorantla. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioPlayer : NSObject<AVAudioPlayerDelegate>

- (id)initWithURL:(NSURL*) url;
- (id)initWithData:(NSData *)data;
- (Boolean)isRunning;
- (void)play;
- (void)stop;
- (void)pause;
- (NSTimeInterval)getCurrentTime;
- (void)playFromTimestamp:(NSTimeInterval) timestamp;
//- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag;

@property (nonatomic, retain) AVAudioPlayer* avAudioPlayer;
@property (nonatomic, assign) Boolean playing;
@property (nonatomic, assign) id audioplayerDelegate;


@end

