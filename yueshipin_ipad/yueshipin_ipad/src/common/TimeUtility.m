//
//  TimeUtility.m
//  ijoyplus
//
//  Created by joyplus1 on 12-11-14.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "TimeUtility.h"

@implementation TimeUtility

+ (NSString *)formatTimeInSecond:(double)time
{
    int hour = time /  60.0 / 60.0;

    int minute = (time - hour * 60 * 60) / 60.0;

    int second = time - hour * 60 * 60 - minute * 60;
    
    NSString *formatedString;
    if(hour > 0){
        formatedString = [NSString stringWithFormat:@"%@:%@:%@", [self numberToString:hour], [self numberToString:minute], [self numberToString:second]];
    } else {
        formatedString = [NSString stringWithFormat:@"%@:%@",[self numberToString:minute], [self numberToString:second]];
    }
    return formatedString;
}

+ (NSString *)numberToString:(int)num
{
    NSString *str;
    if(num > 0){
        if(num < 10){
            str = [NSString stringWithFormat:@"0%i", num];
        } else {
            str = [NSString stringWithFormat:@"%i", num];
            
        }
    } else{
        str = @"00";
    }
    return str;
}

@end
