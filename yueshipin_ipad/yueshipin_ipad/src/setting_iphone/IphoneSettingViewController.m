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
    UIButton *feedBack = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    feedBack.frame = CGRectMake(24, 168, 273, 33);
    [feedBack setTitle:@"意见反馈" forState:UIControlStateNormal];
    [feedBack addTarget:self action:@selector(feedBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:feedBack];
    
    UIButton *suggest = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    suggest.frame = CGRectMake(24, 208, 273, 33);
    [suggest setTitle:@"给我们评价" forState:UIControlStateNormal];
    [suggest addTarget:self action:@selector(suggest:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:suggest];
    
    UIButton *aboutUs = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    aboutUs.frame = CGRectMake(24, 247, 273, 33);
    [aboutUs setTitle:@"关于我们" forState:UIControlStateNormal];
    [aboutUs addTarget:self action:@selector(aboutUs:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:aboutUs];
	// Do any additional setup after loading the view.
}


-(void)feedBack:(id)sender{
    FeedBackViewController *feedBackViewController = [[FeedBackViewController alloc] init];
    [self.navigationController pushViewController:feedBackViewController animated:YES];

}

-(void)suggest:(id)sender{
    
    
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
