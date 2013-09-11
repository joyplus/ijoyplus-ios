//
//  PlayingMusicHandler.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-28.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "PlayingMusicHandler.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CommonHeader.h"

@interface PlayingMusicHandler ()

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *homeButton;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UILabel *musicDurationLabel;
@property (nonatomic, strong) NSTimer *musicProgressTimer;
@property (nonatomic, strong) UILabel *musicNameLabel;
@property (nonatomic, strong) NSArray *musicArray;
@property (nonatomic, strong)UISlider *volumeSlider;
@property (nonatomic, strong)UIButton *volumeBtn;
@property (nonatomic)int currentIndex;

@end

@implementation PlayingMusicHandler
@synthesize backButton, homeButton, playButton;
@synthesize musicDurationLabel;
@synthesize musicProgressTimer;
@synthesize musicNameLabel;
@synthesize musicArray;
@synthesize currentIndex;
@synthesize volumeSlider;
@synthesize volumeBtn;


//===================== Music part =======================
- (void)removeMusicContainer
{
    UIView *homeView = [[AppDelegate instance].rootViewController.view viewWithTag:HOME_VIEW_TAG];
    UIView *musicContainer = [homeView viewWithTag:HOME_MUSIC_CONTAINER_TAG];
    if (musicContainer) {
        [musicProgressTimer invalidate];
        musicProgressTimer = nil;
        musicNameLabel = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil];
        [musicContainer removeFromSuperview];
        musicContainer = nil;
    }
}

- (void)showPlayingMusicContainer
{
    MPMusicPlayerController *musicPlayer = [AppDelegate instance].musicPlayer;
    [self removeMusicContainer];
    if (musicPlayer.playbackState == MPMoviePlaybackStatePlaying) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (musicPlayStateChanged:) name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil];
        MPMediaQuery *query = [MPMediaQuery songsQuery];
        musicArray = [query items];
        currentIndex = [musicArray indexOfObject:musicPlayer.nowPlayingItem];
        CGRect bounds = [UIScreen mainScreen].bounds;
        UIView *musicContainer = [[UIView alloc]initWithFrame:CGRectMake(14, bounds.size.height - 120, GRID_VIEW_WIDTH - 7, 97)];
        musicContainer.tag = HOME_MUSIC_CONTAINER_TAG;
        musicContainer.backgroundColor = [UIColor clearColor];
        UIView *homeView = [[AppDelegate instance].rootViewController.view viewWithTag:HOME_VIEW_TAG];
        [homeView addSubview:musicContainer];
        
        UIImageView *placeholderImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, musicContainer.frame.size.width, musicContainer.frame.size.height)];
        placeholderImage.image = [UIImage imageNamed:@"player_bg"];
        [musicContainer addSubview:placeholderImage];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, 5, 100, 30)];
        titleLabel.text = @"正在播放";
        titleLabel.backgroundColor = [UIColor clearColor];
        [titleLabel sizeToFit];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont systemFontOfSize:14];
        [musicContainer addSubview:titleLabel];
        
        UIImageView *playSign = [[UIImageView alloc]initWithFrame:CGRectMake(10, 28, 7, 11)];
        playSign.image = [UIImage imageNamed:@"playing_sign"];
        [musicContainer addSubview:playSign];
        
        MPMediaItem *media = [musicPlayer nowPlayingItem];
        musicDurationLabel = [[UILabel alloc]initWithFrame:CGRectMake(GRID_VIEW_WIDTH - 50, 5, 40, 30)];
        musicDurationLabel.textAlignment = UITextAlignmentRight;
        NSNumber *durationNum = (NSNumber *)[media valueForProperty:MPMediaItemPropertyPlaybackDuration];
        musicDurationLabel.text = [NSString stringWithFormat:@"-%@", [TimeUtility formatTimeInSecond:durationNum.doubleValue - musicPlayer.currentPlaybackTime]];
        musicDurationLabel.font = [UIFont systemFontOfSize:13];
        musicDurationLabel.textColor = [UIColor whiteColor];
        musicDurationLabel.backgroundColor = [UIColor clearColor];
        [musicDurationLabel sizeToFit];
        [musicContainer addSubview:musicDurationLabel];
        
        musicNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(25, 25, 150, 30)];
        musicNameLabel.text = [media valueForProperty: MPMediaItemPropertyTitle];
        musicNameLabel.font = [UIFont systemFontOfSize:13];
        musicNameLabel.textColor = [UIColor whiteColor];
        musicNameLabel.backgroundColor = [UIColor clearColor];
        [musicNameLabel sizeToFit];
        [musicContainer addSubview:musicNameLabel];
        
        UIButton *playModeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        playModeBtn.frame = CGRectMake(10, 50, 40, 40);
        [playModeBtn setTintColor:[UIColor blackColor]];
        [playModeBtn setBackgroundImage:[UIImage imageNamed:@"cycle_list"] forState:UIControlStateNormal];
        [playModeBtn addTarget:self action:@selector(playModeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [musicContainer addSubview:playModeBtn];
        
        UIButton *prevBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        prevBtn.frame = CGRectMake(55, 50, 40, 40);
        [prevBtn setBackgroundImage:[UIImage imageNamed:@"tab_rw"] forState:UIControlStateNormal];
        [prevBtn setBackgroundImage:[UIImage imageNamed:@"tab_rw_pressed"] forState:UIControlStateHighlighted];
        [prevBtn addTarget:self action:@selector(prevBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [musicContainer addSubview:prevBtn];
        
        UIButton *pauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        pauseBtn.frame = CGRectMake(95, 50, 40, 40);
        [pauseBtn setBackgroundImage:[UIImage imageNamed:@"tab_pause"] forState:UIControlStateNormal];
        [pauseBtn setBackgroundImage:[UIImage imageNamed:@"tab_pause_pressed"] forState:UIControlStateHighlighted];
        [pauseBtn addTarget:self action:@selector(pauseBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [musicContainer addSubview:pauseBtn];
        
        UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        nextBtn.frame = CGRectMake(130, 50, 40, 40);
        [nextBtn setBackgroundImage:[UIImage imageNamed:@"tab_ff"] forState:UIControlStateNormal];
        [nextBtn setBackgroundImage:[UIImage imageNamed:@"tab_ff_pressed"] forState:UIControlStateHighlighted];
        [nextBtn addTarget:self action:@selector(nextBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [musicContainer addSubview:nextBtn];
        
//        volumeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        volumeBtn.frame = CGRectMake(260, 40, 50, 50);
//        [volumeBtn setTitle:@"Volume" forState:UIControlStateNormal];
//        [volumeBtn addTarget:self action:@selector(volumeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
//        [musicContainer addSubview:volumeBtn];
        
        musicProgressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateMusicPlaybackTime) userInfo:nil repeats:YES];
    }
}

- (void)updateMusicPlaybackTime
{
    MPMusicPlayerController *musicPlayer = [AppDelegate instance].musicPlayer;
    MPMediaItem *media = [musicPlayer nowPlayingItem];
    NSNumber *durationNum = (NSNumber *)[media valueForProperty:MPMediaItemPropertyPlaybackDuration];
    musicDurationLabel.text = [NSString stringWithFormat:@"-%@", [TimeUtility formatTimeInSecond:durationNum.doubleValue - musicPlayer.currentPlaybackTime]];
}

- (void)musicPlayStateChanged:(NSNotification *)aNotification
{
    MPMusicPlayerController *musicPlayer = [AppDelegate instance].musicPlayer;
    musicNameLabel.text = [musicPlayer.nowPlayingItem valueForProperty: MPMediaItemPropertyTitle];
}

- (void)playModeBtnClicked:(UIButton *)btn
{
    [AppDelegate instance].musicRepeatMode = ([AppDelegate instance].musicRepeatMode + 1)%3;
    [self setPlayMode:btn];
    NSLog(@"%i", [AppDelegate instance].musicRepeatMode);
}

- (void)setPlayMode:(UIButton *)btn
{
    MPMusicPlayerController *musicPlayer = [AppDelegate instance].musicPlayer;
    int repeateMode = [AppDelegate instance].musicRepeatMode;
    if (repeateMode == 0) {
        [musicPlayer setShuffleMode: MPMusicShuffleModeOff];
        [musicPlayer setRepeatMode: MPMusicRepeatModeAll];
        [btn setBackgroundImage:[UIImage imageNamed:@"cycle_list"] forState:UIControlStateNormal];
    } else if(repeateMode == 1) {
        [musicPlayer setShuffleMode: MPMusicShuffleModeOff];
        [musicPlayer setRepeatMode: MPMusicRepeatModeOne];
        [btn setBackgroundImage:[UIImage imageNamed:@"cycle_single"] forState:UIControlStateNormal];
    }else if(repeateMode == 2) {
        [musicPlayer setShuffleMode: MPMusicShuffleModeSongs];
        [musicPlayer setRepeatMode: MPMusicRepeatModeAll];
        [btn setBackgroundImage:[UIImage imageNamed:@"tab_random"] forState:UIControlStateNormal];
    }
//    } else if(repeateMode == 3){
//        [musicPlayer setShuffleMode: MPMusicShuffleModeOff];
//        [musicPlayer setRepeatMode: MPMusicRepeatModeNone];
//    }
}

- (void)prevBtnClicked
{
    currentIndex--;
    [self validateCurrentIndex];
    MPMusicPlayerController *musicPlayer = [AppDelegate instance].musicPlayer;
    [musicPlayer skipToPreviousItem];
    if ([musicPlayer nowPlayingItem]) {
        if (musicPlayer.playbackState != MPMusicPlaybackStatePlaying) {
            [musicPlayer play];
        }
    } else {
        [self updatePlayCollections];
    }
    musicNameLabel.text = [musicPlayer.nowPlayingItem valueForProperty: MPMediaItemPropertyTitle];
}


- (void)pauseBtnClicked:(UIButton *)btn
{
    MPMusicPlayerController *musicPlayer = [AppDelegate instance].musicPlayer;
    if (musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
        [btn setBackgroundImage:[UIImage imageNamed:@"tab_play"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"tab_play_pressed"] forState:UIControlStateHighlighted];
        [musicPlayer pause];
    } else {
        [musicPlayer play];
        [btn setBackgroundImage:[UIImage imageNamed:@"tab_pause"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"tab_pause_pressed"] forState:UIControlStateHighlighted];
    }
    
}

- (void)nextBtnClicked
{
    currentIndex++;
    [self validateCurrentIndex];
    MPMusicPlayerController *musicPlayer = [AppDelegate instance].musicPlayer;
    [musicPlayer skipToNextItem];
    if ([musicPlayer nowPlayingItem]) {
        if (musicPlayer.playbackState != MPMusicPlaybackStatePlaying) {
            [musicPlayer play];
        }
    } else {
        [self updatePlayCollections];
    }
    musicNameLabel.text = [musicPlayer.nowPlayingItem valueForProperty: MPMediaItemPropertyTitle];
}

- (void)updatePlayCollections
{
    MPMusicPlayerController *musicPlayer = [AppDelegate instance].musicPlayer;
    [musicPlayer stop];
    NSMutableArray *playingItems = [[NSMutableArray alloc]initWithCapacity:musicArray.count];
    [playingItems addObjectsFromArray: [musicArray subarrayWithRange: NSMakeRange(currentIndex, musicArray.count - currentIndex)]];
    [playingItems addObjectsFromArray: [musicArray subarrayWithRange: NSMakeRange(0, currentIndex)]];
    [musicPlayer setQueueWithItemCollection:[MPMediaItemCollection collectionWithItems:playingItems]];
    [musicPlayer play];
}

- (void)validateCurrentIndex
{
    if (currentIndex < 0) {
        currentIndex = musicArray.count -1;
    } else if (currentIndex >= musicArray.count){
        currentIndex = 0;
    }
}

- (void)volumeBtnClicked
{
    volumeSlider.hidden = !volumeSlider.hidden;
    if (volumeSlider == nil) {
        volumeSlider = [[UISlider alloc]initWithFrame:CGRectMake(volumeBtn.frame.origin.x - 80, volumeBtn.frame.origin.y - 100, 200, 5)];
        volumeSlider.minimumValue = 0;
        volumeSlider.maximumValue = 1;
        volumeSlider.value = [AppDelegate instance].musicPlayer.volume;
        [volumeSlider addTarget:self action:@selector(volumeSliderAction) forControlEvents:UIControlEventValueChanged];
        volumeSlider.backgroundColor = [UIColor clearColor];
        UIImage *stetchTrack = [[UIImage imageNamed:@"faderTrack.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
        [volumeSlider setThumbImage: [UIImage imageNamed:@"faderKey.png"] forState:UIControlStateNormal];
        [volumeSlider setMinimumTrackImage:stetchTrack forState:UIControlStateNormal];
        [volumeSlider setMaximumTrackImage:stetchTrack forState:UIControlStateNormal];
        CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI * -0.5);
        volumeSlider.transform = trans;
        
        UIView *homeView = [[AppDelegate instance].rootViewController.view viewWithTag:HOME_VIEW_TAG];
        UIView *musicContainer = [homeView viewWithTag:HOME_MUSIC_CONTAINER_TAG];
        [musicContainer addSubview:volumeSlider];
    }
}

//============== Music Part End==================
@end
