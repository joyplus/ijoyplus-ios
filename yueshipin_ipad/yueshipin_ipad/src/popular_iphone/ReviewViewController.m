//
//  ReviewViewController.m
//  yueshipin
//
//  Created by 08 on 13-4-7.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "ReviewViewController.h"

@interface ReviewViewController ()

@end

@implementation ReviewViewController
@synthesize reqURL;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    reqURL = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIImageView * topView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_bg_common.png"]];
    topView.frame = CGRectMake(0, 0, 320, 44);
    [self.view addSubview:topView];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(10, 0, 55, 44);
    backButton.backgroundColor = [UIColor clearColor];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"back_f.png"] forState:UIControlStateHighlighted];
    [self.view addSubview:backButton];
    
    UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320,44)];
    title.textColor = [UIColor whiteColor];
    title.backgroundColor = [UIColor clearColor];
    title.textAlignment = UITextAlignmentCenter;
    title.text = @"更多影评";
    title.font = [UIFont boldSystemFontOfSize:16];
    [self.view addSubview:title];
    
    CGRect bounds = [UIScreen mainScreen].bounds;
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44, 320, bounds.size.height-64)];
    _webView.scalesPageToFit = YES;
    [self.view addSubview:_webView];
    NSString * url = [NSString stringWithFormat:@"http://movie.douban.com/subject/%@/reviews",reqURL];
    NSURL * requestURL = [NSURL URLWithString:url];
    [_webView loadRequest:[NSURLRequest requestWithURL:requestURL]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
    
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    
    return UIInterfaceOrientationPortrait;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
