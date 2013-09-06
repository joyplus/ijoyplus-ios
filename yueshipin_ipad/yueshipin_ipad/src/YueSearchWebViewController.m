//
//  YueSearchWebViewController.m
//  yueshipin
//
//  Created by huokun on 13-9-6.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "YueSearchWebViewController.h"
#import "CommonHeader.h"
#import "UIImage+Scale.h"

#define YUE_SEARCH_KEY  (@"yueSearch_intro")

@interface YueSearchWebViewController ()
@property (nonatomic ,strong) NSString * url;
- (void)showIntroView;
@end

@implementation YueSearchWebViewController
@synthesize url;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithUrl:(NSString *)turl
{
    if (self = [super init])
    {
        url = turl;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor clearColor];
    
    UIButton *myButton = [UIButton buttonWithType:UIButtonTypeCustom];
    myButton.frame = CGRectMake(0, 2, 56, 40);
    [myButton setBackgroundImage:[UIImage imageNamed:@"yueWeb_back"] forState:UIControlStateNormal];
    [myButton setBackgroundImage:[UIImage imageNamed:@"yueWeb_back_f"] forState:UIControlStateHighlighted];
    [myButton addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *customItem = [[UIBarButtonItem alloc] initWithCustomView:myButton];
    self.navigationItem.leftBarButtonItem = customItem;
    
    UILabel *t = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 800, 30)];
    t.font = [UIFont boldSystemFontOfSize:18];
    t.textColor = [UIColor whiteColor];
    t.backgroundColor = [UIColor clearColor];
    t.textAlignment = UITextAlignmentCenter;
    t.text = url;
    self.navigationItem.titleView = t;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage scaleFromImage:[UIImage imageNamed:@"top_bg_common.png"] toSize:CGSizeMake(kFullWindowHeight, 44)]
                                                  forBarMetrics:UIBarMetricsDefault];
    
    CGRect bound = [UIScreen mainScreen].bounds;
	webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, bound.size.height, bound.size.width - 64)];
    [webView setBackgroundColor:[UIColor clearColor]];
    [webView setScalesPageToFit:YES];
    webView.delegate = self;
    [self.view addSubview:webView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSURL * request = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //NSURL * request = [[NSURL alloc] initWithString:url];
    [webView loadRequest:[NSURLRequest requestWithURL:request]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)closeSelf
{
    if (webView.canGoBack)
    {
        [webView goBack];
    }
    else
    {
        webView.delegate = nil;
        [webView stopLoading];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)showIntroView
{
    NSString *newKey = [NSString stringWithFormat:@"%@_%@", VERSION, YUE_SEARCH_KEY];
    NSString *showMenuIntro = [NSString stringWithFormat:@"%@", [[ContainerUtility sharedInstance] attributeForKey:newKey]];
    if (![showMenuIntro isEqualToString:@"1"]) {
        [[ContainerUtility sharedInstance] setAttribute:@"1" forKey:newKey];
        UIView *view = [self.view viewWithTag:3268999];
        if (view == nil) {
            view = [[UIView alloc]initWithFrame:CGRectMake(0, -10, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width + 10)];
            view.tag = 3268999;
            [view setBackgroundColor:[UIColor clearColor]];
            UIImageView *temp = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Yue_Search_Intro"]];
            temp.frame = view.frame;
            [view addSubview:temp];
            [self.view addSubview:view];
        }
        UITapGestureRecognizer *closeModalViewGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeIntroModalView)];
        closeModalViewGesture.numberOfTapsRequired = 1;
        [view addGestureRecognizer:closeModalViewGesture];
    }
}

- (void)removeIntroModalView
{
    UIView *modalView = (UIView *)[self.view viewWithTag:3268999];
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
        for (UIView *subview in modalView.subviews) {
            [subview setAlpha:0];
        }
        [modalView setAlpha:0];
    } completion:^(BOOL finished) {
        [modalView removeFromSuperview];
    }];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)wView
{
    if (wView.canGoBack)
    {
        [self showIntroView];
    }
    UILabel * text = (UILabel *)self.navigationItem.titleView;
    text.text = wView.request.URL.absoluteString;
}

@end
