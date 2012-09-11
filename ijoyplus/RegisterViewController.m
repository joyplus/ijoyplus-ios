//
//  RegisterViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-11.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "RegisterViewController.h"
#import "CMConstants.h"
#import "AppDelegate.h"
#import "BottomTabViewController.h"

@interface RegisterViewController ()
- (void)closeSelf;
@end

@implementation RegisterViewController
@synthesize sinaButton;
@synthesize tecentButton;
@synthesize renrenButton;
@synthesize douban;
@synthesize registerButton;

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
    self.title = NSLocalizedString(@"register", nil);
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"go_back", nil) style:UIBarButtonSystemItemSearch target:self action:@selector(closeSelf)];
    self.navigationItem.leftBarButtonItem = button;
    [sinaButton setActionSheetButtonWithColor: CMConstants.greyColor];
    sinaButton.buttonBorderWidth = 0;
    [sinaButton setTitle: NSLocalizedString(@"新浪微博", nil) forState:UIControlStateNormal];
    
    [tecentButton setActionSheetButtonWithColor: CMConstants.greyColor];
    tecentButton.buttonBorderWidth = 0;
    [tecentButton setTitle: NSLocalizedString(@"腾讯网", nil) forState:UIControlStateNormal];
    
    [renrenButton setActionSheetButtonWithColor: CMConstants.greyColor];
    renrenButton.buttonBorderWidth = 0;
    [renrenButton setTitle: NSLocalizedString(@"人人网", nil) forState:UIControlStateNormal];
    
    [douban setActionSheetButtonWithColor: CMConstants.greyColor];
    douban.buttonBorderWidth = 0;
    [douban setTitle: NSLocalizedString(@"豆瓣网", nil) forState:UIControlStateNormal];
    
    [registerButton setActionSheetButtonWithColor: CMConstants.greyColor];
    registerButton.buttonBorderWidth = 0;
    [registerButton setTitle: NSLocalizedString(@"register", nil) forState:UIControlStateNormal];
}

- (void)closeSelf
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidUnload
{
    [self setSinaButton:nil];
    [self setTecentButton:nil];
    [self setRenrenButton:nil];
    [self setDouban:nil];
    [self setRegisterButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)register:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.userLoggedIn = YES;
    BottomTabViewController *viewController = [[BottomTabViewController alloc]init];
    appDelegate.window.rootViewController = viewController;
    [self presentViewController:viewController animated:YES completion:nil];
}
@end
