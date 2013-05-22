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
+ (void)showDownloadSuccess:(UIView *)view;
+ (void)showDownloadFailure:(UIView *)view;
+ (UIView *)getDotView:(int)radius;
- (void)hideAtOnce;
- (void)showProgressBar:(UIView *)view;
- (void)hide;
+ (void)showPlayVideoFailure:(UIView *)view;
+ (void)showNoSpace:(UIView *)view;
+ (void)showDetailError:(UIView *)view  error:(NSError *)error;

@end
