//
//  StatementsViewController.m
//  yueshipin
//
//  Created by Rong on 13-1-3.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "StatementsViewController.h"
#import "UIImage+Scale.h"

@interface StatementsViewController ()

@end

@implementation StatementsViewController

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
	// Do any additional setup after loading the view.
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_common.png"]];
    bg.frame = CGRectMake(0, 0, 320, kFullWindowHeight);
    [self.view addSubview:bg];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 49, 30);
    backButton.backgroundColor = [UIColor clearColor];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"back_f.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    self.title = @"免责声明";
    UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_mian_ze_sheng_ming.png"]];
    img.frame = CGRectMake(15, 20, 290, 602.5);
    
    UIScrollView *scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kCurrentWindowHeight-44)];
    [scrollview setContentSize:CGSizeMake(320, 642.5)];
    [scrollview addSubview:img];
    [self.view addSubview:scrollview];
}

-(void)back:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
