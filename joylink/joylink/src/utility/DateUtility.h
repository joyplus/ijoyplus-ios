//
//  DateUtility.h
//  PersonalTool
//
//  Created by 永庆 李 on 12-2-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define D_MINUTE	60
#define D_HOUR		3600
#define D_DAY		86400
#define D_WEEK		604800
#define D_YEAR		31556926

@interface DateUtility : NSObject

+ (NSString *)formattedStringUsingFormat:(NSString *)dateFormat;

+ (NSDate *) dateWithDaysFromGivenDate: (NSUInteger) days givenDate: (NSDate*) givenDate;

+ (NSString *)formattedDateTimeString:(NSDate *)date;

+ (NSString *)formatDateWithString:(NSDate *)date formatString: (NSString*) formatString;

+ (NSDate *) addMinutes:(NSDate*) referenceDate minutes:(NSUInteger) dMinutes;

+ (NSDate *) dateWithDaysFromNow: (NSUInteger) days;

+ (NSDate *)dateFromFormatString:(NSString *)dateString formatString: (NSString*) formatString;
@end
