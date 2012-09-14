//
//  PathViewController.m
//  RaisedCenterTabBar
//
//  Created by Peter Boctor on 12/15/10.
//
// Copyright (c) 2011 Peter Boctor
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE
//

#import "BottomTabViewController.h"
#import "UIImageView+WebCache.h"
#import "FriendTabViewController.h"
#import "ListTabViewController.h"
#import "MyselfViewController.h"
#import "PopularSegmentViewController.h"
@interface BottomTabViewController (){
    PopularSegmentViewController *detailController1;
    FriendTabViewController *detailController2;
    ListTabViewController *detailController3;
    MyselfViewController *detailController4;
}
- (void)initTabControllers;
-(UINavigationController*) addNavigation:(UIViewController*) rootViewController;
@end

@implementation BottomTabViewController

- (void)viewDidUnload {
    [super viewDidUnload];
    detailController1 = nil;
    detailController2 = nil;
    detailController3 = nil;
    detailController4 = nil;
}

- (id)init {
    if ((self = [super init])) {
    }
    self.delegate = self;
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"app_name", nil);
    self.delegate = self;
    [self initTabControllers];
    self.viewControllers = [NSArray arrayWithObjects: detailController1, detailController2, detailController3,detailController4, nil];
    [self setSelectedIndex:0];
}

- (void)initTabControllers
{
    detailController1 = [[PopularSegmentViewController alloc] initWithNibName:@"PopularSegmentViewController" bundle:nil];
    detailController1.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"popular", nil)  image:[UIImage imageNamed:@"pop_tab"] tag:0];
    
    detailController2 = [[FriendTabViewController alloc] init];
    detailController2.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"friend", nil) image:[UIImage imageNamed:@"rec_tab"] tag:0];
    detailController3 = [[ListTabViewController alloc] init];
    detailController3.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"list", nil) image:[UIImage imageNamed:@"list_tab"] tag:0];
    
    detailController4 = [[MyselfViewController alloc]initWithNibName:@"MyselfViewController" bundle:nil];
    detailController4.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"myself", nil) image:[UIImage imageNamed:@"my_tab"] tag:0];
}

-(UINavigationController*) addNavigation:(UIViewController*) rootViewController
{
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    rootViewController.navigationItem.titleView = [UIUtility customizeAppTitle];
    return navController;
}

#pragma mark - Tab bar delegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if([viewController isKindOfClass:[PopularSegmentViewController class]]){
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"search", nil) style:UIBarButtonSystemItemSearch target:self action:@selector(search)];
        self.navigationItem.rightBarButtonItem = rightButton;
    }
    return YES;
}
@end
