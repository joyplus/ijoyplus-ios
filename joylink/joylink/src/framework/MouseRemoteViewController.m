//
//  MouseRemoteViewController.m
//  joylink
//
//  Created by joyplus1 on 13-4-27.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "MouseRemoteViewController.h"
#import "CommonHeader.h"
#import "MoveView.h"
#import "UpDownScrollView.h"
#import "LeftRightScrollView.h"

@interface MouseRemoteViewController ()

@end

@implementation MouseRemoteViewController

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
    UILabel *title = (UILabel *)[self.navBar viewWithTag:TITLE_TAG];
    title.text = @"鼠标";
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addCenterControl
{
    UIView *remoteToolBar = (UIView *)[self.view viewWithTag:REMOTE_TOOLBAR_TAG];
    
    MoveView *touchView = nil;
    if ([CommonMethod isIphone5]) {
        touchView = [[MoveView alloc]initWithFrame:CGRectMake(12, remoteToolBar.frame.origin.y + remoteToolBar.frame.size.height + 5, self.view.frame.size.width - 80, 335)];
    } else {
        touchView = [[MoveView alloc]initWithFrame:CGRectMake(12, remoteToolBar.frame.origin.y + remoteToolBar.frame.size.height + 5, self.view.frame.size.width - 80, 245)];
    }
    touchView.backgroundColor = [UIColor clearColor];
    
    UIImageView *bgImage = [[UIImageView alloc]initWithFrame:CGRectMake(touchView.frame.origin.x, touchView.frame.origin.y, 296, touchView.frame.size.height + 60)];
    bgImage.image = [[UIImage imageNamed:@"mouse_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 0, 5, 0)];
    [self.view addSubview:bgImage];
    
    UIImageView *rightScroll = [[UIImageView alloc]initWithFrame:CGRectMake(275, touchView.frame.origin.y + 13, 12, 295 - 13 - 25)];
    rightScroll.image = [[UIImage imageNamed:@"mouse_y"]resizableImageWithCapInsets:UIEdgeInsetsMake(5, 0, 5, 0)];
    [self.view addSubview:rightScroll];
    
    UIImageView *bottomScroll = [[UIImageView alloc]initWithFrame:CGRectMake(touchView.frame.origin.x + 30, touchView.frame.origin.y + touchView.frame.size.height + 35, touchView.frame.size.width - 40, 12)];
    bottomScroll.image = [[UIImage imageNamed:@"mouse_x"]resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    [self.view addSubview:bottomScroll];
    
    [self.view addSubview:touchView];
    
    UpDownScrollView *scrollUpDownView = [[UpDownScrollView alloc]initWithFrame:CGRectMake(touchView.frame.size.width, touchView.frame.origin.y, 60, touchView.frame.size.height)];
    scrollUpDownView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:scrollUpDownView];
    
    LeftRightScrollView *scrollLeftRightView = [[LeftRightScrollView alloc]initWithFrame:CGRectMake(touchView.frame.origin.x, touchView.frame.origin.y + touchView.frame.size.height,  touchView.frame.size.width, 60)];
    scrollLeftRightView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:scrollLeftRightView];
}

@end
