//
//  VideoDetailViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-29.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "VideoDetailViewController.h"
#import "SelectListViewController.h"
#import "CommonHeader.h"
#import "CommonMotheds.h"
#import "ListViewController.h"
#import "AvVideoWebViewController.h"
#import "CommentDetailViewController.h"
#import "AVPlayerViewController.h"
#import "SubdownloadItem.h"

@interface VideoDetailViewController ()
- (NSDictionary *)downloadedItem:(NSString *)Id
                           index:(NSInteger)index;
@end

@implementation VideoDetailViewController
@synthesize prodId;
@synthesize fromViewController;
@synthesize type;
@synthesize subname;
@synthesize mp4DownloadUrls;
@synthesize m3u8DownloadUrls;
@synthesize downloadUrls;
@synthesize downloadSource;
@synthesize canPlayVideo;

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
    [self.view addGestureRecognizer:self.swipeRecognizer];
    // Custom initialization
    self.bgImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.frame.size.height)];
    self.bgImage.image = [UIImage imageNamed:@"left_background@2x.jpg"];
    self.bgImage.layer.zPosition = -1;
    [self.view addSubview:self.bgImage];
    
    [self setCloseTipsViewHidden:NO];
    mp4DownloadUrls = [[NSMutableArray alloc]initWithCapacity:5];
    m3u8DownloadUrls = [[NSMutableArray alloc]initWithCapacity:5];
    downloadUrls = [[NSMutableArray alloc]initWithCapacity:5];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self clearMemory];
}

- (void)clearMemory
{
    _sinaweibo = nil;
    video = nil;
    topics = nil;
    [mp4DownloadUrls removeAllObjects];
    mp4DownloadUrls = nil;
    [m3u8DownloadUrls removeAllObjects];
    m3u8DownloadUrls = nil;
    [downloadUrls removeAllObjects];
    downloadUrls = nil;
    episodeArray = nil;
    umengPageName = nil;
}

- (void)dealloc
{
    [self clearMemory];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:umengPageName];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:umengPageName];
}

- (void)shareBtnClicked
{
    //Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [UIUtility showNetWorkError:self.view];
        return;
    }
    _sinaweibo = [AppDelegate instance].sinaweibo;
    _sinaweibo.delegate = self;
    
    if ([_sinaweibo isLoggedIn]) {
        
        [AppDelegate instance].rootViewController.prodId = self.prodId;
        [AppDelegate instance].rootViewController.prodUrl = [video objectForKey:@"poster"];
        [AppDelegate instance].rootViewController.prodName = [video objectForKey:@"name"];
        [[AppDelegate instance].rootViewController showSharePopup];
    } else {
        [_sinaweibo logIn];
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

- (NSDictionary *)downloadedItem:(NSString *)Id
                           index:(NSInteger)index
{
    NSArray * playlists = [CommonMotheds localPlaylists:Id type:type];
    
    if (0 == playlists.count)
    {
        return nil;
    }
    
    NSDictionary * playInfo = [[video objectForKey:@"episodes"] objectAtIndex:index];
    
    if (SHOW_TYPE == type
        || COMIC_TYPE == type
        || DRAMA_TYPE == type)
    {
        for (NSDictionary * dic in playlists)
        {
            if ([[dic objectForKey:@"name"] isEqualToString:[playInfo objectForKey:@"name"]])
            {
                return dic;
            }
        }
    }
    else
    {
        for (NSDictionary * dic in playlists)
        {
            if ([[dic objectForKey:@"itemId"] isEqualToString:Id])
            {
                return dic;
            }
        }
        //        if ([[playInfo objectForKey:@"id"] isEqualToString:Id])
        //        {
        //            return [playlists objectAtIndex:0];
        //        }
    }
    return nil;
}

- (NSMutableArray *)tureWangpanDownloadURL:(NSArray *)wangpanHTML
{
    NSMutableArray * urls = [NSMutableArray array];
    for (NSString * url in wangpanHTML)
    {
        NSArray * array = [url componentsSeparatedByString:@"|"];
        NSString * tureURL = nil;
        if (array.count == 2)
        {
            tureURL = [array objectAtIndex:0];
            
            NSString *downloadURL = [CommonMotheds getDownloadURLWithHTML:tureURL];
            if (nil != downloadURL)
            {
                [urls addObject:[NSString stringWithFormat:@"%@|%@",downloadURL,[array objectAtIndex:1]]];
            }
        }
    }
    return urls;
}

#pragma mark - SinaWeibo Delegate

- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
    [self shareBtnClicked];
    [self storeAuthData];
    [sinaweibo requestWithURL:@"users/show.json"
                       params:[NSMutableDictionary dictionaryWithObject:sinaweibo.userID forKey:@"uid"]
                   httpMethod:@"GET"
                     delegate:self];
}

- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboDidLogOut");
    [self removeAuthData];
}

- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboLogInDidCancel");
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error
{
    NSLog(@"sinaweibo logInDidFailWithError %@", error);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                        message:@"网络数据错误，请重新登陆。"
                                                       delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error
{
    NSLog(@"sinaweiboAccessTokenInvalidOrExpired %@", error);
    [self removeAuthData];
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
                [[CacheUtility sharedCache] removeObjectForKey:WATCH_RECORD_CACHE_KEY];
                [[CacheUtility sharedCache] removeObjectForKey:@"my_support_list"];
                [[CacheUtility sharedCache] removeObjectForKey:@"my_collection_list"];
                //                [[NSNotificationCenter defaultCenter] postNotificationName:PERSONAL_VIEW_REFRESH object:nil];
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
        
    }
}



- (NSString *)parseVideoUrl:(NSDictionary *)tempVideo
{
    NSString *videoUrl;
    NSArray *urlArray =  [tempVideo objectForKey:@"urls"];
    for(NSDictionary *url in urlArray){
        if([GAO_QING isEqualToString:[url objectForKey:@"type"]]){
            videoUrl = [url objectForKey:@"url"];
            break;
        }
    }
    if(videoUrl == nil){
        for(NSDictionary *url in urlArray){
            if([BIAO_QING isEqualToString:[url objectForKey:@"type"]]){
                videoUrl = [url objectForKey:@"url"];
                break;
            }
        }
    }
    if(videoUrl == nil){
        for(NSDictionary *url in urlArray){
            if([LIU_CHANG isEqualToString:[url objectForKey:@"type"]]){
                videoUrl = [url objectForKey:@"url"];
                break;
            }
        }
    }
    if(videoUrl == nil){
        for(NSDictionary *url in urlArray){
            if([CHAO_QING isEqualToString:[url objectForKey:@"type"]]){
                videoUrl = [url objectForKey:@"url"];
                break;
            }
        }
    }
    if(videoUrl == nil){
        if(urlArray.count > 0){
            videoUrl = [[urlArray objectAtIndex:0] objectForKey:@"url"];
        }
    }
    return videoUrl;
}

//- (void)addListBtnClicked
//{
//    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
//    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
//        [UIUtility showNetWorkError:self.view];
//        return;
//    }
//    SelectListViewController *viewController = [[SelectListViewController alloc]init];
//    viewController.prodId = self.prodId;
//    viewController.type = self.type;
//    viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
//    [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:NO];
//}

- (void)reportBtnClicked
{
    //Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [UIUtility showNetWorkError:self.view];
        return;
    }
    [AppDelegate instance].rootViewController.prodId = self.prodId;
    [AppDelegate instance].rootViewController.prodName = [video objectForKey:@"name"];
    [AppDelegate instance].rootViewController.prodType = [NSString stringWithFormat:@"%i", type];
    [[AppDelegate instance].rootViewController showReportPopup:self.prodId];
}

- (void)showSublistView:(int)num{
    ListViewController *viewController = [[ListViewController alloc] init];
    viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
    NSDictionary *item = [topics objectAtIndex:num];
    NSString *topId = [NSString stringWithFormat:@"%@", [item objectForKey: @"t_id"]];
    viewController.topId = topId;
    viewController.listTitle = [item objectForKey: @"t_name"];
    [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:NO];
}

- (void)closeBtnClicked
{
    fromViewController.moveToLeft = YES;
    if (fromViewController == nil) {
        [[AppDelegate instance].rootViewController.stackScrollViewController removeViewInSlider];
    } else {
        [[AppDelegate instance].rootViewController.stackScrollViewController removeViewToViewInSlider:fromViewController.class];
    }
}

NSComparator sortString = ^(id obj1, id obj2){
    if ([obj1 floatValue] > [obj2 floatValue]) {
        return (NSComparisonResult)NSOrderedDescending;
    }
    
    if ([obj1 floatValue] < [obj2 floatValue]) {
        return (NSComparisonResult)NSOrderedAscending;
    }
    return (NSComparisonResult)NSOrderedSame;
};

- (void)getDownloadUrls:(int)num
{
    if(num < 0 || num >=episodeArray.count){
        return;
    }
    [mp4DownloadUrls removeAllObjects];
    [m3u8DownloadUrls removeAllObjects];
    [downloadUrls removeAllObjects];
    
    NSMutableArray * allUrls_ = [NSMutableArray array];
    NSArray *videoUrlArray = [[episodeArray objectAtIndex:num] objectForKey:@"down_urls"];
    
    for (NSDictionary *dic in videoUrlArray) {
        NSArray *oneSourceArr = [dic objectForKey:@"urls"];
        NSString *source = [dic objectForKey:@"source"];
        self.downloadSource = source;
        for (NSDictionary *oneUrlInfo in oneSourceArr) {
            
            NSString * str = [oneUrlInfo objectForKey:@"url"];
            NSString *tempUrl = str;
            if([str rangeOfString:@"{now_date}"].location != NSNotFound){
                int nowDate = [[NSDate date] timeIntervalSince1970];
                tempUrl = [str stringByReplacingOccurrencesOfString:@"{now_date}" withString:[NSString stringWithFormat:@"%i", nowDate]];
            }
            NSString *filetype = [oneUrlInfo objectForKey:@"file"];
            NSDictionary *myDic = [NSDictionary dictionaryWithObjectsAndKeys:tempUrl,@"url",filetype,@"type",source,@"source", nil];
            
            [allUrls_ addObject:myDic];
        }
    }
    
    NSMutableArray *tempSortArr = [NSMutableArray arrayWithCapacity:5];
    for (NSDictionary *dic in allUrls_)
    {
        NSMutableDictionary *temp_dic = [NSMutableDictionary dictionaryWithDictionary:dic];
        NSString *source_str = [temp_dic objectForKey:@"source"];
        
        if ([source_str isEqualToString:@"wangpan"]) {
            [temp_dic setObject:@"0.1" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"le_tv_fee"]) {
            [temp_dic setObject:@"0.2" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"letv"]) {
            [temp_dic setObject:@"1" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"fengxing"]){
            [temp_dic setObject:@"2" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"qiyi"]){
            [temp_dic setObject:@"3" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"youku"]){
            [temp_dic setObject:@"4" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"sinahd"]){
            [temp_dic setObject:@"5" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"sohu"]){
            [temp_dic setObject:@"6" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"56"]){
            [temp_dic setObject:@"7" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"qq"]){
            [temp_dic setObject:@"8" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"pptv"]){
            [temp_dic setObject:@"9" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"pps"]){
            [temp_dic setObject:@"10" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"m1905"]){
            [temp_dic setObject:@"11" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"baidu_wangpan"]){
            [temp_dic setObject:@"12" forKey:@"level"];
        }
        [tempSortArr addObject:temp_dic];
    }
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"level" ascending:YES comparator:sortString];
    allUrls_ = [NSMutableArray arrayWithArray:[tempSortArr sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]]];
    
    if(allUrls_.count > 0)
    {
        for(NSDictionary *tempVideo in allUrls_)
        {
            NSString * videoInfo = [NSString stringWithFormat:@"%@|%@",[tempVideo objectForKey:@"url"],[tempVideo objectForKey:@"type"]];
            [downloadUrls addObject:videoInfo];
        }
    }
}

- (void)updateBadgeIcon
{
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_DOWNLOAD_ITEM_NUM object:nil];
}

- (void)playVideo:(int)num
{
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [UIUtility showNetWorkError:self.view];
        return;
    }
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isWifiReachable)]){
        willPlayIndex = num;
        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil
                                                           message:@"播放视频会消耗大量流量，您确定要在非WiFi环境下播放吗？"
                                                          delegate:self
                                                 cancelButtonTitle:@"取消"
                                                 otherButtonTitles:@"确定", nil];
        alertView.tag = 8888;
        [alertView show];
    } else {
        [self willPlayVideo:num];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 8888) {
        if(buttonIndex == 1){
            [self willPlayVideo:willPlayIndex];
        }
    }
    else{
        NSMutableArray *httpUrlArray = [[NSMutableArray alloc]initWithCapacity:5];
        for (int i = 0; i < episodeArray.count; i++) {
            NSArray *videoUrls = [[episodeArray objectAtIndex:i] objectForKey:@"video_urls"];
            BOOL found = NO;
            for (NSDictionary *videoUrl in videoUrls) {
                NSString *url = [NSString stringWithFormat:@"%@", [videoUrl objectForKey:@"url"]];
                if([self validadUrl:url]){
                    NSString *httpUrl = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    [httpUrlArray addObject:httpUrl];
                    found = YES;
                    break;
                }
            }
            if (!found) {
                [httpUrlArray addObject:@""];
            }
        }
        if (buttonIndex == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[httpUrlArray objectAtIndex:0]]];
        }
        else if(buttonIndex == 1){
            [self beginPlayVideo:playNum withArray:httpUrlArray];
        }
        
    }
    
}

- (void)willPlayVideo:(int)num
{
    if(num < 0 || num >= episodeArray.count){
        return;
    }
    
    NSArray *downUrls = [[episodeArray objectAtIndex:num] objectForKey:@"down_urls"];
    for (NSDictionary *downUrl in downUrls)
    {
        NSArray *urls = [downUrl objectForKey:@"urls"];
        for (NSDictionary *url in urls)
        {
            NSString *realurl = [url objectForKey:@"url"];
            NSString *trimUrl = [realurl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (trimUrl && trimUrl.length > 0)
            {
                hasVideoUrl_ = YES;
            }
        }
    }

    playNum = num;
    [self recordPlayStatics];
    // 网页地址
    NSMutableArray *httpUrlArray = [[NSMutableArray alloc]initWithCapacity:5];
    for (int i = 0; i < episodeArray.count; i++) {
        NSArray *videoUrls = [[episodeArray objectAtIndex:i] objectForKey:@"video_urls"];
        BOOL found = NO;
        for (NSDictionary *videoUrl in videoUrls) {
            NSString *url = [NSString stringWithFormat:@"%@", [videoUrl objectForKey:@"url"]];
            if([self validadUrl:url]){
                NSString *httpUrl = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                [httpUrlArray addObject:httpUrl];
                found = YES;
                break;
            }
        }
        if (!found) {
            [httpUrlArray addObject:@""];
        }
    }
    if ([[AppDelegate instance].showVideoSwitch isEqualToString:@"2"])
    {
        if (httpUrlArray.count > 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[httpUrlArray objectAtIndex:0]]];
        } else {
            [UIUtility showPlayVideoFailure:self.view];
        }
        return;
    }
    else if ([[AppDelegate instance].showVideoSwitch isEqualToString:@"3"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"将使用何种方式来播放？" delegate:self cancelButtonTitle:@"Safari" otherButtonTitles:@"内置浏览器", nil];
        alert.tag = 9999;
        [alert show];
        return;
        
    }
    
    [self beginPlayVideo:num withArray:httpUrlArray];
    
}

-(void)beginPlayVideo:(int)num  withArray:(NSMutableArray *)httpUrlArray{
    
    NSDictionary * info = [self downloadedItem:self.prodId index:num];
    if (nil != info)
    {
        AVPlayerViewController *viewController = [[AVPlayerViewController alloc]init];
        viewController.videoFormat = [info objectForKey:@"downloadType"];
        viewController.isDownloaded = YES;
        viewController.m3u8Duration = [[info objectForKey:@"duration"] intValue];
        viewController.closeAll = YES;
        viewController.videoUrl = [info objectForKey:@"videoUrl"];
        viewController.type = type;
        viewController.name = [video objectForKey:@"name"];//[info objectForKey:@"name"];
        if (type == SHOW_TYPE)
        {
            viewController.subname = [info objectForKey:@"name"];
        } else {
            viewController.subname = [info objectForKey:@"subItemId"];
        }
        viewController.currentNum = num;
        viewController.prodId = self.prodId;
        viewController.video = video;
        viewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, 768);
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [[AppDelegate instance].rootViewController pesentMyModalView:viewController];
        return;
    }
    
    BOOL hasVideoUrls = NO;
    for (int i = 0; i < episodeArray.count; i++) {
        NSArray *videoUrlArray = [[episodeArray objectAtIndex:num] objectForKey:@"down_urls"];
        if(videoUrlArray.count > 0){
            for(NSDictionary *tempVideo in videoUrlArray){
                hasVideoUrls = YES;
                break;
            }
        }
        if (hasVideoUrls) {
            break;
        }
    }
    
    AvVideoWebViewController *webViewController = [[AvVideoWebViewController alloc] init];
    webViewController.videoHttpUrlArray = httpUrlArray;
    webViewController.prodId = self.prodId;
    webViewController.hasVideoUrls = hasVideoUrls;
    webViewController.type = type;
    webViewController.currentNum = num;
    webViewController.dramaDetailViewControllerDelegate = self;
    webViewController.video = video;
    webViewController.hasVideoUrl = hasVideoUrl_;
    webViewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [[AppDelegate instance].rootViewController pesentMyModalView:[[UINavigationController alloc]initWithRootViewController:webViewController]];
    
}
- (void)recordPlayStatics
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: self.prodId, @"prod_id", [video objectForKey:@"name"], @"prod_name", subname, @"prod_subname", [NSNumber numberWithInt:type], @"prod_type", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathRecordPlay parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (BOOL)validadUrl:(NSString *)originalUrl
{
    NSString *formatUrl = [[originalUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    if([formatUrl hasPrefix:@"http://"] || [formatUrl hasPrefix:@"https://"]){
        return YES;
    }
    return NO;
}

// This callback method will be implemented by subclasses.
- (void)playNextEpisode{
    
}

- (void)showCommentDetail:(NSDictionary *)commentItem
{
    CommentDetailViewController *viewController = [[CommentDetailViewController alloc]init];
    viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
    viewController.titleContent = [commentItem objectForKey:@"title"];
    viewController.content = [commentItem objectForKey:@"comments"];
    viewController.parentDelegateController = self;
    viewController.preViewController = self;
    [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:YES moveToLeft:self.moveToLeft];
    //self.moveToLeft = NO;
}

- (void)hideCloseBtn
{
    //error: never be here , implemented in subclasses.
}

- (void)checkCanPlayVideo
{
    for (NSDictionary *epi in episodeArray) {
        NSArray *videoUrls = [epi objectForKey:@"video_urls"];
        for (NSDictionary *videoUrl in videoUrls) {
            NSString *url = [videoUrl objectForKey:@"url"];
            NSString *source = [videoUrl objectForKey:@"source"];
            NSString *trimUrl = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([source isEqualToString:@"yuanxian"]) {
                canPlayVideo = NO;
                return;
            }
            if (trimUrl && trimUrl.length > 0) {
                canPlayVideo = YES;
                break;
            }
        }
        if (canPlayVideo) {
            break;
        } else {
            NSArray *downUrls = [epi objectForKey:@"down_urls"];
            for (NSDictionary *downUrl in downUrls) {
                NSArray *urls = [downUrl objectForKey:@"urls"];
                for (NSDictionary *url in urls) {
                    NSString *realurl = [url objectForKey:@"url"];
                    NSString *trimUrl = [realurl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    if (trimUrl && trimUrl.length > 0) {
                        canPlayVideo = YES;
                        break;
                    }
                }
                if (canPlayVideo) {
                    break;
                }
            }
        }
    }
}

- (BOOL)isDownloadURLExit
{
    for (NSDictionary *epi in episodeArray)
    {
        NSArray *downUrls = [epi objectForKey:@"down_urls"];
        for (NSDictionary *downUrl in downUrls)
        {
            NSArray *urls = [downUrl objectForKey:@"urls"];
            for (NSDictionary *url in urls)
            {
                NSString *realurl = [url objectForKey:@"url"];
                NSString *trimUrl = [realurl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if (trimUrl && trimUrl.length > 0)
                {
                    return YES;
                }
            }
        }
    }
    return NO;
}

@end
