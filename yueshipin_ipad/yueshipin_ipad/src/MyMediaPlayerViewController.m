//
//  MyMediaPlayerViewController.m
//  yueshipin
//
//  Created by joyplus1 on 13-1-9.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "MyMediaPlayerViewController.h"

@interface MyMediaPlayerViewController ()

@end

@implementation MyMediaPlayerViewController
@synthesize videoUrls;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [myHUD showProgressBar:self.view];
//    for (; <#condition#>; <#increment#>) {
//        <#statements#>
//    }
}

@end
