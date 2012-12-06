//
//  SettingsViewController.h
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-20.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "GenericBaseViewController.h"
#import "MenuViewController.h"
#import "SinaWeibo.h"

@interface SettingsViewController : GenericBaseViewController <SinaWeiboDelegate, SinaWeiboRequestDelegate>

- (id)initWithFrame:(CGRect)frame;
@property (nonatomic, weak)id <MenuViewControllerDelegate> menuViewControllerDelegate;
@end
