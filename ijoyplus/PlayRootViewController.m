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
#import "PostViewController.h"
#import "AppDelegate.h"
#import "UIUtility.h"
#import "CMConstants.h"

@interface PlayRootViewController (){
    UISwipeGestureRecognizer *leftGesture;
    UISwipeGestureRecognizer *rightGesture;
    UIViewController *previousViewController;
    UIViewController *nextViewController;
    UIViewController *currentViewController;
    UIToolbar *bottomToolbar;
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
    
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
//    if(appDelegate.userLoggedIn){
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"share", nil) style:UIBarButtonSystemItemSearch target:self action:@selector(share)];
        self.navigationItem.rightBarButtonItem = rightButton;
//    }
    
    
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
    
    if (bottomToolbar == nil){
        [self initToolBar];
    }
    [self.view addSubview:bottomToolbar];
}

- (void)share
{
    PostViewController *viewController = [[PostViewController alloc]initWithNibName:@"PostViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
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
    bottomToolbar = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)initToolBar
{
    bottomToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height - NAVIGATION_BAR_HEIGHT - 48, self.view.frame.size.width, TAB_BAR_HEIGHT)];
    UIImage *toobarImage = [UIUtility createImageWithColor:[UIColor blackColor]];
    [bottomToolbar setBackgroundImage:toobarImage forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];

    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn1 setFrame:CGRectMake(0, 0, 78, TAB_BAR_HEIGHT)];
    [btn1 setTitle:NSLocalizedString(@"register", nil) forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn1.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [UIUtility addTextShadow:btn1.titleLabel];
    btn1.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|
    UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [btn1 setBackgroundImage:[UIImage imageNamed:@"reg_btn_normal"] forState:UIControlStateNormal];
    [btn1 setBackgroundImage:[UIImage imageNamed:@"reg_btn_active"] forState:UIControlStateHighlighted];
    [btn1 addTarget:self action:@selector(like)forControlEvents:UIControlEventTouchUpInside];
    [bottomToolbar addSubview:btn1];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn2 setFrame:CGRectMake(btn1.frame.origin.x + 80, 0, 78, TAB_BAR_HEIGHT)];
    [btn2 setTitle:NSLocalizedString(@"login", nil) forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn2.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [UIUtility addTextShadow:btn2.titleLabel];
    btn2.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|
    UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [btn2 setBackgroundImage:[UIImage imageNamed:@"log_btn_normal"] forState:UIControlStateNormal];
    [btn2 setBackgroundImage:[UIImage imageNamed:@"log_btn_active"] forState:UIControlStateHighlighted];
    [btn2 addTarget:self action:@selector(watch)forControlEvents:UIControlEventTouchUpInside];
    [bottomToolbar addSubview:btn2];
    
    UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn3 setFrame:CGRectMake(btn2.frame.origin.x + 80, 0, 78, TAB_BAR_HEIGHT)];
    [btn3 setTitle:NSLocalizedString(@"login", nil) forState:UIControlStateNormal];
    [btn3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn3.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [UIUtility addTextShadow:btn2.titleLabel];
    btn3.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|
    UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [btn3 setBackgroundImage:[UIImage imageNamed:@"log_btn_normal"] forState:UIControlStateNormal];
    [btn3 setBackgroundImage:[UIImage imageNamed:@"log_btn_active"] forState:UIControlStateHighlighted];
    [btn3 addTarget:self action:@selector(collection)forControlEvents:UIControlEventTouchUpInside];
    [bottomToolbar addSubview:btn3];
    
    UIButton *btn4 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn4 setFrame:CGRectMake(btn3.frame.origin.x + 80, 0, 78, TAB_BAR_HEIGHT)];
    [btn4 setTitle:NSLocalizedString(@"login", nil) forState:UIControlStateNormal];
    [btn4 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn4.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [UIUtility addTextShadow:btn2.titleLabel];
    btn4.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|
    UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [btn4 setBackgroundImage:[UIImage imageNamed:@"log_btn_normal"] forState:UIControlStateNormal];
    [btn4 setBackgroundImage:[UIImage imageNamed:@"log_btn_active"] forState:UIControlStateHighlighted];
    [btn4 addTarget:self action:@selector(comment)forControlEvents:UIControlEventTouchUpInside];
    bottomToolbar.layer.zPosition = 1;
    [bottomToolbar addSubview:btn4];
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
