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
	removePreviousView = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    bgImage.image = [UIImage imageNamed:@"detail_bg"];
    
    [menuBtn removeFromSuperview];
    menuBtn = nil;
    
    closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(470, 20, 40, 42);
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
    [closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    return self;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self addKeyToLocalHistory:sBar.text];
    [searchBar resignFirstResponder];
    [table reloadData];
    SearchListViewController *viewController = [[SearchListViewController alloc] init];
    viewController.keyword = searchBar.text;
    viewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:NO];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [self addKeyToLocalHistory:sBar.text];
    [searchBar resignFirstResponder];
    [table reloadData];
    SearchListViewController *viewController = [[SearchListViewController alloc] init];
    viewController.keyword = searchBar.text;
    viewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:NO];
}

@end
