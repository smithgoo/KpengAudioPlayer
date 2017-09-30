//
//  KpengAudioPlayer.m
//  SingDemo
//
//  Created by 王朋 on 2017/9/30.
//  Copyright © 2017年 王朋. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KpengAudioPlayerDelegate <NSObject>

-(void)getPlayerTime:(NSTimeInterval )time andTotal:(NSTimeInterval)totalTime;

-(void)getAudioPlayerFinished:(BOOL)success;

-(void)getPlayerError:(NSError *)error;

@end

@interface KpengAudioPlayer : NSObject

@property(nonatomic,weak)id<KpengAudioPlayerDelegate> delegate;

+(KpengAudioPlayer *)sharePLayer;

+(void )destruction;

-(void)playWithUrl:(NSURL *)url;

-(void)pause;

-(void)resume;

-(void)stop;


-(BOOL)isPlaying;

- (void)setCurrentTimeForPlayer:(NSTimeInterval)currentTime;

@end

