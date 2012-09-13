//
//  CMConstants.m
//  ClassManagement
//
//  Created by 永庆 李 on 12-3-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CMConstants.h"
@implementation CMConstants

+ (UIColor *)greyColor
{
    return [UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1.0];
}

+ (UIColor*)colorLoadMore{
    
    return [UIColor colorWithRed:0.339 green:0.421 blue:0.535 alpha:1];
}

+ (UIFont*)fontLoadMore{
    return [UIFont fontWithName:@"CenturyGothic-Bold" size:8];
}

+ (UIColor *)separatorColor
{
    return [UIColor colorWithRed:57/255.0 green:59/255.0 blue:60/255.0 alpha:1];
}

+ (UIColor *)textColor
{
    return [UIColor colorWithRed:145/255.0 green:210/255.0 blue:212/255.0 alpha:1];
}

+ (UIFont *)titleFont
{
    return [UIFont systemFontOfSize:15];
}

@end
