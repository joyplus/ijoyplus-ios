//
//  VideoWebViewController.m
//  yueshipin
//
//  Created by joyplus1 on 13-1-17.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "AvVideoWebViewController.h"
#import "CommonHeader.h"
#import "UIImage+Scale.h"
#import "AVPlayerViewController.h"

@interface AvVideoWebViewController ()

@property (nonatomic, strong)UIWebView *webView;
@property (nonatomic)BOOL appeared;
@property (nonatomic, strong)NSMutableArray *subnameArray;
@end

@implementation AvVideoWebViewController
@synthesize video;
@synthesize webView;
@synthesize videoHttpUrlArray;
@synthesize prodId;
@synthesize playTime;
@synthesize type, currentNum, isDownloaded;
@synthesize appeared;
@synthesize dramaDetailViewControllerDelegate;
@synthesize hasVideoUrls;
@synthesize subnameArray;
@synthesize subname;
@synthesize name;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [webView stopLoading];
    webView = nil;
    video = nil;
    [videoHttpUrlArray removeAllObjects];
    videoHttpUrlArray = nil;
    prodId = nil;
    [videoHttpUrlArray removeAllObjects];
    videoHttpUrlArray = nil;
    name = nil;
    subname = nil;
    subnameArray = nil;
}

- (void)dealloc
{
    [webView stopLoading];
    webView = nil;
    video = nil;
    [videoHttpUrlArray removeAllObjects];
    videoHttpUrlArray = nil;
    prodId = nil;
    [videoHttpUrlArray removeAllObjects];
    videoHttpUrlArray = nil;
    name = nil;
    subname = nil;
    subnameArray = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(BOOL)shouldAutorotate {
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *myButton = [UIButton buttonWithType:UIButtonTypeCustom];
    myButton.frame = CGRectMake(0, 2, 56, 40);
    [myButton setBackgroundImage:[UIImage imageNamed:@"left_btn"] forState:UIControlStateNormal];
    [myButton setBackgroundImage:[UIImage imageNamed:@"left_btn_pressed"] forState:UIControlStateHighlighted];
    [myButton addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *customItem = [[UIBarButtonItem alloc] initWithCustomView:myButton];
    self.navigationItem.leftBarButtonItem = customItem;
    
    if (name == nil) {
        name = [video objectForKey:@"name"];
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        UILabel *t = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 30)];
        t.font = [UIFont boldSystemFontOfSize:18];
        t.textColor = [UIColor whiteColor];
        t.backgroundColor = [UIColor clearColor];
        t.textAlignment = UITextAlignmentCenter;
        t.text = [NSString stringWithFormat:@"%@", name];
        self.navigationItem.titleView = t;        
    }else{
        self.title = [NSString stringWithFormat:@"%@", name];
    }
    [self.navigationController.navigationBar setBackgroundImage:[UIImage scaleFromImage:[UIImage imageNamed:@"top_bg_common.png"] toSize:CGSizeMake(kFullWindowHeight, 44)] forBarMetrics:UIBarMetricsDefault];
    CGRect bound = [UIScreen mainScreen].bounds;
	webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, bound.size.height, bound.size.width)];
    [webView setBackgroundColor:[UIColor clearColor]];
    webView.scalesPageToFit = YES;
    [self hideGradientBackground:webView];
    if (videoHttpUrlArray.count > 0 && currentNum < videoHttpUrlArray.count) {
        NSURL *url = [NSURL URLWithString:[videoHttpUrlArray objectAtIndex:currentNum]];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        [webView loadRequest:requestObj];
    }
    [webView setScalesPageToFit:YES];
    [self.view addSubview:webView];
    
    if (!hasVideoUrls) {
        subnameArray = [[NSMutableArray alloc]initWithCapacity:10];
        for (NSDictionary *oneEpisode in [video objectForKey:@"episodes"]) {
            NSString *tempName = [NSString stringWithFormat:@"%@", [oneEpisode objectForKey:@"name"]];
            [subnameArray addObject:tempName];
        }
        [self updateWatchRecord];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.alpha = 1;
    [self.navigationController setNavigationBarHidden:NO];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        //[[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!appeared) {
        appeared = YES;
        if (hasVideoUrls > 0) {
            UIView *blackView = [[UIView alloc]initWithFrame:self.view.frame];
            blackView.backgroundColor = [UIColor blackColor];
            blackView.alpha = 0;
            [self.view addSubview:blackView];
            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
                self.navigationController.navigationBar.alpha = 0;
                blackView.alpha = 1;
            } completion:^(BOOL finished) {
                [self showMediaPlayer];
                self.navigationController.navigationBar.alpha = 1;
                [blackView removeFromSuperview];
            }];
        }
    }
}

- (void)showMediaPlayer
{
    if (hasVideoUrls) {
        AVPlayerViewController *viewController = [[AVPlayerViewController alloc]init];
        viewController.videoWebViewControllerDelegate = self;
        viewController.currentNum = self.currentNum;
        viewController.video = video;
        viewController.type = self.type;
        viewController.prodId = self.prodId;
        viewController.name = name;
        viewController.lastPlayTime = CMTimeMakeWithSeconds([playTime floatValue], NSEC_PER_SEC);
        viewController.subname = subname;
        if (video == nil) {//如果是从播放历史里来，就关闭网页和视频
            viewController.closeAll = YES;
        }
        [self.navigationController pushViewController:viewController animated:NO];
    }
}

- (void)playNextEpisode:(int)nextEpisodeNum
{
    if (currentNum != nextEpisodeNum) {        
        self.currentNum = nextEpisodeNum;
        if (self.currentNum < videoHttpUrlArray.count) {
            NSURL *url = [NSURL URLWithString:[videoHttpUrlArray objectAtIndex:self.currentNum]];
            NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
            [self.webView loadRequest:requestObj];
        }
        if([self.dramaDetailViewControllerDelegate respondsToSelector:@selector(changePlayingEpisodeBtn:)]){
            [self.dramaDetailViewControllerDelegate changePlayingEpisodeBtn:self.currentNum];
        } else {
            [[CacheUtility sharedCache]putInCache:[NSString stringWithFormat:@"drama_epi_%@", self.prodId] result:[NSNumber numberWithInt:currentNum+1]];
        }
    }
}

- (void)closeSelf
{
    self.dramaDetailViewControllerDelegate = nil;
//    [self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateWatchRecord
{
    if (currentNum < subnameArray.count) {
        subname = [subnameArray objectAtIndex:currentNum];
    }
    NSString *userId = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: userId, @"userid", self.prodId, @"prod_id", [video objectForKey:@"name"], @"prod_name", subname, @"prod_subname", [NSNumber numberWithInt:self.type], @"prod_type", @"2", @"play_type", [NSNumber numberWithInt:0], @"playback_time", [NSNumber numberWithInt:0], @"duration", [videoHttpUrlArray objectAtIndex:self.currentNum], @"video_url", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathAddPlayHistory parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        [[CacheUtility sharedCache] removeObjectForKey:WATCH_RECORD_CACHE_KEY];
        [[NSNotificationCenter defaultCenter] postNotificationName:WATCH_HISTORY_REFRESH object:nil];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"zz%@", error);
    }];
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

@end
