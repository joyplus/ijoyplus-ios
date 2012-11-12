//
//  ProgramViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-10-8.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "ProgramViewController.h"
#import "CustomBackButton.h"


@interface ProgramViewController (){
    //    MBProgressHUD *HUD;
}

@end

@implementation ProgramViewController
@synthesize programUrl;
@synthesize webView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"receive memory warning in %@", self.class);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self.webView loadRequest: nil];
    [self.webView removeFromSuperview];
    self.webView = nil;
    //    HUD = nil;
    self.programUrl = nil;
}

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
    CustomBackButton *backButton = [[CustomBackButton alloc] initWith:[UIImage imageNamed:@"back-button"] highlight:[UIImage imageNamed:@"back-button"] leftCapWidth:14.0 text:NSLocalizedString(@"back", nil)];
    [backButton addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    //    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    //    [self.view addSubview:HUD];
    //    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"joplus_logo"]];
    //    HUD.mode = MBProgressHUDModeCustomView;
    //    HUD.dimBackground = YES;
    //    HUD.opacity = 1;
    //    [HUD show:YES];
    //    [HUD hide:YES afterDelay:1];
    
    NSURL *url = [NSURL URLWithString:self.programUrl];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObj];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void) hideGradientBackground:(UIView*)theView
{
    for (UIView * subview in theView.subviews)
    {
        if ([subview isKindOfClass:[UIImageView class]])
            subview.hidden = YES;
        
        [self hideGradientBackground:subview];
    }
}

- (void)closeSelf
{
    [self.navigationController popViewControllerAnimated:YES];
}

//- (UIButton *)findButtonInView:(UIView *)view {
//    UIButton *button = nil;
//
//    if ([view isMemberOfClass:[UIButton class]]) {
//        return (UIButton *)view;
//    }
//
//    if (view.subviews && [view.subviews count] > 0) {
//        for (UIView *subview in view.subviews) {
//            button = [self findButtonInView:subview];
//            if (button) return button;
//        }
//    }
//
//    return button;
//}

@end
