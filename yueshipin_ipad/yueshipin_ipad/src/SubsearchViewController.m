//
//  SubsearchViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-28.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "SubsearchViewController.h"
#import "SearchListViewController.h"

@interface SubsearchViewController (){
    UIButton *closeBtn;
}

@end

@implementation SubsearchViewController

- (void)viewDidUnload
{
    [super viewDidUnload];
    closeBtn = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:CMConstants.backgroundColor];
	removePreviousView = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view setBackgroundColor:CMConstants.backgroundColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    bgImage.image = nil;
    [bgImage removeFromSuperview];
    
    [menuBtn removeFromSuperview];
    menuBtn = nil;
    
    closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(465, 20, 40, 42);
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
    [closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    return self;
}
@end
