//
//  CommonMotheds.h
//  yueshipin
//
//  Created by Rong on 13-3-22.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonMotheds : NSObject
+(BOOL)isNetworkEnbled;
+(void)showNetworkDisAbledAlert:(UIView *)view;
+(void)showInternetError:(NSError *)error inView:(UIView *)view;
+(BOOL)isFirstTimeRun;
+(BOOL)isVersionUpdate;
+(void)setVersion;
+ (NSArray *)localPlaylists:(NSString *)mediaId;
@end
