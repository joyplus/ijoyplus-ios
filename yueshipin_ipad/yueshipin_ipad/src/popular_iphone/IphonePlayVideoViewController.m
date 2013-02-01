//
//  IphonePlayVideoViewController.m
//  yueshipin
//
//  Created by 08 on 13-1-29.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "IphonePlayVideoViewController.h"
#import "MyMediaPlayerViewController.h"
@interface IphonePlayVideoViewController ()

@end

@implementation IphonePlayVideoViewController
@synthesize webView = webView_;
@synthesize httpUrlsArr = httpUrlsArr_;
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
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *myButton = [UIButton buttonWithType:UIButtonTypeCustom];
    myButton.frame = CGRectMake(0, 0, 56, 29);
    [myButton setBackgroundImage:[UIImage imageNamed:@"left_btn"] forState:UIControlStateNormal];
    [myButton setBackgroundImage:[UIImage imageNamed:@"left_btn_pressed"] forState:UIControlStateHighlighted];
    [myButton addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *customItem = [[UIBarButtonItem alloc] initWithCustomView:myButton];
    self.navigationItem.leftBarButtonItem = customItem;
    
    CGRect bound = [UIScreen mainScreen].bounds;
	webView_ = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, bound.size.height, bound.size.width-50)];
    webView_.scalesPageToFit = YES;
    NSString *urlStr = [httpUrlsArr_ objectAtIndex:0];
    NSURL *url = [NSURL URLWithString:urlStr];
   // NSURL *url = [NSURL URLWithString:@"http://www.sina.com.cn"];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [webView_ loadRequest:requestObj];
    [self.view addSubview:webView_];
    
     [self performSelector:@selector(showMediaPlayer) withObject:nil afterDelay:0.5];
    
}
-(void)closeSelf{

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.alpha = 1;
    [self.navigationController setNavigationBarHidden:NO];

}

- (void)showMediaPlayer{
  MyMediaPlayerViewController *viewController = [[MyMediaPlayerViewController alloc]init];
  viewController.videoUrls = [NSMutableArray arrayWithObject:[NSString stringWithString:@"http://122.228.96.168/13/49/13/letv-uts/1334565907-None-None-None-None-6170040-294356608-a5a27857c4e424ee1122bfc080909e51-1334565907.mp4?crypt=5b6c260eaa7f2e549&b=2000&gn=860&nc=1&bf=22&p2p=1&video_type=mp4&check=0&tm=1351771200&key=0de26e503be21f316b446a8247a059fb&lgn=letv&proxy=1945014825&cipi=1945093243&tag=mobile&np=1&vtype=mp4&ptype=s1&level=350&t=1351677043&cid=&vid=&sign=mb&dname=mobile"]];
   [self.navigationController pushViewController:viewController animated:NO]; 

}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
