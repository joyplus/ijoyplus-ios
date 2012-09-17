//
//  CustomBackButtonHolder.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-17.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "CustomBackButtonHolder.h"
#import "CustomBackButton.h"

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

- (id)getBackButton:(UIImage*)backButtonImage highlight:(UIImage*)backButtonHighlightImage leftCapWidth:(CGFloat)capWidth text:(NSString *)text
{
    CustomBackButton* backButton = [[CustomBackButton alloc] initWith:[UIImage imageNamed:@"navigationBarBackButton.png"] highlight:nil leftCapWidth:14.0 text:NSLocalizedString(@"go_back", nil)];
    backButton.titleLabel.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1];
    [backButton addTarget:vController action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
    return backButton;
}

@end
