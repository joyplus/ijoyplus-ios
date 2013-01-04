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
#import "MBProgressHUD.h"
#import "SDImageCache.h"

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
    
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(12, 17, 296, 59)];
    view1.backgroundColor = [UIColor whiteColor];
    UIImageView *sinaWeibo = [[UIImageView alloc] initWithFrame:CGRectMake(12, 13, 272, 33)];
    sinaWeibo.image = [UIImage imageNamed:@"my_s_xinlang.png"];
    [view1 addSubview:sinaWeibo];
    [self.view addSubview:view1];
    
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(12, 86, 296, 59)];
    view2.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view2];
    
    UIButton *clearCache = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    clearCache.frame = CGRectMake(24, 100, 273, 33);
    // [feedBack setTitle:@"意见反馈" forState:UIControlStateNormal];
    [clearCache setBackgroundImage:[UIImage imageNamed:@"my_setting_cache.png"] forState:UIControlStateNormal];
    [clearCache setBackgroundImage:[UIImage imageNamed:@"my_setting_cache_s.png"] forState:UIControlStateHighlighted];
    [clearCache addTarget:self action:@selector(clearCache:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clearCache];
    
    
    UIView *view3 = [[UIView alloc] initWithFrame:CGRectMake(12, 155, 296, 172)];
    view3.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view3];
    UIButton *feedBack = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    feedBack.frame = CGRectMake(24, 168, 273, 33);
   // [feedBack setTitle:@"意见反馈" forState:UIControlStateNormal];
    [feedBack setBackgroundImage:[UIImage imageNamed:@"my_setting_other.png"] forState:UIControlStateNormal];
    [feedBack setBackgroundImage:[UIImage imageNamed:@"my_setting_other_s.png"] forState:UIControlStateHighlighted];
    [feedBack addTarget:self action:@selector(feedBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:feedBack];
    
    UIButton *suggest = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    suggest.frame = CGRectMake(24, 208, 273, 33);
    //[suggest setTitle:@"免责声明" forState:UIControlStateNormal];
    [suggest setBackgroundImage:[UIImage imageNamed:@"my_setting_other4.png"] forState:UIControlStateNormal];
    [suggest setBackgroundImage:[UIImage imageNamed:@"my_setting_other4_s.png"] forState:UIControlStateHighlighted];
    [suggest addTarget:self action:@selector(suggest:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:suggest];
    
    UIButton *aboutUs = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    aboutUs.frame = CGRectMake(24, 286, 273, 33);
    //[aboutUs setTitle:@"关于我们" forState:UIControlStateNormal];
    [aboutUs setBackgroundImage:[UIImage imageNamed:@"my_setting_other2.png"] forState:UIControlStateNormal];
    [aboutUs setBackgroundImage:[UIImage imageNamed:@"my_setting_other2_s.png"] forState:UIControlStateHighlighted];
    [aboutUs addTarget:self action:@selector(aboutUs:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:aboutUs];
    
    UIButton *careUs = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    careUs.frame = CGRectMake(24, 247, 273, 33);
    [careUs setBackgroundImage:[UIImage imageNamed:@"my_setting_other3.png"] forState:UIControlStateNormal];
    [careUs setBackgroundImage:[UIImage imageNamed:@"my_setting_other3_s.png"] forState:UIControlStateHighlighted];
    [careUs addTarget:self action:@selector(careUs:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:careUs];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = YES;
}
-(void)careUs:(id)sender{
    

}
-(void)clearCache:(id)sender{

    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.labelText = @"正在清理...";
    [HUD showWhileExecuting:@selector(clearCache) onTarget:self withObject:nil animated:YES];
    
}

- (void)clearCache
{
    [[SDImageCache sharedImageCache] clearDisk];
    sleep(1);
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
