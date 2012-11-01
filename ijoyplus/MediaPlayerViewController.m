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

@interface MediaPlayerViewController (){
    MPMoviePlayerViewController *playerViewController;
    MPMoviePlayerController *player;
}

@end

@implementation MediaPlayerViewController
@synthesize videoUrl;

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
//    self.videoUrl = @"http://m.youku.com/wap/pvs?id=XNDUxNjU4NjAw&format=3gphd";
    int nowDate = [[NSDate date] timeIntervalSince1970];
    NSNumber *lastPlayTime = (NSNumber*)[[CacheUtility sharedCache]loadFromCache:self.videoUrl];
    if([self.videoUrl rangeOfString:@"{now_date}"].location != NSNotFound){
        self.videoUrl = [self.videoUrl stringByReplacingOccurrencesOfString:@"{now_date}" withString:[NSString stringWithFormat:@"%i", nowDate]];
    }
    NSLog(@"%@", self.videoUrl);
    NSURL *mediaFileUrl = [[NSURL alloc] initWithString:self.videoUrl];
    playerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:mediaFileUrl];
    CGRect bound = self.view.bounds;
    playerViewController.view.frame = CGRectMake(0, -20, bound.size.width, bound.size.height + 20);

    [self.navigationController setNavigationBarHidden:YES];
    [self.view addSubview:playerViewController.view];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    player = [playerViewController moviePlayer];
    
//    for(UIView *subview in ((UIView *)[[player.backgroundView.superview subviews] objectAtIndex:2]).subviews){
//        if([subview isKindOfClass:[UINavigationBar class]]){
//            UINavigationBar *bar = (UINavigationBar *)subview;
//            UIView *view = [bar.subviews objectAtIndex:3];
//            CustomBackButton *backButton = [[CustomBackButton alloc] initWith:[UIImage imageNamed:@"back-button"] highlight:[UIImage imageNamed:@"back-button"] leftCapWidth:14.0 text:NSLocalizedString(@"back", nil)];
//            backButton.frame = view.frame;
//            [bar insertSubview:backButton aboveSubview:view];
//        }
//    }
    [player setInitialPlaybackTime: lastPlayTime.doubleValue];
    [player play];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [playerViewController.view removeFromSuperview];
    playerViewController.view = nil;
    playerViewController = nil;
    self.videoUrl = nil;
    player = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void) playVideoFinished:(NSNotification *)theNotification//当点击Done按键或者播放完毕时调用此函数
{
	NSTimeInterval lastPlayTime = player.currentPlaybackTime;
    [[CacheUtility sharedCache] putInCache:self.videoUrl result:[NSNumber numberWithDouble:lastPlayTime]];
    [self dismissModalViewControllerAnimated:YES];
}
@end
