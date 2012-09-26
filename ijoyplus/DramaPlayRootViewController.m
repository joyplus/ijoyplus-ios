//
//  FriendPlayRootViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-12.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "DramaPlayRootViewController.h"
#import "DramaPlayViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AnimationFactory.h"
#import "CustomBackButton.h"
#import "CustomBackButtonHolder.h"
#import "PostViewController.h"
#import "AppDelegate.h"
#import "UIUtility.h"
#import "CMConstants.h"

@interface DramaPlayRootViewController ()

@end

@implementation DramaPlayRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)initViewController
{
    currentViewController = [[DramaPlayViewController alloc]initWithNibName:@"DramaPlayViewController" bundle:nil];
    previousViewController = [[DramaPlayViewController alloc]initWithNibName:@"DramaPlayViewController" bundle:nil];
    nextViewController = [[DramaPlayViewController alloc]initWithNibName:@"DramaPlayViewController" bundle:nil];
    [self addChildViewController:currentViewController];
    currentViewController.view.frame = CGRectMake(0, 0, 320, 480);
    [self.view addSubview:currentViewController.view];
}


- (void)like
{
    
}

- (void)watch
{
    
}

- (void)collection
{
    
}

- (void)comment
{
    PostViewController *viewController = [[PostViewController alloc]initWithNibName:@"PostViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
