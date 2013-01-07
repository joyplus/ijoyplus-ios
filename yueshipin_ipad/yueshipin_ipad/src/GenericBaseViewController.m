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
#import "CommonHeader.h"

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
    myHUD = [[UIUtility alloc]init];
    [self.view setBackgroundColor:CMConstants.backgroundColor];
    
    swipeRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(closeBtnClicked)];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    swipeRecognizer.numberOfTouchesRequired=1;
    
    openMenuRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(menuBtnClicked)];
    openMenuRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    openMenuRecognizer.numberOfTouchesRequired=1;
    
    closeMenuRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeMenu)];
    closeMenuRecognizer.numberOfTouchesRequired=1;
    
    swipeCloseMenuRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(closeMenu)];
    swipeCloseMenuRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeCloseMenuRecognizer.numberOfTouchesRequired=1;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    myHUD = nil;
    swipeRecognizer = nil;
    openMenuRecognizer = nil;
    closeMenuRecognizer = nil;
    swipeCloseMenuRecognizer = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"didReceiveMemoryWarning");
}

- (void)closeMenu
{
    [AppDelegate instance].closed = YES;
    [[AppDelegate instance].rootViewController.stackScrollViewController menuToggle:YES isStackStartView:YES];
}

- (void)menuBtnClicked
{
    [[AppDelegate instance].rootViewController.stackScrollViewController removeAllSubviewInSlider];
    [AppDelegate instance].closed = ![AppDelegate instance].closed;
    [[AppDelegate instance].rootViewController.stackScrollViewController menuToggle:[AppDelegate instance].closed isStackStartView:YES];
}

- (void)closeBtnClicked
{
    [[AppDelegate instance].rootViewController.stackScrollViewController removeViewInSlider];
}

@end
