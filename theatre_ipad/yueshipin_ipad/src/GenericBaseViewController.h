//
//  GenericBaseViewController.h
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-19.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIUtility.h"

@interface GenericBaseViewController : UIViewController{
    UIUtility *myHUD;
    float totalSpace_;
    float totalFreeSpace_;
}

@property (nonatomic, strong) UIImageView *bgImage;

@property (nonatomic, strong)UISwipeGestureRecognizer *swipeRecognizer;

- (float)getFreeDiskspacePercent;

- (void)setCloseTipsViewHidden:(BOOL)isHidden;
@end
