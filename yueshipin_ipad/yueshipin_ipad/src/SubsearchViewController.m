//
//  SubsearchViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-28.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "SubsearchViewController.h"
#import "SearchListViewController.h"

@interface SubsearchViewController (){
    UIButton *closeBtn;
}

@end

@implementation SubsearchViewController
@synthesize moveToLeft;

- (void)viewDidUnload
{
    [super viewDidUnload];
    closeBtn = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:CMConstants.backgroundColor];
	removePreviousView = NO;
    self.moveToLeft = YES;
    [self.view addGestureRecognizer:swipeRecognizer];
    
    [self.view removeGestureRecognizer:closeMenuRecognizer];
    [self.view removeGestureRecognizer:swipeCloseMenuRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view setBackgroundColor:CMConstants.backgroundColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    bgImage.image = nil;
    [bgImage removeFromSuperview];
    
    [menuBtn removeFromSuperview];
    
    closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(465, 20, 40, 42);
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
    [closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    return self;
}

- (void)search:(NSString *)keyword
{
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([hostReach currentReachabilityStatus] == NotReachable) {
        [UIUtility showNetWorkError:self.view];
        return;
    }
    keyword = [keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    sBar.text = keyword;
    [self closeMenu];
    [self addKeyToLocalHistory:keyword];
    [sBar resignFirstResponder];
    SearchListViewController *viewController = [[SearchListViewController alloc] init];
    viewController.keyword = keyword;
    viewController.fromViewController = self;
    viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
    [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:removePreviousView moveToLeft:self.moveToLeft];
    self.moveToLeft = NO;
}

- (void)closeBtnClicked
{
    self.moveToLeft = YES;
    [[AppDelegate instance].rootViewController.stackScrollViewController removeViewInSlider:self];
}
@end
