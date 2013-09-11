//
//  TPRemoteViewController.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-3-1.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "TPRemoteViewController.h"
#import "CommonHeader.h"

@implementation TPRemoteViewController

- (void)viewDidUnload
{
    [super viewDidUnload];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self addRemoteToolBar];
}

- (void)addRemoteToolBar
{
    UIToolbar *remoteToolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT-1, self.bounds.size.width, TOOLBAR_HEIGHT)];
    [remoteToolBar setNeedsDisplay];
    [self.view addSubview:remoteToolBar];
    
    UIButton *firstButton = [UIButton buttonWithType:UIButtonTypeCustom];
    firstButton.frame = CGRectMake(10, 0, 40, 40);
    [firstButton setBackgroundImage:[UIImage imageNamed:@"menu_icon_blue"] forState:UIControlStateNormal];
    [firstButton setBackgroundImage:[UIImage imageNamed:@"menu_icon_blue_pressed"] forState:UIControlStateHighlighted];
    [firstButton addTarget:self action:@selector(firstButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [remoteToolBar addSubview:firstButton];
    
    UIButton *secondButton = [UIButton buttonWithType:UIButtonTypeCustom];
    secondButton.frame = CGRectMake(60, 0, 40, 40);
    [secondButton setBackgroundImage:[UIImage imageNamed:@"home_icon_blue"] forState:UIControlStateNormal];
    [secondButton setBackgroundImage:[UIImage imageNamed:@"home_icon_blue_pressed"] forState:UIControlStateHighlighted];
    [secondButton addTarget:self action:@selector(secondButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [remoteToolBar addSubview:secondButton];
    
    UIButton *thirdButton = [UIButton buttonWithType:UIButtonTypeCustom];
    thirdButton.frame = CGRectMake(110, 0, 40, 40);
    [thirdButton setBackgroundImage:[UIImage imageNamed:@"back_icon_blue"] forState:UIControlStateNormal];
    [thirdButton setBackgroundImage:[UIImage imageNamed:@"back_icon_blue_pressed"] forState:UIControlStateHighlighted];
    [thirdButton addTarget:self action:@selector(thirdButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [remoteToolBar addSubview:thirdButton];
    
    UIButton *fourthButton = [UIButton buttonWithType:UIButtonTypeCustom];
    fourthButton.frame = CGRectMake(170, 0, 40, 40);
    [fourthButton setBackgroundImage:[UIImage imageNamed:@"keyboard_icon"] forState:UIControlStateNormal];
    [fourthButton setBackgroundImage:[UIImage imageNamed:@"keyboard_icon_pressed"] forState:UIControlStateHighlighted];
    [fourthButton addTarget:self action:@selector(fourthButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [remoteToolBar addSubview:fourthButton];
    
    UIButton *fifthButton = [UIButton buttonWithType:UIButtonTypeCustom];
    fifthButton.frame = CGRectMake(220, 0, 40, 40);
    [fifthButton setBackgroundImage:[UIImage imageNamed:@"setting_icon"] forState:UIControlStateNormal];
    [fifthButton setBackgroundImage:[UIImage imageNamed:@"setting_icon_pressed"] forState:UIControlStateHighlighted];
    [fifthButton addTarget:self action:@selector(fourthButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [remoteToolBar addSubview:fifthButton];
    
    UIButton *sixthButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sixthButton.frame = CGRectMake(270, 0, 40, 40);
    [sixthButton setBackgroundImage:[UIImage imageNamed:@"mark_icon"] forState:UIControlStateNormal];
    [sixthButton setBackgroundImage:[UIImage imageNamed:@"mark_icon_pressed"] forState:UIControlStateHighlighted];
    [sixthButton addTarget:self action:@selector(showFavorite) forControlEvents:UIControlEventTouchUpInside];
    [remoteToolBar addSubview:sixthButton];
}

- (void)sixthButton
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
