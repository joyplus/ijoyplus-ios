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

#define DEFAULT_POSITION_Y 600
#define EPISODE_NUMBER_IN_ROW 5

@interface DramaDetailViewController (){
    NSMutableArray *commentArray;
    SublistViewController *topicListViewController;
    CommentListViewController *commentListViewController;
    int totalEpisodeNumber;
    UIButton *introBtn;
    float introContentHeight;
    BOOL introExpand;
    BOOL btnAdded;
    UITapGestureRecognizer *tapGesture;
    
    UIScrollView *episodeView;
    int episodePageNumber;
    
    UIButton *nextBtn;
    UIButton *previousBtn;
    int increasePositionY;
}


@end

@implementation DramaDetailViewController


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
    nextBtn = nil;
    previousBtn = nil;
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
    [self setDownloadBtn:nil];
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
    
    self.bgScrollView.frame = CGRectMake(0, 255, self.view.frame.size.width, self.view.frame.size.height);
    [self.bgScrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    
    self.playBtn.frame = CGRectMake(290, 115, 185, 40);
    [self.playBtn setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [self.playBtn setBackgroundImage:[UIImage imageNamed:@"play_pressed"] forState:UIControlStateHighlighted];
    
    self.closeBtn.frame = CGRectMake(465, 20, 40, 42);
    [self.closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [self.closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
    [self.closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.placeholderImage.frame = CGRectMake(LEFT_WIDTH, 78, 217, 312);
    self.placeholderImage.image = [UIImage imageNamed:@"movie_frame"];
    
    self.filmImage.frame = CGRectMake(LEFT_WIDTH+5, 84, 205, 300);
    self.filmImage.image = [UIImage imageNamed:@"video_placeholder"];
    
    self.playRoundBtn.frame = CGRectMake(0, 0, 63, 63);
    [self.playRoundBtn setBackgroundImage:[UIImage imageNamed:@"play_btn"] forState:UIControlStateNormal];
    [self.playRoundBtn setBackgroundImage:[UIImage imageNamed:@"play_btn_pressed"] forState:UIControlStateHighlighted];
    [self.playRoundBtn addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
    self.playRoundBtn.center = self.filmImage.center;
    
    self.titleImage.frame = CGRectMake(LEFT_WIDTH, 35, 62, 26);
    self.titleImage.image = [UIImage imageNamed:@"detail_title"];
    
    self.titleLabel.frame = CGRectMake(278, 85, 210, 20);
    self.titleLabel.font = CMConstants.titleFont;
    
    self.scoreLabel.frame = CGRectMake(280, 110, 50, 20);
    self.doulanLogo.frame = CGRectMake(335, 113, 15, 15);
    self.doulanLogo.image = [UIImage imageNamed:@"douban"];
    
    self.playBtn.frame = CGRectMake(280, 150, 185, 40);
    [self.playBtn setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [self.playBtn setBackgroundImage:[UIImage imageNamed:@"play_pressed"] forState:UIControlStateHighlighted];
    [self.playBtn addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
    
    self.actorLabel.frame = CGRectMake(280, 210, 50, 15);
    self.actorLabel.textColor = CMConstants.grayColor;
    self.actorName1Label.frame = CGRectMake(325, 210, 140, 15);
    self.actorName1Label.textColor = CMConstants.grayColor;
    //    self.actorName2Label.frame = CGRectMake(335, 235, 100, 15);
    //    self.actorName2Label.textColor = CMConstants.grayColor;
    //    self.actorName3Label.frame = CGRectMake(335, 260, 100, 15);
    //    self.actorName3Label.textColor = CMConstants.grayColor;
    self.playLabel.frame = CGRectMake(280, 240, 50, 15);
    self.playLabel.textColor = CMConstants.grayColor;
    self.playTimeLabel.frame = CGRectMake(325, 240, 100, 15);
    self.playTimeLabel.textColor = CMConstants.grayColor;
    self.regionLabel.frame = CGRectMake(280, 270, 50, 15);
    self.regionLabel.textColor = CMConstants.grayColor;
    self.regionNameLabel.frame = CGRectMake(325, 270, 100, 15);
    self.regionNameLabel.textColor = CMConstants.grayColor;
    
    self.dingNumberImage.frame = CGRectMake(280, 360, 75, 24);
    self.dingNumberImage.image = [UIImage imageNamed:@"pushinguser"];
    self.dingNumberLabel.frame = CGRectMake(285, 360, 40, 24);
    
    self.collectioNumber.frame = CGRectMake(380, 360, 84, 24);
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
    tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(introBtnClicked)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self.introContentTextView addGestureRecognizer:tapGesture];
    
    commentArray = [[NSMutableArray alloc]initWithCapacity:10];
    
    introBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [introBtn setBackgroundImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    introBtn.frame = CGRectMake(LEFT_WIDTH + 410, self.introContentTextView.frame.origin.y + 80, 14, 9);
    [introBtn addTarget:self action:@selector(introBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.bgScrollView addSubview:introBtn];
    
    self.type = 2;
    
    episodeView = [[UIScrollView alloc]initWithFrame:CGRectZero];
    episodeView.scrollEnabled = NO;
    episodeView.backgroundColor = [UIColor clearColor];
    [episodeView setPagingEnabled:YES];
    [self.bgScrollView addSubview:episodeView];
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
                introBtn.frame = CGRectMake(introBtn.frame.origin.x, self.introContentTextView.frame.origin.y + 80 + introContentHeight - 100, introBtn.frame.size.width, introBtn.frame.size.height);
                increasePositionY = introContentHeight - 100;
                [self repositElements];
            } completion:^(BOOL finished) {
            }];
        } else {
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
                [self.introContentTextView setFrame:CGRectMake(self.introContentTextView.frame.origin.x, self.introContentTextView.frame.origin.y, self.introContentTextView.frame.size.width, 100)];
                self.introBgImage.frame = CGRectMake(LEFT_WIDTH, self.introBgImage.frame.origin.y, self.introBgImage.frame.size.width, 100);
                [introBtn setBackgroundImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
                introBtn.frame = CGRectMake(introBtn.frame.origin.x, self.introContentTextView.frame.origin.y + 80, introBtn.frame.size.width, introBtn.frame.size.height);
                increasePositionY = 0;
                [self repositElements];
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
    if([@"1" isEqualToString:[AppDelegate instance].playBtnSuppressed]){
        [self.playRoundBtn setHidden:YES];
        [self.playBtn setEnabled:NO];
        [self.playBtn setBackgroundImage:[UIImage imageNamed:@"play_disabled"] forState:UIControlStateDisabled];
        [self.downloadBtn setHidden:YES];
    }
    if(video == nil){
        [self retrieveData];
    }
}

- (void)retrieveData
{
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([hostReach currentReachabilityStatus] == NotReachable) {
        [UIUtility showNetWorkError:self.view];
    }
    NSString *key = [NSString stringWithFormat:@"%@%@", @"drama", self.prodId];
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:key];
    if(cacheResult != nil){
        [self parseData:cacheResult];
    } else {
        if([hostReach currentReachabilityStatus] != NotReachable) {
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
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        episodeArray = [episodeArray sortedArrayUsingComparator:^(NSDictionary *a, NSDictionary *b) {
            NSNumber *first =  [f numberFromString:[NSString stringWithFormat:@"%@", [a objectForKey:@"name"]]];
            NSNumber *second = [f numberFromString:[NSString stringWithFormat:@"%@", [b objectForKey:@"name"]]];
            return [first compare:second];
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
    [self.filmImage setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
    
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
    
    if(downloadUrls != nil && downloadUrls.count > 0){
    } else {
        [self.downloadBtn setEnabled:NO];
        [self.downloadBtn setBackgroundImage:[UIImage imageNamed:@"no_download"] forState:UIControlStateDisabled];
    }
    
    self.introContentTextView.textColor = CMConstants.grayColor;
    self.introContentTextView.text = [video objectForKey:@"summary"];
    increasePositionY = 0;
    [self repositElements];
}


- (void)calculateIntroContentHeight
{
    self.introContentTextView.text = [video objectForKey:@"summary"];
    introContentHeight = self.introContentTextView.contentSize.height;
}

- (void)next20Epi:(UIButton *)btn
{
    if(btn.tag == 9011){
        episodePageNumber++;
    } else {
        episodePageNumber--;
    }
    if(episodePageNumber <=0){
        episodePageNumber = 0;
        [nextBtn setHidden:NO];
        [previousBtn setHidden:YES];
    }
    if(episodePageNumber >= floor(totalEpisodeNumber/(EPISODE_NUMBER_IN_ROW*4.0))){
        episodePageNumber = floor(totalEpisodeNumber/(EPISODE_NUMBER_IN_ROW*4.0));
        [nextBtn setHidden:YES];
        [previousBtn setHidden:NO];
    }
    [self relocateComment];
    if(episodePageNumber > 0 && episodePageNumber < floor(totalEpisodeNumber/(EPISODE_NUMBER_IN_ROW*4.0))){
        [nextBtn setHidden:NO];
        [previousBtn setHidden:NO];
    }
    [nextBtn setTitle:[NSString stringWithFormat:@"后%i集", (int)fmin(20, totalEpisodeNumber - (episodePageNumber+1)*20)] forState:UIControlStateNormal];
    [episodeView setContentOffset:CGPointMake(430*episodePageNumber, 0)];
}

- (void)repositElements
{
    id lastNumObj = [[CacheUtility sharedCache]loadFromCache:[NSString stringWithFormat:@"drama_epi_%@", self.prodId]];
    int lastNum = -1;
    if(lastNumObj != nil){
        lastNum = [lastNumObj integerValue];
    }
    
    totalEpisodeNumber = episodeArray.count;
    episodeView.frame = CGRectMake(LEFT_WIDTH, DEFAULT_POSITION_Y + increasePositionY, 430, fmin(4, ceil(totalEpisodeNumber*1.0/EPISODE_NUMBER_IN_ROW)) * 39);
    episodeView.contentSize = CGSizeMake(ceil(totalEpisodeNumber/EPISODE_NUMBER_IN_ROW*4.0) * 430, episodeView.frame.size.height);
    if(![@"1" isEqualToString:[AppDelegate instance].playBtnSuppressed]){
        if(!btnAdded){
            for (int i = 0; i < totalEpisodeNumber; i++) {
                btnAdded = YES;
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.tag = i+1;
                int pageNum = floor(i/(EPISODE_NUMBER_IN_ROW*4.0));
                [btn setFrame:CGRectMake(pageNum*430 + (i % EPISODE_NUMBER_IN_ROW) * 87, floor((i%(EPISODE_NUMBER_IN_ROW*4))*1.0/ EPISODE_NUMBER_IN_ROW) * 39, 82, 34)];
                NSString *name = [NSString stringWithFormat:@"%@", [[episodeArray objectAtIndex:i] objectForKey:@"name"]];
                [btn setTitle:name forState:UIControlStateNormal];
                [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
                btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|
                UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
                if(lastNum == i+1){
                    [btn setBackgroundImage:[UIImage imageNamed:@"drama_watched"] forState:UIControlStateNormal];
                } else {
                    [btn setBackgroundImage:[UIImage imageNamed:@"drama"] forState:UIControlStateNormal];
                }
                [btn setBackgroundImage:[UIImage imageNamed:@"drama_pressed"] forState:UIControlStateHighlighted];
                [btn setTitleColor:CMConstants.grayColor forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor colorWithRed:55/255.0 green:100/255.0 blue:158/255.0 alpha:1] forState:UIControlStateHighlighted];
                [btn addTarget:self action:@selector(dramaPlay:)forControlEvents:UIControlEventTouchUpInside];
                [episodeView addSubview:btn];
            }
        }
        if(nextBtn == nil){
            nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [nextBtn setTitle:[NSString stringWithFormat:@"后%i集", (int)fmin(20, totalEpisodeNumber - (episodePageNumber+1)*20)] forState:UIControlStateNormal];
            [nextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [nextBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 60, 0, 5)];
            [nextBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
            nextBtn.titleLabel.font = [UIFont systemFontOfSize:13];
            [nextBtn setTitleColor:CMConstants.grayColor forState:UIControlStateNormal];
            [nextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
            [nextBtn setImage:[UIImage imageNamed:@"right"] forState:UIControlStateNormal];
            [nextBtn addTarget:self action:@selector(next20Epi:) forControlEvents:UIControlEventTouchUpInside];
            nextBtn.tag = 9011;
            [self.bgScrollView addSubview:nextBtn];
        }
        
        if(previousBtn == nil){
            previousBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [previousBtn setTitle:@"前20集" forState:UIControlStateNormal];
            [previousBtn setImage:[UIImage imageNamed:@"left"] forState:UIControlStateNormal];
            previousBtn.titleLabel.font = [UIFont systemFontOfSize:13];
            [previousBtn setTitleColor:CMConstants.grayColor forState:UIControlStateNormal];
            [previousBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 60)];
            [previousBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            [previousBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
            [previousBtn addTarget:self action:@selector(next20Epi:) forControlEvents:UIControlEventTouchUpInside];
            previousBtn.tag = 9012;
            [previousBtn setHidden:YES];
            [self.bgScrollView addSubview:previousBtn];
        }
        if(totalEpisodeNumber <= EPISODE_NUMBER_IN_ROW * 4){
            [nextBtn setHidden:YES];
            [previousBtn setHidden:YES];
        }
    }
    [self relocateComment];
}

- (void)relocateComment
{
    UIButton *lastBtnInPage = (UIButton *)[episodeView viewWithTag:fmin((episodePageNumber+1) * EPISODE_NUMBER_IN_ROW * 4, totalEpisodeNumber)];
    
    nextBtn.frame = CGRectMake(LEFT_WIDTH + 350, episodeView.frame.origin.y + lastBtnInPage.frame.origin.y + lastBtnInPage.frame.size.height , 80, 30);
    previousBtn.frame = CGRectMake(LEFT_WIDTH, episodeView.frame.origin.y + lastBtnInPage.frame.origin.y + lastBtnInPage.frame.size.height, 80, 30);
    
    int positionY = previousBtn.frame.origin.y + 10;
    if([@"1" isEqualToString:[AppDelegate instance].playBtnSuppressed]){
        positionY = episodeView.frame.origin.y;
    }
    if(topics.count > 0){
        self.relatedImage.frame = CGRectMake(LEFT_WIDTH, positionY + 30, 80, 20);
        self.relatedImage.image = [UIImage imageNamed:@"morelists_title1"];
        if(topicListViewController == nil){
            topicListViewController = [[SublistViewController alloc]initWithStyle:UITableViewStylePlain];
            topicListViewController.listData = topics;
            topicListViewController.videoDelegate = self;
            [self addChildViewController:topicListViewController];
            [self.bgScrollView addSubview:topicListViewController.view];
        }
        topicListViewController.view.frame = CGRectMake(LEFT_WIDTH, positionY + 60, 430, (topics.count > 5 ? 5 : topics.count)*30);
        positionY = topicListViewController.view.frame.origin.y + (topics.count > 5 ? 5 : topics.count)*30;
    }
    
    int totalCommentNum = [[video objectForKey:@"total_comment_number"] integerValue];
    self.commentImage.frame = CGRectMake(LEFT_WIDTH, positionY + 30, 74, 19);
    self.commentImage.image = [UIImage imageNamed:@"comment_title"];
    
    self.numberLabel.frame = CGRectMake(139, positionY + 30, 100, 18);
    self.numberLabel.textColor = CMConstants.grayColor;
    self.numberLabel.text = [NSString stringWithFormat:@"(%i条)", totalCommentNum];
    
    self.commentBtn.frame = CGRectMake(405, positionY + 27, 66, 26);
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
    commentListViewController.listData = commentArray;
    [commentListViewController.tableView reloadData];
    commentListViewController.view.frame = CGRectMake(LEFT_WIDTH, positionY + 60, 430, commentListViewController.tableHeight);
    
    [self.bgScrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+episodeView.frame.size.height + commentListViewController.tableHeight+ 300 + increasePositionY +  (topics.count > 5 ? 5 : topics.count)*30)];
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
                    increasePositionY = introContentHeight - 80;
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
    [self.bgScrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+episodeView.frame.size.height + commentListViewController.tableHeight+ 300 + increasePositionY +  (topics.count > 5 ? 5 : topics.count)*30)];
    commentListViewController.view.frame = CGRectMake(LEFT_WIDTH, commentListViewController.view.frame.origin.y, 430, tableHeight);
}

- (void)clearLastBtnImage
{
    id lastNumObj = [[CacheUtility sharedCache]loadFromCache:[NSString stringWithFormat:@"drama_epi_%@", self.prodId]];
    int lastNum = -1;
    if(lastNumObj != nil){
        lastNum = [lastNumObj integerValue];
    }
    UIButton *lastbtn = (UIButton *)[episodeView viewWithTag:lastNum];
    [lastbtn setBackgroundImage:[UIImage imageNamed:@"drama"] forState:UIControlStateNormal];
}

- (void)dramaPlay:(id)sender
{
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([hostReach currentReachabilityStatus] == NotReachable) {
        [UIUtility showNetWorkError:self.view];
        return;
    }
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

- (NSString *)getVideoAddress:(NSInteger)num
{
    NSString *videoUrl = nil;
    if(num-1 < 0 || num-1 >=episodeArray.count){
        return nil;
    }
    NSArray *videoUrlArray = [[episodeArray objectAtIndex:num-1] objectForKey:@"down_urls"];
    if(videoUrlArray.count > 0){
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
    }
    return videoUrl;
}

- (void)willPlayVideo:(NSInteger)num
{
    [[CacheUtility sharedCache]putInCache:[NSString stringWithFormat:@"drama_epi_%@", self.prodId] result:[NSNumber numberWithInt:num]];
    NSString *videoUrl = [self getVideoAddress:num];
    if(videoUrl == nil){
        [self gotoWebsite:num];
    } else {
        MediaPlayerViewController *viewController = [[MediaPlayerViewController alloc]initWithNibName:@"MediaPlayerViewController" bundle:nil];
        viewController.videoUrl = videoUrl;
        viewController.prodId = self.prodId;
        viewController.dramaDetailViewControllerDelegate = self;
        viewController.type = 2;
        viewController.currentNum = num;
        viewController.name = [video objectForKey:@"name"];
        viewController.subname = [NSString stringWithFormat:@"%i", num];
        [[AppDelegate instance].rootViewController pesentMyModalView:viewController];
    }
}

- (void)playNextEpisode:(int)currentNum
{
    if(currentNum <=0 || currentNum >=episodeArray.count){
        return;
    }
    id lastNumObj = [[CacheUtility sharedCache]loadFromCache:[NSString stringWithFormat:@"drama_epi_%@", self.prodId]];
    int lastNum = -1;
    if(lastNumObj != nil){
        lastNum = [lastNumObj integerValue];
    }
    
    UIButton *btn = (UIButton *)[episodeView viewWithTag:lastNum];
    [btn setBackgroundImage:[UIImage imageNamed:@"drama"] forState:UIControlStateNormal];
    
    UIButton *nextEpiBtn = (UIButton *)[episodeView viewWithTag:lastNum+1];
    [nextEpiBtn setBackgroundImage:[UIImage imageNamed:@"drama_watched"] forState:UIControlStateNormal];
    [self willPlayVideo:currentNum+1];
}

- (void)gotoWebsite:(NSInteger)num
{
    ProgramViewController *viewController = [[ProgramViewController alloc]initWithNibName:@"ProgramViewController" bundle:nil];
    NSString *url = nil;
    NSArray *urlArray = [[episodeArray objectAtIndex:num-1] objectForKey:@"video_urls"];
    if (urlArray.count > 0) {
        url = [[urlArray objectAtIndex:0] objectForKey:@"url"];
    }
    if(url == nil){
        url = [[[[episodeArray objectAtIndex:0] objectForKey:@"video_urls"] objectAtIndex:0] objectForKey:@"url"];
    }
    viewController.prodId = self.prodId;
    viewController.programUrl = url;
    viewController.title = [video objectForKey:@"name"];
    viewController.type = 2;
    viewController.subname = [NSString stringWithFormat:@"%i", num];
    [[AppDelegate instance].rootViewController pesentMyModalView:[[UINavigationController alloc]initWithRootViewController:viewController]];
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
            [[NSNotificationCenter defaultCenter] postNotificationName:PERSONAL_VIEW_REFRESH object:nil];
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
            [[AppDelegate instance].rootViewController showFailureModalView:1.5];
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
    [[AppDelegate instance].rootViewController showDramaDownloadView:self.prodId title:[video objectForKey:@"name"] totalNumber:totalEpisodeNumber];
}

- (BOOL)downloadDrama:(int)num
{
    NSString *query = [NSString stringWithFormat:@"WHERE item_id = '%@'", self.prodId];
    DownloadItem *item = (DownloadItem *)[DownloadItem findFirstByCriteria:query];
    if (item == nil) {
        BOOL success = [self addSubdownloadItem:num];
        if(success){
            [self addDownloadItem:num];
            return YES;
        } else {
            return NO;
        }
    } else {
        NSString *subquery = [NSString stringWithFormat:@"WHERE item_id = '%@' and subitem_id = '%@'", self.prodId, [NSString stringWithFormat:@"%i", num]];
        SubdownloadItem *subitem = (SubdownloadItem *)[SubdownloadItem findFirstByCriteria:subquery];
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
    [item save];
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
    subitem.fileName = [NSString stringWithFormat:@"%@_%i%@", self.prodId, num, @".mp4"];
    [self getDownloadUrls:num-1];
    if(downloadUrls.count > 0){
        subitem.url = [downloadUrls objectAtIndex:0];
        //        subitem.url = @"http://api.joyplus.tv/joyplus-service/video/t.mp4";
        [subitem save];
        [[AppDelegate instance] addToDownloaderArray:subitem];
        [self updateBadgeIcon];
        return YES;
    } else {
        return NO;
    }
}


@end
