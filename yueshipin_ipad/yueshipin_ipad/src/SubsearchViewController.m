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
	removePreviousView = NO;
    self.moveToLeft = YES;
    [self.view addGestureRecognizer:self.swipeRecognizer];
    
    [self setCloseTipsViewHidden:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.bgImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.bgImage.image = [UIImage imageNamed:@"left_background@2x.jpg"];
    self.bgImage.layer.zPosition = -1;
    [self.view addSubview:self.bgImage];
    
    closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(456, 0, 50, 50);
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
