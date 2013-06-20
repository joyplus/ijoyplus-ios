//
//  IphoneSettingViewController.m
//  yueshipin
//
//  Created by 08 on 12-12-26.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "IphoneSettingViewController.h"
#import "AboutViewController.h"
#import "StatementsViewController.h"
#import "MBProgressHUD.h"
#import "SDImageCache.h"
#import "Reachability.h"
#import "UIUtility.h"
#import "ContainerUtility.h"
#import "AppDelegate.h"
#import "CMConstants.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "UIImage+Scale.h"
#import "AFSinaWeiboAPIClient.h"
#import "UMFeedback.h"
#import <QuartzCore/QuartzCore.h>
#import "ActionUtility.h"
#import "CacheUtility.h"
#import "AppRecommendViewController.h"
#import "UMUFPGridCell.h"
#import "GridViewCellDemo.h"
#import "CommonMotheds.h"
#import "FeedbackViewController.h"
#import "Harpy.h"
#import "IntroductionView.h"
@interface IphoneSettingViewController ()

@end

@implementation IphoneSettingViewController
@synthesize sinaSwith = sinaSwith_;
@synthesize sinaweibo = sinaweibo_;
@synthesize weiboName = weiboName_;

@synthesize mGridView = _mGridView;

static int NUMBER_OF_COLUMNS = 3;
static int NUMBER_OF_APPS_PERPAGE = 9;
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
    
    self.title = @"设置";
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 55, 44);
    backButton.backgroundColor = [UIColor clearColor];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"back_f.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_common.png"]];
    bg.frame = CGRectMake(0, 0, 320, kFullWindowHeight);
    [self.view addSubview:bg];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, kCurrentWindowHeight-44)];
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.contentSize = CGSizeMake(320, kFullWindowHeight+265);
    [self.view addSubview:scrollView];
    
    UIImageView *sinaImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, 300, 45)];
    sinaImg.image = [UIImage imageNamed:@"my_s_xinlang.png"];
    sinaImg.userInteractionEnabled = YES;
    weiboName_ = [[UILabel alloc] initWithFrame:CGRectMake(74, 4, 120, 22)];
    weiboName_.backgroundColor = [UIColor clearColor];
    weiboName_.textColor =  [UIColor colorWithRed:247/255.0 green:122/255.0 blue:151/255.0 alpha:1];
    weiboName_.font = [UIFont boldSystemFontOfSize:13];
    [sinaImg addSubview:weiboName_];
    sinaSwith_ = [[UISwitch alloc] initWithFrame:CGRectMake(220, 6, 40, 22)];
    sinaSwith_.transform =  CGAffineTransformMakeScale(0.80, 0.80);
    [sinaSwith_ addTarget:self action:@selector(sinaSwitchClicked:) forControlEvents:UIControlEventValueChanged];
    sinaSwith_.onTintColor = [UIColor colorWithRed:247/255.0 green:122/255.0 blue:151/255.0 alpha:1];
    [sinaImg addSubview:sinaSwith_];
    
    
    sinaweibo_ = [AppDelegate instance].sinaweibo;
    sinaweibo_.delegate = self;
    if([sinaweibo_ isLoggedIn]){
        sinaSwith_.on = YES;
        NSString *username = (NSString *)[[ContainerUtility sharedInstance] attributeForKey:kUserNickName];
        weiboName_.text = [NSString stringWithFormat:@"(%@)",username];;
    }

    [scrollView addSubview:sinaImg];
    
    UIImageView *networkImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 70, 300, 45)];
    networkImg.image = [UIImage imageNamed:@"3G_bg.png"];
    networkImg.userInteractionEnabled = YES;
    UISwitch *networkSet = [[UISwitch alloc] initWithFrame:CGRectMake(220, 6, 40, 22)];
    networkSet.transform =  CGAffineTransformMakeScale(0.80, 0.80);
    [networkSet addTarget:self action:@selector(networkSetSwitchClicked:) forControlEvents:UIControlEventValueChanged];
    networkSet.onTintColor = [UIColor colorWithRed:247/255.0 green:122/255.0 blue:151/255.0 alpha:1];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    networkSet.on = [[defaults objectForKey:@"isSupport3GDownload"] boolValue];
    if ([[AppDelegate instance].showVideoSwitch isEqualToString:@"0"]){
            [networkImg addSubview:networkSet];
            [scrollView addSubview:networkImg];
    }
    
    
    sinaweibo_ = [AppDelegate instance].sinaweibo;
    sinaweibo_.delegate = self;
    if([sinaweibo_ isLoggedIn]){
        sinaSwith_.on = YES;
        NSString *username = (NSString *)[[ContainerUtility sharedInstance] attributeForKey:kUserNickName];
        weiboName_.text = [NSString stringWithFormat:@"(%@)",username];;
    }
    
    [scrollView addSubview:sinaImg];
   
    UIButton *clearCache = [UIButton buttonWithType:UIButtonTypeCustom];
    clearCache.frame = CGRectMake(10, 140, 300, 35);
    // [feedBack setTitle:@"清楚缓存" forState:UIControlStateNormal];
    [clearCache setBackgroundImage:[UIImage imageNamed:@"my_setting_cache.png"] forState:UIControlStateNormal];
    [clearCache setBackgroundImage:[UIImage imageNamed:@"my_setting_cache_s.png"] forState:UIControlStateHighlighted];
    [clearCache addTarget:self action:@selector(clearCache:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:clearCache];
    
    UIButton *feedBack = [UIButton buttonWithType:UIButtonTypeCustom];
    feedBack.frame = CGRectMake(10, 173, 300, 35);
    // [feedBack setTitle:@"意见反馈" forState:UIControlStateNormal];
    [feedBack setBackgroundImage:[UIImage imageNamed:@"my_setting_other.png"] forState:UIControlStateNormal];
    [feedBack setBackgroundImage:[UIImage imageNamed:@"my_setting_other_s.png"] forState:UIControlStateHighlighted];
    [feedBack addTarget:self action:@selector(feedBack:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:feedBack];
    
    UIButton *aboutUs = [UIButton buttonWithType:UIButtonTypeCustom];
    aboutUs.frame = CGRectMake(10, 320, 300, 35);
    //[aboutUs setTitle:@"关于我们" forState:UIControlStateNormal];
    [aboutUs setBackgroundImage:[UIImage imageNamed:@"my_setting_other2.png"] forState:UIControlStateNormal];
    [aboutUs setBackgroundImage:[UIImage imageNamed:@"my_setting_other2_s.png"] forState:UIControlStateHighlighted];
    [aboutUs addTarget:self action:@selector(aboutUs:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:aboutUs];
    
    UIButton *update = [UIButton buttonWithType:UIButtonTypeCustom];
    update.frame = CGRectMake(10, 239, 300, 35);
    [update setBackgroundImage:[UIImage imageNamed:@"iphoneCheckUpdate.png"] forState:UIControlStateNormal];
    [update setBackgroundImage:[UIImage imageNamed:@"iphoneCheckUpdatePress.png"] forState:UIControlStateHighlighted];
    [update addTarget:self action:@selector(update:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:update];
    
    UIButton *xinshouyindao = [UIButton buttonWithType:UIButtonTypeCustom];
    xinshouyindao.frame = CGRectMake(10, 272, 300, 35);
    [xinshouyindao setBackgroundImage:[UIImage imageNamed:@"xinshouyindao.png"] forState:UIControlStateNormal];
    [xinshouyindao setBackgroundImage:[UIImage imageNamed:@"xinshouyindao_s.png"] forState:UIControlStateHighlighted];
    [xinshouyindao addTarget:self action:@selector(xinshouyindao) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:xinshouyindao];
    
    UIButton *careUs = [UIButton buttonWithType:UIButtonTypeCustom];
    careUs.frame = CGRectMake(10, 206, 300, 35);
    [careUs setBackgroundImage:[UIImage imageNamed:@"my_setting_other3.png"] forState:UIControlStateNormal];
    [careUs setBackgroundImage:[UIImage imageNamed:@"my_setting_other3_s.png"] forState:UIControlStateHighlighted];
    [careUs addTarget:self action:@selector(careUs:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:careUs];
    
    UIButton *suggest = [UIButton buttonWithType:UIButtonTypeCustom];
    suggest.frame = CGRectMake(10, 353, 300, 35);
    //[suggest setTitle:@"免责声明" forState:UIControlStateNormal];
    [suggest setBackgroundImage:[UIImage imageNamed:@"my_setting_other4.png"] forState:UIControlStateNormal];
    [suggest setBackgroundImage:[UIImage imageNamed:@"my_setting_other4_s.png"] forState:UIControlStateHighlighted];
    [suggest addTarget:self action:@selector(suggest:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:suggest];
    
    UIButton *version = [UIButton buttonWithType:UIButtonTypeCustom];
    version.frame = CGRectMake(10, 386, 300, 35);
    //[suggest setTitle:@"免责声明" forState:UIControlStateNormal];
    [version setBackgroundImage:[UIImage imageNamed:@"my_setting_version.png"] forState:UIControlStateNormal];
    [version setBackgroundImage:[UIImage imageNamed:@"my_setting_version.png"] forState:UIControlStateHighlighted];
    [scrollView addSubview:version];
    
    NSString *bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 1, 150, 30)];
    versionLabel.backgroundColor = [UIColor clearColor];
    versionLabel.font = [UIFont systemFontOfSize:14];
    versionLabel.text = [NSString stringWithFormat:@"v%@",bundleVersion];
    versionLabel.textColor = [UIColor grayColor];
    [version addSubview:versionLabel];
    
    if ([[AppDelegate instance].recommendAppSwich isEqualToString:@"0"])
    {
        UIImageView *jinpin = [[UIImageView alloc] initWithFrame:CGRectMake(15, 435, 55, 13)];
        jinpin.image = [UIImage imageNamed:@"jingpintuijian.png"];
        [scrollView addSubview:jinpin];
        
        _mGridView = [[UMUFPGridView alloc] initWithFrame:CGRectMake(12, 455,296,260) appkey:umengAppKey slotId:nil currentViewController:self];
        [_mGridView setBackgroundColor:[UIColor colorWithRed:120.0/255 green:120.0/255 blue:120.0/255 alpha:0.2]];
        _mGridView.datasource = self;
        _mGridView.delegate = self;
        _mGridView.dataLoadDelegate = (id<GridViewDataLoadDelegate>)self;
        _mGridView.autoresizesSubviews = NO;
        _mGridView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        [_mGridView requestPromoterDataInBackground];
        [scrollView addSubview:_mGridView];
    }
}

-(void)back:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)appRecommed:(id)sender{
    AppRecommendViewController *viewController = [[AppRecommendViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];

}
-(void)careUs:(id)sender{
    if (![CommonMotheds isNetworkEnbled]) {
        [UIUtility showNetWorkError:self.view];
        return;
    }
    sinaweibo_ = [AppDelegate instance].sinaweibo;
    if([sinaweibo_ isLoggedIn]){
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:sinaweibo_.accessToken, @"access_token", @"悦视频", @"screen_name", nil];
        [[AFSinaWeiboAPIClient sharedClient] postPath:kFollowUserURI parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        }];
        [self showSuccessModalView:1.5];
    } else {
        NSURL *url=[NSURL URLWithString:@"http://weibo.com/u/3058636171"];
        [[UIApplication sharedApplication] openURL:url];
    }


}
-(void)update:(id)sender{
  [Harpy checkVersion:self.view];
}
- (void)showSuccessModalView:(int)closeTime
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    view.tag = 3268142;
    [view setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
    UIImageView *temp = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"success_img"]];
    temp.frame = CGRectMake(0, 0, 200, 100);
    temp.center = view.center;
    [view addSubview:temp];
    [self.view addSubview:view];
    [NSTimer scheduledTimerWithTimeInterval:closeTime target:self selector:@selector(removeOverlay) userInfo:nil repeats:NO];
}

- (void)removeOverlay
{
    UIView *view = (UIView *)[self.view viewWithTag:3268142];
    for(UIView *subview in view.subviews){
        [subview removeFromSuperview];
    }
    [view removeFromSuperview];
    view = nil;
}

- (void)sinaSwitchClicked:(UISwitch *)sender
{
    //Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [UIUtility showNetWorkError:self.view];
        return;
    }
    BOOL flag = sender.isOn;
    if(flag){
        [sinaweibo_ logIn];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"确定要解除绑定吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];

    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [sinaweibo_ logOut];
    }
    else if (buttonIndex == 0){
        sinaSwith_.on = YES;
    }
}

-(void)networkSetSwitchClicked:(UISwitch *)aswitch{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *value = nil;
    if (aswitch.isOn) {
        value = [NSNumber numberWithBool:YES];
    }
    else{
        value = [NSNumber numberWithBool:NO];
    }
    [defaults setObject:value forKey:@"isSupport3GDownload"];
    [defaults synchronize];
}
-(void)clearCache:(id)sender{

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
-(void)feedBack:(id)sender{
    if (![CommonMotheds isNetworkEnbled]) {
        [UIUtility showNetWorkError:self.view];
        return;
    }
    FeedbackViewController *feedbackViewController = [[FeedbackViewController alloc] init];
    [self.navigationController pushViewController:feedbackViewController animated:YES];

    //[UMFeedback showFeedback:self withAppkey:umengAppKey];
}

-(void)suggest:(id)sender{
    StatementsViewController *satementViewController = [[StatementsViewController alloc] init];
    [self.navigationController pushViewController:satementViewController animated:YES];
    
}

-(void)aboutUs:(id)sender{
    AboutViewController *aboutViewController = [[AboutViewController alloc] init];
    [self.navigationController pushViewController:aboutViewController animated:YES];
}
-(void)xinshouyindao{
    CGSize size = [UIApplication sharedApplication].delegate.window.bounds.size;
    IntroductionView *inView = [[IntroductionView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    [inView show];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)removeAuthData
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SinaWeiboAuthData"];
}

- (void)storeAuthData
{
    NSDictionary *authData = [NSDictionary dictionaryWithObjectsAndKeys:
                              sinaweibo_.accessToken, @"AccessTokenKey",
                              sinaweibo_.expirationDate, @"ExpirationDateKey",
                              sinaweibo_.userID, @"UserIDKey",
                              sinaweibo_.refreshToken, @"refresh_token", nil];
    [[NSUserDefaults standardUserDefaults] setObject:authData forKey:@"SinaWeiboAuthData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)unbundingWithTV:(NSString *)Id
{
    NSDictionary * dic = (NSDictionary *)[[ContainerUtility sharedInstance] attributeForKey:[NSString stringWithFormat:@"%@_isBunding",Id]];
    if ([[dic objectForKey:KEY_IS_BUNDING] boolValue] && nil != dic)
    {
        NSString * sendChannel = [NSString stringWithFormat:@"CHANNEL_TV_%@",[dic objectForKey:KEY_MACADDRESS]];
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"33", @"push_type",
                              Id, @"user_id",
                              sendChannel, @"tv_channel",
                              nil];
        [[BundingTVManager shareInstance] sendMsg:data];
    }
}

#pragma mark - SinaWeibo Delegate

- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
    [self storeAuthData];
    sinaSwith_.on = YES;
    [sinaweibo requestWithURL:@"users/show.json"
                       params:[NSMutableDictionary dictionaryWithObject:sinaweibo.userID forKey:@"uid"]
                   httpMethod:@"GET"
                     delegate:self];
}

- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboDidLogOut");
   
    [self removeAuthData];
    sinaSwith_.on = NO;
    
    //add code by huokun for "用户变换，取消与TV绑定数据"
    [self unbundingWithTV:(NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId]];
    //add code end
    
    [[ContainerUtility sharedInstance] removeObjectForKey:kUserId];
    [[ContainerUtility sharedInstance] removeObjectForKey:kUserAvatarUrl];
    [[ContainerUtility sharedInstance] removeObjectForKey:kUserNickName];
    [[CacheUtility sharedCache] removeObjectForKey:@"PersonalData"];
    [[CacheUtility sharedCache] removeObjectForKey:@"watch_record"];
    [ActionUtility generateUserId:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SINAWEIBOCHANGED" object:nil];
    }];
    weiboName_.text = @"";
}

- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboLogInDidCancel");
    sinaSwith_.on = NO;
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error
{
    NSLog(@"sinaweibo logInDidFailWithError %@", error);
    sinaSwith_.on = NO;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                        message:@"网络数据错误，请重新登陆。"
                                                       delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error
{
    NSLog(@"sinaweiboAccessTokenInvalidOrExpired %@", error);
    [self removeAuthData];
    sinaSwith_.on = NO;
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
        weiboName_.text = [NSString stringWithFormat:@"(%@)",username];
        NSString *avatarUrl = [userInfo objectForKey:@"avatar_large"];
        [[ContainerUtility sharedInstance] setAttribute:avatarUrl forKey:kUserAvatarUrl];
         NSString *userId = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId];
        
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:userId, @"pre_user_id", [userInfo objectForKey:@"idstr"], @"source_id", @"1", @"source_type", nil];
        [[AFServiceAPIClient sharedClient] postPath:kPathUserValidate parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            NSString *responseCode = [result objectForKey:@"res_code"];
            if(responseCode == nil)
            {
                //add code by huokun for "用户变换，取消与TV绑定数据"
                [self unbundingWithTV:(NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId]];
                //add code end
                
                NSString *user_id = [result objectForKey:@"user_id"];
                [[AFServiceAPIClient sharedClient] setDefaultHeader:@"user_id" value:user_id];
                [[ContainerUtility sharedInstance] setAttribute:user_id forKey:kUserId];
                [[CacheUtility sharedCache] removeObjectForKey:@"PersonalData"];
                [[CacheUtility sharedCache] removeObjectForKey:@"watch_record"];
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"SINAWEIBOCHANGED" object:nil];
            }
            else
            {
                NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: [userInfo objectForKey:@"idstr"], @"source_id", @"1", @"source_type", avatarUrl, @"pic_url", username, @"nickname", nil];
                [[AFServiceAPIClient sharedClient] postPath:kPathAccountBindAccount parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"SINAWEIBOCHANGED" object:nil];
                } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                    
                }];
            }
            
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            [UIUtility showDetailError:self.view error:error];
        }];
        
        
        
    }
}

- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error
{
    if ([request.url hasSuffix:@"users/show.json"])
    {
        
    }
}


#pragma mark GridViewDataSource
- (NSInteger)numberOfColumsInGridView:(UMUFPGridView *)gridView{
    
    return NUMBER_OF_COLUMNS;
}

- (NSInteger)numberOfAppsPerPage:(UMUFPGridView *)gridView
{
    return NUMBER_OF_APPS_PERPAGE;
}

- (UIView *)gridView:(UMUFPGridView *)gridView cellForRowAtIndexPath:(IndexPath *)indexPath{
    
    GridViewCellDemo *view = [[GridViewCellDemo alloc] initWithIdentifier:nil];
    
    return view;
}

-(void)gridView:(UMUFPGridView *)gridView relayoutCellSubview:(UIView *)view withIndexPath:(IndexPath *)indexPath{
    
    int arrIndex = [gridView arrayIndexForIndexPath:indexPath];
    if (arrIndex < [_mGridView.mPromoterDatas count])
    {
        NSDictionary *promoter = [_mGridView.mPromoterDatas objectAtIndex:arrIndex];
        
        GridViewCellDemo *imageViewCell = (GridViewCellDemo *)view;
        imageViewCell.indexPath = indexPath;
        imageViewCell.titleLabel.text = [promoter valueForKey:@"title"];
        
        [imageViewCell.imageView setImageURL:[NSURL URLWithString:[promoter valueForKey:@"icon"]]];
    }
}
- (CGFloat)gridView:(UMUFPGridView *)gridView heightForRowAtIndexPath:(IndexPath *)indexPath
{
    return 80.0f;
}

- (void)gridView:(UMUFPGridView *)gridView didSelectRowAtIndexPath:(IndexPath *)indexPath
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
//    int arrIndex = [gridView arrayIndexForIndexPath:indexPath];
//    if (arrIndex < [_mGridView.mPromoterDatas count])
//    {
//        NSDictionary *promoter = [_mGridView.mPromoterDatas objectAtIndex:arrIndex];
//        NSString *url = [promoter valueForKey:@"url"];
//        NSLog(@"%@", url);
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
//    }
}

- (void)UMUFPGridViewDidLoadDataFinish:(UMUFPGridView *)gridView promotersAmount:(NSInteger)promotersAmount
{
    NSLog(@"%s, %d", __PRETTY_FUNCTION__, promotersAmount);
    
    [gridView reloadData];
}

- (void)UMUFPGridView:(UMUFPGridView *)gridView didLoadDataFailWithError:(NSError *)error
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}


@end
