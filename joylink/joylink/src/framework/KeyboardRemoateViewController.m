//
//  KeyboardRemoateViewController.m
//  joylink
//
//  Created by joyplus1 on 13-4-27.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "KeyboardRemoateViewController.h"
#import "CommonHeader.h"


#define VOLUME_DOWN_BTN_TAG 1601
#define VOLUME_UP_BTN_TAG 1602
#define VOLUME_MUTE_BTN_TAG 1603

#define UP_BTN_TAG 1604
#define LEFT_BTN_TAG 1605
#define RIGHT_BTN_TAG 1606
#define DOWN_BTN_TAG 1607
#define OK_BTN_TAG 1608

@interface KeyboardRemoateViewController ()

@end

@implementation KeyboardRemoateViewController

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
    UILabel *title = (UILabel *)[self.navBar viewWithTag:TITLE_TAG];
    title.text = @"遥控器";
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addCenterControl
{
    [self addVolumeToolbarView];
    [self addCenterControlRemote];
}

- (void)addVolumeToolbarView
{
    UIView *volumeToolbarView = [[UIView alloc]initWithFrame:CGRectMake(0, TOOLBAR_HEIGHT + NAVIGATION_BAR_HEIGHT, self.bounds.size.width, 61)];
    volumeToolbarView.tag = VOLUME_TOOLBAR_VIEW;
    volumeToolbarView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:volumeToolbarView];
    
    UIButton *firstButton = [UIButton buttonWithType:UIButtonTypeCustom];
    firstButton.frame = CGRectMake(0, 0, 77, 61);
    firstButton.tag = VOLUME_DOWN_BTN_TAG;
    firstButton.center = CGPointMake(volumeToolbarView.frame.size.width/3 - 39, firstButton.center.y);
    [firstButton setBackgroundImage:[UIImage imageNamed:@"vol-"] forState:UIControlStateNormal];
    [firstButton setBackgroundImage:[UIImage imageNamed:@"vol-_active"] forState:UIControlStateHighlighted];
    [firstButton addTarget:self action:@selector(directionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [volumeToolbarView addSubview:firstButton];
    
    UIButton *secondButton = [UIButton buttonWithType:UIButtonTypeCustom];
    secondButton.frame = CGRectMake(0, 0, 108, 61);
    secondButton.tag = VOLUME_MUTE_BTN_TAG;
    secondButton.center = CGPointMake(volumeToolbarView.center.x, secondButton.center.y);
    [secondButton setBackgroundImage:[UIImage imageNamed:@"mute"] forState:UIControlStateNormal];
    [secondButton setBackgroundImage:[UIImage imageNamed:@"mute_active"] forState:UIControlStateHighlighted];
    [secondButton addTarget:self action:@selector(directionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [volumeToolbarView addSubview:secondButton];
    
    UIButton *thirdButton = [UIButton buttonWithType:UIButtonTypeCustom];
    thirdButton.frame = CGRectMake(0, 0, 77, 61);
    thirdButton.tag = VOLUME_UP_BTN_TAG;
    thirdButton.center = CGPointMake(volumeToolbarView.frame.size.width*2.0/3.0 + 39, thirdButton.center.y);
    [thirdButton setBackgroundImage:[UIImage imageNamed:@"vol+"] forState:UIControlStateNormal];
    [thirdButton setBackgroundImage:[UIImage imageNamed:@"vol+_active"] forState:UIControlStateHighlighted];
    [thirdButton addTarget:self action:@selector(directionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [volumeToolbarView addSubview:thirdButton];
}

- (void)addCenterControlRemote
{
    int width = 243;
    UIView *volumeToolbarView = (UIView *)[self.view viewWithTag:VOLUME_TOOLBAR_VIEW];
    CGRect frame = CGRectMake(45, NAVIGATION_BAR_HEIGHT + TOOLBAR_HEIGHT + volumeToolbarView.frame.size.height, width, 247);
    if ([CommonMethod isIphone5]) {
        frame = CGRectMake(45, NAVIGATION_BAR_HEIGHT + TOOLBAR_HEIGHT + volumeToolbarView.frame.size.height + 40, width, 247);
    }
    UIView *roundControllerView = [[UIView alloc]initWithFrame:frame];
    roundControllerView.tag = ROUND_CONTROLLER_TAG;
    roundControllerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:roundControllerView];
    
    UIImageView *remoteBg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 238, 247)];
    remoteBg.image = [UIImage imageNamed:@"arrow_bg"];
    [roundControllerView addSubview:remoteBg];
    
    UIButton *firstButton = [UIButton buttonWithType:UIButtonTypeCustom];
    firstButton.frame = CGRectMake(0, 0, width, 84);
    firstButton.tag = UP_BTN_TAG;
    [firstButton setBackgroundImage:[UIImage imageNamed:@"up"] forState:UIControlStateNormal];
    [firstButton setBackgroundImage:[UIImage imageNamed:@"up_active"] forState:UIControlStateHighlighted];
    [firstButton addTarget:self action:@selector(directionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [roundControllerView addSubview:firstButton];
    
    UIButton *secondButton = [UIButton buttonWithType:UIButtonTypeCustom];
    secondButton.frame = CGRectMake(0, 0, 84, width);
    secondButton.tag = LEFT_BTN_TAG;
    [secondButton setBackgroundImage:[UIImage imageNamed:@"left"] forState:UIControlStateNormal];
    [secondButton setBackgroundImage:[UIImage imageNamed:@"left_active"] forState:UIControlStateHighlighted];
    [secondButton addTarget:self action:@selector(directionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [roundControllerView addSubview:secondButton];
    
    UIButton *thirdButton = [UIButton buttonWithType:UIButtonTypeCustom];
    thirdButton.frame = CGRectMake(0, 0, 118, 125);
    thirdButton.tag = OK_BTN_TAG;
    thirdButton.center = CGPointMake(roundControllerView.frame.size.width/2.0, roundControllerView.frame.size.height/2.0);
    [thirdButton setBackgroundImage:[UIImage imageNamed:@"ok"] forState:UIControlStateNormal];
    [thirdButton setBackgroundImage:[UIImage imageNamed:@"ok_active"] forState:UIControlStateHighlighted];
    [thirdButton addTarget:self action:@selector(directionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [roundControllerView addSubview:thirdButton];
    
    UIButton *fourthButton = [UIButton buttonWithType:UIButtonTypeCustom];
    fourthButton.frame = CGRectMake(roundControllerView.frame.size.width - 84, 0, 84, width);
    fourthButton.tag = RIGHT_BTN_TAG;
    [fourthButton setBackgroundImage:[UIImage imageNamed:@"right"] forState:UIControlStateNormal];
    [fourthButton setBackgroundImage:[UIImage imageNamed:@"right_active"] forState:UIControlStateHighlighted];
    [fourthButton addTarget:self action:@selector(directionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [roundControllerView addSubview:fourthButton];
    
    UIButton *fifthButton = [UIButton buttonWithType:UIButtonTypeCustom];
    fifthButton.frame = CGRectMake(0, roundControllerView.frame.size.height - 84, width, 84);
    fifthButton.tag = DOWN_BTN_TAG;
    [fifthButton setBackgroundImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
    [fifthButton setBackgroundImage:[UIImage imageNamed:@"down_active"] forState:UIControlStateHighlighted];
    [fifthButton addTarget:self action:@selector(directionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [roundControllerView addSubview:fifthButton];
}

- (void)directionBtnClicked:(UIButton *)btn
{
    if (![self serverIsConnected]) {
        return;
    }
    switch (btn.tag) {
        case VOLUME_DOWN_BTN_TAG:
        {
            RemoteAction *action = [ActionFactory getMessageAction:SEND_KEY_CODE];
            NSString *msg = [NSString stringWithFormat:@"{\"keycode\":%d}", KEYCODE_VOLUME_DOWN];
            [action trigger:msg];
            break;
        }
        case VOLUME_UP_BTN_TAG:
        {
            RemoteAction *action = [ActionFactory getMessageAction:SEND_KEY_CODE];
            NSString *msg = [NSString stringWithFormat:@"{\"keycode\":%d}", KEYCODE_VOLUME_UP];
            [action trigger:msg];
            break;
        }
        case VOLUME_MUTE_BTN_TAG:
        {
            RemoteAction *action = [ActionFactory getMessageAction:SEND_KEY_CODE];
            NSString *msg = [NSString stringWithFormat:@"{\"keycode\":%d}", KEYCODE_VOLUME_MUTE];
            [action trigger:msg];
            break;
        }
        case UP_BTN_TAG:
        {
            RemoteAction *action = [ActionFactory getMessageAction:SEND_KEY_CODE];
            NSString *msg = [NSString stringWithFormat:@"{\"keycode\":%d}", KEYCODE_DPAD_UP];
            [action trigger:msg];
            break;
        }
        case LEFT_BTN_TAG:
        {
            RemoteAction *action = [ActionFactory getMessageAction:SEND_KEY_CODE];
            NSString *msg = [NSString stringWithFormat:@"{\"keycode\":%d}", KEYCODE_DPAD_LEFT];
            [action trigger:msg];
            break;
        }
        case RIGHT_BTN_TAG:
        {
            RemoteAction *action = [ActionFactory getMessageAction:SEND_KEY_CODE];
            NSString *msg = [NSString stringWithFormat:@"{\"keycode\":%d}", KEYCODE_DPAD_RIGHT];
            [action trigger:msg];
            break;
        }
        case DOWN_BTN_TAG:
        {
            RemoteAction *action = [ActionFactory getMessageAction:SEND_KEY_CODE];
            NSString *msg = [NSString stringWithFormat:@"{\"keycode\":%d}", KEYCODE_DPAD_DOWN];
            [action trigger:msg];
            break;
        }
        case OK_BTN_TAG:
        {
            RemoteAction *action = [ActionFactory getMessageAction:SEND_KEY_CODE];
            NSString *msg = [NSString stringWithFormat:@"{\"keycode\":%d}", KEYCODE_DPAD_CENTER];
            [action trigger:msg];
            break;
        }
        default:
            break;
    }
}

@end
