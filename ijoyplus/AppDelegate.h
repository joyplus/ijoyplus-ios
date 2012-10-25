//
//  AppDelegate.h
//  ijoyplus
//
//  Created by joyplus1 on 12-9-3.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TencentOAuth.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
- (void)refreshRootView;
- (BOOL)isParseReachable;
- (BOOL)isWifiReachable;
@end
