//
//  CommonMotheds.m
//  yueshipin
//
//  Created by Rong on 13-3-22.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "CommonMotheds.h"
#import "Reachability.h"
@implementation CommonMotheds
+(BOOL)isNetworkEnbled{
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([hostReach currentReachabilityStatus] != NotReachable){
        return YES;
    }
    else{
        return NO;
    }
}

+(void)showNetworkDisAbledAlert{
    if (![CommonMotheds isNetworkEnbled]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"网络异常，请检查网络。" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
        [alert show];
    }
}
@end
