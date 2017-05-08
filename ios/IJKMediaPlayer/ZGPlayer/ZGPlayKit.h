//
//  ZGPlayKit.h
//  IJKMediaPlayer
//
//  Created by 鲁志刚 on 2017/5/5.
//  Copyright © 2017年 bilibili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZGPlayKit : UIView

- (instancetype)initWithPath:(NSString *)path;
- (instancetype)initWithURL:(NSString *)URL;

@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *url;

- (NSTimeInterval)remainingTime;
- (NSTimeInterval)duration;
- (NSTimeInterval)currentPlaybackTime;


- (void)zg_play;
- (void)zg_pause;
- (void)zg_stop;

- (BOOL)zg_isPlaying;
- (float)zg_position;

- (void)zg_setNewPosition:(float)posistion;
- (BOOL)zg_seekable;

- (void)zg_fastForwardAtRate:(float)rate;;
- (void)zg_fastRewindAtRate:(float)rate;
- (void)zg_clearMedia;

- (void)zg_jumpTo:(int)interval;

- (void)zg_setBrightness:(CGFloat)brightness;

- (void)zg_setContrast:(CGFloat)contrast;

- (void)zg_setHue:(CGFloat)hue;
- (void)zg_setSaturation:(CGFloat)saturation;

- (void)zg_setGamma:(CGFloat)gamma;

- (void)setAudioDelay:(float)delay;

- (void)zg_setSubtitlesDelay:(float)delay;
- (void)zg_setVideoAspectRatio:(NSInteger)scale;
- (void)zg_setSpeed:(float)value;


@end
