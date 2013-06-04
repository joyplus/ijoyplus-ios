//
//  IphoneShowViewController.m
//  yueshipin
//
//  Created by 08 on 12-12-28.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "IphoneShowDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "CacheUtility.h"
#import "CMConstants.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "UIImage+Scale.h"
#import "SendWeiboViewController.h"
#import "ProgramNavigationController.h"
#import "ShowDownloadViewController.h"
#import "CommonMotheds.h"
#import "UIUtility.h"

@interface IphoneShowDetailViewController ()

@end

@implementation IphoneShowDetailViewController

@synthesize videoInfo = videoInfo_;
@synthesize videoType = videoType_;
@synthesize summary = summary_;
@synthesize scrollView = scrollView_;
@synthesize next = next_;
@synthesize pre = pre_;
@synthesize commentArray = commentArray_;
@synthesize summaryBg = summaryBg_;
@synthesize summaryLabel = summaryLabel__;
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
    self.title = @"综艺";
    type_ = 3;
    name_ = titleStr;
    
    isloaded_ = NO;
    commentArray_ = [NSMutableArray arrayWithCapacity:10];
    [self loadData];
    [self loadComments];

    favCount_ = [[self.infoDic objectForKey:@"favority_num" ] intValue];
    supportCount_ = [[self.infoDic objectForKey:@"support_num" ] intValue];
    
    summaryBg_ = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"summryBg.png"] stretchableImageWithLeftCapWidth:50 topCapHeight:50 ]];
    summaryBg_.frame = CGRectMake(14, 25, 292, 90);
    summaryLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(28, 20, 264,90)];
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
    
    pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:480.0f tableView:self.tableView withClient:self];
}

- (void)viewWillAppear:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
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
    NSString *key = [NSString stringWithFormat:@"%@%@", @"show", [self.infoDic objectForKey:@"prod_id"]];
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:key];
    if(cacheResult != nil){
        isloaded_ = YES;
        videoInfo_ = (NSDictionary *)[cacheResult objectForKey:@"show"];
        episodesArr_ = [videoInfo_ objectForKey:@"episodes"];
        NSLog(@"episodes count is %d",[episodesArr_ count]);
        summary_ = [videoInfo_ objectForKey:@"summary"];
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
    NSString *proId =  [self.infoDic objectForKey:@"prod_id"]; 
    if (proId == nil) {
        proId =  [self.infoDic objectForKey:@"content_id"];
    }
    if (proId == nil) {
        proId =  [self.infoDic objectForKey:@"id"];
    }
    prodId_ = proId;
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: proId, @"prod_id", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathProgramView parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        [[CacheUtility sharedCache] putInCache:key result:result];
        isloaded_ = YES;
        videoInfo_ = (NSDictionary *)[result objectForKey:@"show"];
        if (isNotification_) {
            [self notificationData];
        }
        else{
            infoDic_ = videoInfo_;
        }
        episodesArr_ = [videoInfo_ objectForKey:@"episodes"];
        NSLog(@"episodes count is %d",[episodesArr_ count]);
        summary_ = [videoInfo_ objectForKey:@"summary"];
        [tempHUD hide:YES];
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:0.0f];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        [tempHUD hide:YES];
        [UIUtility showDetailError:self.view error:error];
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
            else{
              [pullToRefreshManager_ setPullToRefreshViewVisible:NO];
            }
        }
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:0.0f];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:0.0f];
    }];
    
}
- (void)loadTable {
    [self.tableView reloadData];
    [pullToRefreshManager_ tableViewReloadFinished];
}

- (void)viewDidUnload{
    [super viewDidUnload];
    scrollView_ = nil;
    next_ = nil;
    pre_ = nil;
    summaryBg_ = nil;
    summaryLabel_ = nil;
    moreBtn_ = nil;
    pullToRefreshManager_ = nil;
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if ([commentArray_ count] > 0) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 3;
    }
    else if (section == 1){
        if ([commentArray_ count]>0) {
            return [commentArray_ count]+1;
        }
        else{
            return 0;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
     UITableViewCell *cell  = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
//    for (UIView *view in cell.subviews) {
//        [view removeFromSuperview];
//    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:{
                
                UIImageView *frame = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_placeholder.png"]];
                frame.frame = CGRectMake(14, 14, 90, 143);
                [cell addSubview:frame];
                
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 16, 85, 138)];
                
                NSString *url = [videoInfo_ objectForKey:@"ipad_poster"];
                if(url == nil){
                    url = [videoInfo_ objectForKey:@"poster"];
                }

                [imageView setImageWithURL:[NSURL URLWithString:url]];
                 wechatImgStr_ = url;
                [cell addSubview:imageView];
                
                NSString *directors = [self.infoDic objectForKey:@"directors"];
                if (directors == nil) {
                    directors = @" ";
                }
                NSString *actors = [self.infoDic objectForKey:@"stars"];
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
                
                UILabel *actorsLabel = [[UILabel alloc] initWithFrame:CGRectMake(116, 39, 200, 15)];
                actorsLabel.font = [UIFont systemFontOfSize:12];
                actorsLabel.textColor = [UIColor grayColor];
                actorsLabel.backgroundColor = [UIColor clearColor];
                actorsLabel.text = [NSString stringWithFormat:@"主演: %@",actors];
                
                UILabel *areaLabel = [[UILabel alloc] initWithFrame:CGRectMake(116, 77, 200, 15)];
                areaLabel.font = [UIFont systemFontOfSize:12];
                areaLabel.textColor = [UIColor grayColor];
                areaLabel.backgroundColor = [UIColor clearColor];
                areaLabel.text = [NSString stringWithFormat:@"地区: %@",area];
                
                UILabel *directorLabel = [[UILabel alloc] initWithFrame:CGRectMake(116, 57, 200, 15)];
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
                [play setImage:[UIImage imageNamed:@"play_video.png"] forState:UIControlStateNormal];
                [play setImage:[UIImage imageNamed:@"play_video_s.png"] forState:UIControlStateHighlighted];
                [play addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:play];
                
                UIButton *addFav = [UIButton buttonWithType:UIButtonTypeCustom];
                addFav.frame =  CGRectMake(165, 165, 80, 35);
                addFav.tag = 10002;
                [addFav setImage:[UIImage imageNamed:@"icon_shoucang.png"] forState:UIControlStateNormal];
                [addFav setImage:[UIImage imageNamed:@"icon_shoucang_s.png"] forState:UIControlStateHighlighted];
                
                if (favCount_ <1000) {
                    [addFav setTitle:[NSString stringWithFormat:@"(%d)",favCount_]  forState:UIControlStateNormal];
                }
                else if (favCount_ >= 1000 && favCount_<= 1100) {
                    
                    [addFav setTitle:[NSString stringWithFormat:@"(1k)"]  forState:UIControlStateNormal];
                }
                else {
                    float favNum = favCount_*1.0/1000;
                    [addFav setTitle:[NSString stringWithFormat:@"(%.1fk)",favNum]  forState:UIControlStateNormal];
                }
                addFav.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
                addFav.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
                [addFav setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                [addFav setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
                [addFav addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
                addFav.titleLabel.font = [UIFont systemFontOfSize:10];
                [cell addSubview:addFav];
                
                UIButton *support = [UIButton buttonWithType:UIButtonTypeCustom];
                support.frame = CGRectMake(80, 165, 80, 35);
                support.tag = 10003;
                [support setImage:[UIImage imageNamed:@"icon_ding.png"] forState:UIControlStateNormal];
                [support setImage:[UIImage imageNamed:@"icon_ding_s.png"] forState:UIControlStateHighlighted];
                [support setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                [support setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
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
                [downLoad setBackgroundImage:[UIImage imageNamed:@"download_video.png"] forState:UIControlStateNormal];
                [downLoad setBackgroundImage:[UIImage imageNamed:@"download_video.png"] forState:UIControlStateHighlighted];
                [downLoad setBackgroundImage:[UIImage imageNamed:@"cache_no.png"] forState:UIControlStateDisabled];
                [downLoad addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
                if (![self isDownloadUrlEnable]) {
                    downLoad.enabled = NO;
                }
                downLoad.titleLabel.font = [UIFont systemFontOfSize:14];
                
                if (isloaded_) {
                    [cell addSubview:downLoad];
                }
    
                UIButton *report = [UIButton buttonWithType:UIButtonTypeCustom];
                report.frame = CGRectMake(0, 165, 80, 35);
                report.tag = 10005;
                [report setImage:[UIImage imageNamed:@"icon_fankui.png"] forState:UIControlStateNormal];
                [report setImage:[UIImage imageNamed:@"icon_fankui_s.png"] forState:UIControlStateHighlighted];
                [report addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
                report.titleLabel.font = [UIFont systemFontOfSize:14];
                [cell addSubview:report];
                
                UIButton *share = [UIButton buttonWithType:UIButtonTypeCustom];
                share.frame = CGRectMake(240, 165, 80, 35);
                share.tag = 10005;
                [share setImage:[UIImage imageNamed:@"icon_fenxiang.png"] forState:UIControlStateNormal];
                [share setImage:[UIImage imageNamed:@"icon_fenxiang_s.png"] forState:UIControlStateHighlighted];
                [share addTarget:self action:@selector(share:event:) forControlEvents:UIControlEventTouchUpInside];
                share.titleLabel.font = [UIFont systemFontOfSize:14];
                [cell addSubview:share];
                
                break;
            }
            case 1:{
                UIImageView *onLine = [[UIImageView alloc] initWithFrame:CGRectMake(12, 10, 32, 13)];
                onLine.image = [UIImage imageNamed:@"juji.png"];
                [cell addSubview:onLine];
                
                UIView *view = [self showEpisodesplayView];
               [cell addSubview:view];
                break;
            }
                
            case 2:{
                UIImageView *jianjie = [[UIImageView alloc] initWithFrame:CGRectMake(14, 5, 30, 13)];
                jianjie.image = [UIImage imageNamed:@"tab2_detailed_common_writing3.png"];
                [cell addSubview:jianjie];
                
                [cell addSubview:summaryBg_];
                if (summary_ != nil) {
                    summaryLabel_.text = [NSString stringWithFormat:@"    %@",summary_];
                }
                [cell addSubview:summaryLabel_];
                //[cell addSubview:moreBtn_];
                break;
            }
            default:
                break;
        }
    }
    else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            UIImageView *commentV = [[UIImageView alloc] initWithFrame:CGRectMake(14, 15, 50, 14)];
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
            return 250;
        }
        else if(row == 2){
            if (moreBtn_.selected) {
                float height = [self heightForString:summary_ fontSize:13 andWidth:271];
                
                if (height < 85) {
                    return 115;
                }
                return height+30;

            }
            else{
                return 115;
            }

        }
        
    }
    else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            return 30;
        }
        else{
            NSDictionary *item = [commentArray_ objectAtIndex:row -1];
            NSString *content = [item objectForKey:@"content"];
            return [self heightForString:content fontSize:13 andWidth:271]+23;
            
        }

    }
    return 0;
    
}
-(void)action:(id)sender {
    if (![self checkNetWork]) {
       [UIUtility showNetWorkError:self.view];
        return;
    }
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        case 10001:{
            //[self Play:0];
            [self playVideo:0];
            break;
        }
        case 10002:{
            NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: prodId_, @"prod_id", nil];
            [[AFServiceAPIClient sharedClient] postPath:kPathProgramFavority parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
                NSString *responseCode = [result objectForKey:@"res_code"];
                if([responseCode isEqualToString:kSuccessResCode]){
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_FAV"object:nil];
                    favCount_++;
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
        case 10003:{
            NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:prodId_, @"prod_id", nil];
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
        
            ShowDownloadViewController *showDownlooadViewController = [[ShowDownloadViewController alloc] init];
            showDownlooadViewController.title = self.title;
            NSString *itemId = [self.infoDic objectForKey:@"prod_id"];
            if (itemId == nil) {
                itemId = [self.infoDic objectForKey:@"content_id"];
            }
            if (itemId == nil) {
                 itemId = [self.infoDic objectForKey:@"id"];
            }
            showDownlooadViewController.prodId = itemId;
            
            showDownlooadViewController.listArr =  [NSMutableArray arrayWithArray:episodesArr_];
            NSString *titleStr = [self.infoDic objectForKey:@"prod_name"];
            if (titleStr == nil) {
                titleStr = [self.infoDic objectForKey:@"content_name"];
            }
            if (titleStr == nil) {
                titleStr = [self.infoDic objectForKey:@"name"];
            }
            showDownlooadViewController.title = titleStr;
            NSString *url = [videoInfo_ objectForKey:@"ipad_poster"];
            if(url == nil){
                url = [videoInfo_ objectForKey:@"poster"];
            }
            showDownlooadViewController.imageviewUrl = url;
            [self presentModalViewController:[[UINavigationController alloc] initWithRootViewController:showDownlooadViewController] animated:YES];
            break;
        }
        case 10005:{
            
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
            
            break;
        }
  
        default:
            break;
    }
}

-(void)more{
    moreBtn_.selected = !moreBtn_.selected;
    float height = [self heightForString:summary_ fontSize:13 andWidth:271];
    if (moreBtn_.selected) {
        if (height < 85) {
            return;
        }
        summaryBg_.frame = CGRectMake(14, 25, 292, [self heightForString:summary_ fontSize:13 andWidth:271]+5);
        summaryLabel_.frame = CGRectMake(28, 28, 264,[self heightForString:summary_ fontSize:13 andWidth:271]);
        //moreBtn_.frame = CGRectMake(288, [self heightForString:summary_ fontSize:13 andWidth:271], 18, 14);
        
    }
    else{
        summaryBg_.frame = CGRectMake(14, 25, 292, 90);
        summaryLabel_.frame = CGRectMake(28, 25, 264,90);
        //moreBtn_.frame = CGRectMake(288, 90, 18, 14);
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
-(BOOL)isDownloadUrlEnable{
    NSString *downloadUrl = nil;
    for (int i = 0; i <[episodesArr_ count]; i++) {
        NSArray *videoUrlArray = [[episodesArr_ objectAtIndex:i] objectForKey:@"down_urls"];
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
        if (downloadUrl != nil ) {
            return YES;
        }
    }
    return NO;
    
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
            if([LIU_CHANG isEqualToString:[url objectForKey:@"type"]]&&[@"mp4" isEqualToString:[url objectForKey:@"file"]]){
                videoUrl = [url objectForKey:@"url"];
                break;
            }
            if([LIU_CHANG isEqualToString:[url objectForKey:@"type"]]&&[@"m3u8" isEqualToString:[url objectForKey:@"file"]]){
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

-(UIView *)showEpisodesplayView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 260)];
    view.backgroundColor = [UIColor clearColor];
    int count = [episodesArr_ count];
    
    pageCount_ = (count%5 == 0 ? (count/5):(count/5)+1);
    
    UIImageView *listBgView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 32, 236, 205)];
    listBgView.image = [UIImage imageNamed:@"juji_liebiao_bg"];
    [view addSubview:listBgView];
    
    scrollView_= [[UIScrollView alloc] initWithFrame:CGRectMake(42, 35, 240, 210)];
    scrollView_.contentSize = CGSizeMake(320*(count/15), 125);
    scrollView_.backgroundColor = [UIColor clearColor];
    scrollView_.scrollEnabled = NO;
    scrollView_.pagingEnabled = YES;
    scrollView_.showsHorizontalScrollIndicator = NO;
    for (int i = 0; i < count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(2+(i/5)*240, (i%5)*40, 227, 37);
        button.tag = i+1;
        NSDictionary *dic = [episodesArr_ objectAtIndex:i];
        
        NSString *title = [NSString stringWithFormat:@"%@", [dic objectForKey:@"name"]];
        button.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:110.0/255 green:110.0/255 blue:110.0/255 alpha:1] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:190.0/255 green:190.0/255 blue:190.0/255 alpha:1] forState:UIControlStateDisabled];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
         button.titleLabel.font = [UIFont systemFontOfSize:12];
         button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [button setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
        [button setBackgroundImage:[UIImage imageNamed:@"tab2_detailed_variety_online_bg.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"tab2_detailed_variety_online_bg_s.png"] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(episodesPlay:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView_ addSubview:button];
    }
    currentPage_ = 1;
    
    next_ = [UIButton buttonWithType:UIButtonTypeCustom];
    next_.frame = CGRectMake(280, 30, 30, 208);
   // [next_ setTitle:@"PRE" forState:UIControlStateNormal];
    [next_ setBackgroundImage:[UIImage imageNamed:@"tab2_detailed_variety_More1"] forState:UIControlStateNormal];
    [next_ setBackgroundImage:[UIImage imageNamed:@"tab2_detailed_variety_More1_s"] forState:UIControlStateHighlighted];
    [next_ addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchDown];
    [view  addSubview:next_];
    if (pageCount_ == 1) {
        next_.enabled = NO;
    }

    pre_ = [UIButton buttonWithType:UIButtonTypeCustom];
    pre_.frame = CGRectMake(8, 30, 30, 208);
    if (currentPage_ == 1) {
        pre_.enabled = NO;
    }
    //[pre_ setTitle:@"NEXT" forState:UIControlStateNormal];
    [pre_ setBackgroundImage:[UIImage imageNamed:@"tab2_detailed_variety_More2"] forState:UIControlStateNormal];
    [pre_ setBackgroundImage:[UIImage imageNamed:@"tab2_detailed_variety_More2_s"] forState:UIControlStateHighlighted];
    [pre_ addTarget:self action:@selector(pre:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:pre_];
   
    [view addSubview:scrollView_];
    return view;
    
}

-(void)next:(id)sender{
    currentPage_++;
    [UIView beginAnimations:nil context:NULL];
    
    [UIView setAnimationDuration:0.3f];
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    [self.scrollView setContentOffset:CGPointMake(240.0f*(currentPage_-1), 0.0f) animated:YES];
    
    [UIView commitAnimations];
    if (currentPage_ == pageCount_ ) {
        next_.enabled = NO;
    }
    else{
        next_.enabled = YES;
    
    }
    
    if (currentPage_ == 1 ) {
        pre_.enabled = NO;
    }
    else{
        pre_.enabled = YES;
        
    }
    
}
-(void)pre:(id)sender{
    currentPage_--;
    [UIView beginAnimations:nil context:NULL];
    
    [UIView setAnimationDuration:0.3f];
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    [self.scrollView setContentOffset:CGPointMake(240.0f*(currentPage_-1), 0.0f) animated:YES];
    
    [UIView commitAnimations];
    if (currentPage_ == pageCount_ ) {
        next_.enabled = NO;
    }
    else{
        next_.enabled = YES;
        
    }
    if (currentPage_ == 1 ) {
        pre_.enabled = NO;
    }
    else{
        pre_.enabled = YES;
        
    }
    
}
-(void)episodesPlay:(id)sender{
    int playNum = ((UIButton *)sender).tag;
    //[self Play:playNum-1];
    //name_ = ((UIButton *)sender).titleLabel.text;
    [self playVideo:playNum-1];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [pullToRefreshManager_ tableViewReleased];
}

- (void)MNMBottomPullToRefreshManagerClientReloadTable {
    [CommonMotheds showNetworkDisAbledAlert:self.view];
    [self loadComments];
    
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
         
     }];
}

@end
