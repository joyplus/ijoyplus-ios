//
//  SubsearchViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-28.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "AddSearchViewController.h"
#import "AddSearchListViewController.h"

@interface AddSearchViewController ()

@end

@implementation AddSearchViewController
@synthesize topId;
@synthesize backToViewController;
@synthesize type;

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.topId = nil;
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
    self.bgImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.bgImage.image = [UIImage imageNamed:@"left_background@2x.jpg"];
    self.bgImage.layer.zPosition = -1;
    [self.view addSubview:self.bgImage];
    [self.view addGestureRecognizer:self.swipeRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    return self;
}

- (void)search:(NSString *)keyword
{
    keyword = [keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [self addKeyToLocalHistory:keyword];
    [sBar resignFirstResponder];
    AddSearchListViewController *viewController = [[AddSearchListViewController alloc] init];
    viewController.keyword = keyword;
    viewController.topId = self.topId;
    viewController.type = self.type;
    viewController.backToViewController = self.backToViewController;
    viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
    [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:NO moveToLeft:NO];
    
}

@end
