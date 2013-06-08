  //
//  MovieDetailViewController.m
//  yueshipin
//
//  Created by 08 on 12-12-28.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "IphoneMovieDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "CacheUtility.h"
#import "CMConstants.h"
#import "AppDelegate.h"
#import "ReviewViewController.h"
#import "MBProgressHUD.h"
#import "UIImage+Scale.h"
#import "UIImage+Scale.h"
#import "SendWeiboViewController.h"
#import "ListDetailViewController.h"
#import "ProgramNavigationController.h"
#import "CommonMotheds.h"
#import "FilmReviewDetailView.h"
#import "AppDelegate.h"
#import "UIUtility.h"
#import "DatabaseManager.h"
#import <Parse/Parse.h>

#define REVIEW_VIEW_TAG (11112)

@interface IphoneMovieDetailViewController ()

@end

@implementation IphoneMovieDetailViewController

@synthesize videoInfo = videoInfo_;
@synthesize videoType = videoType_;
@synthesize summary = summary_;
@synthesize commentArray =commentArray_;
@synthesize relevantList = relevantList_;
@synthesize summaryBg = summaryBg_;
@synthesize summaryLabel = summaryLabel_;
@synthesize moreBtn = moreBtn_;
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
    
    UIImageView *backGround = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_common.png"]];
    backGround.frame = CGRectMake(0, 0, 320, 480);
    self.tableView.backgroundView = backGround;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 55, 44);
    backButton.backgroundColor = [UIColor clearColor];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"back_f.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    self.navigationItem.hidesBackButton = YES;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    NSString *titleStr = [self.infoDic objectForKey:@"prod_name"];
    if (titleStr == nil) {
        titleStr = [self.infoDic objectForKey:@"content_name"];
    }
    if (titleStr == nil) {
        titleStr = [self.infoDic objectForKey:@"name"];
    }
    self.title = @"电影";
    name_ = titleStr;
    type_ = 1;
    
    isLoaded_ = NO;
    
    commentArray_ = [NSMutableArray arrayWithCapacity:10];
    [self loadData];
    [self loadComments];
    
//    favCount_ = [[self.infoDic objectForKey:@"favority_num" ] intValue];
//    supportCount_ = [[self.infoDic objectForKey:@"support_num" ] intValue];
    
    summaryBg_ = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"summryBg.png"] stretchableImageWithLeftCapWidth:50 topCapHeight:50 ]];
    summaryBg_.frame = CGRectMake(14, 35, 292, 90);
    summaryLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(28, 35, 264,90)];
    summaryLabel_.textColor = [UIColor grayColor];
    summaryLabel_.backgroundColor = [UIColor clearColor];
    summaryLabel_.numberOfLines = 0;
    summaryLabel_.lineBreakMode = UILineBreakModeWordWrap;
    summaryLabel_.font = [UIFont systemFontOfSize:13];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(more)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    summaryLabel_.userInteractionEnabled = YES;
    summaryLabel_.lineBreakMode = NSLineBreakByTruncatingTail;
    [summaryLabel_ addGestureRecognizer:tapGesture];
    moreBtn_ = [UIButton buttonWithType:UIButtonTypeCustom];
    moreBtn_.backgroundColor = [UIColor clearColor];
    moreBtn_.frame = CGRectMake(288, 90, 18, 14);
    [moreBtn_ setBackgroundImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    [moreBtn_ setBackgroundImage:[UIImage imageNamed:@"more_off"] forState:UIControlStateSelected];
    [moreBtn_ addTarget:self action:@selector(more:) forControlEvents:UIControlEventTouchUpInside];

}

-(void)viewWillAppear:(BOOL)animated{
  [CommonMotheds showNetworkDisAbledAlert:self.view];
}
-(void)back:(id)sender{
    if (!isNotification_) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
    
        [self dismissModalViewControllerAnimated:YES];
    }

}

-(void)loadData{
     MBProgressHUD *tempHUD;
    NSString *itemId = [self.infoDic objectForKey:@"prod_id"];
    if (itemId == nil) {
        itemId = [self.infoDic objectForKey:@"content_id"];
    }
    if (itemId == nil) {
         itemId = [self.infoDic objectForKey:@"id"];
    }
    
    prodId_ = itemId;
    NSString *key = [NSString stringWithFormat:@"%@%@", @"movie",itemId ];
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:key];
    if(cacheResult != nil){
        isLoaded_ = YES;
        videoInfo_ = (NSDictionary *)[cacheResult objectForKey:@"movie"];
        episodesArr_ = [videoInfo_ objectForKey:@"episodes"];
        [self checkCanPlayVideo];
        summary_ = [videoInfo_ objectForKey:@"summary"];
        relevantList_ = [cacheResult objectForKey:@"topics"];
        favCount_ = [[videoInfo_ objectForKey:@"favority_num"] integerValue];
        supportCount_ = [[videoInfo_ objectForKey:@"support_num"] integerValue];
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:0.0f];
    }
    else{
        
        if(tempHUD == nil){
            tempHUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:tempHUD];
            tempHUD.labelText = @"加载中...";
            tempHUD.opacity = 0.5;
            [tempHUD show:YES];
        }
    }
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: prodId_, @"prod_id", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathProgramView parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        [[CacheUtility sharedCache] putInCache:key result:result];
        isLoaded_ = YES;
        
        videoInfo_ = (NSDictionary *)[result objectForKey:@"movie"];
        if (isNotification_) {
            [self notificationData];
        }
        else{
            self.infoDic = videoInfo_;

        }
        episodesArr_ = [videoInfo_ objectForKey:@"episodes"];
        [self checkCanPlayVideo];
        summary_ = [videoInfo_ objectForKey:@"summary"];
        relevantList_ = [result objectForKey:@"topics"];
        [tempHUD hide:YES];
        favCount_ = [[videoInfo_ objectForKey:@"favority_num"] integerValue];
        supportCount_ = [[videoInfo_ objectForKey:@"support_num"] integerValue];
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:0.0f];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        [tempHUD hide:YES];
        [UIUtility showDetailError:self.view error:error];
    }];
    
    NSString *reviews_key = [NSString stringWithFormat:@"%@%@reviews", @"movie",itemId ];
    id reviewsCacheResult = [[CacheUtility sharedCache] loadFromCache:reviews_key];
    if (reviewsCacheResult != nil) {
         arrReviewData_ = [reviewsCacheResult objectForKey:@"reviews"];
         [self performSelector:@selector(loadTable) withObject:nil afterDelay:0.0f];
    }
    NSDictionary * reqData = [NSDictionary dictionaryWithObjectsAndKeys:prodId_, @"prod_id",@"1",@"page_num",@"3",@"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathProgramReviews
                                    parameters:reqData
                                       success:^(AFHTTPRequestOperation *operation, id result)
     {
         [[CacheUtility sharedCache] putInCache:reviews_key result:result];
         arrReviewData_ = [result objectForKey:@"reviews"];
         [self.tableView reloadData];
         
     }failure:^(__unused AFHTTPRequestOperation *operation, NSError *error)
     {
         
     }];
    
}
-(void)notificationData{
    infoDic_ = videoInfo_;
    name_ = [infoDic_ objectForKey:@"name"];
    [self loadTable];
}
-(void)loadComments{
   
    NSString *itemId = [self.infoDic objectForKey:@"prod_id"];
    if (itemId == nil) {
        itemId = [self.infoDic objectForKey:@"content_id"];
    }
    if (itemId == nil) {
        itemId = [self.infoDic objectForKey:@"id"];
    }
    int pageNum = ceil(commentArray_.count / 10.0)+1;
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: itemId, @"prod_id",[NSNumber numberWithInt:pageNum], @"page_num", [NSNumber numberWithInt:10], @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathProgramComments parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *comments = (NSArray *)[result objectForKey:@"comments"];
            if(comments != nil && comments.count > 0){
                [commentArray_ addObjectsFromArray:comments];
                
            }
        }
       [self performSelector:@selector(loadTable) withObject:nil afterDelay:0.0f];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
       [self performSelector:@selector(loadTable) withObject:nil afterDelay:0.0f];
    }];

}
- (void)loadTable {
    
    [self.tableView reloadData];
}

- (void)viewDidUnload{
    [super viewDidUnload];
    summaryBg_ = nil;
    summaryLabel_ = nil;
    moreBtn_ = nil;
    arrReviewData_ = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{   int count = 3;
    
    if ([commentArray_ count] > 0) {
        count++;
    }
    if ([arrReviewData_ count]>0) {
        count++;
    }
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 2;
    }
    else if (section == 1){
        if ([relevantList_ count]>0) {
             return [relevantList_ count] > 5 ? 5+1:[relevantList_ count]+1;
        }
        else{
            return 0;
        }
       
    }
    else if (section == 2){
        return 0;
        if ([commentArray_ count]>0) {
            return [commentArray_ count]+1;
        }
        else{
            return 0;
        }
    }
    else if (3 == section)
    {
        return arrReviewData_.count > 0 ? 1 : 0;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    for (UIView *view in cell.subviews) {
        [view removeFromSuperview];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:{
                UIImageView *frame = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_placeholder.png"]];
                frame.frame = CGRectMake(14, 14, 90, 143);
                frame.backgroundColor = [UIColor clearColor];
                [cell addSubview:frame];
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(18, 19, 83, 134)];
        
                NSString *imageUrl = [self.infoDic objectForKey:@"prod_pic_url"];
                if (imageUrl == nil) {
                    imageUrl = [self.infoDic objectForKey:@"content_pic_url"];
                }
                if (imageUrl == nil) {
                    imageUrl = [self.infoDic objectForKey:@"poster"];
                }
                [imageView setImageWithURL:[NSURL URLWithString:imageUrl] /*placeholderImage:[UIImage imageNamed:@"video_placeholder"]*/];
                wechatImgStr_ = imageUrl;
                [cell addSubview:imageView];
                
                NSString *titleStr = [self.infoDic objectForKey:@"prod_name"];
                if (titleStr == nil) {
                    titleStr = [self.infoDic objectForKey:@"content_name"];
                }
                if (titleStr == nil) {
                        titleStr = [self.infoDic objectForKey:@"name"];
                }
                UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(116, 14, 170, 18)];
                titleLabel.font = [UIFont systemFontOfSize:15];
                titleLabel.textColor = [UIColor grayColor];
                titleLabel.backgroundColor = [UIColor clearColor];
                titleLabel.text = titleStr;
                [cell addSubview:titleLabel];
                
                NSString *directors = [self.infoDic objectForKey:@"directors"];
                if (directors == nil) {
                    directors = [self.infoDic objectForKey:@"director"];
                }
                if (directors == nil) {
                    directors = @" ";
                }
                
                NSString *actors = [self.infoDic objectForKey:@"stars"];
                if (actors == nil) {
                    actors = [self.infoDic objectForKey:@"star"];
                }
                if (actors == nil) {
                    actors = @" ";
                }
                
                NSString *date = [self.infoDic objectForKey:@"publish_date"];
                if (date == nil) {
                    date = @" ";
                }
                NSString *area = [self.infoDic objectForKey:@"area"];
                if (area == nil) {
                    area = @" ";
                }
                
                UILabel *actorsLabel = [[UILabel alloc] initWithFrame:CGRectMake(116, 39, 200, 15)];
                actorsLabel.font = [UIFont systemFontOfSize:12];
                actorsLabel.textColor = [UIColor grayColor];
                actorsLabel.backgroundColor = [UIColor clearColor];
                actorsLabel.text = [NSString stringWithFormat:@"主演: %@",actors];
                
                UILabel *areaLabel = [[UILabel alloc] initWithFrame:CGRectMake(116, 57, 200, 15)];
                areaLabel.font = [UIFont systemFontOfSize:12];
                areaLabel.textColor = [UIColor grayColor];
                areaLabel.backgroundColor = [UIColor clearColor];
                areaLabel.text = [NSString stringWithFormat:@"地区: %@",area];
                
                UILabel *directorLabel = [[UILabel alloc] initWithFrame:CGRectMake(116, 75, 200, 15)];
                directorLabel.font = [UIFont systemFontOfSize:12];
                directorLabel.textColor = [UIColor grayColor];
                directorLabel.backgroundColor = [UIColor clearColor];
                directorLabel.text = [NSString stringWithFormat:@"导演: %@",directors];
                
                UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(116, 93, 200, 15)];
                dateLabel.font = [UIFont systemFontOfSize:12];
                dateLabel.textColor = [UIColor grayColor];
                dateLabel.backgroundColor = [UIColor clearColor];
                dateLabel.text = [NSString stringWithFormat:@"年代: %@",date];
                
                
                [cell addSubview:actorsLabel];
                [cell addSubview:areaLabel];
                [cell addSubview:directorLabel];
                [cell addSubview:dateLabel];;
                
                UIButton *play = [UIButton buttonWithType:UIButtonTypeCustom];
                play.frame = CGRectMake(110, 110, 90, 45);
                play.tag = 10001;
                [play setBackgroundImage:[UIImage imageNamed:@"play_video.png"] forState:UIControlStateNormal];
                [play setBackgroundImage:[UIImage imageNamed:@"play_video_s.png"] forState:UIControlStateHighlighted];
                [play setBackgroundImage:[UIImage imageNamed:@"no_video_source.png"] forState:UIControlStateDisabled];
                [play addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:play];
                
                UIButton * expectbtn = [UIButton buttonWithType:UIButtonTypeCustom];
                expectbtn.tag = 100010;
                expectbtn.frame = CGRectMake(110, 110, 90, 45);
                [expectbtn setBackgroundImage:[UIImage imageNamed:@"icon_xiangkan_bg_.png"] forState:UIControlStateNormal];
                [expectbtn setBackgroundImage:[UIImage imageNamed:@"icon_xiangkan_bg_.png"] forState:UIControlStateHighlighted];
                [expectbtn setImage:[UIImage imageNamed:@"icon_xiangkan.png"] forState:UIControlStateNormal];
                [expectbtn setImage:[UIImage imageNamed:@"icon_xiangkan_s.png"] forState:UIControlStateHighlighted];
                [expectbtn setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 30)];
                expectbtn.titleLabel.textAlignment = UITextAlignmentCenter;
                [expectbtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
                [expectbtn setTitleColor:[UIColor colorWithRed:170.0f/255.0f green:170.0f/255.0f blue:161.0f/255.0f alpha:0.6f] forState:UIControlStateNormal];
                [expectbtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
                expectbtn.titleLabel.font = [UIFont boldSystemFontOfSize:9];
                [expectbtn addTarget:self action:@selector(expectVideo) forControlEvents:UIControlEventTouchUpInside];
             
                expectbtn.hidden = YES;
                
                UIButton *addFav = [UIButton buttonWithType:UIButtonTypeCustom];
                addFav.frame =  CGRectMake(170, 165, 80, 35);
                addFav.tag = 10002;
                [addFav setImage:[UIImage imageNamed:@"icon_shoucang.png"] forState:UIControlStateNormal];
                [addFav setImage:[UIImage imageNamed:@"icon_shoucang_s.png"] forState:UIControlStateHighlighted];
                if (favCount_ <1000) {
                    [addFav setTitle:[NSString stringWithFormat:@"(%d)",favCount_]  forState:UIControlStateNormal];
                    [expectbtn setTitle:[NSString stringWithFormat:@"(%d)",favCount_] forState:UIControlStateNormal];
                }
                else if (favCount_ >= 1000 && favCount_<= 1100) {
                    
                    [addFav setTitle:[NSString stringWithFormat:@"(1k)"]  forState:UIControlStateNormal];
                    [expectbtn setTitle:[NSString stringWithFormat:@"(1K)"] forState:UIControlStateNormal];
                }
                else {
                    float favNum = favCount_*1.0/1000;
                    [addFav setTitle:[NSString stringWithFormat:@"(%.1fk)",favNum]  forState:UIControlStateNormal];
                    [expectbtn setTitle:[NSString stringWithFormat:@"(%.1fk)",favNum] forState:UIControlStateNormal];
                }
                addFav.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
                addFav.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
                addFav.backgroundColor = [UIColor clearColor];
                [addFav setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                [addFav setTitleColor:[UIColor colorWithRed:170.0f/255.0f green:170.0f/255.0f blue:161.0f/255.0f alpha:0.6f] forState:UIControlStateHighlighted];
                [addFav addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
                addFav.titleLabel.font = [UIFont systemFontOfSize:10];
                [cell addSubview:addFav];
                
                UIButton *support = [UIButton buttonWithType:UIButtonTypeCustom];
                support.frame = CGRectMake(80, 165, 80, 35);
                support.tag = 10003;
                [support setImage:[UIImage imageNamed:@"icon_ding.png"] forState:UIControlStateNormal];
                [support setImage:[UIImage imageNamed:@"icon_ding_s.png"] forState:UIControlStateHighlighted];
                [support setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                [support setTitleColor:[UIColor colorWithRed:170.0f/255.0f green:170.0f/255.0f blue:161.0f/255.0f alpha:0.6f] forState:UIControlStateHighlighted];
                if (supportCount_ <1000) {
                    [support setTitle:[NSString stringWithFormat:@"(%d)",supportCount_]  forState:UIControlStateNormal];
                }
                else if (supportCount_ >= 1000 && supportCount_<= 1100) {
                    
                    [support setTitle:[NSString stringWithFormat:@"(1k)"]  forState:UIControlStateNormal];
                }
                else {
                    float suppotNum = supportCount_*1.0/1000;
                    [support setTitle:[NSString stringWithFormat:@"(%.1fk)",suppotNum]  forState:UIControlStateNormal];
                }
                support.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
                support.titleEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
                [support addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
                support.titleLabel.font = [UIFont systemFontOfSize:10];
                [cell addSubview:support];
                
                
                UIButton *downLoad = [UIButton buttonWithType:UIButtonTypeCustom];
                downLoad.frame = CGRectMake(205, 110, 90, 45);
                downLoad.tag = 10004;
                
                BOOL isEnableReportBtn = YES;
                if ([self getDownloadUrl] == nil) {
                    [downLoad setBackgroundImage:[UIImage imageNamed:@"cache_no.png"] forState:UIControlStateNormal];
                    [downLoad setBackgroundImage:[UIImage imageNamed:@"cache_no.png"] forState:UIControlStateHighlighted];
                    [downLoad setBackgroundImage:[UIImage imageNamed:@"cache_no.png"] forState:UIControlStateDisabled];
                    downLoad.enabled = NO;
                    isEnableReportBtn = NO;
                }
                else{
                    [downLoad setBackgroundImage:[UIImage imageNamed:@"download_video.png"] forState:UIControlStateNormal];
                    [downLoad setBackgroundImage:[UIImage imageNamed:@"download_video_pressed.png"] forState:UIControlStateHighlighted];
                }
                if (self.canPlayVideo) {
                    play.hidden = NO;
                    expectbtn.hidden = YES;
                } else {
                    play.hidden = YES;
                    expectbtn.hidden = NO;
                }                
                [downLoad setBackgroundImage:[UIImage imageNamed:@"download_video_pressed.png"] forState:UIControlStateSelected];
                [downLoad addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
                downLoad.titleLabel.font = [UIFont systemFontOfSize:14];
                if (isLoaded_) {
                    [cell addSubview:expectbtn];
                    if ([CommonMotheds getOnlineConfigValue] != 2){
                        [cell addSubview:downLoad];
                    }
                }

                NSString *itemId = [self.infoDic objectForKey:@"prod_id"];
                if (itemId == nil) {
                    itemId = [self.infoDic objectForKey:@"content_id"];
                }
                if (itemId == nil) {
                    itemId = [self.infoDic objectForKey:@"id"];
                }
                NSString *subquery = [NSString stringWithFormat:@"WHERE itemId = '%@'",itemId];
                NSArray *tempArr = [DatabaseManager findByCriteria:DownloadItem.class queryString:subquery];
                if ([tempArr count] >0) {
                    [downLoad setBackgroundImage:[UIImage imageNamed:@"download_video_pressed.png"] forState:UIControlStateNormal];
                    [downLoad setBackgroundImage:[UIImage imageNamed:@"download_video_pressed.png"] forState:UIControlStateHighlighted];
                    downLoad.selected = YES;
                    downLoad.adjustsImageWhenHighlighted = NO;
                }

                
                UIButton *report = [UIButton buttonWithType:UIButtonTypeCustom];
                report.frame = CGRectMake(0, 165, 80, 35);
                report.tag = 10005;
                [report setImage:[UIImage imageNamed:@"icon_fankui.png"] forState:UIControlStateNormal];
                [report setImage:[UIImage imageNamed:@"icon_fankui_s.png"] forState:UIControlStateHighlighted];
                [report addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
                report.titleLabel.font = [UIFont systemFontOfSize:14];
                [cell addSubview:report];
                if (isEnableReportBtn) {
                    report.enabled = YES;
                }
                else{
                    report.enabled = NO;
                }
                
                UIButton *share = [UIButton buttonWithType:UIButtonTypeCustom];
                share.frame = CGRectMake(240, 165, 80, 35);
                [share setImage:[UIImage imageNamed:@"icon_fenxiang.png"] forState:UIControlStateNormal];
                [share setImage:[UIImage imageNamed:@"icon_fenxiang_s.png"] forState:UIControlStateHighlighted];
                [share addTarget:self action:@selector(share:event:) forControlEvents:UIControlEventTouchUpInside];
                share.titleLabel.font = [UIFont systemFontOfSize:14];
                [cell addSubview:share];
                
                break;
            }
            case 1:{
                UIImageView *jianjie = [[UIImageView alloc] initWithFrame:CGRectMake(14, 15, 32, 13)];
                jianjie.image = [UIImage imageNamed:@"tab2_detailed_common_writing3.png"];
                if (summary_ != nil) {
                    summaryLabel_.text = [NSString stringWithFormat:@"    %@",summary_];
                }
                
                if (isLoaded_) {
                    [cell addSubview:jianjie];
                    [cell addSubview:summaryBg_];
                    [cell addSubview:summaryLabel_];

                }
                
                break;
            }
                
                default:
                break;
        }
    }
    else if (indexPath.section == 1){
        
        int num = [relevantList_ count] > 5 ? 5:[relevantList_ count];
        if (indexPath.row == 0) {
            UIImageView *commentV = [[UIImageView alloc] initWithFrame:CGRectMake(14, 15, 50, 14)];
            commentV.image = [UIImage imageNamed:@"tab2_detailed_common_writing1.png"];
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 5, 320,30)];
            [view addSubview:commentV];
            [cell addSubview:view];
        }
        else{
           
            UIButton *bgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            bgBtn.tag = indexPath.row -1;
            bgBtn.frame = CGRectMake(14, 0, 292, 26);
            if (num == 1) {
                [bgBtn setBackgroundImage:[UIImage imageNamed:@"summryBg.png"] forState:UIControlStateNormal];
            }
            else{
                if (indexPath.row == 1) {
                    [bgBtn setBackgroundImage:[UIImage imageNamed:@"more_bg_1.png"] forState:UIControlStateNormal];
                }
                else if (indexPath.row == num){
                    [bgBtn setBackgroundImage:[UIImage imageNamed:@"more_bg_3.png"] forState:UIControlStateNormal];
                }
                else{
                    [bgBtn setBackgroundImage:[UIImage imageNamed:@"more_bg_2.png"] forState:UIControlStateNormal];
                }
                
            }
            [bgBtn setBackgroundImage:[UIImage imageNamed:@"more_bg_2.png"] forState:UIControlStateHighlighted];
            [bgBtn addTarget:self action:@selector(didSelect:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:bgBtn];
            
            NSDictionary *dic = [relevantList_ objectAtIndex:indexPath.row-1];
            bgBtn.titleLabel.font = [UIFont systemFontOfSize:15];
            [bgBtn setTitle:[dic objectForKey:@"t_name"] forState:UIControlStateNormal];
            [bgBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [bgBtn setTitleColor:[UIColor colorWithRed:247/255.0 green:122/255.0 blue:151/255.0 alpha:1] forState:UIControlStateHighlighted];
                        
            UIImageView *push = [[UIImageView alloc] initWithFrame:CGRectMake(288, 8, 6, 10)];
            push.image = [UIImage imageNamed:@"tab2_detailed_common_jian_tou.png"];
            [cell addSubview:push];
            
            if (num != indexPath.row) {
                 UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fengexian.png"]];
                line.frame = CGRectMake(25,25, 270, 1);
                [cell addSubview:line];
            }
        
        }
        
    }
    else if (indexPath.section == 2){
        if (indexPath.row == 0) {
            UIImageView *commentV = [[UIImageView alloc] initWithFrame:CGRectMake(14, 5, 50, 14)];
            commentV.image = [UIImage imageNamed:@"tab2_detailed_common_writing4.png"];
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320,20)];
            [view addSubview:commentV];
            [cell addSubview:view];
        }
        else{
        
            NSDictionary *item = [commentArray_ objectAtIndex:indexPath.row-1];
            
            UILabel *user =[[UILabel alloc] initWithFrame:CGRectMake(25, 5, 180, 14)];
            user.text = @"网络用户";
            user.font = [UIFont systemFontOfSize:14];
            user.backgroundColor = [UIColor clearColor];
            UILabel *date =[[UILabel alloc] initWithFrame:CGRectMake(210, 5, 90, 14)];
            
            NSString *dateStr = [item objectForKey:@"create_date"];
            if (dateStr.length > 10) {
                dateStr = [dateStr substringToIndex:10];
            }
            date.text = dateStr;
            date.font = [UIFont systemFontOfSize:14];
            date.textColor = [UIColor grayColor];
            date.backgroundColor = [UIColor clearColor];
            [cell addSubview:user];
            [cell addSubview:date];
            NSString *content = [item objectForKey:@"content"];
            int height = [self heightForString:content fontSize:13 andWidth:271];
            UILabel *comment =[[UILabel alloc]initWithFrame:CGRectMake(25, 20, 270, height)];
            comment.text = content;
            comment.backgroundColor = [UIColor clearColor];
            comment.textColor = [UIColor grayColor];
            comment.numberOfLines = 0;
            comment.lineBreakMode = UILineBreakModeWordWrap;
            comment.font = [UIFont systemFontOfSize:13];
            [cell addSubview:comment];
            
            UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab2_detailed_common_writing4_fenge.png"]];
            line.frame = CGRectMake(25,height+22, 270, 1);
            [cell addSubview:line];
        }
    
    }
    else if (3 == indexPath.section)
    {
        UIImageView *yingping = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"yingping.png"]];
        yingping.frame = CGRectMake(14, 22, 32, 14);
        [cell addSubview:yingping];
        
        for (int i = 0; i < arrReviewData_.count; i ++)
        {
            NSDictionary * data = [arrReviewData_ objectAtIndex:i];
            FilmReviewViewCell * preCell = (FilmReviewViewCell *)[cell viewWithTag:(REVIEW_VIEW_TAG + i - 1)];
            
            CGRect rect = CGRectMake(12, 44, 296, 133);
            if (nil != preCell)
            {
                rect.origin.y = preCell.frame.size.height + preCell.frame.origin.y + 10.0f;
            }
            
            FilmReviewViewCell * reviewCell = [[FilmReviewViewCell alloc] initWithFrame:rect
                                                                            title:[data objectForKey:@"title"]
                                                                          content:[data objectForKey:@"comments"]];
            reviewCell.tag = REVIEW_VIEW_TAG + i;
            [reviewCell setDelegate:self];
            [cell addSubview:reviewCell];
            
            if (i == arrReviewData_.count - 1 && 3 == arrReviewData_.count)
            {
                UIButton * moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                moreBtn.frame = CGRectMake(220, reviewCell.frame.origin.y + reviewCell.frame.size.height + 20.0f, 200, 60);
                moreBtn.backgroundColor = [UIColor clearColor];
                [moreBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 30, 100)];
                [moreBtn setTitle:@"更多影评 >" forState:UIControlStateNormal];
                moreBtn.titleLabel.font = [UIFont systemFontOfSize:12];
                moreBtn.titleLabel.textColor = [UIColor colorWithRed:247/255.0 green:100/255.0 blue:136/255.0 alpha:1];
                [moreBtn setTitleColor:[UIColor colorWithRed:247/255.0 green:100/255.0 blue:136/255.0 alpha:1]
                              forState:UIControlStateNormal];
                [moreBtn addTarget:self
                            action:@selector(moreBtnClicked:)
                  forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:moreBtn];
            }
        }
        
    }
    return cell;
}

- (float) heightForString:(NSString *)value fontSize:(float)fontSize andWidth:(float)width
{
    CGSize sizeToFit = [value sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    return sizeToFit.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    int row = indexPath.row;
    if (indexPath.section == 0) {
        if (row == 0) {
            return 195;
        }
        else if(row == 1){
            if (moreBtn_.selected) {
                float height = [self heightForString:summary_ fontSize:13 andWidth:271];
                
                if (height < 85) {
                    return 125;
                }
                return height+40;

            }
            else{
                 return 125;
            }
           
        }
    
    }
    else if (indexPath.section == 1){
        if ([relevantList_ count]>0) {
            if (indexPath.row == 0) {
                return 43;
            }
            else{
                return 26;
            
            }
            
        }
        else{
            return 0;
        }
    
    
    }
    else if (indexPath.section == 2){
        return 0;
        if (indexPath.row == 0) {
            return 20;
        }
        else{
            NSDictionary *item = [commentArray_ objectAtIndex:row -1];
            NSString *content = [item objectForKey:@"content"];
            return [self heightForString:content fontSize:13 andWidth:271]+23;
        
        }
        
    }
    else if (3 == indexPath.section)
    {
        CGFloat height = 44.0f + arrReviewData_.count * 133 + (arrReviewData_.count - 1)*20.0f + 50;
        return height;
    }
        return 0;
    
}

-(void)didSelect:(UIButton *)btn{
    if (![self checkNetWork]) {
        [UIUtility showNetWorkError:self.view];
        return;
    }
    int num = btn.tag;
    NSDictionary *dic = [relevantList_ objectAtIndex:num];
    ListDetailViewController *listDetail = [[ListDetailViewController alloc] initWithStyle:UITableViewStylePlain];
    listDetail.title = [dic objectForKey:@"t_name"];
    listDetail.topicId = [dic objectForKey:@"t_id"];
    listDetail.Type = 9001;
    [self.navigationController pushViewController:listDetail animated:YES];

}

- (void)expectVideo
{
    //电影不需要注册消息推送
//    [self SubscribingToChannels];
    [self addVideotoFav:ADDEXPECT];
}

- (void)addVideotoFav:(NSInteger)type
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: prodId_, @"prod_id", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathProgramFavority parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        
        if([responseCode isEqualToString:kSuccessResCode]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_FAV"object:nil];
            favCount_++;
            [self showOpSuccessModalView:1.5 with:type];
            [self.tableView reloadData];
            
        } else {
            [self showOpFailureModalView:1.5 with:type];
        }
        
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        [self showOpFailureModalView:1.5 with:type];
    }];
}

-(void)action:(id)sender {
    if (![self checkNetWork]) {
        [UIUtility showNetWorkError:self.view];
        return;
    }
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        case 10001:{
            [self playVideo:0];
            break;
        }
        case 10002:{
            //电影不需要注册消息推送
//            [self SubscribingToChannels];
            [self addVideotoFav:ADDFAV];
            
            break;
        }
        case 10003:{
            NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: prodId_, @"prod_id", nil];
            [[AFServiceAPIClient sharedClient] postPath:kPathSupport parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
                NSString *responseCode = [result objectForKey:@"res_code"];
                if([responseCode isEqualToString:kSuccessResCode]){
                    supportCount_ ++;
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_SUPPORT" object:nil];
                    [self showOpSuccessModalView:1 with:DING];
                    [self.tableView reloadData];
                } else {
                    [self showOpFailureModalView:1 with:DING];
                }
            } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                   [self showOpFailureModalView:1 with:DING];
            }];
            
            
            break;
        }
        case 10004:{
            if (button.selected) {
                return;
            }
            button.selected = YES;
            [button setBackgroundImage:[UIImage imageNamed:@"download_video_pressed.png"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"download_video_pressed.png"] forState:UIControlStateHighlighted];
            button.adjustsImageWhenHighlighted = NO;
            
            NSString *url = [self getDownloadUrl];
//            NSString *url = @"http://v.youku.com/player/getM3U8/vid/127814846/type/flv/ts/%7Bnow_date%7D/useKeyframe/0/v.m3u8";
            if (url == nil || [url isEqualToString:@""]) {
                NSLog(@"Get the download url is failed");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"暂无下载地址" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
                [alert show];
                return;
            }
            NSString *name = [videoInfo_ objectForKey:@"name"];
            if (name == nil || [name isEqualToString:@""]) {
                NSLog(@"Get the download name is failed");
                return;
            }
            NSString *prodId = [videoInfo_ objectForKey:@"id"];
            if (prodId == nil || [prodId isEqualToString:@""]) {
                NSLog(@"Get the download prodId is failed");
                return;
            }
            NSString *imgUrl = [self.infoDic objectForKey:@"prod_pic_url"];
            if (imgUrl == nil) {
                imgUrl = [self.infoDic objectForKey:@"content_pic_url"];
            }
            if (imgUrl == nil) {
                imgUrl = [self.infoDic objectForKey:@"poster"];
            }
            NSArray *infoArr = [NSArray arrayWithObjects:prodId,name,imgUrl,@"1",[NSNumber numberWithInt:0], nil];
            
            CheckDownloadUrls *check = [[CheckDownloadUrls alloc] init];
            check.downloadInfoArr = infoArr;
            check.oneEsp = [self checkDownloadUrls:[episodesArr_ objectAtIndex:0]];
            check.checkDownloadUrlsDelegate = [CheckDownloadUrlsManager defaultCheckDownloadUrlsManager];
            [CheckDownloadUrlsManager addToCheckQueue:check];
            break;
        }
        case 10005:
        {
            
            FeedBackView * feedback = [[FeedBackView alloc] initWithFrame:CGRectMake(0, 2*kFullWindowHeight, 320, kFullWindowHeight)];
            feedback.delegate = self;
            UITabBarController * ctrl = [AppDelegate instance].tabBarView;
            feedback.clipsToBounds = YES;
            [ctrl.selectedViewController.view addSubview:feedback];
            
            [UIView beginAnimations:nil context:NULL];
            
            [UIView setAnimationDuration:0.5f];
            
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            
            feedback.frame = CGRectMake(0, 0, 320, kFullWindowHeight);
            
            [UIView commitAnimations];
            
            return;
            
            NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:prodId_, @"prod_id", nil];
            [[AFServiceAPIClient sharedClient] getPath:kPathProgramInvalid parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {

                 [self showOpSuccessModalView:3 with:REPORT];
                
            } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                 [self showOpSuccessModalView:3 with:REPORT];
            }];

            break;
        }
        default:
            break;
    }
}

- (void)moreBtnClicked:(id)sender
{
    NSString * douban_Id = [self.infoDic objectForKey:@"douban_id"];
    
    if (nil == douban_Id)
    {
        return;
    }
    
    ReviewViewController * rCtrl = [[ReviewViewController alloc] init];
    rCtrl.reqURL = douban_Id;
    [self presentViewController:rCtrl animated:YES completion:NULL];
}

-(void)more{
   
        moreBtn_.selected = !moreBtn_.selected;
        float height = [self heightForString:summary_ fontSize:13 andWidth:271];
        if (moreBtn_.selected) {
            if (height < 85) {
                return;
            }
            summaryBg_.frame = CGRectMake(14, 35, 292, height+5);
            summaryLabel_.frame = CGRectMake(28, 35, 264,height);
            
            
        }
        else{
            summaryBg_.frame = CGRectMake(14, 35, 292, 90);
            summaryLabel_.frame = CGRectMake(28, 35, 264,90);
            
        }
    [self loadTable];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
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



-(NSString *)getVideoUrl{
    NSString *videoUrl = nil;
    NSArray *videoUrlArray = [[episodesArr_ objectAtIndex:0] objectForKey:@"down_urls"];
    if(videoUrlArray.count > 0){
      
        for(NSDictionary *tempVideo in videoUrlArray){
            if([LETV isEqualToString:[tempVideo objectForKey:@"source"]]){
                videoUrl = [self parseVideoUrl:tempVideo];
                break;
            }
        }
        if(videoUrl == nil){
            videoUrl = [self parseVideoUrl:[videoUrlArray objectAtIndex:0]];
        }
    }
    return videoUrl;
}

-(NSString *)getDownloadUrl
{
    NSString *downloadUrl = nil;
    if (0 == episodesArr_.count)
        return nil;
    NSArray *videoUrlArray = [[episodesArr_ objectAtIndex:0] objectForKey:@"down_urls"];
    if(videoUrlArray.count > 0){
        for(NSDictionary *tempVideo in videoUrlArray){
            if([LETV isEqualToString:[tempVideo objectForKey:@"source"]]){
                downloadUrl = [self parseDownloadUrl:tempVideo];
                break;
            }
        }
        if(downloadUrl == nil){
            downloadUrl = [self parseDownloadUrl:[videoUrlArray objectAtIndex:0]];
        }
    }
    return downloadUrl;

}
- (NSString *)parseDownloadUrl:(NSDictionary *)tempVideo
{
    NSString *videoUrl;
    NSArray *urlArray =  [tempVideo objectForKey:@"urls"];
    for(NSDictionary *url in urlArray){
        if([GAO_QING isEqualToString:[url objectForKey:@"type"]]&&[@"mp4" isEqualToString:[url objectForKey:@"file"]]){
            videoUrl = [url objectForKey:@"url"];
            
            break;
        }
        if([GAO_QING isEqualToString:[url objectForKey:@"type"]]&&[@"m3u8" isEqualToString:[url objectForKey:@"file"]]){
            videoUrl = [url objectForKey:@"url"];
          
            break;
        }
    }
    if(videoUrl == nil){
        for(NSDictionary *url in urlArray){
            if([BIAO_QING isEqualToString:[url objectForKey:@"type"]]&&[@"mp4" isEqualToString:[url objectForKey:@"file"]]){
                videoUrl = [url objectForKey:@"url"];
               
                break;
            }
            if([BIAO_QING isEqualToString:[url objectForKey:@"type"]]&&[@"m3u8" isEqualToString:[url objectForKey:@"file"]]){
                videoUrl = [url objectForKey:@"url"];
               
                break;
            }
        }
    }
    if(videoUrl == nil){
        for(NSDictionary *url in urlArray){
            if([LIU_CHANG isEqualToString:[[url objectForKey:@"type"] lowercaseString]]&&[@"mp4" isEqualToString:[url objectForKey:@"file"]]){
                videoUrl = [url objectForKey:@"url"];
              
                break;
            }
            if([LIU_CHANG isEqualToString:[[url objectForKey:@"type"] lowercaseString]]&&[@"m3u8" isEqualToString:[url objectForKey:@"file"]]){
                videoUrl = [url objectForKey:@"url"];
               
                break;
            }
        }
    }
    if(videoUrl == nil){
        for(NSDictionary *url in urlArray){
            if([CHAO_QING isEqualToString:[url objectForKey:@"type"]]&&[@"mp4" isEqualToString:[url objectForKey:@"file"]]){
                videoUrl = [url objectForKey:@"url"];
                
                break;
            }
            if([CHAO_QING isEqualToString:[url objectForKey:@"type"]]&&[@"m3u8" isEqualToString:[url objectForKey:@"file"]]){
                videoUrl = [url objectForKey:@"url"];
                
                break;
            }
        }
    }
    
    
    if(videoUrl == nil){
        if(urlArray.count > 0){
            for(NSDictionary *url in urlArray){
                if ([[url objectForKey:@"file"] isEqualToString:@"mp4"]) {
                    videoUrl = [url objectForKey:@"url"];
                   
                }
                if ([[url objectForKey:@"file"] isEqualToString:@"m3u8"]) {
                    videoUrl = [url objectForKey:@"url"];
                    
                }
            
            }
        }
    }
    return videoUrl;
    
    
}



#pragma mark -
#pragma mark - FilmReviewViewCellDelegate 

- (void)filmReviewTaped:(NSString *)title content:(NSString *)content
{
    FilmReviewDetailView * filmView = [[FilmReviewDetailView alloc] initWithFrame:CGRectMake(0, 2*kFullWindowHeight, 320, kFullWindowHeight)
                                                                            title:title
                                                                          content:content];
    
    UITabBarController * ctrl = [AppDelegate instance].tabBarView;
    
    [ctrl.selectedViewController.view addSubview:filmView];
    
    [UIView beginAnimations:nil context:NULL];
    
    [UIView setAnimationDuration:0.5f];
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    filmView.frame = CGRectMake(0, 0, 320, kFullWindowHeight);
    
    [UIView commitAnimations];
    
}
#pragma mark -
#pragma mark - FeedBackDelegate
- (void)feedBackType:(NSString *)type
        detailReason:(NSString *)reason
{
    NSString *feedbackType = type;
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: \
                                prodId_, @"prod_id",\
                                name_ ,@"prod_name",\
                                @"1",@"prod_type",\
                                feedbackType,@"invalid_type",\
                                reason,@"memo",\
                                nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathProgramInvalid parameters:parameters success:^(AFHTTPRequestOperation *operation, id result)
    {
        
    }failure:^(__unused AFHTTPRequestOperation *operation, NSError *error)
    {
        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
//                                                        message:@"问题反馈提交失败!"
//                                                       delegate:nil
//                                              cancelButtonTitle:@"我知道了"
//                                              otherButtonTitles:nil, nil];
//        [alert show];
    }];
}

@end
