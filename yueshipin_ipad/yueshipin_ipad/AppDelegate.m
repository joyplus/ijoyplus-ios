//
//  AppDelegate.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-19.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "AppDelegate.h"
#import "CommonHeader.h"
#import "OpenUDID.h"
#import "RootViewController.h"
#import "MobClick.h"
#import <Parse/Parse.h>
#import "ActionUtility.h"
#import "iRate.h"
#import "UMFeedback.h"

@interface AppDelegate ()
@property (nonatomic, strong) Reachability *hostReach;
@property (nonatomic, strong) Reachability *internetReach;
@property (nonatomic, strong) Reachability *wifiReach;
@property (nonatomic, readonly) int networkStatus;
@property (strong, nonatomic) NSMutableArray *downloaderArray;
- (void)monitorReachability;

@end

@implementation AppDelegate
@synthesize downloadItems;
@synthesize subdownloadItems;
@synthesize downloadManager;
@synthesize window;
@synthesize rootViewController;
@synthesize closed;
@synthesize networkStatus;
@synthesize hostReach;
@synthesize internetReach;
@synthesize wifiReach;
@synthesize sinaweibo;
@synthesize downloaderArray;
@synthesize currentDownloadingNum;
@synthesize alertUserInfo;
@synthesize showVideoSwitch;
@synthesize closeVideoMode;

+ (AppDelegate *) instance {
	return (AppDelegate *) [[UIApplication sharedApplication] delegate];
}

+ (void)initialize
{
	//set the app and bundle ID. normally you wouldn't need to do this
    //but we need to test with an app that's actually on the store
	[iRate sharedInstance].appStoreID = APPIRATER_APP_ID;
    [iRate sharedInstance].applicationBundleID = @"com.joyplus.yueshipin";
    [iRate sharedInstance].onlyPromptIfLatestVersion = NO;
    [iRate sharedInstance].daysUntilPrompt = 5;
    
    //enable preview mode
    [iRate sharedInstance].previewMode = NO;
}

- (void)customizeAppearance
{
    // Set the background image for *all* UINavigationBars
    UIImage *gradientImage44 = [[UIImage imageNamed:@"nav_bar_bg_44"]resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [[UINavigationBar appearance] setBackgroundImage:gradientImage44 forBarMetrics:UIBarMetricsDefault];
    
    [[UIProgressView appearance] setProgressTintColor:[UIColor colorWithRed:95/255.0 green:169/255.0 blue:250/255.0 alpha:1.0]];
    [[UIProgressView appearance] setTrackTintColor:[UIColor colorWithRed:80/255.0 green:80/255.0 blue:80/255.0 alpha:1.000]];
}
- (void)initSinaweibo
{
    self.sinaweibo = [[SinaWeibo alloc] initWithAppKey:kSinaWeiboAppKey appSecret:kSinaWeiboAppSecret appRedirectURI:kSinaWeiboRedirectURL andDelegate:nil];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *sinaweiboInfo = [defaults objectForKey:@"SinaWeiboAuthData"];
    if ([sinaweiboInfo objectForKey:@"AccessTokenKey"] && [sinaweiboInfo objectForKey:@"ExpirationDateKey"] && [sinaweiboInfo objectForKey:@"UserIDKey"])
    {
        sinaweibo.accessToken = [sinaweiboInfo objectForKey:@"AccessTokenKey"];
        sinaweibo.expirationDate = [sinaweiboInfo objectForKey:@"ExpirationDateKey"];
        sinaweibo.userID = [sinaweiboInfo objectForKey:@"UserIDKey"];
    }
}

- (void)saveChannelRecord
{
    NSString * appKey = @"efd3fb70a08b4a608fccd421f21a79e8";
    NSString * deviceName = [[[UIDevice currentDevice] name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString * udid = [[UIDevice currentDevice] uniqueIdentifier];
    NSString * urlString = [NSString stringWithFormat:@"http://log.umtrack.com/ping/%@/?devicename=%@&udid=%@", appKey,deviceName,udid];
    [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL: [NSURL URLWithString:urlString]] delegate:nil];
}

- (void)initDownloadManager
{
    downloadItems = [[NSMutableArray alloc]initWithCapacity:10];
    [downloadItems addObjectsFromArray:[DownloadItem allObjects]];
    subdownloadItems = [[NSMutableArray alloc]initWithCapacity:10];
    [subdownloadItems addObjectsFromArray:[SubdownloadItem allObjects]];
    downloadManager = [[DownloadManager alloc]init];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[AFHTTPRequestOperationLogger sharedLogger] startLogging];
    [MobClick startWithAppkey:umengAppKey reportPolicy:REALTIME channelId:CHANNEL_ID];
    self.showVideoSwitch = @"0";
    self.closeVideoMode = @"0";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineConfigCallBack:) name:UMOnlineConfigDidFinishedNotification object:nil];
    [MobClick updateOnlineConfig];
    [MobClick checkUpdate];
    [self saveChannelRecord];
    NSString *appKey = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kIpadAppKey];
    if (appKey == nil) {
        [[ContainerUtility sharedInstance] setAttribute:kDefaultAppKey forKey:kIpadAppKey];
    }
    [ActionUtility generateUserId:nil];
    [self initSinaweibo];
    [self monitorReachability];
    [self isParseReachable];
//    [Parse setApplicationId:@"FtAzML5ln4zKkcL28zc9XR6kSlSGwXLdnsQ2WESB" clientKey:@"YzMYsyKNV7ibjZMfIDSGoV5zxsylV4evtO8x64tl"];   // Test Env
    [Parse setApplicationId:@"UBgv7IjGR8i6AN0nS4diS48oQTk6YErFi3LrjK4P" clientKey:@"Y2lKxqco7mN3qBmZ05S8jxSP8nhN92hSN4OHDZR8"]; // Production Env
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound];
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
        PFInstallation *installation = [PFInstallation currentInstallation];
        [installation setBadge:0];
        [installation saveInBackground];
    }
    [self customizeAppearance];
    self.closed = YES;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self initDownloadManager];

    self.rootViewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
    self.window.rootViewController = self.rootViewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)onlineConfigCallBack:(NSNotification *)notification {
    NSString *appKey = [notification.userInfo objectForKey:kIpadAppKey];
    if(appKey != nil){
        [[AFServiceAPIClient sharedClient] setDefaultHeader:@"app_key" value:appKey];
        [[ContainerUtility sharedInstance] setAttribute:appKey forKey:kIpadAppKey];
    }
    if ([CHANNEL_ID isEqualToString:@""]) {//参数self.showVideoSwitch只对app store生效
        self.showVideoSwitch = [NSString stringWithFormat:@"%@", [notification.userInfo objectForKey:SHOW_VIDEO_SWITCH]];
        self.closeVideoMode = [NSString stringWithFormat:@"%@", [notification.userInfo objectForKey:CLOSE_VIDEO_MODE]];
    }
    if(self.showVideoSwitch == nil){
        self.showVideoSwitch = @"0";
    }
    if(self.closeVideoMode == nil){
        self.closeVideoMode = @"0";
    }
    if (![self.showVideoSwitch isEqualToString:@"0"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_MENU_ITEM object:nil];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [PFPush storeDeviceToken:deviceToken];
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
        PFInstallation *installation = [PFInstallation currentInstallation];
        [installation setBadge:0];
        [installation saveInBackground];
    }
    [PFPush subscribeToChannelInBackground:@"" block:^(BOOL succeeded, NSError *error) {
        if (succeeded)
            NSLog(@"Successfully subscribed to broadcast channel!");
        else
            NSLog(@"Failed to subscribe to broadcast channel; Error: %@",error);
    }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        // show some alert or otherwise handle the failure to register.
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
	}
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    self.alertUserInfo = userInfo;
    NSString *alert = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil message:alert delegate:self  cancelButtonTitle:@"不了" otherButtonTitles:@"看一下", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSString *prodId = [NSString stringWithFormat:@"%@", [self.alertUserInfo objectForKey:@"prod_id"]];
        NSString *prodType = [NSString stringWithFormat:@"%@", [self.alertUserInfo objectForKey:@"prod_type"]];
        if(prodId != nil && prodType != nil){
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:prodId, @"prod_id", prodType, @"prod_type", nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"push_notification" object:nil userInfo:userInfo];
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    Reachability *myhostReach = [Reachability reachabilityForInternetConnection];
    if([myhostReach currentReachabilityStatus] == NotReachable) {
        [UIUtility showNetWorkError:self.rootViewController.view];
    };
    
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
        PFInstallation *installation = [PFInstallation currentInstallation];
        [installation setBadge:0];
        [installation saveInBackground];
    }
    [self.sinaweibo applicationDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)isParseReachable {
    return self.networkStatus != NotReachable;
}
- (BOOL)isWifiReachable {
    return self.networkStatus == ReachableViaWiFi;
}
- (void)monitorReachability {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    self.hostReach = [Reachability reachabilityWithHostname: @"www.baidu.com"];
    [self.hostReach startNotifier];
    
    self.internetReach = [Reachability reachabilityForInternetConnection];
    [self.internetReach startNotifier];
    
    self.wifiReach = [Reachability reachabilityForLocalWiFi];
    [self.wifiReach startNotifier];
}
//Called by Reachability whenever status changes.
- (void)reachabilityChanged:(NSNotification* )note {
    Reachability *curReach = (Reachability *)[note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    networkStatus = [curReach currentReachabilityStatus];
    if(self.networkStatus != NotReachable){
        NSLog(@"Network is fine.");
        [downloadManager startDownloadingThreads];
        [ActionUtility generateUserId:nil];
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [self.sinaweibo handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [self.sinaweibo handleOpenURL:url];
}

@end
