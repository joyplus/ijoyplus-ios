//
//  AppDelegate.h
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-19.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SinaWeibo.h"
#import "TabBarViewController.h"
#import "DownloadItem.h"
#import "SubdownloadItem.h"
#import "McDownload.h"

@class RootViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, NSURLConnectionDelegate, McDownloadDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) RootViewController *rootViewController;

@property (strong, nonatomic) TabBarViewController *tabBarView;

@property (assign, nonatomic) BOOL closed;

@property (assign, nonatomic) BOOL triggeredByPlayer;

@property (strong, nonatomic) SinaWeibo *sinaweibo;

@property (strong, nonatomic) NSString *playBtnSuppressed;

@property (assign, atomic) int currentDownloadingNum;

@property (strong, nonatomic) NSDictionary * alertUserInfo;

- (NSMutableArray *)getDownloaderQueue;
- (void)addToDownloaderArray:(DownloadItem *)item;
- (void)deleteDownloaderInQueue:(DownloadItem *)item;
+ (AppDelegate *) instance;

- (BOOL)isParseReachable;
- (BOOL)isWifiReachable;

@end
