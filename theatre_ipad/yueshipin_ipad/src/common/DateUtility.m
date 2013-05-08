//
//  DateUtility.m
//  PersonalTool
//
//  Created by 永庆 李 on 12-2-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DateUtility.h"

@implementation DateUtility

+ (NSString *)formattedStringUsingFormat:(NSString *)dateFormat
{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:dateFormat];
    [formatter setCalendar:cal];
    [formatter setLocale:[NSLocale currentLocale]];
    NSString *ret = [formatter stringFromDate:[NSDate date]];

    
    return ret;
}

+ (NSDate *) dateWithDaysFromGivenDate: (NSUInteger) days givenDate: (NSDate*) givenDate
{
	NSTimeInterval aTimeInterval = [givenDate timeIntervalSinceReferenceDate] + D_DAY * days;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;	
}

//Used for class date time
+ (NSString *)formattedDateTimeString:(NSDate *)date
{
    return [DateUtility formatDateWithString:date formatString: @"yyyy-MM-dd EEEE HH:mm"];
}

//Used for class date time
+ (NSString *)formatDateWithString:(NSDate *)date formatString: (NSString*) formatString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:formatString];   
    return [formatter stringFromDate:date];;
}

+ (NSDate *)dateFromFormatString:(NSString *)dateString formatString: (NSString*) formatString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:formatString];
    return [formatter dateFromString:dateString];;
}

+ (NSDate *) addMinutes:(NSDate*) referenceDate minutes:(NSUInteger) dMinutes
{
	NSTimeInterval aTimeInterval = [referenceDate timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;			
}

+ (NSDate *) dateWithDaysFromNow: (NSUInteger) days
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_DAY * days;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;	
}
@end
