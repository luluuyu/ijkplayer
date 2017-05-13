//
//  ZGPlayKit.m
//  IJKMediaPlayer
//
//  Created by 鲁志刚 on 2017/5/5.
//  Copyright © 2017年 bilibili. All rights reserved.
//

#import "ZGPlayKit.h"
#import <ZGKit/IJKMediaFramework.h>
#import "IJKFFOptions.h"
#import <ZGKit/IJKMediaPlayback.h>
#import "IJKFFMoviePlayerDef.h"
#import "IJKMediaPlayback.h"
#import "IJKMediaModule.h"
#import "IJKAudioKit.h"
#import "IJKNotificationManager.h"
#import "NSString+IJKMedia.h"
#import "ijkioapplication.h"
#include "string.h"

#import "IJKFFMoviePlayerController.h"

@interface ZGPlayKit ()

@property (nonatomic,strong) IJKFFMoviePlayerController *player;

@end

@implementation ZGPlayKit

- (instancetype)initWithPath:(NSString *)path
{
    if (self = [super init]) {
        self.path = path;
        [self _initSelf];
    }
    return self;
}

- (instancetype)initWithURL:(NSString *)URL
{
    if (self = [super init]) {
        self.url = URL;
        [self _initSelf];
    }
    return self;
}

- (void)_initSelf
{
#ifdef DEBUG
    [IJKFFMoviePlayerController setLogReport:YES];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEBUG];
#else
    [IJKFFMoviePlayerController setLogReport:NO];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_SILENT];
#endif
    
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    NSURL *URL;
    if (_path) {
        URL = [NSURL fileURLWithPath:_path];
    } else if (_url) {
        URL = [NSURL URLWithString:_url];
    }
    if (URL == nil) {
        return ;
    }
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:URL withOptions:options];
    self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
    self.player.shouldAutoplay = YES;
    
    [self addSubview:self.player.view];
    
    [self installMovieNotificationObservers];
    
    [self.player prepareToPlay];
}

- (NSTimeInterval)remainingTime
{
    return self.player.duration - self.player.currentPlaybackTime;
}

- (NSTimeInterval)duration
{
    return self.player.duration;
}

- (NSTimeInterval)currentPlaybackTime
{
    return self.player.currentPlaybackTime;
}

#pragma mark Private Method
-(void)installMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_player];
}

-(void)removeMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.player.view.frame = self.bounds;
}

#pragma mark Notification Action
- (void)loadStateDidChange:(NSNotification*)notification
{
    //    MPMovieLoadStateUnknown        = 0,
    //    MPMovieLoadStatePlayable       = 1 << 0,
    //    MPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
    //    MPMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started
    
    IJKMPMovieLoadState loadState = _player.loadState;
    
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStatePlaythroughOK: %d\n", (int)loadState);
    } else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
    } else {
        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
    //    MPMovieFinishReasonPlaybackEnded,
    //    MPMovieFinishReasonPlaybackError,
    //    MPMovieFinishReasonUserExited
    int reason = [[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    
    switch (reason)
    {
        case IJKMPMovieFinishReasonPlaybackEnded:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonUserExited:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonPlaybackError:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
            break;
            
        default:
            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
}

- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
    NSLog(@"mediaIsPreparedToPlayDidChange\n");
}

- (void)moviePlayBackStateDidChange:(NSNotification*)notification
{
    ZGPlayKitState state = -1;
    switch (_player.playbackState)
    {
        case IJKMPMoviePlaybackStateStopped: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);
            state = ZGPlayKitStateStopped;
            break;
        }
        case IJKMPMoviePlaybackStatePlaying: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
            state = ZGPlayKitStatePlaying;
            break;
        }
        case IJKMPMoviePlaybackStatePaused: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
            state = ZGPlayKitStatePaused;
            break;
        }
        case IJKMPMoviePlaybackStateInterrupted: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)_player.playbackState);
            state = ZGPlayKitStatePaused;
            break;
        }
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)_player.playbackState);
            break;
        }
        default: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_player.playbackState);
            break;
        }
    }
    if (self.stateChanged) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wenum-conversion"
        self.stateChanged(state);
#pragma clang diagnostic pop
    }
}


- (void)zg_play {
    [self.player play];
}

- (void)zg_pause {
    [self.player pause];
}

- (void)zg_stop {
    [self.player stop];
}

- (BOOL)zg_isPlaying {
    return [self.player isPlaying];
}

- (float)zg_position {
    return self.player.currentPlaybackTime / self.player.duration;
}

- (void)zg_setNewPosition:(float)posistion {
    self.player.currentPlaybackTime = posistion * self.player.duration;
}

- (BOOL)zg_seekable {
    return true;
}

- (void)zg_fastForwardAtRate:(float)rate {
    self.player.playbackRate = rate;
}

- (void)zg_fastRewindAtRate:(float)rate {
    // do nothing;
    NSLog(@"%s",__func__);
}

- (void)zg_clearMedia {
    [self.player shutdown];
    [self removeMovieNotificationObservers];
}

- (void)zg_jumpTo:(int)interval {
    self.player.currentPlaybackTime = self.player.currentPlaybackTime + interval;
}

- (void)zg_setBrightness:(CGFloat)brightness {
    NSLog(@"%s",__func__);
}

- (void)zg_setContrast:(CGFloat)contrast {
    NSLog(@"%s",__func__);
}

- (void)zg_setHue:(CGFloat)hue {
    NSLog(@"%s",__func__);
}

- (void)zg_setSaturation:(CGFloat)saturation {
    NSLog(@"%s",__func__);
}

- (void)zg_setGamma:(CGFloat)gamma {
    NSLog(@"%s",__func__);
}

- (void)setAudioDelay:(float)delay {
    NSLog(@"%s",__func__);
}

- (void)zg_setSubtitlesDelay:(float)delay {
    NSLog(@"%s",__func__);
}

- (void)zg_setVideoAspectRatio:(NSInteger)scale {
    NSLog(@"%s",__func__);
}

- (void)zg_setSpeed:(float)value {
    self.player.playbackRate = value;
}

- (UIViewController *)superController
{
    UIView *next = [self superview];
    while (next)
    {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]){
            return (UIViewController*)nextResponder;
        }
        next = next.superview;
    }
    return nil;
}

@end
