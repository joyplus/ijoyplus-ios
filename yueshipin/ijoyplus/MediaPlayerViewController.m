//
//  MediaPlayerViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-10-31.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "MediaPlayerViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CustomBackButton.h"
#import "CacheUtility.h"
#import "FPPopoverController.h"
#import "DeviceListViewController.h"
#import "IntroductionView.h"

@interface MediaPlayerViewController (){
    MPMoviePlayerViewController *playerViewController;
    MPMoviePlayerController *player;
    UIView *overlayView;
}
@end

@implementation MediaPlayerViewController
@synthesize videoUrl;

- (void)viewDidUnload
{
    [super viewDidUnload];
    [playerViewController.view removeFromSuperview];
    playerViewController.view = nil;
    playerViewController = nil;
    self.videoUrl = nil;
    player = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification object:nil];
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
    //    self.videoUrl = @"http://m.youku.com/wap/pvs?id=XNDUxNjU4NjAw&format=3gphd";
    int nowDate = [[NSDate date] timeIntervalSince1970];
    if([self.videoUrl rangeOfString:@"{now_date}"].location != NSNotFound){
        self.videoUrl = [self.videoUrl stringByReplacingOccurrencesOfString:@"{now_date}" withString:[NSString stringWithFormat:@"%i", nowDate]];
    }
    NSLog(@"%@", self.videoUrl);
    //NSURL *mediaFileUrl = [[NSURL alloc] initFileURLWithPath:@"assets-library://asset/asset.MOV?id=647CACF5-F040-4FB7-9EFC-3D24F63F1F4D&ext=MOV"]; 
    NSURL *mediaFileUrl = [[NSURL alloc] initWithString:self.videoUrl];
    playerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:mediaFileUrl];
    CGRect bound = self.view.bounds;
    playerViewController.view.frame = CGRectMake(0, -20, bound.size.width, bound.size.height + 20);
    
    [self.navigationController setNavigationBarHidden:YES];
    [self.view addSubview:playerViewController.view];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerPreloadFinish:) name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification object:nil];
    player = [playerViewController moviePlayer];
    NSNumber *lastPlayTime = (NSNumber*)[[CacheUtility sharedCache]loadFromCache:self.videoUrl];
    NSLog(@"%f", player.duration);
    NSLog(@"%f", player.playableDuration);
    if(player.duration - player.playableDuration <= 5){
        lastPlayTime = 0;
    }
    [player setInitialPlaybackTime: lastPlayTime.doubleValue];
    [player play];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIDeviceOrientationLandscapeLeft;
}

- (void)moviePlayerPreloadFinish:(NSNotification *)theNotification
{
    [self readSubviews:player.view];
    UIView *buttonView = (UIView *)[overlayView.subviews objectAtIndex:0];
    UIView *existingBtnView = ((UIView *)[buttonView.subviews objectAtIndex:1]);
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame = CGRectMake(0, 0, 56, 56);
    shareBtn.center = CGPointMake(40, existingBtnView.center.y);
    shareBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [shareBtn setBackgroundImage:[UIImage imageNamed:@"device"] forState:UIControlStateNormal];
    [shareBtn setBackgroundImage:[UIImage imageNamed:@"device_pressed"] forState:UIControlStateHighlighted];
    [shareBtn addTarget:self action:@selector(showPopWindow:)forControlEvents:UIControlEventTouchUpInside];
//    [buttonView addSubview:shareBtn];
}
- (void)playVideoFinished:(NSNotification *)theNotification//当点击Done按键或者播放完毕时调用此函数
{
	NSTimeInterval lastPlayTime = player.currentPlaybackTime;
    [playerViewController.view removeFromSuperview];
    [[CacheUtility sharedCache] putInCache:self.videoUrl result:[NSNumber numberWithDouble:lastPlayTime]];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)readSubviews:(UIView *)view
{
    for (UIView *aView in [view subviews]){
        if ([aView isKindOfClass:NSClassFromString(@"MPFullScreenVideoOverlay")]) {
            overlayView = aView;
            return;
        }
        [self readSubviews:aView];
    }
}

- (void)showPopWindow:(id)sender
{
    [player pause];
    DeviceListView *deviceListView = [[DeviceListView alloc] initWithTitle:@"请选择输出设备"];
    deviceListView.tag = 1001;
    deviceListView.delegate = self;
    [deviceListView showInView:self.view animated:YES];
}

- (void)leveyPopListViewDidCancel
{
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
