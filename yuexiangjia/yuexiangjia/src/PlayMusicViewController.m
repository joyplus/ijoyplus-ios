//
//  GroupImageViewController.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-21.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "PlayMusicViewController.h"
#import "CommonHeader.h"
#import <AVFoundation/AVFoundation.h> 
#import "CHYSlider.h"
#import "VolumeGesture.h"


@interface PlayMusicViewController ()<VolumeGestureDelegate>

@property (nonatomic, strong)MPMusicPlayerController *musicPlayer;
@property (nonatomic, strong)MPMediaItem *media;
@property (nonatomic, strong)UILabel *nameLabel;
@property (nonatomic, strong)UIImageView *imageView;
@property (nonatomic, strong)UISlider *progressSlider;
@property (nonatomic)double totalMusicTime;
@property (nonatomic, strong)NSTimer *progressTimer;
@property (nonatomic, strong)UISlider *volumeSlider;
@property (nonatomic, strong)UIButton *volumeBtn;
@property (nonatomic, strong)UIButton *prevBtn;
@property (nonatomic, strong)UIButton *pauseBtn;
@property (nonatomic, strong)UIButton *nextBtn;
@property (nonatomic, strong)UIButton *playModeBtn;
@property (nonatomic, strong)UILabel *endTimeLabel;
@property (nonatomic)int currentIndex;
@property (nonatomic, strong)UILabel *artist;
@end

@implementation PlayMusicViewController
@synthesize mediaArray;
@synthesize startIndex, currentIndex, showPlaying;
@synthesize musicPlayer;
@synthesize media;
@synthesize nameLabel, endTimeLabel, artist;
@synthesize imageView;
@synthesize progressSlider;
@synthesize totalMusicTime;
@synthesize progressTimer;
@synthesize playModeBtn, prevBtn, pauseBtn, nextBtn, volumeBtn, volumeSlider;

- (void)viewDidUnload
{
    [super viewDidUnload];
    mediaArray = nil;
    media = nil;
    nameLabel = nil;
    imageView = nil;
    progressSlider = nil;
    progressTimer = nil;
    volumeSlider = nil;
    volumeBtn = nil;
    prevBtn = nil;
    pauseBtn = nil;
    nextBtn = nil;
    playModeBtn = nil;
    endTimeLabel = nil;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = CMConstants.blackBackgroundColor;
    
    musicPlayer = [AppDelegate instance].musicPlayer;
    self.showMiddleBtn = YES;
    [super showToolbar];
    
    if ([AppDelegate instance].iphone5) {
        imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width)];
    } else {
        imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width * 0.9)];
    }
    if (showPlaying) {
        media = musicPlayer.nowPlayingItem;
    } else {
        media = [mediaArray objectAtIndex:startIndex];
    }
    MPMediaItemArtwork *artworkItem = [media valueForProperty: MPMediaItemPropertyArtwork];
    if ([artworkItem imageWithSize:imageView.frame.size]) {
        [imageView setImage:[artworkItem imageWithSize:imageView.frame.size]];
    } else {
        [imageView setImage:[UIImage imageNamed:@"music_default"]];
    }
    [self.view addSubview:imageView];
    
    UILabel *nameBgLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, imageView.frame.size.height, self.bounds.size.width, 40)];
    nameBgLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    [self.view addSubview:nameBgLabel];
    
    nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, imageView.frame.size.height + 3, 250, 25)];
    nameLabel.text = [media valueForProperty: MPMediaItemPropertyTitle];
    nameLabel.font = [UIFont systemFontOfSize:14];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:nameLabel];
    
    artist = [[UILabel alloc]initWithFrame:CGRectMake(10, imageView.frame.size.height + 23, 250, 20)];
    artist.text = [media valueForProperty: MPMediaItemPropertyArtist];
    artist.font = [UIFont systemFontOfSize:13];
    artist.backgroundColor = [UIColor clearColor];
    artist.textColor = [UIColor lightGrayColor];
    [self.view addSubview:artist];
    
    UIImageView *slideBg = [[UIImageView alloc]initWithFrame:CGRectMake(0, imageView.frame.origin.y + imageView.frame.size.height + 40, self.bounds.size.width, 35)];
    slideBg.image = [UIImage imageNamed:@"slider_bg"];
    [self.view addSubview:slideBg];
    
    totalMusicTime = ((NSNumber *)[media valueForKey:MPMediaItemPropertyPlaybackDuration]).doubleValue;
    
    progressSlider = [[UISlider alloc]initWithFrame:CGRectMake(10, imageView.frame.size.height + 48, self.bounds.size.width - 20, 10)];
    progressSlider.minimumValue = 0;
    progressSlider.maximumValue = 1.0;
    if (showPlaying) {
        progressSlider.value = musicPlayer.currentPlaybackTime / totalMusicTime;
    } else {
        progressSlider.value = 0;
    }
    [progressSlider addTarget:self action:@selector(sliderTouchDown) forControlEvents:UIControlEventTouchDown];
    [progressSlider addTarget:self action:@selector(sliderTouchUp) forControlEvents:UIControlEventTouchUpInside];
    [progressSlider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:progressSlider];
    
    UIImageView *musicBg = [[UIImageView alloc]initWithFrame:CGRectMake(0, slideBg.frame.origin.y + slideBg.frame.size.height-2, self.bounds.size.width, 66)];
    musicBg.image = [UIImage imageNamed:@"music_player_bg"];
    [self.view addSubview:musicBg];
    
    playModeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    playModeBtn.frame = CGRectMake(5, imageView.frame.size.height + 80, 50, 50);
    [prevBtn setBackgroundImage:[UIImage imageNamed:@"tab_rw"] forState:UIControlStateNormal];
    [prevBtn setBackgroundImage:[UIImage imageNamed:@"tab_rw_pressed"] forState:UIControlStateHighlighted];
    [playModeBtn addTarget:self action:@selector(playModeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playModeBtn];
    
    prevBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    prevBtn.frame = CGRectMake(65, imageView.frame.size.height + 80, 50, 50);
    [prevBtn setBackgroundImage:[UIImage imageNamed:@"tab_rw"] forState:UIControlStateNormal];
    [prevBtn setBackgroundImage:[UIImage imageNamed:@"tab_rw_pressed"] forState:UIControlStateHighlighted];
    [prevBtn addTarget:self action:@selector(prevBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:prevBtn];
    
    pauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    pauseBtn.frame = CGRectMake(135, imageView.frame.size.height + 80, 50, 50);
    [pauseBtn setBackgroundImage:[UIImage imageNamed:@"tab_play"] forState:UIControlStateNormal];
    [pauseBtn setBackgroundImage:[UIImage imageNamed:@"tab_play_pressed"] forState:UIControlStateHighlighted];
    [pauseBtn addTarget:self action:@selector(pauseBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pauseBtn];
    
    nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.frame = CGRectMake(205, imageView.frame.size.height + 80, 50, 50);
    [nextBtn setBackgroundImage:[UIImage imageNamed:@"tab_ff"] forState:UIControlStateNormal];
    [nextBtn setBackgroundImage:[UIImage imageNamed:@"tab_ff_pressed"] forState:UIControlStateHighlighted];
    [nextBtn addTarget:self action:@selector(nextBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextBtn];
    
//    volumeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    volumeBtn.frame = CGRectMake(260, imageView.frame.size.height + 70, 50, 50);
//    [volumeBtn setTitle:@"Volume" forState:UIControlStateNormal];
//    [volumeBtn addTarget:self action:@selector(volumeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:volumeBtn];
    
    progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(process) userInfo:nil repeats:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (musicPlayStateChanged:) name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil];
    if (!showPlaying) {
        [NSThread detachNewThreadSelector:@selector(startMusicPlayer) toTarget:self withObject:nil];
    }
    [self addGestureOnView];
    
    endTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.bounds.size.width - 70, imageView.frame.size.height + 8, 60, 30)];
    endTimeLabel.font = [UIFont systemFontOfSize:12];
    endTimeLabel.textAlignment = NSTextAlignmentRight;
    endTimeLabel.text = @"00:00";
    endTimeLabel.textColor = [UIColor lightGrayColor];
    endTimeLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:endTimeLabel];
    
    [AppDelegate instance].castingType = YueVideoCasting;
}

- (void)addGestureOnView
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    tapGesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGesture];
    
    UISwipeGestureRecognizer *nextGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(nextBtnClicked)];
    nextGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    nextGesture.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:nextGesture];
    
    UISwipeGestureRecognizer *prevGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(prevBtnClicked)];
    prevGesture.direction = UISwipeGestureRecognizerDirectionRight;
    prevGesture.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:prevGesture];
    
//    VolumeGesture *volumeUpGesture = [[VolumeGesture alloc]initWithTarget:self action:nil];
//    volumeUpGesture.delegate = self;
//    [self.view addGestureRecognizer:volumeUpGesture];
}

- (void)changeVolume:(float)value
{
    musicPlayer.volume += value;
}

- (void)tapAction
{
    if (volumeSlider.hidden) {
        [pauseBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    volumeSlider.hidden = YES;
}

-(void)process
{
    if(musicPlayer.currentPlaybackTime > 0){
        progressSlider.value = musicPlayer.currentPlaybackTime / totalMusicTime;
        endTimeLabel.text = [NSString stringWithFormat:@"-%@", [TimeUtility formatTimeInSecond:totalMusicTime - musicPlayer.currentPlaybackTime]];
    }
}

- (void)musicPlayStateChanged:(NSNotification *)aNotification
{
    [self showMusicDetail];
}

- (void)validateCurrentIndex
{
    if (currentIndex < 0) {
        currentIndex = mediaArray.count -1;
    } else if (currentIndex >= mediaArray.count){
        currentIndex = 0;
    }
}
- (void)prevBtnClicked
{
    currentIndex--;
    [self validateCurrentIndex];
    [musicPlayer skipToPreviousItem];
    if ([musicPlayer nowPlayingItem]) {
        [self showMusicDetail];
        if (musicPlayer.playbackState != MPMusicPlaybackStatePlaying) {
            [musicPlayer play];
        }
    } else {
        [self updatePlayCollections];
    }
}

- (void)updatePlayCollections
{
    [musicPlayer stop];
    NSMutableArray *playingItems = [[NSMutableArray alloc]initWithCapacity:mediaArray.count];
    [playingItems addObjectsFromArray: [mediaArray subarrayWithRange: NSMakeRange(currentIndex, mediaArray.count - currentIndex)]];
    [playingItems addObjectsFromArray: [mediaArray subarrayWithRange: NSMakeRange(0, currentIndex)]];
    [musicPlayer setQueueWithItemCollection:[MPMediaItemCollection collectionWithItems:playingItems]];
    [musicPlayer play];
}

- (void)pauseBtnClicked
{
    if (musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
        [musicPlayer pause];
        [pauseBtn setBackgroundImage:[UIImage imageNamed:@"tab_play"] forState:UIControlStateNormal];
        [pauseBtn setBackgroundImage:[UIImage imageNamed:@"tab_play_pressed"] forState:UIControlStateHighlighted];
    } else {
        [musicPlayer play];
        [pauseBtn setBackgroundImage:[UIImage imageNamed:@"tab_pause"] forState:UIControlStateNormal];
        [pauseBtn setBackgroundImage:[UIImage imageNamed:@"tab_pause_pressed"] forState:UIControlStateHighlighted];
    }
    
}

- (void)nextBtnClicked
{
    currentIndex++;
    [self validateCurrentIndex];
    [musicPlayer skipToNextItem];
    if ([musicPlayer nowPlayingItem]) {
        [self showMusicDetail];
        if (musicPlayer.playbackState != MPMusicPlaybackStatePlaying) {
            [musicPlayer play];
        }
    } else {
        [self updatePlayCollections];
    }
}

- (void)volumeBtnClicked
{
    volumeSlider.hidden = !volumeSlider.hidden;
    if (volumeSlider == nil) {
        volumeSlider = [[UISlider alloc]initWithFrame:CGRectMake(volumeBtn.frame.origin.x - 80, volumeBtn.frame.origin.y - 100, 200, 5)];
        volumeSlider.minimumValue = 0;
        volumeSlider.maximumValue = 1;
        volumeSlider.value = musicPlayer.volume;
        [volumeSlider addTarget:self action:@selector(volumeSliderAction) forControlEvents:UIControlEventValueChanged];
        volumeSlider.backgroundColor = [UIColor clearColor];
        UIImage *stetchTrack = [[UIImage imageNamed:@"faderTrack.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
        [volumeSlider setThumbImage: [UIImage imageNamed:@"faderKey.png"] forState:UIControlStateNormal];
        [volumeSlider setMinimumTrackImage:stetchTrack forState:UIControlStateNormal];
        [volumeSlider setMaximumTrackImage:stetchTrack forState:UIControlStateNormal];
        CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI * -0.5);
        volumeSlider.transform = trans;
        [self.view addSubview:volumeSlider];
    }
}

- (void)volumeSliderAction
{
    musicPlayer.volume = volumeSlider.value;
}

- (void)showMusicDetail
{
    MPMediaItemArtwork *artworkItem = [musicPlayer.nowPlayingItem valueForProperty: MPMediaItemPropertyArtwork];
    if ([artworkItem imageWithSize:imageView.frame.size]) {
        [imageView setImage:[artworkItem imageWithSize:imageView.frame.size]];
    } else {
        [imageView setImage:[UIImage imageNamed:@"NoArtworkImage"]];
    }
    nameLabel.text = [musicPlayer.nowPlayingItem valueForProperty: MPMediaItemPropertyTitle];
    artist.text = [musicPlayer.nowPlayingItem valueForProperty: MPMediaItemPropertyArtist];
    totalMusicTime = ((NSNumber *)[musicPlayer.nowPlayingItem valueForKey:MPMediaItemPropertyPlaybackDuration]).doubleValue;
}

- (void)startMusicPlayer
{
    [self setPlayMode];
    NSMutableArray *playingItems = [[NSMutableArray alloc]initWithCapacity:mediaArray.count];
    [playingItems addObjectsFromArray: [mediaArray subarrayWithRange: NSMakeRange(startIndex, mediaArray.count - startIndex)]];
    [playingItems addObjectsFromArray: [mediaArray subarrayWithRange: NSMakeRange(0, startIndex)]];
    [musicPlayer setQueueWithItemCollection:[MPMediaItemCollection collectionWithItems:playingItems]];
    [musicPlayer play];
    [musicPlayer beginGeneratingPlaybackNotifications];
}

- (void)playModeBtnClicked
{
    [AppDelegate instance].musicRepeatMode = ([AppDelegate instance].musicRepeatMode + 1)%3;
    [self setPlayMode];
    NSLog(@"%i", [AppDelegate instance].musicRepeatMode);
}

- (void)setPlayMode
{
    int repeateMode = [AppDelegate instance].musicRepeatMode;
    if (repeateMode == 0) {
        [musicPlayer setShuffleMode: MPMusicShuffleModeOff];
        [musicPlayer setRepeatMode: MPMusicRepeatModeAll];
        [playModeBtn setBackgroundImage:[UIImage imageNamed:@"cycle_list"] forState:UIControlStateNormal];
    } else if(repeateMode == 1) {
        [musicPlayer setShuffleMode: MPMusicShuffleModeOff];
        [musicPlayer setRepeatMode: MPMusicRepeatModeOne];
        [playModeBtn setBackgroundImage:[UIImage imageNamed:@"cycle_single"] forState:UIControlStateNormal];
    }else if(repeateMode == 2) {
        [musicPlayer setShuffleMode: MPMusicShuffleModeSongs];
        [musicPlayer setRepeatMode: MPMusicRepeatModeAll];
        [playModeBtn setBackgroundImage:[UIImage imageNamed:@"tab_random"] forState:UIControlStateNormal];
    }
}

- (void)sliderTouchDown
{
    [progressTimer invalidate];
}

- (void)sliderTouchUp
{
    [progressTimer invalidate];
    progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(process) userInfo:nil repeats:YES];
}

- (void)sliderValueChanged
{
    [progressTimer invalidate];
    progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(process) userInfo:nil repeats:YES];
    musicPlayer.currentPlaybackTime = totalMusicTime * progressSlider.value;
}

- (void)backButtonClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)homeButtonClicked
{
    [self dismissViewControllerAnimated:NO completion:nil];
    [super homeButtonClicked];
}


- (void)playBtnClicked
{
    [AppDelegate instance].castingType = YueMusicCasting;
}

@end
