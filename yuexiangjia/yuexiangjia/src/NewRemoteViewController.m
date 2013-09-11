//
//  NewRemoteViewController.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-4-23.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "NewRemoteViewController.h"
#import "CommonHeader.h"

#define REMOTE_TOOLBAR_TAG 1111
#define VOLUME_TOOLBAR_VIEW 1112
#define ROUND_CONTROLLER_TAG 1113


@interface NewRemoteViewController ()

@property (nonatomic, strong)UIView *keyboardView;
@property (nonatomic, strong)UIView *mouseView;
@end

@implementation NewRemoteViewController
@synthesize keyboardView, mouseView;

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
	[super showNavigationBar:@"遥控器"];
    [self addRemoteToolBar];
    
    [self showKeyboardView];
    
    [self addRemoteBackButton];
    [self addSwitchView];
    [super showToolbar];
}

- (void)showKeyboardView
{
    mouseView.alpha = 0;
    [mouseView setHidden:YES];
    if (keyboardView) {
        keyboardView.alpha = 1;
        [keyboardView setHidden:NO];
    } else {
        keyboardView = [[UIView alloc]initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT + TOOLBAR_HEIGHT, self.bounds.size.width, self.bounds.size.height - NAVIGATION_BAR_HEIGHT - TOOLBAR_HEIGHT*4 - 24)];
        keyboardView.backgroundColor = [UIColor yellowColor];
        [self.view addSubview:keyboardView];
        [self addVolumeToolbarView];
        [self addCenterControl];
    }
    
}

- (void)showMouseView
{
    keyboardView.alpha = 0;
    [keyboardView setHidden:YES];
    if (mouseView) {
        mouseView.alpha = 1;
        [mouseView setHidden:NO];
    } else {
        mouseView = [[UIView alloc]initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT + TOOLBAR_HEIGHT, self.bounds.size.width, self.bounds.size.height - NAVIGATION_BAR_HEIGHT - TOOLBAR_HEIGHT*4 - 24)];
        mouseView.backgroundColor = [UIColor blueColor];
        [self.view addSubview:mouseView];
    }
    
}

- (void)addRemoteToolBar
{
    UIToolbar *remoteToolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT-1, self.bounds.size.width, TOOLBAR_HEIGHT)];
    remoteToolBar.tag = REMOTE_TOOLBAR_TAG;
    [remoteToolBar setNeedsDisplay];
    [self.view addSubview:remoteToolBar];
    
    UIButton *firstButton = [UIButton buttonWithType:UIButtonTypeCustom];
    firstButton.frame = CGRectMake(0, 0, 40, 40);
    firstButton.center = CGPointMake(remoteToolBar.frame.size.width/3 - 20, firstButton.center.y);
    [firstButton setBackgroundImage:[UIImage imageNamed:@"menu_icon_blue"] forState:UIControlStateNormal];
    [firstButton setBackgroundImage:[UIImage imageNamed:@"menu_icon_blue_pressed"] forState:UIControlStateHighlighted];
    [firstButton addTarget:self action:@selector(firstButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [remoteToolBar addSubview:firstButton];
    
    UIButton *secondButton = [UIButton buttonWithType:UIButtonTypeCustom];
    secondButton.frame = CGRectMake(0, 0, 40, 40);
    secondButton.center = CGPointMake(remoteToolBar.center.x, secondButton.center.y);
    [secondButton setBackgroundImage:[UIImage imageNamed:@"home_icon_blue"] forState:UIControlStateNormal];
    [secondButton setBackgroundImage:[UIImage imageNamed:@"home_icon_blue_pressed"] forState:UIControlStateHighlighted];
    [secondButton addTarget:self action:@selector(secondButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [remoteToolBar addSubview:secondButton];
    
    UIButton *thirdButton = [UIButton buttonWithType:UIButtonTypeCustom];
    thirdButton.frame = CGRectMake(0, 0, 40, 40);
    thirdButton.center = CGPointMake(remoteToolBar.frame.size.width*2.0/3.0 + 20, thirdButton.center.y);
    [thirdButton setBackgroundImage:[UIImage imageNamed:@"back_icon_blue"] forState:UIControlStateNormal];
    [thirdButton setBackgroundImage:[UIImage imageNamed:@"back_icon_blue_pressed"] forState:UIControlStateHighlighted];
    [thirdButton addTarget:self action:@selector(thirdButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [remoteToolBar addSubview:thirdButton];
}

- (void)firstButtonClicked
{

}

- (void)secondButtonClicked
{

}

- (void)thirdButtonClicked
{

}

- (void)addVolumeToolbarView
{
    UIToolbar *remoteToolBar = (UIToolbar *)[self.view viewWithTag:REMOTE_TOOLBAR_TAG];
    UIView *volumeToolbarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, TOOLBAR_HEIGHT)];
    volumeToolbarView.tag = VOLUME_TOOLBAR_VIEW;
    volumeToolbarView.backgroundColor = [UIColor blueColor];
    [keyboardView addSubview:volumeToolbarView];
    
    UIButton *firstButton = [UIButton buttonWithType:UIButtonTypeCustom];
    firstButton.frame = CGRectMake(0, 0, 40, 40);
    [firstButton setTitle:@"减小" forState:UIControlStateNormal];
    firstButton.center = CGPointMake(volumeToolbarView.frame.size.width/3 - 20, firstButton.center.y);
    [firstButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [firstButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
    [firstButton addTarget:self action:@selector(firstButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [volumeToolbarView addSubview:firstButton];
    
    UIButton *secondButton = [UIButton buttonWithType:UIButtonTypeCustom];
    secondButton.frame = CGRectMake(0, 0, 40, 40);
    [secondButton setTitle:@"静音" forState:UIControlStateNormal];
    secondButton.center = CGPointMake(volumeToolbarView.center.x, secondButton.center.y);
    [secondButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [secondButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
    [secondButton addTarget:self action:@selector(secondButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [volumeToolbarView addSubview:secondButton];
    
    UIButton *thirdButton = [UIButton buttonWithType:UIButtonTypeCustom];
    thirdButton.frame = CGRectMake(0, 0, 40, 40);
    [thirdButton setTitle:@"增大" forState:UIControlStateNormal];
    thirdButton.center = CGPointMake(volumeToolbarView.frame.size.width*2.0/3.0 + 20, thirdButton.center.y);
    [thirdButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [thirdButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
    [thirdButton addTarget:self action:@selector(thirdButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [volumeToolbarView addSubview:thirdButton];
}

- (void)addCenterControl
{
    int width = 210;
    UIView *roundControllerView = [[UIView alloc]initWithFrame:CGRectMake(45, TOOLBAR_HEIGHT, width, width)];
    roundControllerView.tag = ROUND_CONTROLLER_TAG;
    roundControllerView.backgroundColor = [UIColor redColor];
    [keyboardView addSubview:roundControllerView];
    
    UIButton *firstButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    firstButton.frame = CGRectMake(0, 0, 160, 40);
    [firstButton setTitle:@"上" forState:UIControlStateNormal];
    firstButton.center = CGPointMake(roundControllerView.frame.size.width/2.0, firstButton.center.y);
    [firstButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [firstButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
    [firstButton addTarget:self action:@selector(firstButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [roundControllerView addSubview:firstButton];
    
    UIButton *secondButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    secondButton.frame = CGRectMake(20, 0, 40, 160);
    [secondButton setTitle:@"左" forState:UIControlStateNormal];
    secondButton.center = CGPointMake(secondButton.center.x, roundControllerView.frame.size.height/2.0);
    [secondButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [secondButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
    [secondButton addTarget:self action:@selector(secondButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [roundControllerView addSubview:secondButton];
    
    UIButton *thirdButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    thirdButton.frame = CGRectMake(0, 0, 60, 60);
    [thirdButton setTitle:@"中" forState:UIControlStateNormal];
    thirdButton.center = CGPointMake(roundControllerView.frame.size.width/2.0, roundControllerView.frame.size.height/2.0);
    [thirdButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [thirdButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
    [thirdButton addTarget:self action:@selector(thirdButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [roundControllerView addSubview:thirdButton];
    
    UIButton *fourthButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    fourthButton.frame = CGRectMake(0, 0, 40, 160);
    [fourthButton setTitle:@"右" forState:UIControlStateNormal];
    fourthButton.center = CGPointMake(roundControllerView.frame.size.width-40, roundControllerView.frame.size.height/2.0);
    [fourthButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [fourthButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
    [fourthButton addTarget:self action:@selector(thirdButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [roundControllerView addSubview:fourthButton];
    
    UIButton *fifthButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    fifthButton.frame = CGRectMake(0, roundControllerView.frame.size.height - 40, 160, 40);
    [fifthButton setTitle:@"下" forState:UIControlStateNormal];
    fifthButton.center = CGPointMake(roundControllerView.frame.size.width/2.0, fifthButton.center.y);
    [fifthButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [fifthButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
    [fifthButton addTarget:self action:@selector(thirdButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [roundControllerView addSubview:fifthButton];
}

- (void)addRemoteBackButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(0,  self.bounds.size.height - TOOLBAR_HEIGHT*3 - 24, 260, TOOLBAR_HEIGHT);
    [button setTitle:@"返回" forState:UIControlStateNormal];
    button.center = CGPointMake(keyboardView.center.x, button.center.y);
    [button setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(thirdButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)addSwitchView
{
    UIView *switchView = [[UIView alloc]initWithFrame:CGRectMake(0, self.bounds.size.height - TOOLBAR_HEIGHT*2 - 24, self.bounds.size.width, TOOLBAR_HEIGHT)];
    switchView.backgroundColor = [UIColor redColor];
    [self.view addSubview:switchView];
    
    UIButton *firstButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    firstButton.frame = CGRectMake(0, 0, 40, 40);
    [firstButton setTitle:@"Keyboard" forState:UIControlStateNormal];
//    firstButton.center = CGPointMake(roundControllerView.frame.size.width/2.0, firstButton.center.y);
    [firstButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [firstButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
    [firstButton addTarget:self action:@selector(showKeyboardView) forControlEvents:UIControlEventTouchUpInside];
    [switchView addSubview:firstButton];
    
    UIButton *secondButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    secondButton.frame = CGRectMake(45, 0, 40, 40);
    [secondButton setTitle:@"左" forState:UIControlStateNormal];
//    secondButton.center = CGPointMake(secondButton.center.x, roundControllerView.frame.size.height/2.0);
    [secondButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [secondButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
    [secondButton addTarget:self action:@selector(showMouseView) forControlEvents:UIControlEventTouchUpInside];
    [switchView addSubview:secondButton];
}

- (void)backButtonClicked
{
    [super homeButtonClicked];
}
@end
