//
//  ProgramViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-10-8.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "ProgramViewController.h"
#import "CustomBackButton.h"

@interface ProgramViewController ()

@end

@implementation ProgramViewController
@synthesize programUrl;
@synthesize webView;

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.webView = nil;
    self.programUrl = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    [self.webView setBackgroundColor:[UIColor clearColor]];
    [self hideGradientBackground:self.webView];
//    self.webView.delegate = self;
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.programUrl]]];
    [self.webView setScalesPageToFit:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

- (UIButton *)findButtonInView:(UIView *)view {
    UIButton *button = nil;
    
    if ([view isMemberOfClass:[UIButton class]]) {
        return (UIButton *)view;
    }
    
    if (view.subviews && [view.subviews count] > 0) {
        for (UIView *subview in view.subviews) {
            button = [self findButtonInView:subview];
            if (button) return button;
        }
    }
    
    return button;
}

- (void)webViewDidFinishLoad:(UIWebView *)_webView {
//    UIButton *b = [self findButtonInView:_webView];
//    [b sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)closeSelf
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
