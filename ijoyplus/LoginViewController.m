//
//  LoginViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-7.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "LoginViewController.h"
#import "BottomTabViewController.h"
#import "AppDelegate.h"

@interface LoginViewController ()

- (void)closeSelf;
- (void)login;
@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"cancel", nil) style:UIBarButtonSystemItemSearch target:self action:@selector(closeSelf)];
    self.navigationItem.leftBarButtonItem = button;
    
    UIBarButtonItem *loginBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Login", nil) style:UIBarButtonSystemItemSearch target:self action:@selector(login)];
    self.navigationItem.rightBarButtonItem = loginBtn;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)closeSelf
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)login
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.userLoggedIn = YES;
    BottomTabViewController *viewController = [[BottomTabViewController alloc]init];
    appDelegate.window.rootViewController = viewController;
    [self presentViewController:viewController animated:YES completion:nil];
}
@end
