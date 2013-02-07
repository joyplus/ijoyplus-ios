//
//  MyMediaPlayerViewController.m
//  yueshipin
//
//  Created by joyplus1 on 13-1-9.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "MyMediaPlayerViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CommonHeader.h"
#import "UIImage+Scale.h"
@interface MyMediaPlayerViewController () <NSURLConnectionDelegate>

@property (nonatomic, strong)NSLock *theLock;
@property (atomic, strong)NSURL *workingUrl;
@property (atomic) int errorUrlNum;
@property (nonatomic, strong)MPMoviePlayerViewController *playerViewController;
@property (nonatomic, strong)MPMoviePlayerController *player;
@property (nonatomic, strong)UIView *loadingView;
@property (nonatomic, strong)UIWebView *webView;
@property (nonatomic, strong)NSNumber *lastPlayTime;
@property (nonatomic, strong)NSTimer *controlVisibilityTimer;
@property (atomic)BOOL closed;
@end

@implementation MyMediaPlayerViewController
@synthesize videoUrls;
@synthesize workingUrl;
@synthesize playerViewController;
@synthesize player;
@synthesize loadingView;
@synthesize name;
@synthesize webView;
@synthesize videoHttpUrl;
@synthesize errorUrlNum;
@synthesize prodId;
@synthesize subname;
@synthesize playTime;
@synthesize type, currentNum, isDownloaded, closeAll, closed;
@synthesize videoWebViewControllerDelegate;
@synthesize lastPlayTime;
@synthesize theLock;
@synthesize controlVisibilityTimer;
@synthesize dramaDetailViewControllerDelegate;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerContentPreloadDidFinishNotification object:nil];
    loadingView = nil;
    self.prodId = nil;
    self.name = nil;
    [playerViewController.view removeFromSuperview];
    playerViewController.view = nil;
    playerViewController = nil;
    player = nil;
    lastPlayTime = nil;
    videoWebViewControllerDelegate = nil;
    videoHttpUrl = nil;
    [videoUrls removeAllObjects];
    videoUrls = nil;
    workingUrl = nil;
    [self.webView loadRequest: nil];
    [self.webView removeFromSuperview];
    self.webView = nil;
    controlVisibilityTimer = nil;
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
    [self.view setBackgroundColor:[UIColor whiteColor]];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        UILabel *t = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 30)];
        t.font = [UIFont boldSystemFontOfSize:18];
        t.textColor = [UIColor whiteColor];
        t.backgroundColor = [UIColor clearColor];
        t.textAlignment = UITextAlignmentCenter;
        t.text = self.name;
        self.navigationItem.titleView = t;
    
    }else{
        self.title = self.name;
    }
    
    UIButton *myButton = [UIButton buttonWithType:UIButtonTypeCustom];
    myButton.frame = CGRectMake(0, 0, 56, 29);
    [myButton setBackgroundImage:[UIImage imageNamed:@"left_btn"] forState:UIControlStateNormal];
    [myButton setBackgroundImage:[UIImage imageNamed:@"left_btn_pressed"] forState:UIControlStateHighlighted];
    [myButton addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *customItem = [[UIBarButtonItem alloc] initWithCustomView:myButton];
    self.navigationItem.leftBarButtonItem = customItem;
    
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage scaleFromImage:[UIImage imageNamed:@"top_bg_common.png"] toSize:CGSizeMake(kFullWindowHeight, 44)] forBarMetrics:UIBarMetricsDefault];
    theLock = [[NSLock alloc]init];
    
    UIImageView *imageView = nil;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
      loadingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.width)];
      imageView = [[UIImageView alloc]initWithFrame:loadingView.frame];
      imageView.image = [UIImage imageNamed:@"cache_video"];
    } else{
        loadingView = [[UIView alloc]initWithFrame:CGRectMake(-13, 0, self.view.bounds.size.height+44, self.view.bounds.size.width)];
        imageView = [[UIImageView alloc]initWithFrame:loadingView.frame];
        if([AppDelegate instance].window.bounds.size.height == 568){
            imageView.image = [UIImage imageNamed:@"iphone_cache_video"];
        } else {
            imageView.image = [UIImage imageNamed:@"iphone_cache_video2"];
        }
    }
    //
    loadingView.backgroundColor = [UIColor blackColor];
    [loadingView addSubview:imageView];
    UILabel *playtimeLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 80)];
    playtimeLab.center = CGPointMake([AppDelegate instance].window.bounds.size.height/2, 240);
    playtimeLab.text = playTime;
    playtimeLab.backgroundColor = [UIColor clearColor];
    playtimeLab.textColor = [UIColor whiteColor];
    playtimeLab.font = [UIFont systemFontOfSize:14];
    playtimeLab.textAlignment = NSTextAlignmentCenter;
    [loadingView addSubview:playtimeLab];
    [self.view addSubview:loadingView];
   
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerPreloadFinish:) name:MPMoviePlayerContentPreloadDidFinishNotification object:nil];
    
    [myHUD showProgressBar:self.view];
    if(videoUrls.count > 0){
        if (isDownloaded) {
            workingUrl = [[NSURL alloc] initFileURLWithPath:[videoUrls objectAtIndex:0]];
            [self playVideo];
        } else {
            for (NSString *url in videoUrls) {
                int nowDate = [[NSDate date] timeIntervalSince1970];
                NSString *formattedUrl = url;
                if([url rangeOfString:@"{now_date}"].location != NSNotFound){
                    formattedUrl = [url stringByReplacingOccurrencesOfString:@"{now_date}" withString:[NSString stringWithFormat:@"%i", nowDate]];
                }
                NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:formattedUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5];
                [NSURLConnection connectionWithRequest:request delegate:self];
            }
        }
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showNavigationBar)];
        tapRecognizer.numberOfTapsRequired = 1;
        [self.view addGestureRecognizer:tapRecognizer];
    } else if (videoHttpUrl){
        [self showWebView];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];
    if(videoUrls.count > 0){
        self.navigationController.navigationBar.alpha = 0;
        [self.navigationController setNavigationBarHidden:NO];
    }
}

- (void)showNavigationBar
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.35];
    [self.navigationController.navigationBar setAlpha:1];
    [UIView commitAnimations];
    [controlVisibilityTimer invalidate];
    controlVisibilityTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(hideNavigationBar) userInfo:nil repeats:NO];
}
- (void)hideNavigationBar
{
    [controlVisibilityTimer invalidate];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.35];
    [self.navigationController.navigationBar setAlpha:0];
    [UIView commitAnimations];
}

-(BOOL)shouldAutorotate {
    
    return NO;
    
}

-(NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskLandscapeRight;
    
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationLandscapeRight;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"error url");
    [connection cancel];
    //如果所有的视频地址都无效，则播放网页地址
    [self checkIfShowWebView];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    @synchronized(workingUrl){
        if(workingUrl == nil){
            NSDictionary *headerFields = [(NSHTTPURLResponse *)response allHeaderFields];
            NSString *contentLength = [NSString stringWithFormat:@"%@", [headerFields objectForKey:@"Content-Length"]];
            if (contentLength.intValue > 100) {
                NSLog(@"working = %@", connection.originalRequest.URL);
                workingUrl = connection.originalRequest.URL;
                [self performSelectorOnMainThread:@selector(playVideo) withObject:nil waitUntilDone:NO];
                [connection cancel];
            } else {
                [self checkIfShowWebView];
            }
        }
    }
}

- (void)checkIfShowWebView
{
    [theLock lock];
    errorUrlNum++;
    if (errorUrlNum == videoUrls.count) {
        [myHUD hideAtOnce];
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.opacity = 0.5;
        HUD.labelText = @"即将使用网页播放";
        [HUD show:YES];
        [self performSelector:@selector(closeModalView) withObject:nil afterDelay:2.5];
    }
    [theLock unlock];

}

- (void)closeModalView
{
    if (closeAll) {
        [self dismissModalViewControllerAnimated:NO];
    } else {
        [self closeCacheScreen];
        [self.navigationController popViewControllerAnimated:NO];
    }
    //        [self showWebView];
}

- (void)showWebView
{
    [self closeCacheScreen];
    CGRect bound = [UIScreen mainScreen].bounds;
    if(videoHttpUrl){
        webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, bound.size.height, bound.size.width)];
        [webView setBackgroundColor:[UIColor clearColor]];
        [self hideGradientBackground:webView];
        NSURL *url = [NSURL URLWithString:videoHttpUrl];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        [webView loadRequest:requestObj];
        [webView setScalesPageToFit:YES];
        [self.view addSubview:webView];
    } else {
        [UIUtility showPlayVideoFailure:self.view];
    }
}

- (void)playVideo{
    CGRect bound = self.view.bounds;
    playerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:self.workingUrl];
    playerViewController.view.frame = CGRectMake(0, 0, bound.size.width, bound.size.height);
    playerViewController.moviePlayer.scalingMode = MPMovieScalingModeNone;
    [self.view insertSubview:self.playerViewController.view belowSubview:loadingView];
    
    player = [playerViewController moviePlayer];

    [player prepareToPlay];
    player.useApplicationAudioSession = NO;
    NSString *key = [NSString stringWithFormat:@"%@_%@", self.prodId, self.subname];
    lastPlayTime = [[CacheUtility sharedCache]loadFromCache:key];
    [player setInitialPlaybackTime: lastPlayTime.doubleValue];
    [player play];
}

- (void)moviePlayerPreloadFinish:(NSNotification *)theNotification
{
   // [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.navigationController setNavigationBarHidden:YES];
    [self closeCacheScreen];
}

- (void)playVideoFinished:(NSNotification *)theNotification//当点击Done按键或者播放完毕时调用此函数
{
    if (!closed) {
        closed = YES;
        [self updateWatchRecord];
    }
    BOOL userClicked = YES;
	lastPlayTime = [NSNumber numberWithDouble:player.currentPlaybackTime];
    if((player.duration - lastPlayTime.doubleValue <= 0.1 || lastPlayTime == nil) && player.duration > 0){
        lastPlayTime = [NSNumber numberWithInt:0];
        userClicked = NO;
    }
    NSString *key = [NSString stringWithFormat:@"%@_%@", self.prodId, self.subname];
    [[CacheUtility sharedCache] putInCache:key result:lastPlayTime];
    [player pause];
//    [playerViewController.view removeFromSuperview];
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
      [[UIApplication sharedApplication] setStatusBarHidden:NO];
      [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    
    if ([@"0" isEqualToString:[AppDelegate instance].closeVideoMode]) {
        [self dismissModalViewControllerAnimated:NO];
    } else{
        if (closeAll) {
            [self dismissModalViewControllerAnimated:NO];
        } else {
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
    if(!userClicked){
        if ([@"0" isEqualToString:[AppDelegate instance].closeVideoMode]) {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            [self.dramaDetailViewControllerDelegate playNextEpisode];
            }
            else{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PLAY_NEXT" object:[NSNumber numberWithInt:self.currentNum]];
            }
        } else {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                [self.videoWebViewControllerDelegate playNextEpisode:self.currentNum+1];
            }
            else{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PLAY_NEXT" object:[NSNumber numberWithInt:self.currentNum]];
            }
        }
    }
}


- (void)updateWatchRecord
{
    if(!isDownloaded){
        int playbackTime = 0;
        if(player.currentPlaybackTime > 0){
            playbackTime = [NSNumber numberWithFloat:player.currentPlaybackTime].intValue;
        }
        int duration = 0;
        if(player.duration > 0){
            duration = [NSNumber numberWithFloat:player.duration].intValue;
        }
        self.subname = self.subname == nil ? @"" : self.subname;
        NSString *userId = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId];
        NSString *tempPlayType = @"1";
        NSString *tempUrl = workingUrl.absoluteString;
        NSLog(@"%@", tempUrl);
        if (workingUrl == nil) {
            tempPlayType = @"2";
            tempUrl = videoHttpUrl;
        }
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: userId, @"userid", self.prodId, @"prod_id", self.name, @"prod_name", self.subname, @"prod_subname", [NSNumber numberWithInt:self.type], @"prod_type", tempPlayType, @"play_type", [NSNumber numberWithInt:playbackTime], @"playback_time", [NSNumber numberWithInt:duration], @"duration", tempUrl, @"video_url", nil];
        [[AFServiceAPIClient sharedClient] postPath:kPathAddPlayHistory parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [[NSNotificationCenter defaultCenter] postNotificationName:WATCH_HISTORY_REFRESH object:nil];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"zz%@", error);
        }];
    }
}

- (void) hideGradientBackground:(UIView*)theView
{
    for (UIView * subview in theView.subviews)
    {
        if ([subview isKindOfClass:[UIImageView class]])
            subview.hidden = YES;
        
        [self hideGradientBackground:subview];
    }
}


- (void)closeSelf
{
    closeAll = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}

- (void)closeCacheScreen
{
    [myHUD hide];
    [loadingView removeFromSuperview];
    loadingView = nil;
}

@end
