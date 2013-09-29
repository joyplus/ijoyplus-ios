//
//  FeedController.m
//  DDMenuController
//
//  Created by Devin Doty on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HomeViewController.h"
#import "CommonHeader.h"
#import "GroupImageViewController.h"
#import "MusicListViewController.h"
#import "VideoGridViewController.h"
#import "MusicListViewController.h"
#import "BrowserViewController.h"
#import "AppListViewController.h"
#import "SettingsViewController.h"
#import "BaseUINavigationController.h"
#import "RemoteViewController.h"
#import "KeyboardRemoateViewController.h"
#import "JSONKit.h"
#import "FPPopoverController.h"
#import "DeviceListViewController.h"
#import "PlayMusicViewController.h"
#import "PlayVideoViewController.h"
#import "CustomNavigationViewController.h"

#define PIC_BUTTON_TAG 1001
#define MUSIC_BUTTON_TAG 1002
#define VIDEO_BUTTON_TAG 1003
#define APP_BUTTON_TAG 1004
#define JOYPLUS_BUTTON_TAG 1005
#define TV_BUTTON_TAG 1006
#define DEVICE_VIEW_TAG 3001
#define DEVICE_TIP_TAG 3002
#define DEVICE_BTN_TAG 3003
#define HUD_TAG 3004

#define LEFT_MARGIN 8
#define ROW_MIDDLE_MARGIN 5

@interface HomeViewController () <FPPopoverControllerDelegate>

@property (nonatomic, strong) NSDictionary *yueshipinApp;
@property (nonatomic, strong) NSDictionary *tvApp;
@property (nonatomic, strong) DeviceListViewController *controller;
@property (nonatomic, strong) FPPopoverController *popover;
@property (nonatomic) BOOL popupDisplay;

@end

@implementation HomeViewController
@synthesize yueshipinApp;
@synthesize tvApp;
@synthesize controller;
@synthesize popover;
@synthesize popupDisplay;

- (id)init {
    if ((self = [super init])) {
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#ifdef __IPHONE_6_0
- (BOOL)shouldAutorotate
{
    return NO;
}
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
#else

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#endif
#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeServerTip:) name:DONGLE_IS_CONNECTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDeviceList:) name:SHOW_DEVICE_LIST object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDeviceList:) name:RELOAD_DEVICE_LIST object:nil];

    yueshipinApp = [NSDictionary dictionaryWithObjectsAndKeys:@"com.joyplus.tv.Main", @"className", @"1", @"firstInstallTime", @"0", @"flags", @"com.joyplus.tv", @"packegeName", nil];
    tvApp = [NSDictionary dictionaryWithObjectsAndKeys:@"xlcao.sohutv4.ui.MeleTVMainActivity", @"className", @"1", @"firstInstallTime", @"0", @"flags", @"xlcao.sohutv4", @"packegeName", nil];
    
    [self addMenuView:0];
    [self addContententView:0];
    [self showNavigationBar:[CommonMethod appName]];
    [self showMenuBtn];
    
    UIView *deviceView = [[UIView alloc]initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT+5, self.view.bounds.size.width, 30)];
    deviceView.tag = DEVICE_VIEW_TAG;
    deviceView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"info_bg"]];
    [self addInContentView:deviceView];
    
    UIButton *deviceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deviceBtn.frame = CGRectMake(0, 0, deviceView.frame.size.width, deviceView.frame.size.height);
    deviceBtn.tag = DEVICE_BTN_TAG;
    [deviceBtn setHidden:YES];
    [deviceBtn addTarget:self action:@selector(deviceBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [deviceView addSubview:deviceBtn];
    
    UIImageView *deviceIcon = [[UIImageView alloc]initWithFrame:CGRectMake(18, 0, 20, 15)];
    deviceIcon.center = CGPointMake(deviceIcon.center.x, deviceView.frame.size.height/2);
    deviceIcon.image = [UIImage imageNamed:@"icon_device"];
    [deviceView addSubview:deviceIcon];
    
    UILabel *deviceTip = [[UILabel alloc]initWithFrame:CGRectMake(deviceIcon.frame.origin.x + deviceIcon.frame.size.width + 5, 0, 210, deviceView.frame.size.height)];
    deviceTip.tag = DEVICE_TIP_TAG;
    deviceTip.text = @"正在查找可用设备";
    deviceTip.textColor = CMConstants.textColor;
    deviceTip.backgroundColor = [UIColor clearColor];
    deviceTip.font = [UIFont systemFontOfSize:14];
    [deviceView addSubview:deviceTip];
    
    MBProgressHUD *HUD = (MBProgressHUD *)[deviceView viewWithTag:HUD_TAG];
    if (HUD == nil) {
        HUD = [[MBProgressHUD alloc] initWithView:deviceView];
        HUD.xOffset = 10;
        ((UIActivityIndicatorView *)HUD.indicator).activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;// = CGRectMake(HUD.frame.origin.x, HUD.frame.origin.y, 30, 30);
        [deviceView addSubview:HUD];
        HUD.tag = HUD_TAG;
        HUD.opacity = 0;
    }
    [HUD show:YES];
    
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, deviceView.frame.origin.y + deviceView.frame.size.height+1, self.view.bounds.size.width, 568)];
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height + 88);
    [self addInContentView:scrollView];
    if ([CommonMethod isIphone5]) {
        [scrollView setScrollEnabled:NO];
    } 
    
//    UIButton *picBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    picBtn.frame = CGRectMake(LEFT_MARGIN, 0, 149, 139);
//    picBtn.tag = PIC_BUTTON_TAG;
//    [picBtn setBackgroundImage:[UIImage imageNamed:@"icon_picture"] forState:UIControlStateNormal];
//    [picBtn setBackgroundImage:[UIImage imageNamed:@"icon_picture_active"] forState:UIControlStateHighlighted];
//    [picBtn addTarget:self action:@selector(iconBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [scrollView addSubview:picBtn];
    
    UIButton *musicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    musicBtn.frame = CGRectMake(LEFT_MARGIN, 0, 149, 139);    musicBtn.tag = MUSIC_BUTTON_TAG;
    [musicBtn setBackgroundImage:[UIImage imageNamed:@"icon_music"] forState:UIControlStateNormal];
    [musicBtn setBackgroundImage:[UIImage imageNamed:@"icon_music_active"] forState:UIControlStateHighlighted];
    [musicBtn addTarget:self action:@selector(iconBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:musicBtn];
    
    UIButton *videoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    videoBtn.frame = CGRectMake(LEFT_MARGIN + musicBtn.frame.size.width + ROW_MIDDLE_MARGIN, musicBtn.frame.origin.y, 149, 139);
    videoBtn.tag = VIDEO_BUTTON_TAG;
    [videoBtn setBackgroundImage:[UIImage imageNamed:@"icon_video"] forState:UIControlStateNormal];
    [videoBtn setBackgroundImage:[UIImage imageNamed:@"icon_video_active"] forState:UIControlStateHighlighted];
    [videoBtn addTarget:self action:@selector(iconBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:videoBtn];
    
    UIButton *joyplusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    joyplusBtn.frame = CGRectMake(LEFT_MARGIN, musicBtn.frame.origin.y + musicBtn.frame.size.height, 149, 139);    
    joyplusBtn.tag = JOYPLUS_BUTTON_TAG;
    [joyplusBtn setBackgroundImage:[UIImage imageNamed:@"icon_joyplus"] forState:UIControlStateNormal];
    [joyplusBtn setBackgroundImage:[UIImage imageNamed:@"icon_joyplus_active"] forState:UIControlStateHighlighted];
    [joyplusBtn addTarget:self action:@selector(iconBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:joyplusBtn];
    
    UIButton *tvBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tvBtn.frame = CGRectMake(LEFT_MARGIN + musicBtn.frame.size.width + ROW_MIDDLE_MARGIN, musicBtn.frame.origin.y + musicBtn.frame.size.height, 149, 139);
    tvBtn.tag = TV_BUTTON_TAG;
    [tvBtn setBackgroundImage:[UIImage imageNamed:@"icon_tv"] forState:UIControlStateNormal];
    [tvBtn setBackgroundImage:[UIImage imageNamed:@"icon_tv_active"] forState:UIControlStateHighlighted];
    [tvBtn addTarget:self action:@selector(iconBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:tvBtn];
    
    UIButton *appBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    appBtn.frame = CGRectMake(LEFT_MARGIN, joyplusBtn.frame.origin.y + videoBtn.frame.size.height, 149, 139);
    appBtn.tag = APP_BUTTON_TAG;
    [appBtn setBackgroundImage:[UIImage imageNamed:@"icon_app"] forState:UIControlStateNormal];
    [appBtn setBackgroundImage:[UIImage imageNamed:@"icon_app_active"] forState:UIControlStateHighlighted];
    [appBtn addTarget:self action:@selector(iconBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:appBtn];
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    UIView *deviceView = (UIView *)[self.view viewWithTag:DEVICE_VIEW_TAG];
//    UILabel *deviceTip = (UILabel *)[deviceView viewWithTag:DEVICE_TIP_TAG];
//    if ([AppDelegate instance].moviePlayer.airPlayVideoActive) {
//        deviceTip.text = @"正在传送视频...";
//    } else if (![AppDelegate instance].moviePlayer.airPlayVideoActive && [CommonMethod isAirPlayActive]){
//        deviceTip.text = @"正在传送音乐...";
//    }
//}

- (void)changeServerTip:(NSNotification *)notification
{
    BOOL connected = [((NSNumber *)notification.object) boolValue];
    UIView *deviceView = (UIView *)[self.view viewWithTag:DEVICE_VIEW_TAG];
    UILabel *deviceTip = (UILabel *)[deviceView viewWithTag:DEVICE_TIP_TAG];
    UIButton *deviceBtn = (UIButton *)[deviceView viewWithTag:DEVICE_BTN_TAG];
    [deviceBtn setHidden:NO];
    if (connected) {
        deviceTip.text = [NSString stringWithFormat:@"已连接到设备: %@", [AppDelegate instance].dongleServerName];
        MBProgressHUD *HUD = (MBProgressHUD *)[deviceView viewWithTag:HUD_TAG];
        [HUD hide:YES];
    } else {
        if([AppDelegate instance].CLIENT_CONNECT_INDEX >= MAX_CHECK_SERVER_STATE_RETRY_TIMES){
            //连接中断了
            deviceTip.text = @"连接已中断, 点击刷新";
            [deviceBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
        } else {
            //通知没有连上；
            deviceTip.text = @"没有找到可用设备, 点击刷新";
            MBProgressHUD *HUD = (MBProgressHUD *)[deviceView viewWithTag:HUD_TAG];
            [HUD hide:YES];
        }
    }
}

- (void)deviceBtnClicked:(UIButton *)btn
{
    UIView *deviceView = (UIView *)[self.view viewWithTag:DEVICE_VIEW_TAG];
    UILabel *deviceTip = (UILabel *)[deviceView viewWithTag:DEVICE_TIP_TAG];
//    if ([AppDelegate instance].moviePlayer.airPlayVideoActive) {
//        PlayVideoViewController *viewController = [[PlayVideoViewController alloc]init];
//        viewController.media = [AppDelegate instance].videoMedia;
//        viewController.playList = nil;
//        CustomNavigationViewController *navViewController = [[CustomNavigationViewController alloc]initWithRootViewController:viewController];
//        [self presentViewController:navViewController animated:YES completion:nil];
//    } else if (![AppDelegate instance].moviePlayer.airPlayVideoActive && [CommonMethod isAirPlayActive]){
//        PlayMusicViewController *viewController = [[PlayMusicViewController alloc]init];
//        NSArray *items = [NSArray arrayWithObject:[AppDelegate instance].musicMedia];
//        viewController.mediaArray = items;
//        viewController.startIndex = 0;
//        BaseUINavigationController *navViewController = [[BaseUINavigationController alloc]initWithRootViewController:viewController];
//        [self presentViewController:navViewController animated:YES completion:nil];
//    } else {
//    }
    UIButton *deviceBtn = (UIButton *)[deviceView viewWithTag:DEVICE_BTN_TAG];
    [deviceBtn setHidden:YES];
    deviceTip.text = @"正在查找可用设备";
    MBProgressHUD *HUD = (MBProgressHUD *)[deviceView viewWithTag:HUD_TAG];
    [HUD show:YES];
    [[AppDelegate instance] reconnectDongle];
}

- (void)showDeviceList:(NSNotification *)notification
{
    NSArray *serverArray = notification.object;
    if (serverArray.count > 1) {
        if (controller == nil) {
            popupDisplay = YES;
            controller = [[DeviceListViewController alloc] init];
            controller.serverArray = serverArray;
            controller.delegate = self;
            popover = [[FPPopoverController alloc] initWithViewController:controller];
            popover.delegate = self;
            popover.contentSize = CGSizeMake(255, 200);
            popover.tint = FPPopoverDefaultTint;
            popover.arrowDirection = FPPopoverArrowDirectionAny;
            UIView *deviceView = (UIView *)[self.view viewWithTag:DEVICE_VIEW_TAG];
            [popover presentPopoverFromView:deviceView];
        } else{
            if (popupDisplay) {
                controller.serverArray = serverArray;
                [controller.table reloadData];
            } else {
                popupDisplay = YES;
                UIView *deviceView = (UIView *)[self.view viewWithTag:DEVICE_VIEW_TAG];
                [popover presentPopoverFromView:deviceView];
            }
        }
    }
}

- (void)reloadDeviceList:(NSNotification *)notification
{
    NSArray *serverArray = notification.object;
    if (serverArray.count > 0 && controller) {
        [controller.table reloadData];
    }
}

- (void)iconBtnClicked:(UIButton *)btn
{
    switch (btn.tag) {
        case PIC_BUTTON_TAG:
        {
            GroupImageViewController *viewController = [[GroupImageViewController alloc]init];
            viewController.homeDelegate = self;
            [self presentViewController:[[BaseUINavigationController alloc]initWithRootViewController:viewController] animated:YES completion:nil];
            break;
        }
        case MUSIC_BUTTON_TAG:
        {
            MusicListViewController *viewController = [[MusicListViewController alloc]init];
            viewController.homeDelegate = self;
            [self presentViewController:[[BaseUINavigationController alloc]initWithRootViewController:viewController] animated:YES completion:nil];
            break;
        }
        case VIDEO_BUTTON_TAG:
        {
            VideoGridViewController *viewController = [[VideoGridViewController alloc]init];
            viewController.homeDelegate = self;
            [self presentViewController:[[BaseUINavigationController alloc]initWithRootViewController:viewController] animated:YES completion:nil];
            break;
        }
        case APP_BUTTON_TAG:
        {
            if(![self serverIsConnected]) return;
            AppListViewController *viewController = [[AppListViewController alloc]init];
            [self presentViewController:[[BaseUINavigationController alloc]initWithRootViewController:viewController] animated:YES completion:nil];
            break;
        }
        case JOYPLUS_BUTTON_TAG:
        {
            if(![self serverIsConnected]) return;
            if ([yueshipinApp isEqualToDictionary:[AppDelegate instance].lastApp]) {
                NSLog(@"The app is started already!");
            } else {
                [[AppDelegate instance] closePreviousApp];
                [[AppDelegate instance] startNewApp:yueshipinApp];
            }
            RemoteViewController *viewController = [[KeyboardRemoateViewController alloc]init];
            [self presentViewController:viewController animated:YES completion:nil];
            break;
        }
        case TV_BUTTON_TAG:
        {
            if(![self serverIsConnected]) return;
            if ([tvApp isEqualToDictionary:[AppDelegate instance].lastApp]) {
                NSLog(@"The app is started already!");
            } else {
                [[AppDelegate instance] closePreviousApp];
                [[AppDelegate instance] startNewApp:tvApp];
            }
            RemoteViewController *viewController = [[KeyboardRemoateViewController alloc]init];
            [self presentViewController:viewController animated:YES completion:nil];
            break;
        }
        default:
            break;
    }
}

- (void)closeChildWindow:(UIViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)closePopupView
{
    [popover dismissPopoverAnimated:YES];
}

- (void)popoverControllerDidDismissPopover:(FPPopoverController *)popoverController
{
    popupDisplay = NO;
}
@end
