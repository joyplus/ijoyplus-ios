//
//  SettingsViewController.h
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-20.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "CommonHeader.h"
#import "MenuViewController.h"
#import <QuartzCore/QuartzCore.h>

typedef enum _fade_orientation {
    FADE_TOPNBOTTOM = 0,
    FADE_LEFTNRIGHT
} fade_orientation;

@interface PersonalViewController : GenericBaseViewController <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

- (id)initWithFrame:(CGRect)frame;


@end
