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
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 40, 30);
    backButton.backgroundColor = [UIColor clearColor];
    [backButton setImage:[UIImage scaleFromImage:[UIImage imageNamed:@"top_return_common.png"]  toSize:CGSizeMake(20, 18)] forState:UIControlStateNormal];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    self.title = @"免责声明";
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_mian_ze_sheng_ming.png"]];
    bg.frame = CGRectMake(0, 0, 320, 480);
    [self.view addSubview:bg];
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
