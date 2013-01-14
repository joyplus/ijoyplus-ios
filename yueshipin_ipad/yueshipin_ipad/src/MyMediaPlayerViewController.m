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

@interface MyMediaPlayerViewController () <NSURLConnectionDelegate>


@property (atomic, strong)NSURL *workingUrl;
@property (atomic) int errorUrlNum;
@property (nonatomic, strong)MPMoviePlayerViewController *playerViewController;
@property (nonatomic, strong)MPMoviePlayerController *player;
@property (nonatomic, strong)UIView *loadingView;
@property (nonatomic, strong)UIWebView *webView;
@property (nonatomic, strong)NSNumber *lastPlayTime;
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
@synthesize type, currentNum, isDownloaded;
@synthesize dramaDetailViewControllerDelegate;
@synthesize lastPlayTime;

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
    dramaDetailViewControllerDelegate = nil;
    videoHttpUrl = nil;
    [videoUrls removeAllObjects];
    videoUrls = nil;
    workingUrl = nil;
    [self.webView loadRequest: nil];
    [self.webView removeFromSuperview];
    self.webView = nil;
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
    
    UILabel *t = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 30)];
    t.font = [UIFont boldSystemFontOfSize:18];
    t.textColor = [UIColor whiteColor];
    t.backgroundColor = [UIColor clearColor];
    t.textAlignment = UITextAlignmentCenter;
    t.text = self.name;
    self.navigationItem.titleView = t;
    
    UIButton *myButton = [UIButton buttonWithType:UIButtonTypeCustom];
    myButton.frame = CGRectMake(0, 0, 56, 29);
    [myButton setBackgroundImage:[UIImage imageNamed:@"left_btn"] forState:UIControlStateNormal];
    [myButton setBackgroundImage:[UIImage imageNamed:@"left_btn_pressed"] forState:UIControlStateHighlighted];
    [myButton addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *customItem = [[UIBarButtonItem alloc] initWithCustomView:myButton];
    self.navigationItem.leftBarButtonItem = customItem;
    
    loadingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.width)];
    loadingView.backgroundColor = [UIColor blackColor];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:loadingView.frame];
    imageView.image = [UIImage imageNamed:@"cache_video"];
    [loadingView addSubview:imageView];
    [self.view addSubview:loadingView];
    
    [myHUD showProgressBar:self.view];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerPreloadFinish:) name:MPMoviePlayerContentPreloadDidFinishNotification object:nil];
    
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
    } else {
        [self showWebView];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"error url");
    [connection cancel];
    //如果所有的视频地址都无效，则播放网页地址
    errorUrlNum++;
    if (errorUrlNum >= videoUrls.count) {
        [self showWebView];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    @synchronized(workingUrl){
        if(workingUrl == nil){
            NSLog(@"working = %@", connection.originalRequest.URL);
            workingUrl = connection.originalRequest.URL;
            [self performSelectorOnMainThread:@selector(playVideo) withObject:nil waitUntilDone:NO];
            [connection cancel];
        }
    }
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
        [self.view addSubview:webView];
    } else {
        [UIUtility showPlayVideoFailure:self.view];
    }
}

- (void)playVideo{
    CGRect bound = self.view.bounds;
    playerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:self.workingUrl];
    playerViewController.view.frame = CGRectMake(0, 0, bound.size.width, bound.size.height);
    
    [self.view insertSubview:self.playerViewController.view belowSubview:loadingView];
    
    player = [playerViewController moviePlayer];
    [player prepareToPlay];
    player.useApplicationAudioSession = NO;
    lastPlayTime = (NSNumber*)[[CacheUtility sharedCache]loadFromCache:[NSString stringWithFormat:@"%@_%@", self.prodId, self.subname]];
    [player setInitialPlaybackTime: lastPlayTime.doubleValue];
    [player play];
}

- (void)moviePlayerPreloadFinish:(NSNotification *)theNotification
{
    [self.navigationController setNavigationBarHidden:YES];
    [self closeCacheScreen];
}

- (void)playVideoFinished:(NSNotification *)theNotification//当点击Done按键或者播放完毕时调用此函数
{
    BOOL userClicked = YES;
	lastPlayTime = [NSNumber numberWithDouble:player.currentPlaybackTime];
    NSLog(@"%f", player.duration);
    NSLog(@"%f", lastPlayTime.doubleValue);
    NSLog(@"%f", player.duration - lastPlayTime.doubleValue);
    if((player.duration - lastPlayTime.doubleValue <= 0.1 || lastPlayTime == nil) && player.duration > 0){
        lastPlayTime = [NSNumber numberWithInt:0];
        userClicked = NO;
    }
    [self updateWatchRecord];
    [[CacheUtility sharedCache] putInCache:[NSString stringWithFormat:@"%@_%@", self.prodId, self.subname] result:lastPlayTime];
    [player stop];
    [playerViewController dismissMoviePlayerViewControllerAnimated];
    playerViewController = nil;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    [self dismissViewControllerAnimated:YES completion:^{
        [UIApplication sharedApplication].statusBarHidden = NO;
        if(!userClicked){
            [self.dramaDetailViewControllerDelegate playNextEpisode];
        }
    }];
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
        NSString *tempProdType = @"1";
        NSString *tempUrl = workingUrl.absoluteString;
        if (workingUrl == nil) {
            tempProdType = @"2";
            tempUrl = videoHttpUrl;
        }
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: userId, @"userid", self.prodId, @"prod_id", self.name, @"prod_name", self.subname, @"prod_subname", [NSNumber numberWithInt:self.type], @"prod_type", tempProdType, @"play_type", [NSNumber numberWithInt:playbackTime], @"playback_time", [NSNumber numberWithInt:duration], @"duration", tempUrl, @"video_url", nil];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}

- (void)closeCacheScreen
{
    [myHUD hide];
    [loadingView removeFromSuperview];
    loadingView = nil;
}

@end
