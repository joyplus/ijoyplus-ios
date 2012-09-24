//
//  AppDelegate.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-3.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "AppDelegate.h"
#import "BottomTabViewController.h"
#import "PopularSegmentViewController.h"

@interface AppDelegate (){
    BottomTabViewController *detailViewController;
}

@end

@implementation AppDelegate
@synthesize userLoggedIn;

- (void)customizeAppearance
{
    // Set the background image for *all* UINavigationBars
    UIImage *gradientImage44 = [[UIImage imageNamed:@"nav_bar_bg_44"]resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [[UINavigationBar appearance] setBackgroundImage:gradientImage44 forBarMetrics:UIBarMetricsDefault];
       
    // Customize UIBarButtonItems
    UIImage *button30 = [[UIImage imageNamed:@"custom-button"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    [[UIBarButtonItem appearance] setBackgroundImage:button30 forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0], UITextAttributeTextColor, [UIFont boldSystemFontOfSize:12], UITextAttributeFont, nil] forState:UIControlStateNormal];
    
    // Customize UISegment
    UIImage *segmentSelected = [[UIImage imageNamed:@"segcontrol_sel"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
    UIImage *segmentUnselected = [[UIImage imageNamed:@"segcontrol_uns"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 8, 0, 8)];
    UIImage *segmentSelectedUnselected = [UIImage imageNamed:@"segcontrol_sel-uns"];
    UIImage *segUnselectedSelected = [UIImage imageNamed:@"segcontrol_uns-sel"];
    UIImage *segmentUnselectedUnselected = [UIImage imageNamed:@"segcontrol_uns-uns"];
    
    [[UISegmentedControl appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor, [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0], UITextAttributeTextShadowColor, [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset, [UIFont fontWithName:@"Arial" size:15], UITextAttributeFont, nil] forState:UIControlStateNormal];
    
    [[UISegmentedControl appearance] setBackgroundImage:segmentUnselected forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setBackgroundImage:segmentSelected forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    [[UISegmentedControl appearance] setDividerImage:segmentUnselectedUnselected forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setDividerImage:segmentSelectedUnselected forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setDividerImage:segUnselectedSelected forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UINavigationController *viewController;
    self.userLoggedIn = NO;
//    if(self.userLoggedIn){
        detailViewController = [[BottomTabViewController alloc] init];
        viewController = [[UINavigationController alloc]initWithRootViewController:detailViewController];
//    } else {
//        PopularSegmentViewController *detailViewController = [[PopularSegmentViewController alloc]initWithNibName:@"PopularSegmentViewController" bundle:nil];
//        detailViewController.navigationItem.titleView = [UIUtility customizeAppTitle];
//        viewController = [[UINavigationController alloc]initWithRootViewController:detailViewController];
//    }
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
    [self customizeAppearance];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)refreshRootView
{
    [detailViewController closeChild];
}

@end
