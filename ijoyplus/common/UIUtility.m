//
//  UIUtility.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-13.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "UIUtility.h"

@implementation UIUtility

+ (void)customizeToolbar:(UIToolbar *)toolbar
{
    UIImage *toobarImage = [[UIImage imageNamed:@"tool_bar_bg"]resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [toolbar setBackgroundImage:toobarImage forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
}
@end
