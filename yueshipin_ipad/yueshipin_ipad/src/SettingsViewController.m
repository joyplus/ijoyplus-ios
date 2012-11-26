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
    UILabel *sinaUsernameLabel;
    SinaWeibo *_sinaweibo;
    NSDictionary *userInfo;
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
        
        topImage = [[UIImageView alloc]initWithFrame:CGRectMake(80, 40, 170, 34)];
        topImage.image = [UIImage imageNamed:@"setting_title"];
        [self.view addSubview:topImage];
        
        sinaWeiboBg = [[UIImageView alloc]initWithFrame:CGRectMake(80, 120, 370, 79)];
        sinaWeiboBg.image = [UIImage imageNamed:@"setting_cell_bg"];
        [self.view addSubview:sinaWeiboBg];
        
        sinaWeiboImg = [[UIImageView alloc]initWithFrame:CGRectMake(100, 134, 334, 45)];
        sinaWeiboImg.image = [UIImage imageNamed:@"weibo"];
        [self.view addSubview:sinaWeiboImg];
        
        sinaUsernameLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 8, 135, 25)];
        sinaUsernameLabel.backgroundColor = [UIColor clearColor];
        sinaUsernameLabel.font = [UIFont boldSystemFontOfSize:13];
        sinaUsernameLabel.textColor = CMConstants.textBlueColor;
        [sinaWeiboImg addSubview:sinaUsernameLabel];
        
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
	_sinaweibo = [AppDelegate instance].sinaweibo;
    _sinaweibo.delegate = self;
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
        [_sinaweibo logIn];
    } else {
        [_sinaweibo logOut];
    }
}

- (void)menuBtnClicked
{
    [self.menuViewControllerDelegate menuButtonClicked];
}

- (void)removeAuthData
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SinaWeiboAuthData"];
}

- (void)storeAuthData
{
    NSDictionary *authData = [NSDictionary dictionaryWithObjectsAndKeys:
                              _sinaweibo.accessToken, @"AccessTokenKey",
                              _sinaweibo.expirationDate, @"ExpirationDateKey",
                              _sinaweibo.userID, @"UserIDKey",
                              _sinaweibo.refreshToken, @"refresh_token", nil];
    [[NSUserDefaults standardUserDefaults] setObject:authData forKey:@"SinaWeiboAuthData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - SinaWeibo Delegate

- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
    [self storeAuthData];
    sinaSwitch.on = YES;
    [sinaweibo requestWithURL:@"users/show.json"
                       params:[NSMutableDictionary dictionaryWithObject:sinaweibo.userID forKey:@"uid"]
                   httpMethod:@"GET"
                     delegate:self];
}

- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboDidLogOut");
    sinaUsernameLabel.text = @"";
    [self removeAuthData];
    sinaSwitch.on = NO;
}

- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboLogInDidCancel");
    sinaSwitch.on = NO;
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error
{
    NSLog(@"sinaweibo logInDidFailWithError %@", error);
    sinaSwitch.on = NO;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                        message:@"网络数据错误，请重新登陆。"
                                                       delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error
{
    NSLog(@"sinaweiboAccessTokenInvalidOrExpired %@", error);
    [self removeAuthData];
    sinaSwitch.on = NO;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                        message:@"Token已过期，请重新登陆。"
                                                       delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}

#pragma mark - SinaWeiboRequest Delegate

- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
{
    if ([request.url hasSuffix:@"users/show.json"])
    {
        userInfo = result;
        NSString *username = [userInfo objectForKey:@"screen_name"];
        sinaUsernameLabel.text = [NSString stringWithFormat:@"(%@)", username];
    }
}

- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error
{
    if ([request.url hasSuffix:@"users/show.json"])
    {
        userInfo = nil;
        sinaUsernameLabel.text = @"";
    }
}

@end
