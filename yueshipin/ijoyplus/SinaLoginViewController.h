//
//  SinaLoginViewController.h
//  ijoyplus
//
//  Created by joyplus1 on 12-9-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBEngine.h"
#import "WBSendView.h"
#import "WBLogInAlertView.h"
#import "AFSinaWeiboAPIClient.h"
#import "MBProgressHUD.h"
#import "GenericLoginViewController.h"

@interface SinaLoginViewController : GenericLoginViewController <WBEngineDelegate, WBLogInAlertViewDelegate>

@end
