//
//  CommonMotheds.m
//  yueshipin
//
//  Created by Rong on 13-3-22.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "CommonMotheds.h"
#import "Reachability.h"
#import "UIUtility.h"
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

+(void)showNetworkDisAbledAlert:(UIView *)view{
    if (![CommonMotheds isNetworkEnbled]) {
         [UIUtility showNetWorkError:view];
    }
}
@end
