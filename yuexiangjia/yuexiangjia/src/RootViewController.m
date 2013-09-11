//
//  RootViewController.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-24.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "RootViewController.h"
#import "HomeViewController.h"
#import "CommonHeader.h"

@interface RootViewController ()

@end

@implementation RootViewController

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
	HomeViewController *homeViewController = [[HomeViewController alloc]init];
    homeViewController.view.frame = [[UIScreen mainScreen] bounds];
    homeViewController.view.tag = HOME_VIEW_TAG;
    [self addChildViewController:homeViewController];
    [self.view addSubview:homeViewController.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
