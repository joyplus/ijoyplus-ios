//
//  ProgramViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-10-8.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "ProgramViewController.h"
#import "CustomBackButton.h"
#import "ProgramView.h"


@interface ProgramViewController (){
    ProgramView *view;
}

@end

@implementation ProgramViewController
@synthesize programUrl;

- (void)viewDidUnload
{
    view = nil;
    self.programUrl = nil;
    [super viewDidUnload];
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
    
     view = [[ProgramView alloc]initWithUrl:self.programUrl];
    [self.view addSubview:view];
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

//- (void)webViewDidFinishLoad:(UIWebView *)_webView {
//    [self hideProgressBar];
//}

- (void)closeSelf
{
    [self.navigationController popViewControllerAnimated:YES];
}



@end
