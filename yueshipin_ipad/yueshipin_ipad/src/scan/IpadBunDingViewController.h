//
//  IpadBunDingViewController.h
//  yueshipin
//
//  Created by lily on 13-7-11.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BundingTVManager.h"
#import "AppDelegate.h"
#define CLOSE  @"close"
@class MBProgressHUD;
@interface IpadBunDingViewController : UIViewController<FayeClientDelegate>{
    NSString        *userId;
    MBProgressHUD   *HUDView;
    NSTimer         *timer;
}
@property (nonatomic, strong) NSString * strData;
@property (nonatomic, assign) BOOL showBunding;
@end
