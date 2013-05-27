//
//  CommonUtility.m
//  CommonUtility
//
//  Created by 永庆 李 on 12-2-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NetWorkUtility.h"
#import "Reachability.h"

@implementation NetWorkUtility

-(BOOL) isNetworkConnected{
    
    Reachability *hostReach = [Reachability reachabilityWithHostname:@"www.baidu.com"];
	// 判断连接类型
    if([hostReach currentReachabilityStatus]  == NotReachable) {
        HUD.labelText = NSLocalizedString(@"message.networkError", nil);
        sleep(1);
        return NO;
    }else{
        return YES;
    }
}


-(BOOL) checkNetWorkStatus:(UIView *) view{
    
    Reachability *hostReach = [Reachability reachabilityWithHostname:@"www.baidu.com"];
	// 判断连接类型
    if([hostReach currentReachabilityStatus]  == NotReachable) {
        
        [self showNetworkError:view];
        return NO;
        
    }else{
        return YES;
    }
    
}

-(void) showNetworkError:(UIView *) view{
    HUD = [[MBProgressHUD alloc] initWithView:view];
	[view addSubview:HUD];
    
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = NSLocalizedString(@"message.networkError", nil);
    
    [HUD show:YES];
	[HUD hide:YES afterDelay:2];
}

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
	HUD = nil;
}
@end

