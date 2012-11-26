//
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
//  DataViewController.m
//  StackScrollView
//
//  Created by Reefaq on 2/24/11.
//  Copyright 2011 raw engineering . All rights reserved.
//

#import "DataViewController.h"
#import "RootViewController.h"
#import "StackScrollViewController.h"
#import "DetailViewController.h"
#import "DataDetailViewController.h"

@implementation DataViewController
@synthesize tableView;
@synthesize menuViewControllerDelegate;

#pragma mark -
#pragma mark View lifecycle

- (id)initWithFrame:(CGRect)frame {
    if (self = [super init]) {
		[self.view setFrame:frame]; 

		self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
		[self.tableView setDelegate:self];
		[self.tableView setDataSource:self];

        UIView* footerView =  [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
		self.tableView.tableFooterView = footerView;
        
		[self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
		[self.view addSubview:self.tableView];
        
        menuBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        menuBtn.frame = CGRectMake(0, 0, 100, 50);
        [menuBtn setTitle:@"菜单" forState:UIControlStateNormal];
        [menuBtn addTarget:self action:@selector(menuBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:menuBtn];
	}
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)menuBtnClicked
{
//    CGRect frame = [UIScreen mainScreen].bounds;
//    DataViewController *dataViewController = [[DataViewController alloc] initWithFrame:CGRectMake(0, 0, frame.size.height/2, frame.size.height)];
//    //TODO: invokedBYController should be MENU controller
//	[[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:dataViewController invokeByController:self.menuViewController isStackStartView:TRUE];
//    [[AppDelegate instance].rootViewController.stackScrollViewController menuToggle:closed isStackStartView:YES];
//    closed = !closed;
    [self.menuViewControllerDelegate menuButtonClicked];
}

- (void)closeMenu
{
    [AppDelegate instance].closed = YES;
    [[AppDelegate instance].rootViewController.stackScrollViewController menuToggle:YES isStackStartView:YES];
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
    return 5;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
	cell.textLabel.text = [NSString stringWithFormat:@"Data %d", indexPath.row];
	cell.textLabel.textColor = [UIColor blackColor];

    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self closeMenu];
    CGRect frame = [UIScreen mainScreen].bounds;
    if(indexPath.row == 4){
        DataDetailViewController *dataViewController = [[DataDetailViewController alloc] initWithNibName:@"DataDetailViewController" bundle:nil];
        dataViewController.view.frame = CGRectMake(frame.size.height, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:dataViewController invokeByController:self isStackStartView:FALSE];

    } else {
        DetailViewController *dataViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
        dataViewController.view.frame = CGRectMake(frame.size.height + LEFT_MENU_DIPLAY_WIDTH, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:dataViewController invokeByController:self isStackStartView:FALSE];
    }
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self clearMemory];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [self clearMemory];
}

- (void)clearMemory
{
    self.tableView = nil;
    menuBtn = nil;
}


@end

