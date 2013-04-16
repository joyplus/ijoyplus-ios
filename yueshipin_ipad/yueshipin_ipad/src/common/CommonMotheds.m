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

+(BOOL)isFirstTimeRun{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"App_version"]==nil){
        
        return YES;
    }
    else{
        return NO;
    }
}

+(BOOL)isVersionUpdate{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *oldVersion = [defaults objectForKey:@"App_version"];
    if(oldVersion!=nil){
        NSString *newVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
        NSComparisonResult result = [oldVersion compare:newVersion];
        if (result == NSOrderedAscending) {
            return YES;
        }
    }
    else{
         NSString *bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
         NSLog(@" %@is app version", bundleVersion);
        [defaults setObject:bundleVersion forKey:@"App_version"];
    }
    return NO;
}
@end
