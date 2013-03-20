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
#import "ContainerUtility.h"

@interface UIUtility (){
    MBProgressHUD *HUD;
}

@end

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
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.opacity = 0.5;
    HUD.labelText = NSLocalizedString(@"message.networkError", nil);
    [HUD show:YES];
    [HUD hide:YES afterDelay:1.5];
}
+ (void)showSystemError:(UIView *)view
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:HUD];
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = NSLocalizedString(@"message.systemError", nil);
    HUD.opacity = 0.5;
    [HUD show:YES];
    [HUD hide:YES afterDelay:1.5];
}

+ (UIView *)getDotView:(int)radius
{
    UIView *dotView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, radius, radius)];
    dotView.layer.cornerRadius = 5;
    dotView.layer.masksToBounds = YES;
    dotView.backgroundColor = [UIColor colorWithRed:129/255.0 green:129/255.0 blue:129/255.0 alpha:1.0];
    return dotView;
}

- (void)showProgressBar:(UIView *)view
{
    if(HUD == nil){
        HUD = [[MBProgressHUD alloc] initWithView:view];
        HUD.frame = CGRectMake(HUD.frame.origin.x, HUD.frame.origin.y, HUD.frame.size.width, HUD.frame.size.height);
        [view addSubview:HUD];
        HUD.labelText = @"加载中...";
        HUD.opacity = 0.5;
        [HUD show:YES];
    }
}

- (void)hideAtOnce
{
    [HUD hide:YES];
}

- (void)hide
{
    [HUD hide:YES afterDelay:0.2];
}

+ (void)showDownloadSuccess:(UIView *)view
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:HUD];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.opacity = 0.5;
    HUD.labelText = @"已加入缓存队列,请到菜单-缓存视频查询";//@"已成功加至缓存队列";
    [HUD show:YES];
    [HUD hide:YES afterDelay:1.5];
}

+ (void)showDownloadFailure:(UIView *)view
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:HUD];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.opacity = 0.5;
    HUD.labelText = @"该视频无法缓存";
    [HUD show:YES];
    [HUD hide:YES afterDelay:2];
}

+ (void)showPlayVideoFailure:(UIView *)view
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:HUD];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.opacity = 0.5;
    HUD.labelText = @"该视频暂不能播放！";
    [HUD show:YES];
    [HUD hide:YES afterDelay:3];
}

+ (void)showNoSpace:(UIView *)view
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:HUD];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.opacity = 0.5;
    HUD.labelText = @"空间不足，请清理内存后重试。";
    [HUD show:YES];
    [HUD hide:YES afterDelay:3];
}

@end
