//
//  IphoneWebPlayerViewController.m
//  yueshipin
//
//  Created by 08 on 13-2-28.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "IphoneWebPlayerViewController.h"
#import "IphoneAVPlayerViewController.h"
#import "UIImage+Scale.h"
#import "CMConstants.h"
#import "ContainerUtility.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "AppDelegate.h"
#import "CommonMotheds.h"
@interface IphoneWebPlayerViewController ()

@end

@implementation IphoneWebPlayerViewController
@synthesize episodesArr = episodesArr_;
@synthesize webUrl = webUrl_;
@synthesize webView = webView_;
@synthesize nameStr = nameStr_;
@synthesize playNum ;
@synthesize videoType = videoType_;
@synthesize prodId = prodId_;
@synthesize playBackTime = playBackTime_;
@synthesize webUrlSource = webUrlSource_;
@synthesize subnameArray;
@synthesize isPlayFromRecord = isPlayFromRecord_;
@synthesize continuePlayInfo = continuePlayInfo_;
@synthesize hasVideoUrl = hasVideoUrl_;
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
    self.title = nameStr_;
    [self.navigationController.navigationBar setBackgroundImage:IPHONE_TOP_NAVIGATIONBAR_BG forBarMetrics:UIBarMetricsDefault];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 49, 30);
    backButton.backgroundColor = [UIColor clearColor];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"back_f.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    if (!isPlayFromRecord_) {
         [self initDataSource];
    }
   
    //[self initWebView];
    if ([[AppDelegate instance].showVideoSwitch isEqualToString:@"2"]) {
        [[UIApplication sharedApplication] openURL:webUrl_];
        return;
    } else if([[AppDelegate instance].showVideoSwitch isEqualToString:@"0"]) {
        [self initPlayerView];

        [AppDelegate instance].isInPlayView = YES;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(initWebView:)
                                                 name:@"addWebView"
                                               object:nil];
    } else if([[AppDelegate instance].showVideoSwitch isEqualToString:@"1"]||[[AppDelegate instance].showVideoSwitch isEqualToString:@"3"]) {
        [self initWebView:nil];
    }

    
}


-(void)viewWillAppear:(BOOL)animated{
 [self.navigationController setNavigationBarHidden:NO animated:NO];

}

-(void)initDataSource{
   NSDictionary *episodesInfo = [episodesArr_ objectAtIndex:playNum];
    NSDictionary *oneEpisodeInfo = [[episodesInfo objectForKey:@"video_urls"] objectAtIndex:0];
    webUrlSource_ =[oneEpisodeInfo objectForKey:@"source"];
    webUrl_ = [NSURL URLWithString:[oneEpisodeInfo objectForKey:@"url"]];
}


-(void)initWebView:(NSNotification *)notfication{
    CGRect bounds = [UIScreen mainScreen].bounds;
    webView_ = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.height, bounds.size.width-32)];
    webView_.scalesPageToFit = YES;
    webView_.delegate = self;
    if (notfication) {
        NSDictionary *userInfo = notfication.userInfo;
        BOOL fromBaidu = ((NSNumber *)[userInfo objectForKey:@"fromBaidu"]).boolValue;
        if (fromBaidu) {
            NSString *boundle = [[NSBundle mainBundle] resourcePath];
            webView_.scrollView.scrollEnabled = NO;
            webView_.backgroundColor = [UIColor colorWithRed:218/255.0 green:218/255.0 blue:218/255.0 alpha:1];
            if ([CommonMotheds isIphone5]) {
                [webView_ loadHTMLString:[NSString stringWithFormat:@"<body bgcolor='#dadada'><img src='404iphone5.jpg'/></body>"] baseURL:[NSURL fileURLWithPath:boundle]];
            } else {
                [webView_ loadHTMLString:[NSString stringWithFormat:@"<body bgcolor='#dadada'><img src='404iphone4.jpg'/></body>"] baseURL:[NSURL fileURLWithPath:boundle]];
            }
        } else {
            [webView_ loadRequest:[NSURLRequest requestWithURL:webUrl_]];
        }
    } else {
        [webView_ loadRequest:[NSURLRequest requestWithURL:webUrl_]];
    }
    [self.view addSubview:webView_];
}


//UIWebView delegate;
- (void)webViewDidFinishLoad:(UIWebView *)webView{


}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{


}

-(void)initPlayerView{
   
    IphoneAVPlayerViewController *iphoneAVPlayerViewController = [[IphoneAVPlayerViewController alloc] init];
    
    if (!isPlayFromRecord_) {
        iphoneAVPlayerViewController.nameStr = nameStr_;
        iphoneAVPlayerViewController.episodesArr = episodesArr_;
        iphoneAVPlayerViewController.playNum = playNum;
        if (nil == subnameArray)
        {
            subnameArray = [[NSMutableArray alloc] init];
        }
        for (NSDictionary * dic in  episodesArr_)
        {
            [subnameArray addObject:[dic objectForKey:@"name"]];
        }
        iphoneAVPlayerViewController.subnameArray = subnameArray;
        
        iphoneAVPlayerViewController.lastPlayTime =  CMTimeMakeWithSeconds(playBackTime_.doubleValue, NSEC_PER_SEC);
        iphoneAVPlayerViewController.webPlayUrl = webUrl_.absoluteString;
        iphoneAVPlayerViewController.webUrlSource = webUrlSource_;
    }
    else
    {
        NSNumber *playBackTime = (NSNumber *)[continuePlayInfo_ objectForKey:@"playback_time"];
        iphoneAVPlayerViewController.lastPlayTime = CMTimeMakeWithSeconds(playBackTime.doubleValue, NSEC_PER_SEC);
    }
    
    iphoneAVPlayerViewController.videoType = videoType_;
    iphoneAVPlayerViewController.prodId = prodId_;
    iphoneAVPlayerViewController.continuePlayInfo = continuePlayInfo_;
    iphoneAVPlayerViewController.isPlayFromRecord = isPlayFromRecord_;
    [self.navigationController pushViewController:iphoneAVPlayerViewController animated:NO];
}

-(void)back:(id)sender{
    [self updateWatchRecord];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateWatchRecord
{
    NSString *userId = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId];
    NSString *tempPlayType = @"2";
    NSString *subname = [NSString stringWithFormat:@"%d",(playNum+1)];
    if (nil == subnameArray)
    {
        subnameArray = [[NSMutableArray alloc] init];
    }
    else{
        [subnameArray removeAllObjects];
    }
    for (NSDictionary * dic in  episodesArr_){
        [subnameArray addObject:[dic objectForKey:@"name"]];
    }
    if (videoType_ != 1 && playNum < subnameArray.count) {
        subname = [subnameArray objectAtIndex:playNum];
    }
    NSNumber *duration = [NSNumber numberWithInt:0];
    if (!hasVideoUrl_) {
        duration = [NSNumber numberWithInt:-2];
    }
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: userId, @"userid", prodId_, @"prod_id", nameStr_, @"prod_name", subname, @"prod_subname", [NSNumber numberWithInt:videoType_], @"prod_type", tempPlayType, @"play_type", [NSNumber numberWithInt:0], @"playback_time", duration, @"duration", webUrl_, @"video_url", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathAddPlayHistory parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        [[NSNotificationCenter defaultCenter] postNotificationName:WATCH_HISTORY_REFRESH object:nil];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == /*UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == */UIInterfaceOrientationLandscapeRight;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:@"addWebView"
                                                 object:nil];
    [AppDelegate instance].isInPlayView = NO;
    webView_.delegate = nil;
    [subnameArray removeAllObjects];
    subnameArray = nil;
    
}
@end
