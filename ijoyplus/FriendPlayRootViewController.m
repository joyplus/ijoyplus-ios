//
//  FriendPlayRootViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-12.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "FriendPlayRootViewController.h"
#import "FriendPlayViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AnimationFactory.h"
#import "CustomBackButton.h"
#import "CustomBackButtonHolder.h"
#import "PostViewController.h"
#import "AppDelegate.h"
#import "UIUtility.h"
#import "CMConstants.h"

@interface FriendPlayRootViewController ()

@end

@implementation FriendPlayRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)initViewController
{
    currentViewController = [[FriendPlayViewController alloc]initWithNibName:@"FriendPlayViewController" bundle:nil];
    ((FriendPlayViewController *)currentViewController).programId = self.programId;
//    previousViewController = [[FriendPlayViewController alloc]initWithNibName:@"FriendPlayViewController" bundle:nil];
//    nextViewController = [[FriendPlayViewController alloc]initWithNibName:@"FriendPlayViewController" bundle:nil];
    [self addChildViewController:currentViewController];
    currentViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - TAB_BAR_HEIGHT);
    [self.view addSubview:currentViewController.view];
}

@end
