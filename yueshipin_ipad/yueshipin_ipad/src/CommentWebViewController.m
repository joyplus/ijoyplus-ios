//
//  CommentWebViewController.m
//  yueshipin
//
//  Created by joyplus1 on 13-4-2.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "CommentWebViewController.h"

@interface CommentWebViewController ()

@property (nonatomic, strong)UIWebView *webView;

@end

@implementation CommentWebViewController
@synthesize webView;
@synthesize commentUrl;
@synthesize titleContent;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    webView.delegate = nil;
    [webView stopLoading];
    webView = nil;
    commentUrl = nil;
    titleContent = nil;
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
    
	CGRect bound = [UIScreen mainScreen].bounds;
	webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, bound.size.height, bound.size.width)];
    [webView setBackgroundColor:[UIColor clearColor]];
    webView.scalesPageToFit = YES;
    [self hideGradientBackground:webView];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:[NSURL URLWithString:commentUrl]];
    [webView loadRequest:requestObj];
    [webView setScalesPageToFit:YES];
    [self.view addSubview:webView];
    
    UILabel *t = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 30)];
    t.font = [UIFont boldSystemFontOfSize:18];
    t.textColor = [UIColor whiteColor];
    t.backgroundColor = [UIColor clearColor];
    t.textAlignment = UITextAlignmentCenter;
    t.text = [NSString stringWithFormat:@"%@", titleContent];
    self.navigationItem.titleView = t;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)closeSelf
{
    webView.delegate = nil;
    [webView stopLoading];
    [self dismissViewControllerAnimated:YES completion:nil];
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
