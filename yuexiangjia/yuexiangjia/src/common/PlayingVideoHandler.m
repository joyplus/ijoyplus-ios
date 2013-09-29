//
//  PlayingVideoHandler.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-28.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "PlayingVideoHandler.h"
#import "CommonHeader.h"

@interface PlayingVideoHandler ()

@property (nonatomic, strong) NSTimer *videoProgressTimer;
@property (nonatomic, strong) UILabel *videoDurationLabel;
@property (nonatomic, strong)UISlider *volumeSlider;
@property (nonatomic, strong)UIButton *volumeBtn;
@end

@implementation PlayingVideoHandler
@synthesize videoProgressTimer;
@synthesize videoDurationLabel;
@synthesize volumeSlider;
@synthesize volumeBtn;

//============== Video Part Start ================

- (void)removeVideoContainer
{
    UIView *homeView = [[AppDelegate instance].rootViewController.view viewWithTag:HOME_VIEW_TAG];
    UIView *videoContainer = [homeView viewWithTag:HOME_VIDEO_CONTAINER_TAG];
    if (videoContainer) {
        [videoProgressTimer invalidate];
        videoProgressTimer = nil;
        [videoContainer removeFromSuperview];
        videoContainer = nil;
    }
}

- (void)showPlayingVideoContainer
{
    MPMoviePlayerController *player = [AppDelegate instance].moviePlayer;
    [self removeVideoContainer];
    if (player) {
        CGRect bounds = [UIScreen mainScreen].bounds;
        UIView *videoContainer = [[UIView alloc]initWithFrame:CGRectMake(14, bounds.size.height - 120, GRID_VIEW_WIDTH - 7, 97)];
        videoContainer.tag = HOME_VIDEO_CONTAINER_TAG;
        videoContainer.backgroundColor = [UIColor clearColor];
        UIView *homeView = [[AppDelegate instance].rootViewController.view viewWithTag:HOME_VIEW_TAG];
        [homeView addSubview:videoContainer];
        
        UIImageView *placeholderImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, videoContainer.frame.size.width, videoContainer.frame.size.height)];
        placeholderImage.image = [UIImage imageNamed:@"player_bg"];
        [videoContainer addSubview:placeholderImage];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, 5, 100, 30)];
        titleLabel.text = @"正在播放";
        titleLabel.backgroundColor = [UIColor clearColor];
        [titleLabel sizeToFit];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont systemFontOfSize:14];
        [videoContainer addSubview:titleLabel];
        
        videoDurationLabel = [[UILabel alloc]initWithFrame:CGRectMake(GRID_VIEW_WIDTH - 50, 5, 40, 30)];
        videoDurationLabel.text = [NSString stringWithFormat:@"-%@", [TimeUtility formatTimeInSecond:player.duration - player.currentPlaybackTime]];
        videoDurationLabel.font = [UIFont systemFontOfSize:13];
        videoDurationLabel.textColor = [UIColor whiteColor];
        videoDurationLabel.backgroundColor = [UIColor clearColor];
        [videoDurationLabel sizeToFit];
        [videoContainer addSubview:videoDurationLabel];
        
        //        videoNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 60, 30)];
        //        videoNameLabel.text = @"未知";
        //        videoNameLabel.font = [UIFont systemFontOfSize:13];
        //        [videoDurationLabel addSubview:videoNameLabel];
        
        UIButton *prevBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        prevBtn.frame = CGRectMake(55, 50, 40, 40);
        [prevBtn setBackgroundImage:[UIImage imageNamed:@"tab_rw"] forState:UIControlStateNormal];
        [prevBtn setBackgroundImage:[UIImage imageNamed:@"tab_rw_pressed"] forState:UIControlStateHighlighted];
        [prevBtn addTarget:self action:@selector(prevBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [videoContainer addSubview:prevBtn];
        
        UIButton *pauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        pauseBtn.frame = CGRectMake(95, 50, 40, 40);
        [pauseBtn setBackgroundImage:[UIImage imageNamed:@"tab_pause"] forState:UIControlStateNormal];
        [pauseBtn setBackgroundImage:[UIImage imageNamed:@"tab_pause_pressed"] forState:UIControlStateHighlighted];
        [pauseBtn addTarget:self action:@selector(pauseBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [videoContainer addSubview:pauseBtn];
        
        UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        nextBtn.frame = CGRectMake(130, 50, 40, 40);
        [nextBtn setBackgroundImage:[UIImage imageNamed:@"tab_ff"] forState:UIControlStateNormal];
        [nextBtn setBackgroundImage:[UIImage imageNamed:@"tab_ff_pressed"] forState:UIControlStateHighlighted];
        [nextBtn addTarget:self action:@selector(nextBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [videoContainer addSubview:nextBtn];
        
//        volumeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        volumeBtn.frame = CGRectMake(180, 40, 50, 50);
//        [volumeBtn setTitle:@"Volume" forState:UIControlStateNormal];
//        [volumeBtn addTarget:self action:@selector(volumeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
//        [videoContainer addSubview:volumeBtn];
        
        videoProgressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateVideoPlaybackTime) userInfo:nil repeats:YES];
    }
}

- (void)updateVideoPlaybackTime
{
    MPMoviePlayerController *player = [AppDelegate instance].moviePlayer;
    videoDurationLabel.text = [NSString stringWithFormat:@"-%@", [TimeUtility formatTimeInSecond:player.duration - player.currentPlaybackTime]];
}


- (void)nextBtnClicked
{
    MPMoviePlayerController *player = [AppDelegate instance].moviePlayer;
    if (player.currentPlaybackTime + 30 > player.duration) {
        player.currentPlaybackTime = player.duration;
    } else {
        player.currentPlaybackTime += 30;
    }
}

- (void)pauseBtnClicked:(UIButton *)btn
{
    MPMoviePlayerController *player = [AppDelegate instance].moviePlayer;
    if (player.playbackState == MPMusicPlaybackStatePlaying) {
        [player pause];
        [btn setBackgroundImage:[UIImage imageNamed:@"tab_play"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"tab_play_pressed"] forState:UIControlStateHighlighted];
    } else {
        [player play];
        [btn setBackgroundImage:[UIImage imageNamed:@"tab_pause"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"tab_pause_pressed"] forState:UIControlStateHighlighted];
    }
}

- (void)prevBtnClicked
{
    MPMoviePlayerController *player = [AppDelegate instance].moviePlayer;
    if (player.currentPlaybackTime - 30 < 0) {
        player.currentPlaybackTime = 0;
    } else {
        player.currentPlaybackTime -= 30;
    }
}

- (void)volumeBtnClicked
{
    volumeSlider.hidden = !volumeSlider.hidden;
    if (volumeSlider == nil) {
        volumeSlider = [[UISlider alloc]initWithFrame:CGRectMake(volumeBtn.frame.origin.x - 80, volumeBtn.frame.origin.y - 100, 200, 5)];
        volumeSlider.minimumValue = 0;
        volumeSlider.maximumValue = 1;
        volumeSlider.value = [MPMusicPlayerController applicationMusicPlayer].volume;
        [volumeSlider addTarget:self action:@selector(volumeSliderAction) forControlEvents:UIControlEventValueChanged];
        volumeSlider.backgroundColor = [UIColor clearColor];
        UIImage *stetchTrack = [[UIImage imageNamed:@"faderTrack.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
        [volumeSlider setThumbImage: [UIImage imageNamed:@"faderKey.png"] forState:UIControlStateNormal];
        [volumeSlider setMinimumTrackImage:stetchTrack forState:UIControlStateNormal];
        [volumeSlider setMaximumTrackImage:stetchTrack forState:UIControlStateNormal];
        CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI * -0.5);
        volumeSlider.transform = trans;
        
        UIView *homeView = [[AppDelegate instance].rootViewController.view viewWithTag:HOME_VIEW_TAG];
        UIView *videoContainer = [homeView viewWithTag:HOME_VIDEO_CONTAINER_TAG];
        [videoContainer addSubview:volumeSlider];
    }
}

- (void)volumeSliderAction
{
    [MPMusicPlayerController applicationMusicPlayer].volume = volumeSlider.value;
}


//============== Video Part End==================


@end
