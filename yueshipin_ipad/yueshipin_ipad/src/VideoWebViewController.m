//
//  VideoWebViewController.m
//  yueshipin
//
//  Created by joyplus1 on 13-1-17.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "VideoWebViewController.h"
#import "MyMediaPlayerViewController.h"
#import "CommonHeader.h"

@interface VideoWebViewController ()

@property (nonatomic, strong)UIWebView *webView;
@property (nonatomic)int currentNum;
@property (nonatomic)BOOL appeared;
@end

@implementation VideoWebViewController
@synthesize video;
@synthesize webView;
@synthesize videoHttpUrlArray;
@synthesize name;
@synthesize prodId;
@synthesize subname;
@synthesize type, currentNum, isDownloaded, startNum;
@synthesize appeared;
@synthesize videoUrlsArray;
@synthesize dramaDetailViewControllerDelegate;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    webView = nil;
    video = nil;
    [videoHttpUrlArray removeAllObjects];
    videoHttpUrlArray = nil;
    name = nil;
    prodId = nil;
    subname = nil;
    [videoHttpUrlArray removeAllObjects];
    videoHttpUrlArray = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
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
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *myButton = [UIButton buttonWithType:UIButtonTypeCustom];
    myButton.frame = CGRectMake(0, 0, 56, 29);
    [myButton setBackgroundImage:[UIImage imageNamed:@"left_btn"] forState:UIControlStateNormal];
    [myButton setBackgroundImage:[UIImage imageNamed:@"left_btn_pressed"] forState:UIControlStateHighlighted];
    [myButton addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *customItem = [[UIBarButtonItem alloc] initWithCustomView:myButton];
    self.navigationItem.leftBarButtonItem = customItem;
    
    UILabel *t = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 30)];
    t.font = [UIFont boldSystemFontOfSize:18];
    t.textColor = [UIColor whiteColor];
    t.backgroundColor = [UIColor clearColor];
    t.textAlignment = UITextAlignmentCenter;
    t.text = self.name;
    self.navigationItem.titleView = t;
    
    CGRect bound = [UIScreen mainScreen].bounds;
	webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, bound.size.height, bound.size.width)];
    [webView setBackgroundColor:[UIColor clearColor]];
    [self hideGradientBackground:webView];
    NSURL *url = [NSURL URLWithString:[videoHttpUrlArray objectAtIndex:0]];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [webView loadRequest:requestObj];
    [webView setScalesPageToFit:YES];
    [self.view addSubview:webView];
    
    [self updateWatchRecord];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.alpha = 1;
    [self.navigationController setNavigationBarHidden:NO];
    if (!appeared) {
        appeared = YES;
        if (self.videoUrlsArray.count > 0) {
            [self performSelector:@selector(showMediaPlayer) withObject:nil afterDelay:0.5];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)showMediaPlayer
{
    if (self.currentNum < self.videoUrlsArray.count) {
        NSArray *tempVideoUrlsArray = [self.videoUrlsArray objectAtIndex:self.currentNum];
        if(tempVideoUrlsArray.count > 0){
            MyMediaPlayerViewController *viewController = [[MyMediaPlayerViewController alloc]init];
            viewController.currentNum = self.currentNum;
            viewController.videoUrls = [self.videoUrlsArray objectAtIndex:self.currentNum];
            viewController.videoHttpUrl = [self.videoHttpUrlArray objectAtIndex:self.currentNum];
            viewController.prodId = self.prodId;
            viewController.videoWebViewControllerDelegate = self;
            viewController.type = self.type;
            viewController.name = [self.video objectForKey:@"name"];
            viewController.subname = self.subname;
            viewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
            [self.navigationController pushViewController:viewController animated:NO];
        }
    }
}

- (void)playNextEpisode:(int)nextEpisodeNum
{
    self.currentNum = nextEpisodeNum;
    if (self.currentNum < self.videoUrlsArray.count){
        NSURL *url = [NSURL URLWithString:[videoHttpUrlArray objectAtIndex:self.currentNum]];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:requestObj];
        if([self.dramaDetailViewControllerDelegate respondsToSelector:@selector(changePlayingEpisodeBtn:)]){
            [self.dramaDetailViewControllerDelegate changePlayingEpisodeBtn:self.startNum + self.currentNum];
        }
        [self showMediaPlayer];
    }
}

- (void)closeSelf
{
    [self dismissModalViewControllerAnimated:NO];
}

- (void)updateWatchRecord
{
    if (self.currentNum < self.videoUrlsArray.count) {
        self.subname = self.subname == nil ? @"" : self.subname;
        NSString *userId = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId];
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: userId, @"userid", self.prodId, @"prod_id", self.name, @"prod_name", self.subname, @"prod_subname", [NSNumber numberWithInt:self.type], @"prod_type", @"2", @"play_type", [NSNumber numberWithInt:0], @"playback_time", [NSNumber numberWithInt:0], @"duration", [videoHttpUrlArray objectAtIndex:self.currentNum], @"video_url", nil];
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

@end
