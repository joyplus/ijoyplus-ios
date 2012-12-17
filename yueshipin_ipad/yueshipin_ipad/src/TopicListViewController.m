//
//  ListViewController.m
//  yueshipin_ipad
//
//  Created by zhang zhipeng on 12-11-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "TopicListViewController.h"
#import "MovieDetailViewController.h"
#import "DramaDetailViewController.h"
#import "ShowDetailViewController.h"
#import "ListViewController.h"
#import "MyListViewController.h"


@interface TopicListViewController (){
    UITableView *table;
    UIImageView *titleImage;
    NSMutableArray *videoArray;
    MNMBottomPullToRefreshManager *pullToRefreshManager_;
    NSUInteger reloads_;
    int pageSize;
    UIButton *closeBtn;
}

@end

@implementation TopicListViewController

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PERSONAL_VIEW_REFRESH object:nil];
    table = nil;
    titleImage = nil;
    [videoArray removeAllObjects];
    videoArray = nil;
    pullToRefreshManager_ = nil;
    closeBtn = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    titleImage = [[UIImageView alloc]initWithFrame:CGRectMake(LEFT_WIDTH, 35, 62, 26)];
    titleImage.image = [UIImage imageNamed:@"list_title"];
    [self.view addSubview:titleImage];
    
    closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(465, 20, 40, 42);
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
    [closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    
    table = [[UITableView alloc]initWithFrame:CGRectMake(LEFT_WIDTH, 80, 420, self.view.frame.size.height - 370)];
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor = [UIColor clearColor];
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.showsVerticalScrollIndicator = NO;
    [self.view addSubview:table];
    reloads_ = 2;
    pageSize = 10;
    pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:480.0f tableView:table withClient:self];
    [self loadTable];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData:) name:PERSONAL_VIEW_REFRESH object:nil];
}

- (void)refreshData:(NSNotification *)notification
{
    [self retrieveTopsListData];
}

- (void)loadTable {
    [table reloadData];
    [pullToRefreshManager_ tableViewReloadFinished];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self retrieveTopsListData];        
}


- (void)retrieveTopsListData
{       
//    id cacheResult = [[CacheUtility sharedCache] loadFromCache:@"my_topic_list"];
//    if(cacheResult != nil){
//        [self parseVideoData:cacheResult];
//    } else {
//    }
    [myHUD showProgressBar:self.view];
    if([[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: @"1", @"page_num", [NSNumber numberWithInt:pageSize], @"page_size", nil];
        [[AFServiceAPIClient sharedClient] getPath:kPathUserTopics parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [self parseVideoData:result];
            [myHUD hide];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
            [videoArray removeAllObjects];
            [myHUD hide];
        }];
    }
}

- (void)parseVideoData:(id)result
{
    videoArray = [[NSMutableArray alloc]initWithCapacity:10];
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        NSArray *videos = [result objectForKey:@"tops"];
        if(videos != nil && videos.count > 0){
//            [[CacheUtility sharedCache] putInCache:@"my_topic_list" result:result];
            [videoArray addObjectsFromArray:videos];
        }
        if(videos.count < pageSize){
            [pullToRefreshManager_ setPullToRefreshViewVisible:NO];
        } else {
            [pullToRefreshManager_ setPullToRefreshViewVisible:YES];
        }
    }
    [self loadTable];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return videoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(40, 8, 110, 149)];
        imageView.image = [UIImage imageNamed:@"moviecard_list"];
        [cell.contentView addSubview:imageView];
        
        UIImageView *contentImage = [[UIImageView alloc]initWithFrame:CGRectMake(52, 13, 85, 131)];
        contentImage.tag = 1001;
        [cell.contentView addSubview:contentImage];
        
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(160, 12, 250, 25)];
        nameLabel.font = CMConstants.titleFont;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.tag = 2001;
        [cell.contentView addSubview:nameLabel];
        
        UIImageView *typeImage1 = [[UIImageView alloc]initWithFrame:CGRectMake(160, 40, 37, 18)];
        typeImage1.tag = 8001;
        [cell.contentView addSubview:typeImage1];
        
        int posx = 165;
        UIView *dotView1 = [UIUtility getDotView:6];
        dotView1.center = CGPointMake(posx, 55);
        dotView1.tag = 3001;
        [cell.contentView addSubview:dotView1];
        
        UIView *dotView2 = [UIUtility getDotView:6];
        dotView2.center = CGPointMake(posx+140, 55);
        dotView2.tag = 3002;
        [cell.contentView addSubview:dotView2];
        
        UIView *dotView3 = [UIUtility getDotView:6];
        dotView3.center = CGPointMake(posx, 80);
        dotView3.tag = 3003;
        [cell.contentView addSubview:dotView3];
        
        UIView *dotView4 = [UIUtility getDotView:6];
        dotView4.center = CGPointMake(posx+140, 80);
        dotView4.tag = 3004;
        [cell.contentView addSubview:dotView4];
        
        UIView *dotView5 = [UIUtility getDotView:6];
        dotView5.center = CGPointMake(posx, 105);
        dotView5.tag = 3005;
        [cell.contentView addSubview:dotView5];
        
        UIView *dotView6 = [UIUtility getDotView:6];
        dotView6.center = CGPointMake(posx+140, 105);
        dotView6.tag = 3006;
        [cell.contentView addSubview:dotView6];
        
        UIView *dotView7 = [UIUtility getDotView:6];
        dotView7.center = CGPointMake(posx, 130);
        dotView7.tag = 3007;
        [cell.contentView addSubview:dotView7];
        
        for (int i = 0; i < 3; i++){
            UIView *dotView8 = [UIUtility getDotView:4];
            dotView8.center = CGPointMake(posx+140 + i * 6, 130);
            dotView8.tag = 3008 + i;
            [cell.contentView addSubview:dotView8];
        }
        
        UILabel *name1 = [[UILabel alloc]initWithFrame:CGRectMake(posx+15, 42, 110, 25)];
        name1.font =[UIFont systemFontOfSize:14];
        name1.backgroundColor = [UIColor clearColor];
        [name1 setTextColor:CMConstants.grayColor];
        name1.tag = 4001;
        [cell.contentView addSubview:name1];
        
        UILabel *name2 = [[UILabel alloc]initWithFrame:CGRectMake(posx+155, 42, 110, 25)];
        name2.font = [UIFont systemFontOfSize:14];
        name2.backgroundColor = [UIColor clearColor];
        [name2 setTextColor:CMConstants.grayColor];
        name2.tag = 4002;
        [cell.contentView addSubview:name2];
        
        UILabel *name3 = [[UILabel alloc]initWithFrame:CGRectMake(posx+15, 67, 110, 25)];
        name3.font =[UIFont systemFontOfSize:14];
        name3.backgroundColor = [UIColor clearColor];
        [name3 setTextColor:CMConstants.grayColor];
        name3.tag = 4003;
        [cell.contentView addSubview:name3];
        
        UILabel *name4 = [[UILabel alloc]initWithFrame:CGRectMake(posx+155, 67, 110, 25)];
        name4.font =[UIFont systemFontOfSize:14];
        name4.backgroundColor = [UIColor clearColor];
        [name4 setTextColor:CMConstants.grayColor];
        name4.tag = 4004;
        [cell.contentView addSubview:name4];
        
        UILabel *name5 = [[UILabel alloc]initWithFrame:CGRectMake(posx+15, 91, 110, 25)];
        name5.font =[UIFont systemFontOfSize:14];
        name5.backgroundColor = [UIColor clearColor];
        [name5 setTextColor:CMConstants.grayColor];
        name5.tag = 4005;
        [cell.contentView addSubview:name5];
        
        UILabel *name6 = [[UILabel alloc]initWithFrame:CGRectMake(posx+155, 91, 110, 25)];
        name6.font =[UIFont systemFontOfSize:14];
        name6.backgroundColor = [UIColor clearColor];
        [name6 setTextColor:CMConstants.grayColor];
        name6.tag = 4006;
        [cell.contentView addSubview:name6];
        
        UILabel *name7 = [[UILabel alloc]initWithFrame:CGRectMake(posx+15, 115, 110, 25)];
        name7.font =[UIFont systemFontOfSize:14];
        name7.backgroundColor = [UIColor clearColor];
        [name7 setTextColor:CMConstants.grayColor];
        name7.tag = 4007;
        [cell.contentView addSubview:name7];
        
        UIImageView *devidingLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, 158, table.frame.size.width, 2)];
        devidingLine.image = [UIImage imageNamed:@"dividing"];
        [cell.contentView addSubview:devidingLine];        
    }
    NSDictionary *item = [videoArray objectAtIndex:indexPath.row];
    UIImageView *contentImage = (UIImageView *)[cell viewWithTag:1001];
    [contentImage setImageWithURL:[NSURL URLWithString:[item objectForKey:@"pic_url"]] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:2001];
    nameLabel.text = [item objectForKey:@"name"];
    
    NSString *type = [NSString stringWithFormat:@"%@", [item objectForKey:@"prod_type"]];
    UIImageView *typeImage1 = (UIImageView *)[cell viewWithTag:8001];
    if([type isEqualToString:@"1"]){
        typeImage1.image = [UIImage imageNamed:@"movie_type"];
    } else if([type isEqualToString:@"2"]){
        typeImage1.image = [UIImage imageNamed:@"drama_type"];
    } else {
        typeImage1.image = [UIImage imageNamed:@"show_type"];
    }

    NSArray *videos = [item objectForKey:@"items"];
    for(int i = 0; i < 7; i++){
        UIView *dotView =  (UIView *)[cell viewWithTag:3001 + i];
        UILabel *label = (UILabel *)[cell viewWithTag:4001 + i];
        if(i < videos.count){
            dotView.backgroundColor = CMConstants.grayColor;
            label.text = [[videos objectAtIndex:i] objectForKey:@"prod_name"];
        } else {
            label.text = @"";
            dotView.backgroundColor = [UIColor clearColor];
        }
    }
    if(videos.count < 7){
        for (int i = 0; i < 3; i++){
            UIView *dotView8 = (UIView *)[cell viewWithTag:3008 + i];
            dotView8.backgroundColor = [UIColor clearColor];
        }
    } 

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 160;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [table deselectRowAtIndexPath:indexPath animated:YES];
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([hostReach currentReachabilityStatus] == NotReachable) {
        [UIUtility showNetWorkError:self.view];
        return;
    }
    MyListViewController *viewController = [[MyListViewController alloc] init];
    viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
    NSDictionary *item = [videoArray objectAtIndex:indexPath.row];
    NSString *topId = [NSString stringWithFormat:@"%@", [item objectForKey: @"id"]];
    viewController.type = [[NSString stringWithFormat:@"%@", [item objectForKey:@"prod_type"]]intValue];
    viewController.topId = topId;
    viewController.listTitle = [item objectForKey: @"name"];
    viewController.fromViewController = self;
    [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:YES moveToLeft:self.moveToLeft];
    self.moveToLeft = NO;
}

#pragma mark -
#pragma mark MNMBottomPullToRefreshManagerClient

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [pullToRefreshManager_ tableViewScrolled];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [pullToRefreshManager_ tableViewReleased];
}

- (void)MNMBottomPullToRefreshManagerClientReloadTable {
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [UIUtility showNetWorkError:self.view];
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:2.0f];
        return;
    }
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:reloads_], @"page_num", [NSNumber numberWithInt:pageSize], @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathUserTopics parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        NSArray *tempArray;
        if(responseCode == nil){
            tempArray = [result objectForKey:@"tops"];
            if(tempArray.count > 0){
                [videoArray addObjectsFromArray:tempArray];
                reloads_ ++;
            }
        } else {
            
        }
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:0.0f];
        if(tempArray.count < pageSize){
            [pullToRefreshManager_ setPullToRefreshViewVisible:NO];
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:0.0f];
    }];
}
@end
