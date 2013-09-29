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
@property (nonatomic, strong)UILabel *curTimeLabel;
@property (nonatomic, strong)UILabel *albumName;
@property (nonatomic)int currentIndex;
@property (nonatomic, strong)UILabel *artist;

@property (nonatomic, strong)UIButton *randomBtn;
@property (nonatomic, strong)UIButton *singleCycleBtn;
@property (nonatomic, strong)UIButton *allCycleBtn;

- (void)customMusicView;
- (void)setMusicPlayerView;
//- (void)managerPlayControlBtn;

@end

@implementation PlayMusicViewController
@synthesize mediaArray;
@synthesize randomBtn,allCycleBtn,singleCycleBtn;
@synthesize startIndex, currentIndex, showPlaying;
@synthesize musicPlayer;
@synthesize media;
@synthesize nameLabel, endTimeLabel,curTimeLabel, artist,albumName;
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil];
    
    [musicPlayer endGeneratingPlaybackNotifications];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    musicPlayer = [AppDelegate instance].musicPlayer;
    if (nil == musicPlayer)
    {
        musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    }
    
    self.showMiddleBtn = YES;
    
    if ([CommonMethod isIphone5])
    {
        imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width)];
    }
    else
    {
        imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width * 0.9)];
    }
    if (showPlaying)
    {
        media = musicPlayer.nowPlayingItem;
    }
    else
    {
        media = [mediaArray objectAtIndex:startIndex];
        [NSThread detachNewThreadSelector:@selector(startMusicPlayer) toTarget:self withObject:nil];
    }
    totalMusicTime = ((NSNumber *)[media valueForKey:MPMediaItemPropertyPlaybackDuration]).doubleValue;
    //[self addMenuView:-NAVIGATION_BAR_HEIGHT];
    [self addContententView:-NAVIGATION_BAR_HEIGHT];
    [self showAvplayerBtn];
    [self showBackBtnForNavController];
    
    [self customMusicView];
    [self setMusicPlayerView];
    [self addGestureOnView];
    progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                     target:self
                                                   selector:@selector(process)
                                                   userInfo:nil
                                                    repeats:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(musicPlayingItemChanged:)
                                                 name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                                               object:nil];

    [musicPlayer beginGeneratingPlaybackNotifications];
    
    [AppDelegate instance].castingType = YueVideoCasting;
}

#pragma mark -
#pragma mark - Private
- (void)customMusicView
{
    //专辑封面
    if ([CommonMethod isIphone5])
    {
        imageView = [[UIImageView alloc]initWithFrame:CGRectMake(34, 22, 252, 252)];
    }
    else
    {
        imageView = [[UIImageView alloc]initWithFrame:CGRectMake(34, 22, 252, 252)];
    }
    
    [self.view addSubview:imageView];
    imageView.userInteractionEnabled = YES;
    
    //播放器时长、总时长、进度条
    endTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(252 - 60 - 10, 252 - 30 - 23, 60, 30)];
    endTimeLabel.font = [UIFont systemFontOfSize:12];
    endTimeLabel.textAlignment = NSTextAlignmentRight;
    endTimeLabel.text = @"00:00";
    endTimeLabel.textColor = [UIColor lightGrayColor];
    endTimeLabel.backgroundColor = [UIColor clearColor];
    [imageView addSubview:endTimeLabel];
    
    curTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 252 - 30 - 23, 60, 30)];
    curTimeLabel.font = [UIFont systemFontOfSize:12];
    curTimeLabel.text = @"00:00";
    curTimeLabel.textColor = [UIColor lightGrayColor];
    curTimeLabel.backgroundColor = [UIColor clearColor];
    [imageView addSubview:curTimeLabel];
    
    progressSlider = [[UISlider alloc]initWithFrame:CGRectMake(0, 252 - 23, 252, 23)];
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
    [imageView addSubview:progressSlider];
    progressSlider.value = 0;
    
    //专辑信息
    
    nameLabel = [[UILabel alloc]init];
    
    nameLabel.font = [UIFont systemFontOfSize:16];
    nameLabel.textAlignment = UITextAlignmentCenter;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textColor = [UIColor whiteColor];
    
    if ([CommonMethod isIphone5])
    {
        nameLabel.frame = CGRectMake(34, imageView.frame.size.height + imageView.frame.origin.y + 32, 252, 25);
        
        CGFloat height = nameLabel.frame.size.height + nameLabel.frame.origin.y;
        
        artist = [[UILabel alloc]initWithFrame:CGRectMake(34, height + 5, 252, 20)];
        
        artist.font = [UIFont systemFontOfSize:14];
        artist.backgroundColor = [UIColor clearColor];
        artist.textColor = [UIColor lightGrayColor];
        artist.textAlignment = UITextAlignmentCenter;
        [self.view addSubview:artist];
        
        albumName = [[UILabel alloc]initWithFrame:CGRectMake(34, height + 30, 252, 20)];
        
        albumName.font = [UIFont systemFontOfSize:14];
        albumName.backgroundColor = [UIColor clearColor];
        albumName.textColor = [UIColor lightGrayColor];
        albumName.textAlignment = UITextAlignmentCenter;
        [self.view addSubview:albumName];
        
    }
    else
    {
        nameLabel.frame = CGRectMake(34, imageView.frame.size.height + imageView.frame.origin.y + 20, 252, 25);
    }
    
    [self.view addSubview:nameLabel];
    
    //播控按钮
    
    CGFloat height = [UIScreen mainScreen].bounds.size.height - 20 - 44;
    prevBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    prevBtn.frame = CGRectMake(35, height - 75 - 20, 68, 75);
    [prevBtn setBackgroundImage:[UIImage imageNamed:@"pre"] forState:UIControlStateNormal];
    [prevBtn setBackgroundImage:[UIImage imageNamed:@"pre_active"] forState:UIControlStateHighlighted];
    [prevBtn addTarget:self action:@selector(prevBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:prevBtn];
    
    pauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    pauseBtn.frame = CGRectMake(35 + 30 + 68, height - 75 - 20, 68, 75);
    [pauseBtn setBackgroundImage:[UIImage imageNamed:@"play"]
                        forState:UIControlStateNormal];
    [pauseBtn setBackgroundImage:[UIImage imageNamed:@"play_active"]
                        forState:UIControlStateHighlighted];
    [pauseBtn setBackgroundImage:[UIImage imageNamed:@"pause"]
                        forState:UIControlStateSelected];
    [pauseBtn setBackgroundImage:[UIImage imageNamed:@"pause_active"]
                        forState:UIControlStateHighlighted|UIControlStateSelected];
    [pauseBtn addTarget:self action:@selector(pauseBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    pauseBtn.selected = YES;
    [self.view addSubview:pauseBtn];
    
    nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.frame = CGRectMake(35 + 30*2 + 68*2, height - 75 - 20, 68, 75);
    [nextBtn setBackgroundImage:[UIImage imageNamed:@"next"] forState:UIControlStateNormal];
    [nextBtn setBackgroundImage:[UIImage imageNamed:@"next_active"] forState:UIControlStateHighlighted];
    [nextBtn addTarget:self action:@selector(nextBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextBtn];
    
    if (0 == mediaArray.count)
    {
        nextBtn.enabled = NO;
        prevBtn.enabled = NO;
    }
    
    //播放模式按钮
    CGFloat originY = nameLabel.frame.origin.y - 25;
    CGFloat originX = imageView.frame.origin.x + imageView.frame.size.width - 30;
    
    allCycleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    allCycleBtn.frame = CGRectMake(originX, originY, 30, 30);
    allCycleBtn.backgroundColor = [UIColor clearColor];
    [allCycleBtn setImage:[UIImage imageNamed:@"cycle"] forState:UIControlStateNormal];
    [allCycleBtn setImage:[UIImage imageNamed:@"cycle_active"] forState:UIControlStateHighlighted];
    //[allCycleBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 30, 30)];
    [allCycleBtn addTarget:self action:@selector(modelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:allCycleBtn];
    
    singleCycleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    singleCycleBtn.frame = allCycleBtn.frame;
    [singleCycleBtn setImage:[UIImage imageNamed:@"single"] forState:UIControlStateNormal];
    [singleCycleBtn setImage:[UIImage imageNamed:@"single_active"] forState:UIControlStateHighlighted];
    //[singleCycleBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 30, 30)];
    [singleCycleBtn addTarget:self action:@selector(modelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:singleCycleBtn];
    
    randomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    randomBtn.frame = allCycleBtn.frame;
    [randomBtn setImage:[UIImage imageNamed:@"random"] forState:UIControlStateNormal];
    [randomBtn setImage:[UIImage imageNamed:@"random_active"] forState:UIControlStateHighlighted];
    //[randomBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 30, 30)];
    [randomBtn addTarget:self action:@selector(modelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:randomBtn];
    
    randomBtn.hidden = YES;
    allCycleBtn.hidden = YES;
    singleCycleBtn.hidden = YES;
    
    if (MPMusicRepeatModeOne == musicPlayer.repeatMode
        && MPMusicShuffleModeOff == musicPlayer.shuffleMode)
    {
        singleCycleBtn.hidden = NO;
    }
    else if (MPMusicRepeatModeAll == musicPlayer.repeatMode
             && MPMusicShuffleModeOff == musicPlayer.shuffleMode)
    {
        allCycleBtn.hidden = NO;
    }
    else if (MPMusicRepeatModeAll == musicPlayer.repeatMode
             && MPMusicShuffleModeSongs == musicPlayer.shuffleMode)
    {
        randomBtn.hidden = NO;
    }
    else
    {
        allCycleBtn.hidden = NO;
    }
}

- (void)setMusicPlayerView
{
    MPMediaItemArtwork *artworkItem = [musicPlayer.nowPlayingItem valueForProperty: MPMediaItemPropertyArtwork];
    if ([artworkItem imageWithSize:imageView.frame.size])
    {
        [imageView setImage:[artworkItem imageWithSize:imageView.frame.size]];
    } else {
        [imageView setImage:[UIImage imageNamed:@"music_default"]];
    }
    
    nameLabel.text = [musicPlayer.nowPlayingItem valueForProperty: MPMediaItemPropertyTitle];
    artist.text = [musicPlayer.nowPlayingItem valueForProperty: MPMediaItemPropertyArtist];
    albumName.text = [musicPlayer.nowPlayingItem valueForProperty: MPMediaItemPropertyAlbumTitle];
    totalMusicTime = ((NSNumber *)[musicPlayer.nowPlayingItem valueForKey:MPMediaItemPropertyPlaybackDuration]).doubleValue;
    endTimeLabel.text = [NSString stringWithFormat:@"-%@", [TimeUtility formatTimeInSecond:totalMusicTime - musicPlayer.currentPlaybackTime]];
}

- (void)addGestureOnView
{
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
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
    if(musicPlayer.currentPlaybackTime > 0)
    {
        progressSlider.value = musicPlayer.currentPlaybackTime / totalMusicTime;
        endTimeLabel.text = [NSString stringWithFormat:@"-%@", [TimeUtility formatTimeInSecond:totalMusicTime - musicPlayer.currentPlaybackTime]];
        curTimeLabel.text = [NSString stringWithFormat:@"%@",[TimeUtility formatTimeInSecond:musicPlayer.currentPlaybackTime]];
    }
}

- (void)musicPlayingItemChanged:(NSNotification *)aNotification
{
    media = musicPlayer.nowPlayingItem;
    [self setMusicPlayerView];
}

- (void)validateCurrentIndex
{
    if (currentIndex < 0)
    {
        currentIndex = mediaArray.count -1;
    }
    else if (currentIndex >= mediaArray.count)
    {
        currentIndex = 0;
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

- (void)sliderTouchUp:(UISlider *)slider
{
    [progressTimer invalidate];
    progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                     target:self
                                                   selector:@selector(process)
                                                   userInfo:nil
                                                    repeats:YES];
    musicPlayer.currentPlaybackTime = totalMusicTime * progressSlider.value;
}

- (void)sliderValueChanged
{
//    [progressTimer invalidate];
//    progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(process) userInfo:nil repeats:YES];
//    musicPlayer.currentPlaybackTime = totalMusicTime * progressSlider.value;
}

- (void)backButtonClicked
{
//    if (![CommonMethod isAirPlayActive]) {        
//        [musicPlayer stop];
//        musicPlayer = nil;
//    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)homeButtonClicked
{
    [self dismissViewControllerAnimated:NO completion:nil];
    [super homeButtonClicked];
}


//- (void)playBtnClicked
//{
//    [AppDelegate instance].castingType = YueMusicCasting;
//}

//- (void)managerPlayControlBtn
//{
//    NSInteger index = [mediaArray indexOfObject:media];
//    if (0 == index)
//    {
//        prevBtn.enabled = NO;
//        nextBtn.enabled = YES;
//    }
//    else if (index + 1 == mediaArray.count)
//    {
//        prevBtn.enabled = YES;
//        nextBtn.enabled = NO;
//    }
//    else
//    {
//        prevBtn.enabled = YES;
//        nextBtn.enabled = YES;
//    }
//}

#pragma mark -
#pragma mark - 播放模式控制按钮
- (void)modelBtnClick:(UIButton *)btn
{
    allCycleBtn.hidden = YES;
    singleCycleBtn.hidden = YES;
    randomBtn.hidden = YES;
    
    if (randomBtn == btn)//(allCycleBtn == btn)
    {
        allCycleBtn.hidden = NO;
        
        [musicPlayer setShuffleMode: MPMusicShuffleModeOff];
        [musicPlayer setRepeatMode: MPMusicRepeatModeAll];
        
    }
    else if (allCycleBtn == btn)//(singleCycleBtn == btn)
    {
        singleCycleBtn.hidden = NO;
        
        [musicPlayer setShuffleMode: MPMusicShuffleModeOff];
        [musicPlayer setRepeatMode: MPMusicRepeatModeOne];
        
    }
    else
    {
        randomBtn.hidden = NO;
        
        [musicPlayer setShuffleMode: MPMusicShuffleModeSongs];
        [musicPlayer setRepeatMode: MPMusicRepeatModeAll];
        
    }
}

#pragma mark -
#pragma mark - 播控按钮
- (void)prevBtnClicked
{
    currentIndex--;
    [self validateCurrentIndex];
    progressSlider.value = 0;
    curTimeLabel.text = @"00:00";
//    [self managerPlayControlBtn];
    [musicPlayer skipToPreviousItem];
    if ([musicPlayer nowPlayingItem]) {
        [self setMusicPlayerView];
        if (musicPlayer.playbackState != MPMusicPlaybackStatePlaying) {
            [musicPlayer play];
        }
        [pauseBtn setSelected:YES];
    } else {
        [self updatePlayCollections];
    }
}

- (void)nextBtnClicked
{
    currentIndex++;
    [self validateCurrentIndex];
    progressSlider.value = 0;
    curTimeLabel.text = @"00:00";
//    [self managerPlayControlBtn];
    [musicPlayer skipToNextItem];
    if ([musicPlayer nowPlayingItem])
    {
        [self setMusicPlayerView];
        if (musicPlayer.playbackState != MPMusicPlaybackStatePlaying)
        {
            [musicPlayer play];
        }
        [pauseBtn setSelected:YES];
    } else {
        [self updatePlayCollections];
    }
}

- (void)pauseBtnClicked:(UIButton *)btn
{
    btn.selected = !btn.selected;
    if (musicPlayer.playbackState == MPMusicPlaybackStatePlaying)
    {
        [musicPlayer pause];
    }
    else
    {
        [musicPlayer play];
    }
    
}


@end
