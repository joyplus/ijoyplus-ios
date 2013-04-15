//
//  UnbundingViewController.h
//  yueshipin
//
//  Created by 08 on 13-4-9.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FayeClient.h"
@interface UnbundingViewController : UIViewController <UIAlertViewDelegate,FayeClientDelegate>
{
    NSString *userId;
    FayeClient * sendClient;
    FayeClient * listenClient;
}
@end
