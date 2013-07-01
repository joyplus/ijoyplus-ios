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
#import "ActionUtility.h"
#import <Parse/Parse.h>
#import "CustomNavigationViewControllerPortrait.h"
#import "CommonMotheds.h"
#import "SubdownloadItem.h"
#import "DatabaseManager.h"
#import "TFHpple.h"

/* Asset keys */
 NSString * const k_TracksKey         = @"tracks";
 NSString * const k_PlayableKey		= @"playable";

/* PlayerItem keys */
 NSString * const k_StatusKey         = @"status";
 NSString * const k_BufferEmpty       = @"playbackBufferEmpty";
 NSString * const k_ToKeepUp          = @"playbackLikelyToKeepUp";

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
#define CLOUND_TV_BUTTON_TAG    10010
#define LOCAL_LOGO_BUTTON_TAG   10011
#define TRACK_BUTTON_TAG 10012
#define PLAIN_CLEAR 100
#define HIGH_CLEAR 200
#define SUPER_CLEAR 300
#define MINI_PLAY_DURATION      (3.0f)
#define KEY_MAX_CONNECT_TIME    (5)

enum
{
    CLOUND_TV_PLAY,
    CLOUND_TV_PAUSE,
    CLOUND_TV_CLOSE,
    CLOUND_TV_SEEK_TO_TIME,
    UNKNOW_TYPE
};

@interface IphoneAVPlayerViewController ()
{
    NSURLConnection     *urlConnection;
}
@property (nonatomic) double seekBeginTime;
@property (nonatomic, strong) NSMutableArray * downloadIndex;
@property (nonatomic) BOOL fromBaidu;
- (void)stopMyTimer;
- (void)beginMyTimer;
- (void)showActivityView;
- (void)dismissActivityView;
- (void)pushWebURLToCloudTV:(NSString *)pushType;
- (void)setPlayVolume:(CGFloat)volume;
- (void)controlCloundTV:(NSInteger)controlType;
- (void)getVideoDetail;
- (void)prepareOnlinePlay:(NSArray *)episodes;
- (void)playLocal:(NSDictionary *)file;
- (void)changeTracks:(int)type;

@end
static void *AVPlayerDemoPlaybackViewControllerRateObservationContext = &AVPlayerDemoPlaybackViewControllerRateObservationContext;
static void *AVPlayerDemoPlaybackViewControllerStatusObservationContext = &AVPlayerDemoPlaybackViewControllerStatusObservationContext;
static void *AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext = &AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext;
static void *AVPlayerDemoPlaybackViewControllerCurrentItemBufferingContext = &AVPlayerDemoPlaybackViewControllerCurrentItemBufferingContext;
@implementation IphoneAVPlayerViewController
@synthesize seekBeginTime;
@synthesize topToolBar = topToolBar_;
@synthesize bottomToolBar = bottomToolBar_;
@synthesize avplayerView = avplayerView_;
@synthesize mPlayerItem ,mPlayer,mURL,mScrubber,myHUD;
@synthesize selectButton = selectButton_;
@synthesize clarityButton = clarityButton_;
@synthesize localLogoBtn;
@synthesize playButton = playButton_;
@synthesize pauseButton = pauseButton;
@synthesize cloundTVButton;
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
@synthesize willPlayLabel = willPlayLabel_;
@synthesize workingUrl = workingUrl_;
@synthesize titleLabel = titleLabel_;
@synthesize webUrlSource = webUrlSource_;
@synthesize subnameArray;
@synthesize isM3u8 = isM3u8_;
@synthesize continuePlayInfo = continuePlayInfo_;
@synthesize isPlayFromRecord = isPlayFromRecord_;
@synthesize localPlaylist,downloadIndex, fromBaidu;
#pragma mark Asset URL

- (void)setURL:(NSURL*)URL
{
	if (mURL != URL)
	{
		mURL = URL;
        
        workingUrl_ = URL.absoluteString;
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:mURL options:nil];
        
        NSString * nameStr = @"myQueue";
        const char * queueName = [nameStr UTF8String];
        dispatch_queue_t queue = dispatch_queue_create(queueName, NULL);
        dispatch_async(queue, ^(void){
            NSMutableArray *allAudioParams = [NSMutableArray array];
            NSArray *audioTracks =  [asset tracksWithMediaType:AVMediaTypeAudio];
            if ([audioTracks count]>1)
            {
                for (int i = 0; i < [audioTracks count]; i++)
                {
                    AVMutableAudioMixInputParameters *audioInputParams =
                    [AVMutableAudioMixInputParameters audioMixInputParameters];

                    if (i != 0)
                    {
                        [audioInputParams setVolume:0.0 atTime:kCMTimeZero];
                    }

                    AVAssetTrack *track = [audioTracks objectAtIndex:i];
                    [audioInputParams setTrackID:[track trackID]];
                    [allAudioParams addObject:audioInputParams];
                }
                audioMix_ = [AVMutableAudioMix audioMix];
                [audioMix_ setInputParameters:allAudioParams];
            }
            [self prepareToPlayAsset:asset];
        });
        
        
    }
}


-(void)setPath:(NSString *)path{

    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:path] options:nil];

    NSMutableArray *allAudioParams = [NSMutableArray array];
    NSArray *audioTracks =  [asset tracksWithMediaType:AVMediaTypeAudio];
    if ([audioTracks count]>1) {
        for (int i = 0; i < [audioTracks count]; i++) {
            AVMutableAudioMixInputParameters *audioInputParams =
            [AVMutableAudioMixInputParameters audioMixInputParameters];
            if (i > 0) {
                [audioInputParams setVolume:0.0 atTime:kCMTimeZero];
            }
            AVAssetTrack *track = [audioTracks objectAtIndex:i];
            [audioInputParams setTrackID:[track trackID]];
            [allAudioParams addObject:audioInputParams];
        }
        audioMix_ = [AVMutableAudioMix audioMix];
        [audioMix_ setInputParameters:allAudioParams];
    }
    
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
    
    if (audioMix_) {
        [self.mPlayerItem setAudioMix:audioMix_];
        [self showTrackSelectButton];
    }
    /* Observe the player item "status" key to determine when it is ready to play. */
    [self.mPlayerItem addObserver:self
                       forKeyPath:k_StatusKey
                          options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          context:AVPlayerDemoPlaybackViewControllerStatusObservationContext];
    //buffering
	[self.mPlayerItem addObserver:self
                       forKeyPath:k_BufferEmpty
                          options:NSKeyValueObservingOptionNew
                          context:AVPlayerDemoPlaybackViewControllerCurrentItemBufferingContext];
    [self.mPlayerItem addObserver:self
                       forKeyPath:k_ToKeepUp
                          options:NSKeyValueObservingOptionNew
                          context:AVPlayerDemoPlaybackViewControllerCurrentItemBufferingContext];
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
        
        //self.player.usesExternalPlaybackWhileExternalScreenIsActive = YES;
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
	
    
    if (CMTIME_IS_VALID(lastPlayTime_)) {
        [mPlayer seekToTime:lastPlayTime_];
         seeTimeLabel_.text =  [TimeUtility formatTimeInSecond:CMTimeGetSeconds(lastPlayTime_)];
    }
    

    if (videoType_ == 2 || videoType_ ==3) {
       [[CacheUtility sharedCache]putInCache:[NSString stringWithFormat:@"drama_epi_%@", prodId_] result:[NSNumber numberWithInt:playNum]];
    }
  
    [self  syncCurrentClear];
}

-(void)assetFailedToPrepareForPlayback:(NSError *)error
{
    [self removePlayerTimeObserver];
    [self syncScrubber];
    [self disableScrubber];
    [self disableBottomToolBarButtons];
    /* Display the error. */
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
   
    if (islocalFile_ && isM3u8_) {
        return  CMTimeMakeWithSeconds(self.playDuration, NSEC_PER_SEC);
    }
    
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
-(void)disableScrubber{
  self.mScrubber.enabled = NO;
}

-(void)disableBottomToolBarButtons
{
   
    for (UIView *view in bottomToolBar_.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            if (view.tag == PRE_BUTTON_TAG || view.tag == FULL_SCREEN_TAG || view.tag == CLARITY_BUTTON_TAG || view.tag  == PLAY_BUTTON_TAG || view.tag == PAUSE_BUTTON_TAG) {
                UIButton *btn = (UIButton *)view;
                btn.enabled = NO;
            }
        }
    }
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
                [self disableBottomToolBarButtons];
                [self disableAirPlayButton];
                
                playButton_.hidden = YES;
                pauseButton_.hidden = NO;
                myHUD.hidden = NO;
                [mPlayer play];
            }
                break;
                
            case AVPlayerStatusReadyToPlay:
            {
                /* Once the AVPlayerItem becomes ready to play, i.e.
                 [playerItem status] == AVPlayerItemStatusReadyToPlay,
                 its duration can be fetched from the item. */
                
                if (!islocalFile_) {
                    [self syncLogo:workingUrl_];
                }
                else
                {
                    UILabel * label = (UILabel *)[topToolBar_ viewWithTag:100001];
                    label.text = nil;
                    sourceLogo_.image = nil;
                }
                
                
                CMTime playerDuration = [self playerItemDuration];
                totalTimeLable_.text = [TimeUtility formatTimeInSecond:CMTimeGetSeconds(playerDuration)];
                
                [playCacheView_ removeFromSuperview];
                myHUD.hidden = YES;
                [self initScrubberTimer];
                [self initTimeLabelTimer];
                [self enableBottomToolBarButtons];
                [self enableTracksSelectButton];
                if (mPlayer.airPlayVideoActive){
                    [self enaleAirPlayButton];
                }
                //[self showToolBar];
                
                [mPlayer play];
                
                playButton_.hidden = YES;
                pauseButton_.hidden = NO;
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
           //[self syncPlayPauseButtons];
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
            [self disableBottomToolBarButtons];
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
    else if (context == AVPlayerDemoPlaybackViewControllerCurrentItemBufferingContext)
    {
        AVPlayerItem * pItem = (AVPlayerItem *)object;
        if (k_BufferEmpty == path)
        {
            if (pItem.playbackBufferEmpty)
            {
                NSLog(@"Buffer Empty");
                [self showActivityView];
            }
            else
            {
                NSLog(@"Not Empty");
            }
            
        }
        else if (k_ToKeepUp == path)
        {
            if (pItem.playbackLikelyToKeepUp)
            {
                [self dismissActivityView];
                NSLog(@"KeepUp, dismiss waitting view");
                BOOL isPlaying = [self isPlaying];
                BOOL isHidden = playButton_.hidden;
                if (!isPlaying && isHidden)
                {
                    [mPlayer play];
                    //NSLog(@"AVPlayer play");
                }
            }
            else
            {
                if (![self isPlaying])
                {
                    NSLog(@"Not KeepUp, show waitting view");
                    [self showActivityView];
                }
            }
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
	double interval = 0.1f;
	
	CMTime playerDuration = [self playerItemDuration];
	if (CMTIME_IS_INVALID(playerDuration))
	{
		return;
	}
	double duration = CMTimeGetSeconds(playerDuration);
	if (isfinite(duration))
	{
		CGFloat width = CGRectGetWidth([mScrubber bounds]);
		interval = 0.5f * duration / width;
	}
    
    if (nil != mTimeObserver)
    {
        [mTimeObserver invalidate];
        mTimeObserver = nil;
    }
	/* Update the scrubber during normal playback. */
    __block typeof (self) myself = self;
    if (isnan(interval) || interval < 0.1f) {
        interval = 0.1f;
    }
	mTimeObserver = [mPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                                                           queue:NULL /* If you pass NULL, the main queue is used. */
                                                      usingBlock:^(CMTime time)
                      {
                          double curTime = CMTimeGetSeconds([myself.mPlayer currentTime]);
                          
                          if (fabs(curTime - myself.seekBeginTime) > 1.0f)
                          {
                              [myself syncScrubber];
                          }
                      }];
  
    
}

-(void)initTimeLabelTimer
{
    if (nil != timeLabelTimer_)
    {
        [timeLabelTimer_ invalidate];
        timeLabelTimer_ = nil;
    }
   timeLabelTimer_ = [NSTimer scheduledTimerWithTimeInterval:1
                                                      target:self
                                                    selector:@selector(syncTimeLabel)
                                                    userInfo:nil
                                                     repeats:YES];
}
-(void)syncTimeLabel{
    seeTimeLabel_.text =  [TimeUtility formatTimeInSecond:CMTimeGetSeconds([mPlayer currentTime])];

}
-(void)enableBottomToolBarButtons
{
    self.mScrubber.enabled = YES;
    for (UIView *view in bottomToolBar_.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            if (view.tag == PRE_BUTTON_TAG || view.tag == FULL_SCREEN_TAG || view.tag == CLARITY_BUTTON_TAG || view.tag  == PLAY_BUTTON_TAG || view.tag == PAUSE_BUTTON_TAG) {
                UIButton *btn = (UIButton *)view;
                btn.enabled = YES;
            }
        }
    }

}

-(void)hiddenToolBar{

     topToolBar_.hidden = YES;
     bottomToolBar_.hidden = YES;
     bottomView_.hidden = YES;
    selectButton_.selected = NO;
    clarityButton_.selected = NO;
    tableList_.frame = CGRectMake(kFullWindowHeight-110, 55, 100, 0);
     clearBgView_.hidden = YES;
    [self hiddenChangeTrackView];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}
-(void)showToolBar{
    [self.view bringSubviewToFront:topToolBar_];
    [self.view bringSubviewToFront:bottomToolBar_];
    [self.view bringSubviewToFront:bottomView_];
    if (bottomToolBar_.hidden) {
        topToolBar_.hidden = NO;
        bottomToolBar_.hidden = NO;
        bottomView_.hidden = NO;
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    else{
        topToolBar_.hidden = YES;
        bottomToolBar_.hidden = YES;
        bottomView_.hidden = YES;
        selectButton_.selected = NO;
        tableList_.frame = CGRectMake(kFullWindowHeight-110, 55, 100, 0);
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    
    if (selectButton_.selected) {
//        selectButton_.selected = NO;
//        tableList_.frame = CGRectMake(kFullWindowHeight-110, 55, 100, 0);
        [self.view bringSubviewToFront:tableList_];
    }
    
    if (clarityButton_.selected) {
        clarityButton_.selected = NO;
        clearBgView_.hidden = YES;
    }
    UIButton *tack = (UIButton *)[bottomToolBar_ viewWithTag:TRACK_BUTTON_TAG];
    if (tack.selected) {
        tack.selected = NO;
        [self hiddenChangeTrackView];
    }

    [self resetMyTimer];

    
}
-(void)resetMyTimer
{
    [self stopMyTimer];
    [self beginMyTimer];
}

- (void)stopMyTimer
{
    if (myTimer_ != nil) {
        [myTimer_ invalidate];
        myTimer_ = nil;
    }
}
- (void)beginMyTimer
{
    if (nil == myTimer_)
    {
        myTimer_ = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(hiddenToolBar) userInfo:nil repeats:NO];
    }
}

- (void)pushWebURLToCloudTV:(NSString *)pushType
{
    NSNumber * type = [NSNumber numberWithInt:videoType_];
    NSString *userId = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:@"kUserId"];
    double curTime = CMTimeGetSeconds([self.mPlayer currentTime]);
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          pushType, @"push_type",
                          userId, @"user_id",
                          workingUrl_,@"prod_url",
                          [NSString stringWithFormat:@"%@",videoSource_],@"prod_src",
                          [NSNumber numberWithFloat:curTime],@"prod_time",
                          prodId_,@"prod_id",
                          nameStr_,@"prod_name",
                          type,@"prod_type",
                          [NSNumber numberWithInt:0],@"prod_qua",
                          nil];
    
    [[BundingTVManager shareInstance] sendMsg:data];
    [MobClick event:KEY_PUSH_VIDEO];
    isTVReady = NO;
//    [self.mPlayer pause];
//    playButton_.hidden = NO;
//    pauseButton_.hidden = YES;
    
//    [[ContainerUtility sharedInstance] setAttribute:[NSString stringWithFormat:@"%f",[self currentVolume]] forKey:@"current_volume"];
//    
//    [self setPlayVolume:0.0f];
}

- (void)showActivityView
{
//    if (!playCacheView_.superview)
//    {
//        [self.view addSubview:playCacheView_];
//        
//        myHUD.hidden = NO;
//        [self.view bringSubviewToFront:myHUD];
//        [myHUD show:YES];
//        willPlayLabel_.text = nil;
//    }
    myHUD.hidden = NO;
    [self.view bringSubviewToFront:myHUD];
    [myHUD show:YES];
}
- (void)dismissActivityView
{
//    if (playCacheView_.superview)
//    {
//        [playCacheView_ removeFromSuperview];
//        myHUD.hidden = YES;
//    }
     myHUD.hidden = YES;
}

-(void)playerItemDidReachEnd:(id)sender{
    if (videoType_ == 1) {
        [self playEnd];
        return;
    }
    if (islocalFile_) {
        UIButton * nextBtn = (UIButton *)[bottomToolBar_ viewWithTag:NEXT_BUTTON_TAG];
        [nextBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
        //[self playNextLocalFile];
        return;
    }
    [self playNext];

}
-(void)playNext{
    
    if (playNum == [episodesArr_ count]-1) {
        [self playEnd];
        return;
    }
    
    [self destoryPlayer];
    
    playNum++;
    [tableList_ reloadData];

    [[CacheUtility sharedCache] putInCache:[NSString stringWithFormat:@"%@_%d",prodId_,(playNum+1)] result:[NSNumber numberWithInt:0]];
    lastPlayTime_ = kCMTimeZero;
    
    [self disableBottomToolBarButtons];
    
    [self addCacheview];

    [self initDataSource:playNum];
    
    [self beginToPlay];
    
    [self recordPlayStatics];
    
    [self clearSelectView];
    
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
    [self initPlayerView];
    [self initUI];
    
    if (!islocalFile_) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wifiNotAvailable:) name:WIFI_IS_NOT_AVAILABLE object:nil];
        //初始化数据；
        if (!isPlayFromRecord_) {
            
        dispatch_async( dispatch_queue_create("newQueue", NULL), ^{
                            [self initDataSource:playNum];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                 [self beginToPlay];
                                 [self clearSelectView];
                             });
                    });
            
        }
        else{
            [self initDataPlayFromRecord];
        }
    }
    else
    {
        if (isM3u8_)
        {
            [self setURL:[NSURL URLWithString:local_file_path_]];
        }
        else
        {
            [self setPath:local_file_path_];
        }
        selectButton_.enabled = NO;
        [self getVideoDetail];
         [self clearSelectView];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackground:)
                                                 name:APPLICATION_DID_ENTER_BACKGROUND_NOTIFICATION
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive:)
                                                 name:APPLICATION_DID_BECOME_ACTIVE_NOTIFICATION
                                               object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChanged:) name:NETWORK_CHANGED object:nil];
}

-(void)initUI{
    self.title = nameStr_;
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    isPlayOnTV = NO;
    isTVReady = NO;
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self initTopToolBar];
    [self initBottomToolBar];
    
    
    [self disableBottomToolBarButtons];
    playCacheView_ = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kFullWindowHeight, self.view.bounds.size.width + 24)];
    if([AppDelegate instance].window.bounds.size.height == 568){
        playCacheView_.image = [UIImage imageNamed:@"iphone_video_loading_IP5"];
    }
    else{
       playCacheView_.image = [UIImage imageNamed:@"iphone_video_loading"];
    }
    [self.view addSubview:playCacheView_];
    
    myHUD = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 300, 80)];
    myHUD.center = CGPointMake(self.view.center.x, self.view.center.y+110);
    myHUD.backgroundColor = [UIColor clearColor];
    myHUD.userInteractionEnabled = NO;
    myHUD.labelText = @"正在加载，请稍等";
    myHUD.labelFont = [UIFont systemFontOfSize:12];
    myHUD.opacity = 0;
    [myHUD show:YES];
    
    if (!islocalFile_)
    {
          [self.view addSubview:myHUD];
    }

    willPlayLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    willPlayLabel_.center = CGPointMake(playCacheView_.center.x, 180);
    willPlayLabel_.font = [UIFont systemFontOfSize:12];
    willPlayLabel_.backgroundColor = [UIColor clearColor];
    willPlayLabel_.textColor = [UIColor grayColor];
    willPlayLabel_.textAlignment = NSTextAlignmentCenter;
    if (!islocalFile_) {
        [playCacheView_ addSubview:willPlayLabel_];
        [self initWillPlayLabel];
    }
   
}

-(void)initWillPlayLabel{
    if (videoType_ == 1) {
        titleLabel_.text = [NSString stringWithFormat:@"%@",nameStr_];
    }
    else if (videoType_ == 2){
        titleLabel_.text = [NSString stringWithFormat:@"%@ 第%d集", nameStr_, (playNum+1)];
    }
    else if (videoType_ == 3){
        NSDictionary *item = [episodesArr_ objectAtIndex:playNum];
        titleLabel_.text = [NSString stringWithFormat:@"%@",[item objectForKey:@"name"]];
    }
    
    [self initplaytime];
    
    NSString *str = [TimeUtility formatTimeInSecond:CMTimeGetSeconds(lastPlayTime_)];
    if (![str isEqualToString:@"00:00"] && ![str isEqualToString:@"00:00:00"]){
    willPlayLabel_.text = [NSString stringWithFormat:@"上次播放至: %@",str];
    }
    else{
        willPlayLabel_.text = nil;
    }

}

-(void)initDataSource:(int)num{
    if (num >= [episodesArr_ count]) {
        return;
    }
   NSDictionary *episodesInfo = [episodesArr_ objectAtIndex:num];
    NSArray *down_load_urls = [episodesInfo objectForKey:@"down_urls"];
    NSMutableArray *tempSortArr = [NSMutableArray arrayWithCapacity:5];
    for (NSDictionary *dic in down_load_urls) {
        fromBaidu = NO;
        NSMutableDictionary *temp_dic = [NSMutableDictionary dictionaryWithDictionary:dic];
        NSString *source_str = [temp_dic objectForKey:@"source"];
        
        if ([source_str isEqualToString:@"wangpan"]) {
            [temp_dic setObject:@"0.1" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"le_tv_fee"]) {
            [temp_dic setObject:@"0.2" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"letv"]) {
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
        else if ([source_str isEqualToString:@"baidu_wangpan"]){
            fromBaidu = YES;
            [temp_dic setObject:@"12" forKey:@"level"];
            NSArray * dURL = [temp_dic objectForKey:@"urls"];
            if (0 == dURL.count)
                return;
            NSMutableArray *newUrls = [NSMutableArray arrayWithCapacity:5];
            for (NSDictionary *oneDic in dURL) {
                    NSString * downloadURL = [CommonMotheds getDownloadURLWithHTML:[oneDic objectForKey:@"url"]];
                    NSMutableDictionary * newDic = [NSMutableDictionary dictionary];
                    if (nil != downloadURL){
                        [newDic setObject:downloadURL forKey:@"url"];
                        [newDic setObject:[oneDic objectForKey:@"file"] forKey:@"file"];
                        [newDic setObject:[oneDic objectForKey:@"type"] forKey:@"type"];
                        [newUrls addObject:newDic];
                    }
            }
             [temp_dic setObject:newUrls forKey:@"urls"];
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
            if (url_str){
                [urlandSource setObject:url_str forKey:@"url"];
            }
           
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
        if ([obj1 floatValue] > [obj2 floatValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        } 
        
        if ([obj1 floatValue] < [obj2 floatValue]) {
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
                [self showNOThisClearityUrl:YES];
            }
            break;
        }
        case HIGH_CLEAR:{
            if ([highClearArr count] > 0) {
                url = [[highClearArr objectAtIndex:0] objectForKey:@"url"];
                [self sendHttpRequest:url];
            }
            else{
                 [self showNOThisClearityUrl:YES];
            }
           
            break;
        }
        case SUPER_CLEAR:{
            
            if ([superClearArr count] > 0) {
                url = [[superClearArr objectAtIndex:0] objectForKey:@"url"];
                [self sendHttpRequest:url];
            }
            else{
                [self showNOThisClearityUrl:YES];
               
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
            
            if(url != nil){
                [self sendHttpRequest:url];
            }
            else{
                NSLog(@"Error:Get Play Url Fail!");
                [self destoryPlayer];
                [[UIApplication sharedApplication] setStatusBarHidden:NO];
                [self.navigationController popViewControllerAnimated:NO];
                NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:fromBaidu], @"fromBaidu", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"addWebView"
                                                                    object:self
                                                                  userInfo:userInfo];
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
                [self showNOThisClearityUrl:YES];
            }
            
            break;
        }
        case HIGH_CLEAR:{
            if ([highClearArr count] > play_url_index ) {
                NSString *url = [[highClearArr objectAtIndex:play_url_index] objectForKey:@"url"];
                [self sendHttpRequest:url];
            }
            else{
                [self showNOThisClearityUrl:YES];
            }
              
            break;
        }
        case SUPER_CLEAR:{
            if ([superClearArr count] > play_url_index ) {
                NSString *url = [[superClearArr objectAtIndex:play_url_index] objectForKey:@"url"];
                [self sendHttpRequest:url];
            }
            else{
                [self showNOThisClearityUrl:YES];
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
                [self destoryPlayer];
                [[UIApplication sharedApplication] setStatusBarHidden:NO];
                [self.navigationController popViewControllerAnimated:YES];
                NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:fromBaidu], @"fromBaidu", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"addWebView"
                                                                    object:self
                                                                  userInfo:userInfo];
            }

            break;
        }
    }
    
   
}
-(void)showNOThisClearityUrl:(BOOL)bol{
    if (bol) {
        UILabel  *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250,40)];
        label.text = @"此分辨率已失效，请选择其它分辨率";
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:14];
        label.tag = 99999;
        label.center = CGPointMake( playCacheView_.center.x,  playCacheView_.center.y+50);
        [playCacheView_ addSubview:label];
        
        myHUD.hidden = YES;
    }
    else{
        UIView *view = [playCacheView_ viewWithTag:99999];
        if (view) {
             [view removeFromSuperview];
        }
    }
    

}

NSComparator cmptr2 = ^(NSString *obj1, NSString * obj2){
    NSString *str1 = [[obj1 componentsSeparatedByString:@"_"]objectAtIndex:1];
    NSString *str2 = [[obj2 componentsSeparatedByString:@"_"]objectAtIndex:1];
    
    if ([str1 integerValue] > [str2 integerValue]) {
        return (NSComparisonResult)NSOrderedDescending;
    }
    
    if ([str1 integerValue] < [str2 integerValue]) {
        return (NSComparisonResult)NSOrderedAscending;
    }
    return (NSComparisonResult)NSOrderedSame;
};
/*
-(void)playNextLocalFile{
    NSString *queryString = [NSString stringWithFormat:@"where itemId = '%@' AND downloadStatus = 'finish'",prodId_];
    NSArray *items = [DatabaseManager findByCriteria:[SubdownloadItem class] queryString:queryString];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES comparator:cmptr2];
    NSMutableArray *sortedItems = [NSMutableArray arrayWithArray: [items sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]]];
    for (SubdownloadItem *sub in sortedItems) {
        NSString *sub_name = [[sub.subitemId componentsSeparatedByString:@"_"] objectAtIndex:1];
        int num = [sub_name intValue];
        if (num > playNum) {
            
            NSString *fileName = [sub.subitemId stringByAppendingString:@".mp4"];
            NSError *error;
            // 创建文件管理器
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            //指向文件目录
            NSString *documentsDirectory= [NSHomeDirectory()
                                           stringByAppendingPathComponent:@"Documents"];
            NSArray *fileList = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error];
            
            NSString *playPath = nil;
            if (![sub.downloadType isEqualToString:@"m3u8"]) {
                for (NSString *str in fileList) {
                    if ([str isEqualToString:fileName]) {
                        playPath = [documentsDirectory stringByAppendingPathComponent:str];
                        break;
                    }
                }
            }
            else{
                [[AppDelegate instance] startHttpServer];
                playPath =[NSString stringWithFormat:@"%@/%@/%@/%d.m3u8",LOCAL_HTTP_SERVER_URL,sub.itemId,sub.subitemId ,num];
                isM3u8_ = YES;
                self.playDuration = sub.duration;
            }
            if (playPath) {
                local_file_path_ = playPath;
                islocalFile_ = YES;
                if (sub.type == 2) {
                    NSString *name = [[sub.name componentsSeparatedByString:@"_"] objectAtIndex:0];
                    nameStr_ = [NSString stringWithFormat:@"%@ 第%d集",name,num];
                    playNum = num;
                }
                else if (sub.type == 3){
                    nameStr_ =  [[sub.name componentsSeparatedByString:@"_"] lastObject];
                }
                prodId_ = sub.itemId;
                videoType_ = sub.type;
                [[CacheUtility sharedCache] putInCache:[NSString stringWithFormat:@"%@_%d",prodId_,playNum] result:[NSNumber numberWithInt:0]];
                lastPlayTime_ = kCMTimeZero;
                [self addCacheview];
                if (!isM3u8_) {
                    [self setPath:playPath];
                }
                else{
                    [self setURL:[NSURL URLWithString:playPath]];
                
                }
            
            }
            
            return;
        }
    }
     [self playEnd];
}
*/

-(void)sendHttpRequest:(NSString *)str{
    //Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        NSString *formattedUrl = str;
        if([str rangeOfString:@"{now_date}"].location != NSNotFound){
            int nowDate = [[NSDate date] timeIntervalSince1970];
            formattedUrl = [str stringByReplacingOccurrencesOfString:@"{now_date}" withString:[NSString stringWithFormat:@"%i", nowDate]];
        }
        NSLog(@"The request url is %@",formattedUrl);
        NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:formattedUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];
        urlConnection = [NSURLConnection connectionWithRequest:request delegate:self];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"亲，网络出问题了，请检查后重试！" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
        [alert show];
    
    }
    

}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"iphoneAvplayerViewController didFailWithError:%@",error);
    
    //Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
       [self retryUrltoPlay];
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    //NSLog(@"begin at :%@",[[NSDate date] description]);
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
    int status_Code = HTTPResponse.statusCode;
    if (status_Code >= 200 && status_Code <= 299)
    {
        NSDictionary *headerFields = [HTTPResponse allHeaderFields];
        //NSLog(@"step1 :%@",[[NSDate date] description]);
        NSString *content_type = [NSString stringWithFormat:@"%@", [headerFields objectForKey:@"Content-Type"]];
        NSString *contentLength = [headerFields objectForKey:@"Content-Length"];
        if (![content_type hasPrefix:@"text/html"] && contentLength.intValue > 0)
        {
            //NSLog(@"step2 :%@",[[NSDate date] description]);
            [self setURL:connection.originalRequest.URL];
            //NSLog(@"step3 :%@",[[NSDate date] description]);
            [connection cancel];
            if (isPlayOnTV)
            {
                [self pushWebURLToCloudTV:@"411"];
            }
            //NSLog(@"end 1 at:%@",[[NSDate date] description]);
            return;
        }
    
    }
    NSLog(@"end 2 at:%@",[[NSDate date] description]);
    [self retryUrltoPlay];
}
-(void)initTopToolBar{
    topToolBar_ = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 20, kFullWindowHeight, 38)];
    [topToolBar_ setBackgroundImage:[UIUtility createImageWithColor:[UIColor colorWithRed:30/255.0 green:30/255.0 blue:30/255.0 alpha:0.5] ] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    topToolBar_.hidden = YES;
    [self.view addSubview:topToolBar_];
    
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(7, 0, 45, 38);
    [closeButton setBackgroundImage:[UIImage imageNamed:@"iphone_back_bt"] forState:UIControlStateNormal];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"iphone_back_bt_pressed"] forState:UIControlStateHighlighted];
    closeButton.backgroundColor = [UIColor clearColor];
    closeButton.tag = CLOSE_BUTTON_TAG;
    [closeButton addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
    [topToolBar_ addSubview:closeButton];
    [topToolBar_ setBackgroundImage:[UIImage imageNamed:@"iphone_top_bg"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    selectButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
    selectButton_.frame = CGRectMake(kFullWindowHeight-87, 5, 57, 27);
    [selectButton_ setBackgroundImage:[UIImage imageNamed:@"iphone_select_bt"] forState:UIControlStateNormal];
    [selectButton_ setBackgroundImage:[UIImage imageNamed:@"iphone_select_bt_pressed"] forState:UIControlStateHighlighted];
    [selectButton_ setBackgroundImage:[UIImage imageNamed:@"iphone_select_bt_pressed"] forState:UIControlStateSelected];
    selectButton_.backgroundColor = [UIColor clearColor];
    selectButton_.tag = SELECT_BUTTON_TAG;
    [selectButton_ addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
    if ((videoType_  == 2 ||videoType_  == 3)) {
        [topToolBar_ addSubview:selectButton_];
    }
    
    
    titleLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(topToolBar_.frame.size.width/2.0 - 120.0f, 0, 240, 38)];
    //titleLabel_.center = topToolBar_.center;
    titleLabel_.backgroundColor = [UIColor clearColor];
    titleLabel_.font = [UIFont systemFontOfSize:14];
    titleLabel_.textAlignment = NSTextAlignmentCenter;
    titleLabel_.textColor = [UIColor whiteColor];
    titleLabel_.text = nameStr_;
    [topToolBar_ addSubview:titleLabel_];
    
    tableList_ = [[UITableView alloc] initWithFrame:CGRectMake(kFullWindowHeight-110, 55, 100, 0) style:UITableViewStylePlain];
    tableList_.backgroundColor = [UIColor clearColor];
    tableList_.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableList_.delegate = self;
    tableList_.dataSource = self;
    [self.view addSubview:tableList_];
    
    //if (!islocalFile_)
    {
        UILabel *sourceText = [[UILabel alloc] initWithFrame:CGRectMake(70, 8, 30, 18)];
        //sourceText.text = @"来源:";
        sourceText.tag = 100001;
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
    avplayerView_ = [[AVPlayerView alloc] initWithFrame:CGRectMake(0, 0, kFullWindowHeight, 320)];
    avplayerView_.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showToolBar)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [avplayerView_ addGestureRecognizer:tapGesture];
    [self.view addSubview:avplayerView_];
    
    ariplayView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"airplay_bg.png"]];
    ariplayView.frame = CGRectMake(0, 0, kFullWindowHeight, 320);
    ariplayView.backgroundColor = [UIColor clearColor];
    
    cloudTVView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"airplay_bg.png"]];
    cloudTVView.frame = CGRectMake(0, 0, kFullWindowHeight, 320);
    cloudTVView.backgroundColor = [UIColor clearColor];
    
    airPlayLabel_ = [[UILabel alloc]initWithFrame:CGRectMake(0, 200, kFullWindowHeight, 30)];
    airPlayLabel_.backgroundColor = [UIColor clearColor];
    airPlayLabel_.textColor = [UIColor lightGrayColor];
    airPlayLabel_.text = @"此视频正在通过 AirPlay 播放。";
    airPlayLabel_.font = [UIFont systemFontOfSize:15];
    airPlayLabel_.textAlignment = NSTextAlignmentCenter;
    [ariplayView addSubview:airPlayLabel_];
}

-(void)initBottomToolBar{
    
    bottomToolBar_ = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 256 + 20, kFullWindowHeight, 44)];
    bottomToolBar_.backgroundColor = [UIColor clearColor];
    //bottomToolBar_.alpha = 0.8;
    bottomToolBar_.hidden = YES;
    [bottomToolBar_ setBackgroundImage:[UIImage imageNamed:@"iphone_play_bg"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    [self.view addSubview:bottomToolBar_];
    
    bottomView_ = [[UIImageView alloc] initWithFrame:CGRectMake(0,231 + 20, kFullWindowHeight, 25)];
    bottomView_.alpha = 0.8;
    bottomView_.image = [UIImage imageNamed:@"iphone_time_bg"];
    bottomView_.backgroundColor = [UIColor clearColor];
    bottomView_.userInteractionEnabled = YES;
    
    mScrubber = [[UISlider alloc]initWithFrame:CGRectMake(0, 0, 354 , 8)];
    //mScrubber.transform = CGAffineTransformMakeScale(1.0,1.2);
    mScrubber.backgroundColor = [UIColor clearColor];
    mScrubber.center = CGPointMake(kFullWindowHeight/2, 13);
    [mScrubber setThumbImage: [UIImage imageNamed:@"iphone_progress_thumb"] forState:UIControlStateNormal];
    [mScrubber setMinimumTrackImage:[[UIImage imageNamed:@"iphone_time_jindu_x"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)] forState:UIControlStateNormal];
    [mScrubber setMaximumTrackImage:[[UIImage imageNamed:@"iphone_time_jindu"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)] forState:UIControlStateNormal];
    [mScrubber addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchCancel];
    [mScrubber addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchUpInside];
    [mScrubber addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchUpOutside];
    [mScrubber addTarget:self action:@selector(beginScrubbing:) forControlEvents:UIControlEventTouchDown];
    [mScrubber addTarget:self action:@selector(scrub:) forControlEvents:UIControlEventTouchDragInside];
    [mScrubber addTarget:self action:@selector(scrub:) forControlEvents:UIControlEventValueChanged];
    [bottomView_ addSubview:mScrubber];
    
    
    seeTimeLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(mScrubber.frame.origin.x - 55, 8, 50, 10)];
    seeTimeLabel_.backgroundColor = [UIColor clearColor];
    seeTimeLabel_.font = [UIFont systemFontOfSize:12];
    seeTimeLabel_.textAlignment = NSTextAlignmentLeft;
    seeTimeLabel_.textColor = [UIColor whiteColor];
    seeTimeLabel_.text = @"00:00";
    [bottomView_ addSubview:seeTimeLabel_];
    
    totalTimeLable_ = [[UILabel alloc] initWithFrame:CGRectMake((kFullWindowHeight+354)/2+8, 8, 90, 10)];
    totalTimeLable_.backgroundColor = [UIColor clearColor];
    totalTimeLable_.font = [UIFont systemFontOfSize:12];
    totalTimeLable_.textAlignment = NSTextAlignmentLeft;
    totalTimeLable_.textColor = [UIColor whiteColor];
    [bottomView_ addSubview:totalTimeLable_];
    
    bottomView_.hidden = YES;
    [self.view addSubview:bottomView_];
    
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
    preButton.frame = CGRectMake(kFullWindowHeight/2-72, 6, 32, 31);
    preButton.backgroundColor = [UIColor clearColor];
    preButton.tag = PRE_BUTTON_TAG;
    [preButton setBackgroundImage:[UIImage imageNamed:@"iphone_prev_bt"] forState:UIControlStateNormal];
    [preButton setBackgroundImage:[UIImage imageNamed:@"iphone_prev_bt_pressed"] forState:UIControlStateHighlighted];
    [preButton setBackgroundImage:[UIImage imageNamed:@"iphone_prev_bt_disabled"] forState:UIControlStateDisabled];
    [preButton addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
    [bottomToolBar_ addSubview:preButton];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.frame = CGRectMake(kFullWindowHeight/2+40, 7, 29, 27);
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
    clarityButton_.frame = CGRectMake(kFullWindowHeight-87, 8, 57, 27);
    clarityButton_.backgroundColor = [UIColor clearColor];
    [clarityButton_ setBackgroundImage:[UIImage imageNamed:@"iphone_quality_bt"] forState:UIControlStateNormal];
    [clarityButton_ setBackgroundImage:[UIImage imageNamed:@"iphone_quality_bt_pressed"] forState:UIControlStateHighlighted];
    [clarityButton_ setBackgroundImage:[UIImage imageNamed:@"iphone_quality_bt_pressed"] forState:UIControlStateSelected];
    clarityButton_.adjustsImageWhenHighlighted = NO;
    clarityButton_.tag = CLARITY_BUTTON_TAG;
    [clarityButton_ addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
    [bottomToolBar_ addSubview:clarityButton_];
    
    localLogoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    localLogoBtn.frame = CGRectMake(kFullWindowHeight-87, 8, 33, 27);
    localLogoBtn.backgroundColor = [UIColor clearColor];
    [localLogoBtn setBackgroundImage:[UIImage imageNamed:@"bendi_icon"] forState:UIControlStateNormal];
    localLogoBtn.tag = LOCAL_LOGO_BUTTON_TAG;
    [bottomToolBar_ addSubview:localLogoBtn];
    
    volumeView_ = [ [MPVolumeView alloc] initWithFrame:CGRectMake(60, 7, 30, 30)];
    volumeView_.backgroundColor = [UIColor clearColor];
    [volumeView_ setShowsVolumeSlider:NO];
    [volumeView_ setShowsRouteButton:YES];
    for (UIView *asubview in volumeView_.subviews) {
        if ([NSStringFromClass(asubview.class) isEqualToString:@"MPButton"]) {
            airPlayButton_ = (UIButton *)asubview;
            airPlayButton_.backgroundColor = [UIColor clearColor];
            airPlayButton_.frame = CGRectMake(0, 0, 33, 27);
            [airPlayButton_ setImage:nil forState:UIControlStateNormal];
            [airPlayButton_ setImage:nil forState:UIControlStateHighlighted];
            [airPlayButton_ setImage:nil forState:UIControlStateSelected];
            [airPlayButton_ setBackgroundImage:[UIImage imageNamed:@"iphone_route_bt"] forState:UIControlStateNormal];
            [airPlayButton_ setBackgroundImage:[UIImage imageNamed:@"iphone_route_bt_light"] forState:UIControlStateHighlighted];
            break;
        }
    }
    
    if (!(isM3u8_ && islocalFile_)) {
        [bottomToolBar_ addSubview:volumeView_];
        [self disableAirPlayButton];
    }
    
    NSString *userId = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:@"kUserId"];
    NSDictionary * data = (NSDictionary *)[[ContainerUtility sharedInstance] attributeForKey:[NSString stringWithFormat:@"%@_isBunding",userId]];
    NSNumber * isbunding = [data objectForKey:KEY_IS_BUNDING];
    if ([isbunding boolValue])
    {
        
        if (![BundingTVManager shareInstance].isConnected)
        {
            NSString * sendChannel = [NSString stringWithFormat:@"/screencast/CHANNEL_TV_%@",[data objectForKey:KEY_MACADDRESS]];
            [[BundingTVManager shareInstance] connecteServerWithChannel:sendChannel];
        }
        
        [BundingTVManager shareInstance].sendClient.delegate = self;
        
        cloundTVButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cloundTVButton.frame = CGRectMake(118, 8, 32.5, 27);
        cloundTVButton.backgroundColor = [UIColor clearColor];
        cloundTVButton.tag = CLOUND_TV_BUTTON_TAG;
        [cloundTVButton setBackgroundImage:[UIImage imageNamed:@"cloud_tv.png"] forState:UIControlStateNormal];
        [cloundTVButton setBackgroundImage:[UIImage imageNamed:@"cloud_tv_f.png"] forState:UIControlStateHighlighted];
        [cloundTVButton setBackgroundImage:[UIImage imageNamed:@"cloud_tv_f.png"] forState:UIControlStateSelected];
        [cloundTVButton addTarget:self
                           action:@selector(action:)
                 forControlEvents:UIControlEventTouchUpInside];
        [bottomToolBar_ addSubview:cloundTVButton];
    }
}


-(void)clearSelectView{
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 202, 109)];
        view.tag = 99;
        UIButton *plainClearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        plainClearBtn.frame = CGRectMake(0, 0, 42, 42);
       // plainClearBtn.center = CGPointMake(34, 65);
        plainClearBtn.tag = 100;
        [plainClearBtn addTarget:self action:@selector(clearButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        [plainClearBtn setBackgroundImage:[UIImage imageNamed:@"iphone_biaoqing_bt"] forState:UIControlStateNormal];
        [plainClearBtn setBackgroundImage:[UIImage imageNamed:@"iphone_biaoqing_bt_pressed"] forState:UIControlStateHighlighted];
        [plainClearBtn setBackgroundImage:[UIImage imageNamed:@"iphone_biaoqing_bt_pressed"]forState:UIControlStateDisabled];
        plainClearBtn.adjustsImageWhenDisabled = NO;
    
         
        UIButton *highClearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        highClearBtn.backgroundColor = [UIColor clearColor];
        [highClearBtn addTarget:self action:@selector(clearButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        [highClearBtn setBackgroundImage:[UIImage imageNamed:@"iphone_gaoqing_high_bt"] forState:UIControlStateNormal];
        [highClearBtn setBackgroundImage:[UIImage imageNamed:@"iphone_gaoqing_bt_pressed"] forState:UIControlStateHighlighted];
        [highClearBtn setBackgroundImage:[UIImage imageNamed:@"iphone_gaoqing_bt_pressed"]forState:UIControlStateDisabled];
        highClearBtn.frame = CGRectMake(0, 0, 42, 42);
        highClearBtn.tag = 101;
        highClearBtn.adjustsImageWhenDisabled = NO;
         
        UIButton *superClearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        superClearBtn.backgroundColor = [UIColor clearColor];
        [superClearBtn addTarget:self action:@selector(clearButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        [superClearBtn setBackgroundImage:[UIImage imageNamed:@"iphone_chaoqing_super_bt"] forState:UIControlStateNormal];
        [superClearBtn setBackgroundImage:[UIImage imageNamed:@"iphone_chaoqing_bt_pressed"] forState:UIControlStateHighlighted];
        [superClearBtn setBackgroundImage:[UIImage imageNamed:@"iphone_chaoqing_bt_pressed"]forState:UIControlStateDisabled];
        superClearBtn.frame = CGRectMake(0, 0, 42, 42);
        superClearBtn.tag = 102;
        superClearBtn.adjustsImageWhenDisabled = NO;
    
    int num = 0;
    if ([plainClearArr count]>0) {
        num++;
    }
    if ([highClearArr count]>0) {
        num++;
    }
    if ([superClearArr count]>0) {
        num++;
    }
    if (num == 2) {
        if ([plainClearArr count] > 0) {
            plainClearBtn.frame = CGRectMake(0, 0, 42, 42);
            plainClearBtn.enabled = NO;
            [view addSubview:plainClearBtn];
            
            if ([highClearArr count]>0) {
              highClearBtn.frame = CGRectMake(43, 0, 42, 42);
              [view addSubview:highClearBtn];
            }
            else{
              superClearBtn.frame = CGRectMake(43,0, 42, 42);
              [view addSubview:superClearBtn];
            }
        }
       else if ([highClearArr count]>0) {
           [view addSubview:highClearBtn];
           
           if ([plainClearArr count]>0) {
               highClearBtn.frame = CGRectMake(43, 0, 42, 42);

               plainClearBtn.frame = CGRectMake(0, 0, 42, 42);
               plainClearBtn.enabled = NO;
               [view addSubview:plainClearBtn];
           }
           else{
                highClearBtn.frame = CGRectMake(0, 0, 42, 42);
               highClearBtn.enabled = NO;
               superClearBtn.frame = CGRectMake(43,0, 42, 42);
               [view addSubview:superClearBtn];
           }
        }
       else if ([superClearArr count]>0){
        superClearBtn.frame = CGRectMake(43,0, 42, 42);
        [view addSubview:superClearBtn];   
           if ([plainClearArr count]>0) {
               if ([plainClearArr count]>0) {
                   plainClearBtn.frame = CGRectMake(0, 0, 42, 42);
                   plainClearBtn.enabled = NO;
                   [view addSubview:plainClearBtn];
               }
               else{
                   highClearBtn.frame = CGRectMake(0, 0, 42, 42);
                   highClearBtn.enabled = NO;
                   [view addSubview:highClearBtn];
               }
           }
       
       }
        UIView *separatorView = [[UIView alloc]initWithFrame:CGRectMake(42, 0, 1, 42)];
        separatorView.backgroundColor = [UIColor colorWithRed:80/255.0 green:80/255.0 blue:80/255.0 alpha:0.5];
        [view addSubview:separatorView];
    }
    if (num == 3) {
        plainClearBtn.frame = CGRectMake(0, 0, 42, 42);
        plainClearBtn.enabled = NO;
         [view addSubview:plainClearBtn];
        highClearBtn.frame = CGRectMake(43, 0, 42, 42);
        [view addSubview:highClearBtn];
        superClearBtn.frame = CGRectMake(86, 0, 42, 42);
        [view addSubview:superClearBtn];
        
        UIView *separatorView = [[UIView alloc]initWithFrame:CGRectMake(42, 0, 1, 42)];
        separatorView.backgroundColor = [UIColor colorWithRed:80/255.0 green:80/255.0 blue:80/255.0 alpha:0.5];
        [view addSubview:separatorView];
        
        UIView *separatorView1 = [[UIView alloc]initWithFrame:CGRectMake(85, 0, 1, 42)];
        separatorView1.backgroundColor = [UIColor colorWithRed:80/255.0 green:80/255.0 blue:80/255.0 alpha:0.5];
        [view addSubview:separatorView1];
    }
    if (num > 1) {
        view.frame = CGRectMake(0, 0, num*42, 50);
        clearBgView_  = [[CMPopTipView alloc] initWithCustomView:view];
        clearBgView_.backgroundColor = [UIColor colorWithRed:10/255.0 green:10/255.0 blue:10/255.0 alpha:1];
        clearBgView_.disableTapToDismiss = YES;
        clearBgView_.animation = CMPopTipAnimationPop;
        [clearBgView_ presentPointingAtView:clarityButton_ inView:self.view animated:YES];
        
        if ([[UIScreen mainScreen] bounds].size.height == 568) {
            clearBgView_.frame = CGRectMake(bottomToolBar_.frame.size.width - clearBgView_.frame.size.width-20, clearBgView_.frame.origin.y, clearBgView_.frame.size.width, clearBgView_.frame.size.height);
        }
        else{
            clearBgView_.frame = CGRectMake(bottomToolBar_.frame.size.width - clearBgView_.frame.size.width, clearBgView_.frame.origin.y, clearBgView_.frame.size.width, clearBgView_.frame.size.height);
        }
        
        clearBgView_.hidden = YES;
        localLogoBtn.hidden = YES;
    }
    else
    {
        clarityButton_.hidden = YES;
        if (islocalFile_)
        {
            localLogoBtn.hidden = NO;
        }
        else
        {
            localLogoBtn.hidden = YES;
        }
    }
}
-(void)showTrackSelectButton{
    UIButton *trackSelect = [UIButton buttonWithType:UIButtonTypeCustom];
    trackSelect.frame = CGRectMake(kFullWindowHeight-160, 7, 33, 27);
    trackSelect.backgroundColor = [UIColor clearColor];
    [trackSelect setBackgroundImage:[UIImage imageNamed:@"iphone_shengdao"] forState:UIControlStateNormal];
    [trackSelect setBackgroundImage:[UIImage imageNamed:@"iphone_shengdao_s"] forState:UIControlStateHighlighted];
    [trackSelect setBackgroundImage:[UIImage imageNamed:@"iphone_shengdao_s"] forState:UIControlStateSelected];
    trackSelect.adjustsImageWhenHighlighted = NO;
    trackSelect.tag = TRACK_BUTTON_TAG;
    trackSelect.enabled = NO;
    [trackSelect addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
    [bottomToolBar_ addSubview:trackSelect];
}
-(void)showChangeTrackView{
    if (changeTrackView_ == nil) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 138, 109)];
        imageView.image = [UIImage imageNamed:@"iphone_shengdao_bg"];
        imageView.userInteractionEnabled = YES;
        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftBtn setBackgroundImage:[UIImage imageNamed:@"shengdao1"] forState:UIControlStateNormal];
        [leftBtn setBackgroundImage:[UIImage imageNamed:@"shengdao1_s"] forState:UIControlStateDisabled];
        [leftBtn setBackgroundImage:[UIImage imageNamed:@"shengdao1_s"] forState:UIControlStateHighlighted];
        leftBtn.enabled = NO;
        leftBtn.tag = 300001;
        [leftBtn addTarget:self action:@selector(trackButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        leftBtn.frame = CGRectMake(5, 55, 60, 32);
        [imageView addSubview:leftBtn];
        
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightBtn setBackgroundImage:[UIImage imageNamed:@"shengdao2"] forState:UIControlStateNormal];
        [rightBtn setBackgroundImage:[UIImage imageNamed:@"shengdao2_s"] forState:UIControlStateDisabled];
        [rightBtn setBackgroundImage:[UIImage imageNamed:@"shengdao2_s"] forState:UIControlStateHighlighted];
        rightBtn.tag = 300002;
        [rightBtn addTarget:self action:@selector(trackButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        rightBtn.frame = CGRectMake(74, 55, 60, 32);
        [imageView addSubview:rightBtn];
        
        changeTrackView_  = [[CMPopTipView alloc] initWithCustomView:imageView];
        changeTrackView_.backgroundColor = [UIColor clearColor];
        changeTrackView_.disableTapToDismiss = YES;
        changeTrackView_.animation = CMPopTipAnimationPop;
        UIButton *button = (UIButton *)[bottomToolBar_ viewWithTag:TRACK_BUTTON_TAG];
        [changeTrackView_ presentPointingAtView:button inView:self.view animated:YES];
    }
    [self.view bringSubviewToFront:changeTrackView_];
    changeTrackView_.hidden = NO;

}

-(void)hiddenChangeTrackView{
  changeTrackView_.hidden = YES;
  UIButton *button = (UIButton *)[bottomToolBar_ viewWithTag:TRACK_BUTTON_TAG];
  button.selected = NO;
}

-(void)trackButtonSelected:(UIButton *)btn{
    for (UIView *view in changeTrackView_.customView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *subBtn = (UIButton *)view;
            subBtn.enabled = YES;
        }
    }
    btn.enabled = NO;
    if (btn.tag == 300001)
    {
        [self changeTracks:0];
        
    }
    else if(btn.tag == 300002)
    {
        [self changeTracks:1];
    
    }
    
}
-(void)enableTracksSelectButton{
    UIButton *button = (UIButton *)[bottomToolBar_ viewWithTag:TRACK_BUTTON_TAG];
    button.enabled = YES;
}

-(void)disableAirPlayButton{
    [ariplayView removeFromSuperview];
    if (airPlayButton_) {
        airPlayButton_.enabled = NO;
        [airPlayButton_ setBackgroundImage:[UIImage imageNamed:@"iphone_route_bt"] forState:UIControlStateNormal];
    }
}
-(void)enaleAirPlayButton{
    [avplayerView_ addSubview:ariplayView];
    if (airPlayButton_) {
        [airPlayButton_ setBackgroundImage:[UIImage imageNamed:@"iphone_route_bt_light"] forState:UIControlStateNormal];
        [airPlayButton_ setEnabled:YES];
    }
}


-(void)syncCurrentClear{
    NSString *clearType = nil;
    for ( NSDictionary *dic in plainClearArr) {
        if ([[dic objectForKey:@"url"] isEqualToString:workingUrl_]) {
            clearType = @"plain";
            break;
        }
    }
    if (clearType == nil) {
        for ( NSDictionary *dic in highClearArr) {
            if ([[dic objectForKey:@"url"] isEqualToString:workingUrl_]) {
                clearType = @"high";
                break;
            }
        }
    }
    if (clearType == nil) {
        for ( NSDictionary *dic in superClearArr) {
            if ([[dic objectForKey:@"url"] isEqualToString:workingUrl_]) {
                clearType = @"super";
                break;
            }
        }
    }
    UIView *view = [clearBgView_ viewWithTag:99];
     UIButton *plainbtn = (UIButton *)[view viewWithTag:100];
     UIButton *highbtn = (UIButton *)[view viewWithTag:101];
     UIButton *superbtn = (UIButton *)[view viewWithTag:102];

    if([clearType isEqualToString:@"plain"]){
        plainbtn.enabled = NO;
        highbtn.enabled = YES;
        superbtn.enabled = YES;
    }
    else if([clearType isEqualToString:@"high"]){
        plainbtn.enabled = YES;
        highbtn.enabled = NO;
        superbtn.enabled = YES;
    }
    else if([clearType isEqualToString:@"super"]){
        plainbtn.enabled = YES;
        highbtn.enabled = YES;
        superbtn.enabled = NO;
    }


}

-(void)clearButtonSelected:(UIButton *)btn{

    for (UIView *view in clearBgView_.customView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *subBtn = (UIButton *)view;
            subBtn.enabled = YES;
        }
    }
    
    [self showNOThisClearityUrl:NO];
    
    
    CMTime previousLastPlayTime = [mPlayer currentTime];
    if (CMTIME_IS_VALID(previousLastPlayTime) && CMTimeCompare(previousLastPlayTime, kCMTimeZero) != 0) {
        lastPlayTime_ = previousLastPlayTime;
    }
    [self addCacheview];
    
    clearBgView_.hidden = YES;
    lastPlayTime_ = [mPlayer currentTime];
    [mPlayer pause];
    mPlayer = nil;
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
//    if (isPlayOnTV)
//    {
//        [self pushWebURLToCloudTV:@"411"];
//    }
}
-(void)action:(UIButton *)btn{
    switch (btn.tag) {
        case CLOSE_BUTTON_TAG:{
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            if (isPlayOnTV)
            {
                [self controlCloundTV:CLOUND_TV_CLOSE];
            }
            [BundingTVManager shareInstance].sendClient.delegate = (id)[BundingTVManager shareInstance];
            [self updateWatchRecord];
            [self playEnd];
            
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
            
            if (isPlayOnTV && isTVReady)
            {
                [self controlCloundTV:CLOUND_TV_PLAY];
            }
            [self dismissActivityView];
            [mPlayer play];
            btn.hidden = YES;
            pauseButton_.hidden = NO;
            
            break;
        }
        case PAUSE_BUTTON_TAG:
        {
            
            if (isPlayOnTV && isTVReady)
            {
                [self controlCloundTV:CLOUND_TV_PAUSE];
            }
            [mPlayer pause];
            btn.hidden = YES;
            playButton_.hidden = NO;
            
            break;
        }
        case PRE_BUTTON_TAG:
        {
            double time = CMTimeGetSeconds([mPlayer currentTime]);
            if (isnan(time)) {
                time = 0;
            }
            
            if (time>= 30) {
                [mPlayer seekToTime:CMTimeMakeWithSeconds(time-30, NSEC_PER_SEC)];
            }
            else{
                [mPlayer seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC)];
                
            }
            if (isPlayOnTV)
            {
                [self controlCloundTV:CLOUND_TV_SEEK_TO_TIME];
            }
            break;
        }
        case NEXT_BUTTON_TAG:{
            if (videoType_ == 1) {
                return;
            }
            islocalFile_ = NO;
            self.localPlaylist = [CommonMotheds localPlaylists:self.prodId type:videoType_];
            if ((playNum + 1) >= episodesArr_.count)
            {
                [self playEnd];
                return;
            }
            //NSDictionary * nextInfo = [episodesArr_ objectAtIndex:(playNum + 1)];
            NSDictionary * curInfo = nil;
            for (NSDictionary * dic in localPlaylist)
            {
                NSString * Id = [NSString stringWithFormat:@"%@_%d",self.prodId,(playNum + 2)];
                if ([[dic objectForKey:@"subItemId"] isEqualToString:Id])
                {
                    curInfo = dic;
                    islocalFile_ = YES;
                    break;
                }
            }
            
            if (!islocalFile_)
            {
                [self showNOThisClearityUrl:NO];
                clarityButton_.hidden = NO;
                localLogoBtn.hidden = YES;
                [self playNext];
            }
            else
            {
                playNum ++;
                [self playLocal:curInfo];
                clarityButton_.hidden = YES;
                localLogoBtn.hidden = NO;
                //[self playNextLocalFile];
            }
            
            [tableList_ reloadData];
            
            break;
        }
        case CLARITY_BUTTON_TAG:{
            [self resetMyTimer];
            if (btn.selected) {
                btn.selected = NO;
                clearBgView_.hidden = YES;
            }
            else{
            
                btn.selected = YES;
                 clearBgView_.hidden = NO;
                [self.view bringSubviewToFront:clearBgView_];
            }
            [self hiddenChangeTrackView];
            break;
        }
        case SELECT_BUTTON_TAG:{
            [self resetMyTimer];
            [self.view bringSubviewToFront:tableList_];
            
            self.downloadIndex = [self downloadIndexArray];
            
            if (btn.selected) {
                btn.selected = NO;
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.3];
                tableList_.frame = CGRectMake(kFullWindowHeight-110, 55, 100, 0);
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
                tableList_.frame = CGRectMake(kFullWindowHeight-110, 55, 100, height);
                [tableList_ reloadData];
                if(playNum >= 0 && playNum < episodesArr_.count){
                    [tableList_  scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:playNum inSection:0]
                                       atScrollPosition:UITableViewScrollPositionMiddle
                                               animated:NO];
                }
                [UIView commitAnimations];
              
            }
            break;
        }
        case CLOUND_TV_BUTTON_TAG:
        {
            btn.selected = !btn.selected;
            isPlayOnTV = btn.selected;
            if (isPlayOnTV)
            {
//                airPlayLabel_.text = @"此视频正在通过 JoyPlus 播放";
//                [cloudTVView addSubview:airPlayLabel_];
//                [avplayerView_ addSubview:cloudTVView];
                [self pushWebURLToCloudTV:@"41"];
            }
            else
            {
                [self controlCloundTV:CLOUND_TV_CLOSE];
//                [cloudTVView removeFromSuperview];
//                [airPlayLabel_ removeFromSuperview];
//                airPlayLabel_.text = @"此视频正在通过 AirPlay 播放";
//                
//                NSString * volume = (NSString *)[[ContainerUtility sharedInstance] attributeForKey:@"current_volume"];
//                [self setPlayVolume:[volume floatValue]];
            }
            break;
        }
        case TRACK_BUTTON_TAG:{
            [self resetMyTimer];
            btn.selected = !btn.selected;
            if (btn.selected) {
                [self showChangeTrackView];
            }
            else{
                [self hiddenChangeTrackView];
            }
            clearBgView_.hidden = YES;
            clarityButton_.selected = NO;
            break;
        }
        default:
            break;
    }

}
- (void)clearPlayerData
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self playEnd];
}

- (void)destoryPlayer
{
    [urlConnection cancel];
    urlConnection = nil;
    if (islocalFile_)
    {
        [[AppDelegate instance] stopHttpServer];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WIFI_IS_NOT_AVAILABLE object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APPLICATION_DID_BECOME_ACTIVE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APPLICATION_DID_ENTER_BACKGROUND_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WIFI_IS_NOT_AVAILABLE object:nil];
    [self.player removeObserver:self forKeyPath:k_CurrentItemKey];
    [self.player removeObserver:self forKeyPath:@"rate"];
    [self.player .currentItem removeObserver:self forKeyPath:@"status"];
    //buffering
    [self.mPlayerItem removeObserver:self forKeyPath:k_BufferEmpty];
    [self.mPlayerItem removeObserver:self forKeyPath:k_ToKeepUp];
    
    [self removePlayerTimeObserver];
    [self stopMyTimer];
    if (nil != timeLabelTimer_)
    {
        [timeLabelTimer_ invalidate];
        timeLabelTimer_ = nil;
    }
    [self.player  pause];
    mPlayer = nil;
    mPlayerItem = nil;
}

-(void)playEnd{
    [self destoryPlayer];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)beginScrubbing:(id)sender
{
    [self stopMyTimer];
    seekBeginTime = CMTimeGetSeconds([mPlayer currentTime]);
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
            
            if (isnan(tolerance) || tolerance < 0.1f) {
                tolerance = 0.1f;
            }
            __block typeof (self) myself = self;
            //__block typeof (isPlayOnTV)isPlay = isPlayOnTV;
			mTimeObserver = [mPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC) queue:NULL usingBlock:
                             ^(CMTime time)
                             {
                                double curTime = CMTimeGetSeconds([myself.mPlayer currentTime]);
                                // NSLog(@"\n begin time %f,cur time:%f",myself.seekBeginTime,curTime);
                                if (fabs(curTime - myself.seekBeginTime) > 1.0f)
                                {
                                    [myself syncScrubber];
                                }
                             }];
        
		}
	}
    
	if (mRestoreAfterScrubbingRate)
	{
		[mPlayer setRate:mRestoreAfterScrubbingRate];
		mRestoreAfterScrubbingRate = 0.f;
	}
    if (isPlayOnTV)
    {
        [self controlCloundTV:CLOUND_TV_SEEK_TO_TIME];
    }
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
        if (isnan(time)) {
            time = 0;
        }
		[mScrubber setValue:(maxValue - minValue) * time / duration + minValue];
	}
    
}

- (BOOL)isScrubbing
{
	return mRestoreAfterScrubbingRate != 0.f;
}

-(void)scrub:(id)sender{

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
        
        NSString * str = [dic objectForKey:@"url"];
        NSString *tempStr = str;
        if([str rangeOfString:@"{now_date}"].location != NSNotFound){
            int nowDate = [[NSDate date] timeIntervalSince1970];
            tempStr = [str stringByReplacingOccurrencesOfString:@"{now_date}" withString:[NSString stringWithFormat:@"%i", nowDate]];
        }
        
        if ([tempStr isEqualToString:urlStr]) {
            source_str = [dic objectForKey:@"source"];
            break;
        }
    }
    videoSource_ = source_str;
    return [self parseLogo:source_str];
}

-(UIImage *)parseLogo:(NSString *)source_str{
    UIImage *logoImg = nil;
    if ([source_str isEqualToString:@"letv"]||[source_str isEqualToString:@"le_tv_fee"]) {
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
    else if ([source_str isEqualToString:@"wangpan"]
             || [source_str isEqualToString:@"baidu_wangpan"]){
        logoImg = [UIImage imageNamed:@"logo_pptv"];
    }

    return logoImg;

}
-(void)syncLogo:(NSString *)url{
    UILabel *label = (UILabel *)[topToolBar_ viewWithTag:100001];
  
    UIImage *img = [self getVideoSource:url];
    if (img == nil) {
        img = [self parseLogo:webUrlSource_];
    }
    if (img == nil) {
       label.text = nil;
    }
    else{
       label.text =  @"来源:";
    }
    sourceLogo_.backgroundColor = [UIColor clearColor];
    sourceLogo_.frame = CGRectMake(102, 11, img.size.width/3, img.size.height/3);
    sourceLogo_.image = img;
}
- (void)updateWatchRecord
{
    int playbackTime = 0;
    if(CMTimeGetSeconds([mPlayer currentTime])> 0){
        playbackTime = [NSNumber numberWithFloat:CMTimeGetSeconds([mPlayer currentTime])].intValue;
    }
    if (playbackTime == 0) {
        playbackTime = [NSNumber numberWithFloat:CMTimeGetSeconds(lastPlayTime_)].intValue;
    }
    int duration = 0;
    if(CMTimeGetSeconds([self playerItemDuration]) > 0){
        duration = [NSNumber numberWithFloat:CMTimeGetSeconds([self playerItemDuration])].intValue;
    }
    
    if(!islocalFile_){
        NSString *userId = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId];
        NSString *tempPlayType = @"1";

        NSString *playUrl = ((AVURLAsset *)mPlayerItem.asset).URL.absoluteString;
        if (playUrl == nil) {
            tempPlayType = @"2";
            playUrl = webPlayUrl_;
        }
        
        if (nil == prodId_)
            return;
        
        if (duration == 0 || (duration - playbackTime)>5) {
            [[CacheUtility sharedCache] putInCache:[NSString stringWithFormat:@"%@_%d",prodId_,(playNum+1)] result:[NSNumber numberWithInt:playbackTime] ];
        }
        else{ 
           [[CacheUtility sharedCache] putInCache:[NSString stringWithFormat:@"%@_%d",prodId_,(playNum+1)] result:[NSNumber numberWithInt:0] ];
        }
//        NSString *subname = @"";
//        if (videoType_ != 1 && playNum < subnameArray.count) {
//            subname = [subnameArray objectAtIndex:playNum];
//        }
       NSString *subname = [subnameArray objectAtIndex:playNum];
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: userId, @"userid", prodId_, @"prod_id", nameStr_, @"prod_name", subname, @"prod_subname", [NSNumber numberWithInt:videoType_], @"prod_type", tempPlayType, @"play_type", [NSNumber numberWithInt:playbackTime], @"playback_time", [NSNumber numberWithInt:duration], @"duration", playUrl, @"video_url", nil];
        [[AFServiceAPIClient sharedClient] postPath:kPathAddPlayHistory parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        [[NSNotificationCenter defaultCenter] postNotificationName:WATCH_HISTORY_REFRESH object:nil];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
           
        }];
    }
    else{
        if ((duration - playbackTime)>5) {
            [[CacheUtility sharedCache] putInCache:[NSString stringWithFormat:@"%@_%d",prodId_,(playNum+1)] result:[NSNumber numberWithInt:playbackTime] ];
            
        }
        else{
            NSString * str = [NSString stringWithFormat:@"%@_%d",prodId_,(playNum + 1)];
            [[CacheUtility sharedCache] putInCache:str result:[NSNumber numberWithInt:0] ];
           
        }
    }
}

//- (NSString *)getDownloadURLWithHTML:(NSString *)url
//{
//    NSData *htmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
//    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
//    NSArray *elements  = [xpathParser searchWithXPathQuery:@"//a"]; // get the title
//    
//    NSString * downloadURL = nil;
//    for (TFHppleElement * element in elements)
//    {
//        NSDictionary * dic = [element attributes];
//        
//        NSLog(@"%@",[dic objectForKey:@"class"]);
//        NSLog(@"%@",[dic objectForKey:@"id"]);
//        NSLog(@"%@",[element content]);
//        
//        if (([[dic objectForKey:@"class"] isEqualToString:@"new-dbtn"]
//             && [[dic objectForKey:@"id"] isEqualToString:@"downFileButtom"]) ||
//            ([[dic objectForKey:@"class"] isEqualToString:@"btn blue-btn"]
//             && [[dic objectForKey:@"id"] isEqualToString:@"fileDownload"]))
//        {
//            downloadURL = [element objectForKey:@"href"];
//            [downloadURL stringByReplacingOccurrencesOfString:@"amp;" withString:@""];
//            NSLog(@"%@",downloadURL);
//        }
//    }
//    return downloadURL;
//}


#pragma mark - changeTracks 
- (void)changeTracks:(int)type{    //0-第1个音轨；1-第2个音轨；
    if (audioMix_) {
        NSArray *inputParametersArray = audioMix_.inputParameters;
        for (int i = 0; i < [inputParametersArray count]; i++) {
            AVMutableAudioMixInputParameters *oneAudioMixInPut = [inputParametersArray objectAtIndex:i];
            if (i == type) {
                [oneAudioMixInPut setVolume:0.6 atTime:[mPlayer currentTime]];
            }
            else{
                [oneAudioMixInPut setVolume:0.0 atTime:[mPlayer currentTime]];
            }
            
        }
        [self.mPlayerItem setAudioMix:audioMix_];
    }
}
#pragma mark -
#pragma mark - TableViewDelegate & dataSource

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
        
        UIImageView * logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"local_file_icon"]];
        logo.frame = CGRectMake(tableList_.frame.size.width - 25, 0, 25, 25);
        [cell.contentView addSubview:logo];
        logo.backgroundColor = [UIColor clearColor];
        logo.tag = 23414;
        logo.hidden = YES;
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.font = [UIFont systemFontOfSize:12];
     
    if (indexPath.row == playNum) {
        cell.textLabel.textColor = [UIColor colorWithRed:240/255.0 green:51/255.0 blue:171/255.0 alpha:1];
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
   
    BOOL isDownload = NO;
    UIImageView * logo = (UIImageView *)[cell.contentView viewWithTag:23414];
    for (NSString * index in self.downloadIndex)
    {
        if ([index intValue] == indexPath.row + 1)
        {
            isDownload = YES;
            break;
        }
    }
    if (isDownload)
    {
        logo.hidden = NO;
    }
    else{
        logo.hidden = YES;
    }
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 38.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [self showNOThisClearityUrl:NO];
    
    [self destoryPlayer];
    
    playNum = indexPath.row;
    
    //tableList_.frame = CGRectMake(kFullWindowHeight-110, 55, 100, 0);
    //selectButton_.selected = NO;
    [tableList_ reloadData];
    
    [[CacheUtility sharedCache] putInCache:[NSString stringWithFormat:@"%@_%d",prodId_,(playNum+1)] result:[NSNumber numberWithInt:0]];
    lastPlayTime_ = kCMTimeZero;
    
    [self addCacheview];
    
    UITableViewCell * curCell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView * logo = (UIImageView *)[curCell.contentView viewWithTag:23414];
    if (logo.hidden)
    {
        islocalFile_ = NO;
        [self disableBottomToolBarButtons];
        [self addCacheview];
        [self initDataSource:playNum];
        [self beginToPlay];
        
        [self recordPlayStatics];
        clarityButton_.hidden = NO;
        localLogoBtn.hidden = YES;
        [self clearSelectView];
        bottomToolBar_.hidden = YES;
        selectButton_.selected = YES;
        [self showToolBar];
    }
    else
    {
        islocalFile_ = YES;
        NSDictionary * playInfo = nil;
        for (int i = 0; i < self.localPlaylist.count; i ++)
        {
            NSDictionary * dic = [localPlaylist objectAtIndex:i];
            if ([[dic objectForKey:@"subItemId"] isEqualToString:[NSString stringWithFormat:@"%@_%d",self.prodId,(indexPath.row + 1)]])
            {
                playInfo = dic;
                break;
            }
        }
        if (playInfo == nil)
            return;
        local_file_path_ = [playInfo objectForKey:@"videoUrl"];
        if ([[playInfo objectForKey:@"downloadType"] isEqualToString:@"m3u8"])
        {
            [[AppDelegate instance] startHttpServer];
            [self setURL:[NSURL URLWithString:local_file_path_]];
        }
        else
        {
            [self setPath:local_file_path_];
        }
        clarityButton_.hidden = YES;
        localLogoBtn.hidden = NO;
    }
}

#pragma mark -
#pragma mark - UIScrollViewDelegate

//- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
//{
//    [self stopMyTimer];
//}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
   [self resetMyTimer];
}

#pragma mark -
#pragma mark - NetworkChangedNSNotification
-(void)networkChanged:(NSNotification *)notify{
    int status = [(NSNumber *)(notify.object) intValue];
    if (status == 0) {
        myHUD.labelText = @"亲，网络出问题了，请检查后重试！";
    }
    else{
        myHUD.labelText = @"正在加载，请稍等";
    }
}

#pragma mark -
#pragma mark - 

- (NSMutableArray *)downloadIndexArray
{
    NSMutableArray * dArray = [[NSMutableArray alloc] init];
    NSArray * downloadedItem = [CommonMotheds localPlaylists:self.prodId type:videoType_];
    self.localPlaylist = downloadedItem;
    if (videoType_ == SHOW_TYPE)
    {
        
        for (int j = 0; j < downloadedItem.count; j ++)
        {
            NSDictionary * item = [downloadedItem objectAtIndex:j];
            NSString * index = [item objectForKey:@"subItemId"];
            
            NSArray * arr = [index componentsSeparatedByString:@"_"];
            if (arr.count != 2)
            {
                continue;
            }
            [dArray addObject:[arr objectAtIndex:1]];
        }
    }
    else
    {
        for (int j = 0; j < downloadedItem.count; j ++)
        {
            NSDictionary * item = [downloadedItem objectAtIndex:j];
            NSString * index = [item objectForKey:@"name"];
            
            NSArray * arr = [index componentsSeparatedByString:@"_"];
            if (arr.count != 2)
            {
                return nil;
            }
            [dArray addObject:[arr objectAtIndex:1]];
        }
    }
    return dArray;
}

- (void)playLocal:(NSDictionary *)file
{
    [self destoryPlayer];
    //self.playDuration = [[file objectForKey:@"duration"] intValue];
    if ([[file objectForKey:@"downloadType"] isEqualToString:@"m3u8"])
    {
        isM3u8_ = YES;
    }
    else
    {
        isM3u8_ = NO;
    }
    local_file_path_ = [file objectForKey:@"videoUrl"];
    islocalFile_ = YES;
    
    [[CacheUtility sharedCache] putInCache:[NSString stringWithFormat:@"%@_%d",prodId_,(playNum +1)] result:[NSNumber numberWithInt:0]];
    lastPlayTime_ = kCMTimeZero;
    [self addCacheview];
    if (isM3u8_)
    {
        [[AppDelegate instance] startHttpServer];
        [self setURL:[NSURL URLWithString:local_file_path_]];
    }
    else
    {
        [self setPath:local_file_path_];
    }
}

- (void)prepareOnlinePlay:(NSArray *)episodes
{
    episodesArr_ = episodes;
    [self initWillPlayLabel];
}

- (void)getVideoDetail
{
    NSString *key = nil;
    if (SHOW_TYPE == videoType_)
    {
        key = [NSString stringWithFormat:@"%@%@", @"show", self.prodId];
    }
    else if (DRAMA_TYPE == videoType_ || COMIC_TYPE == videoType_)
    {
        key = [NSString stringWithFormat:@"%@%@", @"tv", self.prodId];
    }
    else
    {
        return;
    }
    
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:key];
    if(cacheResult != nil)
    {
        selectButton_.enabled = YES;
        NSDictionary * episodesDic = nil;
        if (DRAMA_TYPE == videoType_ || COMIC_TYPE == videoType_)
        {
            episodesDic = [cacheResult objectForKey:@"tv"];
        }
        else if (SHOW_TYPE == videoType_)
        {
            episodesDic = [cacheResult objectForKey:@"show"];
        }
        [self prepareOnlinePlay:[episodesDic objectForKey:@"episodes"]];
    }
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: self.prodId, @"prod_id", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathProgramView parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        [[CacheUtility sharedCache] putInCache:key result:result];
        selectButton_.enabled = YES;
        NSDictionary * episodesDic = nil;
        if (DRAMA_TYPE == videoType_ || COMIC_TYPE == videoType_)
        {
            episodesDic = [result objectForKey:@"tv"];
        }
        else if (SHOW_TYPE == videoType_)
        {
            episodesDic = [result objectForKey:@"show"];
        }
        [self prepareOnlinePlay:[episodesDic objectForKey:@"episodes"]];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)recordPlayStatics
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: prodId_, @"prod_id", nameStr_, @"prod_name", [NSString stringWithFormat:@"%d",playNum], @"prod_subname", [NSNumber numberWithInt:videoType_], @"prod_type", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathRecordPlay parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSLog(@"succeed!");
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}
-(void)initplaytime{
    if (!CMTIME_IS_VALID(lastPlayTime_)) {
        NSNumber *playtime = [[CacheUtility sharedCache] loadFromCache:[NSString stringWithFormat:@"%@_%@",prodId_,[NSString stringWithFormat:@"%d",(playNum+1)]]];
        lastPlayTime_ = CMTimeMakeWithSeconds(playtime.doubleValue, NSEC_PER_SEC);
    }
    
}
-(void)addCacheview{
    
    [self initWillPlayLabel];
    
    if (!islocalFile_)
    {
        [playCacheView_ removeFromSuperview];
        [self.view addSubview:playCacheView_];
        if (nil == myHUD.superview)
        {
            [self.view addSubview:myHUD];
        }
        //myHUD.frame = CGRectMake(kFullWindowHeight/2 - 100,186, 200, 80);
        [self.view bringSubviewToFront:myHUD];
        
        myHUD.hidden = NO;
        [myHUD show:YES];
    }

}


-(void)initDataPlayFromRecord{
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:prodId_, @"prod_id", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathProgramView parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSDictionary *videoInfo = nil;
        if (videoType_ == 1) {
            videoInfo = (NSDictionary *)[result objectForKey:@"movie"];
        }
        else if(videoType_ == 2){
            videoInfo = (NSDictionary *)[result objectForKey:@"tv"];
        }
        else if (videoType_ == 3){
            videoInfo = (NSDictionary *)[result objectForKey:@"show"];
        }
        if ([[AppDelegate instance].showVideoSwitch isEqualToString:@"2"]) {
            int num = [[continuePlayInfo_ objectForKey:@"prod_subname"] intValue];
            NSDictionary *dic = [[videoInfo objectForKey:@"episodes"] objectAtIndex:num];
            NSArray *webUrlArr = [dic objectForKey:@"video_urls"];
            NSDictionary *urlInfo = [webUrlArr objectAtIndex:0];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[urlInfo objectForKey:@"url"]]];
        }
        else{
            playNum = 0;
            if (subnameArray == nil || subnameArray.count == 0) {
                subnameArray = [[NSMutableArray alloc]initWithCapacity:10];
                for (NSDictionary *oneEpisode in [videoInfo objectForKey:@"episodes"]) {
                    NSString *tempName = [NSString stringWithFormat:@"%@", [oneEpisode objectForKey:@"name"]];
                    [subnameArray addObject:tempName];
                }
            }
            if (videoType_ != 1 && subnameArray.count > 0) {
                //playNum = [subnameArray indexOfObject:[continuePlayInfo_ objectForKey:@"prod_subname"]];
                NSString *localSubname = [continuePlayInfo_ objectForKey:@"prod_subname"];
                for (NSString *subNameStr in subnameArray) {
                    if ([localSubname hasPrefix:subNameStr]|| [subNameStr hasPrefix:localSubname]) {
                        playNum = [subnameArray indexOfObject:subNameStr];
                        break;
                    }
                }
                if (playNum < 0 || playNum >= subnameArray.count) {
                    playNum = 0;
                }
            }
            nameStr_ =  [continuePlayInfo_ objectForKey:@"prod_name"];
            episodesArr_ = [videoInfo objectForKey:@"episodes"];
            
            dispatch_async( dispatch_queue_create("newQueue", NULL), ^{
                                [self initDataSource:playNum];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                        [self beginToPlay];
                                        [self clearSelectView];
                             });
                    });
            
            [self initWillPlayLabel];
            [tableList_ reloadData];
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
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

-(void)dealloc
{
    [avplayerView_.layer removeFromSuperlayer];
    
    avplayerView_ = nil;
    topToolBar_ = nil;
    bottomToolBar_ = nil;
    avplayerView_ = nil;
    mURL = nil;
    mScrubber = nil;
    mTimeObserver = nil;
    playCacheView_ = nil;
    selectButton_ = nil;
    clarityButton_ = nil;
    playButton_ = nil;
    pauseButton_ = nil;
    bottomView_ = nil;
    seeTimeLabel_ = nil;
    totalTimeLable_ = nil;
    nameStr_ = nil;
    clearBgView_ = nil;
    sortEpisodesArr_ = nil;
    episodesArr_ = nil;
    tableList_ = nil;
    superClearArr = nil;
    highClearArr = nil;
    plainClearArr = nil;
    play_index_tag = nil;
    local_file_path_ = nil;
    myTimer_ = nil;
    myHUD = nil;
    prodId_ = nil;
    webPlayUrl_ = nil;
    timeLabelTimer_ = nil;
    volumeView_ = nil;
    airPlayLabel_ = nil;
    sourceLogo_ = nil;
    willPlayLabel_ = nil;
    workingUrl_ = nil;
    titleLabel_ = nil;
    webUrlSource_ = nil;
    [subnameArray removeAllObjects];
    subnameArray = nil;
}

#pragma mark -
#pragma mark - app进入后台/重新激活
- (void)appDidEnterBackground:(NSNotification *)niti
{
    if (![ActionUtility isAirPlayActive])
    {
        if (self.isPlaying)
        {
            [mPlayer pause];
            playButton_.hidden = NO;
            pauseButton_.hidden = YES;
        }
        
        [self updateWatchRecord];
        
//        if (isPlayOnTV)
//        {
//            NSString * volume = (NSString *)[[ContainerUtility sharedInstance] attributeForKey:@"current_volume"];
//            [self setPlayVolume:[volume floatValue]];
//        }
        
    }
}

- (void)appDidBecomeActive:(NSNotification *)niti
{
//    if (isPlayOnTV)
//    {
//        [[ContainerUtility sharedInstance] setAttribute:[NSString stringWithFormat:@"%f",[self currentVolume]] forKey:@"current_volume"];
//        
//        [self setPlayVolume:0.0f];
//    }
}

#pragma mark -
#pragma mark - wifi -> 3G

- (void)wifiNotAvailable:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WIFI_IS_NOT_AVAILABLE object:nil];
    NSString *show3GAlert = (NSString *)notification.object;
    if ([show3GAlert isEqualToString:@"0"]) {
        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil message:@"当前网络为非Wifi环境，您确定要继续播放吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0){
        UIButton *closeBtn = (UIButton *)[topToolBar_ viewWithTag:CLOSE_BUTTON_TAG];
        [self action:closeBtn];
    }
}

#pragma mark -
#pragma mark FayeObjc delegate
- (void) messageReceived:(NSDictionary *)messageDict
{
    if ([[messageDict objectForKey:@"push_type"] isEqualToString:@"31"])
    {
        
    }
    else if ([[messageDict objectForKey:@"push_type"] isEqualToString:@"32"])
    {
        
    }
    else if ([[messageDict objectForKey:@"push_type"] isEqualToString:@"42"])
    {
        isTVReady = YES;
    }
}

- (void)connectedToServer
{
    
}

- (void)disconnectedFromServer
{
    [[BundingTVManager shareInstance] reconnectToServer];
    [BundingTVManager shareInstance].sendClient.delegate = self;
}

- (void)socketDidSendMessage:(ZTWebSocket *)aWebSocket
{
    
}

- (void)subscriptionFailedWithError:(NSString *)error
{
    
}
- (void)subscribedToChannel:(NSString *)channel
{
    
}

#pragma mark - 
#pragma mark - 控制投放TV接口(private)
- (void)controlCloundTV:(NSInteger)controlType
{
    NSString *userId = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:@"kUserId"];
    NSDictionary * data = (NSDictionary *)[[ContainerUtility sharedInstance] attributeForKey:[NSString stringWithFormat:@"%@_isBunding",userId]];
    NSString * sendChannel = [NSString stringWithFormat:@"CHANNEL_TV_%@",[data objectForKey:KEY_MACADDRESS]];
    double curTime = mScrubber.value * CMTimeGetSeconds([self playerItemDuration]);//CMTimeGetSeconds([self.mPlayer currentTime]);
    NSNumber * type = [NSNumber numberWithInt:videoType_];
    NSString * cType = nil;
    switch (controlType)
    {
        case CLOUND_TV_PLAY:
        {
            cType = @"403";
        }
            break;
        case CLOUND_TV_PAUSE:
        {
            cType = @"405";
        }
            break;
        case CLOUND_TV_CLOSE:
        {
            cType = @"409";
        }
            break;
        case CLOUND_TV_SEEK_TO_TIME:
        {
            cType = @"407";
        }
            break;
        default:
            break;
    }
    
    NSDictionary *reqData = [NSDictionary dictionaryWithObjectsAndKeys:
                          cType, @"push_type",
                          userId, @"user_id",
                          sendChannel, @"tv_channel",
                          [NSNumber numberWithFloat:curTime],@"prod_time",
                             workingUrl_,@"prod_url",
                             prodId_,@"prod_id",
                             nameStr_,@"prod_name",
                             type,@"prod_type",
                          nil];
    
    [[BundingTVManager shareInstance] sendMsg:reqData];
}

- (CGFloat)currentVolume
{
    return [MPMusicPlayerController applicationMusicPlayer].volume;
}

- (void)setPlayVolume:(CGFloat)volume
{
    MPMusicPlayerController *mpc = [MPMusicPlayerController applicationMusicPlayer];
    mpc.volume = volume;
}

@end
