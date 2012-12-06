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
}

- (void)closeMenu;

@end
