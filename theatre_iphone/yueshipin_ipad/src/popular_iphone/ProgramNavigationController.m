//
//  ProgramNavigationController.m
//  yueshipin
//
//  Created by 08 on 13-1-8.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "ProgramNavigationController.h"
#import "UIImage+Scale.h"

@interface ProgramNavigationController ()

@end

@implementation ProgramNavigationController

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
     [self.navigationBar setBackgroundImage:[UIImage scaleFromImage:[UIImage imageNamed:@"play_bg.png"] toSize:CGSizeMake(320, 44)] forBarMetrics:UIBarMetricsDefault];
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(0, 0, 40, 30);
    closeButton.backgroundColor = [UIColor clearColor];
    [closeButton setImage:[UIImage scaleFromImage:[UIImage imageNamed:@"shut.png"] toSize:CGSizeMake(19, 18)] forState:UIControlStateNormal];
    [closeButton setImage:[UIImage scaleFromImage:[UIImage imageNamed:@"shut_pressed.png"] toSize:CGSizeMake(19, 18)] forState:UIControlStateHighlighted];
    UIBarButtonItem *closeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    self.navigationItem.backBarButtonItem = closeButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
