//
//  UIUtility.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-13.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "UIUtility.h"
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"

@implementation UIUtility

+ (void)customizeNavigationBar:(UINavigationBar *)navBar
{
    navBar.layer.shadowColor = [[UIColor blackColor] CGColor];
    navBar.layer.shadowOffset = CGSizeMake(0.0, 1.0);
    navBar.layer.shadowOpacity = 0.8;
}

+ (void)customizeToolbar:(UIToolbar *)toolbar
{
    UIImage *toobarImage = [UIImage imageNamed:@"tool_bar_bg"];
    [toolbar setBackgroundImage:toobarImage forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
}

+ (void)addTextShadow:(UILabel *)textLabel
{
    textLabel.layer.shadowOffset = CGSizeMake(0, 1);
    textLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    textLabel.layer.shadowOpacity = 0.5;
}

+ (UILabel *)customizeAppTitle
{
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    titleLabel.text = NSLocalizedString(@"app_name", nil);
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.layer.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5].CGColor;
    titleLabel.layer.shadowOffset = CGSizeMake(0, 1);
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [titleLabel sizeToFit];
    return titleLabel;
}
+ (UIImage *) createImageWithColor: (UIColor *) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
+ (void)showNetWorkError:(UIView *)view
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:HUD];
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = NSLocalizedString(@"message.networkError", nil);
    [HUD show:YES];
    [HUD hide:YES afterDelay:1];
}
@end
