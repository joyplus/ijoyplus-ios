//
//  MovieDetailViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-20.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "ShowDetailViewController.h"
#import "CommonHeader.h"
#import "ProgramViewController.h"
#import "MediaPlayerViewController.h"
#import "CommentListViewController.h"

#define DEFAULT_POSOTION_Y 585

@interface ShowDetailViewController (){
    NSMutableArray *commentArray;
    CommentListViewController *commentListViewController;
    UIButton *introBtn;
    float introContentHeight;
    BOOL introExpand;
    UITapGestureRecognizer *tapGesture;
    int showPageNumber;
    BOOL btnAdded;
    UIScrollView *showListView;
}

@end

@implementation ShowDetailViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [commentArray removeAllObjects];
    commentArray = nil;
    commentListViewController = nil;
    introBtn = nil;
    tapGesture = nil;
    showListView = nil;
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
    [self setPreviousShowBtn:nil];
    [self setNextShowBtn:nil];
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
    
    self.bgScrollView.frame = CGRectMake(0, 260, self.view.frame.size.width, self.view.frame.size.height);
    [self.bgScrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height*1.5)];
    
    self.closeBtn.frame = CGRectMake(465, 20, 40, 42);
    [self.closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [self.closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
    [self.closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.filmImage.frame = CGRectMake(LEFT_WIDTH+5, 84, 205, 300);
    self.filmImage.image = [UIImage imageNamed:@"video_placeholder"];
    
    self.placeholderImage.frame = CGRectMake(LEFT_WIDTH, 78, 217, 312);
    self.placeholderImage.image = [UIImage imageNamed:@"movie_frame"];
    
    self.playRoundBtn.frame = CGRectMake(0, 0, 63, 63);
    [self.playRoundBtn setBackgroundImage:[UIImage imageNamed:@"play_btn"] forState:UIControlStateNormal];
    [self.playRoundBtn setBackgroundImage:[UIImage imageNamed:@"play_btn"] forState:UIControlStateHighlighted];
    [self.playRoundBtn addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
    
    self.playRoundBtn.center = self.filmImage.center;
    
    self.titleImage.frame = CGRectMake(LEFT_WIDTH, 35, 62, 26);
    self.titleImage.image = [UIImage imageNamed:@"detail_title"];
    
    self.titleLabel.frame = CGRectMake(278, 85, 200, 20);
    self.titleLabel.font = CMConstants.titleFont;
    
    self.scoreLabel.frame = CGRectMake(280, 110, 50, 20);
    self.doulanLogo.frame = CGRectMake(325, 113, 15, 15);
    self.doulanLogo.image = [UIImage imageNamed:@"douban"];
    
    self.playBtn.frame = CGRectMake(280, 120, 185, 40);
    [self.playBtn setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [self.playBtn setBackgroundImage:[UIImage imageNamed:@"play_pressed"] forState:UIControlStateHighlighted];
    [self.playBtn addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
    
    self.actorLabel.frame = CGRectMake(280, 180, 80, 15);
    self.actorLabel.textColor = CMConstants.grayColor;
    self.actorName1Label.frame = CGRectMake(355, 180, 140, 15);
    self.actorName1Label.textColor = CMConstants.grayColor;
    //    self.actorName2Label.frame = CGRectMake(345, 235, 100, 15);
    //    self.actorName2Label.textColor = CMConstants.grayColor;
    //    self.actorName3Label.frame = CGRectMake(345, 260, 100, 15);
    //    self.actorName3Label.textColor = CMConstants.grayColor;
    self.playLabel.frame = CGRectMake(280, 210, 80, 15);
    self.playLabel.textColor = CMConstants.grayColor;
    self.playTimeLabel.frame = CGRectMake(325, 210, 100, 15);
    self.playTimeLabel.textColor = CMConstants.grayColor;
    self.regionLabel.frame = CGRectMake(280, 240, 50, 15);
    self.regionLabel.textColor = CMConstants.grayColor;
    self.regionNameLabel.frame = CGRectMake(325, 240, 100, 15);
    self.regionNameLabel.textColor = CMConstants.grayColor;
    
    self.dingNumberImage.frame = CGRectMake(280, 360, 75, 24);
    self.dingNumberImage.image = [UIImage imageNamed:@"pushinguser"];
    self.dingNumberLabel.frame = CGRectMake(295, 360, 40, 24);
    
    self.collectioNumber.frame = CGRectMake(380, 360, 84, 24);
    self.collectioNumber.image = [UIImage imageNamed:@"collectinguser"];
    self.collectionNumberLabel.frame = CGRectMake(395, 360, 40, 24);
    
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
    
    self.downloadBtn.frame = CGRectMake(LEFT_WIDTH + 240, 405, 76, 34);
    [self.downloadBtn setBackgroundImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
    [self.downloadBtn setBackgroundImage:[UIImage imageNamed:@"download_pressed"] forState:UIControlStateHighlighted];
    [self.downloadBtn addTarget:self action:@selector(downloadBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    //    self.addListBtn.frame = CGRectMake(290, 405, 104, 34);
    //    [self.addListBtn setBackgroundImage:[UIImage imageNamed:@"listing"] forState:UIControlStateNormal];
    //    [self.addListBtn setBackgroundImage:[UIImage imageNamed:@"listing_pressed"] forState:UIControlStateHighlighted];
    //    [self.addListBtn addTarget:self action:@selector(addListBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
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
    introBtn.frame = CGRectMake(LEFT_WIDTH + 413, self.introContentTextView.frame.origin.y + 80, 14, 9);
    [introBtn addTarget:self action:@selector(introBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.bgScrollView addSubview:introBtn];
    
    showListView = [[UIScrollView alloc]initWithFrame:CGRectZero];
    showListView.scrollEnabled = NO;
    showListView.backgroundColor = [UIColor clearColor];
    [showListView setPagingEnabled:YES];
    [self.bgScrollView addSubview:showListView];
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
                [self repositElements:introContentHeight - 100];
            } completion:^(BOOL finished) {
            }];
        } else {
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
                [self.introContentTextView setFrame:CGRectMake(self.introContentTextView.frame.origin.x, self.introContentTextView.frame.origin.y, self.introContentTextView.frame.size.width, 100)];
                self.introBgImage.frame = CGRectMake(LEFT_WIDTH, self.introBgImage.frame.origin.y, self.introBgImage.frame.size.width, 100);
                [introBtn setBackgroundImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
                introBtn.frame = CGRectMake(introBtn.frame.origin.x, self.introContentTextView.frame.origin.y + 80, introBtn.frame.size.width, introBtn.frame.size.height);
                [self repositElements:0];
            } completion:^(BOOL finished) {
                
            }];
        }
    } else {
        [introBtn removeFromSuperview];
        introBtn = nil;
    }
}

- (void)retrieveData
{
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([hostReach currentReachabilityStatus] == NotReachable) {
        [UIUtility showNetWorkError:self.view];
    }
    NSString *key = [NSString stringWithFormat:@"%@%@", @"show", self.prodId];
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

- (void)calculateIntroContentHeight
{
    self.introContentTextView.text = [video objectForKey:@"summary"];
    introContentHeight = self.introContentTextView.contentSize.height;
}

- (void)parseData:(id)result
{
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        NSString *key = [NSString stringWithFormat:@"%@%@", @"show", self.prodId];
        [[CacheUtility sharedCache] putInCache:key result:result];
        video = (NSDictionary *)[result objectForKey:@"show"];
        episodeArray = [video objectForKey:@"episodes"];
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
    NSString *stars = [[video objectForKey:@"stars"] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
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
    
    [self repositElements:0];
    
    [self updatePageBtnState];
}

- (void)repositElements:(int)increasePositionY
{
    int positionY = DEFAULT_POSOTION_Y + increasePositionY + 15;
    if(![@"1" isEqualToString:[AppDelegate instance].playBtnSuppressed]){
        if(episodeArray.count > 5){
            self.previousShowBtn.frame = CGRectMake(LEFT_WIDTH,  positionY, 32, 161);
            self.nextShowBtn.frame = CGRectMake(LEFT_WIDTH + 390 + 10,  positionY, 32, 161);
        }
        showListView.center = CGPointMake(showListView.center.x, positionY + showListView.frame.size.height/2);
        if(!btnAdded){
            btnAdded = YES;
            if(episodeArray.count > 5){
                showListView.frame = CGRectMake(LEFT_WIDTH + 40, positionY, 350, 5 * 32);
                showListView.contentSize = showListView.frame.size;
                
                [self.previousShowBtn setBackgroundImage:[UIImage imageNamed:@"tab_left"] forState:UIControlStateNormal];
                [self.previousShowBtn setBackgroundImage:[UIImage imageNamed:@"tab_left_pressed"] forState:UIControlStateHighlighted];
                [self.previousShowBtn setBackgroundImage:[UIImage imageNamed:@"tab_left_disable"] forState:UIControlStateDisabled];
                [self.previousShowBtn addTarget:self action:@selector(nextShowBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                self.previousShowBtn.tag = 9001;
                
                [self.nextShowBtn setBackgroundImage:[UIImage imageNamed:@"tab_right"] forState:UIControlStateNormal];
                [self.nextShowBtn setBackgroundImage:[UIImage imageNamed:@"tab_right_pressed"] forState:UIControlStateHighlighted];
                [self.nextShowBtn setBackgroundImage:[UIImage imageNamed:@"tab_right_disable"] forState:UIControlStateDisabled];
                [self.nextShowBtn addTarget:self action:@selector(nextShowBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                self.nextShowBtn.tag = 9002;
                for (int i = 0; i < episodeArray.count; i++) {
                    btnAdded = YES;
                    int pageNum = floor(i/5.0);
                    NSDictionary *item = [episodeArray objectAtIndex:i];
                    UIButton *nameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                    nameBtn.tag = i + 1;
                    [nameBtn setFrame:CGRectMake(pageNum*showListView.frame.size.width, (i%5) * 32, showListView.frame.size.width, 30)];
                    NSString *name = [NSString stringWithFormat:@"%@", [item objectForKey:@"name"]];
                    if ([item objectForKey:@"name"] == nil) {
                        name = @"";
                    }
                    [nameBtn setTitle:name forState:UIControlStateNormal];
                    [nameBtn setBackgroundImage:[UIImage imageNamed:@"tab_show"] forState:UIControlStateNormal];
                    [nameBtn setBackgroundImage:[UIImage imageNamed:@"tab_show_pressed"] forState:UIControlStateHighlighted];
                    nameBtn.titleLabel.font = [UIFont systemFontOfSize:14];
                    [nameBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    [nameBtn setTitleColor:CMConstants.grayColor forState:UIControlStateHighlighted];
                    [nameBtn addTarget:self action:@selector(nameBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                    nameBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                    [nameBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
                    [showListView addSubview:nameBtn];
                }
            } else {
                [self.previousShowBtn setHidden:YES];
                [self.nextShowBtn setHidden:YES];
                showListView.frame = CGRectMake(LEFT_WIDTH, positionY, 430, episodeArray.count * 32);
                showListView.contentSize = showListView.frame.size;
                for(int i = 0; i < episodeArray.count; i++){
                    NSDictionary *item = [episodeArray objectAtIndex:i];
                    UIButton *nameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                    nameBtn.tag = i + 1;
                    nameBtn.frame = CGRectMake(0, i * 32, showListView.frame.size.width, 30);
                    NSString *name = [NSString stringWithFormat:@"%@", [item objectForKey:@"name"]];
                    if ([item objectForKey:@"name"] == nil) {
                        name = @"";
                    }
                    [nameBtn setTitle:name forState:UIControlStateNormal];
                    [nameBtn setBackgroundImage:[UIImage imageNamed:@"tab_show"] forState:UIControlStateNormal];
                    [nameBtn setBackgroundImage:[UIImage imageNamed:@"tab_show_pressed"] forState:UIControlStateHighlighted];
                    nameBtn.titleLabel.font = [UIFont systemFontOfSize:14];
                    [nameBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    [nameBtn setTitleColor:CMConstants.grayColor forState:UIControlStateHighlighted];
                    [nameBtn addTarget:self action:@selector(nameBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                    nameBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                    [nameBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
                    [showListView addSubview:nameBtn];
                }
            }
        }
        positionY = showListView.frame.origin.y + showListView.frame.size.height;
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
    
    [self.bgScrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+commentListViewController.tableHeight+5 * 30 + 200 + increasePositionY)];
    //    commentListViewController.view.frame = CGRectMake(LEFT_WIDTH, positionY + 70, 425, commentListViewController.tableHeight);
}

- (void)nameBtnClicked:(UIButton *)btn{
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([hostReach currentReachabilityStatus] == NotReachable) {
        [UIUtility showNetWorkError:self.view];
        return;
    }
    [self playVideo:btn.tag - 1];
}

- (NSMutableArray *)getEpisodes
{
    NSMutableArray *tempArray = [[NSMutableArray alloc]initWithCapacity:5];
    for(int i = showPageNumber * 5; i <  showPageNumber * 5 + 5; i++){
        if(i < episodeArray.count){
            [tempArray addObject: [episodeArray objectAtIndex:i]];
        } else {
            [tempArray addObject:[[NSDictionary alloc]init]];
        }
    }
    return tempArray;
}

- (void)nextShowBtnClicked:(UIButton *)btn
{
    if(btn.tag == 9001){
        showPageNumber --;
    } else{
        showPageNumber ++;
    }
    if(showPageNumber < 0){
        showPageNumber = 0;
    }
    if(showPageNumber > ceil(episodeArray.count / 5.0)-1){
        showPageNumber = ceil(episodeArray.count / 5.0)-1;
    }
    [self updatePageBtnState];
    [showListView setContentOffset:CGPointMake(350*showPageNumber, 0) animated:YES];
}

- (void)updatePageBtnState
{
    if(showPageNumber > 0 && showPageNumber < ceil(episodeArray.count / 5.0)-1){
        [self.previousShowBtn setEnabled:YES];
        [self.nextShowBtn setEnabled:YES];
    }
    if(showPageNumber == 0){
        [self.previousShowBtn setEnabled:NO];
    }
    if(showPageNumber == ceil(episodeArray.count / 5.0)-1){
        [self.nextShowBtn setEnabled:NO];
    }
}

- (void)getTopComments:(int)num
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: self.prodId, @"prod_id", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathProgramView parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSString *key = [NSString stringWithFormat:@"%@%@", @"show", self.prodId];
            [[CacheUtility sharedCache] putInCache:key result:result];
            video = (NSDictionary *)[result objectForKey:@"show"];
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
    [self.bgScrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+tableHeight+5 * 30 + 200)];
    commentListViewController.view.frame = CGRectMake(LEFT_WIDTH, commentListViewController.view.frame.origin.y, 430, tableHeight);
}

- (void)playVideo
{
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [UIUtility showNetWorkError:self.view];
        return;
    }
    [self playVideo:0];
}

- (void)playVideo:(NSInteger)num
{
    if(num < 0 || num >= episodeArray.count){
        return;
    }
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

- (void)willPlayVideo:(NSInteger)num
{
    NSArray *videoUrlArray = [[episodeArray objectAtIndex:num] objectForKey:@"down_urls"];
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
            viewController.prodId = self.prodId;
            viewController.type = 3;
            viewController.name = [video objectForKey:@"name"];
            viewController.subname = [[episodeArray objectAtIndex:num] objectForKey:@"name"];
            [[AppDelegate instance].rootViewController pesentMyModalView:viewController];
        }
    }else {
        [self gotoWebsite:num];
    }
}

- (void)gotoWebsite:(NSInteger)num
{
    ProgramViewController *viewController = [[ProgramViewController alloc]initWithNibName:@"ProgramViewController" bundle:nil];
    NSArray *urlArray = [[episodeArray objectAtIndex:num] objectForKey:@"video_urls"];
    NSString *url = [[urlArray objectAtIndex:0] objectForKey:@"url"];
    if([StringUtility stringIsEmpty:url]){
        url = @"";
    }
    viewController.prodId = self.prodId;
    viewController.programUrl = url;
    viewController.title = [video objectForKey:@"name"];
    viewController.type = 3;
    viewController.subname = [[episodeArray objectAtIndex:num] objectForKey:@"name"];
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
    [AppDelegate instance].rootViewController.videoDetailDelegate = self;
    [[AppDelegate instance].rootViewController showShowDownloadView:self.prodId title:[video objectForKey:@"name"] episodeArray:episodeArray];
}

- (BOOL)downloadShow:(int)num
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
        NSString *subquery = [NSString stringWithFormat:@"WHERE item_id = '%@' and subitem_id = '%@'", self.prodId, [StringUtility md5:[NSString stringWithFormat:@"%@", [[episodeArray objectAtIndex:num] objectForKey:@"name"]]]];
        SubdownloadItem *subitem = (SubdownloadItem *)[SubdownloadItem findFirstByCriteria:subquery];
        if(subitem == nil){
            return [self addSubdownloadItem:num];
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
    item.type = 3;
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
    subitem.name = [[episodeArray objectAtIndex:num] objectForKey:@"name"];
    subitem.percentage = 0;
    subitem.type = 3;
    subitem.subitemId = [StringUtility md5:[NSString stringWithFormat:@"%@", [[episodeArray objectAtIndex:num] objectForKey:@"name"]]];
    subitem.downloadStatus = @"waiting";
    subitem.fileName = [NSString stringWithFormat:@"%@_%@%@", self.prodId, subitem.subitemId, @".mp4"];
    [self getDownloadUrls:num];
    if(downloadUrls.count > 0){
        subitem.url = [downloadUrls objectAtIndex:0];
        [subitem save];
        [[AppDelegate instance] addToDownloaderArray:subitem];
        [self updateBadgeIcon];
        return YES;
    } else {
        return NO;
    }
}


@end
