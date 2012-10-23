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
#import "AFHTTPRequestOperationLogger.h"
#import "Reachability.h"
#import "ContainerUtility.h"
#import "CMConstants.h"
#import "SFHFKeychainUtils.h"
#import "StringUtility.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "MobClick.h"
#import "WBEngine.h"
#import "BlockAlertView.h"
#import "CacheUtility.h"

@interface AppDelegate (){
    BottomTabViewController *detailViewController;
}
@property (nonatomic, strong) Reachability *hostReach;
@property (nonatomic, strong) Reachability *internetReach;
@property (nonatomic, readonly) int networkStatus;
- (void)monitorReachability;

@end

@implementation AppDelegate
@synthesize networkStatus;
@synthesize hostReach;
@synthesize internetReach;

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
    [[AFHTTPRequestOperationLogger sharedLogger] startLogging];
//    [AFHTTPRequestOperationLogger sharedLogger].level = AFLoggerLevelError;
    [MobClick startWithAppkey:umengAppKey reportPolicy:REALTIME channelId:@"91store"];
    [self monitorReachability];
    [self isParseReachable];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    NSNumber *num = (NSNumber *)[[ContainerUtility sharedInstance]attributeForKey:kUserLoggedIn];
    if([num boolValue]){
        [self renewSession];
    }
    detailViewController = [[BottomTabViewController alloc] init];
    UINavigationController *viewController = [[UINavigationController alloc]initWithRootViewController:detailViewController];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
    [self customizeAppearance];
    return YES;
}

- (void)renewSession
{
    NSString *username = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserName];
    NSString *password = [SFHFKeychainUtils getPasswordForUsername:kUserName andServiceName:kUserLoginService error:nil];
    NSString *tecentOpenId = [SFHFKeychainUtils getPasswordForUsername:@"tecentOpenId" andServiceName:@"tecentlogin" error:nil];
    if(![StringUtility stringIsEmpty:password] && ![StringUtility stringIsEmpty:username]){
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    kAppKey, @"app_key",
                                    username, @"username",
                                    password, @"password",
                                    nil];
        [[AFServiceAPIClient sharedClient] postPath:kPathAccountLogin parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            NSString *responseCode = [result objectForKey:@"res_code"];
            if(![responseCode isEqualToString:kSuccessResCode]){
                [[ContainerUtility sharedInstance] setAttribute:[NSNumber numberWithBool:NO] forKey:kUserLoggedIn];
                [[WBEngine sharedClient] logOut];
                [SFHFKeychainUtils deleteItemForUsername:username andServiceName:@"login" error:nil];
                [[CacheUtility sharedCache] clear];
                [[ContainerUtility sharedInstance] clear];
                [self refreshRootView];
            }
        }
        failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"<<<<<<%@>>>>>", error);
        }];
    } else if([WBEngine sharedClient].isLoggedIn && ![WBEngine sharedClient].isAuthorizeExpired){
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: kAppKey, @"app_key", [[WBEngine sharedClient] userID], @"source_id", @"1", @"source_type", nil];
        [[AFServiceAPIClient sharedClient] postPath:kPathUserValidate parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            NSString *responseCode = [result objectForKey:@"res_code"];
            if(![responseCode isEqualToString:kSuccessResCode]){
                [[ContainerUtility sharedInstance] setAttribute:[NSNumber numberWithBool:NO] forKey:kUserLoggedIn];
                [self refreshRootView];
            }
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"<<<<<<%@>>>>>", error);
        }];
    } else if(![StringUtility stringIsEmpty:tecentOpenId]){
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: kAppKey, @"app_key", tecentOpenId, @"source_id", @"2", @"source_type", nil];
        [[AFServiceAPIClient sharedClient] postPath:kPathUserValidate parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            NSString *responseCode = [result objectForKey:@"res_code"];
            if(![responseCode isEqualToString:kSuccessResCode]){
                [[ContainerUtility sharedInstance] setAttribute:[NSNumber numberWithBool:NO] forKey:kUserLoggedIn];
                [self refreshRootView];
            }
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"<<<<<<%@>>>>>", error);
        }];
    }
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

- (BOOL)isParseReachable {
    return self.networkStatus != NotReachable;
}
- (void)monitorReachability {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    self.hostReach = [Reachability reachabilityWithHostname: @"www.baidu.com"];
    [self.hostReach startNotifier];
    
    self.internetReach = [Reachability reachabilityForInternetConnection];
    [self.internetReach startNotifier];
}
//Called by Reachability whenever status changes.
- (void)reachabilityChanged:(NSNotification* )note {
    Reachability *curReach = (Reachability *)[note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NSLog(@"Reachability changed: %@", curReach);
    networkStatus = [curReach currentReachabilityStatus];
    if(self.networkStatus != NotReachable){
        NSNumber *num = (NSNumber *)[[ContainerUtility sharedInstance]attributeForKey:kUserLoggedIn];
        if([num boolValue]){
            [self renewSession];
        }
    }
}

@end
