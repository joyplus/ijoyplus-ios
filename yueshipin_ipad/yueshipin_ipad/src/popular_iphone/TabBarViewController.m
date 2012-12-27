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
       
        
//        sortedViewController *sortedview = [[sortedViewController alloc] init];
//        navigationViewController *sortNav = [[navigationViewController alloc] initWithRootViewController:sortedview];
        
        PageManageViewController *pageView = [[PageManageViewController alloc] init];
        navigationViewController *sortNav = [[navigationViewController alloc] initWithRootViewController:pageView];
        
        MineViewController *mineview = [[MineViewController alloc] init];
        navigationViewController *mineNav = [[navigationViewController alloc] initWithRootViewController:mineview];
       
        
        self.viewControllers = [NSArray arrayWithObjects:allListNav,sortNav,mineNav, nil];
        
        [(UITabBarItem *)[self.tabBar.items objectAtIndex:0] setTitle:YUEDAN];
        [(UITabBarItem *)[self.tabBar.items objectAtIndex:1] setTitle:YUEBANG];
        [(UITabBarItem *)[self.tabBar.items objectAtIndex:2] setTitle:MINE];
        
        self.selectedIndex = 0;
     
    }
    return self;
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
