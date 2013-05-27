//
//  ListViewController.m
//  yueshipin_ipad
//
//  Created by zhang zhipeng on 12-11-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "ClauseViewController.h"

@interface ClauseViewController (){
    UIScrollView *bgScrollView;
    UIImageView *titleImage;
    UIImageView *contentImage;
    UIButton *closeBtn;
}

@end

@implementation ClauseViewController

- (void)viewDidUnload
{
    [super viewDidUnload];
    closeBtn = nil;
    titleImage = nil;
    contentImage = nil;
    bgScrollView = nil;
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
    
    bgScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 520, 720)];
    [bgScrollView setBackgroundColor:[UIColor clearColor]];
    bgScrollView.contentSize = CGSizeMake(420, 850);
    bgScrollView.scrollEnabled = YES;
    bgScrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:bgScrollView];
    
    titleImage = [[UIImageView alloc]initWithFrame:CGRectMake(50, 35, 110, 27)];
    titleImage.image = [UIImage imageNamed:@"clause_title"];
    [bgScrollView addSubview:titleImage];
    
    closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(456, 0, 50, 50);
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
    [closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    
    contentImage = [[UIImageView alloc]initWithFrame:CGRectMake(50, 100, 418, 733)];
    contentImage.image = [UIImage imageNamed:@"clause_content"];
    [bgScrollView addSubview:contentImage];
    [self.view addGestureRecognizer:self.swipeRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
