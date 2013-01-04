//
//  IphoneSettingViewController.m
//  yueshipin
//
//  Created by 08 on 12-12-26.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "IphoneSettingViewController.h"
#import "FeedBackViewController.h"
#import "AboutViewController.h"
#import "StatementsViewController.h"

@interface IphoneSettingViewController ()

@end

@implementation IphoneSettingViewController

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
    UIBarButtonItem * backtButton = [[UIBarButtonItem alloc]init];
    backtButton.image=[UIImage imageNamed:@"top_return_common.png"];
    self.navigationItem.backBarButtonItem = backtButton;
    
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_common.png"]];
    bg.frame = CGRectMake(0, 0, 320, 480);
    [self.view addSubview:bg];
    
    UIButton *feedBack = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    feedBack.frame = CGRectMake(24, 168, 273, 33);
    [feedBack setTitle:@"意见反馈" forState:UIControlStateNormal];
    [feedBack addTarget:self action:@selector(feedBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:feedBack];
    
    UIButton *suggest = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    suggest.frame = CGRectMake(24, 208, 273, 33);
    [suggest setTitle:@"免责声明" forState:UIControlStateNormal];
    [suggest addTarget:self action:@selector(suggest:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:suggest];
    
    UIButton *aboutUs = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    aboutUs.frame = CGRectMake(24, 247, 273, 33);
    [aboutUs setTitle:@"关于我们" forState:UIControlStateNormal];
    [aboutUs addTarget:self action:@selector(aboutUs:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:aboutUs];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = YES;
}

-(void)feedBack:(id)sender{
    FeedBackViewController *feedBackViewController = [[FeedBackViewController alloc] init];
    [self.navigationController pushViewController:feedBackViewController animated:YES];

}

-(void)suggest:(id)sender{
    StatementsViewController *satementViewController = [[StatementsViewController alloc] init];
    [self.navigationController pushViewController:satementViewController animated:YES];
    
}

-(void)aboutUs:(id)sender{
    AboutViewController *aboutViewController = [[AboutViewController alloc] init];
    [self.navigationController pushViewController:aboutViewController animated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
