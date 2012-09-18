//
//  CustomBackButtonHolder.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-17.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "CustomBackButtonHolder.h"

@interface CustomBackButtonHolder ()
{
    UIViewController *vController;
}

@end

@implementation CustomBackButtonHolder

- (id)initWithViewController:(UIViewController *)viewController
{
    self = [super init];
    if(self){
        vController = viewController;
    }
    return self;
    
}

- (id)getBackButton:(NSString *)text
{
    CustomBackButton* backButton = [[CustomBackButton alloc] initWith:[UIImage imageNamed:@"back-button"] highlight:[UIImage imageNamed:@"back-button"] leftCapWidth:14.0 text:text];
    backButton.titleLabel.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1];
    [backButton addTarget:vController action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
    return backButton;
}

- (id)getNavgiationButton:(NSString *)text{
    CustomBackButton* backButton = [[CustomBackButton alloc] initWith:[UIImage imageNamed:@"custom-button"] highlight:[UIImage imageNamed:@"custom-button"] leftCapWidth:8.0 text:text];
    backButton.titleLabel.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1];
    [backButton addTarget:vController action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
    return backButton;
}

@end
