//
//  UIUtility.h
//  ijoyplus
//
//  Created by joyplus1 on 12-9-13.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIUtility : NSObject

+ (void)customizeNavigationBar:(UINavigationBar *)navBar;
+ (void)customizeToolbar:(UIToolbar *)toolbar;
+ (void)addTextShadow:(UILabel *)textLabel;
+ (UILabel *)customizeAppTitle;
+ (UIImage *) createImageWithColor: (UIColor *) color;
+ (void)showNetWorkError:(UIView *)view;
+ (void)showSystemError:(UIView *)view;
+ (UIView *)getDotView:(int)radius;
@end
