//
//  BaseViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-13.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "BaseViewController.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController
@synthesize bottomToolbar;

- (void)addToolBar
{
//    self.bottomToolbar.frame = CGRectMake(0, self.view.frame.size.height - TAB_BAR_HEIGHT, self.view.frame.size.width, TAB_BAR_HEIGHT);
//    [UIUtility customizeToolbar:self.bottomToolbar];
//    UIButton *registerBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [registerBtn setFrame:CGRectMake(MOVIE_LOGO_WIDTH_GAP, 5, self.view.frame.size.width/2-12, TAB_BAR_HEIGHT-10)];
//    [registerBtn setTitle:NSLocalizedString(@"register", nil) forState:UIControlStateNormal];
//    [registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [registerBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
//    [UIUtility addTextShadow:registerBtn.titleLabel];
//    registerBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|
//    UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
//    [registerBtn setBackgroundImage:[[UIImage imageNamed:@"reg_btn_normal"]stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
//    [registerBtn setBackgroundImage:[[UIImage imageNamed:@"reg_btn_active"]stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
//    [registerBtn addTarget:self action:@selector(registerScreen)forControlEvents:UIControlEventTouchUpInside];
//    [self.bottomToolbar addSubview:registerBtn];
//    
//    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [loginBtn setFrame:CGRectMake(self.view.frame.size.width/2 + MOVIE_LOGO_WIDTH_GAP/2, 5, self.view.frame.size.width/2 - 12, TAB_BAR_HEIGHT-10)];
//    [loginBtn setTitle:NSLocalizedString(@"login", nil) forState:UIControlStateNormal];
//    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [loginBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
//    [UIUtility addTextShadow:loginBtn.titleLabel];
//    loginBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|
//    UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
//    [loginBtn setBackgroundImage:[[UIImage imageNamed:@"log_btn_normal"]stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
//    [loginBtn setBackgroundImage:[[UIImage imageNamed:@"log_btn_active"]stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
//    [loginBtn addTarget:self action:@selector(loginScreen)forControlEvents:UIControlEventTouchUpInside];
//    [self.bottomToolbar addSubview:loginBtn];
//    self.bottomToolbar.layer.zPosition = 1;
//    [self.bottomToolbar addSubview:loginBtn];
}

- (void)loginScreen
{
    LoginViewController *viewController = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:viewController];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}


- (void)registerScreen
{
    RegisterViewController *viewController = [[RegisterViewController alloc]initWithNibName:@"RegisterViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:viewController];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
    
}

- (void)hideToolBar
{
    [self.bottomToolbar setHidden:YES];
}

- (void)viewDidUnload {
    [self setBottomToolbar:nil];
    [super viewDidUnload];
}
@end
