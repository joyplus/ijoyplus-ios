//
//  TabBarViewController.m
//  yueshipin
//
//  Created by 08 on 12-12-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "TabBarViewController.h"
#import "ChannelViewController.h"
#import "allListViewController.h"
#import "PageManageViewController.h"
#import "MineViewController.h"
#import "UIImage+Scale.h"
#import "IphoneMovieDetailViewController.h"
#import "TVDetailViewController.h"
#import "IphoneShowDetailViewController.h"
#import "iphoneDownloadViewController.h"
#import "RespForWXRootViewController.h"
#import "CustomNavigationViewControllerPortrait.h"
#import "CacheUtility.h"
#import "DownLoadManager.h"
#import "CommonHeader.h"

@interface TabBarViewController ()

@end

@implementation TabBarViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
        
        ChannelViewController *channelview = [[ChannelViewController alloc] init];
        UINavigationController *channelNav = [[UINavigationController alloc] initWithRootViewController:channelview];
        [channelNav.navigationBar setBackgroundImage:IPHONE_TOP_NAVIGATIONBAR_BG forBarMetrics:UIBarMetricsDefault];
        
        allListViewController *allListview = [[allListViewController alloc] init];
        //RespForWXRootViewController *allListview = [[RespForWXRootViewController alloc] init];
        UINavigationController *allListNav = [[UINavigationController alloc] initWithRootViewController:allListview];
        [allListNav.navigationBar setBackgroundImage:IPHONE_TOP_NAVIGATIONBAR_BG forBarMetrics:UIBarMetricsDefault];
       
        PageManageViewController *pageView = [[PageManageViewController alloc] init];
        UINavigationController *sortNav = [[UINavigationController alloc] initWithRootViewController:pageView];
        [sortNav.navigationBar setBackgroundImage:IPHONE_TOP_NAVIGATIONBAR_BG forBarMetrics:UIBarMetricsDefault];
        
        MineViewController *mineview = [[MineViewController alloc] init];
        UINavigationController *mineNav = [[UINavigationController alloc] initWithRootViewController:mineview];
        [mineNav.navigationBar setBackgroundImage:IPHONE_TOP_NAVIGATIONBAR_BG forBarMetrics:UIBarMetricsDefault];
        
        //init downLoad viewController
        IphoneDownloadViewController * downloadCtrl = [[IphoneDownloadViewController alloc] init];
        UINavigationController * downLoadNavCtrl = [[UINavigationController alloc] initWithRootViewController:downloadCtrl];
        [downLoadNavCtrl.navigationBar setBackgroundImage:IPHONE_TOP_NAVIGATIONBAR_BG forBarMetrics:UIBarMetricsDefault];
        
        channelNav.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
        allListNav.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
        sortNav.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
        downLoadNavCtrl.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
        mineNav.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
        
        UIImage *tabBackground = [[UIImage imageNamed:@"tab_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [[UITabBar appearance] setBackgroundImage:tabBackground];
        [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"tab_bg_zhong_212.png"]];
        
        self.viewControllers = [NSArray arrayWithObjects:channelNav,sortNav,allListNav,downLoadNavCtrl,mineNav, nil];
        [(UITabBarItem *)[self.tabBar.items objectAtIndex:0] setImage:[UIImage imageNamed:@"icon_tab5.png" ]];
        [(UITabBarItem *)[self.tabBar.items objectAtIndex:0] setTitle:PINDAO];
        [(UITabBarItem *)[self.tabBar.items objectAtIndex:0] setTitlePositionAdjustment:UIOffsetMake(0, -3)];
        
        [(UITabBarItem *)[self.tabBar.items objectAtIndex:2] setImage:[UIImage imageNamed:@"icon_tab2.png" ]];
        [(UITabBarItem *)[self.tabBar.items objectAtIndex:2] setTitle:YUEDAN];
        [(UITabBarItem *)[self.tabBar.items objectAtIndex:2] setTitlePositionAdjustment:UIOffsetMake(0, -3)];
        [(UITabBarItem *)[self.tabBar.items objectAtIndex:1] setImage:[UIImage imageNamed:@"icon_tab1.png" ]];
        [(UITabBarItem *)[self.tabBar.items objectAtIndex:1] setTitle:YUEBANG];
        [(UITabBarItem *)[self.tabBar.items objectAtIndex:1] setTitlePositionAdjustment:UIOffsetMake(0, -3)];
        [(UITabBarItem *)[self.tabBar.items objectAtIndex:4] setImage:[UIImage imageNamed:@"icon_tab4.png" ]];
        [(UITabBarItem *)[self.tabBar.items objectAtIndex:4] setTitle:MINE];
        [(UITabBarItem *)[self.tabBar.items objectAtIndex:4] setTitlePositionAdjustment:UIOffsetMake(0, -3)];
        [(UITabBarItem *)[self.tabBar.items objectAtIndex:3] setImage:[UIImage imageNamed:@"icon_tab3.png" ]];
        [(UITabBarItem *)[self.tabBar.items objectAtIndex:3] setTitle:XIAZAI];
        [(UITabBarItem *)[self.tabBar.items objectAtIndex:3] setTitlePositionAdjustment:UIOffsetMake(0, -3)];
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
        {
            self.tabBar.tintColor = [UIColor orangeColor];
        }
        else
        {
            self.tabBar.selectedImageTintColor = [UIColor orangeColor];
        }
        
        self.selectedIndex = 1;
        [self setNoHighlightTabBar];
        
        [self setBadgeValue];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentView:) name:@"push_notification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setBadgeValue) name:@"SET_WARING_NUM" object:nil];
    }
    return self;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    int index = [self.tabBar.items indexOfObject:item];
    if (index == self.selectedIndex) {
        UINavigationController *nav = [self.viewControllers objectAtIndex:index];
        UIViewController *tempViewComtroller = [nav.viewControllers objectAtIndex:0];
        switch (index) {
                case 0:{
                        ChannelViewController *channelview = (ChannelViewController *)tempViewComtroller;
                        [channelview reFreshViewController];
                        break;
                    }
                case 1:{
                         PageManageViewController *pagemanager = (PageManageViewController *)tempViewComtroller;
                         [pagemanager reFreshViewController];
                        break;
                    }
                case 2:{
                        allListViewController *alllist = (allListViewController *)tempViewComtroller;
                        [alllist reFreshViewController];
                        break;
                    }
                default:
                    break;
            }
        }
}

-(void)setBadgeValue{
    int count = [DownLoadManager downloadTaskCount];
    if (count > 0) {
         [(UITabBarItem *)[self.tabBar.items objectAtIndex:3] setBadgeValue:[NSString stringWithFormat:@"%d",count]];
        
    }
    else{
         [(UITabBarItem *)[self.tabBar.items objectAtIndex:3] setBadgeValue:nil];
    }

    
}
-(void)presentView:(NSNotification *)notification{
    NSDictionary *infoDic = [notification userInfo];
    NSString *type = [infoDic objectForKey:@"prod_type"];
    switch ([type intValue]) {
        case 1:{
            IphoneMovieDetailViewController *iphoneMovieDetailViewController = [[IphoneMovieDetailViewController alloc] initWithStyle:UITableViewStylePlain];
            iphoneMovieDetailViewController.infoDic = [NSMutableDictionary dictionaryWithDictionary:infoDic];
            iphoneMovieDetailViewController.isNotification = YES;
            [self presentViewController:[[CustomNavigationViewControllerPortrait alloc] initWithRootViewController:iphoneMovieDetailViewController] animated:YES completion:nil];
            break;
        }
        case 2 :{
            TVDetailViewController *tvDetailViewController = [[TVDetailViewController alloc] initWithStyle:UITableViewStylePlain];
            tvDetailViewController.infoDic = infoDic;
            tvDetailViewController.isNotification = YES;
            [self presentViewController:[[CustomNavigationViewControllerPortrait alloc] initWithRootViewController:tvDetailViewController] animated:YES completion:nil];
            
            break;
        }
        case 131 :{
            TVDetailViewController *tvDetailViewController = [[TVDetailViewController alloc] initWithStyle:UITableViewStylePlain];
            tvDetailViewController.infoDic = infoDic;
            tvDetailViewController.isNotification = YES;
            [self presentViewController:[[CustomNavigationViewControllerPortrait alloc] initWithRootViewController:tvDetailViewController] animated:YES completion:nil];
            
            break;
        }
        case 3:{
            IphoneShowDetailViewController *iphoneShowDetailViewController = [[IphoneShowDetailViewController alloc] initWithStyle:UITableViewStylePlain];
            iphoneShowDetailViewController.infoDic = infoDic;
            iphoneShowDetailViewController.isNotification = YES;
            [self presentViewController:[[CustomNavigationViewControllerPortrait alloc] initWithRootViewController:iphoneShowDetailViewController] animated:YES completion:nil];
            break;
        }
        default:
            break;
    }
    }

- (void)setNoHighlightTabBar

{
    
    NSArray * tabBarSubviews = [self.tabBar subviews];
    
    int index4SelView;
    
    if(self.selectedIndex+1 > 4)
        
    {//selected the last tab.
        
        index4SelView = [tabBarSubviews count]-1;
        
    }
    
    else if([self.viewControllers count] > 5)
        
    {//have "more" tab. and havn't selected the last tab:"more" tab.
        
        index4SelView = [tabBarSubviews count] - 5 + self.selectedIndex;
        
    }
    
    else
        
    {//have no "more" tab.
        
        index4SelView = [tabBarSubviews count] -
        
        [self.viewControllers count] + self.selectedIndex;
        
    }
    
    if([tabBarSubviews count] < index4SelView+1)
        
    {
        
        assert(false);
        
        return;
        
    }
    
    UIView * selView = [tabBarSubviews objectAtIndex:index4SelView];
    
    NSArray * selViewSubviews = [selView subviews];
    
    for(UIView * v in selViewSubviews)
        
    {
        
        if(v && [NSStringFromClass([v class]) isEqualToString:@"UITabBarSelectionIndicatorView"])
            
        {//the v is the highlight view.
            
            [v removeFromSuperview];
            
            break;
            
        }
        
    }
}

-(BOOL)shouldAutorotate {
    
    return NO;
    
}

-(NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
    
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    
    return UIInterfaceOrientationPortrait;
    
}


#ifdef __IPHONE_7_0

- (NSUInteger)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController NS_AVAILABLE_IOS(7_0)
{
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)navigationControllerPreferredInterfaceOrientationForPresentation:(UINavigationController *)navigationController NS_AVAILABLE_IOS(7_0)
{
    return UIInterfaceOrientationPortrait;
}

#endif

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
        [self setNeedsStatusBarAppearanceUpdate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//
//#pragma mark -
//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}
//
//- (BOOL)prefersStatusBarHidden
//{
//    return NO;
//}

@end
