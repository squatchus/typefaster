//
//  sounds.m
//  type.trainer
//
//  Created by Sergey Mazulev on 09.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

#import "TFSoundService.h"

@import AudioToolbox;
@import AVFoundation;

@interface TFSoundService()

@property (nonatomic, strong) AVAudioPlayer *errorPlayer;
@property (nonatomic, strong) AVAudioPlayer *clickPlayer;
@property (nonatomic, strong) AVAudioPlayer *rankPlayer;
@property (nonatomic, strong) AVAudioPlayer *resultPlayer;
@property (nonatomic, strong) AVAudioPlayer *buttonPlayer;

@end

@implementation TFSoundService

- (instancetype)init
{
    if (self = [super init])
    {
        NSString *toneFilename = [NSBundle.mainBundle pathForResource:@"Tock" ofType:@"caf"];
        NSURL *toneURLRef = [NSURL fileURLWithPath:toneFilename];
        _clickPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: toneURLRef error: nil];
        _clickPlayer.volume = 0.1;
        [_clickPlayer prepareToPlay];

        toneFilename = [NSBundle.mainBundle pathForResource:@"error" ofType:@"wav"];
        toneURLRef = [NSURL fileURLWithPath:toneFilename];
        _errorPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: toneURLRef error: nil];
        [_errorPlayer prepareToPlay];
        
        toneFilename = [NSBundle.mainBundle pathForResource:@"click" ofType:@"wav"];
        toneURLRef = [NSURL fileURLWithPath:toneFilename];
        _buttonPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: toneURLRef error: nil];
        [_buttonPlayer prepareToPlay];

        toneFilename = [NSBundle.mainBundle pathForResource:@"new_result" ofType:@"wav"];
        toneURLRef = [NSURL fileURLWithPath:toneFilename];
        _resultPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: toneURLRef error: nil];
        [_resultPlayer prepareToPlay];

        toneFilename = [NSBundle.mainBundle pathForResource:@"new_rank" ofType:@"wav"];
        toneURLRef = [NSURL fileURLWithPath:toneFilename];
        _rankPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: toneURLRef error: nil];
        [_rankPlayer prepareToPlay];
    }
    return self;
}

- (void)playKeyboardClickSound
{
    if (_clickPlayer.isPlaying)
        _clickPlayer.currentTime = 0;
    else
        [_clickPlayer play];
}

- (void)playButtonClickSound
{
    if (_buttonPlayer.isPlaying)
        _buttonPlayer.currentTime = 0;
    else
        [_buttonPlayer play];
}

- (void)playErrorSound
{
    if (_errorPlayer.isPlaying)
        _errorPlayer.currentTime = 0;
    else
        [_errorPlayer play];
}

- (void)playNewRecordSound
{
    if (_resultPlayer.isPlaying)
        _resultPlayer.currentTime = 0;
    else
        [_resultPlayer play];
}

- (void)playNewRankSound
{
    if (_rankPlayer.isPlaying)
        _rankPlayer.currentTime = 0;
    else
        [_rankPlayer play];
}

@end
