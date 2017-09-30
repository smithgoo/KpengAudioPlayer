//
//  KpengAudioPlayer.m
//  SingDemo
//
//  Created by 王朋 on 2017/9/30.
//  Copyright © 2017年 王朋. All rights reserved.
//

#import "KpengAudioPlayer.h"

#import <AVFoundation/AVFoundation.h>

@interface KpengAudioPlayer()<AVAudioPlayerDelegate>

@property(nonatomic,strong)NSTimer      *countTimer;
@property(nonatomic,strong)AVAudioPlayer    *player;
@end

static  KpengAudioPlayer   *_sharePlayer = nil;
static dispatch_once_t onceToken;
@implementation KpengAudioPlayer


-(BOOL)isPlaying {
    
    if (_player) {
        return YES;
    }
    return NO;
    
}
- (void)setCurrentTimeForPlayer:(NSTimeInterval)currentTime{
    _player.currentTime = currentTime;
    [self countTime];
}

-(void)countTime{
    if(_player && _player.isPlaying){
        if(_delegate && [_delegate respondsToSelector:@selector(getPlayerTime:andTotal:)]){
            [_delegate getPlayerTime:_player.currentTime andTotal:_player.duration];
        }
    }
}

+(KpengAudioPlayer *)sharePLayer{
    dispatch_once(&onceToken, ^{
        _sharePlayer = [KpengAudioPlayer new];
        _sharePlayer.countTimer = [NSTimer timerWithTimeInterval:0.5 target:_sharePlayer selector:@selector(countTime) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_sharePlayer.countTimer forMode:NSDefaultRunLoopMode];
    });
    
    return _sharePlayer;
}

+(void )destruction {
    _sharePlayer = nil;
    onceToken =0;
}


-(void)resume{
    [_player play];
    [_countTimer setFireDate:[NSDate distantPast]];
}

-(void)pause{
    [_player pause];
    [_countTimer setFireDate:[NSDate distantFuture]];
}

-(void)stop{
    [_player stop];
    [_countTimer invalidate];
    _countTimer = nil;
}

-(void)playWithUrl:(NSURL *)url{
    if(_player){
        [_player stop];
        _player = nil;
    }
    NSError *error;
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if(error){
        if(_delegate && [_delegate respondsToSelector:@selector(getPlayerError:)]){
            [_delegate getPlayerError:error];
        }
    }else{
        _player.delegate = self;
        [_player prepareToPlay];
        [_player play];
    }
    
    if(![_countTimer isValid]){
        [_countTimer setFireDate:[NSDate distantPast]];
    }
}

#pragma mark player event
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if(_delegate && [_delegate respondsToSelector:@selector(getAudioPlayerFinished:)]){
        
        [_delegate getAudioPlayerFinished:flag];
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error{
    if(_delegate && [_delegate respondsToSelector:@selector(getPlayerError:)]){
        [_delegate getPlayerError:error];
    }
}

@end

