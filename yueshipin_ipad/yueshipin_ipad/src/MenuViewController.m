/*
 This module is licenced under the BSD license.
 
 Copyright (C) 2011 by raw engineering <nikhil.jain (at) raweng (dot) com, reefaq.mohammed (at) raweng (dot) com>.
 
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:
 
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
//
//  MenuViewController.m
//  StackScrollView
//
//  Created by Reefaq on 2/24/11.
//  Copyright 2011 raw engineering . All rights reserved.
//

#import "MenuViewController.h"
#import "CommonHeader.h"
#import "RootViewController.h"
#import "StackScrollViewController.h"
#import "HomeViewController.h"
#import "SettingsViewController.h"
#import "SearchViewController.h"
#import "PersonalViewController.h"
#import "DownloadViewController.h"
#import "UMGridViewController.h"

#define  TABLE_HEADER_HEIGHT 20

@interface MenuViewController () {
    HomeViewController *homeViewController;
    SettingsViewController *settingsViewController;
    SearchViewController *searchViewController;
    PersonalViewController *personalViewController;
    DownloadViewController *downloadViewController;
    UMGridViewController *appViewController;
    NSInteger selectedIndex;
    JSBadgeView *badgeView;
}

@end

@implementation MenuViewController
@synthesize tableView;


#pragma mark -
#pragma mark View lifecycle

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    homeViewController = nil;
    settingsViewController = nil;
    searchViewController = nil;
    personalViewController = nil;
    badgeView = nil;
    appViewController = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RELOAD_MENU_ITEM object:nil];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super init]) {
		[self.view setFrame:frame];
		UIImageView *leftLineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, 3, self.view.frame.size.height-27)];
        leftLineImageView.image = [[UIImage imageNamed:@"menu_left_line"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 0, 5, 0)];
        [self.view addSubview:leftLineImageView];
        
        UIImageView *bottomLineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(3, self.view.frame.size.height-27, self.view.frame.size.width -3, self.view.frame.size.height)];
        bottomLineImageView.image = [[UIImage imageNamed:@"menu_bottom_line"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 0, 5, 0)];
        [self.view addSubview:bottomLineImageView];
        
		self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(4, 6, LEFT_MENU_DIPLAY_WIDTH+4, self.view.frame.size.height - TABLE_HEADER_HEIGHT) style:UITableViewStylePlain];
        [self.tableView setSeparatorStyle:UITableViewCellSelectionStyleNone];
		[self.tableView setDelegate:self];
		[self.tableView setDataSource:self];
		[self.tableView setBackgroundColor:[UIColor clearColor]];
        [self.tableView setScrollEnabled:NO];
        
        UIView* footerView =  [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
		self.tableView.tableFooterView = footerView;
        
		[self.view addSubview:self.tableView];
		
		UIView* verticalLineView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, -5, 1, self.view.frame.size.height)];
		[verticalLineView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
		[verticalLineView setBackgroundColor:[UIColor whiteColor]];
		[self.view addSubview:verticalLineView];
		[self.view bringSubviewToFront:verticalLineView];
        
        selectedIndex = 0;
        [self initMenuController];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDownloadNum:) name:RELOAD_MENU_ITEM object:nil];
	}
    return self;
}

- (void)initMenuController
{
    CGRect frame = [UIScreen mainScreen].bounds;
    homeViewController = [[HomeViewController alloc] initWithFrame:CGRectMake(0, 0, LEFT_VIEW_WIDTH, frame.size.width)];
    
    searchViewController = [[SearchViewController alloc] initWithFrame:CGRectMake(0, 0, LEFT_VIEW_WIDTH, frame.size.width)];

    personalViewController = [[PersonalViewController alloc] initWithFrame:CGRectMake(0, 0, LEFT_VIEW_WIDTH, frame.size.width)];
    
    settingsViewController = [[SettingsViewController alloc] initWithFrame:CGRectMake(0, 0, LEFT_VIEW_WIDTH, frame.size.width)];
    
    downloadViewController = [[DownloadViewController alloc] initWithFrame:CGRectMake(0, 0, LEFT_VIEW_WIDTH, frame.size.width)];
    
    appViewController = [[UMGridViewController alloc] initWithFrame:CGRectMake(0, 0, LEFT_VIEW_WIDTH, frame.size.width)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(![AppDelegate instance].triggeredByPlayer){
        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:[self getViewControllerByIndex] invokeByController:self isStackStartView:YES removePreviousView:NO];
    }
}

- (void)updateDownloadNum:(NSNotification *)aNotification
{
    [tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(![AppDelegate instance].triggeredByPlayer){
        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:[self getViewControllerByIndex] invokeByController:self isStackStartView:YES removePreviousView:NO];
        [AppDelegate instance].closed = ![AppDelegate instance].closed;
        [[AppDelegate instance].rootViewController.stackScrollViewController menuToggle:[AppDelegate instance].closed isStackStartView:YES];
    }
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 7;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		UIView* bgView = [[UIView alloc] init];
		[bgView setBackgroundColor:[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1]];
		[cell setSelectedBackgroundView:bgView];

        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 30, 30)];
        imageView.tag = 1001;
        [cell.contentView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(60, 20, 60, 55)];
        label.textColor = CMConstants.grayColor;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:15];
        label.tag = 1002;
        [cell.contentView addSubview:label];
    }
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1001];
    UILabel *label = (UILabel *)[cell viewWithTag:1002];
    if(indexPath.row == 0){
        imageView.image = [UIImage imageNamed:@"popular_icon"];
        label.text = @"正在流行";
    } else if(indexPath.row == 1){
        imageView.image = [UIImage imageNamed:@"personal_icon"];
        label.text = @"个人主页";
    } else if(indexPath.row == 2){
        imageView.image = [UIImage imageNamed:@"searching_icon"];
        label.text = @"搜索";
    } else if(indexPath.row == 3){
//        if([@"0" isEqualToString:[AppDelegate instance].showVideoSwitch]){
        imageView.image = [UIImage imageNamed:@"download_icon"];
        label.text = @"缓存视频";
        if (badgeView) {
            [badgeView removeFromSuperview];
            badgeView = nil;
        }
        badgeView = [[JSBadgeView alloc] initWithParentView:cell alignment:JSBadgeViewAlignmentTopCenter];
        badgeView.badgePositionAdjustment = CGPointMake(50, 18);
        badgeView.badgeText = @"0";
        [badgeView setHidden:YES];
        int newNum = [ActionUtility getDownloadingItemNumber];
        if(newNum == 0){
            [badgeView setHidden:YES];
        } else {
            [badgeView setHidden:NO];
            badgeView.badgeText = [NSString stringWithFormat:@"%i", newNum];
        }
//        } else{
//            imageView.image = nil;
//            label.text = @"";
//            UIView* bgView = [[UIView alloc] init];
//            [bgView setBackgroundColor:[UIColor clearColor]];
//            [cell setSelectedBackgroundView:bgView];
//        }
    } else if(indexPath.row == 4){
        imageView.image = [UIImage imageNamed:@"recommend_icon"];
        label.text = @"精品推荐";
    } else if(indexPath.row == 5){
        UIView* bgView = [[UIView alloc] init];
		[bgView setBackgroundColor:[UIColor clearColor]];
        [cell setSelectedBackgroundView:bgView];
    } else {
        imageView.image = [UIImage imageNamed:@"settings_icon"];
        label.text = @"设置";
    }
    [label sizeToFit];
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (UIViewController *)getViewControllerByIndex
{
    if(selectedIndex == 0){
        return homeViewController;
    } else if(selectedIndex == 1){
        return personalViewController;
    } else if(selectedIndex == 2){
        return searchViewController;
    } else if(selectedIndex == 3){
//        if([@"0" isEqualToString:[AppDelegate instance].showVideoSwitch]){
            return downloadViewController;
//        } else {
//            return nil;
//        }
    } else if(selectedIndex == 4){
        return appViewController;
    } else if(selectedIndex == 5){
        return nil;
    } else {
        return settingsViewController;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndex = indexPath.row;
    if(selectedIndex == 5){
        return;
    }
    UIViewController *viewController = [self getViewControllerByIndex];
	[[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:YES removePreviousView:NO];
    if(selectedIndex < 5){
        BOOL isReachable = [[AppDelegate instance] performSelector:@selector(isParseReachable)];
        if(!isReachable) {
            [UIUtility showNetWorkError:viewController.view];
        }
    }
    [AppDelegate instance].closed = NO;
    if (selectedIndex == 6) {
        [[AppDelegate instance].rootViewController showIntroModalView:WEIBO_INTRO introImage:[UIImage imageNamed:@"weibo_intro"]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 5){
        CGRect frame = [UIScreen mainScreen].bounds;
        return frame.size.width - 60 * 6 - 50;
    } else {
        return 60;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return TABLE_HEADER_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *aView = [[UIView alloc]init];
    aView.backgroundColor = [UIColor clearColor];
    return aView;
}

@end

