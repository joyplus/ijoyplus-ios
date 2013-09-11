//
//  ViewController.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-21.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "HomeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CommonHeader.h"
#import "GMGridView.h"
#import "FPPopoverController.h"
#import "DeviceListViewController.h"
#import "GroupImageViewController.h"
#import "VideoGridViewController.h"
#import "MusicListViewController.h"
#import "NewRemoteViewController.h"
#import "BrowserViewController.h"
#import "AppListViewController.h"
#import "SettingsViewController.h"
#import "TestSocketViewController.h"

#define NUMBER_ITEMS_ON_LOAD 6
#define ICON_WIDTH 108
#define ICON_HEIGHT 108

@interface HomeViewController () <GMGridViewDataSource, GMGridViewActionDelegate>{
    __gm_weak GMGridView *_gmGridView;
    NSMutableArray *_data;
}

@property (nonatomic, strong)GroupImageViewController *groupViewController;
@property (nonatomic, strong)MusicListViewController *musicListViewController;
@property (nonatomic, strong)VideoGridViewController *videoGridViewController;
@property (nonatomic, strong)BrowserViewController *browserViewController;
@property (nonatomic, strong)AppListViewController *appListViewController;
@property (nonatomic, strong)NewRemoteViewController *remoteViewController;

@end

@implementation HomeViewController
@synthesize groupViewController, musicListViewController, videoGridViewController;
@synthesize browserViewController, appListViewController, remoteViewController;
- (void)viewDidUnload
{
    [super viewDidUnload];
    _gmGridView = nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (id)init
{
    if ((self =[super init])){
        _data = [[NSMutableArray alloc] init];
        for (int i = 0; i < NUMBER_ITEMS_ON_LOAD; i ++){
            [_data addObject:[NSString stringWithFormat:@"%d", i]];
        }
    }
    return self;
}

- (void)viewDidLoad
{
//    [super loadView];
//    NSInteger spacing = 10;
//    GMGridView *gmGridView = [[GMGridView alloc] initWithFrame:CGRectMake(10, 10, GRID_VIEW_WIDTH, GRID_VIEW_HEIGHT)];
//    gmGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    gmGridView.backgroundColor = [UIColor clearColor];
//    gmGridView.scrollView.scrollEnabled = NO;
//    [self.view addSubview:gmGridView];
//    _gmGridView = gmGridView;
//    
//    _gmGridView.style = GMGridViewStyleSwap;
//    _gmGridView.itemSpacing = spacing;
//    _gmGridView.minEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
//    _gmGridView.centerGrid = YES;
//    _gmGridView.actionDelegate = self;
//    _gmGridView.dataSource = self;
    [super viewDidLoad];
    for(int i = 0; i < 6; i++){
        UIButton *imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        imageBtn.frame = CGRectMake(14 + (i%2)*(ICON_WIDTH + 10), 10 + floor(i/2.0)*(ICON_HEIGHT + 10), ICON_WIDTH, ICON_HEIGHT);
        [imageBtn addTarget:self action:@selector(imageBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        imageBtn.tag = 1101 + i;
        [self.view addSubview:imageBtn];
        switch (i) {
            case 0:
                [imageBtn setBackgroundImage:[UIImage imageNamed:@"pic"] forState:UIControlStateNormal];
                [imageBtn setBackgroundImage:[UIImage imageNamed:@"pic_pressed"] forState:UIControlStateHighlighted];
                break;
            case 1:
                [imageBtn setBackgroundImage:[UIImage imageNamed:@"music"] forState:UIControlStateNormal];
                [imageBtn setBackgroundImage:[UIImage imageNamed:@"music_pressed"] forState:UIControlStateHighlighted];
                break;
            case 2:
                [imageBtn setBackgroundImage:[UIImage imageNamed:@"movie"] forState:UIControlStateNormal];
                [imageBtn setBackgroundImage:[UIImage imageNamed:@"movie_pressed"] forState:UIControlStateHighlighted];
                break;
            case 3:
                [imageBtn setBackgroundImage:[UIImage imageNamed:@"browser"] forState:UIControlStateNormal];
                [imageBtn setBackgroundImage:[UIImage imageNamed:@"browser_pressed"] forState:UIControlStateHighlighted];
                break;
            case 4:
                [imageBtn setBackgroundImage:[UIImage imageNamed:@"app"] forState:UIControlStateNormal];
                [imageBtn setBackgroundImage:[UIImage imageNamed:@"app_pressed"] forState:UIControlStateHighlighted];
                break;
            case 5:
                [imageBtn setBackgroundImage:[UIImage imageNamed:@"remote"] forState:UIControlStateNormal];
                [imageBtn setBackgroundImage:[UIImage imageNamed:@"remote_pressed"] forState:UIControlStateHighlighted];
                break;
            default:
                break;
        }
    }
    
//    UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    playBtn.frame = CGRectMake(self.view.bounds.size.width - 50, 20, 35, 35);
//    playBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
//    [playBtn setBackgroundImage:[UIImage imageNamed:@"equ_btn"] forState:UIControlStateNormal];
//    [playBtn setBackgroundImage:[UIImage imageNamed:@"equ_btn_pressed"] forState:UIControlStateHighlighted];
//    [playBtn addTarget:self action:@selector(selectDevice:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:playBtn];
    
    MPVolumeView *routeBtn = [[MPVolumeView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 50, 20, 35, 35)];
    [routeBtn setBackgroundColor:[UIColor clearColor]];
    [routeBtn setShowsVolumeSlider:NO];
    [routeBtn setShowsRouteButton:YES];
    [self.view addSubview:routeBtn];
    
    for (UIView *asubview in routeBtn.subviews) {
        if ([NSStringFromClass(asubview.class) isEqualToString:@"MPButton"]) {
            UIButton *btn = (UIButton *)asubview;
            btn.frame = CGRectMake(0, 0, 35, 35);
            [btn setImage:nil forState:UIControlStateNormal];
            [btn setImage:nil forState:UIControlStateHighlighted];
            [btn setImage:nil forState:UIControlStateSelected];
            [btn setBackgroundImage:[UIImage imageNamed:@"equ_btn"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"equ_btn_pressed"] forState:UIControlStateHighlighted];
        }
    }
    
    UIButton *testBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    testBtn.frame = CGRectMake(self.view.bounds.size.width - 50, self.view.bounds.size.height - 250, 33, 33);
    [testBtn setTitle:@"TestSocket" forState:UIControlStateNormal];
    [testBtn addTarget:self action:@selector(testBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testBtn];
    
    UIButton *settingsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    settingsBtn.frame = CGRectMake(self.view.bounds.size.width - 50, self.view.bounds.size.height - 50, 33, 33);
    settingsBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [settingsBtn setBackgroundImage:[UIImage imageNamed:@"setting_btn"] forState:UIControlStateNormal];
    [settingsBtn setBackgroundImage:[UIImage imageNamed:@"setting_btn_pressed"] forState:UIControlStateHighlighted];
    [settingsBtn addTarget:self action:@selector(settingBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:settingsBtn];
}

- (void)testBtnClicked
{
    TestSocketViewController *viewController = [[TestSocketViewController alloc]initWithNibName:@"TestSocketViewController" bundle:nil];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


//////////////////////////////////////////////////////////////
#pragma mark GMGridViewDataSource
//////////////////////////////////////////////////////////////

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return NUMBER_ITEMS_ON_LOAD;
}

- (CGSize)sizeForItemsInGMGridView:(GMGridView *)gridView
{
    return CGSizeMake(ICON_WIDTH, ICON_HEIGHT);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    //NSLog(@"Creating view indx %d", index);
    
    CGSize size = [self sizeForItemsInGMGridView:gridView];
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    if (!cell){
        cell = [[GMGridViewCell alloc] init];       
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        view.backgroundColor = [UIColor clearColor];
        cell.contentView = view;
    }    
    UIButton *imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    imageBtn.frame = cell.contentView.frame;
    [imageBtn addTarget:self action:@selector(imageBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    imageBtn.tag = 1101 + index;
    [cell.contentView addSubview:imageBtn];
    switch (index) {
        case 0:
            [imageBtn setBackgroundImage:[UIImage imageNamed:@"pic"] forState:UIControlStateNormal];
            [imageBtn setBackgroundImage:[UIImage imageNamed:@"pic_pressed"] forState:UIControlStateHighlighted];
            break;
        case 1:
            [imageBtn setBackgroundImage:[UIImage imageNamed:@"music"] forState:UIControlStateNormal];
            [imageBtn setBackgroundImage:[UIImage imageNamed:@"music_pressed"] forState:UIControlStateHighlighted];
            break;
        case 2:
            [imageBtn setBackgroundImage:[UIImage imageNamed:@"movie"] forState:UIControlStateNormal];
            [imageBtn setBackgroundImage:[UIImage imageNamed:@"movie_pressed"] forState:UIControlStateHighlighted];
            break;
        case 3:
            [imageBtn setBackgroundImage:[UIImage imageNamed:@"browser"] forState:UIControlStateNormal];
            [imageBtn setBackgroundImage:[UIImage imageNamed:@"browser_pressed"] forState:UIControlStateHighlighted];
            break;
        case 4:
            [imageBtn setBackgroundImage:[UIImage imageNamed:@"app"] forState:UIControlStateNormal];
            [imageBtn setBackgroundImage:[UIImage imageNamed:@"app_pressed"] forState:UIControlStateHighlighted];
            break;
        case 5:
            [imageBtn setBackgroundImage:[UIImage imageNamed:@"remote"] forState:UIControlStateNormal];
            [imageBtn setBackgroundImage:[UIImage imageNamed:@"remote_pressed"] forState:UIControlStateHighlighted];
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)imageBtnClicked:(UIButton *)btn
{
    int position = btn.tag - 1101;
    NSLog(@"before subview = %i", [AppDelegate instance].rootViewController.view.subviews.count);
    for (int i = 0; i < NUMBER_ITEMS_ON_LOAD; i++) {
        UIView *subview = [[AppDelegate instance].rootViewController.view viewWithTag:ITEM_VIEW_TAG + i];
        [subview removeFromSuperview];
        subview = nil;
    }
    NSLog(@"after subview = %i", [AppDelegate instance].rootViewController.view.subviews.count);
    if (position == 0) {
        groupViewController = [[GroupImageViewController alloc]init];
        groupViewController.view.frame = [[UIScreen mainScreen] bounds];
        groupViewController.view.tag = ITEM_VIEW_TAG + position;
        [[AppDelegate instance].rootViewController.view insertSubview:groupViewController.view belowSubview:self.view];
        [super moveToUpSide:self.view];
    } else if(position == 1){
        musicListViewController = [[MusicListViewController alloc]init];
        musicListViewController.view.frame = [[UIScreen mainScreen] bounds];
        musicListViewController.view.tag = ITEM_VIEW_TAG + position;
        [[AppDelegate instance].rootViewController.view insertSubview:musicListViewController.view belowSubview:self.view];
        [super moveToUpSide:self.view];
    } else if(position == 2){
        videoGridViewController = [[VideoGridViewController alloc]init];
        videoGridViewController.view.frame = [[UIScreen mainScreen] bounds];
        videoGridViewController.view.tag = ITEM_VIEW_TAG + position;
        [[AppDelegate instance].rootViewController.view insertSubview:videoGridViewController.view belowSubview:self.view];
        [super moveToUpSide:self.view];
    } else if(position == 3){
        browserViewController = [[BrowserViewController alloc]init];
        browserViewController.view.frame = [[UIScreen mainScreen] bounds];
        browserViewController.view.tag = ITEM_VIEW_TAG + position;
        [[AppDelegate instance].rootViewController.view insertSubview:browserViewController.view belowSubview:self.view];
        [super moveToUpSide:self.view];
    } else if(position == 4){
        appListViewController = [[AppListViewController alloc]init];
        appListViewController.view.frame = [[UIScreen mainScreen] bounds];
        appListViewController.view.tag = ITEM_VIEW_TAG + position;
        [[AppDelegate instance].rootViewController.view insertSubview:appListViewController.view belowSubview:self.view];
        [super moveToUpSide:self.view];
    } else if(position == 5){
        remoteViewController = [[NewRemoteViewController alloc]init];
        remoteViewController.view.frame = [[UIScreen mainScreen] bounds];
        remoteViewController.view.tag = ITEM_VIEW_TAG + position;
        [[AppDelegate instance].rootViewController.view insertSubview:remoteViewController.view belowSubview:self.view];
        [super moveToUpSide:self.view];
    }
}

- (void)GMGridView:(GMGridView *)gridView deleteItemAtIndex:(NSInteger)index
{
    
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewActionDelegate
//////////////////////////////////////////////////////////////
- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    
}


//////////////////////////////////////////////////////////////
#pragma mark private methods
//////////////////////////////////////////////////////////////

- (void)selectDevice:(UIButton *)btn
{
    DeviceListViewController *controller = [[DeviceListViewController alloc] init];
    FPPopoverController *popover = [[FPPopoverController alloc] initWithViewController:controller];
    popover.contentSize = CGSizeMake(255, 200);
    popover.tint = FPPopoverDefaultTint;
    popover.arrowDirection = FPPopoverArrowDirectionAny;
    [popover presentPopoverFromView:btn];
}

- (void)settingBtnClicked
{
    SettingsViewController *viewController = [[SettingsViewController alloc] init];
//    viewController.view.frame = self.view.frame;
    [self presentViewController:[[UINavigationController alloc]initWithRootViewController:viewController] animated:YES completion:nil];
    
}

@end
