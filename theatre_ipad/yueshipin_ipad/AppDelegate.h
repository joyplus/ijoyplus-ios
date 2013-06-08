//
//  AppDelegate.h
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-19.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SinaWeibo.h"
#import "DownloadItem.h"
#import "SubdownloadItem.h"
#import "NewDownloadManager.h"
#import "WXApi.h"
#import "NewM3u8DownloadManager.h"
#import "AdViewController.h"
@class RootViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, NSURLConnectionDelegate, UIAlertViewDelegate,WXApiDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) RootViewController *rootViewController;


@property (assign, nonatomic) BOOL closed;

@property (assign, nonatomic) BOOL triggeredByPlayer;

@property (strong, nonatomic) SinaWeibo *sinaweibo;

@property (strong, nonatomic) NSString *showVideoSwitch;  // 0:有视频，播放视频，无视频，播放网页 1:只播放网页 2:调用safari打开播放网页
@property (strong, nonatomic) NSString *closeVideoMode;   // 0:关闭视频和网页  1:只关闭视频，不关闭网页
@property (strong, nonatomic) NSString *recommendAppSwich;// 0:显示推荐应用    1:隐藏推荐应用
@property (assign, atomic) int currentDownloadingNum;

@property (strong, nonatomic) NSDictionary * alertUserInfo;
@property (nonatomic) float mediaVolumeValue;

@property (strong, nonatomic) NewDownloadManager *padDownloadManager;

@property (nonatomic, strong) NSString *playWithDownload;

@property (nonatomic, assign)BOOL isInPlayView;
@property (nonatomic, strong) AdViewController *adViewController;
@property (nonatomic, strong)NSString *advUrl;
@property (nonatomic, strong)NSString *advTargetUrl;
@property UIBackgroundTaskIdentifier bgTask;

+ (AppDelegate *) instance;
- (void)startHttpServer;
- (void)stopHttpServer;
- (BOOL)isParseReachable;
- (BOOL)isWifiReachable;
- (void)decreaseDownloadingNum;

@end
