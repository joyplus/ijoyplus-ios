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
#import "VideoWebViewController.h"
#import "CustomNavigationViewController.h"
#import "CacheUtility.h"
#import "TimeUtility.h"
#import "UIImage+Scale.h"
#define VIEWTAG   123654

@interface IphoneVideoViewController ()

@end

@implementation IphoneVideoViewController
@synthesize mySinaWeibo = _mySinaWeibo;
@synthesize infoDic = _infoDic;
@synthesize episodesArr = episodesArr_;
@synthesize prodId = prodId_;
@synthesize subName = subName_;
@synthesize name = name_;
@synthesize videoUrlsArray = videoUrlsArray_;
@synthesize httpUrlArray = httpUrlArray_;
@synthesize isNotification = isNotification_;
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
        [self.navigationController.navigationBar setBackgroundImage:[UIImage scaleFromImage:[UIImage imageNamed:@"top_bg_common.png"] toSize:CGSizeMake(320, 44)] forBarMetrics:UIBarMetricsDefault];
    }
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
   
    if (type == ADDFAV) {
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
    if (type == DING ) {
         UIImageView *temp = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"operation_is_successful.png"]];
        temp.frame = CGRectMake(0, 0, 92, 27);
        temp.center = view.center;
        [view addSubview:temp];
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
    UIImageView *temp = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"operation_fails.png"]];
    if (type == DING) {
        temp.frame = CGRectMake(0, 0, 92, 27);
        temp.center = view.center;
    }
    if (type == ADDFAV) {
        temp.frame = CGRectMake(16, 110, 92, 27);
    }
    [view addSubview:temp];
  
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


-(void)share:(id)sender{
   
        _mySinaWeibo = [AppDelegate instance].sinaweibo;
        _mySinaWeibo.delegate = self;
        if ([_mySinaWeibo isLoggedIn]) {
            SendWeiboViewController *sendV = [[SendWeiboViewController alloc] init];
            sendV.infoDic = _infoDic;
            [self presentViewController:[[UINavigationController alloc] initWithRootViewController:sendV] animated:YES completion:nil];
        }
        else{
            [_mySinaWeibo logIn];
           
        }
 
}

#pragma mark - SinaWeibo Delegate
- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo{
    
    SendWeiboViewController *sendV = [[SendWeiboViewController alloc] init];
    sendV.infoDic = _infoDic;
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

- (BOOL)validadUrl:(NSString *)originalUrl
{
    NSString *formatUrl = [[originalUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    if([formatUrl hasPrefix:@"http://"] || [formatUrl hasPrefix:@"https://"]){
        return YES;
    }
    return NO;
}

-(void)playVideo:(int)num{
    if (num < 0 || num >= episodesArr_.count) {
        return;
    }
    // 网页地址
    httpUrlArray_ = [[NSMutableArray alloc]initWithCapacity:5];
    for (int i = 0; i < episodesArr_.count; i++) {
        NSArray *videoUrls = [[episodesArr_ objectAtIndex:i] objectForKey:@"video_urls"];
    
        BOOL found = NO;
        for (NSDictionary *videoUrl in videoUrls) {
            NSString *url = [NSString stringWithFormat:@"%@", [videoUrl objectForKey:@"url"]];
            if([self validadUrl:url]){
                NSString *httpUrl = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                [httpUrlArray_ addObject:httpUrl];
                found = YES;
                break;
            }
        }
        if (!found) {
            [httpUrlArray_ addObject:@""];
        }
    }
    if ([[AppDelegate instance].showVideoSwitch isEqualToString:@"2"]) {
        if (httpUrlArray_.count > 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[httpUrlArray_ objectAtIndex:0]]];
        } else {
            [UIUtility showPlayVideoFailure:self.view];
        }
    } else {
        // 视频地址
        videoUrlsArray_ = [[NSMutableArray alloc]initWithCapacity:5];
        if ([[AppDelegate instance].showVideoSwitch isEqualToString:@"0"]) { // 0:先播放视频，再播放网页
            for (int i = 0; i < episodesArr_.count; i++) {
                NSMutableArray *urlsArray = [[NSMutableArray alloc]initWithCapacity:5];
                NSArray *videoUrlArray = [[episodesArr_ objectAtIndex:i] objectForKey:@"down_urls"];
                if(videoUrlArray.count > 0){
                    NSMutableArray *urlsDicArray = [[NSMutableArray alloc]initWithCapacity:5];
                    for(NSDictionary *tempVideo in videoUrlArray){
                        NSArray *urls = [tempVideo objectForKey:@"urls"];
                        [urlsDicArray addObjectsFromArray:urls];
                    }
                    urlsDicArray = [urlsDicArray sortedArrayUsingComparator:^(NSDictionary *a, NSDictionary *b) {
                        NSNumber *first =  [NSString stringWithFormat:@"%@", [a objectForKey:@"file"]];
                        NSNumber *second = [NSString stringWithFormat:@"%@", [b objectForKey:@"file"]];
                        return [second compare:first];
                    }];
                    for (NSDictionary *url in urlsDicArray) {
                        NSString *tempUrl = [url objectForKey:@"url"];
                        if([self validadUrl:tempUrl]){
                            [urlsArray addObject:[tempUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
                        }
                    }
                }
                [videoUrlsArray_ addObject:urlsArray];
            }
        }
       
        VideoWebViewController *webViewController = [[VideoWebViewController alloc] init];
        webViewController.videoUrlsArray = videoUrlsArray_;
        webViewController.videoHttpUrlArray = httpUrlArray_;
        webViewController.prodId = self.prodId;
        webViewController.type = type_;
        webViewController.startNum = num;
       // webViewController.dramaDetailViewControllerDelegate = self;
        webViewController.subname = [NSString stringWithFormat:@"%d",num];
        webViewController.playTime = [self getRecordInfo:num];
        webViewController.name = name_;
        webViewController.currentNum = num;
        NSLog(@"now play is %d",num);
        //webViewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);CustomNavigationViewController
       [self presentViewController:[[CustomNavigationViewController alloc] initWithRootViewController:webViewController] animated:YES completion:nil];
    }
}

-(NSString*)getRecordInfo:(int)num{
    NSNumber *cacheResult = [[CacheUtility sharedCache] loadFromCache:[NSString stringWithFormat:@"%@_%@",prodId_,[NSString stringWithFormat:@"%d",num]]];
    NSString *content = nil;
    NSString *time = [TimeUtility formatTimeInSecond:cacheResult.doubleValue];
    if ([time isEqualToString:@"00:00"]) {
        content = @"即将播出";
    }
    else{
        content = [NSString stringWithFormat:@"上次播放至: %@",time];
    }
    return content;
    
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
