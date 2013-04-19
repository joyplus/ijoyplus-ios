//
//  MovieDetailViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-20.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "ShowDetailViewController.h"
#import "CommonHeader.h"
#import "CommentListViewController.h"
#import "DownloadUrlFinder.h"
#import <Parse/Parse.h>
#define DEFAULT_POSOTION_Y 530

@interface ShowDetailViewController (){
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
@synthesize expectbtn;
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    commentListViewController = nil;
    introBtn = nil;
    tapGesture = nil;
    showListView = nil;
    [self setBgScrollView:nil];
    [self setPlaceholderImage:nil];
    [self setFilmImage:nil];
    [self setTitleLabel:nil];
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
    [self setPreviousShowBtn:nil];
    [self setNextShowBtn:nil];
    [self setDownloadBtn:nil];
    [self setReportLabel:nil];
    [self setShareLabel:nil];
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
    
    self.type = 3;
    umengPageName = SHOW_DETAIL;
    
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
    self.titleLabel.textColor = CMConstants.textColor;
    self.actorLabel.frame = CGRectMake(270, 140, 80, 15);
    self.actorLabel.textColor = CMConstants.grayColor;
    self.actorName1Label.frame = CGRectMake(350, 140, 140, 15);
    self.actorName1Label.textColor = CMConstants.grayColor;
    //    self.actorName2Label.frame = CGRectMake(345, 235, 100, 15);
    //    self.actorName2Label.textColor = CMConstants.grayColor;
    //    self.actorName3Label.frame = CGRectMake(345, 260, 100, 15);
    //    self.actorName3Label.textColor = CMConstants.grayColor;
    self.playLabel.frame = CGRectMake(270, 170, 80, 15);
    self.playLabel.textColor = CMConstants.grayColor;
    self.playTimeLabel.frame = CGRectMake(310, 170, 100, 15);
    self.playTimeLabel.textColor = CMConstants.grayColor;
    self.regionLabel.frame = CGRectMake(270, 200, 50, 15);
    self.regionLabel.textColor = CMConstants.grayColor;
    self.regionNameLabel.frame = CGRectMake(310, 200, 100, 15);
    self.regionNameLabel.textColor = CMConstants.grayColor;
    
    self.playBtn.frame = CGRectMake(260, 280, 100, 50);
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
    
    self.downloadBtn.frame = CGRectMake(374, 280, 100, 50);
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
    
    self.introImage.frame = CGRectMake(LEFT_WIDTH, 405, 45, 20);
    self.introImage.image = [UIImage imageNamed:@"brief_title"];
    
    self.introContentTextView.frame = CGRectMake(LEFT_WIDTH, 435, 430, 100);
    self.introContentTextView.textColor = CMConstants.grayColor;
    self.introContentTextView.layer.borderWidth = 1;
    self.introContentTextView.layer.borderColor = CMConstants.tableBorderColor.CGColor;
    tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(introBtnClicked)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self.introContentTextView addGestureRecognizer:tapGesture];
       
    introBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [introBtn setBackgroundImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    introBtn.frame = CGRectMake(LEFT_WIDTH + 415, self.introContentTextView.frame.origin.y + 90, 14, 9);
    [introBtn addTarget:self action:@selector(introBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.bgScrollView addSubview:introBtn];
    
    showListView = [[UIScrollView alloc]initWithFrame:CGRectZero];
    showListView.scrollEnabled = NO;
    showListView.backgroundColor = [UIColor clearColor];
    [showListView setPagingEnabled:YES];
    [self.bgScrollView addSubview:showListView];
    
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
    }
}

- (void)retrieveData
{
    BOOL isReachable = [[AppDelegate instance] performSelector:@selector(isParseReachable)];
    if(!isReachable) {
        [UIUtility showNetWorkError:self.view];
    }
    NSString *key = [NSString stringWithFormat:@"%@%@", @"show", self.prodId];
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
        [self checkCanPlayVideo];
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
    NSString *stars = [[video objectForKey:@"stars"] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.actorName1Label.text = stars;
    
    if (!self.canPlayVideo) {
        self.playBtn.hidden = NO;
        self.expectbtn.hidden = YES;
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

    //在弹出窗口判断视频是否可以下载
//    if(self.mp4DownloadUrls.count > 0 || self.m3u8DownloadUrls.count > 0){
//        NSLog(@"mp4 count: %i", self.mp4DownloadUrls.count);
//        NSLog(@"m3u8 count: %i", self.m3u8DownloadUrls.count);
//    } else {
//        [self.downloadBtn setEnabled:NO];
//        [self.downloadBtn setBackgroundImage:[UIImage imageNamed:@"no_download"] forState:UIControlStateDisabled];
//    }
    
    self.introContentTextView.textColor = CMConstants.grayColor;
    self.introContentTextView.text = [video objectForKey:@"summary"];
    
    [self repositElements:0];
    
    [self updatePageBtnState];
}

- (void)repositElements:(int)increasePositionY
{
    int positionY = DEFAULT_POSOTION_Y + increasePositionY + 15;
        if(episodeArray.count > 5){
            self.previousShowBtn.frame = CGRectMake(LEFT_WIDTH - 22,  positionY, 64, 308.5);
            self.nextShowBtn.frame = CGRectMake(LEFT_WIDTH + 388,  positionY, 64, 308.5);
        }
        showListView.center = CGPointMake(showListView.center.x, positionY + showListView.frame.size.height/2);
        if(!btnAdded){
            btnAdded = YES;
            if(episodeArray.count > 5){
                showListView.frame = CGRectMake(LEFT_WIDTH + 47, positionY, 336.5, 308.5);
                showListView.contentSize = CGSizeMake(ceil(episodeArray.count/5.0) * 336.5, showListView.frame.size.height);
                
                [self.previousShowBtn setBackgroundImage:[UIImage imageNamed:@"tab_left"] forState:UIControlStateNormal];
                [self.previousShowBtn setBackgroundImage:[UIImage imageNamed:@"tab_left_pressed"] forState:UIControlStateHighlighted];
                [self.previousShowBtn setBackgroundImage:[UIImage imageNamed:@"tab_left_disabled"] forState:UIControlStateDisabled];
                [self.previousShowBtn addTarget:self action:@selector(nextShowBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                self.previousShowBtn.tag = 9001;
                
                [self.nextShowBtn setBackgroundImage:[UIImage imageNamed:@"tab_right"] forState:UIControlStateNormal];
                [self.nextShowBtn setBackgroundImage:[UIImage imageNamed:@"tab_right_pressed"] forState:UIControlStateHighlighted];
                [self.nextShowBtn setBackgroundImage:[UIImage imageNamed:@"tab_right_disabled"] forState:UIControlStateDisabled];
                [self.nextShowBtn addTarget:self action:@selector(nextShowBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                self.nextShowBtn.tag = 9002;
                for (int i = 0; i < episodeArray.count; i++) {
                    btnAdded = YES;
                    int pageNum = floor(i/5.0);
                    NSDictionary *item = [episodeArray objectAtIndex:i];
                    UIButton *nameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                    [nameBtn.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
                    nameBtn.tag = i + 1;
                    [nameBtn setFrame:CGRectMake(pageNum*showListView.frame.size.width, (i%5) * (54.5 + 6) + 6, showListView.frame.size.width, 54.5)];
                    NSString *name = [NSString stringWithFormat:@"%@", [item objectForKey:@"name"]];
                    if ([item objectForKey:@"name"] == nil) {
                        name = @"";
                    }
                    [nameBtn setTitle:name forState:UIControlStateNormal];
                    nameBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                    nameBtn.titleLabel.numberOfLines = 2;
                    [nameBtn setBackgroundImage:[UIImage imageNamed:@"tab_show"] forState:UIControlStateNormal];
                    [nameBtn setBackgroundImage:[UIImage imageNamed:@"tab_show_pressed"] forState:UIControlStateHighlighted];
                    nameBtn.titleLabel.font = [UIFont systemFontOfSize:14];
                    [nameBtn setTitleColor:[UIColor colorWithRed:138.0/255.0 green:138.0/255.0 blue:138.0/255.0 alpha:1] forState:UIControlStateNormal];
                    [nameBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
                    [nameBtn addTarget:self action:@selector(nameBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                    nameBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                    [nameBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
                    [showListView addSubview:nameBtn];
                }
            } else {
                [self.previousShowBtn setHidden:YES];
                [self.nextShowBtn setHidden:YES];
                showListView.frame = CGRectMake(LEFT_WIDTH, positionY, 336.5, episodeArray.count * (54.5 + 6));
                showListView.contentSize = showListView.frame.size;
                for(int i = 0; i < episodeArray.count; i++){
                    NSDictionary *item = [episodeArray objectAtIndex:i];
                    UIButton *nameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                    nameBtn.tag = i + 1;
                    nameBtn.frame = CGRectMake(0, i * (54.5 + 6) + 6, showListView.frame.size.width, 54.5);
                    NSString *name = [NSString stringWithFormat:@"%@", [item objectForKey:@"name"]];
                    if ([item objectForKey:@"name"] == nil) {
                        name = @"";
                    }
                    [nameBtn.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
                    [nameBtn setTitle:name forState:UIControlStateNormal];
                    [nameBtn setBackgroundImage:[UIImage imageNamed:@"tab_show"] forState:UIControlStateNormal];
                    [nameBtn setBackgroundImage:[UIImage imageNamed:@"tab_show_pressed"] forState:UIControlStateHighlighted];
                    nameBtn.titleLabel.font = [UIFont systemFontOfSize:14];
                    [nameBtn setTitleColor:[UIColor colorWithRed:138.0/255.0 green:138.0/255.0 blue:138.0/255.0 alpha:1] forState:UIControlStateNormal];
                    [nameBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
                    [nameBtn addTarget:self action:@selector(nameBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                    nameBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                    [nameBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
                    [showListView addSubview:nameBtn];
                }
            }
        }
        positionY = showListView.frame.origin.y + showListView.frame.size.height;
    self.commentImage.frame = CGRectMake(LEFT_WIDTH, positionY + 30, 41, 18);
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
    commentListViewController.view.frame = CGRectMake(LEFT_WIDTH, positionY + 60, 430, commentListViewController.tableHeight);
    
    [self.bgScrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+commentListViewController.tableHeight+5 * 30 + increasePositionY)];
    //    commentListViewController.view.frame = CGRectMake(LEFT_WIDTH, positionY + 70, 425, commentListViewController.tableHeight);
}

- (void)nameBtnClicked:(UIButton *)btn{
    self.subname = btn.titleLabel.text;
    [[CacheUtility sharedCache]putInCache:[NSString stringWithFormat:@"show_epi_%@", self.prodId] result:btn.titleLabel.text];
    [super playVideo:btn.tag - 1];
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
    [showListView setContentOffset:CGPointMake(336.5*showPageNumber, 0) animated:YES];
}

- (void)updatePageBtnState
{
    if(showPageNumber > 0 && showPageNumber < ceil(episodeArray.count / 5.0)-1){
        [self.previousShowBtn setEnabled:YES];
        [self.nextShowBtn setEnabled:YES];
    }
    if(showPageNumber == 0){
        [self.previousShowBtn setEnabled:NO];
        [self.nextShowBtn setEnabled:YES];
    }
    if(showPageNumber == ceil(episodeArray.count / 5.0)-1){
        [self.previousShowBtn setEnabled:YES];
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
    [self.bgScrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+tableHeight+5 * 30)];
    commentListViewController.view.frame = CGRectMake(LEFT_WIDTH, commentListViewController.view.frame.origin.y, 430, tableHeight);
    if (tableHeight > 30) {
        [self.commentImage setHidden:NO];
        [commentListViewController.view setHidden:NO];
    }
}

- (void)playVideo
{
    NSString *title = [[CacheUtility sharedCache]loadFromCache:[NSString stringWithFormat:@"show_epi_%@", self.prodId]];
    int lastNum = 0;
    if (title) {
        for (int i = 0; i < episodeArray.count; i++) {
            UIButton *tempbtn = (UIButton *)[showListView viewWithTag:i+1];
            if ([tempbtn.titleLabel.text isEqualToString:title]) {
                lastNum = i;
                break;
            }
        }
        self.subname = title;
    } else {
        UIButton *btn = (UIButton *)[showListView viewWithTag:1];
        self.subname = btn.titleLabel.text;
        if (self.subname) {
            [[CacheUtility sharedCache]putInCache:[NSString stringWithFormat:@"show_epi_%@", self.prodId] result:btn.titleLabel.text];
        }
    }
    [super playVideo:lastNum];
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
//          [[NSNotificationCenter defaultCenter] postNotificationName:PERSONAL_VIEW_REFRESH object:nil];
            [[AppDelegate instance].rootViewController showSuccessModalView:1.5];
            int dingNum = [[video objectForKey:@"support_num"] intValue] + 1;
            if (dingNum >= 1000) {
                self.dingNumberLabel.text = [NSString stringWithFormat:@"顶(%.1fK)", dingNum/1000.0];
            } else {
                self.dingNumberLabel.text = [NSString stringWithFormat:@"顶(%i)", dingNum];
            };
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
//          [[NSNotificationCenter defaultCenter] postNotificationName:PERSONAL_VIEW_REFRESH object:nil];
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
    [[AppDelegate instance].rootViewController showShowDownloadView:self.prodId title:[video objectForKey:@"name"] episodeArray:episodeArray];
}

- (BOOL)downloadShow:(int)num
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
        NSString *subquery = [NSString stringWithFormat:@"WHERE itemId = '%@' and subitemId = '%@'", self.prodId, [StringUtility md5:[NSString stringWithFormat:@"%@", [[episodeArray objectAtIndex:num] objectForKey:@"name"]]]];
        SubdownloadItem *subitem = (SubdownloadItem *)[DatabaseManager findFirstByCriteria:SubdownloadItem.class queryString:subquery];
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
    subitem.name = [[episodeArray objectAtIndex:num] objectForKey:@"name"];
    subitem.percentage = 0;
    subitem.type = 3;
    subitem.subitemId = [StringUtility md5:[NSString stringWithFormat:@"%@", [[episodeArray objectAtIndex:num] objectForKey:@"name"]]];
    subitem.downloadStatus = @"waiting";
    [self getDownloadUrls:num];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc]initWithCapacity:5];
    [tempArray addObjectsFromArray:self.mp4DownloadUrls];
    [tempArray addObjectsFromArray:self.m3u8DownloadUrls];
    subitem.urlArray = tempArray;
    
    if(subitem.urlArray.count > 0){
        if (self.mp4DownloadUrls.count > 0) {
            subitem.downloadType = @"mp4";
            subitem.fileName = [NSString stringWithFormat:@"%@_%@.mp4", self.prodId, subitem.subitemId];
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
