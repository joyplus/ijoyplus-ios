//
//  GenericBaseViewController.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-21.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "GenericBaseViewController.h"
#import "CommonHeader.h"
#import "RemoteViewController.h"
#import "KeyboardRemoateViewController.h"
#import "MouseRemoteViewController.h"
#import "SettingsViewController.h"

#define DISCONNECT_HUD_TAG 8573902

@interface GenericBaseViewController () <MenuViewDelegate>
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) MenuView *menuView;
@end

@implementation GenericBaseViewController
@synthesize bounds, showMiddleBtn;
@synthesize navBar, toolbar;
@synthesize contentView, menuView, overlayView;

- (void)viewDidUnload
{
    [super viewDidUnload];
    navBar = nil;
    toolbar = nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"didReceiveMemoryWarning in %@", self.class);
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
    [self.view setBackgroundColor:[UIColor blackColor]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
	bounds = [UIScreen mainScreen].bounds;
    overlayView = [[UIView alloc]initWithFrame:bounds];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tap.delegate = (id<UIGestureRecognizerDelegate>)self;
    [overlayView addGestureRecognizer:tap];
    
    contentView = [[UIView alloc]initWithFrame:bounds];
    [contentView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background@2x.jpg"]]];
    menuView = [[MenuView alloc]init];
    menuView.menuDelegate = self;
}

- (void)showNavigationBar:(NSString *)titleContent
{
    navBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, -1, self.bounds.size.width, NAVIGATION_BAR_HEIGHT)];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 40)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = titleContent;
    titleLabel.tag = TITLE_TAG;
    [titleLabel sizeToFit];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.center = CGPointMake(navBar.center.x, navBar.center.y);
    [navBar addSubview:titleLabel];
//    UINavigationItem *navTitle = [[UINavigationItem alloc] initWithTitle:titleContent];
//    [navBar pushNavigationItem:navTitle animated:YES];
    [self.view addSubview:navBar];
}

- (void)showMenuBtn
{
    [navBar addSubview:[self getMenuButton]];
}

- (void)showMenuBtnForNavController
{
    UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc]initWithCustomView:[self getMenuButton]];
    self.navigationItem.rightBarButtonItem = rightBtnItem;
}

- (void)showBackBtnForNavController
{
    UIBarButtonItem *leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:[self getBackButton]];
    self.navigationItem.leftBarButtonItem = leftBtnItem;
}

- (void)showBackBtn
{
    [navBar addSubview:[self getBackButton]];
}

- (void)showAvplayerBtn
{
    MPVolumeView *routeBtn = [[MPVolumeView alloc] initWithFrame:CGRectMake(0, 0, NAVIGATION_BAR_HEIGHT, NAVIGATION_BAR_HEIGHT)];
    [routeBtn setBackgroundColor:[UIColor clearColor]];
    [routeBtn setShowsVolumeSlider:NO];
    [routeBtn setShowsRouteButton:YES];
    for (UIView *asubview in routeBtn.subviews) {
        if ([NSStringFromClass(asubview.class) isEqualToString:@"MPButton"]) {
            UIButton *btn = (UIButton *)asubview;
            btn.frame = CGRectMake(0, 0, NAVIGATION_BAR_HEIGHT, NAVIGATION_BAR_HEIGHT);
            [btn setImage:nil forState:UIControlStateNormal];
            [btn setImage:nil forState:UIControlStateHighlighted];
            [btn setImage:nil forState:UIControlStateSelected];
            [btn setBackgroundImage:[UIImage imageNamed:@"airpla_off"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"airplay_on"] forState:UIControlStateHighlighted];
            break;
        }
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:routeBtn];
}

- (UIButton *)getMenuButton
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(self.bounds.size.width - 50, 0, 43, 43);
    [btn setBackgroundImage:[UIImage imageNamed:@"nav_menu_icon"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"nav_menu_icon_pressed"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(showRight:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (UIButton *)getBackButton
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(5, 0, 40, 40);
    [backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back_pressed"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    return backButton;
}

- (void)addRightButton
{
//    homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    homeButton.frame = CGRectMake(self.bounds.size.width - 47, 0, 40, 40);
//    [homeButton setBackgroundImage:[UIImage imageNamed:@"home_icon"] forState:UIControlStateNormal];
//    [homeButton setBackgroundImage:[UIImage imageNamed:@"home_icon_pressed"] forState:UIControlStateHighlighted];
//    [homeButton addTarget:self action:@selector(homeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
//    [toolbar addSubview:homeButton];
}

- (void)showToolbar
{
    [self showToolbar:0];
}

- (void)showToolbar:(int)offsetY
{
    toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height - TOOLBAR_HEIGHT - offsetY, self.bounds.size.width, TOOLBAR_HEIGHT)];
    [toolbar setNeedsDisplay];
    [self.view addSubview:toolbar];
}


- (void)backButtonClicked
{
}

// should be implemented in subclasses
- (void)playBtnClicked
{
    
}

- (void)showRight:(id)sender
{
    if (contentView.frame.origin.x < 0) {
        [self closeMenuWithBlock:nil];
    } else {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            navBar.frame = CGRectMake(-130, navBar.frame.origin.y, navBar.frame.size.width, navBar.frame.size.height);
            contentView.frame = CGRectMake(-130, contentView.frame.origin.y, contentView.frame.size.width, contentView.frame.size.height);
            self.navigationController.navigationBar.frame = CGRectMake(-130, self.navigationController.navigationBar.frame.origin.y, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
        } completion:^(BOOL finished) {
            overlayView.frame = contentView.frame;
            [self.view addSubview:overlayView];
        }];
    }
}

- (void)tap:(id)sender
{
    [self closeMenuWithBlock:nil];
}

- (void)closeMenuWithBlock:(void (^)())completion
{
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        navBar.frame = CGRectMake(0, navBar.frame.origin.y, navBar.frame.size.width, navBar.frame.size.height);
        contentView.frame = CGRectMake(0, contentView.frame.origin.y, contentView.frame.size.width, contentView.frame.size.height);
        self.navigationController.navigationBar.frame = CGRectMake(0, self.navigationController.navigationBar.frame.origin.y, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
    } completion:^(BOOL finished) {
        overlayView.frame = contentView.frame;
        [overlayView removeFromSuperview];
        if (completion) {            
            completion();
        }
    }];
}

- (void)addContententView:(int)offsetY
{
    contentView.frame = CGRectMake(contentView.frame.origin.x, contentView.frame.origin.y + offsetY, contentView.frame.size.width, contentView.frame.size.height);
    [self.view addSubview:contentView];
}

- (void)addMenuView:(int)offsetY
{
    menuView.frame = CGRectMake(menuView.frame.origin.x, menuView.frame.origin.y + offsetY, menuView.frame.size.width, menuView.frame.size.height);
    [self.view addSubview:menuView];
}
- (void)addInContentView:(UIView *)subview
{
    [contentView addSubview:subview];
}

#pragma mark - MenuViewDelegate
- (void)closeMenu
{
    [self closeMenuWithBlock:nil];
}

- (void)homeMenuClicked
{
    [self closeMenuWithBlock:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)remoteMenuClicked
{
     [self closeMenuWithBlock:^{
         RemoteViewController *viewController = [[KeyboardRemoateViewController alloc]init];
         [self presentViewController:viewController animated:YES completion:nil];
     }];
}

- (void)mouseMenuClicked
{
    [self closeMenuWithBlock:^{
        RemoteViewController *viewController = [[MouseRemoteViewController alloc]init];
        [self presentViewController:viewController animated:YES completion:nil];
    }];
}

- (void)settingsMenuClicked
{
    [self closeMenuWithBlock:^{
        SettingsViewController *viewController = [[SettingsViewController alloc]init];
        [self presentViewController: [[UINavigationController alloc]initWithRootViewController:viewController] animated:YES completion:nil];
    }];
}

- (BOOL)serverIsConnected
{
    if ([StringUtility stringIsEmpty:[AppDelegate instance].dongelSocketServerIP]) {
        MBProgressHUD *HUD = (MBProgressHUD *)[self.view viewWithTag:DISCONNECT_HUD_TAG];
        if (HUD == nil) {
            HUD = [[MBProgressHUD alloc] initWithView:self.view];
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning"]];
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.tag = DISCONNECT_HUD_TAG;
            HUD.opacity = 0.5;
            HUD.labelText = @"连接中断，请重新连接";
            [self.view addSubview:HUD];
        }
        [HUD show:YES];
        [HUD hide:YES afterDelay:2];
        return NO;
    } else {
        return YES;
    }
}

@end
