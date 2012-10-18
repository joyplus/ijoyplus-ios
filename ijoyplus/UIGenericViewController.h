//
//  UIGenericViewController.h
//  ijoyplus
//
//  Created by joyplus1 on 12-10-18.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface UIGenericViewController : UIViewController{
        MBProgressHUD *HUD;
}
- (void)showProgressBar;
- (void) hideProgressBar;
@end
