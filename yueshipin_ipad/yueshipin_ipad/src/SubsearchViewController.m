//
//  SubsearchViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-28.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "SubsearchViewController.h"
#import "AddSearchListViewController.h"

@interface SubsearchViewController ()

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    bgImage.image = [UIImage imageNamed:@""];
    return self;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self addKeyToLocalHistory:sBar.text];
    [searchBar resignFirstResponder];
    [table reloadData];
    AddSearchListViewController *viewController = [[AddSearchListViewController alloc] init];
    viewController.keyword = searchBar.text;
    viewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [self addKeyToLocalHistory:sBar.text];
    [searchBar resignFirstResponder];
    [table reloadData];
    AddSearchListViewController *viewController = [[AddSearchListViewController alloc] init];
    viewController.keyword = searchBar.text;
    viewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE];
}

@end
