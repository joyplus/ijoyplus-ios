//
//  IphoneAVPlayerViewController.m
//  mediaplayer
//
//  Created by 08 on 13-2-26.
//  Copyright (c) 2013年 iplusjoy. All rights reserved.
//

#import "IphoneAVPlayerViewController.h"
#import "UIUtility.h"
#import "TimeUtility.h"
#import "AppDelegate.h"
#import "ContainerUtility.h"
#import "CMConstants.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "CacheUtility.h"
#import "Reachability.h"
/* Asset keys */
 NSString * const k_TracksKey         = @"tracks";
 NSString * const k_PlayableKey		= @"playable";

/* PlayerItem keys */
 NSString * const k_StatusKey         = @"status";

/* AVPlayer keys */
 NSString * const k_RateKey			= @"rate";
 NSString * const k_CurrentItemKey	= @"currentItem";

#define CLOSE_BUTTON_TAG 10001
#define FULL_SCREEN_TAG 10002
#define PLAY_BUTTON_TAG 10003
#define PAUSE_BUTTON_TAG 10004
#define PRE_BUTTON_TAG 10005
#define NEXT_BUTTON_TAG 10006
#define CLARITY_BUTTON_TAG 10007
#define VOLUME_BUTTON_TAG 10008
#define SELECT_BUTTON_TAG 10009
#define PLAIN_CLEAR 100
#define HIGH_CLEAR 200
#define SUPER_CLEAR 300
@interface IphoneAVPlayerViewController ()

@end
static void *AVPlayerDemoPlaybackViewControllerRateObservationContext = &AVPlayerDemoPlaybackViewControllerRateObservationContext;
static void *AVPlayerDemoPlaybackViewControllerStatusObservationContext = &AVPlayerDemoPlaybackViewControllerStatusObservationContext;
static void *AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext = &AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext;
@implementation IphoneAVPlayerViewController
@synthesize topToolBar = topToolBar_;
@synthesize bottomToolBar = bottomToolBar_;
@synthesize avplayerView = avplayerView_;
@synthesize mPlayerItem ,mPlayer,mURL,mScrubber,myHUD;
@synthesize selectButton = selectButton_;
@synthesize clarityButton = clarityButton_;
@synthesize playButton = playButton_;
@synthesize pauseButton = pauseButton;
@synthesize seeTimeLabel = seeTimeLabel_;
@synthesize totalTimeLablel = totalTimeLable_;
@synthesize playCacheView = playCacheView_;
@synthesize bottomView = bottomView_;
@synthesize nameStr = nameStr_;
@synthesize episodesArr = episodesArr_;
@synthesize sortEpisodesArr = sortEpisodesArr_;
@synthesize playNum;
@synthesize tableList = tableList_;
@synthesize superClearArr,highClearArr,plainClearArr;
@synthesize play_index_tag;
@synthesize local_file_path = local_file_path_;
@synthesize islocalFile = islocalFile_;
@synthesize clearBgView = clearBgView_;
@synthesize myTimer = myTimer_;
@synthesize videoType = videoType_;
@synthesize prodId = prodId_;
@synthesize webPlayUrl = webPlayUrl_;
@synthesize lastPlayTime = lastPlayTime_;
@synthesize timeLabelTimer = timeLabelTimer_;
@synthesize volumeView = volumeView_;
@synthesize airPlayLabel = airPlayLabel_;
@synthesize sourceLogo = sourceLogo_;
#pragma mark Asset URL

- (void)setURL:(NSURL*)URL
{
	if (mURL != URL)
	{
		mURL = URL;
		
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:mURL options:nil];
        
        [self prepareToPlayAsset:asset ];
	}
}


-(void)setPath:(NSString *)path{

    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:path] options:nil];
    
    [self prepareToPlayAsset:asset ];

}

- (NSURL*)URL
{
	return mURL;
}

#pragma mark Prepare to play asset, URL

/*
 Invoked at the completion of the loading of the values for all keys on the asset that we require.
 Checks whether loading was successfull and whether the asset is playable.
 If so, sets up an AVPlayerItem and an AVPlayer to play the asset.
 */
- (void)prepareToPlayAsset:(AVURLAsset *)asset 
{
    NSURL *url = asset.URL;
    NSLog(@"播放地址:%@!",url);
    if (!islocalFile_) {
      [self syncLogo:[url absoluteString]];
    }
    
	/* At this point we're ready to set up for playback of the asset. */
    
    /* Stop observing our prior AVPlayerItem, if we have one. */
    if (self.mPlayerItem)
    {
        /* Remove existing player item key value observers and notifications. */
        
        [self.mPlayerItem removeObserver:self forKeyPath:k_StatusKey];
		
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:self.mPlayerItem];
    }
	
    /* Create a new instance of AVPlayerItem from the now successfully loaded AVAsset. */
    self.mPlayerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    /* Observe the player item "status" key to determine when it is ready to play. */
    [self.mPlayerItem addObserver:self
                       forKeyPath:k_StatusKey
                          options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          context:AVPlayerDemoPlaybackViewControllerStatusObservationContext];
	
    /* When the player item has played to its end time we'll toggle
     the movie controller Pause button to be the Play button */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.mPlayerItem];
	
    seekToZeroBeforePlay = NO;
	
    /* Create new player, if we don't already have one. */
    if (![self player])
    {
        /* Get a new AVPlayer initialized to play the specified player item. */
        [self setPlayer:[AVPlayer playerWithPlayerItem:self.mPlayerItem]];
        /* Observe the AVPlayer "currentItem" property to find out when any
         AVPlayer replaceCurrentItemWithPlayerItem: replacement will/did
         occur.*/
        [self.player addObserver:self
                      forKeyPath:k_CurrentItemKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext];
        
        /* Observe the AVPlayer "rate" property to update the scrubber control. */
        [self.player addObserver:self
                      forKeyPath:k_RateKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:AVPlayerDemoPlaybackViewControllerRateObservationContext];
    }
    
    /* Make our new AVPlayerItem the AVPlayer's current item. */
    if (self.player.currentItem != self.mPlayerItem)
    {
        /* Replace the player item with a new player item. The item replacement occurs
         asynchronously; observe the currentItem property to find out when the
         replacement will/did occur*/
        [[self player] replaceCurrentItemWithPlayerItem:self.mPlayerItem];
        
        [self syncPlayPauseButtons];
    }
	
    
    if (lastPlayTime_.value) {
         [mPlayer seekToTime:lastPlayTime_];
         seeTimeLabel_.text =  [TimeUtility formatTimeInSecond:CMTimeGetSeconds(lastPlayTime_)];
    }

    if (videoType_ == 2 || videoType_ ==3) {
       [[CacheUtility sharedCache]putInCache:[NSString stringWithFormat:@"drama_epi_%@", prodId_] result:[NSNumber numberWithInt:playNum]];
    }
  
    [mScrubber setValue:0.0];
}

-(void)assetFailedToPrepareForPlayback:(NSError *)error
{
    [self removePlayerTimeObserver];
    [self syncScrubber];
    [self disableScrubber];
    /* Display the error. */
}

- (void)syncScrubber
{
	CMTime playerDuration = [self playerItemDuration];
	if (CMTIME_IS_INVALID(playerDuration))
	{
		mScrubber.minimumValue = 0.0;
		return;
	}
    
	double duration = CMTimeGetSeconds(playerDuration);
	if (isfinite(duration))
	{
		float minValue = [mScrubber minimumValue];
		float maxValue = [mScrubber maximumValue];
		double time = CMTimeGetSeconds([mPlayer currentTime]);
		[mScrubber setValue:(maxValue - minValue) * time / duration + minValue];
	}

}

-(void)removePlayerTimeObserver
{
	if (mTimeObserver)
	{
		[mPlayer removeTimeObserver:mTimeObserver];
		mTimeObserver = nil;
	}
}

/* ---------------------------------------------------------
 **  Get the duration for a AVPlayerItem.
 ** ------------------------------------------------------- */

- (CMTime)playerItemDuration
{
	AVPlayerItem *playerItem = [mPlayer currentItem];
	if (playerItem.status == AVPlayerItemStatusReadyToPlay)
	{
        /*
         NOTE:
         Because of the dynamic nature of HTTP Live Streaming Media, the best practice
         for obtaining the duration of an AVPlayerItem object has changed in iOS 4.3.
         Prior to iOS 4.3, you would obtain the duration of a player item by fetching
         the value of the duration property of its associated AVAsset object. However,
         note that for HTTP Live Streaming Media the duration of a player item during
         any particular playback session may differ from the duration of its asset. For
         this reason a new key-value observable duration property has been defined on
         AVPlayerItem.
         
         See the AV Foundation Release Notes for iOS 4.3 for more information.
         */
        
		return([playerItem duration]);
	}
	
	return(kCMTimeInvalid);
}

-(void)disableScrubber
{
    self.mScrubber.enabled = NO;
}

- (void)syncPlayPauseButtons
{
	if ([self isPlaying])
	{
        playButton_.hidden = YES;
        pauseButton_.hidden = NO;
	}
	else
	{
        playButton_.hidden = NO;
        pauseButton_.hidden = YES;
	}
}

- (BOOL)isPlaying
{
	return mRestoreAfterScrubbingRate != 0.f || [mPlayer rate] != 0.f;
}

#pragma mark -
#pragma mark Asset Key Value Observing
#pragma mark

#pragma mark Key Value Observer for player rate, currentItem, player item status

/* ---------------------------------------------------------
 **  Called when the value at the specified key path relative
 **  to the given object has changed.
 **  Adjust the movie play and pause button controls when the
 **  player item "status" value changes. Update the movie
 **  scrubber control when the player item is ready to play.
 **  Adjust the movie scrubber control when the player item
 **  "rate" value changes. For updates of the player
 **  "currentItem" property, set the AVPlayer for which the
 **  player layer displays visual output.
 **  NOTE: this method is invoked on the main queue.
 ** ------------------------------------------------------- */

- (void)observeValueForKeyPath:(NSString*) path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
    if (mPlayer.airPlayVideoActive) {
        [avplayerView_ addSubview:airPlayLabel_];
        for (UIView *asubview in volumeView_.subviews) {
            if ([NSStringFromClass(asubview.class) isEqualToString:@"MPButton"]) {
                UIButton *btn = (UIButton *)asubview;
                [btn setImage:nil forState:UIControlStateNormal];
                [btn setImage:nil forState:UIControlStateHighlighted];
                [btn setImage:nil forState:UIControlStateSelected];
                [btn setBackgroundImage:[UIImage imageNamed:@"iphone_route_bt_light"] forState:UIControlStateNormal];
                [btn setEnabled:YES];
                break;
            }
        }
    }
    else{
        [airPlayLabel_ removeFromSuperview];
        for (UIView *asubview in volumeView_.subviews) {
            if ([NSStringFromClass(asubview.class) isEqualToString:@"MPButton"]) {
                UIButton *btn = (UIButton *)asubview;
                [btn setImage:nil forState:UIControlStateNormal];
                [btn setImage:nil forState:UIControlStateHighlighted];
                [btn setImage:nil forState:UIControlStateSelected];
                [btn setBackgroundImage:[UIImage imageNamed:@"iphone_route_bt"] forState:UIControlStateNormal];
                [btn setEnabled:YES];
                break;
            }
        }
    }
    
    
	/* AVPlayerItem "status" property value observer. */
	if (context == AVPlayerDemoPlaybackViewControllerStatusObservationContext)
	{
		[self syncPlayPauseButtons];

        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
                /* Indicates that the status of the player is not yet known because
                 it has not tried to load new media resources for playback */
            case AVPlayerStatusUnknown:
            {
                [self removePlayerTimeObserver];
                [self syncScrubber];
                [self disableScrubber];
               
                playButton_.hidden = YES;
                pauseButton_.hidden = NO;
                myHUD.hidden = NO;
            }
                break;
                
            case AVPlayerStatusReadyToPlay:
            {
                /* Once the AVPlayerItem becomes ready to play, i.e.
                 [playerItem status] == AVPlayerItemStatusReadyToPlay,
                 its duration can be fetched from the item. */
                CMTime playerDuration = [self playerItemDuration];
                totalTimeLable_.text = [TimeUtility formatTimeInSecond:CMTimeGetSeconds(playerDuration)];
                
                [playCacheView_ removeFromSuperview];
                myHUD.hidden = YES;
                [self initScrubberTimer];
                [self initTimeLabelTimer];
                [self enableScrubber];
                [mPlayer play];
                
                playButton_.hidden = YES;
                pauseButton_.hidden = NO;
                
                [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(hiddenToolBar) userInfo:nil repeats:NO];
            }
                break;
                
            case AVPlayerStatusFailed:
            {
                AVPlayerItem *playerItem = (AVPlayerItem *)object;
                [self assetFailedToPrepareForPlayback:playerItem.error];
            }
                break;
        }
	}
	/* AVPlayer "rate" property value observer. */
	else if (context == AVPlayerDemoPlaybackViewControllerRateObservationContext)
	{
           [self syncPlayPauseButtons];
	}
	/* AVPlayer "currentItem" property observer.
     Called when the AVPlayer replaceCurrentItemWithPlayerItem:
     replacement will/did occur. */
	else if (context == AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext)
	{
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        
        /* Is the new player item null? */
        if (newPlayerItem == (id)[NSNull null])
        {
            [self disableScrubber];
        }
        else /* Replacement of player currentItem has occurred */
        {
            /* Set the AVPlayer for which the player layer displays visual output. */
            [avplayerView_ setPlayer:mPlayer];
            
            /* Specifies that the player should preserve the video’s aspect ratio and
             fit the video within the layer’s bounds. */
            [avplayerView_ setVideoFillMode:AVLayerVideoGravityResizeAspect];
            
            [self syncPlayPauseButtons];
        }
	}
	else
	{
		[super observeValueForKeyPath:path ofObject:object change:change context:context];
	}
}

#pragma mark -
#pragma mark Movie scrubber control

/* ---------------------------------------------------------
 **  Methods to handle manipulation of the movie scrubber control
 ** ------------------------------------------------------- */

/* Requests invocation of a given block during media playback to update the movie scrubber control. */
-(void)initScrubberTimer
{
	double interval = .1f;
	
	CMTime playerDuration = [self playerItemDuration];
	if (CMTIME_IS_INVALID(playerDuration))
	{
		return;
	}
	double duration = CMTimeGetSeconds(playerDuration);
	if (isfinite(duration))
	{
		//CGFloat width = CGRectGetWidth([mScrubber bounds]);
        CGFloat width = 100.0;
		interval = 0.5f * duration / width;
	}
    
	/* Update the scrubber during normal playback. */
	mTimeObserver = [mPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                                                           queue:NULL /* If you pass NULL, the main queue is used. */
                                                      usingBlock:^(CMTime time)
                      {
                          [self syncScrubber];
                      }];
    
}

-(void)initTimeLabelTimer{
   timeLabelTimer_ = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(syncTimeLabel) userInfo:nil repeats:YES];
    

}
-(void)syncTimeLabel{
    lastPlayTime_ = [mPlayer currentTime];
    seeTimeLabel_.text =  [TimeUtility formatTimeInSecond:CMTimeGetSeconds([mPlayer currentTime])];

}
-(void)enableScrubber
{
    self.mScrubber.enabled = YES;
}

-(void)hiddenToolBar{

     topToolBar_.hidden = YES;
     bottomToolBar_.hidden = YES;
     bottomView_.hidden = YES;
    selectButton_.selected = NO;
    clarityButton_.selected = NO;
    tableList_.frame = CGRectMake(378, 35, 100, 0);
    [clearBgView_ removeFromSuperview];
    
}
-(void)showToolBar{

    topToolBar_.hidden = NO;
    bottomToolBar_.hidden = NO;
    bottomView_.hidden = NO;
 
    [self resetMyTimer];

    
}
-(void)resetMyTimer{
    if (myTimer_ != nil) {
        [myTimer_ invalidate];
    }
     myTimer_ = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(hiddenToolBar) userInfo:nil repeats:NO];
}
-(void)playerItemDidReachEnd:(id)sender{
    if (videoType_ == 1 || videoType_ == 3) {
        return;
    }
    [self playNext];

}
-(void)playNext{
    lastPlayTime_ = CMTimeMake(0, NSEC_PER_SEC);
    [self removePlayerTimeObserver];
    [self.player pause];
    if (timeLabelTimer_ != nil) {
        [timeLabelTimer_ invalidate];
    }
    playNum++;
    [self initDataSource:playNum];
    
    [self beginToPlay];
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
	// Do any additional setup after loading the view.
    [self initUI];
    
    if (!islocalFile_) {
        //初始化数据；
        [self initDataSource:playNum];
        
        [self beginToPlay];
    }
    else{
        
        [self setPath:local_file_path_];
    }
    
}

-(void)initUI{
    self.title = nameStr_;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    [self.navigationController setNavigationBarHidden:YES animated:YES];

    self.view.backgroundColor = [UIColor blackColor];
    [self initPlayerView];
    [self initTopToolBar];
    [self initBottomToolBar];
    
    playCacheView_ = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kFullWindowHeight, self.view.bounds.size.width)];
    if([AppDelegate instance].window.bounds.size.height == 568){
        playCacheView_.image = [UIImage imageNamed:@"iphone_video_loading_IP5"];
    }
    else{
       playCacheView_.image = [UIImage imageNamed:@"iphone_video_loading"];
    }
    playCacheView_.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showTopToolBar)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [playCacheView_ addGestureRecognizer:tapGesture];
    [self.view addSubview:playCacheView_];
    
    myHUD = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 250, 150)];
    myHUD.center = CGPointMake(self.view.center.x, self.view.center.y+60);
    myHUD.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tapGesture_another = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showTopToolBar)];
    tapGesture_another.numberOfTapsRequired = 1;
    tapGesture_another.numberOfTouchesRequired = 1;
    [playCacheView_ addGestureRecognizer:tapGesture_another];
    
    [myHUD addGestureRecognizer:tapGesture];
    myHUD.labelText = @"加载中...";
    myHUD.opacity = 0;
    [myHUD show:YES];
    [self.view addSubview:myHUD];

    UILabel *lodingLbel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    lodingLbel.center = CGPointMake(playCacheView_.center.x, 60);
    NSString *str = [TimeUtility formatTimeInSecond:CMTimeGetSeconds(lastPlayTime_)];
    if ([str isEqualToString:@"00:00"] || [str isEqualToString:@"00:00:00"]) {
        lodingLbel.text = @"即将播出";
    }
    else{
        lodingLbel.text = [NSString stringWithFormat:@"上次播放至: %@",str];
    }
    
    lodingLbel.font = [UIFont systemFontOfSize:13];
    lodingLbel.backgroundColor = [UIColor clearColor];
    lodingLbel.textColor = [UIColor whiteColor];
    lodingLbel.textAlignment = NSTextAlignmentCenter;
    [playCacheView_ addSubview:lodingLbel];

}


-(void)showTopToolBar{
    topToolBar_.hidden = NO;
    [self.view bringSubviewToFront:topToolBar_];
    [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(hiddenToolBar) userInfo:nil repeats:NO];
}


-(void)initDataSource:(int)num{
    if (num >= [episodesArr_ count]) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
//        [alert show];
        return;
    }
   NSDictionary *episodesInfo = [episodesArr_ objectAtIndex:num];
    NSArray *down_load_urls = [episodesInfo objectForKey:@"down_urls"];
    NSMutableArray *tempSortArr = [NSMutableArray arrayWithCapacity:5];
    for (NSDictionary *dic in down_load_urls) {
        NSMutableDictionary *temp_dic = [NSMutableDictionary dictionaryWithDictionary:dic];
        NSString *source_str = [temp_dic objectForKey:@"source"];
        
        if ([source_str isEqualToString:@"letv"]) {
            [temp_dic setObject:@"1" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"fengxing"]){
            [temp_dic setObject:@"2" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"qiyi"]){
            [temp_dic setObject:@"3" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"youku"]){
            [temp_dic setObject:@"4" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"sinahd"]){
            [temp_dic setObject:@"5" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"sohu"]){
            [temp_dic setObject:@"6" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"56"]){
            [temp_dic setObject:@"7" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"qq"]){
            [temp_dic setObject:@"8" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"pptv"]){
            [temp_dic setObject:@"9" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"pps"]){
            [temp_dic setObject:@"10" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"m1905"]){
            [temp_dic setObject:@"11" forKey:@"level"];
        }
        [tempSortArr addObject:temp_dic];
    }
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"level" ascending:YES comparator:cmpString];
    sortEpisodesArr_ = [NSMutableArray arrayWithArray:[tempSortArr sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]]];
    
    if (superClearArr == nil) {  //存放某一剧集所有来源的超清的地址;
        superClearArr = [NSMutableArray arrayWithCapacity:5];
    }
    [superClearArr removeAllObjects];
    
    if (highClearArr == nil) {  //存放某一剧集所有来源的高清的地址;
        highClearArr = [NSMutableArray arrayWithCapacity:5];
    }
    [highClearArr removeAllObjects];
    
    if (plainClearArr == nil) {  //存放某一剧集所有来源的标清的地址;
        plainClearArr = [NSMutableArray arrayWithCapacity:5];
    }
    [plainClearArr removeAllObjects];
    
    for (NSDictionary *url_info_dic in sortEpisodesArr_) {
        NSArray *urls = [url_info_dic objectForKey:@"urls"];
        NSString *sourceStr = [url_info_dic objectForKey:@"source"];
        for (NSDictionary *url_dic in urls) {
            NSString *type_str = [[url_dic objectForKey:@"type"]lowercaseString];
            NSString *url_str =  [url_dic objectForKey:@"url"];
            
            NSMutableDictionary *urlandSource = [NSMutableDictionary dictionaryWithCapacity:5];
            [urlandSource setObject:sourceStr forKey:@"source"];
            [urlandSource setObject:url_str forKey:@"url"];
           
            if ([type_str isEqualToString:@"hd2"]) {
                 [superClearArr addObject:urlandSource];
            }
            else if ([type_str isEqualToString:@"mp4"]){
                [highClearArr addObject:urlandSource];
            }
            else if ([type_str isEqualToString:@"flv"]||[type_str isEqualToString:@"3gp"]){
                [plainClearArr addObject:urlandSource];
            }
        }
    } 
}

    NSComparator cmpString = ^(id obj1, id obj2){
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        } 
        
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };

-(void)beginToPlay{
    play_url_index = 0;
    NSString *url = nil;
    
    switch (clear_type) {
        case PLAIN_CLEAR:{
            if ([plainClearArr count] > 0) {
                url = [[plainClearArr objectAtIndex:0] objectForKey:@"url"];
                [self sendHttpRequest:url];
            }
            else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"没有找到此清晰度的视频地址,请尝试其它清晰度的地址。" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
                [alertView show];
                
                return;
            }
            break;
        }
        case HIGH_CLEAR:{
            if ([highClearArr count] > 0) {
                url = [[highClearArr objectAtIndex:0] objectForKey:@"url"];
                [self sendHttpRequest:url];
            }
            else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"没有找到此清晰度的视频地址,请尝试其它清晰度的地址。" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
                [alertView show];
                
                return;
            }
            break;
        }
        case SUPER_CLEAR:{
            
            if ([superClearArr count] > 0) {
                url = [[superClearArr objectAtIndex:0] objectForKey:@"url"];
                [self sendHttpRequest:url];
            }
            else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"没有找到此清晰度的视频地址,请尝试其它清晰度的地址。" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
                [alertView show];
               
                return;
            }
            break;
        }
        default:{
             // 播放顺序:高清-超清-标清;
            if ([highClearArr count] > 0) {
                url = [[highClearArr objectAtIndex:0] objectForKey:@"url"];
            }
            else if ([superClearArr count] > 0) {
                url = [[superClearArr objectAtIndex:0] objectForKey:@"url"];
            }
            else if ([plainClearArr count] > 0) {
                url = [[plainClearArr objectAtIndex:0] objectForKey:@"url"];
            }
            
            //url =  @"http://115.238.173.139:80/play/42c906c95416b06db24f609ff70c09ab3fc4a010.mp4";
            if(url != nil){
                [self sendHttpRequest:url];
            }
            else{
                NSLog(@"Error:Get Play Url Fail!");
                [self.navigationController popViewControllerAnimated:NO];
            }

            break;
        }
    }
}

-(void)retryUrltoPlay{
    
    play_url_index ++;
    
    switch (clear_type) {
        case PLAIN_CLEAR:{
            if ([plainClearArr count] >  play_url_index) {
                NSString *url = [[plainClearArr objectAtIndex:play_url_index] objectForKey:@"url"];
                [self sendHttpRequest:url];
            }
            else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"没有找到此清晰度的视频地址,请尝试其它清晰度的地址。" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
                [alertView show];
                return;
            }
            
            break;
        }
        case HIGH_CLEAR:{
            if ([highClearArr count] > play_url_index ) {
                NSString *url = [[plainClearArr objectAtIndex:play_url_index] objectForKey:@"url"];
                [self sendHttpRequest:url];
            }
            else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"没有找到此清晰度的视频地址,请尝试其它清晰度的地址。" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
                [alertView show];
                return;
            }
            break;
        }
        case SUPER_CLEAR:{
            if ([superClearArr count] > play_url_index ) {
                NSString *url = [[plainClearArr objectAtIndex:play_url_index] objectForKey:@"url"];
                [self sendHttpRequest:url];
            }
            else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"没有找到此清晰度的视频地址,请尝试其它清晰度的地址。" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
                [alertView show];
                return;
            }
            break;
        }
        default:{
            NSMutableArray *playUrlArr = [NSMutableArray arrayWithCapacity:5];
            
            if ([highClearArr count]>0) {
                [playUrlArr addObjectsFromArray:highClearArr];
            }
            if ([superClearArr count]>0) {
                [playUrlArr addObjectsFromArray:superClearArr];
            }
            
            if ([plainClearArr count]>0) {
                [playUrlArr addObjectsFromArray:plainClearArr];
            }
            
            if (play_url_index < [playUrlArr count ]) {
                NSString *url = [[playUrlArr objectAtIndex:play_url_index] objectForKey:@"url"];
                [self sendHttpRequest:url];
            }
            else{
                NSLog(@"没找到可播放的地址！");
                [self.navigationController popViewControllerAnimated:YES];
            }

            break;
        }
    }
    
   
}

-(void)sendHttpRequest:(NSString *)str{
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([hostReach currentReachabilityStatus] != NotReachable){
        str = [str stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
        NSLog(@"The request url is %@",str);
        NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:str] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];
        [NSURLConnection connectionWithRequest:request delegate:self];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"网络异常，请检查网络。" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
        [alert show];
    
    }
    

}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"iphoneAvplayerViewController didFailWithError:%@",error);
    [self retryUrltoPlay];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
    int status_Code = HTTPResponse.statusCode;
    if (status_Code >= 200 && status_Code <= 299) {
        NSDictionary *headerFields = [HTTPResponse allHeaderFields];
        NSString *content_type = [NSString stringWithFormat:@"%@", [headerFields objectForKey:@"Content-Type"]];
        if (![content_type hasPrefix:@"text/html"]) {
             [self setURL:connection.originalRequest.URL];
             return;
        }
    
    }
    [self retryUrltoPlay];
}
-(void)initTopToolBar{
    topToolBar_ = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 480, 38)];
    [topToolBar_ setBackgroundImage:[UIUtility createImageWithColor:[UIColor colorWithRed:30/255.0 green:30/255.0 blue:30/255.0 alpha:0.5] ] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    [self.view addSubview:topToolBar_];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(7, 5, 39, 25);
    [closeButton setBackgroundImage:[UIImage imageNamed:@"iphone_back_bt"] forState:UIControlStateNormal];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"iphone_back_bt_pressed"] forState:UIControlStateHighlighted];
    closeButton.backgroundColor = [UIColor clearColor];
    closeButton.tag = CLOSE_BUTTON_TAG;
    [closeButton addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
    [topToolBar_ addSubview:closeButton];
    [topToolBar_ setBackgroundImage:[UIImage imageNamed:@"iphone_top_bg"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    selectButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
    selectButton_.frame = CGRectMake(422, 5, 57, 27);
    [selectButton_ setBackgroundImage:[UIImage imageNamed:@"iphone_select_bt"] forState:UIControlStateNormal];
    [selectButton_ setBackgroundImage:[UIImage imageNamed:@"iphone_select_bt_pressed"] forState:UIControlStateHighlighted];
    [selectButton_ setBackgroundImage:[UIImage imageNamed:@"iphone_select_bt_pressed"] forState:UIControlStateSelected];
    selectButton_.backgroundColor = [UIColor clearColor];
    selectButton_.tag = SELECT_BUTTON_TAG;
    [selectButton_ addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
    if (videoType_  != 1 || islocalFile_) {
        [topToolBar_ addSubview:selectButton_];
    }
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 30)];
    titleLabel.center = topToolBar_.center;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = nameStr_;
    [topToolBar_ addSubview:titleLabel];
    
    tableList_ = [[UITableView alloc] initWithFrame:CGRectMake(378, 35, 100, 0) style:UITableViewStylePlain];
    tableList_.backgroundColor = [UIColor clearColor];
    tableList_.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableList_.delegate = self;
    tableList_.dataSource = self;
    [self.view addSubview:tableList_];
    
    if (!islocalFile_) {
        UILabel *sourceText = [[UILabel alloc] initWithFrame:CGRectMake(70, 8, 30, 18)];
        sourceText.text = @"来源:";
        sourceText.textColor = [UIColor whiteColor];
        sourceText.backgroundColor = [UIColor clearColor];
        sourceText.font = [UIFont systemFontOfSize:12];
        [topToolBar_ addSubview:sourceText];
        
        sourceLogo_ = [[UIImageView alloc] initWithFrame:CGRectMake(102, 8, 30, 18)];
        sourceLogo_.backgroundColor = [UIColor clearColor];
        [topToolBar_ addSubview:sourceLogo_];
    }

}
-(void)initPlayerView{
    mPlayer = nil;
    avplayerView_ = [[AVPlayerView alloc] initWithFrame:CGRectMake(0, 0, 480, 300)];
    avplayerView_.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showToolBar)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [avplayerView_ addGestureRecognizer:tapGesture];
    [self.view addSubview:avplayerView_];
    
    airPlayLabel_ = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 300, 40)];
    airPlayLabel_.center = CGPointMake(avplayerView_.center.x, avplayerView_.center.y);
    airPlayLabel_.backgroundColor = [UIColor clearColor];
    airPlayLabel_.textColor = [UIColor lightGrayColor];
    airPlayLabel_.text = @"此视频正在通过 AirPlay 播放。";
    airPlayLabel_.font = [UIFont systemFontOfSize:15];
    airPlayLabel_.textAlignment = NSTextAlignmentCenter;

}

-(void)initBottomToolBar{
    
    bottomToolBar_ = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 256, 480, 44)];
    bottomToolBar_.backgroundColor = [UIColor clearColor];
    //bottomToolBar_.alpha = 0.8;
    [bottomToolBar_ setBackgroundImage:[UIImage imageNamed:@"iphone_play_bg"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    [self.view addSubview:bottomToolBar_];
    
    bottomView_ = [[UIImageView alloc] initWithFrame:CGRectMake(0,231, kFullWindowHeight, 25)];
    bottomView_.alpha = 0.8;
    bottomView_.image = [UIImage imageNamed:@"iphone_time_bg"];
    bottomView_.backgroundColor = [UIColor clearColor];
    bottomView_.userInteractionEnabled = YES;
    [self.view addSubview:bottomView_];
    
    seeTimeLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(9, 8, 90, 10)];
    seeTimeLabel_.backgroundColor = [UIColor clearColor];
    seeTimeLabel_.font = [UIFont systemFontOfSize:12];
    seeTimeLabel_.textAlignment = NSTextAlignmentLeft;
    seeTimeLabel_.textColor = [UIColor whiteColor];
    seeTimeLabel_.text = @"00:00";
    [bottomView_ addSubview:seeTimeLabel_];
    
    totalTimeLable_ = [[UILabel alloc] initWithFrame:CGRectMake(423, 8, 90, 10)];
    totalTimeLable_.backgroundColor = [UIColor clearColor];
    totalTimeLable_.font = [UIFont systemFontOfSize:12];
    totalTimeLable_.textAlignment = NSTextAlignmentLeft;
    totalTimeLable_.textColor = [UIColor whiteColor];
    [bottomView_ addSubview:totalTimeLable_];
    
    
    mScrubber = [[UISlider alloc]initWithFrame:CGRectMake(0, 0, 354 , 8)];
    mScrubber.center = CGPointMake(kFullWindowHeight/2, 13);
    [mScrubber setThumbImage: [UIImage imageNamed:@"iphone_progress_thumb"] forState:UIControlStateNormal];
    [mScrubber setMinimumTrackImage:[UIImage imageNamed:@"iphone_time_jindu_x"] forState:UIControlStateNormal];
    [mScrubber setMaximumTrackImage:[UIImage imageNamed:@"iphone_time_jindu"] forState:UIControlStateNormal];
    [mScrubber addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchCancel];
    [mScrubber addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchUpInside];
    [mScrubber addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchUpOutside];
    [mScrubber addTarget:self action:@selector(beginScrubbing:) forControlEvents:UIControlEventTouchDown];
    [mScrubber addTarget:self action:@selector(scrub:) forControlEvents:UIControlEventValueChanged];
    [mScrubber addTarget:self action:@selector(scrub:) forControlEvents:UIControlEventTouchDragInside];
    [mScrubber addTarget:self action:@selector(scrub:) forControlEvents:UIControlEventTouchUpOutside];
    [bottomView_ addSubview:mScrubber];
    
    
    UIButton *fullScreen = [UIButton buttonWithType:UIButtonTypeCustom];
    fullScreen.frame = CGRectMake(18, 8, 33, 27);
    fullScreen.backgroundColor = [UIColor clearColor];
    fullScreen.tag = FULL_SCREEN_TAG;
    [fullScreen setBackgroundImage:[UIImage imageNamed:@"iphone_full_bt"] forState:UIControlStateNormal];
    [fullScreen setBackgroundImage:[UIImage imageNamed:@"iphone_full_bt_pressed"] forState:UIControlStateHighlighted];
    [fullScreen setBackgroundImage:[UIImage imageNamed:@"iphone_reduce_bt"] forState:UIControlStateSelected];
    [fullScreen addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
    [bottomToolBar_ addSubview:fullScreen];
    
    playButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
    playButton_.frame = CGRectMake(kFullWindowHeight/2-21, 3, 42, 35);
    [playButton_ setBackgroundImage:[UIImage imageNamed:@"iphone_play_bt"] forState:UIControlStateNormal];
    [playButton_ setBackgroundImage:[UIImage imageNamed:@"iphone_play_bt_pressed"] forState:UIControlStateHighlighted];
    playButton_.backgroundColor = [UIColor clearColor];
    playButton_.tag = PLAY_BUTTON_TAG;
    [playButton_ addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
    [bottomToolBar_ addSubview:playButton_];
    
    pauseButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
    pauseButton_.frame = CGRectMake(kFullWindowHeight/2-21, 3, 42, 35);
    [pauseButton_ setBackgroundImage:[UIImage imageNamed:@"iphone_pause_bt"] forState:UIControlStateNormal];
    [pauseButton_ setBackgroundImage:[UIImage imageNamed:@"iphone_pause_bt_pressed"] forState:UIControlStateHighlighted];
    pauseButton_.backgroundColor = [UIColor clearColor];
    pauseButton_.tag = PAUSE_BUTTON_TAG;
    [pauseButton_ addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
    pauseButton_.hidden = YES;
    [bottomToolBar_ addSubview:pauseButton_];
    
    UIButton *preButton = [UIButton buttonWithType:UIButtonTypeCustom];
    preButton.frame = CGRectMake(182, 6, 32, 31);
    preButton.backgroundColor = [UIColor clearColor];
    preButton.tag = PRE_BUTTON_TAG;
    [preButton setBackgroundImage:[UIImage imageNamed:@"iphone_prev_bt"] forState:UIControlStateNormal];
    [preButton setBackgroundImage:[UIImage imageNamed:@"iphone_prev_bt_pressed"] forState:UIControlStateHighlighted];
    [preButton setBackgroundImage:[UIImage imageNamed:@"iphone_prev_bt_disabled"] forState:UIControlStateDisabled];
    [preButton addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
    [bottomToolBar_ addSubview:preButton];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.frame = CGRectMake(267, 7, 29, 27);
    nextButton.backgroundColor = [UIColor clearColor];
    nextButton.tag = NEXT_BUTTON_TAG;
    [nextButton setBackgroundImage:[UIImage imageNamed:@"iphone_next_bt"] forState:UIControlStateNormal];
    [nextButton setBackgroundImage:[UIImage imageNamed:@"iphone_next_bt_pressed"] forState:UIControlStateHighlighted];
    [nextButton setBackgroundImage:[UIImage imageNamed:@"iphone_next_bt_disabled"] forState:UIControlStateDisabled];
    [nextButton addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
    if (videoType_ == 1) {
        nextButton.enabled = NO;
    }
    [bottomToolBar_ addSubview:nextButton];
    
    clarityButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
    clarityButton_.frame = CGRectMake(422, 8, 57, 27);
    clarityButton_.backgroundColor = [UIColor clearColor];
    [clarityButton_ setBackgroundImage:[UIImage imageNamed:@"iphone_quality_bt"] forState:UIControlStateNormal];
    [clarityButton_ setBackgroundImage:[UIImage imageNamed:@"iphone_quality_bt_pressed"] forState:UIControlStateHighlighted];
    [clarityButton_ setBackgroundImage:[UIImage imageNamed:@"iphone_quality_bt_pressed"] forState:UIControlStateSelected];
    clarityButton_.adjustsImageWhenHighlighted = NO;
    clarityButton_.tag = CLARITY_BUTTON_TAG;
    [clarityButton_ addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
    [bottomToolBar_ addSubview:clarityButton_];
    
    [self clearSelectView];
    
    volumeView_ = [ [MPVolumeView alloc] initWithFrame:CGRectMake(60, 7, 30, 30)];
    volumeView_.backgroundColor = [UIColor clearColor];
    [volumeView_ setShowsVolumeSlider:NO];
    [volumeView_ setShowsRouteButton:YES];
    for (UIView *asubview in volumeView_.subviews) {
        if ([NSStringFromClass(asubview.class) isEqualToString:@"MPButton"]) {
            UIButton *btn = (UIButton *)asubview;
            btn.backgroundColor = [UIColor clearColor];
            btn.frame = CGRectMake(0, 0, 33, 27);
            [btn setImage:nil forState:UIControlStateNormal];
            [btn setImage:nil forState:UIControlStateHighlighted];
            [btn setImage:nil forState:UIControlStateSelected];
            [btn setBackgroundImage:[UIImage imageNamed:@"iphone_route_bt"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"iphone_route_bt_light"] forState:UIControlStateHighlighted];
            break;
        }
    }
    [bottomToolBar_ addSubview:volumeView_];
    
}


-(void)clearSelectView{
    clearBgView_ = [[UIImageView alloc] initWithFrame:CGRectMake(270, 150, 202, 109)];
    clearBgView_.image = [UIImage imageNamed:@"iphone_clarity_bg"];
    clearBgView_.backgroundColor = [UIColor clearColor];
    clearBgView_.userInteractionEnabled = YES;
   
    UIButton *plainClearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    plainClearBtn.frame = CGRectMake(0, 0, 42, 42);
    plainClearBtn.center = CGPointMake(34, 65);
    plainClearBtn.tag = 100;
    [plainClearBtn addTarget:self action:@selector(clearButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    [plainClearBtn setBackgroundImage:[UIImage imageNamed:@"iphone_biaoqing_bt"] forState:UIControlStateNormal];
    [plainClearBtn setBackgroundImage:[UIImage imageNamed:@"iphone_biaoqing_bt_pressed"] forState:UIControlStateHighlighted];
    [plainClearBtn setBackgroundImage:[UIImage imageNamed:@"iphone_biaoqing_bt_pressed"]forState:UIControlStateDisabled];
    plainClearBtn.adjustsImageWhenDisabled = NO;
    [clearBgView_ addSubview:plainClearBtn];
    
    UIButton *highClearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    highClearBtn.backgroundColor = [UIColor clearColor];
    [highClearBtn addTarget:self action:@selector(clearButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    [highClearBtn setBackgroundImage:[UIImage imageNamed:@"iphone_gaoqing_high_bt"] forState:UIControlStateNormal];
    [highClearBtn setBackgroundImage:[UIImage imageNamed:@"iphone_gaoqing_bt_pressed"] forState:UIControlStateHighlighted];
    [highClearBtn setBackgroundImage:[UIImage imageNamed:@"iphone_gaoqing_bt_pressed"]forState:UIControlStateDisabled];
    highClearBtn.frame = CGRectMake(0, 0, 42, 42);
    highClearBtn.center = CGPointMake(101, 65);
    highClearBtn.enabled = NO;
    highClearBtn.tag = 101;
    highClearBtn.adjustsImageWhenDisabled = NO;
    [clearBgView_ addSubview:highClearBtn];
    
    UIButton *superClearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    superClearBtn.backgroundColor = [UIColor clearColor];
    [superClearBtn addTarget:self action:@selector(clearButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    [superClearBtn setBackgroundImage:[UIImage imageNamed:@"iphone_chaoqing_super_bt"] forState:UIControlStateNormal];
    [superClearBtn setBackgroundImage:[UIImage imageNamed:@"iphone_chaoqing_bt_pressed"] forState:UIControlStateHighlighted];
    [superClearBtn setBackgroundImage:[UIImage imageNamed:@"iphone_chaoqing_bt_pressed"]forState:UIControlStateDisabled];
    superClearBtn.frame = CGRectMake(0, 0, 42, 42);
    superClearBtn.center = CGPointMake(168, 65);
    superClearBtn.tag = 102;
    superClearBtn.adjustsImageWhenDisabled = NO;
    [clearBgView_ addSubview:superClearBtn];
    
}
-(void)clearButtonSelected:(UIButton *)btn{

    for (UIView *view in clearBgView_.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *subBtn = (UIButton *)view;
            subBtn.enabled = YES;
        }
    }
    
    playCacheView_.backgroundColor = [UIColor clearColor];
    [clearBgView_ removeFromSuperview];

    switch (btn.tag) {
        case 100:{
            btn.enabled = NO;
            clear_type = PLAIN_CLEAR;
           
            break;
        }
        case 101:{
            clear_type = HIGH_CLEAR;
            btn.enabled = NO;
            
            break;
        }
        case 102:{
            clear_type = SUPER_CLEAR;
            btn.enabled = NO;
       
            break;
        }
        default:
            break;
    }
     [self beginToPlay];
}
-(void)action:(UIButton *)btn{
    switch (btn.tag) {
        case CLOSE_BUTTON_TAG:{
            [self updateWatchRecord];
            
            [avplayerView_.layer removeFromSuperlayer];
            [self.player removeObserver:self forKeyPath:@"rate"];
            [self.player.currentItem removeObserver:self forKeyPath:@"status"];
            [self.player  pause];
            mPlayerItem = nil;
            mPlayer = nil;
           
            [self dismissViewControllerAnimated:YES completion:nil];
          
            //[self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case FULL_SCREEN_TAG:{
            
            if([((AVPlayerLayer *)[avplayerView_ layer]).videoGravity isEqualToString:AVLayerVideoGravityResizeAspect]){
                [btn setBackgroundImage:[UIImage imageNamed:@"iphone_reduce_bt"] forState:UIControlStateNormal];
                [btn setBackgroundImage:[UIImage imageNamed:@"iphone_reduce_bt_pressed"] forState:UIControlStateHighlighted];
                [avplayerView_ setVideoFillMode: AVLayerVideoGravityResizeAspectFill];
            } else {
                [btn setBackgroundImage:[UIImage imageNamed:@"iphone_full_bt"] forState:UIControlStateNormal];
                [btn setBackgroundImage:[UIImage imageNamed:@"iphone_full_bt_pressed"] forState:UIControlStateHighlighted];
                [avplayerView_ setVideoFillMode: AVLayerVideoGravityResizeAspect];
            }
            
            break;
        }
        case PLAY_BUTTON_TAG:{
            [mPlayer play];
            btn.hidden = YES;
            pauseButton_.hidden = NO;
            break;
        }
        case PAUSE_BUTTON_TAG:{
            [mPlayer pause];
            btn.hidden = YES;
            playButton_.hidden = NO;
            
            break;
        }
        case PRE_BUTTON_TAG:{
            double time = CMTimeGetSeconds([mPlayer currentTime]);
            if (time>= 30) {
                [mPlayer seekToTime:CMTimeMakeWithSeconds(time-30, NSEC_PER_SEC)];
            }
            else{
                [mPlayer seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC)];
            
            }
            
            break;
        }
        case NEXT_BUTTON_TAG:{
            if (videoType_ == 1) {
                return;
            }
            
            [self playNext];
            break;
        }
        case CLARITY_BUTTON_TAG:{
            [self resetMyTimer];
            if (btn.selected) {
                btn.selected = NO;
                [clearBgView_ removeFromSuperview];
            }
            else{
            
                btn.selected = YES;
                [self.view addSubview:clearBgView_];
            }

            
            break;
        }
        case SELECT_BUTTON_TAG:{
            [self resetMyTimer];
            if (btn.selected) {
                btn.selected = NO;
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.3];
                tableList_.frame = CGRectMake(378, 35, 100, 0);
                [UIView commitAnimations];
            }
            else{
                btn.selected = YES;
                int height =  38*[episodesArr_ count];
                if (height >195) {
                    height = 195;
                }
                
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.3];
                tableList_.frame = CGRectMake(378, 35, 100, height);
                [UIView commitAnimations];
              
            }
            break;
        }
              
        default:
            break;
    }

}

- (void)beginScrubbing:(id)sender
{
	mRestoreAfterScrubbingRate = [mPlayer rate];
	[mPlayer setRate:0.f];
	
	/* Remove previous timer. */
	[self removePlayerTimeObserver];
}

/* The user has released the movie thumb control to stop scrubbing through the movie. */
- (void)endScrubbing:(id)sender
{
    [self resetMyTimer];
	if (!mTimeObserver)
	{
		CMTime playerDuration = [self playerItemDuration];
		if (CMTIME_IS_INVALID(playerDuration)) {
			return;
		}
		
		double duration = CMTimeGetSeconds(playerDuration);
		if (isfinite(duration))
		{
			CGFloat width = CGRectGetWidth([mScrubber bounds]);
			double tolerance = 0.5f * duration / width;
            
			mTimeObserver = [mPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC) queue:NULL usingBlock:
                             ^(CMTime time)
                             {
                                 [self syncScrubber];
                             }];
		}
	}
    
	if (mRestoreAfterScrubbingRate)
	{
		[mPlayer setRate:mRestoreAfterScrubbingRate];
		mRestoreAfterScrubbingRate = 0.f;
	}
}

- (BOOL)isScrubbing
{
	return mRestoreAfterScrubbingRate != 0.f;
}

-(void)scrub:(id)sender{

    [self resetMyTimer];
    [self removePlayerTimeObserver];
    if ([sender isKindOfClass:[UISlider class]])
	{
		UISlider* slider = sender;
		
		CMTime playerDuration = [self playerItemDuration];
		if (CMTIME_IS_INVALID(playerDuration)) {
			return;
		}
		
		double duration = CMTimeGetSeconds(playerDuration);
		if (isfinite(duration))
		{
			float minValue = [slider minimumValue];
			float maxValue = [slider maximumValue];
			float value = [slider value];
			
			double time = duration * (value - minValue) / (maxValue - minValue);
			
			[mPlayer seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
        
		}
	}



}
-(UIImage *)getVideoSource:(NSString *)urlStr{
    NSString *source_str = nil;
    NSMutableArray *playUrlArr = [NSMutableArray arrayWithCapacity:5];
    
    if ([highClearArr count]>0) {
        [playUrlArr addObjectsFromArray:highClearArr];
    }
    if ([superClearArr count]>0) {
        [playUrlArr addObjectsFromArray:superClearArr];
    }
    
    if ([plainClearArr count]>0) {
        [playUrlArr addObjectsFromArray:plainClearArr];
    }
    for (NSMutableDictionary *dic in playUrlArr) {
        if ([[dic objectForKey:@"url"] isEqualToString:urlStr]) {
            source_str = [dic objectForKey:@"source"];
            break;
        }
    }
    UIImage *logoImg = nil;
    if ([source_str isEqualToString:@"letv"]) {
        logoImg = [UIImage imageNamed:@"logo_letv"];
    }
    else if ([source_str isEqualToString:@"fengxing"]){
        logoImg = [UIImage imageNamed:@"logo_fengxing"];
    }
    else if ([source_str isEqualToString:@"qiyi"]){
        logoImg = [UIImage imageNamed:@"logo_qiyi"];
    }
    else if ([source_str isEqualToString:@"youku"]){
        logoImg = [UIImage imageNamed:@"logo_youku"];
    }
    else if ([source_str isEqualToString:@"sinahd"]){
       logoImg = [UIImage imageNamed:@"logo_sinahd"];
    }
    else if ([source_str isEqualToString:@"sohu"]){
        logoImg = [UIImage imageNamed:@"logo_sohu"];  
    }
    else if ([source_str isEqualToString:@"56"]){
        logoImg = [UIImage imageNamed:@"logo_56"];
    }
    else if ([source_str isEqualToString:@"qq"]){
        logoImg = [UIImage imageNamed:@"logo_qq"];
    }
    else if ([source_str isEqualToString:@"pptv"]){
        logoImg = [UIImage imageNamed:@"logo_pptv"];
    }
    else if ([source_str isEqualToString:@"pps"]){
        logoImg = [UIImage imageNamed:@"logo_pps"];
    }
    else if ([source_str isEqualToString:@"m1905"]){
        logoImg = [UIImage imageNamed:@"logo_m1905"];
    }

    return logoImg;

}
-(void)syncLogo:(NSString *)url{
    UIImage *img = [self getVideoSource:url];
    int a = img.size.width;
    sourceLogo_.frame = CGRectMake(102, 8, img.size.width/2, 18);
    sourceLogo_.image = img;
}
- (void)updateWatchRecord
{
   
    if(!islocalFile_){
        int playbackTime = 0;
        if(CMTimeGetSeconds([mPlayer currentTime])> 0){
            playbackTime = [NSNumber numberWithFloat:CMTimeGetSeconds([mPlayer currentTime])].intValue;
        }
        int duration = 0;
        if(CMTimeGetSeconds([self playerItemDuration]) > 0){
            duration = [NSNumber numberWithFloat:CMTimeGetSeconds([self playerItemDuration])].intValue;
        }
        NSString *userId = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId];
        NSString *tempPlayType = @"1";

        NSString *playUrl = ((AVURLAsset *)mPlayerItem.asset).URL.absoluteString;
        if (playUrl == nil) {
            tempPlayType = @"2";
            playUrl = webPlayUrl_;
        }
        [[CacheUtility sharedCache] putInCache:[NSString stringWithFormat:@"%@_%d",prodId_,playNum] result:[NSNumber numberWithInt:playbackTime] ];
        
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: userId, @"userid", prodId_, @"prod_id", nameStr_, @"prod_name", [NSString stringWithFormat:@"%d",playNum], @"prod_subname", [NSNumber numberWithInt:videoType_], @"prod_type", tempPlayType, @"play_type", [NSNumber numberWithInt:playbackTime], @"playback_time", [NSNumber numberWithInt:duration], @"duration", playUrl, @"video_url", nil];
        [[AFServiceAPIClient sharedClient] postPath:kPathAddPlayHistory parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        [[NSNotificationCenter defaultCenter] postNotificationName:WATCH_HISTORY_REFRESH object:nil];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
           
        }];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return [episodesArr_ count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor blackColor];
        cell.contentView.alpha = 0.8;
        
        UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"jishu_fen_ge_xian"]];
        line.frame = CGRectMake(1, 37, cell.frame.size.width-2, 1);
        [cell.contentView addSubview:line];
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.font = [UIFont systemFontOfSize:12];
     
    if (indexPath.row == playNum) {
        cell.textLabel.textColor = [UIColor colorWithRed:253/255.0 green:128/255.0 blue:8/255.0 alpha:1];
    }
    else{
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    if (videoType_ == 2) {
       
        cell.textLabel.text = [NSString stringWithFormat:@"第%d集",(indexPath.row+1)];
    }
    else if(videoType_ == 3){
        NSDictionary *item = [episodesArr_ objectAtIndex:indexPath.row];
        NSString *name = [item objectForKey:@"name"];
        cell.textLabel.text = name;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    }
   
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 38.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self removePlayerTimeObserver];
    [self.player pause];
    if (timeLabelTimer_ != nil) {
        [timeLabelTimer_ invalidate];
    }
    playNum = indexPath.row;
    [self initDataSource:playNum];
    [self beginToPlay];
    
}

-(NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskLandscapeRight;
    
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationLandscapeRight;
    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [avplayerView_.layer removeFromSuperlayer];
    [self.player removeObserver:self forKeyPath:@"rate"];
	[self.player .currentItem removeObserver:self forKeyPath:@"status"];
    [self.player  pause];
    mPlayerItem = nil;
    mPlayer = nil;
   

}

@end
