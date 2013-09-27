//
//  ScanDetailViewController.m
//  yueshipin
//
//  Created by lily on 13-7-10.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "ScanDetailViewController.h"
#import "ScanViewController.h"
#import "CMConstants.h"
#import "IpadBunDingViewController.h"
#import "PopularTopViewController.h"
@interface ScanDetailViewController ()

@end

@implementation ScanDetailViewController
@synthesize isBunding = isBunding_;
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
    self.title = @"扫一扫";
    
    NSString * bgName = @"nav_bar_bg_44";
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
    {
        [self setNeedsStatusBarAppearanceUpdate];
        bgName = @"nav_bar_bg_44";
    }
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:bgName] forBarMetrics:UIBarMetricsDefault];
    
    self.view.backgroundColor = [UIColor clearColor];
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, 55, 44);
    leftButton.backgroundColor = [UIColor clearColor];
    [leftButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage imageNamed:@"back_f.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    [self initLeftView];
    [self initRightView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ZBarHasReader:) name:ZBarReader object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(back) name:CLOSE object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
   PopularTopViewController *root = (PopularTopViewController *)[self.navigationController presentingViewController];
    [root viewWillAppear:YES];
}
-  (void)initLeftView{

    
    UIImageView * scanView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"saoyisao.png"]];
    scanView.frame = CGRectMake(0, -44 ,516,750);
    scanView.backgroundColor = [UIColor clearColor];

    if (isBunding_) {
        ipadBundingView = [[IpadBunDingViewController alloc] init];
        ipadBundingView.view.frame = CGRectMake(80, 0, 260,1024);
        [self.view addSubview:ipadBundingView.view];
    }
    else{
        ScanViewController * reader = [[ScanViewController alloc] init];
        reader.supportedOrientationsMask = ZBarOrientationMask(UIDeviceOrientationLandscapeRight);
        reader.showsZBarControls = NO;
        reader.showsHelpOnFail = NO;
        reader.showsCameraControls = NO;
        reader.cameraOverlayView = scanView;
        ZBarImageScanner *scanner = reader.scanner;
        [scanner setSymbology: ZBAR_I25
                       config: ZBAR_CFG_ENABLE
                           to: 0];
        reader.view.frame = CGRectMake(80, 0, 240,1024);
        reader.view.tag = 19999;
        [self.view addSubview:reader.view];
    }
    
    
}

-(void)initRightView{
    
    NSInteger x = 0;
    NSInteger y = 0;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
    {
        x = 44;
        y = 20;
    }
    
    UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ipad_scan_intro.png"]];
    imageview.frame = CGRectMake(1024-429 -y, x, 429 + y, 705);
    [self.view addSubview:imageview];
    
}
-(void)back{
    [self dismissModalViewControllerAnimated:YES];
}

-(void)ZBarHasReader:(NSNotification *)notify{
    UIView *view = [self.view viewWithTag:19999];
//    UIView *newView = [[UIView alloc] initWithFrame:view.frame];
//    newView.backgroundColor = [UIColor redColor];
//    [self.view addSubview:newView];
//    [view removeFromSuperview];
    if (ipadBundingView == nil) {
        ipadBundingView = [[IpadBunDingViewController alloc] init];
    }
    ipadBundingView.showBunding = YES;
    ipadBundingView.strData = (NSString *)notify.object;
    ipadBundingView.view.frame = view.frame;
    [self.view addSubview:ipadBundingView.view];
    
    [view removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#ifdef __IPHONE_7_0
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleBlackOpaque;
}
#endif
@end
