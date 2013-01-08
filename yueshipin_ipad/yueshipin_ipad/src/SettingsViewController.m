//
//  SettingsViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-20.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "SettingsViewController.h"
#import "CustomSearchBar.h"
#import "SuggestionViewController.h"
#import "AboutUsViewController.h"
#import "MBProgressHUD.h"
#import "SDImageCache.h"
#import "AFSinaWeiboAPIClient.h"
#import "ClauseViewController.h"
#import "ActionUtility.h"

#define TABLE_VIEW_WIDTH 370
#define MIN_BUTTON_WIDTH 45
#define MAX_BUTTON_WIDTH 355
#define BUTTON_HEIGHT 33
#define BUTTON_TITLE_GAP 13

NSString *templateReviewURL = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=APP_ID";

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
    UIButton *speakBtn;
    UISwitch *sinaSwitch;
    UILabel *sinaUsernameLabel;
    SinaWeibo *_sinaweibo;
    
    UIButton *followBtn;
}

@end

@implementation SettingsViewController


- (void)viewDidUnload
{
    [super viewDidUnload];
    backgroundView = nil;
    menuBtn = nil;
    topImage = nil;
    bgImage = nil;
    speakBtn = nil;
    sinaWeiboBg = nil;
    sinaWeiboImg = nil;
    clearCacheBg = nil;
    clearCacheBtn = nil;
    aboutBg = nil;
    suggestionBtn = nil;
    commentBtn = nil;
    aboutBtn = nil;
    sinaSwitch = nil;
    sinaUsernameLabel = nil;
    _sinaweibo = nil;
    followBtn = nil;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super init]) {
		[self.view setFrame:frame];
        [self.view setBackgroundColor:[UIColor clearColor]];
        backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 24)];
        [backgroundView setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:backgroundView];
        
        bgImage = [[UIImageView alloc]initWithFrame:backgroundView.frame];
        bgImage.image = [UIImage imageNamed:@"left_background"];
        [backgroundView addSubview:bgImage];
        
        menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        menuBtn.frame = CGRectMake(0, 28, 60, 60);
        [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu_btn"] forState:UIControlStateNormal];
        [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu_btn_pressed"] forState:UIControlStateHighlighted];
        [menuBtn addTarget:self action:@selector(menuBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:menuBtn];
        
        topImage = [[UIImageView alloc]initWithFrame:CGRectMake(80, 40, 137, 34)];
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
        sinaUsernameLabel.textColor = CMConstants.titleBlueColor;
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
        [clearCacheBtn addTarget:self action:@selector(clearCacheBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:clearCacheBtn];
        
        aboutBg = [[UIImageView alloc]initWithFrame:CGRectMake(80, 306, 372, 267)];
        aboutBg.image = [[UIImage imageNamed:@"setting_cell_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] ;
        [self.view addSubview:aboutBg];
        
        suggestionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        suggestionBtn.frame = CGRectMake(100, 325, 334, 40);
        [suggestionBtn setBackgroundImage:[UIImage imageNamed:@"advice"] forState:UIControlStateNormal];
        [suggestionBtn setBackgroundImage:[UIImage imageNamed:@"advice_pressed"] forState:UIControlStateHighlighted];
        [suggestionBtn addTarget:self action:@selector(suggestionBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:suggestionBtn];
        
        commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        commentBtn.frame = CGRectMake(100, 372, 334, 40);
        [commentBtn setBackgroundImage:[UIImage imageNamed:@"opinions"] forState:UIControlStateNormal];
        [commentBtn setBackgroundImage:[UIImage imageNamed:@"opinions_pressed"] forState:UIControlStateHighlighted];
        [commentBtn addTarget:self action:@selector(commentBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:commentBtn];
        
        followBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        followBtn.frame = CGRectMake(100, 419, 334, 40);
        [followBtn setBackgroundImage:[UIImage imageNamed:@"follow"] forState:UIControlStateNormal];
        [followBtn setBackgroundImage:[UIImage imageNamed:@"follow_pressed"] forState:UIControlStateHighlighted];
        [followBtn addTarget:self action:@selector(followBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:followBtn];
        
        aboutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        aboutBtn.frame = CGRectMake(100, 466, 334, 40);
        [aboutBtn setBackgroundImage:[UIImage imageNamed:@"about"] forState:UIControlStateNormal];
        [aboutBtn setBackgroundImage:[UIImage imageNamed:@"about_pressed"] forState:UIControlStateHighlighted];
        [aboutBtn addTarget:self action:@selector(aboutBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:aboutBtn];
        
        speakBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        speakBtn.frame = CGRectMake(100, 513, 334, 40);
        [speakBtn setBackgroundImage:[UIImage imageNamed:@"clause"] forState:UIControlStateNormal];
        [speakBtn setBackgroundImage:[UIImage imageNamed:@"clause_pressed"] forState:UIControlStateHighlighted];
        [speakBtn addTarget:self action:@selector(speakBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:speakBtn];
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self.view addGestureRecognizer:closeMenuRecognizer];
    [self.view addGestureRecognizer:swipeCloseMenuRecognizer];
    [self.view addGestureRecognizer:openMenuRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    _sinaweibo = [AppDelegate instance].sinaweibo;
    _sinaweibo.delegate = self;
    [super viewWillAppear:YES];
    if([_sinaweibo isLoggedIn]){
        sinaSwitch.on = YES;
        NSString *username = (NSString *)[[ContainerUtility sharedInstance] attributeForKey:kUserNickName];
        sinaUsernameLabel.text = [NSString stringWithFormat:@"(%@)", username];
    }
}

- (void)clearCacheBtnClicked
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.labelText = @"正在清理...";
    [HUD showWhileExecuting:@selector(clearCache) onTarget:self withObject:nil animated:YES];
}

- (void)clearCache
{
    [[SDImageCache sharedImageCache] clearDisk];
    sleep(1);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)suggestionBtnClicked
{
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([hostReach currentReachabilityStatus] == NotReachable) {
        [UIUtility showNetWorkError:self.view];
        return;
    }
    [self closeMenu];
    SuggestionViewController *viewController = [[SuggestionViewController alloc] initWithNibName:@"SuggestionViewController" bundle:nil];
    viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
    [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:YES];
}

- (void)commentBtnClicked
{
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([hostReach currentReachabilityStatus] == NotReachable) {
        [UIUtility showNetWorkError:self.view];
        return;
    }
    
    NSString *reviewURL = [templateReviewURL stringByReplacingOccurrencesOfString:@"APP_ID" withString:[NSString stringWithFormat:@"%d", APPIRATER_APP_ID]];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:reviewURL]];
}

- (void)aboutBtnClicked
{
    [self closeMenu];
    AboutUsViewController *viewController = [[AboutUsViewController alloc]init];
    viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
    [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:YES];
}

- (void)speakBtnClicked
{
    [self closeMenu];
    ClauseViewController *viewController = [[ClauseViewController alloc]init];
    viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
    [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:YES];
}

- (void)sinaSwitchClicked:(UISwitch *)sender
{
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([hostReach currentReachabilityStatus] == NotReachable) {
        [UIUtility showNetWorkError:self.view];
        return;
    }
    BOOL flag = sender.isOn;
    if(flag){
        [_sinaweibo logIn];
    } else {
        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil
                                                           message:@"确定要解除绑定吗？"
                                                          delegate:self
                                                 cancelButtonTitle:@"取消"
                                                 otherButtonTitles:@"确定", nil];
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        [[ContainerUtility sharedInstance] removeObjectForKey:kUserId];
        [[ContainerUtility sharedInstance] removeObjectForKey:kUserAvatarUrl];
        [[ContainerUtility sharedInstance] removeObjectForKey:kUserNickName];
        [[CacheUtility sharedCache] removeObjectForKey:@"PersonalData"];
        [[CacheUtility sharedCache] removeObjectForKey:@"watch_record"];
        [[CacheUtility sharedCache] removeObjectForKey:@"my_support_list"];
        [[CacheUtility sharedCache] removeObjectForKey:@"my_collection_list"];
        [ActionUtility generateUserId:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:PERSONAL_VIEW_REFRESH object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:WATCH_HISTORY_REFRESH object:nil];
        }];
        [_sinaweibo logOut];
    } else {
        sinaSwitch.on = YES;
    }
}

- (void)followBtnClicked
{
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([hostReach currentReachabilityStatus] == NotReachable) {
        [UIUtility showNetWorkError:self.view];
        return;
    }
    _sinaweibo = [AppDelegate instance].sinaweibo;
    if([_sinaweibo isLoggedIn]){
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:_sinaweibo.accessToken, @"access_token", @"悦视频", @"screen_name", nil];
        [[AFSinaWeiboAPIClient sharedClient] postPath:kFollowUserURI parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        }];
        [[AppDelegate instance].rootViewController showSuccessModalView:1.5];
    } else {
        NSURL *url=[NSURL URLWithString:@"http://weibo.com/u/3058636171"];
        [[UIApplication sharedApplication] openURL:url];
    }
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

- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)userInfo
{
    if ([request.url hasSuffix:@"users/show.json"])
    {
        NSString *username = [userInfo objectForKey:@"screen_name"];
        [[ContainerUtility sharedInstance] setAttribute:username forKey:kUserNickName];
        sinaUsernameLabel.text = [NSString stringWithFormat:@"(%@)", username];
        NSString *avatarUrl = [userInfo objectForKey:@"avatar_large"];
        [[ContainerUtility sharedInstance] setAttribute:avatarUrl forKey:kUserAvatarUrl];
        
        NSString *userId = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId];
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: userId, @"pre_user_id", [userInfo objectForKey:@"idstr"], @"source_id", @"1", @"source_type", nil];
        [[AFServiceAPIClient sharedClient] postPath:kPathUserValidate parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            NSString *responseCode = [result objectForKey:@"res_code"];
            if(responseCode == nil){                
                NSString *user_id = [result objectForKey:@"user_id"];
                [[AFServiceAPIClient sharedClient] setDefaultHeader:@"user_id" value:user_id];
                [[ContainerUtility sharedInstance] setAttribute:user_id forKey:kUserId];
                [[CacheUtility sharedCache] removeObjectForKey:@"PersonalData"];
                [[CacheUtility sharedCache] removeObjectForKey:@"watch_record"];
                [[CacheUtility sharedCache] removeObjectForKey:@"my_support_list"];
                [[CacheUtility sharedCache] removeObjectForKey:@"my_collection_list"];
                [[NSNotificationCenter defaultCenter] postNotificationName:PERSONAL_VIEW_REFRESH object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:WATCH_HISTORY_REFRESH object:nil];
            } else {
                NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: [userInfo objectForKey:@"idstr"], @"source_id", @"1", @"source_type", avatarUrl, @"pic_url", username, @"nickname", nil];
                [[AFServiceAPIClient sharedClient] postPath:kPathAccountBindAccount parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
                    
                } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                    
                }];
            }
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
        
        
        
    }
}

- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error
{
    if ([request.url hasSuffix:@"users/show.json"])
    {
        sinaUsernameLabel.text = @"";
    }
}

@end
