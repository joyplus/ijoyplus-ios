//
//  ListViewController.m
//  yueshipin_ipad
//
//  Created by zhang zhipeng on 12-11-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "AboutUsViewController.h"

@interface AboutUsViewController (){
    UIImageView *titleImage;
    UIImageView *contentImage;
    UIButton *closeBtn;
}

@end

@implementation AboutUsViewController

- (void)viewDidUnload
{
    [super viewDidUnload];
    titleImage = nil;
    contentImage = nil;
    closeBtn = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.bgImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.frame.size.height)];
    self.bgImage.image = [UIImage imageNamed:@"left_background@2x.jpg"];
    [self.view addSubview:self.bgImage];
    
    titleImage = [[UIImageView alloc]initWithFrame:CGRectMake(LEFT_WIDTH, 35, 104, 27)];
    titleImage.image = [UIImage imageNamed:@"about_title"];
    [self.view addSubview:titleImage];
    
    closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(456, 0, 50, 50);
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
    [closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    
    contentImage = [[UIImageView alloc]initWithFrame:CGRectMake(LEFT_WIDTH, 90, 453, 642)];
    contentImage.image = [UIImage imageNamed:@"about_content"];
    [self.view addSubview:contentImage];

    [self.view addGestureRecognizer:self.swipeRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
