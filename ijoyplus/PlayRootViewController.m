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
#import "SendCommentViewController.h"
#import "AppDelegate.h"
#import "UIUtility.h"
#import "CMConstants.h"
#import "StringUtility.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "RecommandViewController.h"
#import "MBProgressHUD.h"
#import "ContainerUtility.h"
#import "PostViewController.h"

@interface PlayRootViewController (){
    UISwipeGestureRecognizer *leftGesture;
    UISwipeGestureRecognizer *rightGesture;
    UIToolbar *bottomToolbar;
}
- (void)closeSelf;

@end

@implementation PlayRootViewController


- (void)viewDidUnload
{
    leftGesture = nil;
    rightGesture = nil;
    bottomToolbar = nil;
    self.programId = nil;
    previousViewController = nil;
    nextViewController = nil;
    currentViewController = nil;
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.title = NSLocalizedString(@"app_name", nil);
    CustomBackButtonHolder *backButtonHolder = [[CustomBackButtonHolder alloc]initWithViewController:self];
    CustomBackButton* backButton = [backButtonHolder getBackButton:NSLocalizedString(@"go_back", nil)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"share", nil) style:UIBarButtonSystemItemSearch target:self action:@selector(share)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [self initViewController];
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

- (void)initViewController
{
    currentViewController = [[PlayViewController alloc]initWithNibName:@"PlayViewController" bundle:nil];
    ((PlayViewController *)currentViewController).programId = self.programId;
    //    previousViewController = [[PlayViewController alloc]initWithNibName:@"PlayViewController" bundle:nil];
    //    nextViewController = [[PlayViewController alloc]initWithNibName:@"PlayViewController" bundle:nil];
    [self addChildViewController:currentViewController];
    currentViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - TAB_BAR_HEIGHT);
    [self.view addSubview:currentViewController.view];
}

- (void)share
{
    NSString *userid = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId];
    if([StringUtility stringIsEmpty:userid]){
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = @"请登陆！";
        [HUD show:YES];
        [HUD hide:YES afterDelay:1.5];
    } else {
        PostViewController *viewController = [[PostViewController alloc]initWithNibName:@"PostViewController" bundle:nil];
        viewController.programId = self.programId;
        [self.navigationController pushViewController:viewController animated:YES];
    }
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
    //    nextViewController = currentViewController;
    //    [currentViewController.view removeFromSuperview];
    //    [currentViewController removeFromParentViewController];
    //    currentViewController = previousViewController;
    //    previousViewController = [[PlayViewController alloc]initWithNibName:@"PlayViewController" bundle:nil];
    //    [self.view addSubview:currentViewController.view];
    //    CATransition *animation = [AnimationFactory pushToLeftAnimation:^{
    //        currentViewController.view.frame = self.view.bounds;
    //    }];
    //    [[self.view layer] addAnimation:animation forKey:@"animation"];
}

- (void)nextAction
{
    //    previousViewController = currentViewController;
    //    [currentViewController.view removeFromSuperview];
    //    [currentViewController removeFromParentViewController];
    //    currentViewController = nextViewController;
    //    nextViewController = [[PlayViewController alloc]initWithNibName:@"PlayViewController" bundle:nil];
    //    [self.view addSubview:currentViewController.view];
    //    CATransition *animation = [AnimationFactory pushToRightAnimation:^{
    //        currentViewController.view.frame = self.view.bounds;
    //    }];
    //    [[self.view layer] addAnimation:animation forKey:@"animation"];
    
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
    [btn1 setTitle:NSLocalizedString(@"recommand_toolbar", nil) forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn1.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [UIUtility addTextShadow:btn1.titleLabel];
    btn1.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|
    UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [btn1 setBackgroundImage:[UIImage imageNamed:@"tab1"] forState:UIControlStateNormal];
    [btn1 setBackgroundImage:[UIUtility createImageWithColor:[UIColor blackColor]] forState:UIControlStateHighlighted];
    [btn1 addTarget:self action:@selector(recommand)forControlEvents:UIControlEventTouchUpInside];
    [bottomToolbar addSubview:btn1];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn2 setFrame:CGRectMake(btn1.frame.origin.x + 80, 0, 78, TAB_BAR_HEIGHT)];
    [btn2 setTitle:NSLocalizedString(@"watch_toolbar", nil) forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn2.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [UIUtility addTextShadow:btn2.titleLabel];
    btn2.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|
    UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [btn2 setBackgroundImage:[UIImage imageNamed:@"tab2"] forState:UIControlStateNormal];
    [btn2 setBackgroundImage:[UIUtility createImageWithColor:[UIColor blackColor]]forState:UIControlStateHighlighted];
    [btn2 addTarget:self action:@selector(watch)forControlEvents:UIControlEventTouchUpInside];
    [bottomToolbar addSubview:btn2];
    
    UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn3 setFrame:CGRectMake(btn2.frame.origin.x + 80, 0, 78, TAB_BAR_HEIGHT)];
    [btn3 setTitle:NSLocalizedString(@"collect_toolbar", nil) forState:UIControlStateNormal];
    [btn3 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn3.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [UIUtility addTextShadow:btn2.titleLabel];
    btn3.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|
    UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [btn3 setBackgroundImage:[UIImage imageNamed:@"tab3"] forState:UIControlStateNormal];
    [btn3 setBackgroundImage:[UIUtility createImageWithColor:[UIColor blackColor]] forState:UIControlStateHighlighted];
    [btn3 addTarget:self action:@selector(collection)forControlEvents:UIControlEventTouchUpInside];
    [bottomToolbar addSubview:btn3];
    
    UIButton *btn4 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn4 setFrame:CGRectMake(btn3.frame.origin.x + 80, 0, 78, TAB_BAR_HEIGHT)];
    [btn4 setTitle:NSLocalizedString(@"comment_toolbar", nil) forState:UIControlStateNormal];
    [btn4 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn4.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [UIUtility addTextShadow:btn2.titleLabel];
    btn4.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|
    UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [btn4 setBackgroundImage:[UIImage imageNamed:@"tab4"] forState:UIControlStateNormal];
    [btn4 setBackgroundImage:[UIUtility createImageWithColor:[UIColor blackColor]] forState:UIControlStateHighlighted];
    [btn4 addTarget:self action:@selector(comment)forControlEvents:UIControlEventTouchUpInside];
    bottomToolbar.layer.zPosition = 1;
    [bottomToolbar addSubview:btn4];
}

- (void)recommand
{
    NSString *userid = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId];
    if([StringUtility stringIsEmpty:userid]){
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = @"请登陆！";
        [HUD show:YES];
        [HUD hide:YES afterDelay:1.5];
    } else {
        RecommandViewController *viewController = [[RecommandViewController alloc]initWithNibName:@"RecommandViewController" bundle:nil];
        viewController.programId = self.programId;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)watch
{
    NSString *userid = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId];
    if([StringUtility stringIsEmpty:userid]){
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = @"请登陆！";
        [HUD show:YES];
        [HUD hide:YES afterDelay:1.5];
    } else {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    kAppKey, @"app_key",
                                    self.programId, @"prod_id",
                                    nil];
        [[AFServiceAPIClient sharedClient] postPath:kPathProgramWatch parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            NSString *responseCode = [result objectForKey:@"res_code"];
            if([responseCode isEqualToString:kSuccessResCode]){
                MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
                [self.navigationController.view addSubview:HUD];
                HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.labelText = NSLocalizedString(@"mark_success", nil);
                HUD.dimBackground = YES;
                [HUD show:YES];
                [HUD hide:YES afterDelay:1];
                [self viewDidLoad];
            } else {
                
            }
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
}

- (void)collection
{
    NSString *userid = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId];
    if([StringUtility stringIsEmpty:userid]){
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = @"请登陆！";
        [HUD show:YES];
        [HUD hide:YES afterDelay:1.5];
    } else {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    kAppKey, @"app_key",
                                    self.programId, @"prod_id",
                                    nil];
        [[AFServiceAPIClient sharedClient] postPath:kPathProgramFavority parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            NSString *responseCode = [result objectForKey:@"res_code"];
            if([responseCode isEqualToString:kSuccessResCode]){
                MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
                [self.navigationController.view addSubview:HUD];
                HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.labelText = NSLocalizedString(@"collection_success", nil);
                HUD.dimBackground = YES;
                [HUD show:YES];
                [HUD hide:YES afterDelay:1];
                [self viewDidLoad];
            } else {
            }
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
}

- (void)comment
{
    NSString *userid = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId];
    if([StringUtility stringIsEmpty:userid]){
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = @"请登陆！";
        [HUD show:YES];
        [HUD hide:YES afterDelay:1.5];
    } else {
        SendCommentViewController *viewController = [[SendCommentViewController alloc]initWithNibName:@"SendCommentViewController" bundle:nil];
        viewController.programId = self.programId;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

@end
