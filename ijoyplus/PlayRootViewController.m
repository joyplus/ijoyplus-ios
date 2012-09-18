//
//  PlayRootViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-12.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "PlayRootViewController.h"
#import "PlayViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AnimationFactory.h"
#import "CustomBackButton.h"
#import "CustomBackButtonHolder.h"

@interface PlayRootViewController (){
    UISwipeGestureRecognizer *leftGesture;
    UISwipeGestureRecognizer *rightGesture;
    UIViewController *previousViewController;
    UIViewController *nextViewController;
    UIViewController *currentViewController;
}
- (void)closeSelf;

@end

@implementation PlayRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.title = NSLocalizedString(@"app_name", nil);
    CustomBackButtonHolder *backButtonHolder = [[CustomBackButtonHolder alloc]initWithViewController:self];
    CustomBackButton* backButton = [backButtonHolder getBackButton:NSLocalizedString(@"go_back", nil)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
	currentViewController = [[PlayViewController alloc]initWithNibName:@"PlayViewController" bundle:nil];
    previousViewController = [[PlayViewController alloc]initWithNibName:@"PlayViewController" bundle:nil];
    nextViewController = [[PlayViewController alloc]initWithNibName:@"PlayViewController" bundle:nil];
    [self addChildViewController:currentViewController];
    currentViewController.view.frame = CGRectMake(0, 0, 320, 480);
    [self.view addSubview:currentViewController.view];

    leftGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(nextAction)];
    leftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftGesture];
    
    rightGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(previousAction)];
    rightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightGesture];
}

- (void)closeSelf
{
    UIViewController *viewController = [self.navigationController popViewControllerAnimated:YES];
    if(viewController == nil){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)previousAction
{
    nextViewController = currentViewController;
    [currentViewController.view removeFromSuperview];
    [currentViewController removeFromParentViewController];
    currentViewController = previousViewController;
    previousViewController = [[PlayViewController alloc]initWithNibName:@"PlayViewController" bundle:nil];
    [self.view addSubview:currentViewController.view];
    CATransition *animation = [AnimationFactory pushToLeftAnimation:^{
        currentViewController.view.frame = self.view.bounds;
    }];
    [[self.view layer] addAnimation:animation forKey:@"animation"];
}
- (void)nextAction
{
    previousViewController = currentViewController;
    [currentViewController.view removeFromSuperview];
    [currentViewController removeFromParentViewController];
    currentViewController = nextViewController;
    nextViewController = [[PlayViewController alloc]initWithNibName:@"PlayViewController" bundle:nil];
    [self.view addSubview:currentViewController.view];
    CATransition *animation = [AnimationFactory pushToRightAnimation:^{
        currentViewController.view.frame = self.view.bounds;
    }];
    [[self.view layer] addAnimation:animation forKey:@"animation"];

}


- (void)viewDidUnload
{
    [super viewDidUnload];
    leftGesture = nil;
    rightGesture = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
