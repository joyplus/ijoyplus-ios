//
//  MovieDetailViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-20.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "DramaDetailViewController.h"
#import "CommonHeader.h"
#import "CommentListViewController.h"
#import "SublistViewController.h"
#import "DownloadUrlFinder.h"
#import <Parse/Parse.h>
#define DEFAULT_POSITION_Y 440
#define EPISODE_NUMBER_IN_ROW 5
#define PAGE_TAB_SCROLL_VIEW_TAG 81253806

@interface DramaDetailViewController (){
    NSMutableArray *commentArray;
    SublistViewController *topicListViewController;
    CommentListViewController *commentListViewController;
    int totalEpisodeNumber;
    UIButton *introBtn;
    float introContentHeight;
    BOOL introExpand;
    UITapGestureRecognizer *tapGesture;
    
    UIScrollView *episodeView;
    int episodePageNumber;
    int increasePositionY;
}

@property (nonatomic, strong) UIScrollView *pageTabScrollView;


@end

@implementation DramaDetailViewController
@synthesize expectbtn;
@synthesize pageTabScrollView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [commentArray removeAllObjects];
    commentArray = nil;
    topicListViewController = nil;
    commentListViewController = nil;
    introBtn = nil;
    tapGesture = nil;
    episodeView = nil;
    [self setBgScrollView:nil];
    [self setPlaceholderImage:nil];
    [self setFilmImage:nil];
    [self setTitleLabel:nil];
    [self setScoreLabel:nil];
    [self setDoulanLogo:nil];
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
    [self setCommentImage:nil];
    [self setDingNumberImage:nil];
    [self setCollectioNumber:nil];
    [self setDingNumberLabel:nil];
    [self setCollectionNumberLabel:nil];
    [self setCloseBtn:nil];
    [self setRelatedImage:nil];
    [self setDownloadBtn:nil];
    [self setScoreLable:nil];
    [self setReportLabel:nil];
    [self setShareLabel:nil];
    [self setEpisodeImage:nil];
    [self setEpisodeViewBg:nil];
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
    
    self.type = 2;
    umengPageName = TV_DETAIL;
    
    self.bgScrollView.frame = CGRectMake(0, 228, self.view.frame.size.width, self.view.frame.size.height - 270);
    [self.bgScrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    
    self.closeBtn.frame = CGRectMake(455, 0, 50, 50);
    [self.closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [self.closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
    [self.closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.placeholderImage.frame = CGRectMake(LEFT_WIDTH, 78, 219, 312);
    self.placeholderImage.image = [UIImage imageNamed:@"movie_frame"];
    
    self.filmImage.frame = CGRectMake(self.placeholderImage.frame.origin.x + 6, self.placeholderImage.frame.origin.y + 8, self.placeholderImage.frame.size.width - 12, self.placeholderImage.frame.size.height - 8);
    
    self.titleLabel.frame = CGRectMake(268, 85, 210, 30);
    self.titleLabel.font = [UIFont boldSystemFontOfSize:22];
    self.titleLabel.textColor = CMConstants.textColor;
    self.scoreLable.frame = CGRectMake(270, 120, 50, 20);
    self.scoreLable.textColor = CMConstants.grayColor;
    self.scoreLabel.frame = CGRectMake(315, 120, 50, 20);
    self.doulanLogo.frame = CGRectMake(365, 123, 15, 15);
    self.doulanLogo.image = [UIImage imageNamed:@"douban"];
    
    self.actorLabel.frame = CGRectMake(270, 150, 50, 15);
    self.actorLabel.textColor = CMConstants.grayColor;
    self.actorName1Label.frame = CGRectMake(315, 150, 140, 15);
    self.actorName1Label.textColor = CMConstants.grayColor;
    self.playLabel.frame = CGRectMake(270, 180, 50, 15);
    self.playLabel.textColor = CMConstants.grayColor;
    self.playTimeLabel.frame = CGRectMake(315, 180, 100, 15);
    self.playTimeLabel.textColor = CMConstants.grayColor;
    self.regionLabel.frame = CGRectMake(270, 210, 50, 15);
    self.regionLabel.textColor = CMConstants.grayColor;
    self.regionNameLabel.frame = CGRectMake(315, 210, 100, 15);
    self.regionNameLabel.textColor = CMConstants.grayColor;
    
    self.playBtn.frame = CGRectMake(265, 280, 100, 50);
    [self.playBtn setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [self.playBtn setBackgroundImage:[UIImage imageNamed:@"play_disabled"] forState:UIControlStateDisabled];
    [self.playBtn setBackgroundImage:[UIImage imageNamed:@"play_pressed"] forState:UIControlStateHighlighted];
    [self.playBtn addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
    
    self.expectbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.expectbtn.frame = CGRectMake(260, 280, 100, 50);
    [self.expectbtn setBackgroundImage:[UIImage imageNamed:@"xiangkan_bg.png"] forState:UIControlStateNormal];
    [self.expectbtn setBackgroundImage:[UIImage imageNamed:@"xiangkan_bg_pressed.png"] forState:UIControlStateHighlighted];
    [self.expectbtn setImage:[UIImage imageNamed:@"xiangkan"] forState:UIControlStateNormal];
    [self.expectbtn setImage:[UIImage imageNamed:@"xiangkan_pressed"] forState:UIControlStateHighlighted];
    [self.expectbtn setImageEdgeInsets:UIEdgeInsetsMake(17, 10, 17, 35)];
    [self.expectbtn setTitleEdgeInsets:UIEdgeInsetsMake(4, 10, 0, 5)];
    self.expectbtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.expectbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.expectbtn setTitleColor:[UIColor colorWithRed:1 green:119.0f/255.0f blue:0 alpha:1] forState:UIControlStateNormal];
    [self.expectbtn addTarget:self action:@selector(expectVideo) forControlEvents:UIControlEventTouchUpInside];
    [self.bgScrollView addSubview:self.expectbtn];
    self.expectbtn.hidden = YES;
    
    self.downloadBtn.frame = CGRectMake(376, 280, 100, 50);
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
    
    self.reportLabel.frame = CGRectMake(270, 365, 40, 20);
    self.reportLabel.center = CGPointMake(self.addListBtn.center.x, self.reportLabel.center.y);
    self.reportLabel.textColor = CMConstants.grayColor;
    
    self.dingNumberLabel.frame = CGRectMake(270, 365, 60, 20);
    self.dingNumberLabel.center = CGPointMake(self.dingBtn.center.x, self.reportLabel.center.y);
    self.dingNumberLabel.textColor = CMConstants.grayColor;
    
    self.collectionNumberLabel.frame = CGRectMake(270, 365, 60, 20);
    self.collectionNumberLabel.center = CGPointMake(self.collectionBtn.center.x, self.reportLabel.center.y);
    self.collectionNumberLabel.textColor = CMConstants.grayColor;
    
    self.shareLabel.frame = CGRectMake(270, 365, 40, 20);
    self.shareLabel.center = CGPointMake(self.shareBtn.center.x, self.reportLabel.center.y);
    self.shareLabel.textColor = CMConstants.grayColor;
    
    self.episodeImage.frame = CGRectZero;
    self.episodeImage.image = [UIImage imageNamed:@"video_title"];
    
    self.episodeViewBg.frame = CGRectZero;
    self.episodeViewBg.image = [UIImage imageNamed:@"episode_view_bg"];
    
    pageTabScrollView = [[UIScrollView alloc]initWithFrame:CGRectZero];
    pageTabScrollView.tag = PAGE_TAB_SCROLL_VIEW_TAG;
    pageTabScrollView.showsHorizontalScrollIndicator = NO;
    pageTabScrollView.backgroundColor = [UIColor clearColor];
    [pageTabScrollView setPagingEnabled:YES];
    [self.bgScrollView addSubview:pageTabScrollView];
    pageTabScrollView.delegate = self;
    pageTabScrollView.backgroundColor = [UIColor clearColor];
    
    episodeView = [[UIScrollView alloc]initWithFrame:CGRectZero];
    episodeView.tag = 323474820;
    //episodeView.scrollEnabled = NO;
    episodeView.showsHorizontalScrollIndicator = NO;
    episodeView.backgroundColor = [UIColor clearColor];
    [episodeView setPagingEnabled:YES];
    [self.bgScrollView addSubview:episodeView];
    episodeView.delegate = self;
    episodeView.backgroundColor = [UIColor clearColor];
    
    self.introContentTextView.frame = CGRectMake(0, 0, 0, 100);
    self.introContentTextView.textColor = CMConstants.grayColor;
    self.introContentTextView.layer.borderWidth = 1;
    self.introContentTextView.layer.borderColor = CMConstants.tableBorderColor.CGColor;
    tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(introBtnClicked)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self.introContentTextView addGestureRecognizer:tapGesture];
    
    commentArray = [[NSMutableArray alloc]initWithCapacity:10];
    
    introBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [introBtn setBackgroundImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    [introBtn addTarget:self action:@selector(introBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.bgScrollView addSubview:introBtn];
    
    [self.commentImage setHidden:YES];
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
                increasePositionY = introContentHeight - 100;
                CGFloat y = self.introContentTextView.frame.origin.y + self.introContentTextView.frame.size.height;
                [self relocateCommentWithOriginY:y];
            } completion:^(BOOL finished) {
            }];
        } else {
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
                [self.introContentTextView setFrame:CGRectMake(self.introContentTextView.frame.origin.x, self.introContentTextView.frame.origin.y, self.introContentTextView.frame.size.width, 100)];
                [introBtn setBackgroundImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
                introBtn.frame = CGRectMake(introBtn.frame.origin.x, self.introContentTextView.frame.origin.y + 90, introBtn.frame.size.width, introBtn.frame.size.height);
                increasePositionY = 0;
                CGFloat y = self.introContentTextView.frame.origin.y + self.introContentTextView.frame.size.height;
                [self relocateCommentWithOriginY:y];
            } completion:^(BOOL finished) {
                
            }];
        }
    } else {
        [introBtn removeFromSuperview];
        introBtn = nil;
    }
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

- (void)changePlayingEpisodeBtn:(int)currentNum
{
    [self clearLastBtnImage];
    [[CacheUtility sharedCache]putInCache:[NSString stringWithFormat:@"drama_epi_%@", self.prodId] result:[NSNumber numberWithInt:currentNum+1]];
    UIButton *btn = (UIButton *)[episodeView viewWithTag:currentNum+1];
    [btn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"drama_watched"] forState:UIControlStateNormal];
}


- (void)playNextEpisode
{
    id lastNumObj = [[CacheUtility sharedCache]loadFromCache:[NSString stringWithFormat:@"drama_epi_%@", self.prodId]];
    int lastNum = -1;
    if(lastNumObj != nil){
        lastNum = [lastNumObj integerValue];
    }
    if (lastNum >= 0 && lastNum+1 <= episodeArray.count) {
        UIButton *currentBtn = (UIButton *)[episodeView viewWithTag:lastNum + 1];
        [self dramaPlay:currentBtn];
    }
}

- (void)retrieveData
{
    BOOL isReachable = [[AppDelegate instance] performSelector:@selector(isParseReachable)];
    if(!isReachable) {
        [UIUtility showNetWorkError:self.view];
    }
    NSString *key = [NSString stringWithFormat:@"%@%@", @"drama", self.prodId];
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
        NSString *key = [NSString stringWithFormat:@"%@%@", @"drama", self.prodId];
        [[CacheUtility sharedCache] putInCache:key result:result];
        video = (NSDictionary *)[result objectForKey:@"tv"];
        episodeArray = [video objectForKey:@"episodes"];
        [self checkCanPlayVideo];
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        episodeArray = [episodeArray sortedArrayUsingComparator:^(NSDictionary *a, NSDictionary *b) {
            NSNumber *first =  [f numberFromString:[NSString stringWithFormat:@"%@", [a objectForKey:@"name"]]];
            NSNumber *second = [f numberFromString:[NSString stringWithFormat:@"%@", [b objectForKey:@"name"]]];
            if (first && second) {
                return [first compare:second];
            } else {
                return NSOrderedSame;
            }
        }];
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
    NSString *stars = [video objectForKey:@"stars"];
    self.actorName1Label.text = stars;
    
    if (!self.canPlayVideo) {
        //[self.playBtn setEnabled:NO];
        self.playBtn.hidden = YES;
        self.expectbtn.hidden = NO;
        [self.downloadBtn setEnabled:NO];
        [self.downloadBtn setBackgroundImage:[UIImage imageNamed:@"no_download"] forState:UIControlStateDisabled];
    }
    
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
    increasePositionY = 0;
    [self repositElements];
}


- (void)calculateIntroContentHeight
{
    self.introContentTextView.text = [video objectForKey:@"summary"];
    introContentHeight = self.introContentTextView.contentSize.height;
}

//- (void)next20Epi:(UIButton *)btn
//{
//    if(btn.tag == 9011){
//        episodePageNumber++;
//    } else {
//        episodePageNumber--;
//    }
//    
//    [self setControlButtonDisplay];
//    [episodeView setContentOffset:CGPointMake(430*episodePageNumber, 0)];
//}

//- (void)setControlButtonDisplay
//{
//    if(episodePageNumber <=0){
//        episodePageNumber = 0;
//        [nextBtn setHidden:NO];
//        [previousBtn setHidden:YES];
//    }
//    if(episodePageNumber >= floor(totalEpisodeNumber/(EPISODE_NUMBER_IN_ROW*4.0))){
//        episodePageNumber = floor(totalEpisodeNumber/(EPISODE_NUMBER_IN_ROW*4.0));
//        [nextBtn setHidden:YES];
//        [previousBtn setHidden:NO];
//    }
//    if(episodePageNumber > 0 && episodePageNumber < floor(totalEpisodeNumber/(EPISODE_NUMBER_IN_ROW*4.0))){
//        [nextBtn setHidden:NO];
//        [previousBtn setHidden:NO];
//    }
//    if ((int)fmin(20, totalEpisodeNumber - (episodePageNumber+1)*20) > 0) {
//        [nextBtn setTitle:[NSString stringWithFormat:@"后%i集", (int)fmin(20, totalEpisodeNumber - (episodePageNumber+1)*20)] forState:UIControlStateNormal];
//    } else {
//        [nextBtn setHidden:YES];
//    }
//}

- (void)pageBtnClicked:(UIButton *)btn
{
    for (UIView *subview in pageTabScrollView.subviews) {
        if ([subview isKindOfClass:[UIButton class]] && subview.tag != btn.tag) {
            UIButton *tabBtn = (UIButton *)subview;
            [tabBtn setTitleColor:CMConstants.grayColor forState:UIControlStateNormal];
            [tabBtn setBackgroundImage:nil forState:UIControlStateNormal];
        }
    }
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"drama_pressed"] forState:UIControlStateNormal];
    [episodeView setContentOffset:CGPointMake(episodeView.frame.size.width*(btn.tag - 7101), 0) animated:YES];
}

- (void)repositElements
{
    id lastNumObj = [[CacheUtility sharedCache]loadFromCache:[NSString stringWithFormat:@"drama_epi_%@", self.prodId]];
    int lastNum = -1;
    if(lastNumObj != nil){
        lastNum = [lastNumObj integerValue];
    }
    BOOL changed = NO;
    if (totalEpisodeNumber != episodeArray.count) {
        changed = YES;
    }
    int dramaPageNum = ceil(episodeArray.count / 20.0);
    
    totalEpisodeNumber = episodeArray.count;
    if (0 != totalEpisodeNumber)
    {
        self.episodeImage.frame = CGRectMake(LEFT_WIDTH, 410, 70, 19);
        pageTabScrollView.frame = CGRectMake(LEFT_WIDTH, DEFAULT_POSITION_Y + increasePositionY, 430-4, 30);
        pageTabScrollView.backgroundColor = [UIColor clearColor];
        pageTabScrollView.contentSize = CGSizeMake(pageTabScrollView.frame.size.width*(dramaPageNum/6+1), pageTabScrollView.frame.size.height);
        for (UIView *aview in pageTabScrollView.subviews) {
            [aview removeFromSuperview];
        }
        for (int i = 0; i < dramaPageNum; i++) {
            UIButton *pageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            pageBtn.frame = CGRectMake(i * (63 + 8), 0, 63, 27);
            pageBtn.tag = 7101 + i;
            if(i == 0){
                [pageBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [pageBtn setBackgroundImage:[UIImage imageNamed:@"drama_pressed"] forState:UIControlStateNormal];
            } else {
                [pageBtn setTitleColor:CMConstants.grayColor forState:UIControlStateNormal];
            }
            [pageBtn setTitle:[NSString stringWithFormat:@"%i-%i", i*20+1, (int)fmin((i+1)*20, episodeArray.count)] forState:UIControlStateNormal];
            [pageBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
            [pageBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            [pageBtn setBackgroundImage:[UIImage imageNamed:@"drama_pressed"] forState:UIControlStateHighlighted];
            [pageBtn addTarget:self action:@selector(pageBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [pageTabScrollView addSubview:pageBtn];
        }
        
        episodeView.frame = CGRectMake(LEFT_WIDTH, DEFAULT_POSITION_Y + increasePositionY + 40, 430, fmin(4, ceil(totalEpisodeNumber*1.0/EPISODE_NUMBER_IN_ROW)) * (36+10) + 5);
        self.episodeViewBg.frame = episodeView.frame;
        episodeView.contentSize = CGSizeMake(ceil(totalEpisodeNumber/(EPISODE_NUMBER_IN_ROW*4.0)) * 430, episodeView.frame.size.height);
        if(changed){
            for (UIView *aview in episodeView.subviews) {
                [aview removeFromSuperview];
            }
            for (int i = 0; i < totalEpisodeNumber; i++) {
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.tag = i+1;
                int pageNum = floor(i/(EPISODE_NUMBER_IN_ROW*4.0));
                [btn setFrame:CGRectMake(13 + pageNum*430 + (i % EPISODE_NUMBER_IN_ROW) * (65 + 20), 7 + floor((i%(EPISODE_NUMBER_IN_ROW*4))*1.0/ EPISODE_NUMBER_IN_ROW) * (36 + 10), 65, 36)];
                NSString *name = [NSString stringWithFormat:@"%@", [[episodeArray objectAtIndex:i] objectForKey:@"name"]];
                [btn setTitle:name forState:UIControlStateNormal];
                [btn.titleLabel setFont:[UIFont systemFontOfSize:18]];
                btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
                BOOL btnStatus = NO;
                // 检查是否有有效的视频地址
                if ([[AppDelegate instance].showVideoSwitch isEqualToString:@"0"]) {
                    NSArray *videoUrlArray = [[episodeArray objectAtIndex:i] objectForKey:@"down_urls"];
                    if(videoUrlArray.count > 0){
                        for(NSDictionary *tempVideo in videoUrlArray){
                            NSArray *urls = [tempVideo objectForKey:@"urls"];
                            for (NSDictionary *url in urls) {
                                if ([super validadUrl:[url objectForKey:@"url"]]) {
                                    btnStatus = YES;
                                    break;
                                }
                            }
                            if (btnStatus) {
                                break;
                            }
                        }
                    }
                }
                if(!btnStatus){
                    // 检查是否有有效的网页地址
                    NSArray *videoUrls = [[episodeArray objectAtIndex:i] objectForKey:@"video_urls"];
                    for (NSDictionary *videoUrl in videoUrls) {
                        NSString *url = [NSString stringWithFormat:@"%@", [videoUrl objectForKey:@"url"]];
                        if([self validadUrl:url]){
                            btnStatus = YES;
                            break;
                        }
                    }
                }
                if (!btnStatus) {
                    [btn setEnabled:NO];
                }
                if(lastNum == i+1 && btn.enabled){
                    [btn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
                    [btn setBackgroundImage:[UIImage imageNamed:@"drama_watched"] forState:UIControlStateNormal];
                } else {
                    [btn setTitleColor:CMConstants.grayColor forState:UIControlStateNormal];
                    [btn setBackgroundImage:[UIImage imageNamed:@"drama"] forState:UIControlStateNormal];
                }
                [btn setBackgroundImage:[[UIImage imageNamed:@"drama_disabled"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateDisabled];
                [btn setBackgroundImage:[UIImage imageNamed:@"drama_pressed"] forState:UIControlStateHighlighted];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
                [btn addTarget:self action:@selector(dramaPlay:)forControlEvents:UIControlEventTouchUpInside];
                [episodeView addSubview:btn];
            }
        }
    }

//    if(nextBtn == nil){
//        nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [nextBtn setTitle:[NSString stringWithFormat:@"后%i集", (int)fmin(20, totalEpisodeNumber - (episodePageNumber+1)*20)] forState:UIControlStateNormal];
//        [nextBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 60, 0, 5)];
//        [nextBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
//        nextBtn.titleLabel.font = [UIFont systemFontOfSize:13];
//        [nextBtn setTitleColor:CMConstants.grayColor forState:UIControlStateNormal];
//        [nextBtn setTitleColor:CMConstants.yellowColor forState:UIControlStateHighlighted];
//        [nextBtn setImage:[UIImage imageNamed:@"right"] forState:UIControlStateNormal];
//        [nextBtn setImage:[UIImage imageNamed:@"right_pressed"] forState:UIControlStateNormal];
//        [nextBtn addTarget:self action:@selector(next20Epi:) forControlEvents:UIControlEventTouchUpInside];
//        nextBtn.tag = 9011;
//        [self.bgScrollView addSubview:nextBtn];
//    }
//    
//    if(previousBtn == nil){
//        previousBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [previousBtn setTitle:@"前20集" forState:UIControlStateNormal];
//        [previousBtn setImage:[UIImage imageNamed:@"left"] forState:UIControlStateNormal];
//        [previousBtn setImage:[UIImage imageNamed:@"left_pressed"] forState:UIControlStateHighlighted];
//        previousBtn.titleLabel.font = [UIFont systemFontOfSize:13];
//        [previousBtn setTitleColor:CMConstants.grayColor forState:UIControlStateNormal];
//        [previousBtn setTitleColor:CMConstants.yellowColor forState:UIControlStateHighlighted];
//        [previousBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 60)];
//        [previousBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
//        [previousBtn addTarget:self action:@selector(next20Epi:) forControlEvents:UIControlEventTouchUpInside];
//        previousBtn.tag = 9012;
//        [previousBtn setHidden:YES];
//        [self.bgScrollView addSubview:previousBtn];
//    }
//    if(totalEpisodeNumber <= EPISODE_NUMBER_IN_ROW * 4){
//        [nextBtn setHidden:YES];
//        [previousBtn setHidden:YES];
//    }
    
    CGFloat y = episodeView.frame.origin.y + episodeView.frame.size.height;
   
    if (0 == y)
    {
        y = self.shareLabel.frame.origin.y + self.shareLabel.frame.size.height;
    }
//    nextBtn.frame = CGRectMake(LEFT_WIDTH + 350, y , 80, 30);
//    previousBtn.frame = CGRectMake(LEFT_WIDTH, y, 80, 30);
//    
//    y = previousBtn.frame.origin.y + previousBtn.frame.size.height;
    self.introImage.frame = CGRectMake(LEFT_WIDTH, y + 20, 45, 20);
    self.introImage.image = [UIImage imageNamed:@"brief_title"];
    
    y = self.introImage.frame.origin.y + self.introImage.frame.size.height + 10;
    self.introContentTextView.frame = CGRectMake(LEFT_WIDTH, y, 430, self.introContentTextView.frame.size.height);
    self.introContentTextView.textColor = CMConstants.grayColor;
    self.introContentTextView.text = [video objectForKey:@"summary"];
    
    introBtn.frame = CGRectMake(LEFT_WIDTH + 415, self.introContentTextView.frame.origin.y + self.introContentTextView.frame.size.height - 10, 14, 9);
    
    y = self.introContentTextView.frame.origin.y + self.introContentTextView.frame.size.height;
    [self relocateCommentWithOriginY:y];
}

- (void)relocateCommentWithOriginY:(CGFloat)y
{
    int positionY = y;
    if(topics.count > 0){
        self.relatedImage.frame = CGRectMake(LEFT_WIDTH, positionY + 20, 80, 20);
        self.relatedImage.image = [UIImage imageNamed:@"morelists_title"];
        if(topicListViewController == nil){
            topicListViewController = [[SublistViewController alloc]initWithStyle:UITableViewStylePlain];
            topicListViewController.listData = topics;
            topicListViewController.videoDelegate = self;
            [self addChildViewController:topicListViewController];
            [self.bgScrollView addSubview:topicListViewController.view];
        }
        topicListViewController.view.frame = CGRectMake(LEFT_WIDTH, positionY + 50, 430, (topics.count > 5 ? 5 : topics.count)*30);
        positionY = topicListViewController.view.frame.origin.y + (topics.count > 5 ? 5 : topics.count)*30;
    }
    
    self.commentImage.frame = CGRectMake(LEFT_WIDTH, positionY + 20, 41, 18);
    self.commentImage.image = [UIImage imageNamed:@"comment_title"];
    
    if(commentListViewController == nil){
        commentListViewController = [[CommentListViewController alloc]initWithStyle:UITableViewStylePlain];
        commentListViewController.parentDelegate = self;
        commentListViewController.prodId = self.prodId;
        [commentListViewController.view setHidden:YES];
        commentListViewController.videoName = [video objectForKey:@"name"];
        commentListViewController.doubanId = [NSString stringWithFormat:@"%@", [video objectForKey:@"douban_id"]];
        [self.bgScrollView addSubview:commentListViewController.view];
    }
    [commentListViewController.tableView reloadData];
    commentListViewController.view.frame = CGRectMake(LEFT_WIDTH, positionY + 48, 430, commentListViewController.tableHeight);
    
    [self.bgScrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+episodeView.frame.size.height + commentListViewController.tableHeight + increasePositionY +  (topics.count > 5 ? 5 : topics.count)*30)];
}

- (void)getTopComments:(int)num
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: self.prodId, @"prod_id", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathProgramView parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSString *key = [NSString stringWithFormat:@"%@%@", @"drama", self.prodId];
            [[CacheUtility sharedCache] putInCache:key result:result];
            video = (NSDictionary *)[result objectForKey:@"tv"];
            episodeArray = [video objectForKey:@"episodes"];
            NSArray *tempArray = (NSMutableArray *)[result objectForKey:@"comments"];
            [commentArray removeAllObjects];
            if(tempArray != nil && tempArray.count > 0){
                [commentArray addObjectsFromArray:tempArray];
            }
            if(introContentHeight > 90){
                if(introExpand){
                    increasePositionY = introContentHeight - 90;
                } else {
                    increasePositionY = 0;
                }
                [self repositElements];
            }
            
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
    }];
}

- (void)refreshCommentListView:(int)tableHeight
{
    [self.bgScrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+episodeView.frame.size.height + commentListViewController.tableHeight + increasePositionY +  (topics.count > 5 ? 5 : topics.count)*30)];
    commentListViewController.view.frame = CGRectMake(LEFT_WIDTH, commentListViewController.view.frame.origin.y, 430, tableHeight);
    if (tableHeight > 30) {
        [self.commentImage setHidden:NO];
        [commentListViewController.view setHidden:NO];
    }
}

- (void)clearLastBtnImage
{
    id lastNumObj = [[CacheUtility sharedCache]loadFromCache:[NSString stringWithFormat:@"drama_epi_%@", self.prodId]];
    int lastNum = -1;
    if(lastNumObj != nil){
        lastNum = [lastNumObj integerValue];
    }
    if (lastNum > 0 && lastNum <= episodeArray.count) {
        UIButton *lastbtn = (UIButton *)[episodeView viewWithTag:lastNum];
        [lastbtn setTitleColor:CMConstants.grayColor forState:UIControlStateNormal];
        [lastbtn setBackgroundImage:[UIImage imageNamed:@"drama"] forState:UIControlStateNormal];
    }
}

- (void)dramaPlay:(UIButton *)btn
{
    [self clearLastBtnImage];
    [btn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"drama_watched"] forState:UIControlStateNormal];
    [[CacheUtility sharedCache]putInCache:[NSString stringWithFormat:@"drama_epi_%@", self.prodId] result:[NSNumber numberWithInt:btn.tag]];
    self.subname = btn.titleLabel.text;
    [super playVideo:btn.tag-1];
}


- (void)playVideo
{
    id lastNumObj = [[CacheUtility sharedCache]loadFromCache:[NSString stringWithFormat:@"drama_epi_%@", self.prodId]];
    int lastNum = -1;
    if(lastNumObj != nil){
        lastNum = [lastNumObj integerValue];
    }
    if (lastNum > 0 && lastNum <= episodeArray.count) {
        UIButton *btn = (UIButton *)[self.bgScrollView viewWithTag:lastNum];
        [self dramaPlay:btn];
    } else {
        UIButton *btn = (UIButton *)[self.bgScrollView viewWithTag:1];
        [self dramaPlay:btn];
    }
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
            //            [[NSNotificationCenter defaultCenter] postNotificationName:PERSONAL_VIEW_REFRESH object:nil];
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

- (void)downloadBtnClicked
{
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([hostReach currentReachabilityStatus] == NotReachable) {
        [UIUtility showNetWorkError:self.view];
        return;
    }
    [AppDelegate instance].rootViewController.videoDetailDelegate = self;
    [[AppDelegate instance].rootViewController showDramaDownloadView:self.prodId video:video];
}

- (BOOL)downloadDrama:(int)num
{
    NSString *query = [NSString stringWithFormat:@"WHERE itemId = '%@'", self.prodId];
    DownloadItem *item = (DownloadItem *)[DatabaseManager findFirstByCriteria:DownloadItem.class queryString:query];
    if (item == nil) {
        BOOL success = [self addSubdownloadItem:num];
        if(success){
            [self addDownloadItem:num];
            return YES;
        } else {
            return NO;
        }
    } else {
        NSString *subquery = [NSString stringWithFormat:@"WHERE itemId = '%@' and subitemId = '%@'", self.prodId, [NSString stringWithFormat:@"%i", num]];
        SubdownloadItem *subitem = (SubdownloadItem *)[DatabaseManager findFirstByCriteria:SubdownloadItem.class queryString:subquery];
        if(subitem == nil){
            BOOL success = [self addSubdownloadItem:num];
            return success;
        } else {
            return YES;
        }
        
    }
}

- (void)addDownloadItem:(int)num
{
    DownloadItem *item = [[DownloadItem alloc]init];
    item.itemId = self.prodId;
    item.imageUrl = [video objectForKey:@"ipad_poster"];
    if([StringUtility stringIsEmpty:item.imageUrl]){
        item.imageUrl = [video objectForKey:@"poster"];
    }
    item.name = [video objectForKey:@"name"];
    item.percentage = 0;
    item.type = 2;
    item.downloadStatus = @"stop";
    [DatabaseManager save:item];
}

- (BOOL)addSubdownloadItem:(int)num
{
    SubdownloadItem *subitem = [[SubdownloadItem alloc]init];
    subitem.itemId = self.prodId;
    subitem.imageUrl = [video objectForKey:@"ipad_poster"];
    if([StringUtility stringIsEmpty:subitem.imageUrl]){
        subitem.imageUrl = [video objectForKey:@"poster"];
    }
    subitem.name = [NSString stringWithFormat:@"第%i集", num];
    subitem.percentage = 0;
    subitem.type = 2;
    subitem.subitemId = [NSString stringWithFormat:@"%i", num];
    subitem.downloadStatus = @"waiting";
    [self getDownloadUrls:num-1];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc]initWithCapacity:5];
    [tempArray addObjectsFromArray:self.mp4DownloadUrls];
    [tempArray addObjectsFromArray:self.m3u8DownloadUrls];
    subitem.urlArray = tempArray;
    
    if(subitem.urlArray.count > 0){
        if (self.mp4DownloadUrls.count > 0) {
            subitem.downloadType = @"mp4";
            subitem.fileName = [NSString stringWithFormat:@"%@_%i.mp4", self.prodId, num];
        } else if(self.m3u8DownloadUrls.count > 0){
            subitem.downloadType = @"m3u8";
        }
        [DatabaseManager save:subitem];
        DownloadUrlFinder *finder = [[DownloadUrlFinder alloc]init];
        finder.item = subitem;
        finder.mp4DownloadUrlNum = self.mp4DownloadUrls;
        [finder setupWorkingUrl];
        [self updateBadgeIcon];
        return YES;
    } else {
        return NO;
    }
}

#pragma mark -
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
{
    if (scrollView.tag == 323474820) {
        int page = floor(scrollView.contentOffset.x/scrollView.frame.size.width);
        int dramaPageNum = ceil(episodeArray.count / 20.0);
        if (page >= 0 && page < dramaPageNum) {
            [pageTabScrollView setContentOffset:CGPointMake(floor(page/6.0) * pageTabScrollView.frame.size.width, 0) animated:YES];
            UIButton *tabBtn = (UIButton *)[pageTabScrollView viewWithTag:7101 + page];
            [self pageBtnClicked:tabBtn];
        }
    }
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
