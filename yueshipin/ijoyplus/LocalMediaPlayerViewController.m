//
//  MediaPlayerViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-10-31.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "LocalMediaPlayerViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CustomBackButton.h"
#import "CacheUtility.h"
#import "FPPopoverController.h"
#import "DeviceListViewController.h"
#import "IntroductionView.h"

@interface LocalMediaPlayerViewController (){
    MPMoviePlayerViewController *playerViewController;
    MPMoviePlayerController *player;
    UIView *overlayView;
}
@end

@implementation LocalMediaPlayerViewController
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
    NSURL *mediaFileUrl = [[NSURL alloc] initWithString:self.videoUrl];
    playerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:mediaFileUrl];
    CGRect bound = self.view.bounds;
    playerViewController.view.frame = CGRectMake(0, -20, bound.size.width, bound.size.height + 20);
    [self.navigationController setNavigationBarHidden:YES];
    [self.view addSubview:playerViewController.view];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerPreloadFinish:) name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification object:nil];
    player = [playerViewController moviePlayer];
    player.controlStyle = MPMovieControlStyleNone;
    NSNumber *lastPlayTime = (NSNumber*)[[CacheUtility sharedCache]loadFromCache:self.videoUrl];
    if(player.duration - player.playableDuration <= 5){
        lastPlayTime = 0;
    }
    [player setInitialPlaybackTime: lastPlayTime.doubleValue];
    [player play];
}

// iOS6.0
-(NSUInteger)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskLandscapeLeft;  // 可以修改为任何方向
}

-(BOOL)shouldAutorotate{
    
    return YES;
}

- (void)moviePlayerPreloadFinish:(NSNotification *)theNotification
{

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

@end
