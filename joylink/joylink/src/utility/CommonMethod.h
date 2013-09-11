//
//  CommonMethod.h
//  joylink
//
//  Created by joyplus1 on 13-4-25.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonMethod : NSObject
+ (BOOL)isIphone5;
+ (NSString *)appName;
+ (void)getWifiInfo;
+ (NSString *)getIPAddress;
+ (NSString *) platformString;
+ (BOOL)isAirPlayActive;
@end
