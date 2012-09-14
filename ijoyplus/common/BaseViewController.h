//
//  BaseViewController.h
//  ijoyplus
//
//  Created by joyplus1 on 12-9-13.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "UIUtility.h"
#import "CMConstants.h"
#import "AppDelegate.h"

@interface BaseViewController : UIViewController{


}
@property (strong, nonatomic) IBOutlet UIToolbar *bottomToolbar;
- (void)addToolBar;
- (void)hideToolBar;
- (void)registerScreen;
- (void)loginScreen;
@end
