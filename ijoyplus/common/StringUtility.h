//
//  StringUtility.h
//  CommonUtility
//
//  Created by 永庆 李 on 12-3-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StringUtility : NSObject
+ (BOOL ) stringIsEmpty:(NSString *) aString;
+ (BOOL ) stringIsEmpty:(NSString *) aString shouldCleanWhiteSpace:(BOOL)cleanWhileSpace;
+ (NSString*) nullToEmpty:(NSString *) aString;
+ (BOOL ) isNotEqualToNull:(NSObject *) param;
+ (BOOL) IsValidEmail:(NSString*) checkString;

@end
