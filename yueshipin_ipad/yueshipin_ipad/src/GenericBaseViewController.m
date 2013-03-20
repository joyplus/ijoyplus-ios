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
#import "CloseTipsView.h"

#define CLOSE_TIPS_VIEW_TAG (1111)

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
    closeMenuRecognizer.numberOfTapsRequired = 1;
    
    swipeCloseMenuRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(closeMenu)];
    swipeCloseMenuRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeCloseMenuRecognizer.numberOfTouchesRequired=1;
    
    menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 28, 60, 60);
    [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu_btn"] forState:UIControlStateNormal];
    [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu_btn_pressed"] forState:UIControlStateHighlighted];
    [menuBtn addTarget:self action:@selector(menuBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    CloseTipsView * cView = [[CloseTipsView alloc] initWithFrame:CGRectMake(0, 627, self.view.frame.size.width, 121)];
    [self.view addSubview:cView];
    cView.tag = CLOSE_TIPS_VIEW_TAG;
    cView.hidden = YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    myHUD = nil;
    swipeRecognizer = nil;
    openMenuRecognizer = nil;
    closeMenuRecognizer = nil;
    swipeCloseMenuRecognizer = nil;
    menuBtn = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"didReceiveMemoryWarning");
}

- (void)closeMenu
{
    [AppDelegate instance].closed = YES;
    [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu_btn"] forState:UIControlStateNormal];
    [[AppDelegate instance].rootViewController.stackScrollViewController menuToggle:YES isStackStartView:YES];
}

- (void)menuBtnClicked
{
    [[AppDelegate instance].rootViewController.stackScrollViewController removeAllSubviewInSlider];
    [AppDelegate instance].closed = ![AppDelegate instance].closed;
    if ([AppDelegate instance].closed) {
        [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu_btn"] forState:UIControlStateNormal];
    } else {
        [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu_btn_pressed"] forState:UIControlStateNormal];
    }
    [[AppDelegate instance].rootViewController.stackScrollViewController menuToggle:[AppDelegate instance].closed isStackStartView:YES];
    [[AppDelegate instance].rootViewController showIntroModalView:DOWNLOAD_SETTING_INTRO introImage:[UIImage imageNamed:@"download_setting_intro"]];
}

- (void)closeBtnClicked
{
    [[AppDelegate instance].rootViewController.stackScrollViewController removeViewInSlider];
}

-(float)getFreeDiskspacePercent
{
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace_ = [fileSystemSizeInBytes floatValue]/1024.0f/1024.0f/1024.0f;
        totalFreeSpace_ = [freeFileSystemSizeInBytes floatValue]/1024.0f/1024.0f/1024.0f;
    }
    float percent = (totalSpace_-totalFreeSpace_)/totalSpace_;
    return percent;
}

- (void)setCloseTipsViewHidden:(BOOL)isHidden
{
    UIView * cView = [self.view viewWithTag:CLOSE_TIPS_VIEW_TAG];
    if (NO == isHidden)
    {
        [self.view bringSubviewToFront:cView];
    }
    cView.hidden = isHidden;
}

@end
