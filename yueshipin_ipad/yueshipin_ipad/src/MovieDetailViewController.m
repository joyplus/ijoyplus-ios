//
//  MovieDetailViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-20.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "MovieDetailViewController.h"
#import "CommonHeader.h"
#import "SinaWeibo.h"
#import "SublistViewController.h"
#import "CommentListViewController.h"
#import "ListViewController.h"
#import "DownloadItem.h"
#import "DownloadHandler.h"
#import "DownloadUrlFinder.h"
#import <QuartzCore/QuartzCore.h>


#define DEFAULT_POSOTION_Y 585

@interface MovieDetailViewController (){
    NSMutableArray *commentArray;
    SublistViewController *topicListViewController;
    CommentListViewController *commentListViewController;
    UIButton *introBtn;
    float introContentHeight;
    BOOL introExpand;
    UITapGestureRecognizer *tapGesture;
}

@end

@implementation MovieDetailViewController


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setDownloadBtn:nil];
    [commentArray removeAllObjects];
    commentArray = nil;
    episodeArray = nil;
    topicListViewController = nil;
    commentListViewController = nil;
    introBtn = nil;
    tapGesture = nil;
    [self setBgScrollView:nil];
    [self setPlaceholderImage:nil];
    [self setFilmImage:nil];
    [self setTitleImage:nil];
    [self setTitleLabel:nil];
    [self setScoreLabel:nil];
    [self setDoulanLogo:nil];
    [self setDirectorLabel:nil];
    [self setDirectorNameLabel:nil];
    [self setActorLabel:nil];
    [self setActorName1Label:nil];
    [self setPlayLabel:nil];
    [self setPlayTimeLabel:nil];
    [self setRegionLabel:nil];
    [self setRegionNameLabel:nil];
    [self setDingBtn:nil];
    [self setCollectionBtn:nil];
    [self setPlayBtn:nil];
    [self setShareBtn:nil];
    [self setAddListBtn:nil];
    [self setLineImage:nil];
    [self setIntroImage:nil];
    [self setIntroBgImage:nil];
    [self setIntroContentTextView:nil];
    [self setRelatedImage:nil];
    [self setCommentImage:nil];
    [self setNumberLabel:nil];
    [self setCommentBtn:nil];
    [self setDingNumberImage:nil];
    [self setCollectioNumber:nil];
    [self setPlayRoundBtn:nil];
    [self setDingNumberLabel:nil];
    [self setCollectionNumberLabel:nil];
    [self setRelatedBgImage:nil];
    [self setCloseBtn:nil];
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
    
    self.type = 1;
    umengPageName = MOVIE_DETAIL;
    
    self.bgScrollView.frame = CGRectMake(0, 255, self.view.frame.size.width, self.view.frame.size.height);
    [self.bgScrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height*1.5)];
    
    self.closeBtn.frame = CGRectMake(465, 20, 40, 42);
    [self.closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [self.closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
    [self.closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.placeholderImage.frame = CGRectMake(LEFT_WIDTH, 78, 217, 312);
    self.placeholderImage.image = [UIImage imageNamed:@"movie_frame"];
    
    self.filmImage.frame = CGRectMake(LEFT_WIDTH+5, 84, 203, 298);
    self.filmImage.image = [UIImage imageNamed:@"video_placeholder"];
    
    self.playRoundBtn.frame = CGRectMake(0, 0, 63, 63);
    [self.playRoundBtn setBackgroundImage:[UIImage imageNamed:@"play_btn"] forState:UIControlStateNormal];
    [self.playRoundBtn setBackgroundImage:[UIImage imageNamed:@"play_btn_pressed"] forState:UIControlStateHighlighted];
    [self.playRoundBtn addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
    
    self.playRoundBtn.center = self.filmImage.center;
    
    self.titleImage.frame = CGRectMake(LEFT_WIDTH, 35, 62, 26);
    self.titleImage.image = [UIImage imageNamed:@"detail_title"];
    
    self.titleLabel.frame = CGRectMake(278, 85, 200, 20);
    self.titleLabel.font = CMConstants.titleFont;
    
    self.scoreLabel.frame = CGRectMake(280, 110, 50, 20);
    self.doulanLogo.frame = CGRectMake(325, 113, 15, 15);
    self.doulanLogo.image = [UIImage imageNamed:@"douban"];
    
    self.playBtn.frame = CGRectMake(280, 150, 185, 40);
    [self.playBtn setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [self.playBtn setBackgroundImage:[UIImage imageNamed:@"play_pressed"] forState:UIControlStateHighlighted];
    [self.playBtn addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
    
    self.directorLabel.frame = CGRectMake(280, 205, 50, 15);
    self.directorLabel.textColor = CMConstants.grayColor;
    self.directorNameLabel.frame = CGRectMake(325, 205, 140, 15);
    self.directorNameLabel.textColor = CMConstants.grayColor;
    self.actorLabel.frame = CGRectMake(280, 230, 50, 15);
    self.actorLabel.textColor = CMConstants.grayColor;
    self.actorName1Label.frame = CGRectMake(325, 230, 140, 15);
    self.actorName1Label.textColor = CMConstants.grayColor;
    //    self.actorName2Label.frame = CGRectMake(335, 255, 140, 15);
    //    self.actorName2Label.textColor = CMConstants.grayColor;
    //    self.actorName3Label.frame = CGRectMake(335, 280, 140, 15);
    //    self.actorName3Label.textColor = CMConstants.grayColor;
    
    self.playLabel.frame = CGRectMake(280, 260, 50, 15);
    self.playLabel.textColor = CMConstants.grayColor;
    self.playTimeLabel.frame = CGRectMake(325, 260, 100, 15);
    self.playTimeLabel.textColor = CMConstants.grayColor;
    self.regionLabel.frame = CGRectMake(280, 290, 50, 15);
    self.regionLabel.textColor = CMConstants.grayColor;
    self.regionNameLabel.frame = CGRectMake(325, 290, 100, 15);
    self.regionNameLabel.textColor = CMConstants.grayColor;
    
    
    self.dingNumberImage.frame = CGRectMake(280, 360, 75, 24);
    self.dingNumberImage.image = [UIImage imageNamed:@"pushinguser"];
    self.dingNumberLabel.frame = CGRectMake(285, 360, 40, 24);
    
    self.collectioNumber.frame = CGRectMake(375, 360, 84, 24);
    self.collectioNumber.image = [UIImage imageNamed:@"collectinguser"];
    self.collectionNumberLabel.frame = CGRectMake(385, 360, 40, 24);
    
    self.dingBtn.frame = CGRectMake(LEFT_WIDTH, 405, 55, 34);
    [self.dingBtn setBackgroundImage:[UIImage imageNamed:@"push"] forState:UIControlStateNormal];
    [self.dingBtn setBackgroundImage:[UIImage imageNamed:@"push_pressed"] forState:UIControlStateHighlighted];
    [self.dingBtn addTarget:self action:@selector(dingBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.collectionBtn.frame = CGRectMake(LEFT_WIDTH + 60, 405, 74, 34);
    [self.collectionBtn setBackgroundImage:[UIImage imageNamed:@"collection"] forState:UIControlStateNormal];
    [self.collectionBtn setBackgroundImage:[UIImage imageNamed:@"collection_pressed"] forState:UIControlStateHighlighted];
    [self.collectionBtn addTarget:self action:@selector(collectionBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.shareBtn.frame = CGRectMake(LEFT_WIDTH + 140, 405, 74, 34);
    [self.shareBtn setBackgroundImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [self.shareBtn setBackgroundImage:[UIImage imageNamed:@"share_pressed"] forState:UIControlStateHighlighted];
    [self.shareBtn addTarget:self action:@selector(shareBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.addListBtn.frame = CGRectMake(280, 405, 104, 34);
    [self.addListBtn setBackgroundImage:[UIImage imageNamed:@"listing"] forState:UIControlStateNormal];
    [self.addListBtn setBackgroundImage:[UIImage imageNamed:@"listing_pressed"] forState:UIControlStateHighlighted];
    [self.addListBtn addTarget:self action:@selector(addListBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.downloadBtn.frame = CGRectMake(394, 405, 76, 34);
    [self.downloadBtn setBackgroundImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
    [self.downloadBtn setBackgroundImage:[UIImage imageNamed:@"download_pressed"] forState:UIControlStateHighlighted];
    [self.downloadBtn addTarget:self action:@selector(downloadBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.lineImage.frame = CGRectMake(LEFT_WIDTH, 450, 430, 2);
    self.lineImage.image = [UIImage imageNamed:@"dividing"];
    
    self.introImage.frame = CGRectMake(LEFT_WIDTH, 460, 45, 20);
    self.introImage.image = [UIImage imageNamed:@"brief_title"];
    
    self.introBgImage.frame = CGRectMake(LEFT_WIDTH, 490, 430, 100);
    self.introBgImage.image = [[UIImage imageNamed:@"brief"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    
    self.introContentTextView.frame = CGRectMake(LEFT_WIDTH + 10, 490, 420, 100);
    self.introContentTextView.textColor = CMConstants.grayColor;
    tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(introBtnClicked)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self.introContentTextView addGestureRecognizer:tapGesture];
    
    introBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [introBtn setBackgroundImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    introBtn.frame = CGRectMake(LEFT_WIDTH + 410, self.introContentTextView.frame.origin.y + 90, 14, 9);
    [introBtn addTarget:self action:@selector(introBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.bgScrollView addSubview:introBtn];
    
    commentArray = [[NSMutableArray alloc]initWithCapacity:10];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(![@"0" isEqualToString:[AppDelegate instance].showVideoSwitch]){
        [self.downloadBtn setHidden:YES];
    }
    if(video == nil){
        [self retrieveData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([@"0" isEqualToString:[AppDelegate instance].showVideoSwitch] && self.downloadBtn.enabled) {
        NSString *playWithDownload = [AppDelegate instance].playWithDownload;
        if (![playWithDownload isEqualToString:@"1"]) {
            [AppDelegate instance].playWithDownload = @"1";
            [[AppDelegate instance].rootViewController showIntroModalView:SHOW_PLAY_INTRO_WITH_DOWNLOAD introImage:[UIImage imageNamed:@"play_intro_with_download"]];
            [[ContainerUtility sharedInstance] setAttribute:@"1" forKey:SHOW_PLAY_INTRO];
            [[ContainerUtility sharedInstance] setAttribute:@"1" forKey:SHOW_DOWNLOAD_INTRO];
        }
    } else {
        [[AppDelegate instance].rootViewController showIntroModalView:SHOW_PLAY_INTRO introImage:[UIImage imageNamed:@"play_intro"]];
    }
}

- (void)retrieveData
{
    BOOL isReachable = [[AppDelegate instance] performSelector:@selector(isParseReachable)];
    if(!isReachable) {
        [UIUtility showNetWorkError:self.view];
    }
    NSString *key = [NSString stringWithFormat:@"%@%@", @"movie", self.prodId];
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:key];
    if(cacheResult != nil){
        [self parseData:cacheResult];
    } else {
        if(isReachable) {
            [myHUD showProgressBar:self.view];
        }
    }
    if([[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: self.prodId, @"prod_id", nil];
        [[AFServiceAPIClient sharedClient] getPath:kPathProgramView parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [self parseData:result];
            [myHUD hide];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            [myHUD hide];
            [UIUtility showSystemError:self.view];
        }];
    } else {
        [myHUD hide];
    }
}

- (void)parseData:(id)result
{
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        NSString *key = [NSString stringWithFormat:@"%@%@", @"movie", self.prodId];
        [[CacheUtility sharedCache] putInCache:key result:result];
        video = (NSDictionary *)[result objectForKey:@"movie"];
        episodeArray = [video objectForKey:@"episodes"];
        topics = [result objectForKey:@"topics"];
        NSArray *tempArray = (NSMutableArray *)[result objectForKey:@"comments"];
        [commentArray removeAllObjects];
        if(tempArray != nil && tempArray.count > 0){
            [commentArray addObjectsFromArray:tempArray];
        }
        [self calculateIntroContentHeight];
        if(introContentHeight < 100){
            [introBtn removeFromSuperview];
            introBtn = nil;
        }
        [self getDownloadUrls:0];
        [self showValues];
        
    } else {
        [UIUtility showSystemError:self.view];
    }
}

- (void)calculateIntroContentHeight
{
    self.introContentTextView.text = [video objectForKey:@"summary"];
    introContentHeight = self.introContentTextView.contentSize.height;
}

- (void)showValues
{
    NSString *url = [video objectForKey:@"ipad_poster"];
    if([StringUtility stringIsEmpty:url]){
        url = [video objectForKey:@"poster"];
    }
    [self.filmImage setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
    
    self.titleLabel.text = [video objectForKey:@"name"];
    self.scoreLabel.text = [NSString stringWithFormat:@"%@ 分", [video objectForKey:@"score"]];
    self.scoreLabel.textColor = CMConstants.scoreBlueColor;
    self.directorNameLabel.text = [video objectForKey:@"directors"];
    
    NSString *stars = [video objectForKey:@"stars"];
    self.actorName1Label.text = stars;
    //    NSArray *starArray;
    //    if([stars rangeOfString:@"/"].length > 0){
    //        starArray = [stars componentsSeparatedByString:@"/"];
    //    } else if([stars rangeOfString:@","].length > 0){
    //        starArray = [stars componentsSeparatedByString:@","];
    //    } else {
    //        starArray = [stars componentsSeparatedByString:@" "];
    //    }
    //    if(starArray.count > 0)
    //        self.actorName1Label.text = [((NSString *)[starArray objectAtIndex:0]) stringByReplacingOccurrencesOfString:@" " withString:@""];
    //    if(starArray.count > 1)
    //        self.actorName2Label.text = [((NSString *)[starArray objectAtIndex:1]) stringByReplacingOccurrencesOfString:@" " withString:@""];
    //    if(starArray.count > 2)
    //        self.actorName3Label.text = [((NSString *)[starArray objectAtIndex:2]) stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    self.regionNameLabel.text = [video objectForKey:@"area"];
    self.playTimeLabel.text = [video objectForKey:@"publish_date"];
    self.dingNumberLabel.text = [NSString stringWithFormat:@"%@", [video objectForKey:@"support_num"]];
    self.collectionNumberLabel.text = [NSString stringWithFormat:@"%@", [video objectForKey:@"favority_num"]];
    
    self.introContentTextView.text = [video objectForKey:@"summary"];
    
    if(self.mp4DownloadUrls.count > 0 || self.m3u8DownloadUrls.count > 0){
        // do nothing
        NSLog(@"mp4 count: %i", self.mp4DownloadUrls.count);
        NSLog(@"m3u8 count: %i", self.m3u8DownloadUrls.count);
    } else {
        [self.downloadBtn setEnabled:NO];
        [self.downloadBtn setBackgroundImage:[UIImage imageNamed:@"no_download"] forState:UIControlStateDisabled];
    }
    [self checkIfDownloading];
    [self repositElements:0];
}

- (void)checkIfDownloading
{
    NSString *query = [NSString stringWithFormat:@"WHERE item_id = '%@'", self.prodId];
    DownloadItem *downloadingItem = (DownloadItem *)[DownloadItem findFirstByCriteria:query];
    if(downloadingItem != nil){
        [self.downloadBtn setEnabled:NO];
        if(downloadingItem.percentage == 100){
            [self.downloadBtn setBackgroundImage:[UIImage imageNamed:@"download_disabled"] forState:UIControlStateDisabled];
        } else {
            [self.downloadBtn setBackgroundImage:[UIImage imageNamed:@"downloading"] forState:UIControlStateDisabled];
        }
    }
}

- (void)repositElements:(int)increasePositionY
{
    int positionY = DEFAULT_POSOTION_Y + increasePositionY + 20;
    if(topics.count > 0){
        self.relatedImage.frame = CGRectMake(LEFT_WIDTH, positionY, 80, 20);
        self.relatedImage.image = [UIImage imageNamed:@"morelists_title1"];
        if(topicListViewController == nil){
            topicListViewController = [[SublistViewController alloc]initWithStyle:UITableViewStylePlain];
            topicListViewController.listData = topics;
            topicListViewController.videoDelegate = self;
            [self.bgScrollView addSubview:topicListViewController.tableView];
        }
        topicListViewController.view.frame = CGRectMake(LEFT_WIDTH, positionY + 30, 430, (topics.count > 5 ? 5 : topics.count)*30);
        //        [topicListViewController.tableView reloadData];
        positionY = topicListViewController.view.frame.origin.y + (topics.count > 5 ? 5 : topics.count)*30;
    }
    
    int totalCommentNum = [[video objectForKey:@"total_comment_number"] integerValue];
    self.commentImage.frame = CGRectMake(LEFT_WIDTH, positionY + 20, 74, 19);
    self.commentImage.image = [UIImage imageNamed:@"comment_title"];
    
    self.numberLabel.frame = CGRectMake(139, positionY + 20, 100, 18);
    self.numberLabel.text = [NSString stringWithFormat:@"(%i条)", totalCommentNum];
    self.numberLabel.textColor = CMConstants.grayColor;
    
    self.commentBtn.frame = CGRectMake(405, positionY + 17, 66, 26);
    [self.commentBtn setBackgroundImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];
    [self.commentBtn setBackgroundImage:[UIImage imageNamed:@"comment_pressed"] forState:UIControlStateHighlighted];
    [self.commentBtn addTarget:self action:@selector(commentBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    if(commentListViewController == nil){
        commentListViewController = [[CommentListViewController alloc]initWithStyle:UITableViewStylePlain];
        commentListViewController.prodId = self.prodId;
        commentListViewController.parentDelegate = self;
        [self.bgScrollView addSubview:commentListViewController.view];
    }
    commentListViewController.totalCommentNum = [[video objectForKey:@"total_comment_number"] integerValue];
    commentListViewController.listData = commentArray;
    [commentListViewController.tableView reloadData];
    commentListViewController.view.frame = CGRectMake(LEFT_WIDTH, positionY + 60, 430, commentListViewController.tableHeight);
    
    [self.bgScrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+ (topics.count > 5 ? 5 : topics.count)*30+commentListViewController.tableHeight+300 + increasePositionY)];
    //    commentListViewController.view.frame = CGRectMake(LEFT_WIDTH, commentListViewController.view.frame.origin.y, 425, commentListViewController.tableHeight);
}

- (void)getTopComments:(int)num
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: self.prodId, @"prod_id", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathProgramView parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSString *key = [NSString stringWithFormat:@"%@%@", @"movie", self.prodId];
            [[CacheUtility sharedCache] putInCache:key result:result];
            video = (NSDictionary *)[result objectForKey:@"movie"];
            episodeArray = [video objectForKey:@"episodes"];
            topics = [result objectForKey:@"topics"];
            NSArray *tempArray = (NSMutableArray *)[result objectForKey:@"comments"];
            [commentArray removeAllObjects];
            if(tempArray != nil && tempArray.count > 0){
                [commentArray addObjectsFromArray:tempArray];
            }
            if(introContentHeight > 90){
                if(introExpand){
                    [self repositElements:introContentHeight - 90];
                } else {
                    [self repositElements:0];
                }
            }
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)refreshCommentListView:(int)tableHeight
{
    [self.bgScrollView setContentSize:CGSizeMake(self.view.frame.size.width, commentListViewController.view.frame.origin.y+tableHeight+300)];
    commentListViewController.view.frame = CGRectMake(LEFT_WIDTH, commentListViewController.view.frame.origin.y, 430, tableHeight);
}

- (void)playVideo
{
    self.subname = @"";
    [super playVideo:0];
//    HTTPServer *httpServer = [[HTTPServer alloc] init];
//    [httpServer setPort:12580];
//	[httpServer setType:@"_http._tcp."];
//    NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDir = [documentPaths objectAtIndex:0];
//	[httpServer setDocumentRoot:documentsDir];
//    NSError *error;
//	if([httpServer start:&error]) {
//		NSLog(@"Started HTTP Server on port %hu", [httpServer listeningPort]);
//	}
//	else {
//		NSLog(@"Error starting HTTP Server: %@", error);
//	}
//    MPMoviePlayerViewController *MPC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:@"http://127.0.0.1:12580/984192/playlist.m3u8"]];
////    MPMoviePlayerViewController *MPC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:@"http://meta.video.qiyi.com/181/ef9f0d6a246b6c2bd6e2b40bd9076eec.m3u8"]];
//    
//    MPMoviePlayerController *moviePlayer = MPC.moviePlayer;
//    moviePlayer.repeatMode = MPMovieRepeatModeNone;
//    moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
//    
//    [self presentMoviePlayerViewControllerAnimated:MPC];
}

//- (NSString *)getVideoAddress
//{
//    NSString *videoAddress = nil;
//    NSArray *videoUrlArray = [[episodeArray objectAtIndex:0] objectForKey:@"down_urls"];
//    if(videoUrlArray.count > 0){
//        for(NSDictionary *tempVideo in videoUrlArray){
//            if([LETV isEqualToString:[tempVideo objectForKey:@"source"]]){
//                videoAddress = [self parseVideoUrl:tempVideo];
//                break;
//            }
//        }
//        if(videoAddress == nil){
//            videoAddress = [self parseVideoUrl:[videoUrlArray objectAtIndex:0]];
//        }
//    }
//    return videoAddress;
//}

- (void)dingBtnClicked:(id)sender
{
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([hostReach currentReachabilityStatus] == NotReachable) {
        [UIUtility showNetWorkError:self.view];
        return;
    }
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: self.prodId, @"prod_id", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathSupport parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if([responseCode isEqualToString:kSuccessResCode]){
            [[NSNotificationCenter defaultCenter] postNotificationName:PERSONAL_VIEW_REFRESH object:nil];
            [[AppDelegate instance].rootViewController showSuccessModalView:1.5];
            self.dingNumberLabel.text = [NSString stringWithFormat:@"%i", [self.dingNumberLabel.text intValue] + 1 ];
        } else {
            [[AppDelegate instance].rootViewController showModalView:[UIImage imageNamed:@"pushed"] closeTime:1.5];
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        [UIUtility showSystemError:self.view];
    }];
}

- (void)collectionBtnClicked
{
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([hostReach currentReachabilityStatus] == NotReachable) {
        [UIUtility showNetWorkError:self.view];
        return;
    }
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: self.prodId, @"prod_id", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathProgramFavority parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if([responseCode isEqualToString:kSuccessResCode]){
            [[NSNotificationCenter defaultCenter] postNotificationName:PERSONAL_VIEW_REFRESH object:nil];
            [[AppDelegate instance].rootViewController showSuccessModalView:1.5];
            self.collectionNumberLabel.text = [NSString stringWithFormat:@"%i", [self.collectionNumberLabel.text intValue] + 1 ];
        } else {
            [[AppDelegate instance].rootViewController showModalView:[UIImage imageNamed:@"collected"] closeTime:1.5];
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        [UIUtility showSystemError:self.view];
    }];
}


- (void)introBtnClicked
{
    introExpand = !introExpand;
    if(introContentHeight > 100){
        if(introExpand){
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
                [self.introContentTextView setFrame:CGRectMake(self.introContentTextView.frame.origin.x, self.introContentTextView.frame.origin.y, self.introContentTextView.frame.size.width, introContentHeight)];
                self.introBgImage.frame = CGRectMake(LEFT_WIDTH, self.introBgImage.frame.origin.y, self.introBgImage.frame.size.width, introContentHeight);
                [introBtn setBackgroundImage:[UIImage imageNamed:@"more_off"] forState:UIControlStateNormal];
                introBtn.frame = CGRectMake(introBtn.frame.origin.x, self.introContentTextView.frame.origin.y + 90 + introContentHeight - 100, introBtn.frame.size.width, introBtn.frame.size.height);
                [self repositElements:introContentHeight - 100];
            } completion:^(BOOL finished) {
            }];
        } else {
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
                [self.introContentTextView setFrame:CGRectMake(self.introContentTextView.frame.origin.x, self.introContentTextView.frame.origin.y, self.introContentTextView.frame.size.width, 100)];
                self.introBgImage.frame = CGRectMake(LEFT_WIDTH, self.introBgImage.frame.origin.y, self.introBgImage.frame.size.width, 100);
                [introBtn setBackgroundImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
                introBtn.frame = CGRectMake(introBtn.frame.origin.x, self.introContentTextView.frame.origin.y + 90, introBtn.frame.size.width, introBtn.frame.size.height);
                [self repositElements:0];
            } completion:^(BOOL finished) {
            }];
        }
    } else {
        [introBtn removeFromSuperview];
        introBtn = nil;
        //        if(introExpand){
        //            [introBtn setBackgroundImage:[UIImage imageNamed:@"more_off"] forState:UIControlStateNormal];
        //        } else {
        //            [introBtn setBackgroundImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
        //        }
    }
    
}

- (void)downloadBtnClicked
{
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([hostReach currentReachabilityStatus] == NotReachable) {
        [UIUtility showNetWorkError:self.view];
        return;
    }
    [self.downloadBtn setEnabled:NO];
    [self.downloadBtn setBackgroundImage:[UIImage imageNamed:@"downloading"] forState:UIControlStateDisabled];

    NSString *query = [NSString stringWithFormat:@"WHERE item_id = '%@'", self.prodId];
    DownloadItem *item = (DownloadItem *)[DownloadItem findFirstByCriteria:query];
    if (item != nil) {
        return;
    }
    
    item = [[DownloadItem alloc]init];
    item.itemId = self.prodId;
    item.imageUrl = [video objectForKey:@"ipad_poster"];
    if([StringUtility stringIsEmpty:item.imageUrl]){
        item.imageUrl = [video objectForKey:@"poster"];
    }
    item.name = [video objectForKey:@"name"];
    item.percentage = 0;
    item.type = 1;
    item.downloadStatus = @"waiting";
    if (self.mp4DownloadUrls.count > 0) {
        item.downloadType = @"mp4";
        item.fileName = [NSString stringWithFormat:@"%@%@", self.prodId, @".mp4"];
    } else if(self.m3u8DownloadUrls.count > 0){
        item.downloadType = @"m3u8";
    }
    NSMutableArray *tempArray = [[NSMutableArray alloc]initWithCapacity:5];
    [tempArray addObjectsFromArray:self.mp4DownloadUrls];
    [tempArray addObjectsFromArray:self.m3u8DownloadUrls];
    item.urlArray = tempArray;
    [item save];
    
    DownloadUrlFinder *finder = [[DownloadUrlFinder alloc]init];
    finder.item = item;
    finder.mp4DownloadUrlNum = self.mp4DownloadUrls;
    [finder setupWorkingUrl];
    
    [self updateBadgeIcon];
    [UIUtility showDownloadSuccess:self.view];
}


@end
