//
//  MediaPlayerViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-10-31.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "MediaPlayerViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CacheUtility.h"
#import "FPPopoverController.h"
#import "DeviceListViewController.h"
#import "CMConstants.h"
#import "DateUtility.h"
#import "CommonHeader.h"

@interface MediaPlayerViewController (){
    MPMoviePlayerViewController *playerViewController;
    MPMoviePlayerController *player;
    UIView *overlayView;
    UIView *mpVideoView;
    UIButton *shareBtn;
    double totalVideoTime;
    BOOL deviceSelected;
    UIView *deviceLoadingView;
    UIButton *switchBtn;
    UIImageView *deviceImageView;
    NSNumber *lastPlayTime;
    
    BOOL play;
    BOOL pause;
    BOOL forward;
    BOOL backward;
}
@end

@implementation MediaPlayerViewController
@synthesize videoUrl;
@synthesize name;
@synthesize type;
@synthesize currentNum;
@synthesize isDownloaded;
@synthesize prodId;
@synthesize dramaDetailViewControllerDelegate;

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.prodId = nil;
    self.name = nil;
    self.videoUrl = nil;
    shareBtn = nil;
    mpVideoView = nil;
    overlayView = nil;
    deviceLoadingView = nil;
    switchBtn = nil;
    deviceImageView = nil;
    [playerViewController.view removeFromSuperview];
    playerViewController.view = nil;
    playerViewController = nil;
    player = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
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
    [self.view setBackgroundColor:[UIColor clearColor]];
//    self.videoUrl = @"http://hot.vrs.sohu.com/ipad909901_4567748189248_220033.m3u8";
    int nowDate = [[NSDate date] timeIntervalSince1970];
    if([self.videoUrl rangeOfString:@"{now_date}"].location != NSNotFound){
        self.videoUrl = [self.videoUrl stringByReplacingOccurrencesOfString:@"{now_date}" withString:[NSString stringWithFormat:@"%i", nowDate]];
    }
    NSLog(@"%@", self.videoUrl);
    //NSURL *mediaFileUrl = [[NSURL alloc] initFileURLWithPath:@"assets-library://asset/asset.MOV?id=647CACF5-F040-4FB7-9EFC-3D24F63F1F4D&ext=MOV"];
    NSURL *mediaFileUrl = nil;
    if(isDownloaded){
        mediaFileUrl = [[NSURL alloc] initFileURLWithPath:self.videoUrl];
    } else {
        mediaFileUrl = [[NSURL alloc] initWithString:self.videoUrl];
    }
    playerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:mediaFileUrl];
    CGRect bound = self.view.bounds;
    playerViewController.view.frame = CGRectMake(0, -20, bound.size.width, bound.size.height + 20);

    [self.navigationController setNavigationBarHidden:YES];
    [self.view addSubview:playerViewController.view];
    
    player = [playerViewController moviePlayer];
    [player prepareToPlay];
    player.useApplicationAudioSession = NO;
    lastPlayTime = (NSNumber*)[[CacheUtility sharedCache]loadFromCache:self.videoUrl];
    [player setInitialPlaybackTime: lastPlayTime.doubleValue];
    [player play];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerPreloadFinish:) name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateChanged:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
}

- (void)printSubview:(UIView *)view
{
    NSLog(@"%@ ====> %i", view.class, view.subviews.count);
    if(view.subviews.count > 0){
        for (UIView *aView in view.subviews) {
            [self printSubview:aView];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

- (void)moviePlayerPreloadFinish:(NSNotification *)theNotification
{
    //    [self readOverLayView:player.view];
    //    UIView *buttonView = (UIView *)[overlayView.subviews objectAtIndex:0];
    //    UIView *existingBtnView = ((UIView *)[buttonView.subviews objectAtIndex:1]);
    //    if(shareBtn == nil){
    //        shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //    }
    //    shareBtn.frame = CGRectMake(0, 0, 56, 56);
    //    shareBtn.center = CGPointMake(40, existingBtnView.center.y);
    //    shareBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    //    [shareBtn setBackgroundImage:[UIImage imageNamed:@"device"] forState:UIControlStateNormal];
    //    [shareBtn setBackgroundImage:[UIImage imageNamed:@"device_pressed"] forState:UIControlStateHighlighted];
    //    [shareBtn addTarget:self action:@selector(showPopWindow:)forControlEvents:UIControlEventTouchUpInside];
    //    [buttonView addSubview:shareBtn];
}
- (void)playVideoFinished:(NSNotification *)theNotification//当点击Done按键或者播放完毕时调用此函数
{
    BOOL userClicked = YES;
	lastPlayTime = [NSNumber numberWithDouble:player.currentPlaybackTime];
    if(player.duration - lastPlayTime.doubleValue <= 0.1 || lastPlayTime == nil){
        lastPlayTime = [NSNumber numberWithInt:0];
        userClicked = NO;
    }
    [self updateWatchRecord];
    [[CacheUtility sharedCache] putInCache:self.videoUrl result:lastPlayTime];
//    [playerViewController.view removeFromSuperview];
    [self dismissViewControllerAnimated:YES completion:^{
        if(!userClicked){
            [self.dramaDetailViewControllerDelegate playNextEpisode:self.currentNum];
        }
    }];
}

- (void)updateWatchRecord
{
    int playbackTime = 0;
    if(player.currentPlaybackTime > 0){
        playbackTime = [NSNumber numberWithFloat:player.currentPlaybackTime].intValue;
    }
    int duration = 0;
    if(player.duration > 0){
        duration = [NSNumber numberWithFloat:player.duration].intValue;
    } 
    NSString *userId = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: userId, @"userid", self.prodId, @"prod_id", self.name, @"prod_name", self.subname, @"prod_subname", [NSNumber numberWithInt:self.type], @"prod_type", @"1", @"play_type", [NSNumber numberWithInt:playbackTime], @"playback_time", [NSNumber numberWithInt:duration], @"duration", self.videoUrl, @"video_url", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathAddPlayHistory parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        [[NSNotificationCenter defaultCenter] postNotificationName:WATCH_HISTORY_REFRESH object:nil];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"zz%@", error);
    }];    
}

- (void)readOverLayView:(UIView *)view
{
    for (UIView *aView in [view subviews]){
        if ([aView isKindOfClass:NSClassFromString(@"MPFullScreenVideoOverlay")]) {
            overlayView = aView;
            return;
        }
        [self readOverLayView:aView];
    }
}

- (void)readMPVideoView:(UIView *)view
{
    for (UIView *aView in [view subviews]){
        if ([aView isKindOfClass:NSClassFromString(@"MPVideoView")]) {
            mpVideoView = aView;
            return;
        }
        [self readMPVideoView:aView];
    }
}

- (void)showPopWindow:(id)sender
{
    [player pause];
    DeviceListView *deviceListView = [[DeviceListView alloc] initWithTitle:@"请选择输出设备"];
    deviceListView.tag = 1001;
    deviceListView.delegate = self;
    [deviceListView showInView:self.view animated:YES];
    [shareBtn setEnabled:NO];
}

- (void)playbackStateChanged:(NSNotification *)notification
{
    if(deviceSelected){
        switch ([player playbackState]) {
            case MPMoviePlaybackStatePlaying:
                if (play){
                    [self sendToDevice:player.currentPlaybackTime];
                }
                play = YES;
                pause = NO;
                break;
            case MPMoviePlaybackStatePaused:
                if(play){
                    [self sendToDevice:player.currentPlaybackTime];
                }
                play = NO;
                pause = YES;
                break;
        }
    }
}

- (void)donothing
{
    
}

- (void)deviceSelected
{
    if(!deviceSelected){
        deviceSelected = YES;
        [self showConnectDeviceView];
    }
}

- (void)showConnectDeviceView
{
    if(deviceLoadingView == nil){
        deviceLoadingView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height)];
        deviceLoadingView.backgroundColor = [UIColor blackColor];
    }
    
    if(mpVideoView == nil){
        [self readMPVideoView:player.view];
    }
    if ( [[UIDevice currentDevice].systemVersion floatValue] < 6.0){
        UIView *videoView = [mpVideoView.subviews objectAtIndex:0];
        [mpVideoView insertSubview:deviceLoadingView aboveSubview:videoView];
        [videoView setHidden:YES];
    } else {
        [mpVideoView setHidden:YES];
    }
    
    if(deviceImageView == nil){
        deviceImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 105, 72)];
        deviceImageView.image = [UIImage imageNamed:@"device_logo"];
        deviceImageView.center = CGPointMake(self.view.bounds.size.width/2, 105);
    }
    [player.view addSubview:deviceImageView];
    
    if(switchBtn == nil){
        switchBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        switchBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [switchBtn.titleLabel setTextColor: [UIColor blackColor]];
        [switchBtn setTitle:@"切换回手机播放" forState:UIControlStateNormal];
        [switchBtn setBackgroundImage:[UIImage imageNamed:@"device_switch"] forState:UIControlStateNormal];
        switchBtn.frame = CGRectMake(0, 0, 105, 27);
        switchBtn.center = CGPointMake(self.view.bounds.size.width/2, 190);
        [switchBtn addTarget:self action:@selector(switchClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    [player.view addSubview:switchBtn];
}

- (void)closeConnectDeviceView
{
    if ( [[UIDevice currentDevice].systemVersion floatValue] < 6.0){
        UIView *videoView = [mpVideoView.subviews objectAtIndex:0] ;
        [videoView setHidden:NO];
    } else {
        [mpVideoView setHidden:NO];
    }
    
    [deviceLoadingView removeFromSuperview];
    [switchBtn removeFromSuperview];
    [deviceImageView removeFromSuperview];
}

- (void)switchClicked:(id)sender
{
    [shareBtn setEnabled:YES];
    deviceSelected = NO;
    [self closeConnectDeviceView];
    [player play];
}

- (void)sendToDevice:(double)currentPlaybackTime
{
    NSLog(@"send to service");
}


- (void)leveyPopListViewDidCancel
{
    [shareBtn setEnabled:YES];
    [player play];
}
//
//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//    // Adjust the current view in prepartion for the new orientation
//    UIView* deviceListView = [self.view viewWithTag:1001];
//    CGFloat width = 0, height = 0;
//    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
//    {
//        width = deviceListView.frame.size.height;
//        height = deviceListView.frame.size.width;
//        deviceListView.frame = CGRectMake(0,0,width, height);
//        deviceListView.center = CGPointMake(deviceListView.center.x, deviceListView.center.y + 40);
//        for(UIView *aView in deviceListView.subviews){
//            if([aView isKindOfClass:UITextView.class]){
//                aView.frame = CGRectMake(TitleLandScapeX, TitleLandScapeY, aView.frame.size.width, aView.frame.size.height);
//            } else if([aView isKindOfClass:UITableView.class]){
//                aView.frame = CGRectMake(TableLandScapeX, TableLandScapeY, TableLandScapeWidth, TableLandScapeHeight);
//            }
//        }
//    }
//    else
//    {
//        width = deviceListView.frame.size.height;
//        height = deviceListView.frame.size.width;
//        deviceListView.frame = CGRectMake(0,0,width, height);
//        deviceListView.center = CGPointMake(deviceListView.center.x, deviceListView.center.y + 40);
//        for(UIView *aView in deviceListView.subviews){
//            if([aView isKindOfClass:UITextView.class]){
//                aView.frame = CGRectMake(TitlePortraitX, TitlePortraitY, aView.frame.size.width, aView.frame.size.height);
//            } else if([aView isKindOfClass:UITableView.class]){
//                aView.frame = CGRectMake(TablePortraitX, TablePortraitY, TablePortraitWidth, TablePortraitHeight);
//            }
//        }
//    }
//}
@end
