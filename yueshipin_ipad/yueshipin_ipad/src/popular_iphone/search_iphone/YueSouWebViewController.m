//
//  YueSouWebViewController.m
//  yueshipin
//
//  Created by huokun on 13-9-9.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "YueSouWebViewController.h"
#import "CommonHeader.h"
#import "UIImage+Scale.h"

#define YUE_SEARCH_KEY  (@"yueSearch_intro_iPhone")

@interface YueSouWebViewController ()
@property (nonatomic ,strong) NSString * url;
@property (nonatomic, strong) NSString * titleStr;
- (void)showIntroView;
@end

@implementation YueSouWebViewController
@synthesize url,titleStr;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithUrl:(NSString *)turl title:(NSString *)title
{
    if (self = [super init])
    {
        url = turl;
        titleStr = title;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor clearColor];
    
    //self.title = titleStr;
    
    UIButton *myButton = [UIButton buttonWithType:UIButtonTypeCustom];
    myButton.frame = CGRectMake(0, 2, 56, 40);
    [myButton setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [myButton setBackgroundImage:[UIImage imageNamed:@"back_f.png"] forState:UIControlStateHighlighted];
    [myButton addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *customItem = [[UIBarButtonItem alloc] initWithCustomView:myButton];
    self.navigationItem.leftBarButtonItem = customItem;

	webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 320, kCurrentWindowHeight - 44)];
    [webView setBackgroundColor:[UIColor clearColor]];
    [webView setScalesPageToFit:YES];
    webView.delegate = self;
    [self.view addSubview:webView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString * requestUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    self.title = requestUrl;
    NSURL * request = [NSURL URLWithString:requestUrl];
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
        [self.navigationController popViewControllerAnimated:YES];
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
            view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, kFullWindowHeight)];
            view.tag = 3268999;
            [view setBackgroundColor:[UIColor clearColor]];
            
            NSString * imageName = nil;
            if (kFullWindowHeight == 1136)
            {
                imageName = @"iPhone_intro_1136";
            }
            else
            {
                imageName = @"iPhone_intro_960";
            }
            UIImageView *temp = [[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
            temp.frame = view.frame;
            [view addSubview:temp];
            [[AppDelegate instance].tabBarView.view addSubview:view];
        }
        UITapGestureRecognizer *closeModalViewGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeIntroModalView)];
        closeModalViewGesture.numberOfTapsRequired = 1;
        [view addGestureRecognizer:closeModalViewGesture];
    }
}

- (void)removeIntroModalView
{
    UIView *modalView = (UIView *)[[AppDelegate instance].tabBarView.view viewWithTag:3268999];
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
    
    self.title = wView.request.URL.absoluteString;
}

@end
