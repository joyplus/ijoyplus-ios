//
//  UIGenericViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-10-18.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "UIGenericViewController.h"

@interface UIGenericViewController ()

@end

@implementation UIGenericViewController

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideProgressBar) name:@"top_segment_clicked" object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    HUD = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"top_segment_clicked" object:nil];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)showProgressBar
{
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.opacity = 0;
    [HUD show:YES];
}
- (void) hideProgressBar
{
    [HUD hide:YES afterDelay:0.5];
}


@end
