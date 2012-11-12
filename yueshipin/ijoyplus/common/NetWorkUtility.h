//
//  CommonUtility.h
//  CommonUtility
//
//  Created by 永庆 李 on 12-2-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "MBProgressHUD.h"

@interface NetWorkUtility :NSObject
{
    MBProgressHUD *HUD;
    
}

-(BOOL) checkNetWorkStatus:(UIView *) view;
-(BOOL) isNetworkConnected;
-(void) showNetworkError:(UIView *) view;
@end
