//
//  MovieDetailViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-20.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "MovieDetailViewController.h"
#import "CommonHeader.h"
#import "MediaPlayerViewController.h"
#import "ProgramViewController.h"
#import "SinaWeibo.h"
#import "SublistViewController.h"
#import "SelectListViewController.h"
#import "CommentListViewController.h"

#define LEFT_GAP 50

@interface MovieDetailViewController (){
    NSMutableArray *commentArray;
    NSArray *episodeArray;
    SublistViewController *topicListViewController;
    NSArray *topics;
    CommentListViewController *commentListViewController;
}

@end

@implementation MovieDetailViewController


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
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
    self.bgScrollView.frame = CGRectMake(0, 260, self.view.frame.size.width, self.view.frame.size.height);
    [self.bgScrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height*1.5)];
    
    self.playBtn.frame = CGRectMake(290, 115, 185, 40);
    [self.playBtn setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [self.playBtn setBackgroundImage:[UIImage imageNamed:@"play_pressed"] forState:UIControlStateHighlighted];
    
    self.closeBtn.frame = CGRectMake(470, 20, 40, 42);
    [self.closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [self.closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
    [self.closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.placeholderImage.frame = CGRectMake(LEFT_GAP, 78, 217, 312);
    self.placeholderImage.image = [UIImage imageNamed:@"movie_frame"];
    
    self.filmImage.frame = CGRectMake(LEFT_GAP+6, 84, 203, 298);
    
    self.playRoundBtn.frame = CGRectMake(0, 0, 63, 63);
    [self.playRoundBtn setBackgroundImage:[UIImage imageNamed:@"play_btn"] forState:UIControlStateNormal];
    [self.playRoundBtn setBackgroundImage:[UIImage imageNamed:@"play_btn_pressed"] forState:UIControlStateHighlighted];
    [self.playRoundBtn addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
    
    self.playRoundBtn.center = self.filmImage.center;
    
    self.titleImage.frame = CGRectMake(LEFT_GAP, 35, 62, 26);
    self.titleImage.image = [UIImage imageNamed:@"detail_title"];
    
    self.titleLabel.frame = CGRectMake(290, 85, 180, 20);
    
    self.scoreLabel.frame = CGRectMake(290, 110, 50, 20);
    self.doulanLogo.frame = CGRectMake(335, 113, 15, 15);
    self.doulanLogo.image = [UIImage imageNamed:@"douban"];
    
    self.playBtn.frame = CGRectMake(290, 150, 185, 40);
    [self.playBtn setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [self.playBtn setBackgroundImage:[UIImage imageNamed:@"play_pressed"] forState:UIControlStateHighlighted];
    [self.playBtn addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
    
    self.directorLabel.frame = CGRectMake(290, 205, 50, 15);
    self.directorNameLabel.frame = CGRectMake(335, 205, 140, 15);
    self.actorLabel.frame = CGRectMake(290, 230, 50, 15);
    self.actorName1Label.frame = CGRectMake(335, 230, 140, 15);
    self.actorName2Label.frame = CGRectMake(335, 255, 140, 15);
    self.actorName3Label.frame = CGRectMake(335, 280, 140, 15);
    
    self.playLabel.frame = CGRectMake(290, 305, 50, 15);
    self.playTimeLabel.frame = CGRectMake(335, 305, 100, 15);
    self.regionLabel.frame = CGRectMake(290, 333, 50, 15);
    self.regionNameLabel.frame = CGRectMake(335, 333, 100, 15);
    
    
    self.dingNumberImage.frame = CGRectMake(290, 360, 75, 24);
    self.dingNumberImage.image = [UIImage imageNamed:@"pushinguser"];
    self.dingNumberLabel.frame = CGRectMake(295, 360, 40, 24);
    
    self.collectioNumber.frame = CGRectMake(390, 360, 84, 24);
    self.collectioNumber.image = [UIImage imageNamed:@"collectinguser"];
    self.collectionNumberLabel.frame = CGRectMake(395, 360, 40, 24);
    
    self.dingBtn.frame = CGRectMake(LEFT_GAP, 405, 55, 34);
    [self.dingBtn setBackgroundImage:[UIImage imageNamed:@"push"] forState:UIControlStateNormal];
    [self.dingBtn setBackgroundImage:[UIImage imageNamed:@"push_pressed"] forState:UIControlStateHighlighted];
    [self.dingBtn addTarget:self action:@selector(dingBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.collectionBtn.frame = CGRectMake(115, 405, 74, 34);
    [self.collectionBtn setBackgroundImage:[UIImage imageNamed:@"collection"] forState:UIControlStateNormal];
    [self.collectionBtn setBackgroundImage:[UIImage imageNamed:@"collection_pressed"] forState:UIControlStateHighlighted];
    [self.collectionBtn addTarget:self action:@selector(collectionBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.shareBtn.frame = CGRectMake(195, 405, 74, 34);
    [self.shareBtn setBackgroundImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [self.shareBtn setBackgroundImage:[UIImage imageNamed:@"share_pressed"] forState:UIControlStateHighlighted];
    [self.shareBtn addTarget:self action:@selector(shareBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.addListBtn.frame = CGRectMake(290, 405, 104, 34);
    [self.addListBtn setBackgroundImage:[UIImage imageNamed:@"listing"] forState:UIControlStateNormal];
    [self.addListBtn setBackgroundImage:[UIImage imageNamed:@"listing_pressed"] forState:UIControlStateHighlighted];
    [self.addListBtn addTarget:self action:@selector(addListBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.lineImage.frame = CGRectMake(LEFT_GAP, 450, 430, 2);
    self.lineImage.image = [UIImage imageNamed:@"dividing"];
    
    self.introImage.frame = CGRectMake(LEFT_GAP, 460, 45, 20);
    self.introImage.image = [UIImage imageNamed:@"brief_title"];
    
    self.introBgImage.frame = CGRectMake(LEFT_GAP, 490, 440, 86);
    self.introBgImage.image = [UIImage imageNamed:@"brief"];
    
    self.introContentTextView.frame = CGRectMake(LEFT_GAP + 10, 493, 400, 80);
    
    commentArray = [[NSMutableArray alloc]initWithCapacity:10];
}

- (void)viewWillAppear:(BOOL)animated
{
    if(video == nil){
        [self retrieveData];
    }
}

- (void)retrieveData
{
    NSString *key = [NSString stringWithFormat:@"%@%@", @"movie", self.prodId];
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:key];
    if(cacheResult != nil){
        [self parseData:cacheResult];
    }
    if([[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: self.prodId, @"prod_id", nil];
        [[AFServiceAPIClient sharedClient] getPath:kPathProgramView parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [self parseData:result];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_MB_PROGRESS_BAR object:self userInfo:nil];
            [UIUtility showSystemError:self.view];
        }];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_MB_PROGRESS_BAR object:self userInfo:nil];
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
        topics = [video objectForKey:@"topics"];
        NSArray *tempArray = (NSMutableArray *)[result objectForKey:@"comments"];
        [commentArray removeAllObjects];
        if(tempArray != nil && tempArray.count > 0){
            [commentArray addObjectsFromArray:tempArray];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_MB_PROGRESS_BAR object:self userInfo:nil];
        [self showValues];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_MB_PROGRESS_BAR object:self userInfo:nil];
        [UIUtility showSystemError:self.view];
    }
}

- (void)showValues
{
    [self.filmImage setImageWithURL:[NSURL URLWithString:[video objectForKey:@"poster"]] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
    
    self.titleLabel.text = [video objectForKey:@"name"];
    self.scoreLabel.text = [NSString stringWithFormat:@"%@ 分", [video objectForKey:@"score"]];
    self.directorNameLabel.text = [video objectForKey:@"directors"];
    
    NSString *stars = [video objectForKey:@"stars"];
    NSArray *starArray;
    if([stars rangeOfString:@"/"].length > 0){
        starArray = [stars componentsSeparatedByString:@"/"];
    } else if([stars rangeOfString:@","].length > 0){
        starArray = [stars componentsSeparatedByString:@","];
    } else {
        starArray = [stars componentsSeparatedByString:@" "];
    }
    if(starArray.count > 0)
        self.actorName1Label.text = [((NSString *)[starArray objectAtIndex:0]) stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(starArray.count > 1)
        self.actorName2Label.text = [((NSString *)[starArray objectAtIndex:1]) stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(starArray.count > 2)
        self.actorName3Label.text = [((NSString *)[starArray objectAtIndex:2]) stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    self.regionNameLabel.text = [video objectForKey:@"area"];
    self.playTimeLabel.text = [video objectForKey:@"publish_date"];
    self.dingNumberLabel.text = [NSString stringWithFormat:@"%@", [video objectForKey:@"support_num"]];
    self.collectionNumberLabel.text = [NSString stringWithFormat:@"%@", [video objectForKey:@"favority_num"]];
    
    self.introContentTextView.text = [video objectForKey:@"summary"];
    
    int positionY = 585;
    if(topics.count > 0){
        self.relatedImage.frame = CGRectMake(LEFT_GAP, 585, 80, 20);
        self.relatedImage.image = [UIImage imageNamed:@"morelists_title"];
        //        self.relatedBgImage.frame = CGRectMake(LEFT_GAP, 620, 440, 86);
        //        self.relatedBgImage.image = [UIImage imageNamed:@"morelists"];
        
        topicListViewController = [[SublistViewController alloc]initWithStyle:UITableViewStylePlain];
        topicListViewController.view.frame = CGRectMake(LEFT_GAP, 590, 425, 200);
        topicListViewController.listData = topics;
        [topicListViewController.tableView reloadData];
        [self.bgScrollView addSubview:topicListViewController.view];
        
        positionY = topicListViewController.view.frame.origin.y + (topics.count > 5 ? 5 : topics.count)*30;
    }
    
    int totalCommentNum = [[video objectForKey:@"total_comment_number"] integerValue];
    self.commentImage.frame = CGRectMake(LEFT_GAP, positionY + 20, 74, 19);
    self.commentImage.image = [UIImage imageNamed:@"comment_title"];
    
    self.numberLabel.frame = CGRectMake(139, positionY + 20, 100, 18);
    self.numberLabel.text = [NSString stringWithFormat:@"(%i条)", totalCommentNum];
    
    self.commentBtn.frame = CGRectMake(410, positionY + 17, 66, 26);
    [self.commentBtn setBackgroundImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];
    [self.commentBtn setBackgroundImage:[UIImage imageNamed:@"comment_pressed"] forState:UIControlStateHighlighted];
    [self.commentBtn addTarget:self action:@selector(commentBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    if(commentListViewController == nil){
        commentListViewController = [[CommentListViewController alloc]initWithStyle:UITableViewStylePlain];
        commentListViewController.view.frame = CGRectMake(LEFT_GAP, positionY + 60, 425, 200);
        commentListViewController.totalCommentNum = totalCommentNum;
        commentListViewController.parentDelegate = self;
        commentListViewController.prodId = self.prodId;
        [self.bgScrollView addSubview:commentListViewController.view];
    }
    commentListViewController.listData = commentArray;
    [commentListViewController.tableView reloadData];
    
    [self.bgScrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+commentListViewController.tableHeight+200)];
    commentListViewController.view.frame = CGRectMake(LEFT_GAP, commentListViewController.view.frame.origin.y, 425, commentListViewController.tableHeight);
}

- (void)getTopComments:(int)num
{
    [self retrieveData];
}

- (void)refreshCommentListView:(int)tableHeight
{
    [self.bgScrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+tableHeight+200)];
    commentListViewController.view.frame = CGRectMake(LEFT_GAP, commentListViewController.view.frame.origin.y, 425, tableHeight);
}

- (void)playVideo
{
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [UIUtility showNetWorkError:self.view];
        return;
    }
    [self playVideo:1];
}

- (void)playVideo:(NSInteger)num
{
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isWifiReachable)]){
        BlockAlertView *alert = [BlockAlertView alertWithTitle:@"" message:@"播放视频会消耗大量流量，您确定要在非WiFi环境下播放吗？"];
        [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel", nil) block:nil];
        [alert setDestructiveButtonWithTitle:@"确定" block:^{
            [self willPlayVideo:num];
        }];
        [alert show];
    } else {
        [self willPlayVideo:num];
    }
}

- (void)willPlayVideo:(NSInteger)num
{
    NSArray *videoUrlArray = [[episodeArray objectAtIndex:num-1] objectForKey:@"down_urls"];
    if(videoUrlArray.count > 0){
        NSString *videoUrl = nil;
        for(NSDictionary *tempVideo in videoUrlArray){
            if([LETV isEqualToString:[tempVideo objectForKey:@"source"]]){
                videoUrl = [self parseVideoUrl:tempVideo];
                break;
            }
        }
        if(videoUrl == nil){
            videoUrl = [self parseVideoUrl:[videoUrlArray objectAtIndex:0]];
        }
        if(videoUrl == nil){
            [self showPlayWebPage];
        } else {
            MediaPlayerViewController *viewController = [[MediaPlayerViewController alloc]initWithNibName:@"MediaPlayerViewController" bundle:nil];
            viewController.videoUrl = videoUrl;
            viewController.type = 1;
            viewController.name = [video objectForKey:@"name"];
            viewController.subname = [NSString stringWithFormat:@"%i", num];
            [self presentModalViewController:viewController animated:YES];
        }
    }else {
        [self showPlayWebPage];
    }
}

- (void)showPlayWebPage
{
    ProgramViewController *viewController = [[ProgramViewController alloc]initWithNibName:@"ProgramViewController" bundle:nil];
    NSArray *urlArray = [video objectForKey:@"video_urls"];
    viewController.programUrl = [[urlArray objectAtIndex:0] objectForKey:@"url"];
    viewController.title = [video objectForKey:@"name"];
    viewController.type = 1;
    viewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:NO];
}


- (void)dingBtnClicked:(id)sender
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: self.prodId, @"prod_id", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathSupport parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if([responseCode isEqualToString:kSuccessResCode]){
            [[AppDelegate instance].rootViewController showSuccessModalView:1.5];
            self.dingNumberLabel.text = [NSString stringWithFormat:@"%i", [self.dingNumberLabel.text intValue] + 1 ];
        } else {
            [[AppDelegate instance].rootViewController showFailureModalView:1.5];
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        [UIUtility showSystemError:self.view];
    }];
}

- (void)collectionBtnClicked
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: self.prodId, @"prod_id", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathProgramFavority parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if([responseCode isEqualToString:kSuccessResCode]){
            [[AppDelegate instance].rootViewController showSuccessModalView:1.5];
            self.collectionNumberLabel.text = [NSString stringWithFormat:@"%i", [self.collectionNumberLabel.text intValue] + 1 ];
        } else {
            [[AppDelegate instance].rootViewController showFailureModalView:1.5];
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        [UIUtility showSystemError:self.view];
    }];
}
@end
