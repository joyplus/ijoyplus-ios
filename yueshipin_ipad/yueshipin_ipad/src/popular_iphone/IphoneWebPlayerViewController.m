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
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"top_bg_common.png"] forBarMetrics:UIBarMetricsDefault];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 40, 30);
    backButton.backgroundColor = [UIColor clearColor];
    [backButton setImage:[UIImage imageNamed:@"top_return_common.png"]forState:UIControlStateNormal];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    [self initDataSource];
    [self initWebView];
    [self initPlayerView];
    [self recordPlayStatics];
}

- (void)recordPlayStatics
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: prodId_, @"prod_id", nameStr_, @"prod_name", [NSString stringWithFormat:@"%d",playNum], @"prod_subname", [NSNumber numberWithInt:videoType_], @"prod_type", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathRecordPlay parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSLog(@"succeed!");
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)viewWillAppear:(BOOL)animated{
 [self.navigationController setNavigationBarHidden:NO animated:NO];

}
-(void)initDataSource{
   NSDictionary *episodesInfo = [episodesArr_ objectAtIndex:playNum];
    webUrl_ = [NSURL URLWithString:[[[episodesInfo objectForKey:@"video_urls"] objectAtIndex:0] objectForKey:@"url"]];
}


-(void)initWebView{
    CGRect bounds = [UIScreen mainScreen].bounds;
    webView_ = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.height, bounds.size.width-20)];
    webView_.scalesPageToFit = YES;
    webView_.delegate = self;
    [webView_ loadRequest:[NSURLRequest requestWithURL:webUrl_]];
    [self.view addSubview:webView_];

}


//UIWebView delegate;
- (void)webViewDidFinishLoad:(UIWebView *)webView{


}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{


}

-(void)initPlayerView{
    IphoneAVPlayerViewController *iphoneAVPlayerViewController = [[IphoneAVPlayerViewController alloc] init];
    iphoneAVPlayerViewController.nameStr = nameStr_;
    iphoneAVPlayerViewController.episodesArr = episodesArr_;
    iphoneAVPlayerViewController.playNum = playNum;
    iphoneAVPlayerViewController.videoType = videoType_;
    iphoneAVPlayerViewController.prodId = prodId_;
    iphoneAVPlayerViewController.webPlayUrl = webUrl_.absoluteString;
    iphoneAVPlayerViewController.lastPlayTime =  CMTimeMakeWithSeconds(playBackTime_.doubleValue, NSEC_PER_SEC);
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
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: userId, @"userid", prodId_, @"prod_id", nameStr_, @"prod_name", [NSString stringWithFormat:@"%d",playNum], @"prod_subname", [NSNumber numberWithInt:videoType_], @"prod_type", tempPlayType, @"play_type", [NSNumber numberWithInt:0], @"playback_time", [NSNumber numberWithInt:0], @"duration", webUrl_, @"video_url", nil];
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
    webView_.delegate = nil;

}
@end
