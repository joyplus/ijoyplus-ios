//
//  CustomBackButtonHolder.h
//  ijoyplus
//
//  Created by joyplus1 on 12-9-17.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomBackButtonHolder : NSObject
- (id)initWithViewController:(UIViewController *)viewController;
- (id)getBackButton:(UIImage*)backButtonImage highlight:(UIImage*)backButtonHighlightImage leftCapWidth:(CGFloat)capWidth text:(NSString *)text;

@end
