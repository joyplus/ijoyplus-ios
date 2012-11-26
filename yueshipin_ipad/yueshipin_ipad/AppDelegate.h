//
//  AppDelegate.h
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-19.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SinaWeibo.h"

@class RootViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) RootViewController *rootViewController;

@property (assign, nonatomic) BOOL closed;

@property (strong, nonatomic) SinaWeibo *sinaweibo;

+ (AppDelegate *) instance;

- (BOOL)isParseReachable;
- (BOOL)isWifiReachable;

@end
