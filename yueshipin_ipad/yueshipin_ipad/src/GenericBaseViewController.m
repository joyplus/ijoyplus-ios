//
//  GenericBaseViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-19.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "GenericBaseViewController.h"
#import "Reachability.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "ContainerUtility.h"
#import "CMConstants.h"
#import "AppDelegate.h"
#import "StackScrollViewController.h"
#import "RootViewController.h"

@interface GenericBaseViewController (){

}

@end

@implementation GenericBaseViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)closeMenu
{
    [AppDelegate instance].closed = YES;
    [[AppDelegate instance].rootViewController.stackScrollViewController menuToggle:YES isStackStartView:YES];
}

- (void)closeBtnClicked
{
    [[AppDelegate instance].rootViewController.stackScrollViewController removeViewInSlider];
}
@end
