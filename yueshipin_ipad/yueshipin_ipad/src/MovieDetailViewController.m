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
#import <Parse/Parse.h>

#define DEFAULT_POSOTION_Y 540

@interface MovieDetailViewController ()
{
    NSMutableArray *commentArray;
    SublistViewController *topicListViewController;
    CommentListViewController *commentListViewController;
    UIButton *introBtn;
    float introContentHeight;
    BOOL introExpand;
    UITapGestureRecognizer *tapGesture;
}

- (void)SubscribingToChannels;

@end

@implementation MovieDetailViewController
@synthesize expectbtn;

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
    [self setIntroImage:nil];
    [self setIntroContentTextView:nil];
    [self setRelatedImage:nil];
    [self setCommentImage:nil];
    [self setDingNumberLabel:nil];
    [self setCollectionNumberLabel:nil];
    [self setCloseBtn:nil];
    [self setReportLabel:nil];
    [self setShareLabel:nil];
    [self setScoreLable:nil];
    self.expectbtn = nil;
    [super viewDidUnload];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.type = 1;
    umengPageName = MOVIE_DETAIL;
    
    self.bgScrollView.frame = CGRectMake(0, 228, self.view.frame.size.width, self.view.frame.size.height - 270);
    [self.bgScrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    
    self.closeBtn.frame = CGRectMake(455, 0, 50, 50);
    [self.closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [self.closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
    [self.closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.placeholderImage.frame = CGRectMake(LEFT_WIDTH, 78, 219, 312);
    self.placeholderImage.image = [UIImage imageNamed:@"movie_frame"];
    
    self.filmImage.frame = CGRectMake(self.placeholderImage.frame.origin.x + 6, self.placeholderImage.frame.origin.y + 8, self.placeholderImage.frame.size.width - 12, self.placeholderImage.frame.size.height - 8);
    
    self.titleLabel.frame = CGRectMake(268, 85, 200, 20);
    self.titleLabel.font = CMConstants.titleFont;
    
    self.scoreLable.frame = CGRectMake(270, 120, 50, 20);
    self.scoreLable.textColor = CMConstants.grayColor;
    self.scoreLabel.frame = CGRectMake(315, 120, 50, 20);
    self.doulanLogo.frame = CGRectMake(365, 123, 15, 15);
    self.doulanLogo.image = [UIImage imageNamed:@"douban"];
    
    self.directorLabel.frame = CGRectMake(270, 150, 50, 15);
    self.directorLabel.textColor = CMConstants.grayColor;
    self.directorNameLabel.frame = CGRectMake(315, 150, 150, 15);
    self.directorNameLabel.textColor = CMConstants.grayColor;
    self.actorLabel.frame = CGRectMake(270, 180, 50, 15);
    self.actorLabel.textColor = CMConstants.grayColor;
    self.actorName1Label.frame = CGRectMake(315, 180, 150, 15);
    self.actorName1Label.textColor = CMConstants.grayColor;
    
    self.playLabel.frame = CGRectMake(270, 210, 50, 15);
    self.playLabel.textColor = CMConstants.grayColor;
    self.playTimeLabel.frame = CGRectMake(315, 210, 100, 15);
    self.playTimeLabel.textColor = CMConstants.grayColor;
    self.regionLabel.frame = CGRectMake(270, 240, 50, 15);
    self.regionLabel.textColor = CMConstants.grayColor;
    self.regionNameLabel.frame = CGRectMake(315, 240, 100, 15);
    self.regionNameLabel.textColor = CMConstants.grayColor;
    
    self.playBtn.frame = CGRectMake(260, 280, 100, 50);
    [self.playBtn setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [self.playBtn setBackgroundImage:[UIImage imageNamed:@"play_disabled"] forState:UIControlStateDisabled];
    [self.playBtn setBackgroundImage:[UIImage imageNamed:@"play_pressed"] forState:UIControlStateHighlighted];
    [self.playBtn addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
    
    self.expectbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.expectbtn.frame = CGRectMake(260, 280, 100, 50);
    [self.expectbtn setBackgroundImage:[UIImage imageNamed:@"xiangkan_bg.png"] forState:UIControlStateNormal];
    [self.expectbtn setBackgroundImage:[UIImage imageNamed:@"xiangkan_bg.png"] forState:UIControlStateHighlighted];
    [self.expectbtn setImage:[UIImage imageNamed:@"xiangkan"] forState:UIControlStateNormal];
    [self.expectbtn setImage:[UIImage imageNamed:@"xiangkan_pressed"] forState:UIControlStateHighlighted];
    [self.expectbtn setImageEdgeInsets:UIEdgeInsetsMake(17, 10, 17, 35)];
    [self.expectbtn setTitleEdgeInsets:UIEdgeInsetsMake(4, 10, 0, 5)];
    self.expectbtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.expectbtn setTitleColor:[UIColor colorWithRed:120.0/255.0 green:120.0/255.0 blue:120.0/255.0 alpha:1] forState:UIControlStateHighlighted];
    [self.expectbtn setTitleColor:[UIColor colorWithRed:1 green:119.0f/255.0f blue:0 alpha:1] forState:UIControlStateNormal];
    [self.expectbtn addTarget:self action:@selector(expectVideo) forControlEvents:UIControlEventTouchUpInside];
    [self.bgScrollView addSubview:self.expectbtn];
    self.expectbtn.hidden = YES;
    
    self.downloadBtn.frame = CGRectMake(384, 280, 100, 50);
    [self.downloadBtn setBackgroundImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
    [self.downloadBtn setBackgroundImage:[UIImage imageNamed:@"download_pressed"] forState:UIControlStateHighlighted];
    [self.downloadBtn addTarget:self action:@selector(downloadBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.addListBtn.frame = CGRectMake(260, 340, 44, 44);
    [self.addListBtn setBackgroundImage:[UIImage imageNamed:@"report_ipad"] forState:UIControlStateNormal];
    [self.addListBtn setBackgroundImage:[UIImage imageNamed:@"report_ipad_pressed"] forState:UIControlStateHighlighted];
    [self.addListBtn addTarget:self action:@selector(reportBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.dingBtn.frame = CGRectMake(260 + 60, 340, 44, 44);
    [self.dingBtn setBackgroundImage:[UIImage imageNamed:@"push"] forState:UIControlStateNormal];
    [self.dingBtn setBackgroundImage:[UIImage imageNamed:@"push_pressed"] forState:UIControlStateHighlighted];
    [self.dingBtn addTarget:self action:@selector(dingBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.collectionBtn.frame = CGRectMake(260 + 120, 340, 44, 44);
    [self.collectionBtn setBackgroundImage:[UIImage imageNamed:@"collection"] forState:UIControlStateNormal];
    [self.collectionBtn setBackgroundImage:[UIImage imageNamed:@"collection_pressed"] forState:UIControlStateHighlighted];
    [self.collectionBtn addTarget:self action:@selector(collectionBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.shareBtn.frame = CGRectMake(260 + 180, 340, 44, 44);
    [self.shareBtn setBackgroundImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [self.shareBtn setBackgroundImage:[UIImage imageNamed:@"share_pressed"] forState:UIControlStateHighlighted];
    [self.shareBtn addTarget:self action:@selector(shareBtnClicked) forControlEvents:UIControlEventTouchUpInside];

    self.reportLabel.frame = CGRectMake(260, 365, 40, 20);
    self.reportLabel.center = CGPointMake(self.addListBtn.center.x, self.reportLabel.center.y);
    self.reportLabel.textColor = CMConstants.grayColor;
    
    self.dingNumberLabel.frame = CGRectMake(260, 365, 60, 20);
    self.dingNumberLabel.center = CGPointMake(self.dingBtn.center.x, self.reportLabel.center.y);
    self.dingNumberLabel.textColor = CMConstants.grayColor;
    
    self.collectionNumberLabel.frame = CGRectMake(260, 365, 60, 20);
    self.collectionNumberLabel.center = CGPointMake(self.collectionBtn.center.x, self.reportLabel.center.y);
    self.collectionNumberLabel.textColor = CMConstants.grayColor;
    
    self.shareLabel.frame = CGRectMake(260, 365, 40, 20);
    self.shareLabel.center = CGPointMake(self.shareBtn.center.x, self.reportLabel.center.y);
    self.shareLabel.textColor = CMConstants.grayColor;
    
    self.introImage.frame = CGRectMake(LEFT_WIDTH, 410, 45, 20);
    self.introImage.image = [UIImage imageNamed:@"brief_title"];

    self.introContentTextView.frame = CGRectMake(LEFT_WIDTH, 440, 430, 100);
    self.introContentTextView.textColor = CMConstants.grayColor;
    self.introContentTextView.layer.borderWidth = 1;
    self.introContentTextView.layer.borderColor = [UIColor colorWithRed:213/255.0 green:213/255.0 blue:213/255.0 alpha:1].CGColor;
    tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(introBtnClicked)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self.introContentTextView addGestureRecognizer:tapGesture];
    
    introBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [introBtn setBackgroundImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    introBtn.frame = CGRectMake(LEFT_WIDTH + 415, self.introContentTextView.frame.origin.y + 90, 14, 9);
    [introBtn addTarget:self action:@selector(introBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.bgScrollView addSubview:introBtn];
    
    commentArray = [[NSMutableArray alloc]initWithCapacity:10];
    [self.commentImage setHidden:YES];
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
    [[AppDelegate instance].rootViewController showIntroModalView:SHOW_PLAY_INTRO_WITH_DOWNLOAD introImage:[UIImage imageNamed:@"play_intro_with_download"]];
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
        [super checkCanPlayVideo];
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
    [self.filmImage setImageWithURL:[NSURL URLWithString:url]];
    
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
    int dingNum = [[video objectForKey:@"support_num"] intValue];
    if (dingNum >= 1000) {
        self.dingNumberLabel.text = [NSString stringWithFormat:@"顶(%.1fK)", dingNum/1000.0];
    } else {
        self.dingNumberLabel.text = [NSString stringWithFormat:@"顶(%i)", dingNum];
    }
    int collectioNum = [[video objectForKey:@"favority_num"] intValue];
    if (collectioNum >= 1000) {
        self.collectionNumberLabel.text = [NSString stringWithFormat:@"收藏(%.1fK)", collectioNum/1000.0];
        [self.expectbtn setTitle:[NSString stringWithFormat:@"(%.1fK)", collectioNum/1000.0] forState:UIControlStateNormal];
    } else {
        [self.expectbtn setTitle:[NSString stringWithFormat:@"(%i)", collectioNum] forState:UIControlStateNormal];
        self.collectionNumberLabel.text = [NSString stringWithFormat:@"收藏(%i)", collectioNum];
    }
    
    self.introContentTextView.text = [video objectForKey:@"summary"];
    
    if (self.canPlayVideo) {
        self.playBtn.hidden = NO;
        self.expectbtn.hidden = YES;
        if(self.mp4DownloadUrls.count > 0 || self.m3u8DownloadUrls.count > 0){
            // do nothing
            //        NSLog(@"mp4 count: %i", self.mp4DownloadUrls.count);
            //        NSLog(@"m3u8 count: %i", self.m3u8DownloadUrls.count);
        } else {
            [self.downloadBtn setEnabled:NO];
            [self.downloadBtn setBackgroundImage:[UIImage imageNamed:@"no_download"] forState:UIControlStateDisabled];
        }
    } else {
        
        self.playBtn.hidden = YES;
        self.expectbtn.hidden = NO;
        
        //[self.playBtn setEnabled:NO];
        [self.downloadBtn setEnabled:NO];
        [self.downloadBtn setBackgroundImage:[UIImage imageNamed:@"no_download"] forState:UIControlStateDisabled];
    }
    
    [self checkIfDownloading];
    [self repositElements:0];
}

- (void)checkIfDownloading
{
    NSString *query = [NSString stringWithFormat:@"WHERE itemId = '%@'", self.prodId];
    DownloadItem *downloadingItem = (DownloadItem *) [DatabaseManager findFirstByCriteria:DownloadItem.class queryString:query];
    if(downloadingItem != nil){
        [self.downloadBtn setEnabled:NO];
        if(downloadingItem.percentage == 100){
            [self.downloadBtn setBackgroundImage:[UIImage imageNamed:@"download_finished"] forState:UIControlStateDisabled];
        } else {
            [self.downloadBtn setBackgroundImage:[UIImage imageNamed:@"download_pressed"] forState:UIControlStateDisabled];
        }
    }
}

- (void)repositElements:(int)increasePositionY
{
    int positionY = DEFAULT_POSOTION_Y + increasePositionY + 20;
    if(topics.count > 0){
        self.relatedImage.frame = CGRectMake(LEFT_WIDTH, positionY, 71, 18);
        self.relatedImage.image = [UIImage imageNamed:@"morelists_title"];
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
    
    self.commentImage.frame = CGRectMake(LEFT_WIDTH, positionY + 20, 41, 18);
    self.commentImage.image = [UIImage imageNamed:@"comment_title"];
    
    if(commentListViewController == nil){
        commentListViewController = [[CommentListViewController alloc]initWithStyle:UITableViewStylePlain];
        commentListViewController.prodId = self.prodId;
        commentListViewController.parentDelegate = self;
        [commentListViewController.view setHidden:YES];
        commentListViewController.videoName = [video objectForKey:@"name"];
        commentListViewController.doubanId = [NSString stringWithFormat:@"%@", [video objectForKey:@"douban_id"]];
        [self.bgScrollView addSubview:commentListViewController.view];
    }
    [commentListViewController.tableView reloadData];
    commentListViewController.view.frame = CGRectMake(LEFT_WIDTH, positionY + 50, 430, commentListViewController.tableHeight);
    
    [self.bgScrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+ (topics.count > 5 ? 5 : topics.count)*30+commentListViewController.tableHeight + increasePositionY)];
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
    [self.bgScrollView setContentSize:CGSizeMake(self.view.frame.size.width, commentListViewController.view.frame.origin.y+tableHeight)];
    commentListViewController.view.frame = CGRectMake(LEFT_WIDTH, commentListViewController.view.frame.origin.y, 430, tableHeight);
    if (tableHeight > 30) {
        [self.commentImage setHidden:NO];
        [commentListViewController.view setHidden:NO];
    }
}

- (void)expectVideo
{
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([hostReach currentReachabilityStatus] == NotReachable) {
        [UIUtility showNetWorkError:self.view];
        return;
    }
    
    [self SubscribingToChannels];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: self.prodId, @"prod_id", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathProgramFavority parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if([responseCode isEqualToString:kSuccessResCode]){
            [[NSNotificationCenter defaultCenter] postNotificationName:SEARCH_LIST_VIEW_REFRESH object:nil];
            [[AppDelegate instance].rootViewController showSuccessModalView:1.5];
            int collectioNum = [[video objectForKey:@"favority_num"] intValue] + 1;
            if (collectioNum >= 1000) {
                self.collectionNumberLabel.text = [NSString stringWithFormat:@"收藏(%.1fK)", collectioNum/1000.0];
                [self.expectbtn setTitle:[NSString stringWithFormat:@"(%.1fK)", collectioNum/1000.0] forState:UIControlStateNormal];
            } else {
                [self.expectbtn setTitle:[NSString stringWithFormat:@"(%i)", collectioNum] forState:UIControlStateNormal];
                self.collectionNumberLabel.text = [NSString stringWithFormat:@"收藏(%i)", collectioNum];
            }
        } else {
            [[AppDelegate instance].rootViewController showModalView:[UIImage imageNamed:@"expect_succeed"] closeTime:1.5];
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        [UIUtility showSystemError:self.view];
    }];
}

- (void)playVideo
{
    self.subname = @"";
    [super playVideo:0];
}

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
            [[NSNotificationCenter defaultCenter] postNotificationName:SEARCH_LIST_VIEW_REFRESH object:nil];
//            [[NSNotificationCenter defaultCenter] postNotificationName:PERSONAL_VIEW_REFRESH object:nil];
            [[AppDelegate instance].rootViewController showSuccessModalView:1.5];
            int dingNum = [[video objectForKey:@"support_num"] intValue] + 1;
            if (dingNum >= 1000) {
                self.dingNumberLabel.text = [NSString stringWithFormat:@"顶(%.1fK)", dingNum/1000.0];
            } else {
                self.dingNumberLabel.text = [NSString stringWithFormat:@"顶(%i)", dingNum];
            }
        } else {
            [[AppDelegate instance].rootViewController showModalView:[UIImage imageNamed:@"pushed"] closeTime:1.5];
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        [UIUtility showSystemError:self.view];
    }];
}

- (void)SubscribingToChannels
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    NSArray *channels = [NSArray arrayWithObjects:[NSString stringWithFormat:@"CHANNEL_PROD_%@",self.prodId], nil];
    [currentInstallation addUniqueObjectsFromArray:channels forKey:@"channels"];
    
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if (succeeded)
        {
            NSLog(@"Successfully subscribed to channel!");
        }
        else
        {
            NSLog(@"Failed to subscribe to broadcast channel; Error: %@",error);
        }
    }];
}

- (void)collectionBtnClicked
{
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([hostReach currentReachabilityStatus] == NotReachable) {
        [UIUtility showNetWorkError:self.view];
        return;
    }
    
    [self SubscribingToChannels];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: self.prodId, @"prod_id", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathProgramFavority parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if([responseCode isEqualToString:kSuccessResCode]){
            [[NSNotificationCenter defaultCenter] postNotificationName:SEARCH_LIST_VIEW_REFRESH object:nil];
            [[AppDelegate instance].rootViewController showSuccessModalView:1.5];
            int collectioNum = [[video objectForKey:@"favority_num"] intValue] + 1;
            if (collectioNum >= 1000) {
                self.collectionNumberLabel.text = [NSString stringWithFormat:@"收藏(%.1fK)", collectioNum/1000.0];
                [self.expectbtn setTitle:[NSString stringWithFormat:@"(%.1fK)", collectioNum/1000.0] forState:UIControlStateNormal];
            } else {
                [self.expectbtn setTitle:[NSString stringWithFormat:@"(%i)", collectioNum] forState:UIControlStateNormal];
                self.collectionNumberLabel.text = [NSString stringWithFormat:@"收藏(%i)", collectioNum];
            }
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
                [introBtn setBackgroundImage:[UIImage imageNamed:@"more_off"] forState:UIControlStateNormal];
                introBtn.frame = CGRectMake(introBtn.frame.origin.x, self.introContentTextView.frame.origin.y + 90 + introContentHeight - 100, introBtn.frame.size.width, introBtn.frame.size.height);
                [self repositElements:introContentHeight - 100];
            } completion:^(BOOL finished) {
            }];
        } else {
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
                [self.introContentTextView setFrame:CGRectMake(self.introContentTextView.frame.origin.x, self.introContentTextView.frame.origin.y, self.introContentTextView.frame.size.width, 100)];
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
    [self.downloadBtn setBackgroundImage:[UIImage imageNamed:@"download_pressed"] forState:UIControlStateDisabled];

    NSString *query = [NSString stringWithFormat:@"WHERE itemId = '%@'", self.prodId];
    DownloadItem *item = (DownloadItem *)[DatabaseManager findFirstByCriteria:DownloadItem.class queryString:query];
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
    [DatabaseManager save:item];
    
    DownloadUrlFinder *finder = [[DownloadUrlFinder alloc]init];
    finder.item = item;
    finder.mp4DownloadUrlNum = self.mp4DownloadUrls;
    [finder setupWorkingUrl];
    
    [self updateBadgeIcon];
    [UIUtility showDownloadSuccess:self.view];
}

//delegate method
- (void)hideCloseBtn
{
    [self.closeBtn setHidden:YES];
}

- (void)showCloseBtn
{
    [self.closeBtn setHidden:NO];
}

@end
