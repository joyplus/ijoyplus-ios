//
//  TabBarViewController.m
//  yueshipin
//
//  Created by 08 on 12-12-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "TabBarViewController.h"
#import "allListViewController.h"
#import "sortedViewController.h"
#import "PageManageViewController.h"
#import "MineViewController.h"
#import "navigationViewController.h"
#import "UIImage+Scale.h"

@interface TabBarViewController ()

@end

@implementation TabBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        allListViewController *allListview = [[allListViewController alloc] init];
        navigationViewController *allListNav = [[navigationViewController alloc] initWithRootViewController:allListview];
        [allListNav.navigationBar setBackgroundImage:[UIImage scaleFromImage:[UIImage imageNamed:@"top_bg_common.png"] toSize:CGSizeMake(320, 44)] forBarMetrics:UIBarMetricsDefault];
       
        PageManageViewController *pageView = [[PageManageViewController alloc] init];
        navigationViewController *sortNav = [[navigationViewController alloc] initWithRootViewController:pageView];
        [sortNav.navigationBar setBackgroundImage:[UIImage scaleFromImage:[UIImage imageNamed:@"top_bg_common.png"] toSize:CGSizeMake(320, 44)]forBarMetrics:UIBarMetricsDefault];
        
        MineViewController *mineview = [[MineViewController alloc] init];
        navigationViewController *mineNav = [[navigationViewController alloc] initWithRootViewController:mineview];
        [mineNav.navigationBar setBackgroundImage:[UIImage scaleFromImage:[UIImage imageNamed:@"top_bg_common.png"] toSize:CGSizeMake(320, 44)] forBarMetrics:UIBarMetricsDefault];
        
        UIImage *tabBackground = [[UIImage imageNamed:@"tab_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [[UITabBar appearance] setBackgroundImage:tabBackground];
        [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"tab_bg_zhong_212.png"]];
        self.viewControllers = [NSArray arrayWithObjects:allListNav,sortNav,mineNav, nil];
        [(UITabBarItem *)[self.tabBar.items objectAtIndex:0] setImage:[UIImage imageNamed:@"icon_tab1.png" ]];
        [(UITabBarItem *)[self.tabBar.items objectAtIndex:0] setTitle:YUEDAN];
        [(UITabBarItem *)[self.tabBar.items objectAtIndex:1] setImage:[UIImage imageNamed:@"icon_tab2.png" ]];
        [(UITabBarItem *)[self.tabBar.items objectAtIndex:1] setTitle:YUEBANG];
        [(UITabBarItem *)[self.tabBar.items objectAtIndex:2] setImage:[UIImage imageNamed:@"icon_tab3.png" ]];
        [(UITabBarItem *)[self.tabBar.items objectAtIndex:2] setTitle:MINE];
        self.tabBar.selectedImageTintColor = [UIColor whiteColor];
        self.selectedIndex = 0;
        [self setNoHighlightTabBar];
     
    }
    return self;
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
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
