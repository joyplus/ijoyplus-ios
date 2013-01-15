//
//  TVDetailViewController.m
//  yueshipin
//
//  Created by 08 on 12-12-28.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "TVDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "CacheUtility.h"
#import "CMConstants.h"
#import "MediaPlayerViewController.h"
#import "AppDelegate.h"
#import "ProgramViewController.h"
#import "MBProgressHUD.h"
#import "UIImage+Scale.h"
#import "SendWeiboViewController.h"
#import "ListDetailViewController.h"
#import "ProgramNavigationController.h"
#import "CacheUtility.h"
@interface TVDetailViewController ()

@end

@implementation TVDetailViewController

@synthesize infoDic = infoDic_;
@synthesize videoInfo = videoInfo_;
@synthesize episodesArr = episodesArr_;
@synthesize videoType = videoType_;
@synthesize summary = summary_;
@synthesize scrollView = scrollView_;
@synthesize commentArray =commentArray_;
@synthesize relevantList = relevantList_;
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
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 40, 30);
    backButton.backgroundColor = [UIColor clearColor];
    [backButton setImage:[UIImage imageNamed:@"top_return_common.png"] forState:UIControlStateNormal];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
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
    
    self.title = [self.infoDic objectForKey:@"prod_name"];
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
        NSLog(@"episodes count is %d",[episodesArr_ count]);
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

//- (void)loadComments
//{
//    commentArray_ = [NSMutableArray arrayWithCapacity:10];
//    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[self.infoDic objectForKey:@"prod_id"], @"prod_id", nil];
//    [[AFServiceAPIClient sharedClient] getPath:kPathProgramView parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
//        NSString *responseCode = [result objectForKey:@"res_code"];
//        if(responseCode == nil){
//            NSString *key = [NSString stringWithFormat:@"%@%@", @"tv", [self.infoDic objectForKey:@"prod_id"]];
//            [[CacheUtility sharedCache] putInCache:key result:result];
//            NSArray *tempArray = (NSMutableArray *)[result objectForKey:@"comments"];
//            [commentArray_ removeAllObjects];
//            if(tempArray != nil && tempArray.count > 0){
//                [commentArray_ addObjectsFromArray:tempArray];
//            }
//            [self.tableView reloadData];
//        }
//    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
//        
//    }];
//}

-(void)loadComments{
    NSString *itemId = [self.infoDic objectForKey:@"prod_id"];
    if (itemId == nil) {
        itemId = [self.infoDic objectForKey:@"content_id"];
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
        return [relevantList_ count] > 5 ? 5:[relevantList_ count];
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
                
                UILabel *areaLabel = [[UILabel alloc] initWithFrame:CGRectMake(116, 74, 200, 15)];
                areaLabel.font = [UIFont systemFontOfSize:12];
                areaLabel.textColor = [UIColor grayColor];
                areaLabel.backgroundColor = [UIColor clearColor];
                areaLabel.text = [NSString stringWithFormat:@"地区: %@",area];
                
                UILabel *directorLabel = [[UILabel alloc] initWithFrame:CGRectMake(116, 89, 200, 15)];
                directorLabel.font = [UIFont systemFontOfSize:12];
                directorLabel.textColor = [UIColor grayColor];
                directorLabel.backgroundColor = [UIColor clearColor];
                directorLabel.text = [NSString stringWithFormat:@"导演: %@",directors];
                
                UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(116, 104, 200, 15)];
                dateLabel.font = [UIFont systemFontOfSize:12];
                dateLabel.textColor = [UIColor grayColor];
                dateLabel.backgroundColor = [UIColor clearColor];
                dateLabel.text = [NSString stringWithFormat:@"年代: %@",date];
                
                
                [cell addSubview:actorsLabel];
                [cell addSubview:areaLabel];
                [cell addSubview:directorLabel];
                [cell addSubview:dateLabel];;
                
                UIButton *play = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                play.frame = CGRectMake(115, 28, 87, 27);
                play.tag = 10001;
                //[play setTitle:@"播放视频" forState:UIControlStateNormal];
                [play setImage:[UIImage imageNamed:@"tab2_detailed_common_play_video.png"] forState:UIControlStateNormal];
                [play setImage:[UIImage imageNamed:@"tab2_detailed_common_play_video_s.png"] forState:UIControlStateHighlighted];
                [play addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:play];
                
                UIButton *addFav = [UIButton buttonWithType:UIButtonTypeCustom];
                addFav.frame = CGRectMake(14, 152, 142, 27);
                addFav.tag = 10002;
                [addFav setBackgroundImage:[UIImage imageNamed:@"tab2_detailed_common_favorite&recommend.png"] forState:UIControlStateNormal];
                [addFav setBackgroundImage:[UIImage imageNamed:@"tab2_detailed_common_favorite&recommend_s.png"] forState:UIControlStateHighlighted];
                [addFav setImage:[UIImage imageNamed:@"tab2_detailed_common_icon_favorite.png"]forState:UIControlStateNormal];
                [addFav setImage:[UIImage imageNamed:@"tab2_detailed_common_icon_favorite_s.png"] forState:UIControlStateHighlighted];
                [addFav setTitle:[NSString stringWithFormat:@"收藏（%d）",favCount_]  forState:UIControlStateNormal];
                [addFav setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [addFav addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
                addFav.titleLabel.font = [UIFont systemFontOfSize:14];
                [cell addSubview:addFav];
                
                UIButton *support = [UIButton buttonWithType:UIButtonTypeCustom];
                support.frame = CGRectMake(165, 152, 142, 27);
                support.tag = 10003;
                [support setBackgroundImage:[UIImage imageNamed:@"tab2_detailed_common_favorite&recommend.png"] forState:UIControlStateNormal];
                [support setBackgroundImage:[UIImage imageNamed:@"tab2_detailed_common_favorite&recommend_s.png"] forState:UIControlStateHighlighted];
                [support setImage: [UIImage imageNamed:@"tab2_detailed_common_icon_recommend.png"] forState:UIControlStateNormal];
                [support setImage:[UIImage imageNamed:@"tab2_detailed_common_icon_recommend_s.png"] forState:UIControlStateHighlighted];
                [support setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [support setTitle:[NSString stringWithFormat:@"顶（%d）",supportCount_] forState:UIControlStateNormal];
                [support addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
                support.titleLabel.font = [UIFont systemFontOfSize:14];
                [cell addSubview:support];
                break;
            }
            case 1:{
                UIImageView *onLine = [[UIImageView alloc] initWithFrame:CGRectMake(14, 10, 50, 13)];
                onLine.image = [UIImage imageNamed:@"tab2_detailed_common_writing2.png"];
                [cell addSubview:onLine];
                [self showEpisodesplayView];
                [cell addSubview:scrollView_];
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
            UIImageView *commentV = [[UIImageView alloc] initWithFrame:CGRectMake(14, 5, 50, 14)];
            commentV.image = [UIImage imageNamed:@"tab2_detailed_common_writing1.png"];
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320,25)];
            [view addSubview:commentV];
            [cell addSubview:view];
        }
        else{
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(14, 0, 292, 26)];
            view.backgroundColor = [UIColor whiteColor];
            [cell addSubview:view];
            NSDictionary *dic = [relevantList_ objectAtIndex:indexPath.row-1];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(45, 2, 200, 20)];
            label.font = [UIFont systemFontOfSize:15];
            label.backgroundColor = [UIColor clearColor];
            label.text = [dic objectForKey:@"t_name"];
            [cell addSubview:label];
            
            UIImageView *push = [[UIImageView alloc] initWithFrame:CGRectMake(288, 8, 6, 10)];
            push.image = [UIImage imageNamed:@"tab2_detailed_common_jian_tou.png"];
            [cell addSubview:push];
            
            int num = [relevantList_ count] > 5 ? 5:[relevantList_ count];
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
            return 155;
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        NSDictionary *dic = [relevantList_ objectAtIndex:indexPath.row -1];
        ListDetailViewController *listDetail = [[ListDetailViewController alloc] initWithStyle:UITableViewStylePlain];
        listDetail.topicId = [dic objectForKey:@"t_id"];
        listDetail.Type = 9000;
        [listDetail initTopicData:listDetail.topicId];
        [self.navigationController pushViewController:listDetail animated:YES];
    }
    
}

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
            MediaPlayerViewController *viewController = [[MediaPlayerViewController alloc]initWithNibName:@"MediaPlayerViewController" bundle:nil];
            viewController.videoUrl = videoUrl;
            viewController.type = 2;
            viewController.name = [videoInfo_ objectForKey:@"name"];
            viewController.prodId = [videoInfo_ objectForKey:@"id"];
            viewController.currentNum = number;
            viewController.subname = [NSString stringWithFormat:@"%d", number];
            [self presentViewController:viewController animated:YES completion:nil];
        }
    }else {
        [self showPlayWebPage];
    }
    [self.tableView reloadData];
}
-(void)action:(id)sender {
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        case 10001:{
            [self Play:1];
            break;
        }
        case 10002:{
            NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: [self.infoDic objectForKey:@"prod_id"], @"prod_id", nil];
            [[AFServiceAPIClient sharedClient] postPath:kPathProgramFavority parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
                NSString *responseCode = [result objectForKey:@"res_code"];
                if([responseCode isEqualToString:kSuccessResCode]){
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshFav"object:nil];
                    favCount_++;
                    [self showOpSuccessModalView:1 with:ADDFAV];
                    [self.tableView reloadData];
                } else {
                    [self showOpFailureModalView:1 with:ADDFAV];

                }
                
            } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                   [self showOpFailureModalView:1 with:ADDFAV];
       
            }];
            
            
            break;
        }
        case 10003:{
            NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: [self.infoDic objectForKey:@"prod_id"], @"prod_id", nil];
            [[AFServiceAPIClient sharedClient] postPath:kPathSupport parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
                NSString *responseCode = [result objectForKey:@"res_code"];
                if([responseCode isEqualToString:kSuccessResCode]){
                    supportCount_ ++;
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
            
        default:
            break;
    }
}
-(void)more{
    moreBtn_.selected = !moreBtn_.selected;
    if (moreBtn_.selected) {
        summaryBg_.frame = CGRectMake(14, 20, 292, [self heightForString:summary_ fontSize:13 andWidth:271]+5);
        summaryLabel_.frame = CGRectMake(28, 23, 264,[self heightForString:summary_ fontSize:13 andWidth:271]);
       // moreBtn_.frame = CGRectMake(288, [self heightForString:summary_ fontSize:13 andWidth:271], 18, 14);
        
    }
    else{
        summaryBg_.frame = CGRectMake(14, 20, 292, 90);
        summaryLabel_.frame = CGRectMake(28, 20, 264,90);
       // moreBtn_.frame = CGRectMake(288, 90, 18, 14);
    }
    [self loadTable];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
    
}

- (void)showPlayWebPage
{
    ProgramViewController *viewController = [[ProgramViewController alloc]initWithNibName:@"ProgramViewController" bundle:nil];
    NSDictionary *episode = [episodesArr_ objectAtIndex:0];
    NSArray *videoUrls = [episode objectForKey:@"video_urls"];
    viewController.programUrl = [[videoUrls objectAtIndex:0] objectForKey:@"url"];
    viewController.title = [videoInfo_ objectForKey:@"name"];
    viewController.type = 1;
    viewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    ProgramNavigationController *pro = [[ProgramNavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:pro animated:YES completion:nil];
    //[self presentViewController:[[UINavigationController alloc] initWithRootViewController:viewController] animated:YES completion:nil];
    
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

-(void)next:(id)sender{
    
    int tag = ((UIButton *)sender).tag;
    [UIView beginAnimations:nil context:NULL];
    
    [UIView setAnimationDuration:0.3f];
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    [self.scrollView setContentOffset:CGPointMake(320.0f*tag, 0.0f) animated:YES];
    
    [UIView commitAnimations];

}
-(void)pre:(id)sender{
    
    int tag = ((UIButton *)sender).tag;
    [UIView beginAnimations:nil context:NULL];
    
    [UIView setAnimationDuration:0.3f];
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    [self.scrollView setContentOffset:CGPointMake(320.0f*tag, 0.0f) animated:YES];

    
    [UIView commitAnimations];
    
}
-(void)episodesPlay:(id)sender{
    int playNum = ((UIButton *)sender).tag;
    
    [self Play:playNum-1];

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
