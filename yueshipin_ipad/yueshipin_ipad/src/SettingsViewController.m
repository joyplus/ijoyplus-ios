//
//  SettingsViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-20.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "SettingsViewController.h"
#import "CustomSearchBar.h"

#define TABLE_VIEW_WIDTH 370
#define MIN_BUTTON_WIDTH 45
#define MAX_BUTTON_WIDTH 355
#define BUTTON_HEIGHT 33
#define BUTTON_TITLE_GAP 13

@interface SettingsViewController (){
    UIView *backgroundView;
    UIButton *menuBtn;
    UIImageView *topImage;
    UIImageView *bgImage;
    
    UIImageView *sinaWeiboBg;
    UIImageView *sinaWeiboImg;
    
    UIImageView *clearCacheBg;
    UIButton *clearCacheBtn;
    UIImageView *aboutBg;
    UIButton *suggestionBtn;
    UIButton *commentBtn;
    UIButton *aboutBtn;
    
    UISwitch *sinaSwitch;
}

@end

@implementation SettingsViewController
@synthesize menuViewControllerDelegate;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super init]) {
		[self.view setFrame:frame];
        [self.view setBackgroundColor:[UIColor clearColor]];
        backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 24)];
        [backgroundView setBackgroundColor:[UIColor yellowColor]];
        [self.view addSubview:backgroundView];
        
        bgImage = [[UIImageView alloc]initWithFrame:backgroundView.frame];
        bgImage.image = [UIImage imageNamed:@"left_background"];
        [backgroundView addSubview:bgImage];
        
        menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        menuBtn.frame = CGRectMake(17, 33, 29, 42);
        [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu_btn"] forState:UIControlStateNormal];
        [menuBtn addTarget:self action:@selector(menuBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:menuBtn];
        
        topImage = [[UIImageView alloc]initWithFrame:CGRectMake(80, 40, 187, 34)];
        topImage.image = [UIImage imageNamed:@"setting_title"];
        [self.view addSubview:topImage];
        
        sinaWeiboBg = [[UIImageView alloc]initWithFrame:CGRectMake(80, 120, 370, 79)];
        sinaWeiboBg.image = [UIImage imageNamed:@"setting_cell_bg"];
        [self.view addSubview:sinaWeiboBg];
        
        sinaWeiboImg = [[UIImageView alloc]initWithFrame:CGRectMake(100, 134, 334, 45)];
        sinaWeiboImg.image = [UIImage imageNamed:@"weibo"];
        [self.view addSubview:sinaWeiboImg];
        
        sinaSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(340, 140, 75, 27)];
        [sinaSwitch addTarget:self action:@selector(sinaSwitchClicked:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:sinaSwitch];
        
        clearCacheBg = [[UIImageView alloc]initWithFrame:CGRectMake(80, 210, 370, 79)];
        clearCacheBg.image = [UIImage imageNamed:@"setting_cell_bg"];
        [self.view addSubview:clearCacheBg];
        
        clearCacheBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        clearCacheBtn.frame = CGRectMake(100, 230, 334, 40);
        [clearCacheBtn setBackgroundImage:[UIImage imageNamed:@"clean"] forState:UIControlStateNormal];
        [clearCacheBtn setBackgroundImage:[UIImage imageNamed:@"clean_pressed"] forState:UIControlStateHighlighted];
        [clearCacheBtn addTarget:self action:@selector(menuBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:clearCacheBtn];
        
        aboutBg = [[UIImageView alloc]initWithFrame:CGRectMake(80, 306, 372, 175)];
        aboutBg.image = [[UIImage imageNamed:@"setting_cell_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2)] ;
        [self.view addSubview:aboutBg];
        
        suggestionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        suggestionBtn.frame = CGRectMake(100, 325, 334, 40);
        [suggestionBtn setBackgroundImage:[UIImage imageNamed:@"advice"] forState:UIControlStateNormal];
        [suggestionBtn setBackgroundImage:[UIImage imageNamed:@"advice_pressed"] forState:UIControlStateHighlighted];
        [suggestionBtn addTarget:self action:@selector(menuBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:suggestionBtn];
        
        commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        commentBtn.frame = CGRectMake(100, 372, 334, 40);
        [commentBtn setBackgroundImage:[UIImage imageNamed:@"opinions"] forState:UIControlStateNormal];
        [commentBtn setBackgroundImage:[UIImage imageNamed:@"opinions_pressed"] forState:UIControlStateHighlighted];
        [commentBtn addTarget:self action:@selector(menuBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:commentBtn];
        
        aboutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        aboutBtn.frame = CGRectMake(100, 422, 334, 40);
        [aboutBtn setBackgroundImage:[UIImage imageNamed:@"about"] forState:UIControlStateNormal];
        [aboutBtn setBackgroundImage:[UIImage imageNamed:@"about_pressed"] forState:UIControlStateHighlighted];
        [aboutBtn addTarget:self action:@selector(menuBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:aboutBtn];
        
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sinaSwitchClicked:(UISwitch *)sender
{
    BOOL flag = sender.isOn;
    if(flag){
        NSLog(@"on");
    } else {
        NSLog(@"off");
    }
}

- (void)menuBtnClicked
{
    [self.menuViewControllerDelegate menuButtonClicked];
}

@end
