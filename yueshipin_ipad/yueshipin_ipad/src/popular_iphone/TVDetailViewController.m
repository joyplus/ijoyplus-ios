//
//  TVDetailViewController.m
//  yueshipin
//
//  Created by 08 on 12-12-28.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "TVDetailViewController.h"
#import "AppDelegate.h"
#import "UIImage+Scale.h"
#import "SendWeiboViewController.h"
#import "ListDetailViewController.h"
#import "ProgramNavigationController.h"
#import "CommonHeader.h"
#import "CacheUtility.h"
#define DOWNLOAD_BG  100001
@interface TVDetailViewController ()

@end

@implementation TVDetailViewController

@synthesize infoDic = infoDic_;
@synthesize videoInfo = videoInfo_;
@synthesize videoType = videoType_;
@synthesize summary = summary_;
@synthesize scrollView = scrollView_;
@synthesize commentArray =commentArray_;
@synthesize relevantList = relevantList_;
@synthesize summaryBg = summaryBg_;
@synthesize summaryLabel = summaryLabel__;
@synthesize moreBtn = moreBtn_;
@synthesize scrollViewUp = scrollViewUp_;
@synthesize scrollViewDown = scrollViewDown_;
@synthesize next = next_;
@synthesize pre = pre_;
@synthesize nextDL = nextDL_;
@synthesize preDL = preDL_;
@synthesize scrollViewUpDL = scrollViewUpDL_;
@synthesize scrollViewDownDL = scrollViewDownDL_;
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
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 40, 30);
    backButton.backgroundColor = [UIColor clearColor];
    [backButton setImage:[UIImage imageNamed:@"top_return_common.png"] forState:UIControlStateNormal];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    self.navigationItem.hidesBackButton = YES;
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(0, 0, 40, 30);
    rightButton.backgroundColor = [UIColor clearColor];
    [rightButton setImage:[UIImage imageNamed:@"top_common_share.png"] forState:UIControlStateNormal];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    _infoDic = self.infoDic;
    
    self.tableView.backgroundView = backGround;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    NSString *titleStr = [self.infoDic objectForKey:@"prod_name"];
    if (titleStr == nil) {
        titleStr = [self.infoDic objectForKey:@"content_name"];
    }
    self.title = titleStr;
    name_ = self.title;
    type_ = 2;
    
    currentPage_ = 1;
    isDownLoad_ = NO;
    commentArray_ = [NSMutableArray arrayWithCapacity:10];
    [self loadData];
    [self loadComments];
    
    favCount_ = [[self.infoDic objectForKey:@"favority_num" ] intValue];
    supportCount_ = [[self.infoDic objectForKey:@"support_num" ] intValue];
    
    summaryBg_ = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"summryBg.png"] stretchableImageWithLeftCapWidth:50 topCapHeight:50 ]];
    summaryBg_.frame = CGRectMake(14, 20, 292, 90);
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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playNext:) name:@"PLAY_NEXT" object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
}

-(void)back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)loadData{
    
    relevantList_ = [NSArray array];
    MBProgressHUD *tempHUD;
    NSString *key = [NSString stringWithFormat:@"%@%@", @"tv", [self.infoDic objectForKey:@"prod_id"]];
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:key];
    if(cacheResult != nil){
        videoInfo_ = (NSDictionary *)[cacheResult objectForKey:@"tv"];
       // episodesArr_ = [videoInfo_ objectForKey:@"episodes"];
         [self SortEpisodes:[videoInfo_ objectForKey:@"episodes"]];
        NSLog(@"episodes count is %d",[episodesArr_ count]);
        summary_ = [videoInfo_ objectForKey:@"summary"];
        relevantList_ = [cacheResult objectForKey:@"topics"];
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
        proId = [self.infoDic objectForKey:@"content_id"];
    }
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:proId, @"prod_id", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathProgramView parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        [[CacheUtility sharedCache] putInCache:key result:result];
        videoInfo_ = (NSDictionary *)[result objectForKey:@"tv"];
        //episodesArr_ = [videoInfo_ objectForKey:@"episodes"];
        [self SortEpisodes:[videoInfo_ objectForKey:@"episodes"]];
        NSLog(@"161 count is %d",[episodesArr_ count]);
        summary_ = [videoInfo_ objectForKey:@"summary"];
        relevantList_ = [result objectForKey:@"topics"];
        [tempHUD hide:YES];
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:0.0f];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        [tempHUD hide:YES];
    }];
    
}

//将所有的剧集排序。
-(void)SortEpisodes:(NSArray *)arr{
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES comparator:cmptr];
    episodesArr_ = [arr sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];

}

NSComparator cmptr = ^(id obj1, id obj2){
    if ([obj1 integerValue] > [obj2 integerValue]) {
        return (NSComparisonResult)NSOrderedDescending;
    }
    
    if ([obj1 integerValue] < [obj2 integerValue]) {
        return (NSComparisonResult)NSOrderedAscending;
    }
    return (NSComparisonResult)NSOrderedSame;
};


-(void)loadComments{
    NSString *itemId = [self.infoDic objectForKey:@"prod_id"];
    if (itemId == nil) {
        itemId = [self.infoDic objectForKey:@"content_id"];
    }
    self.prodId = itemId;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    int count = 2;
    
    if ([commentArray_ count] > 0) {
        count++;
    }
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 3;
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
                UIImageView *frame = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detailFrame.png"]];
                frame.frame = CGRectMake(14, 14, 90, 133);
                [cell addSubview:frame];
                
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(14, 14, 87, 129)];
                NSString *imgUrl =[self.infoDic objectForKey:@"prod_pic_url"];
                if (imgUrl == nil) {
                    imgUrl = [self.infoDic objectForKey:@"content_pic_url"];
                }
                
                [imageView setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
                [cell addSubview:imageView];
                
                NSString *directors = [self.infoDic objectForKey:@"directors"];
                NSString *actors = [self.infoDic objectForKey:@"stars"];
                NSString *date = [self.infoDic objectForKey:@"publish_date"];
                NSString *area = [self.infoDic objectForKey:@"area"];
                
                UILabel *actorsLabel = [[UILabel alloc] initWithFrame:CGRectMake(116, 59, 200, 15)];
                actorsLabel.font = [UIFont systemFontOfSize:12];
                actorsLabel.textColor = [UIColor grayColor];
                actorsLabel.backgroundColor = [UIColor clearColor];
                actorsLabel.text = [NSString stringWithFormat:@"主演: %@",actors];
                
                UILabel *areaLabel = [[UILabel alloc] initWithFrame:CGRectMake(116, 77, 200, 15)];
                areaLabel.font = [UIFont systemFontOfSize:12];
                areaLabel.textColor = [UIColor grayColor];
                areaLabel.backgroundColor = [UIColor clearColor];
                areaLabel.text = [NSString stringWithFormat:@"地区: %@",area];
                
                UILabel *directorLabel = [[UILabel alloc] initWithFrame:CGRectMake(116, 95, 200, 15)];
                directorLabel.font = [UIFont systemFontOfSize:12];
                directorLabel.textColor = [UIColor grayColor];
                directorLabel.backgroundColor = [UIColor clearColor];
                directorLabel.text = [NSString stringWithFormat:@"导演: %@",directors];
                
                UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(116, 113, 200, 15)];
                dateLabel.font = [UIFont systemFontOfSize:12];
                dateLabel.textColor = [UIColor grayColor];
                dateLabel.backgroundColor = [UIColor clearColor];
                dateLabel.text = [NSString stringWithFormat:@"年代: %@",date];
                
                
                [cell addSubview:actorsLabel];
                [cell addSubview:areaLabel];
                [cell addSubview:directorLabel];
                [cell addSubview:dateLabel];;
                
                UIButton *play = [UIButton buttonWithType:UIButtonTypeCustom];
                play.frame = CGRectMake(124, 155, 87, 27);
                play.tag = 10001;
                [play setImage:[UIImage imageNamed:@"play_video.png"] forState:UIControlStateNormal];
                [play setImage:[UIImage imageNamed:@"play_video_s.png"] forState:UIControlStateHighlighted];
                [play addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:play];
                
                UIButton *addFav = [UIButton buttonWithType:UIButtonTypeCustom];
                addFav.frame = CGRectMake(116, 20, 89, 27);
                addFav.tag = 10002;
                [addFav setBackgroundImage:[UIImage imageNamed:@"addFav.png"] forState:UIControlStateNormal];
                [addFav setBackgroundImage:[UIImage imageNamed:@"addFav_pressed.png"] forState:UIControlStateHighlighted];
                [addFav setImage:[UIImage imageNamed:@"tab2_detailed_common_icon_favorite.png"]forState:UIControlStateNormal];
                [addFav setImage:[UIImage imageNamed:@"tab2_detailed_common_icon_favorite_s.png"] forState:UIControlStateHighlighted];
                [addFav setTitle:[NSString stringWithFormat:@"收藏（%d）",favCount_]  forState:UIControlStateNormal];
                [addFav setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [addFav addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
                addFav.titleLabel.font = [UIFont systemFontOfSize:12];
                [cell addSubview:addFav];
                
                UIButton *support = [UIButton buttonWithType:UIButtonTypeCustom];
                support.frame = CGRectMake(219, 20, 80, 27);
                support.tag = 10003;
                [support setBackgroundImage:[UIImage imageNamed:@"collect.png"] forState:UIControlStateNormal];
                [support setBackgroundImage:[UIImage imageNamed:@"collect_pressed.png"] forState:UIControlStateHighlighted];
                [support setImage: [UIImage imageNamed:@"tab2_detailed_common_icon_recommend.png"] forState:UIControlStateNormal];
                [support setImage:[UIImage imageNamed:@"tab2_detailed_common_icon_recommend_s.png"] forState:UIControlStateHighlighted];
                [support setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [support setTitle:[NSString stringWithFormat:@"顶（%d）",supportCount_] forState:UIControlStateNormal];
                [support addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
                support.titleLabel.font = [UIFont systemFontOfSize:12];
                [cell addSubview:support];
                
                UIButton *downLoad = [UIButton buttonWithType:UIButtonTypeCustom];
                downLoad.frame = CGRectMake(225, 155, 74, 28);
                downLoad.tag = 10004;
                [downLoad setBackgroundImage:[UIImage imageNamed:@"download_video.png"] forState:UIControlStateNormal];
                [downLoad setBackgroundImage:[UIImage imageNamed:@"download_video_pressed.png"] forState:UIControlStateHighlighted];
                [downLoad addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
                downLoad.titleLabel.font = [UIFont systemFontOfSize:14];
                [cell addSubview:downLoad];
                
                UIButton *report = [UIButton buttonWithType:UIButtonTypeCustom];
                report.frame = CGRectMake(15, 155, 96, 28);
                report.tag = 10005;
                [report setBackgroundImage:[UIImage imageNamed:@"report.png"] forState:UIControlStateNormal];
                [report setBackgroundImage:[UIImage imageNamed:@"report_pressed.png"] forState:UIControlStateHighlighted];
                [report addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
                report.titleLabel.font = [UIFont systemFontOfSize:14];
                [cell addSubview:report];
                break;
            }
            case 1:{
//                UIImageView *onLine = [[UIImageView alloc] initWithFrame:CGRectMake(14, 10, 50, 13)];
//                onLine.image = [UIImage imageNamed:@"tab2_detailed_common_writing2.png"];
//                [cell addSubview:onLine];
//                [self showEpisodesplayView];
//                [cell addSubview:scrollView_];
                UIView *view = [self showEpisodes];
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
        
        int num = [relevantList_ count] > 5 ? 5:[relevantList_ count];
        if (indexPath.row == 0) {
            UIImageView *commentV = [[UIImageView alloc] initWithFrame:CGRectMake(14, 5, 50, 14)];
            commentV.image = [UIImage imageNamed:@"tab2_detailed_common_writing1.png"];
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320,25)];
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
            [bgBtn setBackgroundImage:[UIImage imageNamed:@"selectBg.png"] forState:UIControlStateHighlighted];
            [bgBtn addTarget:self action:@selector(didSelect:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:bgBtn];

            NSDictionary *dic = [relevantList_ objectAtIndex:indexPath.row-1];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(45, 2, 200, 20)];
            label.font = [UIFont systemFontOfSize:15];
            label.backgroundColor = [UIColor clearColor];
            label.text = [dic objectForKey:@"t_name"];
            [cell addSubview:label];
            
            UIImageView *push = [[UIImageView alloc] initWithFrame:CGRectMake(288, 8, 6, 10)];
            push.image = [UIImage imageNamed:@"tab2_detailed_common_jian_tou.png"];
            [cell addSubview:push];
    
            if (num != indexPath.row) {
                UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab2_detailed_common_writing4_fenge.png"]];
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
            return 181;
        }
        else if(row == 1){
            return 152;
        }
        else if(row == 2){
            if (moreBtn_.selected) {
                return [self heightForString:summary_ fontSize:13 andWidth:271]+25;
            }
            else{
                return 110;
            }

        }

    }
    else if (indexPath.section == 1){
        if ([relevantList_ count]>0) {
            if (indexPath.row == 0) {
                return 25;
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
        if (indexPath.row == 0) {
            return 20;
        }
        else{
            NSDictionary *item = [commentArray_ objectAtIndex:row -1];
            NSString *content = [item objectForKey:@"content"];
            return [self heightForString:content fontSize:13 andWidth:271]+23;
            
        }

    }
       return 0;
    
}

-(void)didSelect:(UIButton *)btn{
    int num = btn.tag;
    NSDictionary *dic = [relevantList_ objectAtIndex:num];
    ListDetailViewController *listDetail = [[ListDetailViewController alloc] initWithStyle:UITableViewStylePlain];
    listDetail.title = [dic objectForKey:@"t_name"];
    listDetail.topicId = [dic objectForKey:@"t_id"];
    listDetail.Type = 9001;
    [self.navigationController pushViewController:listDetail animated:YES];
    
}
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//   
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    if (indexPath.section == 1) {
//        NSDictionary *dic = [relevantList_ objectAtIndex:indexPath.row -1];
//        ListDetailViewController *listDetail = [[ListDetailViewController alloc] initWithStyle:UITableViewStylePlain];
//        listDetail.topicId = [dic objectForKey:@"t_id"];
//        listDetail.Type = 9000;
//        [listDetail initTopicData:listDetail.topicId];
//        [self.navigationController pushViewController:listDetail animated:YES];
//    }
//    
//}

-(void)Play:(int)number{
    [[CacheUtility sharedCache]putInCache:[NSString stringWithFormat:@"drama_epi_%@", [videoInfo_ objectForKey:@"id"]] result:[NSNumber numberWithInt:number]];
    NSArray *videoUrlArray = [[episodesArr_ objectAtIndex:number] objectForKey:@"down_urls"];
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
//            MediaPlayerViewController *viewController = [[MediaPlayerViewController alloc]initWithNibName:@"MediaPlayerViewController" bundle:nil];
//            viewController.videoUrl = videoUrl;
//            viewController.type = 2;
//            viewController.name = [videoInfo_ objectForKey:@"name"];
//            viewController.prodId = [videoInfo_ objectForKey:@"id"];
//            viewController.currentNum = number;
//            viewController.subname = [NSString stringWithFormat:@"%d", number];
//            [self presentViewController:viewController animated:YES completion:nil];
        }
    }else {
        [self showPlayWebPage];
    }
    [self.tableView reloadData];
}

-(void)playNext:(id)sender{
     
    int total = [episodesArr_ count];
     NSNumber *num = ((NSNotification *)sender).object;
    int nowN = [num intValue];
    nowN++;
    [[CacheUtility sharedCache]putInCache:[NSString stringWithFormat:@"drama_epi_%@", self.prodId] result:[NSNumber numberWithInt:nowN]];
    if (total-1 < nowN) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"亲，没有更多的剧集了。" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
//        [alert show];
        return;
    }
    else{
        [self playVideo:nowN];
        [self.tableView reloadData];
    }
   
}
-(void)action:(id)sender {
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        case 10001:{
            //[self Play:1];
            [self playVideo:0];
            break;
        }
        case 10002:{
            NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: [self.infoDic objectForKey:@"prod_id"], @"prod_id", nil];
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
            NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: [self.infoDic objectForKey:@"prod_id"], @"prod_id", nil];
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
            UIView *modalView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, kFullWindowHeight)];
            modalView.tag = 100002;
            modalView.backgroundColor = [UIColor blackColor];
            modalView.alpha = 0.3;
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close)];
            tapGesture.numberOfTapsRequired = 1;
            tapGesture.numberOfTouchesRequired = 1;
            [modalView addGestureRecognizer:tapGesture];
            UIView *view =  [self showDownLoadEpisodes];
            [[AppDelegate instance].window addSubview:modalView];
            [[AppDelegate instance].window addSubview:view];
            
            CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animation];
            bounceAnimation.duration = 0.2;
            bounceAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            bounceAnimation.values = [NSArray arrayWithObjects:
                                      [NSNumber numberWithFloat:0.01],
                                      //[NSNumber numberWithFloat:1.1],
                                      [NSNumber numberWithFloat:0.9],
                                      [NSNumber numberWithFloat:1],
                                      nil];
            [view.layer addAnimation:bounceAnimation forKey:@"transform.scale"];
            
        break;
        }
        case 10005:{
            
            NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[self.infoDic objectForKey:@"prod_id"], @"prod_id", nil];
            [[AFServiceAPIClient sharedClient] postPath:kPathProgramInvalid parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
//                NSString *responseCode = [result objectForKey:@"res_code"];
//                if([responseCode isEqualToString:kSuccessResCode]){
//                    [self showOpSuccessModalView:1 with:ADDFAV];
//                }
//                else {
//                    [self showOpFailureModalView:1 with:ADDFAV];
//                }
                 [self showOpSuccessModalView:3 with:ADDFAV];
                
            } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                [self showOpFailureModalView:1 with:ADDFAV];
            }];
            
            break;
        }
        default:
            break;
    }
}

-(void)selectToDownLoad:(int)num{

    NSArray *videoUrlArray = [[episodesArr_ objectAtIndex:num] objectForKey:@"down_urls"];
    NSString *videoUrl = nil;
    if(videoUrlArray.count > 0){
        for(NSDictionary *tempVideo in videoUrlArray){
            if([LETV isEqualToString:[tempVideo objectForKey:@"source"]]){
                videoUrl = [self parseDownloadUrl:tempVideo];
                break;
            }
        }
        if(videoUrl == nil){
            videoUrl = [self parseDownloadUrl:[videoUrlArray objectAtIndex:0]];
        }
    }

    if (videoUrl == nil || [videoUrl isEqualToString:@""]) {
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
    NSString *imgUrl =[self.infoDic objectForKey:@"prod_pic_url"];
    if (imgUrl == nil) {
        imgUrl = [self.infoDic objectForKey:@"content_pic_url"];
    }
    NSArray *infoArr = [NSArray arrayWithObjects:prodId,videoUrl,name,imgUrl,@"2",[NSString stringWithFormat:@"%d",num], nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DOWNLOAD_MSG" object:infoArr];
}


-(void)more{
    moreBtn_.selected = !moreBtn_.selected;
    if (moreBtn_.selected) {
        summaryBg_.frame = CGRectMake(14, 20, 292, [self heightForString:summary_ fontSize:13 andWidth:271]+5);
        summaryLabel_.frame = CGRectMake(28, 23, 264,[self heightForString:summary_ fontSize:13 andWidth:271]);
      
    }
    else{
        summaryBg_.frame = CGRectMake(14, 20, 292, 90);
        summaryLabel_.frame = CGRectMake(28, 20, 264,90);
    }
    [self loadTable];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
    
}

- (void)showPlayWebPage
{
//    ProgramViewController *viewController = [[ProgramViewController alloc]initWithNibName:@"ProgramViewController" bundle:nil];
//    NSDictionary *episode = [episodesArr_ objectAtIndex:0];
//    NSArray *videoUrls = [episode objectForKey:@"video_urls"];
//    viewController.programUrl = [[videoUrls objectAtIndex:0] objectForKey:@"url"];
//    viewController.title = [videoInfo_ objectForKey:@"name"];
//    viewController.type = 1;
//    viewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
//    ProgramNavigationController *pro = [[ProgramNavigationController alloc] initWithRootViewController:viewController];
//    [self presentViewController:pro animated:YES completion:nil];
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

-(BOOL)isDownloadUrlEnable:(int)num{
    NSString *downloadUrl = nil;
    
    NSArray *videoUrlArray = [[episodesArr_ objectAtIndex:num] objectForKey:@"down_urls"];
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
    if (downloadUrl == nil) {
        return NO;
    }
    else{
        return YES;
    }
    
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
    }
    if(videoUrl == nil){
        for(NSDictionary *url in urlArray){
            if([BIAO_QING isEqualToString:[url objectForKey:@"type"]]&&[@"mp4" isEqualToString:[url objectForKey:@"file"]]){
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
        }
    }
    if(videoUrl == nil){
        for(NSDictionary *url in urlArray){
            if([CHAO_QING isEqualToString:[url objectForKey:@"type"]]&&[@"mp4" isEqualToString:[url objectForKey:@"file"]]){
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
                
            }
        }
    }
    return videoUrl;
    
    
}

/*
-(void)showEpisodesplayView{
    int count = [episodesArr_ count];
    
    pageCount_ = (count%15 == 0 ? (count/15):(count/15)+1);
    
    scrollView_= [[UIScrollView alloc] initWithFrame:CGRectMake(0, 30, 320, 125)];
    scrollView_.contentSize = CGSizeMake(320*pageCount_, 125);
    scrollView_.pagingEnabled = YES;
    scrollView_.showsHorizontalScrollIndicator = NO; 
    NSString *cacheKey = [NSString stringWithFormat:@"drama_epi_%@",[videoInfo_ objectForKey:@"id"]];
    
    NSString *playNum = [[CacheUtility sharedCache]loadFromCache:cacheKey];
    int lastNum = -1;
    if (playNum != nil) {
        lastNum = [playNum intValue];
    }
    for (int i = 0; i < count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake((i/15)*320+20+(i%5)*59, (i%15/5)*32, 54, 28);
        button.tag = i+1;
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(episodesPlay:) forControlEvents:UIControlEventTouchUpInside];
         button.titleLabel.font = [UIFont systemFontOfSize:12];
        if (lastNum == i) {
             [button setBackgroundImage:[UIImage imageNamed:@"tab2_detailed_tv_number_bg_seen.png"] forState:UIControlStateNormal];
        }
        else{
            [button setTitle:[NSString stringWithFormat:@"%d",i+1] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"tab2_detailed_tv_number_bg.png"] forState:UIControlStateNormal];
           
        }
        [button setBackgroundImage:[UIImage imageNamed:@"tab2_detailed_tv_number_bg_seen_s.png"] forState:UIControlStateHighlighted];
         NSDictionary *oneEpisoder = [episodesArr_ objectAtIndex:i];
        if ([oneEpisoder objectForKey:@"down_urls"]== nil && [oneEpisoder objectForKey:@"video_urls"] == nil) {
            button.enabled = NO;
            [button setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        }
         
      [scrollView_ addSubview:button];
    }
    for (int i = 0;i < pageCount_;i++){
        if (i < pageCount_-1) {
            UIButton *Next = [UIButton buttonWithType:UIButtonTypeCustom];
            Next.frame = CGRectMake( 320 *i+250, 107, 55, 13);
            Next.tag = i+1;
            [Next setTitle:@"后15集>" forState:UIControlStateNormal];
            Next.titleLabel.font = [UIFont systemFontOfSize:12];
            [Next setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [Next addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
            [scrollView_ addSubview:Next];
        }
        
        if (i >=1) {
            UIButton *pre = [UIButton buttonWithType:UIButtonTypeCustom];
            pre.frame = CGRectMake(320*i+20, 107, 55, 13);
            pre.tag = i-1;
            [pre setTitle:@"<前15集" forState:UIControlStateNormal];
            pre.titleLabel.font = [UIFont systemFontOfSize:12];
            [pre setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [pre addTarget:self action:@selector(pre:) forControlEvents:UIControlEventTouchUpInside];
            [scrollView_ addSubview:pre];
        }
        
    }
}
 */

-(UIView *)showEpisodes{
    int count = [episodesArr_ count];
    pageCount_ = (count%15 == 0 ? (count/15):(count/15)+1);
   
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(8,0, 304, 152)];
    bgView.tag = DOWNLOAD_BG;
    bgView.backgroundColor = [UIColor clearColor];
  
    page_ = (count%75 == 0 ? (count/75):(count/75)+1);
    scrollViewUp_ = [[UIScrollView alloc] initWithFrame:CGRectMake(22, 13, 260, 20)];
    scrollViewUp_.backgroundColor = [UIColor clearColor];
    scrollViewUp_.contentSize = CGSizeMake(208*page_, 20);
    scrollViewUp_.pagingEnabled = YES;
    scrollViewUp_.bounces = NO;
    scrollViewUp_.showsHorizontalScrollIndicator = NO;
    [scrollViewUp_ setContentOffset:CGPointMake(260.0f*(currentPage_-1), 0.0f) animated:NO];
    
        
    for (int i = 0; i < pageCount_; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        button.frame = CGRectMake(52*i, 0, 52, 20);
        button.backgroundColor = [UIColor clearColor];
        [button addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
        NSString *title = [NSString stringWithFormat:@"%d-%d集",i*15+1,(i+1)*15];
        if (i == 0) {
            button.selected = YES;
        }
        [button setBackgroundImage:[UIImage imageNamed:@"selected.png"] forState:UIControlStateSelected];
        button.titleLabel.font = [UIFont systemFontOfSize:11];
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateNormal];
        [scrollViewUp_ addSubview:button];
    }
    [bgView addSubview:scrollViewUp_];
    
    
    next_ = [UIButton buttonWithType:UIButtonTypeCustom];
    next_.frame = CGRectMake(272, 13, 25, 20);
    [next_ addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
    [next_ setBackgroundImage:[UIImage imageNamed:@"detail_next.png"] forState:UIControlStateNormal];
 
    
    pre_ = [UIButton buttonWithType:UIButtonTypeCustom];
    pre_.frame = CGRectMake(7, 13, 25, 20);
    [pre_ addTarget:self action:@selector(pre:) forControlEvents:UIControlEventTouchUpInside];
    [pre_ setBackgroundImage:[UIImage imageNamed:@"detail_pre.png"] forState:UIControlStateNormal];
    pre_.enabled = NO;
    
    if (page_ > 1) {
        [bgView addSubview:next_];
        [bgView addSubview:pre_];
    }
    
    scrollViewDown_ = [[UIScrollView alloc] initWithFrame:CGRectMake(11,43, 285, 84)];
    scrollViewDown_.backgroundColor = [UIColor clearColor];
    scrollViewDown_.contentSize = CGSizeMake(285*pageCount_, 84);
    scrollViewDown_.pagingEnabled = YES;
    scrollViewDown_.bounces = NO;
    scrollViewDown_.showsHorizontalScrollIndicator = NO;
    
    NSString *cacheKey = [NSString stringWithFormat:@"drama_epi_%@",[videoInfo_ objectForKey:@"id"]];
    NSString *playNum = [[CacheUtility sharedCache]loadFromCache:cacheKey];
    int lastNum = -1;
    if (playNum != nil) {
        lastNum = [playNum intValue];
    }
    for (int i = 0; i < count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake((i/15)*285+(i%5)*57, (i%15/5)*30, 54, 27);
        button.tag = i+1;
        [button setTitle:[NSString stringWithFormat:@"%d",i+1] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        button.titleLabel.font = [UIFont systemFontOfSize:12];
        [button setBackgroundImage:[UIImage imageNamed:@"tab2_detailed_tv_number_bg.png"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(episodesPlay:) forControlEvents:UIControlEventTouchUpInside];
        if (lastNum == i) {
            [button setTitle:nil forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"tab2_detailed_tv_number_bg_seen.png"] forState:UIControlStateNormal];
        }
        else{
           
            [button setBackgroundImage:[UIImage imageNamed:@"tab2_detailed_tv_number_bg.png"] forState:UIControlStateNormal];
            
        }
        [button setBackgroundImage:[UIImage imageNamed:@"tab2_detailed_tv_number_bg_seen_s.png"] forState:UIControlStateHighlighted];
        NSDictionary *oneEpisoder = [episodesArr_ objectAtIndex:i];
        if ([oneEpisoder objectForKey:@"down_urls"]== nil && [oneEpisoder objectForKey:@"video_urls"] == nil) {
            button.enabled = NO;
            [button setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        }
      
        [scrollViewDown_ addSubview:button];
    }
        [bgView addSubview:scrollViewDown_];

    return bgView;
}

-(UIView *)showDownLoadEpisodes{
    isDownLoad_ = YES;
    int count = [episodesArr_ count];
    pageCount_ = (count%15 == 0 ? (count/15):(count/15)+1);
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(8,0, 304, 152)];
    bgView.tag = DOWNLOAD_BG;
    bgView.backgroundColor = [UIColor clearColor];
    
    
    NSMutableArray *EpisodeIdArr = [NSMutableArray arrayWithCapacity:5];
    bgView.frame = CGRectMake(8,184, 304, 177);
    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,304, 177)];
    bgImgView.image = [UIImage imageNamed:@"download_bg.png"];
    [bgView addSubview:bgImgView];
    
    UIButton *close = [UIButton buttonWithType:UIButtonTypeCustom];
    close.frame = CGRectMake(274, 14, 18, 18);
    [close setBackgroundImage:[UIImage imageNamed:@"download_shut.png"] forState:UIControlStateNormal];
    [close setBackgroundImage:[UIImage imageNamed:@"download_shut_pressed.png"] forState:UIControlStateHighlighted];
    [close addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:close];
    
    for (SubdownloadItem *item in [self readDataFromDB]) {
        NSString *episodeId = [[item.name componentsSeparatedByString:@"_"] lastObject];
        [EpisodeIdArr addObject:episodeId];
    }
    currentPageDownLoad_ = 1;
    page_ = (count%75 == 0 ? (count/75):(count/75)+1);
    scrollViewUpDL_ = [[UIScrollView alloc] initWithFrame:CGRectMake(22, 42, 260, 20)];
    scrollViewUpDL_.backgroundColor = [UIColor clearColor];
    scrollViewUpDL_.contentSize = CGSizeMake(208*page_, 20);
    scrollViewUpDL_.pagingEnabled = YES;
    scrollViewUpDL_.bounces = NO;
    scrollViewUpDL_.showsHorizontalScrollIndicator = NO;
   [scrollViewUpDL_ setContentOffset:CGPointMake(260.0f*(currentPageDownLoad_-1), 0.0f) animated:NO];
        
    for (int i = 0; i < pageCount_; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        button.frame = CGRectMake(52*i, 0, 52, 20);
        button.backgroundColor = [UIColor clearColor];
        [button addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
        NSString *title = [NSString stringWithFormat:@"%d-%d集",i*15+1,(i+1)*15];
        if (i == 0) {
            button.selected = YES;
        }
        [button setBackgroundImage:[UIImage imageNamed:@"selected.png"] forState:UIControlStateSelected];
        button.titleLabel.font = [UIFont systemFontOfSize:11];
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateNormal];
        [scrollViewUpDL_ addSubview:button];
    }
    [bgView addSubview:scrollViewUpDL_];
    
    
    nextDL_ = [UIButton buttonWithType:UIButtonTypeCustom];
    nextDL_.frame = CGRectMake(272, 42, 25, 20);
    [nextDL_ addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
    [nextDL_ setBackgroundImage:[UIImage imageNamed:@"detail_next.png"] forState:UIControlStateNormal];
    
    preDL_ = [UIButton buttonWithType:UIButtonTypeCustom];
    preDL_.frame = CGRectMake(7, 42, 25, 20);
    [preDL_ addTarget:self action:@selector(pre:) forControlEvents:UIControlEventTouchUpInside];
    [preDL_ setBackgroundImage:[UIImage imageNamed:@"detail_pre.png"] forState:UIControlStateNormal];
    preDL_.enabled = NO;
    
    if (page_ > 1) {
        [bgView addSubview:nextDL_];
        [bgView addSubview:preDL_];
    }
    
    scrollViewDownDL_ = [[UIScrollView alloc] initWithFrame:CGRectMake(11, 72, 285, 84)];
    scrollViewDownDL_.backgroundColor = [UIColor clearColor];
    scrollViewDownDL_.contentSize = CGSizeMake(285*pageCount_, 84);
    scrollViewDownDL_.pagingEnabled = YES;
    scrollViewDownDL_.bounces = NO;
    scrollViewDownDL_.showsHorizontalScrollIndicator = NO;
    
    NSString *cacheKey = [NSString stringWithFormat:@"drama_epi_%@",[videoInfo_ objectForKey:@"id"]];
    NSString *playNum = [[CacheUtility sharedCache]loadFromCache:cacheKey];
    int lastNum = -1;
    if (playNum != nil) {
        lastNum = [playNum intValue];
    }
    for (int i = 0; i < count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake((i/15)*285+(i%5)*57, (i%15/5)*30, 54, 27);
        button.tag = i+1;
        [button setTitle:[NSString stringWithFormat:@"%d",i+1] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        button.titleLabel.font = [UIFont systemFontOfSize:12];
        [button addTarget:self action:@selector(download:) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:[UIImage imageNamed:@"undownload.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"downloaded_2.png"] forState:UIControlStateSelected];
        [button setBackgroundImage:[UIImage imageNamed:@"downloaded.png"] forState:UIControlStateHighlighted];
        [button setBackgroundImage:[UIImage imageNamed:@"download_disable.png"] forState:UIControlStateDisabled];
        
        for (NSString *str in EpisodeIdArr) {
            if ([str  intValue] == (i+1)) {
                button.selected = YES;
                [button setTitleEdgeInsets:UIEdgeInsetsMake(3, 20, 13, 20)];
                break;
            }
        }
        
        if ( ![self isDownloadUrlEnable:i]) {
            button.enabled = NO;
        }
        
        [scrollViewDownDL_ addSubview:button];
    }
    [bgView addSubview:scrollViewDownDL_];
    
    return bgView;
}
-(NSArray *)readDataFromDB{
    NSString *itemId = [self.infoDic objectForKey:@"prod_id"];
    if (itemId == nil) {
        itemId = [self.infoDic objectForKey:@"content_id"];
    }
    NSString *subquery = [NSString stringWithFormat:@"WHERE item_id = '%@'",itemId];
    NSArray *tempArr = [SubdownloadItem findByCriteria:subquery];
    return tempArr;

}
-(void)buttonSelected:(UIButton *)btn{
    if (!isDownLoad_) {
        NSArray *subViews = [scrollViewUp_ subviews];
        for (UIView *view in subViews) {
            if ([view isKindOfClass:[UIButton class]]) {
                ((UIButton *)view).selected = NO;
            }
        }
        
        btn.selected = YES;
        int tag = btn.tag;
        [UIView beginAnimations:nil context:NULL];
        
        [UIView setAnimationDuration:0.3f];
        
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        [scrollViewDown_ setContentOffset:CGPointMake(285.0f*tag, 0.0f) animated:YES];
        
        [UIView commitAnimations];
    }
    else{
    
        NSArray *subViews = [scrollViewUpDL_ subviews];
        for (UIView *view in subViews) {
            if ([view isKindOfClass:[UIButton class]]) {
                ((UIButton *)view).selected = NO;
            }
        }
        
        btn.selected = YES;
        int tag = btn.tag;
        [UIView beginAnimations:nil context:NULL];
        
        [UIView setAnimationDuration:0.3f];
        
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        [scrollViewDownDL_ setContentOffset:CGPointMake(285.0f*tag, 0.0f) animated:YES];
        
        [UIView commitAnimations];
    
    
    }
    

}
-(void)close{
    isDownLoad_ = NO;
    NSArray *subViews = [[AppDelegate instance].window subviews];
    for (UIView *view in subViews) {
        if (view.tag == 100001 || view.tag == 100002) {
            [view removeFromSuperview];
        }
    }

}

-(void)next:(id)sender{
    if (!isDownLoad_) {
        currentPage_++;
        [UIView beginAnimations:nil context:NULL];
        
        [UIView setAnimationDuration:0.3f];
        
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        [scrollViewUp_ setContentOffset:CGPointMake(260.0f*(currentPage_-1), 0.0f) animated:YES];
        
        [UIView commitAnimations];
        if (currentPage_ == page_ ) {
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
    else{
        currentPageDownLoad_++;
        [UIView beginAnimations:nil context:NULL];
        
        [UIView setAnimationDuration:0.3f];
        
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        [scrollViewUpDL_ setContentOffset:CGPointMake(260.0f*(currentPageDownLoad_-1), 0.0f) animated:YES];
        
        [UIView commitAnimations];
        if (currentPageDownLoad_ == page_ ) {
            nextDL_.enabled = NO;
        }
        else{
            nextDL_.enabled = YES;
            
        }
        
        if (currentPageDownLoad_ == 1 ) {
            preDL_.enabled = NO;
        }
        else{
            preDL_.enabled = YES;
            
        }

    
    }
    
    

}
-(void)pre:(id)sender{
    if (!isDownLoad_) {
        currentPage_--;
        [UIView beginAnimations:nil context:NULL];
        
        [UIView setAnimationDuration:0.3f];
        
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        [scrollViewUp_ setContentOffset:CGPointMake(260.0f*(currentPage_-1), 0.0f) animated:YES];
        
        [UIView commitAnimations];
        if (currentPage_ == page_ ) {
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
    else{
    
        currentPageDownLoad_--;
        [UIView beginAnimations:nil context:NULL];
        
        [UIView setAnimationDuration:0.3f];
        
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        [scrollViewUpDL_ setContentOffset:CGPointMake(260.0f*(currentPageDownLoad_-1), 0.0f) animated:YES];
        
        [UIView commitAnimations];
        if (currentPageDownLoad_ == page_ ) {
            nextDL_.enabled = NO;
        }
        else{
            nextDL_.enabled = YES;
            
        }
        if (currentPageDownLoad_ == 1 ) {
            preDL_.enabled = NO;
        }
        else{
            preDL_.enabled = YES;
            
        }

    
    
    }
    
   
    
}
-(void)episodesPlay:(id)sender{
    int playNum = ((UIButton *)sender).tag;
    [[CacheUtility sharedCache]putInCache:[NSString stringWithFormat:@"drama_epi_%@", self.prodId] result:[NSNumber numberWithInt:playNum-1]];
    [self playVideo:playNum-1];
    [self.tableView reloadData];
}
-(void)download:(UIButton *)btn{
    if (btn.selected) {
        return;
    }
    btn.selected = YES;
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(3, 20, 13, 20)];
    int downloadNum = btn.tag;
    [self selectToDownLoad:downloadNum-1];

}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    //[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    //[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    [pullToRefreshManager_ tableViewReleased];
}

- (void)MNMBottomPullToRefreshManagerClientReloadTable {
    [self loadComments];
    
}

@end
