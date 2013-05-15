//
//  SlideBaseViewController.m
//  yueshipin
//
//  Created by joyplus1 on 12-12-14.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "SlideBaseViewController.h"
#import "AppDelegate.h"
#import "RootViewController.h"

@interface SlideBaseViewController ()

@end

@implementation SlideBaseViewController

@synthesize moveToLeft;

- (void)viewDidUnload
{
    [super viewDidUnload];
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
    self.moveToLeft = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)closeBtnClicked
{
    [[AppDelegate instance].rootViewController.stackScrollViewController removeViewInSlider:self];
}
@end
