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

@property (nonatomic, strong)UIView * playControlView;
@property (nonatomic, strong)MPMoviePlayerController *player;
@property (nonatomic, strong)UISlider *progressSlider;
@property (nonatomic)double totalTime;
@property (nonatomic) BOOL showPlaying;
@property (nonatomic, strong)NSTimer *progressTimer;
@property (nonatomic, strong)NSTimer *controlTimer;
@property (nonatomic, strong)UISlider *volumeSlider;
@property (nonatomic, strong)UIButton *volumeBtn;
@property (nonatomic, strong)UIButton *prevBtn;
@property (nonatomic, strong)UIButton *pauseBtn;
@property (nonatomic, strong)UIButton *nextBtn;
@property (nonatomic, strong)UILabel  *curPlaybackTime;
@property (nonatomic, strong)UILabel  *playbackDuration;
@property (nonatomic, strong)UILabel  *filmName;
@property (nonatomic, strong)UIImageView *innerProgress;

- (void)customPlayerView;
- (void)setProgressValue:(CGFloat)value;
- (NSString *)getTimeString:(NSInteger)playbackTime;
- (void)setControlTimer;
- (void)manageControlBtn;
- (void)resetPlayControlView;

@end

@implementation PlayVideoViewController
@synthesize player;
@synthesize playList, media;
@synthesize totalTime, showPlaying, progressSlider, volumeBtn, volumeSlider;
@synthesize prevBtn, pauseBtn, nextBtn;
@synthesize progressTimer;
@synthesize playControlView,innerProgress;
@synthesize filmName,playbackDuration,curPlaybackTime;
@synthesize controlTimer;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [progressTimer invalidate];
    progressTimer = nil;
    [controlTimer invalidate];
    controlTimer = nil;
    progressSlider = nil;
    playControlView = nil;
    volumeBtn = nil;
    nextBtn = nil;
    prevBtn = nil;
    pauseBtn = nil;
    curPlaybackTime = nil;
    playbackDuration = nil;
    filmName = nil;
    innerProgress = nil;
    
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
    
    [self showBackBtnForNavController];
    [self showAvplayerBtn];
    
    NSURL *mediaFileUrl = [[NSURL alloc] initWithString:media.mediaURL];
    if ([AppDelegate instance].moviePlayer) {
        player = [AppDelegate instance].moviePlayer;        
    } else {
        player = [[MPMoviePlayerController alloc] initWithContentURL: mediaFileUrl];
        [AppDelegate instance].moviePlayer = player;
    }
    if ([AppDelegate instance].videoMedia == nil || ![[AppDelegate instance].videoMedia.mediaURL isEqualToString:media.mediaURL]) {
        player.contentURL = mediaFileUrl;
        player.controlStyle = MPMovieControlStyleNone;
        player.useApplicationAudioSession = NO;
        player.view.frame = CGRectMake(0, -32, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 20);
        [player prepareToPlay];
        [player play];
    }
    [self.view addSubview: player.view];
    [AppDelegate instance].videoMedia = media;
    totalTime = media.duration;
    
    self.navigationController.navigationBar.alpha = 0.8;
    
    [self customPlayerView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backButtonClicked)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [progressTimer fire];
    playbackDuration.text = [self getTimeString:player.duration];
}

- (BOOL) canBecomeFirstResponder
{
    return YES;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
}

- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [pauseBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [nextBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                [prevBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
            default:
                break;
        }
    }
}

#pragma mark -
#pragma mark - Private

- (void)customPlayerView
{
    
    UIButton * bgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bgBtn.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 20 - 32);
    bgBtn.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bgBtn];
    [bgBtn addTarget:self
              action:@selector(playerViewTap)
    forControlEvents:UIControlEventTouchUpInside];
    
    playControlView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 20 - 32)];
    [self.view addSubview:playControlView];
    playControlView.backgroundColor = [UIColor clearColor];
    playControlView.alpha = 0.8;
    
    UIButton * cBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cBtn.frame = playControlView.frame;
    cBtn.backgroundColor = [UIColor clearColor];
    [playControlView addSubview:cBtn];
    [cBtn addTarget:self
              action:@selector(playerViewTap)
    forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *nameBgLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, player.view.frame.size.height, self.bounds.size.width, 40)];
    nameBgLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    [self.view addSubview:nameBgLabel];
    
    CGPoint center = playControlView.center;
    prevBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    prevBtn.frame = CGRectMake(center.x - 34 - 68*2, 160, 68, 75);
    [prevBtn setBackgroundImage:[UIImage imageNamed:@"video_pre"] forState:UIControlStateNormal];
    [prevBtn setBackgroundImage:[UIImage imageNamed:@"video_pre_active"] forState:UIControlStateHighlighted];
    [prevBtn addTarget:self action:@selector(prevBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [playControlView addSubview:prevBtn];
    
    pauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    pauseBtn.frame = CGRectMake(center.x - 34, 160, 68, 75);
    [pauseBtn setBackgroundImage:[UIImage imageNamed:@"video_play"]
                        forState:UIControlStateNormal];
    [pauseBtn setBackgroundImage:[UIImage imageNamed:@"video_play_active"]
                        forState:UIControlStateHighlighted];
    [pauseBtn setBackgroundImage:[UIImage imageNamed:@"video_pause"]
                        forState:UIControlStateSelected];
    [pauseBtn setBackgroundImage:[UIImage imageNamed:@"video_pause_active"]
                        forState:UIControlStateHighlighted|UIControlStateSelected];
    [pauseBtn addTarget:self action:@selector(pauseBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [playControlView addSubview:pauseBtn];
    pauseBtn.selected = YES;
    
    nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.frame = CGRectMake(center.x - 34 + 68*2, 160, 68, 75);
    [nextBtn setBackgroundImage:[UIImage imageNamed:@"video_next"] forState:UIControlStateNormal];
    [nextBtn setBackgroundImage:[UIImage imageNamed:@"video_next_active"] forState:UIControlStateHighlighted];
    [nextBtn addTarget:self action:@selector(nextBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [playControlView addSubview:nextBtn];
    
    [self manageControlBtn];
    
    /*
    UIImageView * bgProgress = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"bar.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)]];
    bgProgress.frame = CGRectMake(0, playControlView.frame.size.height - 10, playControlView.frame.size.width, 10);
    [playControlView addSubview:bgProgress];
    
    
    
    innerProgress = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bar_active.png"]];
    innerProgress.frame = CGRectMake(0, playControlView.frame.size.height - 10, 0, 10);
    [playControlView addSubview:innerProgress];
    */
    
    curPlaybackTime = [[UILabel alloc]initWithFrame:CGRectMake(12, 228, 100, 20)];
    curPlaybackTime.textColor = [UIColor grayColor];
    curPlaybackTime.font = [UIFont systemFontOfSize:18];
    curPlaybackTime.backgroundColor = [UIColor clearColor];
    [playControlView addSubview:curPlaybackTime];
    
    
    progressSlider = [[UISlider alloc]initWithFrame:CGRectMake(0, playControlView.frame.size.height - 23, playControlView.frame.size.width, 23)];
    progressSlider.minimumValue = 0;
    progressSlider.maximumValue = 1.0;
    UIImage *thumbImage = [UIImage imageNamed:@"bar_point.png"];
    [progressSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    [progressSlider setThumbImage:thumbImage forState:UIControlStateHighlighted];
    [progressSlider setMinimumTrackTintColor:[UIColor colorWithRed:0 green:128.0/255.0 blue:172.0/255.0 alpha:1.0]];
    [progressSlider setMaximumTrackTintColor:[UIColor colorWithRed:0 green:38/255.0 blue:51/255.0 alpha:1.0]];
    
    [progressSlider addTarget:self action:@selector(sliderTouchDown) forControlEvents:UIControlEventTouchDown];
    [progressSlider addTarget:self action:@selector(sliderTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [progressSlider addTarget:self action:@selector(sliderTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
    [progressSlider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
    [playControlView addSubview:progressSlider];
    progressSlider.value = 0;
    
    
    playbackDuration = [[UILabel alloc]initWithFrame:CGRectMake(playControlView.frame.size.width - 100 - 12, 228, 100, 20)];
    playbackDuration.textColor = [UIColor grayColor];
    playbackDuration.font = [UIFont systemFontOfSize:18];
    playbackDuration.backgroundColor = [UIColor clearColor];
    playbackDuration.textAlignment = UITextAlignmentRight;
    [playControlView addSubview:playbackDuration];
    
    progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                     target:self
                                                   selector:@selector(updateProgress)
                                                   userInfo:nil
                                                    repeats:YES];
    [self setControlTimer];
}

- (void)hiddenControlView
{
    if (playControlView.hidden)
        return;
    playControlView.hidden = YES;
    self.navigationController.navigationBarHidden = YES;
    CGRect rect = player.view.frame;
    rect.origin.y = 0;
    player.view.frame = rect;
}

- (NSString *)getTimeString:(NSInteger)playbackTime
{
    NSString * time = nil;
    NSInteger hour;
    NSInteger min;
    NSInteger sec;
    hour = playbackTime/3600;
    if (0 == hour)
    {
        min = playbackTime/60;
        sec = playbackTime%60;
        time = [NSString stringWithFormat:@"%.2d:%.2d",min,sec];
    }
    else
    {
        hour = playbackTime/3600;
        min = (playbackTime - 3600 * hour)/60;
        sec = (playbackTime - 3600 * hour)%60;
        time = [NSString stringWithFormat:@"%.2d:%.2d:%.2d",hour,min,sec];
    }
    return time;
}

- (void)setProgressValue:(CGFloat)value
{
    progressSlider.value = value;
//    innerProgress.frame = CGRectMake(0, playControlView.frame.size.height - 10, value * playControlView.frame.size.width, 10);
}

- (void)setControlTimer
{
    [controlTimer invalidate];
    controlTimer = nil;
    controlTimer = [NSTimer scheduledTimerWithTimeInterval:4.0f
                                                    target:self
                                                  selector:@selector(hiddenControlView)
                                                  userInfo:nil
                                                   repeats:NO];
}

- (void)playerViewTap
{
    [self setControlTimer];
    CGRect rect = player.view.frame;
    if (playControlView.hidden)
    {
        playControlView.hidden = NO;
        rect.origin.y = -32;
        self.navigationController.navigationBarHidden = NO;
    }
    else
    {
        playControlView.hidden = YES;
        rect.origin.y = 0;
        self.navigationController.navigationBarHidden = YES;
    }
    player.view.frame = rect;
}

- (void)updateProgress
{
    CGFloat value = player.currentPlaybackTime/player.duration;
    [self setProgressValue:value];
    curPlaybackTime.text = [self getTimeString:player.currentPlaybackTime];
}

- (void)manageControlBtn
{
    if (1 == playList.count)
    {
        nextBtn.enabled = NO;
        prevBtn.enabled = NO;
    }
    else
    {
        NSInteger index = [playList indexOfObject:media];
        if (0 == index)
        {
            prevBtn.enabled = NO;
            nextBtn.enabled = YES;
        }
        else if (playList.count == index + 1)
        {
            nextBtn.enabled = NO;
            prevBtn.enabled = YES;
        }
    }
}

- (void)resetPlayControlView
{
    [self manageControlBtn];
    curPlaybackTime.text = @"00:00";
    playbackDuration.text = [self getTimeString:player.duration];
    progressSlider.value = 0;
    pauseBtn.selected = YES;
}

#pragma mark -
#pragma mark - Public Method

- (void)addGestureOnView
{
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playerViewTap)];
//    tapGesture.numberOfTapsRequired = 1;
//    [self.view addGestureRecognizer:tapGesture];
    
    UISwipeGestureRecognizer *nextGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(nextBtnClicked)];
    nextGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    nextGesture.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:nextGesture];
    
    UISwipeGestureRecognizer *prevGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(prevBtnClicked)];
    prevGesture.direction = UISwipeGestureRecognizerDirectionRight;
    prevGesture.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:prevGesture];
    
}

- (void)changeVolume:(float)value
{
    [MPMusicPlayerController applicationMusicPlayer].volume += value;
}

//- (void)tapAction
//{
//    if (volumeSlider.hidden) {
//        [pauseBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
//    }
//    volumeSlider.hidden = YES;
//}
//
//-(void)process
//{
//    if(player.currentPlaybackTime > 0){
//        progressSlider.value = player.currentPlaybackTime / totalTime;
//    }
//}

- (void)nextBtnClicked
{
    NSInteger index = [playList indexOfObject:media];
    index ++;
    MediaObject * nextObj = [playList objectAtIndex:index];
    self.media = nextObj;
    NSURL *mediaFileUrl = [[NSURL alloc] initWithString:media.mediaURL];
    player.contentURL = mediaFileUrl;
    [player prepareToPlay];
    [player play];
    [self resetPlayControlView];
    [AppDelegate instance].videoMedia = self.media;
}

- (void)pauseBtnClicked:(UIButton *)btn
{
    btn.selected = !btn.selected;
    if (player.playbackState == MPMusicPlaybackStatePlaying)
    {
        [player pause];
        [AppDelegate instance].videoMedia = nil;
    }
    else
    {
        [player play];
        [AppDelegate instance].moviePlayer = player;
        [AppDelegate instance].videoMedia = self.media;
    }    
}

- (void)prevBtnClicked
{
    NSInteger index = [playList indexOfObject:media];
    index --;
    MediaObject * nextObj = [playList objectAtIndex:index];
    self.media = nextObj;
    NSURL *mediaFileUrl = [[NSURL alloc] initWithString:media.mediaURL];
    player.contentURL = mediaFileUrl;
    [player prepareToPlay];
    [player play];
    [self resetPlayControlView];
    [AppDelegate instance].videoMedia = self.media;
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
    progressTimer = nil;
    [controlTimer invalidate];
    controlTimer = nil;
}

- (void)sliderTouchUp:(UISlider *)slider
{
    progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                     target:self
                                                   selector:@selector(updateProgress)
                                                   userInfo:nil
                                                    repeats:YES];
    player.currentPlaybackTime = slider.value * player.duration;
    
    [self setControlTimer];
}

- (void)sliderValueChanged
{
//    progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(process) userInfo:nil repeats:YES];
//    player.currentPlaybackTime = totalTime * progressSlider.value;
}

- (void)backButtonClicked
{
    [progressTimer invalidate];
    progressTimer = nil;
    [controlTimer invalidate];
    controlTimer = nil;
    if (!player.isAirPlayVideoActive) {
        [AppDelegate instance].videoMedia = nil;
        [player pause];
        player = nil;
    }
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
