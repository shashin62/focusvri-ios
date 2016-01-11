//
//  AudioPlayer.m
//  NewWave
//
//  Created by Murali Gorantla on 13/09/15.
//  Copyright (c) 2015 Murali Gorantla. All rights reserved.
//

#import "AudioPlayer.h"

@implementation AudioPlayer


@synthesize avAudioPlayer;
@synthesize playing;
@synthesize audioplayerDelegate;


- (id)initWithURL:(NSURL *)url
{
    if (self = [super init])
    {
        NSError *error;
        avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        avAudioPlayer.numberOfLoops = -1;
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
        else{
            // In this example we'll pre-load the audio into the buffer. You may avoid it if you want
            // as it's not always possible to pre-load the audio.
            [avAudioPlayer prepareToPlay];
        }
        avAudioPlayer.delegate = self;
    }
    else
    {
        return nil;
    }
    return self;
}

- (id)initWithData:(NSData *)data {
    if (self = [super init])
    {
        
        avAudioPlayer = [[AVAudioPlayer alloc] initWithData:data  error:nil];
        avAudioPlayer.numberOfLoops = -1;
        avAudioPlayer.delegate = self;
    }
    else
    {
        return nil;
    }
    return self;
}

- (void)play
{
    //[avAudioPlayer prepareToPlay];
    [avAudioPlayer setVolume: 5.0];
    [avAudioPlayer play];
    self.playing = true;
    return;
}

- (void)pause
{
    if (playing)
    {
        [avAudioPlayer pause];
    }
    return;
}

- (void)stop
{
    [avAudioPlayer stop];
    self.playing = false;
    return;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    // [audioplayerDelegate audioCompleted];
}

- (Boolean)isRunning
{
    return playing;
}

- (NSTimeInterval)getCurrentTime
{
    return [avAudioPlayer currentTime];
}

- (void)playFromTimestamp:(NSTimeInterval)timestamp
{
    [avAudioPlayer setCurrentTime:timestamp];
    [self play];
    return;
}

@end


