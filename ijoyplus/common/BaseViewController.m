//
//  BaseViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-13.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)addToolBar
{
    UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - TAB_BAR_HEIGHT - 44, self.view.frame.size.width, TAB_BAR_HEIGHT)];
    toolBar.layer.zPosition = 1;
    [UIUtility customizeToolbar:toolBar];
    
    UIButton *registerBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [registerBtn setFrame:CGRectMake(2, 2, self.view.frame.size.width/2-1, TAB_BAR_HEIGHT-3)];
    [registerBtn setTitle:NSLocalizedString(@"register", nil) forState:UIControlStateNormal];
    [registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [registerBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [UIUtility addTextShadow:registerBtn.titleLabel];
    registerBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|
    UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [registerBtn setBackgroundImage:[[UIImage imageNamed:@"reg_btn_normal"]stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
    [registerBtn setBackgroundImage:[[UIImage imageNamed:@"reg_btn_active"]stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
    [registerBtn addTarget:self action:@selector(registerScreen)forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:registerBtn];
    
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [loginBtn setFrame:CGRectMake(self.view.frame.size.width/2 + 2, 2, self.view.frame.size.width/2 - 4, TAB_BAR_HEIGHT-3)];
    [loginBtn setTitle:NSLocalizedString(@"login", nil) forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [UIUtility addTextShadow:loginBtn.titleLabel];
    loginBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|
    UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [loginBtn setBackgroundImage:[[UIImage imageNamed:@"log_btn_normal"]stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
    [loginBtn setBackgroundImage:[[UIImage imageNamed:@"log_btn_active"]stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
    [loginBtn addTarget:self action:@selector(loginScreen)forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:loginBtn];
    
    [self.view addSubview:toolBar];
}

@end
