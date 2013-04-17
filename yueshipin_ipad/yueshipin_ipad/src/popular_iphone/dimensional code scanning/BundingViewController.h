//
//  BundingViewController.h
//  yueshipin
//
//  Created by 08 on 13-4-9.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BundingTVManager.h"
#import "AppDelegate.h"

@class MBProgressHUD;

@interface BundingViewController : UIViewController <FayeClientDelegate>
{
    NSString        *userId;
    MBProgressHUD   *HUDView;
    NSTimer         *timer;
}
@property (nonatomic, strong) NSString * strData;
@end
