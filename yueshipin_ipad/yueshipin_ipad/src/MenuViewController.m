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
#import "PopularTopViewController.h"
#import "PopularListViewController.h"
#import "MovieViewController.h"
#import "DramaViewController.h"
#import "ShowViewController.h"
#import "ComicViewController.h"
#import "SettingsViewController.h"
#import "SearchViewController.h"
#import "PersonalViewController.h"
#import "DownloadViewController.h"
#import "UMGridViewController.h"

#define  TABLE_HEADER_HEIGHT 20

@interface MenuViewController () {
    PopularTopViewController *topViewController;
    PopularListViewController *listViewController;
    MovieViewController *movieViewController;
    DramaViewController *dramaViewController;
    ComicViewController *comicViewController;
    ShowViewController *showViewController;
    SearchViewController *searchViewController;
    PersonalViewController *personalViewController;
    DownloadViewController *downloadViewController;
    UMGridViewController *appViewController;
    SettingsViewController *settingsViewController;
    NSInteger selectedIndex;
}

@property (nonatomic, strong) NSArray *menuIconArray;
@property (nonatomic, strong) JSBadgeView *badgeView;
@end

@implementation MenuViewController
@synthesize tableView;
@synthesize menuIconArray;
@synthesize badgeView;

#pragma mark -
#pragma mark View lifecycle

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    badgeView = nil;
    appViewController = nil;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super init]) {
		[self.view setFrame:frame];
//		UIImageView *leftLineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, 3, self.view.frame.size.height-27)];
//        leftLineImageView.image = [[UIImage imageNamed:@"menu_left_line"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 0, 5, 0)];
//        [self.view addSubview:leftLineImageView];
//        
//        UIImageView *bottomLineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(3, self.view.frame.size.height-27, self.view.frame.size.width -3, self.view.frame.size.height)];
//        bottomLineImageView.image = [[UIImage imageNamed:@"menu_bottom_line"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 0, 5, 0)];
//        [self.view addSubview:bottomLineImageView];
        
        menuIconArray = [NSArray arrayWithObjects:@"popular_top", @"popular_list", @"movie_icon", @"drama_icon", @"show_icon", @"comic_icon", @"search_icon", @"personal_icon", @"download_icon", @"recommend_icon", @"", @"setting_icon", nil];
		self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, LEFT_MENU_DIPLAY_WIDTH, self.view.frame.size.height - TABLE_HEADER_HEIGHT) style:UITableViewStylePlain];
        [self.tableView setSeparatorStyle:UITableViewCellSelectionStyleNone];
		[self.tableView setDelegate:self];
		[self.tableView setDataSource:self];
		[self.tableView setBackgroundColor:[UIColor clearColor]];
        [self.tableView setScrollEnabled:NO];
        
        UIView* footerView =  [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
		self.tableView.tableFooterView = footerView;
        
		[self.view addSubview:self.tableView];
		
//		UIView* verticalLineView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, -5, 1, self.view.frame.size.height)];
//		[verticalLineView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
//		[verticalLineView setBackgroundColor:[UIColor whiteColor]];
//		[self.view addSubview:verticalLineView];
//		[self.view bringSubviewToFront:verticalLineView];
        
        selectedIndex = 0;
        [self initMenuController];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDownloadNum:) name:UPDATE_DOWNLOAD_ITEM_NUM object:nil];
	}
    return self;
}

- (void)initMenuController
{
    CGRect frame = [UIScreen mainScreen].bounds;
    topViewController = [[PopularTopViewController alloc] initWithFrame:CGRectMake(0, 0, LEFT_VIEW_WIDTH, frame.size.width)];
    
    listViewController = [[PopularListViewController alloc] initWithFrame:CGRectMake(0, 0, LEFT_VIEW_WIDTH, frame.size.width)];
    
    movieViewController = [[MovieViewController alloc] initWithFrame:CGRectMake(0, 0, FULL_SCREEN_WIDTH, frame.size.width)];
    
    dramaViewController = [[DramaViewController alloc] initWithFrame:CGRectMake(0, 0, FULL_SCREEN_WIDTH, frame.size.width)];
    
    showViewController = [[ShowViewController alloc] initWithFrame:CGRectMake(0, 0, FULL_SCREEN_WIDTH, frame.size.width)];
    
    comicViewController = [[ComicViewController alloc] initWithFrame:CGRectMake(0, 0, FULL_SCREEN_WIDTH, frame.size.width)];
    
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
    badgeView.badgePositionAdjustment = CGPointMake(15, 18);
    badgeView.badgeText = @"0";
    [badgeView setHidden:YES];
    int newNum = [ActionUtility getDownloadingItemNumber];
    if(newNum == 0){
        [badgeView setHidden:YES];
    } else {
        [badgeView setHidden:NO];
        badgeView.badgeText = [NSString stringWithFormat:@"%i", newNum];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(![AppDelegate instance].triggeredByPlayer){
        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:[self getViewControllerByIndex] invokeByController:self isStackStartView:YES removePreviousView:NO];
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
    return 12;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellEditingStyleNone;
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(3, 0, 74, 62)];
        imageView.tag = 1001;
        [cell.contentView addSubview:imageView];
    }
    if(indexPath.row == 8){
        if (badgeView == nil) {
            badgeView = [[JSBadgeView alloc] initWithParentView:cell alignment:JSBadgeViewAlignmentTopCenter];
        }
        [self updateDownloadNum:nil];
    }
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1001];
    if(indexPath.row == 0){
        imageView.image = [UIImage imageNamed:@"popular_top_selected"];
    } else if(indexPath.row == 10){
        imageView.image = nil;
    } else {
        if (indexPath.row < menuIconArray.count) {
            imageView.image = [UIImage imageNamed:[menuIconArray objectAtIndex:indexPath.row]];
        }
    }

    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (UIViewController *)getViewControllerByIndex
{
    if(selectedIndex == 0){
        return topViewController;
    } else if(selectedIndex == 1){
        return listViewController;
    } else if(selectedIndex == 2){
        return movieViewController;
    } else if(selectedIndex == 3){
        return dramaViewController;
    } else if(selectedIndex == 5){
        return showViewController;
    } else if(selectedIndex == 4){
        return comicViewController;
    } else if(selectedIndex == 6){
        return searchViewController;
    } else if(selectedIndex == 7){
        return personalViewController;
    } else if(selectedIndex == 8){
        return downloadViewController;
    } else if(selectedIndex == 9){
        return appViewController;
    } else if(selectedIndex == 10){
        return nil;
    } else {
        return settingsViewController;
    }
}

- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndex = indexPath.row;
    if(selectedIndex == 10){
        return;
    }
    for (int i = 0; i < 12; i++) {
        UITableViewCell *cell = [atableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:1001];
        if (i < menuIconArray.count) {
            imageView.image = [UIImage imageNamed:[menuIconArray objectAtIndex:i]];
        }
    }
    UITableViewCell *cell = [atableView cellForRowAtIndexPath:indexPath];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1001];
    if (indexPath.row < menuIconArray.count) {
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_selected", [menuIconArray objectAtIndex:indexPath.row]]];
    }
    
    UIViewController *viewController = [self getViewControllerByIndex];
    if (indexPath.row > 1 && indexPath.row < 6) {
        VideoViewController *videoViewController = (VideoViewController *)viewController;
        videoViewController.revertSearchCriteria = YES;
    }
	[[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:YES removePreviousView:NO];
    if(selectedIndex < 10){
        BOOL isReachable = [[AppDelegate instance] performSelector:@selector(isParseReachable)];
        if(!isReachable) {
            [UIUtility showNetWorkError:viewController.view];
        }
    }
    [AppDelegate instance].closed = NO;
    if (selectedIndex == 11) {
        [[AppDelegate instance].rootViewController showIntroModalView:WEIBO_INTRO introImage:[UIImage imageNamed:@"weibo_intro"]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 10){
        CGRect frame = [UIScreen mainScreen].bounds;
        return frame.size.width - 62 * 11 - 50;
    } else {
        return 62;
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

