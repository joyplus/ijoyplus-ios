//
//  MovieDetailViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-20.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "DramaDetailViewController.h"
#import "ProgramViewController.h"
#import "MediaPlayerViewController.h"
#import "CommonHeader.h"
#import "CommentListViewController.h"
#import "SublistViewController.h"

#define LEFT_GAP 50

@interface DramaDetailViewController (){
    NSDictionary *video;
    NSMutableArray *commentArray;
    NSArray *episodeArray;
    SublistViewController *topicListViewController;
    CommentListViewController *commentListViewController;
    int totalEpisodeNumber;
    UIButton *introBtn;
    float introContentHeight;
    BOOL introExpand;
    BOOL btnAdded;
    UITapGestureRecognizer *tapGesture;
}


@end

@implementation DramaDetailViewController


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
    [self setActorLabel:nil];
    [self setActorName1Label:nil];
    [self setActorName2Label:nil];
    [self setActorName3Label:nil];
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
    [self setCommentImage:nil];
    [self setNumberLabel:nil];
    [self setCommentBtn:nil];
    [self setDingNumberImage:nil];
    [self setCollectioNumber:nil];
    [self setPlayRoundBtn:nil];
    [self setDingNumberLabel:nil];
    [self setCollectionNumberLabel:nil];
    [self setCloseBtn:nil];
    [self setRelatedImage:nil];
    [self setBgImage:nil];
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
    
    self.bgImage.frame = self.view.frame;
    self.bgImage.image = [UIImage imageNamed:@"detail_bg"];
    
    self.bgScrollView.frame = CGRectMake(0, 260, self.view.frame.size.width, self.view.frame.size.height);
    [self.bgScrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    
    self.playBtn.frame = CGRectMake(290, 115, 185, 40);
    [self.playBtn setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [self.playBtn setBackgroundImage:[UIImage imageNamed:@"play_pressed"] forState:UIControlStateHighlighted];
    
    self.closeBtn.frame = CGRectMake(470, 20, 40, 42);
    [self.closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [self.closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
    [self.closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.placeholderImage.frame = CGRectMake(LEFT_GAP, 78, 217, 312);
    self.placeholderImage.image = [UIImage imageNamed:@"movie_frame"];
    
    self.filmImage.frame = CGRectMake(LEFT_GAP+6, 84, 205, 300);
    self.filmImage.image = [UIImage imageNamed:@"video_placeholder"];
    
    self.playRoundBtn.frame = CGRectMake(0, 0, 63, 63);
    [self.playRoundBtn setBackgroundImage:[UIImage imageNamed:@"play_btn"] forState:UIControlStateNormal];
    [self.playRoundBtn setBackgroundImage:[UIImage imageNamed:@"play_btn_pressed"] forState:UIControlStateHighlighted];
    [self.playRoundBtn addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
    self.playRoundBtn.center = self.filmImage.center;
    
    self.titleImage.frame = CGRectMake(LEFT_GAP, 35, 62, 26);
    self.titleImage.image = [UIImage imageNamed:@"detail_title"];
    
    self.titleLabel.frame = CGRectMake(290, 85, 180, 20);
    self.titleLabel.font = CMConstants.titleFont;
    
    self.scoreLabel.frame = CGRectMake(290, 110, 50, 20);
    self.doulanLogo.frame = CGRectMake(335, 113, 15, 15);
    self.doulanLogo.image = [UIImage imageNamed:@"douban"];
    
    self.playBtn.frame = CGRectMake(290, 150, 185, 40);
    [self.playBtn setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [self.playBtn setBackgroundImage:[UIImage imageNamed:@"play_pressed"] forState:UIControlStateHighlighted];
    [self.playBtn addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
    
    self.actorLabel.frame = CGRectMake(290, 210, 50, 15);
    self.actorLabel.textColor = CMConstants.grayColor;
    self.actorName1Label.frame = CGRectMake(335, 210, 140, 15);
    self.actorName1Label.textColor = CMConstants.grayColor;
//    self.actorName2Label.frame = CGRectMake(335, 235, 100, 15);
//    self.actorName2Label.textColor = CMConstants.grayColor;
//    self.actorName3Label.frame = CGRectMake(335, 260, 100, 15);
//    self.actorName3Label.textColor = CMConstants.grayColor;
    self.playLabel.frame = CGRectMake(290, 240, 50, 15);
    self.playLabel.textColor = CMConstants.grayColor;
    self.playTimeLabel.frame = CGRectMake(335, 240, 100, 15);
    self.playTimeLabel.textColor = CMConstants.grayColor;
    self.regionLabel.frame = CGRectMake(290, 270, 50, 15);
    self.regionLabel.textColor = CMConstants.grayColor;
    self.regionNameLabel.frame = CGRectMake(335, 270, 100, 15);
    self.regionNameLabel.textColor = CMConstants.grayColor;
    
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
    
    self.introBgImage.frame = CGRectMake(LEFT_GAP, 490, 440, 100);
    self.introBgImage.image = [[UIImage imageNamed:@"brief"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 0, 5, 0)];
    
    self.introContentTextView.frame = CGRectMake(LEFT_GAP + 10, 490, 420, 100);
    tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(introBtnClicked)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self.introContentTextView addGestureRecognizer:tapGesture];
    
    commentArray = [[NSMutableArray alloc]initWithCapacity:10];
    
    introBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [introBtn setBackgroundImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    introBtn.frame = CGRectMake(LEFT_GAP + 420, self.introContentTextView.frame.origin.y + 80, 14, 9);
    [introBtn addTarget:self action:@selector(introBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.bgScrollView addSubview:introBtn];
}

- (void)introBtnClicked
{
    introExpand = !introExpand;
    if(introContentHeight > 80){
        if(introExpand){
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
                [self.introContentTextView setFrame:CGRectMake(self.introContentTextView.frame.origin.x, self.introContentTextView.frame.origin.y, self.introContentTextView.frame.size.width, introContentHeight)];
                self.introBgImage.frame = CGRectMake(LEFT_GAP, self.introBgImage.frame.origin.y, self.introBgImage.frame.size.width, introContentHeight);
                [introBtn setBackgroundImage:[UIImage imageNamed:@"more_off"] forState:UIControlStateNormal];
                introBtn.frame = CGRectMake(introBtn.frame.origin.x, self.introContentTextView.frame.origin.y + 80 + introContentHeight - 100, introBtn.frame.size.width, introBtn.frame.size.height);
                [self repositElements:introContentHeight - 100];
            } completion:^(BOOL finished) {
            }];
        } else {
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
                [self.introContentTextView setFrame:CGRectMake(self.introContentTextView.frame.origin.x, self.introContentTextView.frame.origin.y, self.introContentTextView.frame.size.width, 100)];
                self.introBgImage.frame = CGRectMake(LEFT_GAP, self.introBgImage.frame.origin.y, self.introBgImage.frame.size.width, 100);
                [introBtn setBackgroundImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
                introBtn.frame = CGRectMake(introBtn.frame.origin.x, self.introContentTextView.frame.origin.y + 80, introBtn.frame.size.width, introBtn.frame.size.height);
                [self repositElements:0];
            } completion:^(BOOL finished) {
                
            }];
        }
    } else {
        if(introExpand){
            [introBtn setBackgroundImage:[UIImage imageNamed:@"more_off"] forState:UIControlStateNormal];
        } else {
            [introBtn setBackgroundImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    if(video == nil){
        [self retrieveData];
    }
}

- (void)retrieveData
{
    NSString *key = [NSString stringWithFormat:@"%@%@", @"drama", self.prodId];
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
        NSString *key = [NSString stringWithFormat:@"%@%@", @"drama", self.prodId];
        [[CacheUtility sharedCache] putInCache:key result:result];
        video = (NSDictionary *)[result objectForKey:@"tv"];
        episodeArray = [video objectForKey:@"episodes"];
        topics = [result objectForKey:@"topics"];
        NSArray *tempArray = (NSMutableArray *)[result objectForKey:@"comments"];
        [commentArray removeAllObjects];
        if(tempArray != nil && tempArray.count > 0){
            [commentArray addObjectsFromArray:tempArray];
        }
        [self calculateIntroContentHeight];
        [self showValues];
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_MB_PROGRESS_BAR object:self userInfo:nil];
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
    self.scoreLabel.textColor = CMConstants.scoreBlueColor;
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
    
    self.introContentTextView.textColor = CMConstants.grayColor;
    self.introContentTextView.text = [video objectForKey:@"summary"];
    
    [self repositElements:0];
}


- (void)calculateIntroContentHeight
{
    self.introContentTextView.text = [video objectForKey:@"summary"];
    introContentHeight = self.introContentTextView.contentSize.height;
}


- (void)repositElements:(int)increasePositionY
{   
    id lastNumObj = [[CacheUtility sharedCache]loadFromCache:[NSString stringWithFormat:@"drama_epi_%@", self.prodId]];
    int lastNum = -1;
    if(lastNumObj != nil){
        lastNum = [lastNumObj integerValue];
    }
    
    totalEpisodeNumber = episodeArray.count;
    if(btnAdded){
        for (int i = 0; i < totalEpisodeNumber; i++) {
            UIButton *btn = (UIButton *)[self.bgScrollView viewWithTag:i+1];
            [btn setFrame:CGRectMake(LEFT_GAP + (i % 9) * 49, 600 + floor(i / 9.0) * 39 + increasePositionY, 44, 34)];
        }
    } else {
        for (int i = 0; i < totalEpisodeNumber; i++) {
            btnAdded = YES;
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = i+1;
            [btn setFrame:CGRectMake(LEFT_GAP + (i % 9) * 49, 600 + floor(i / 9.0) * 39, 44, 34)];
            if (i < 9) {
                [btn setTitle:[NSString stringWithFormat:@"0%i", i+1] forState:UIControlStateNormal];
            } else {
                [btn setTitle:[NSString stringWithFormat:@"%i", i+1] forState:UIControlStateNormal];
            }
            [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
            btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|
            UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
            if(lastNum == i+1){
                [btn setBackgroundImage:[UIImage imageNamed:@"drama_watched"] forState:UIControlStateNormal];
            } else {
                [btn setBackgroundImage:[UIImage imageNamed:@"drama"] forState:UIControlStateNormal];
            }
            [btn setBackgroundImage:[UIImage imageNamed:@"drama_pressed"] forState:UIControlStateHighlighted];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorWithRed:55/255.0 green:100/255.0 blue:158/255.0 alpha:1] forState:UIControlStateHighlighted];
            [btn addTarget:self action:@selector(dramaPlay:)forControlEvents:UIControlEventTouchUpInside];
            [self.bgScrollView addSubview:btn];
        }
    }
    int positionY = self.introContentTextView.frame.origin.y + self.introContentTextView.frame.size.height + increasePositionY + 10;
    UIButton *lastBtn = (UIButton *)[self.bgScrollView viewWithTag:(totalEpisodeNumber-1)];
    if(lastBtn != nil){
        positionY = lastBtn.frame.origin.y + 30;
    }
    
    if(topics.count > 0){
        self.relatedImage.frame = CGRectMake(LEFT_GAP, positionY + 30, 80, 20);
        self.relatedImage.image = [UIImage imageNamed:@"morelists_title1"];
        if(topicListViewController == nil){
            topicListViewController = [[SublistViewController alloc]initWithStyle:UITableViewStylePlain];
            topicListViewController.listData = topics;
            topicListViewController.videoDelegate = self;
            [self addChildViewController:topicListViewController];
            [self.bgScrollView addSubview:topicListViewController.view];
        }
        topicListViewController.view.frame = CGRectMake(LEFT_GAP, positionY + 55, 440, (topics.count > 5 ? 5 : topics.count)*30);
        positionY = topicListViewController.view.frame.origin.y + (topics.count > 5 ? 5 : topics.count)*30;
    }
    
    int totalCommentNum = [[video objectForKey:@"total_comment_number"] integerValue];
    self.commentImage.frame = CGRectMake(LEFT_GAP, positionY + 20, 74, 19);
    self.commentImage.image = [UIImage imageNamed:@"comment_title"];
    
    self.numberLabel.frame = CGRectMake(139, positionY + 20, 100, 18);
    self.numberLabel.textColor = CMConstants.grayColor;
    self.numberLabel.text = [NSString stringWithFormat:@"(%i条)", totalCommentNum];
    
    self.commentBtn.frame = CGRectMake(425, positionY + 17, 66, 26);
    [self.commentBtn setBackgroundImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];
    [self.commentBtn setBackgroundImage:[UIImage imageNamed:@"comment_pressed"] forState:UIControlStateHighlighted];
    [self.commentBtn addTarget:self action:@selector(commentBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    if(commentListViewController == nil){
        commentListViewController = [[CommentListViewController alloc]initWithStyle:UITableViewStylePlain];
        commentListViewController.parentDelegate = self;
        commentListViewController.prodId = self.prodId;
        [self.bgScrollView addSubview:commentListViewController.view];
    }
    commentListViewController.totalCommentNum = totalCommentNum;
    commentListViewController.view.frame = CGRectMake(LEFT_GAP, positionY + 60, 440, 200);
    commentListViewController.listData = commentArray;
    [commentListViewController.tableView reloadData];
    
    [self.bgScrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+commentListViewController.tableHeight+ceil(totalEpisodeNumber/10.0)*35 + 300 + increasePositionY +  (topics.count > 5 ? 5 : topics.count)*30)];
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
            if(introContentHeight > 80){
                if(introExpand){
                    [self repositElements:introContentHeight - 80];
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
    [self.bgScrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+tableHeight+ceil(totalEpisodeNumber/10.0)*35 + 200)];
    commentListViewController.view.frame = CGRectMake(LEFT_GAP, commentListViewController.view.frame.origin.y, 425, tableHeight);
}

- (void)clearLastBtnImage
{
    id lastNumObj = [[CacheUtility sharedCache]loadFromCache:[NSString stringWithFormat:@"drama_epi_%@", self.prodId]];
    int lastNum = -1;
    if(lastNumObj != nil){
        lastNum = [lastNumObj integerValue];
    }
    UIButton *lastbtn = (UIButton *)[self.bgScrollView viewWithTag:lastNum];
    [lastbtn setBackgroundImage:[UIImage imageNamed:@"drama"] forState:UIControlStateNormal];
}

- (void)dramaPlay:(id)sender
{
    [self clearLastBtnImage];
    UIButton *btn = (UIButton *)sender;
    [btn setBackgroundImage:[UIImage imageNamed:@"drama_watched"] forState:UIControlStateNormal];
    [self playVideo:btn.tag];
}


- (void)playVideo
{
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [UIUtility showNetWorkError:self.view];
        return;
    }
    [self clearLastBtnImage];
    
    UIButton *btn = (UIButton *)[self.bgScrollView viewWithTag:1];
    [btn setBackgroundImage:[UIImage imageNamed:@"drama_watched"] forState:UIControlStateNormal];
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
    [[CacheUtility sharedCache]putInCache:[NSString stringWithFormat:@"drama_epi_%@", self.prodId] result:[NSNumber numberWithInt:num]];
    NSArray *videoUrlArray = [[episodeArray objectAtIndex:num-1] objectForKey:@"down_urls"];
    for(NSDictionary *episode in episodeArray){
        if([[episode objectForKey:@"name"]integerValue] == num){
            videoUrlArray = [episode objectForKey:@"down_urls"];
            break;
        }
    }
    if(videoUrlArray.count > 0){
        NSString *videoUrl = nil;
        for(NSDictionary *tempVideo in videoUrlArray){
            if([LETV isEqualToString:[tempVideo objectForKey:@"source"]]){
                videoUrl = [self parseVideoUrl:tempVideo];
                break;
            }
        }
        if(videoUrl == nil){
            if (videoUrlArray.count > 0) {
                videoUrl = [self parseVideoUrl:[videoUrlArray objectAtIndex:0]];
            }
        }
        if(videoUrl == nil){
            [self gotoWebsite:num];
        } else {
            MediaPlayerViewController *viewController = [[MediaPlayerViewController alloc]initWithNibName:@"MediaPlayerViewController" bundle:nil];
            viewController.videoUrl = videoUrl;
            viewController.type = 2;
            viewController.name = [video objectForKey:@"name"];
            viewController.subname = [NSString stringWithFormat:@"%i", num];
            [[AppDelegate instance].rootViewController pesentMyModalView:viewController];
        }
    }else {
        [self gotoWebsite:num];
    }
}

- (void)gotoWebsite:(NSInteger)num
{
    ProgramViewController *viewController = [[ProgramViewController alloc]initWithNibName:@"ProgramViewController" bundle:nil];
    NSString *url = nil;
    for(NSDictionary *episode in episodeArray){
        if([[episode objectForKey:@"name"]integerValue] == num){
            NSArray *urlArray = [episode objectForKey:@"video_urls"];
            url = [[urlArray objectAtIndex:0] objectForKey:@"url"];
            break;
        }
    }
    if(url == nil){
        url = [[[[episodeArray objectAtIndex:0] objectForKey:@"video_urls"] objectAtIndex:0] objectForKey:@"url"];
    }
    viewController.programUrl = url;
    viewController.title = [video objectForKey:@"name"];
    viewController.type = 2;
    viewController.subname = [NSString stringWithFormat:@"%i", num];
    [[AppDelegate instance].rootViewController pesentMyModalView:[[UINavigationController alloc]initWithRootViewController:viewController]];
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
