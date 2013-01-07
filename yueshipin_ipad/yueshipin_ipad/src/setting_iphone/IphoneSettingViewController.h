//
//  IphoneSettingViewController.h
//  yueshipin
//
//  Created by 08 on 12-12-26.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SinaWeibo.h"

@interface IphoneSettingViewController : UIViewController<SinaWeiboDelegate, SinaWeiboRequestDelegate>{
    UISwitch *sinaSwith_;
     SinaWeibo *sinaweibo_;
}
@property (strong, nonatomic) UISwitch *sinaSwith;
@property (strong, nonatomic) SinaWeibo *sinaweibo;
@end
