//
//  IphoneVideoViewController.m
//  yueshipin
//
//  Created by 08 on 13-1-10.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "IphoneVideoViewController.h"
#import "AppDelegate.h"
#import "SendWeiboViewController.h"
#import "AFSinaWeiboAPIClient.h"
#import "CMConstants.h"
#import "ContainerUtility.h"
#import "ServiceConstants.h"
#import "AFServiceAPIClient.h"
#import "SendWeiboViewController.h"
#import "ActionUtility.h"
#import <QuartzCore/QuartzCore.h>
#import "CustomNavigationViewController.h"
#import "CacheUtility.h"
#import "TimeUtility.h"
#import "UIImage+Scale.h"
#import "IphoneAVPlayerViewController.h"
#import "IphoneWebPlayerViewController.h"
#import "CustomNavigationViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "WXApi.h"
#import "UIImageView+WebCache.h"
#import "TSActionSheet.h"
#import "Reachability.h"
#import "MobClick.h"
#import "CustomNavigationViewControllerPortrait.h"
#import "UIUtility.h"
#define VIEWTAG   123654

@interface IphoneVideoViewController ()

@property (nonatomic) int willPlayIndex;

@end

@implementation IphoneVideoViewController
@synthesize mySinaWeibo = _mySinaWeibo;
@synthesize infoDic = infoDic_;
@synthesize episodesArr = episodesArr_;
@synthesize prodId = prodId_;
@synthesize subName = subName_;
@synthesize name = name_;
@synthesize videoUrlsArray = videoUrlsArray_;
@synthesize httpUrlArray = httpUrlArray_;
@synthesize isNotification = isNotification_;
@synthesize segmentedControl = segmentedControl_;
@synthesize wechatImg = wechatImg_;
@synthesize willPlayIndex;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (isNotification_) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"top_bg_common.png"] forBarMetrics:UIBarMetricsDefault];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSuccessModalView) name:@"wechat_share_success" object:nil];
    
    UIView *footview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    footview.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footview;
}
- (void)viewDidUnload{

 [super viewDidUnload];
 
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

- (void)showOpSuccessModalView:(float)closeTime with:(int)type
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    view.tag = VIEWTAG;
    [view setBackgroundColor:[UIColor clearColor]];
   
    if (type == REPORT)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 80)];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.text = @"您提交的错误我们已经收到，我们会尽快处理，谢谢您的支持.";
        label.center = view.center;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:12];
        label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        label.layer.cornerRadius = 4;
        label.textColor = [UIColor whiteColor];
        [view addSubview:label];
    }
    else if (type == DING
             || type == ADDFAV
             || ADDEXPECT == type)
    {
         UIImageView *temp = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"operation_is_successful.png"]];
        temp.frame = CGRectMake(0, 0, 92, 27);
        temp.center = view.center;
        [view addSubview:temp];
        
        if (ADDEXPECT == type)
        {
            
        }
    }
    
    //[[AppDelegate instance].window addSubview:view];
    [self.view addSubview:view];
    [NSTimer scheduledTimerWithTimeInterval:closeTime target:self selector:@selector(removeOverlay) userInfo:nil repeats:NO];
}
- (void)showOpFailureModalView:(float)closeTime with:(int)type
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    view.tag = VIEWTAG;
    [view setBackgroundColor:[UIColor clearColor]];
    UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 92, 27)];
    label.backgroundColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.alpha = 0.9;
    label.center = view.center;
    label.layer.masksToBounds = YES;
    label.layer.cornerRadius = 6.0;
    if (type == DING) {
       label.text = @"已顶过";
        
    }
    else if (type == ADDFAV) {
       label.text = @"已收藏过";
    }
    else if (ADDEXPECT == type)
    {
        NSString * text = @"想看影片已加入收藏记录";
        CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:12]];
        label.frame = CGRectMake(0, 0, size.width, 27);
        label.text = @"想看影片已加入收藏记录";
        label.center = view.center;
    }
    [view addSubview:label];
  
     [self.view addSubview:view];
    [NSTimer scheduledTimerWithTimeInterval:closeTime target:self selector:@selector(removeOverlay) userInfo:nil repeats:NO];
}
- (void)removeOverlay
{
  for(UIView *view in self.view.subviews ){
      if (view.tag == VIEWTAG) {
          [view removeFromSuperview];
          break;
     }
  
  }
    
}


-(void)share:(id)sender event:(UIEvent *)event{
    
    if (![self checkNetWork]) {
        [UIUtility showNetWorkError:self.view];
        return;
    }
    TSActionSheet *actionSheet = [[TSActionSheet alloc] initWithTitle:@"分享到："];
    [actionSheet addButtonWithTitle:@"新浪微博" block:^{
        [self selectIndex:0];
    }];
    [actionSheet addButtonWithTitle:@"微信好友" block:^{
        [self selectIndex:1];
    }];
    [actionSheet addButtonWithTitle:@"微信朋友圈" block:^{
        [self selectIndex:2];
    }];
    [actionSheet cancelButtonWithTitle:@"取消" block:nil];
    actionSheet.cornerRadius = 5;
    
    [actionSheet showWithTouch:event];

    
}
-(void)selectIndex:(int)index{
    if (![self checkNetWork]) {
        [UIUtility showNetWorkError:self.view];
        return;
    }
    
    switch (index) {
            
        case 0:
            
            [self sinaShare];
            break;
            
        case 1:
            
            [self wechatShare:WXSceneSession];
            [MobClick event:@"ue_wechat_friend_share"];
            break;
        case 2:
            
            [self wechatShare:WXSceneTimeline];
            [MobClick event:@"ue_wechat_social_share"];
            break;
        default:
            
            break;
            
    }


}

-(void)sinaShare{
    _mySinaWeibo = [AppDelegate instance].sinaweibo;
    _mySinaWeibo.delegate = self;
    if ([_mySinaWeibo isLoggedIn]) {
        SendWeiboViewController *sendV = [[SendWeiboViewController alloc] init];
        sendV.infoDic = infoDic_;
        [self presentViewController:[[CustomNavigationViewControllerPortrait alloc] initWithRootViewController:sendV] animated:YES completion:nil];
    }
    else{
        [_mySinaWeibo logIn];
        
    }
}

-(void)wechatShare:(int)sence{
        WXMediaMessage *message = [WXMediaMessage message];
        NSString *name = self.title;
        if (sence == 0) {
            message.title = @"分享部影片给你 ";
            message.description = [NSString stringWithFormat:@"我正在看《%@》，不错哦，推荐给你~",name];
        }
        else if (sence == 1){
            message.title = [NSString stringWithFormat:@"我正在看《%@》，不错哦，推荐给你~",name];;
        }
        [message setThumbImage:wechatImg_];
    
        WXWebpageObject *ext = [WXWebpageObject object];
        ext.webpageUrl = [NSString stringWithFormat:@"http://weixin.joyplus.tv/info.php?prod_id=%@",prodId_];
        message.mediaObject = ext;
    
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = sence;
        
        [WXApi sendReq:req];

}
-(void)removeView{
    [segmentedControl_ removeFromSuperview];
}


- (void)showSuccessModalView
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    view.tag = 100000001;
    [view setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
    UIImageView *temp = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"success_img"]];
    temp.frame = CGRectMake(0, 0, 200, 100);
    temp.center = view.center;
    [view addSubview:temp];
    [self.view addSubview:view];
    [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(removeSucceedOverlay) userInfo:nil repeats:NO];
}

- (void)removeSucceedOverlay
{
    UIView *view = (UIView *)[self.view viewWithTag:100000001];
    for(UIView *subview in view.subviews){
        [subview removeFromSuperview];
    }
    [view removeFromSuperview];
    view = nil;
}



#pragma mark - SinaWeibo Delegate
- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo{
    
    SendWeiboViewController *sendV = [[SendWeiboViewController alloc] init];
    sendV.infoDic = infoDic_;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:sendV] animated:YES completion:nil];
    
    NSDictionary *authData = [NSDictionary dictionaryWithObjectsAndKeys:
                              sinaweibo.accessToken, @"AccessTokenKey",
                              sinaweibo.expirationDate, @"ExpirationDateKey",
                              sinaweibo.userID, @"UserIDKey",
                              sinaweibo.refreshToken, @"refresh_token", nil];
    [[NSUserDefaults standardUserDefaults] setObject:authData forKey:@"SinaWeiboAuthData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [sinaweibo requestWithURL:@"users/show.json"
                       params:[NSMutableDictionary dictionaryWithObject:sinaweibo.userID forKey:@"uid"]
                   httpMethod:@"GET"
                     delegate:self];
    
}
- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo{
    NSLog(@"sinaweiboDidLogOut");
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SinaWeiboAuthData"];
    [[ContainerUtility sharedInstance] removeObjectForKey:kUserAvatarUrl];
    [[ContainerUtility sharedInstance] removeObjectForKey:kUserNickName];
    [ActionUtility generateUserId:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SINAWEIBOCHANGED" object:nil];
    }];
    
}

- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo{
    NSLog(@"sinaweiboLogInDidCancel");
    
}
- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error{
    NSLog(@"sinaweibo logInDidFailWithError %@", error);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                        message:@"网络数据错误，请重新登陆。"
                                                       delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}
- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error{
    NSLog(@"sinaweiboAccessTokenInvalidOrExpired %@", error);
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SinaWeiboAuthData"];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                        message:@"Token已过期，请重新登陆。"
                                                       delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}
#pragma mark - SinaWeiboRequest Delegate

- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)userInfo{
    if ([request.url hasSuffix:@"users/show.json"])
    {
        NSString *username = [userInfo objectForKey:@"screen_name"];
        [[ContainerUtility sharedInstance] setAttribute:username forKey:kUserNickName];
        NSString *avatarUrl = [userInfo objectForKey:@"avatar_large"];
        [[ContainerUtility sharedInstance] setAttribute:avatarUrl forKey:kUserAvatarUrl];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"SINAWEIBOCHANGED" object:nil];
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: [userInfo objectForKey:@"idstr"], @"source_id", @"1", @"source_type", nil];
        [[AFServiceAPIClient sharedClient] postPath:kPathUserValidate parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            NSString *responseCode = [result objectForKey:@"res_code"];
            if(responseCode == nil){
                NSString *user_id = [result objectForKey:@"user_id"];
                [[AFServiceAPIClient sharedClient] setDefaultHeader:@"user_id" value:user_id];
                [[ContainerUtility sharedInstance] setAttribute:user_id forKey:kUserId];
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
        
    }
}


-(void)playVideo:(int)num{
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isWifiReachable)]){
        willPlayIndex = num;
        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil
                                                           message:@"播放视频会消耗大量流量，您确定要在非WiFi环境下播放吗？"
                                                          delegate:self
                                                 cancelButtonTitle:@"取消"
                                                 otherButtonTitles:@"确定", nil];
        [alertView show];
    } else {
        [self willPlayVideo:num];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        [self willPlayVideo:willPlayIndex];
    }
}

- (void)willPlayVideo:(int)num
{
    if (num < 0 || num >= episodesArr_.count) {
        return;
    }
    //[[UIApplication sharedApplication] setStatusBarHidden:YES];
    if ([[AppDelegate instance].showVideoSwitch isEqualToString:@"2"]) {
        NSDictionary *dic = [episodesArr_ objectAtIndex:num];
        NSArray *webUrlArr = [dic objectForKey:@"video_urls"];
        NSDictionary *urlInfo = [webUrlArr objectAtIndex:0];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[urlInfo objectForKey:@"url"]]];
        return;
    }
    IphoneWebPlayerViewController *iphoneWebPlayerViewController = [[IphoneWebPlayerViewController alloc] init];
    iphoneWebPlayerViewController.playNum = num;
    iphoneWebPlayerViewController.nameStr = name_;
    iphoneWebPlayerViewController.episodesArr = episodesArr_;
    iphoneWebPlayerViewController.videoType = type_;
    iphoneWebPlayerViewController.prodId = prodId_;
    NSString *str = [NSString stringWithFormat:@"%@_%@",prodId_,[NSString stringWithFormat:@"%d",(num+1) ]];
    NSNumber *cacheResult = [[CacheUtility sharedCache] loadFromCache:str];
    
    iphoneWebPlayerViewController.playBackTime = cacheResult;
    [self presentViewController:[[CustomNavigationViewController alloc] initWithRootViewController:iphoneWebPlayerViewController] animated:YES completion:nil];
}



-(BOOL)checkNetWork{
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([hostReach currentReachabilityStatus] != NotReachable){
        return YES;
    }
    else{
        return NO;
    }

}

@end
