//
//  GenericBaseViewController.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-21.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "GenericBaseViewController.h"
#import "CommonHeader.h"
#import "DisplayingImageHandler.h"
#import "PlayingMusicHandler.h"
#import "PlayingVideoHandler.h"

@interface GenericBaseViewController ()
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *homeButton;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) DisplayingImageHandler *imageHandler;
@property (nonatomic, strong) PlayingMusicHandler *musicHandler;
@property (nonatomic, strong) PlayingVideoHandler *videoHandler;

@end

@implementation GenericBaseViewController
@synthesize bounds, showMiddleBtn;
@synthesize backButton, homeButton, playButton;
@synthesize navBar, toolbar;
@synthesize imageHandler;
@synthesize musicHandler;
@synthesize videoHandler;

- (void)viewDidUnload
{
    [super viewDidUnload];
    backButton = nil;
    homeButton = nil;
    playButton = nil;
    navBar = nil;
    toolbar = nil;
    imageHandler = nil;
    musicHandler = nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"didReceiveMemoryWarning in %@", self.class);
}

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
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
	bounds = [UIScreen mainScreen].bounds;

    imageHandler = [[DisplayingImageHandler alloc]init];
    musicHandler = [[PlayingMusicHandler alloc]init];
    videoHandler = [[PlayingVideoHandler alloc]init];
}

- (void)showNavigationBar:(NSString *)titleContent
{
    navBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, -1, self.bounds.size.width, NAVIGATION_BAR_HEIGHT)];    
    UINavigationItem *navTitle = [[UINavigationItem alloc] initWithTitle:titleContent];
    [navBar pushNavigationItem:navTitle animated:YES];
    [self.view addSubview:navBar];
}

- (void)buildToolBar
{
    [self addLeftButton];
    [self addMiddleButton];
    [self addRightButton];
}

- (void)addLeftButton
{
    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(5, 0, 40, 40);
    [backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back_pressed"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:backButton];
}

- (void)addMiddleButton
{
    if (showMiddleBtn) {
        playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        playButton.frame = CGRectMake(0, 5, 40, 40);
        playButton.center = CGPointMake(toolbar.center.x, TOOLBAR_HEIGHT/2);
        [playButton setBackgroundImage:[UIImage imageNamed:@"push_icon"] forState:UIControlStateNormal];
        [playButton setBackgroundImage:[UIImage imageNamed:@"push_icon_pressed"] forState:UIControlStateHighlighted];
        [playButton addTarget:self action:@selector(playBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [toolbar addSubview:playButton];
    }
}

- (void)addRightButton
{
    homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    homeButton.frame = CGRectMake(self.bounds.size.width - 47, 0, 40, 40);
    [homeButton setBackgroundImage:[UIImage imageNamed:@"home_icon"] forState:UIControlStateNormal];
    [homeButton setBackgroundImage:[UIImage imageNamed:@"home_icon_pressed"] forState:UIControlStateHighlighted];
    [homeButton addTarget:self action:@selector(homeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:homeButton];
}

- (void)showToolbar
{
    [self showToolbar:0];
}

- (void)showToolbar:(int)offsetY
{
    toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height - TOOLBAR_HEIGHT - offsetY, self.bounds.size.width, TOOLBAR_HEIGHT)];
    [toolbar setNeedsDisplay];
    [self.view addSubview:toolbar];
    [self buildToolBar];
}

// should be implemented in subclasses
- (void)backButtonClicked
{

}

// should be implemented in subclasses
- (void)playBtnClicked
{
    
}

- (void)homeButtonClicked
{
    UIView *homeView = [[AppDelegate instance].rootViewController.view viewWithTag:HOME_VIEW_TAG];
    NSLog(@"home view subviews count: %i", homeView.subviews.count);
    switch ([AppDelegate instance].castingType) {
        case YueImageCasting:
        {
            if (imageHandler == nil) {
                imageHandler = [[DisplayingImageHandler alloc]init];
            }
            [imageHandler showImageContainer];
            break;
        }
        case YueMusicCasting:
        {
            if (musicHandler == nil) {
                musicHandler = [[PlayingMusicHandler alloc]init];
            }
            [musicHandler showPlayingMusicContainer];
            break;
        }
        case YueVideoCasting:
        {
            if (videoHandler == nil) {
                videoHandler = [[PlayingVideoHandler alloc]init];
            }
            [videoHandler showPlayingVideoContainer];
            break;
        }
        default:
            [imageHandler removeImageContainer];
            [musicHandler removeMusicContainer];
            [videoHandler removeVideoContainer];
            break;
    }
    [self moveToDownSide:homeView];
}

- (void)moveToDownSide:(UIView *)view {
    [UIView animateWithDuration:0.5 animations:^{//修改rView坐标
        view.frame = CGRectMake(view.frame.origin.x, 0, view.frame.size.width, view.frame.size.height);
    } completion:^(BOOL finished){
    }];
}

- (void)moveToUpSide:(UIView *)view {
    [UIView animateWithDuration:0.5 animations:^{//修改rView坐标
        view.frame = CGRectMake(view.frame.origin.x, -view.frame.size.height, view.frame.size.width, view.frame.size.height);
    } completion:^(BOOL finished){
        [imageHandler removeImageContainer];
        [musicHandler removeMusicContainer];
        [videoHandler removeVideoContainer];
    }];
}

@end
