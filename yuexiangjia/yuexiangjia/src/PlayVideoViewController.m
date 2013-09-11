//
//  PlayVideoViewController.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-25.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "PlayVideoViewController.h"
#import "CommonHeader.h"
#import "CHYSlider.h"
@interface PlayVideoViewController ()

@property (nonatomic, strong)MPMoviePlayerController *player;
@property (nonatomic, strong)UISlider *progressSlider;
@property (nonatomic)double totalTime;
@property (nonatomic) BOOL showPlaying;
@property (nonatomic, strong)NSTimer *progressTimer;
@property (nonatomic, strong)UISlider *volumeSlider;
@property (nonatomic, strong)UIButton *volumeBtn;
@property (nonatomic, strong)UIButton *prevBtn;
@property (nonatomic, strong)UIButton *pauseBtn;
@property (nonatomic, strong)UIButton *nextBtn;
@end

@implementation PlayVideoViewController
@synthesize player;
@synthesize videoUrl, media;
@synthesize totalTime, showPlaying, progressSlider, volumeBtn, volumeSlider;
@synthesize prevBtn, pauseBtn, nextBtn;
@synthesize progressTimer;

- (void)viewDidUnload
{
    [super viewDidUnload];
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
    self.showMiddleBtn = YES;
    [super showToolbar];
    
    NSURL *mediaFileUrl = [[NSURL alloc] initWithString:self.videoUrl];
    if ([AppDelegate instance].moviePlayer) {
        player = [AppDelegate instance].moviePlayer;
    } else {
        player = [[MPMoviePlayerController alloc] initWithContentURL: mediaFileUrl];
        [AppDelegate instance].moviePlayer = player;
    }
    player.controlStyle = MPMovieControlStyleNone;
    player.useApplicationAudioSession = NO;
    if ([AppDelegate instance].iphone5) {
        player.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width);
    } else {
        player.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width * 0.9);
    }
    [player prepareToPlay];
    [self.view addSubview: player.view];
    [player play];
    
    totalTime = media.duration;
    
    UILabel *nameBgLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, player.view.frame.size.height, self.bounds.size.width, 40)];
    nameBgLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    [self.view addSubview:nameBgLabel];
    
    UIImageView *slideBg = [[UIImageView alloc]initWithFrame:CGRectMake(0, player.view.frame.origin.y + player.view.frame.size.height + 40, self.bounds.size.width, 35)];
    slideBg.image = [UIImage imageNamed:@"slider_bg"];
    [self.view addSubview:slideBg];
    
    progressSlider = [[UISlider alloc]initWithFrame:CGRectMake(10, player.view.frame.size.height + 48, self.bounds.size.width - 20, 10)];
    progressSlider.minimumValue = 0;
    progressSlider.maximumValue = 1.0;
    if (showPlaying) {
        progressSlider.value = player.currentPlaybackTime / totalTime;
    } else {
        progressSlider.value = 0;
    }
    [progressSlider addTarget:self action:@selector(sliderTouchDown) forControlEvents:UIControlEventTouchDown];
    [progressSlider addTarget:self action:@selector(sliderTouchUp) forControlEvents:UIControlEventTouchUpInside];
    [progressSlider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:progressSlider];
    
    UIImageView *playBtnBg = [[UIImageView alloc]initWithFrame:CGRectMake(0, slideBg.frame.origin.y + slideBg.frame.size.height-2, self.bounds.size.width, 66)];
    playBtnBg.image = [UIImage imageNamed:@"music_player_bg"];
    [self.view addSubview:playBtnBg];
    
    prevBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    prevBtn.frame = CGRectMake(65, player.view.frame.size.height + 80, 50, 50);
    [prevBtn setBackgroundImage:[UIImage imageNamed:@"tab_rw"] forState:UIControlStateNormal];
    [prevBtn setBackgroundImage:[UIImage imageNamed:@"tab_rw_pressed"] forState:UIControlStateHighlighted];
    [prevBtn addTarget:self action:@selector(prevBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:prevBtn];
    
    pauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    pauseBtn.frame = CGRectMake(135, player.view.frame.size.height + 80, 50, 50);
    [pauseBtn setBackgroundImage:[UIImage imageNamed:@"tab_play"] forState:UIControlStateNormal];
    [pauseBtn setBackgroundImage:[UIImage imageNamed:@"tab_play_pressed"] forState:UIControlStateHighlighted];
    [pauseBtn addTarget:self action:@selector(pauseBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pauseBtn];
    
    nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.frame = CGRectMake(205, player.view.frame.size.height + 80, 50, 50);
    [nextBtn setBackgroundImage:[UIImage imageNamed:@"tab_ff"] forState:UIControlStateNormal];
    [nextBtn setBackgroundImage:[UIImage imageNamed:@"tab_ff_pressed"] forState:UIControlStateHighlighted];
    [nextBtn addTarget:self action:@selector(nextBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextBtn];
    
//    volumeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    volumeBtn.frame = CGRectMake(260, player.view.frame.size.height + 70, 50, 50);
//    [volumeBtn setTitle:@"Volume" forState:UIControlStateNormal];
//    [volumeBtn addTarget:self action:@selector(volumeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:volumeBtn];
    
    progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(process) userInfo:nil repeats:YES];
    
//    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(200, 10, 25, 25)];
//    [volumeView setBackgroundColor:[UIColor clearColor]];
//    [volumeView setShowsVolumeSlider:NO];
//    
//    [self.view addSubview:volumeView];
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
    [MPMusicPlayerController applicationMusicPlayer].volume += value;
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
    if(player.currentPlaybackTime > 0){
        progressSlider.value = player.currentPlaybackTime / totalTime;
    }
}

- (void)nextBtnClicked
{
    if (player.currentPlaybackTime + 30 > totalTime) {
        player.currentPlaybackTime = totalTime;
    } else {
        player.currentPlaybackTime += 30;
    }
}

- (void)pauseBtnClicked
{
    if (player.playbackState == MPMusicPlaybackStatePlaying) {
        [player pause];
        [pauseBtn setBackgroundImage:[UIImage imageNamed:@"tab_play"] forState:UIControlStateNormal];
        [pauseBtn setBackgroundImage:[UIImage imageNamed:@"tab_play_pressed"] forState:UIControlStateHighlighted];
    } else {
        [player play];
        [pauseBtn setBackgroundImage:[UIImage imageNamed:@"tab_pause"] forState:UIControlStateNormal];
        [pauseBtn setBackgroundImage:[UIImage imageNamed:@"tab_pause_pressed"] forState:UIControlStateHighlighted];
        [AppDelegate instance].moviePlayer = player;
    }    
}

- (void)prevBtnClicked
{
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
        [self.view addSubview:volumeSlider];
    }
}

- (void)volumeSliderAction
{
    [MPMusicPlayerController applicationMusicPlayer].volume = volumeSlider.value;
}

- (void)sliderTouchDown
{
    [progressTimer invalidate];
}

- (void)sliderTouchUp
{
    [progressTimer invalidate];
    progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(process) userInfo:nil repeats:YES];
    player.currentPlaybackTime = totalTime * progressSlider.value;
}

- (void)sliderValueChanged
{
    progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(process) userInfo:nil repeats:YES];
    player.currentPlaybackTime = totalTime * progressSlider.value;
}

- (void)backButtonClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)homeButtonClicked
{
    [self dismissViewControllerAnimated:NO completion:^{
        [super homeButtonClicked];
    }];
}

- (void)playBtnClicked
{
    [AppDelegate instance].castingType = YueVideoCasting;
}
@end
