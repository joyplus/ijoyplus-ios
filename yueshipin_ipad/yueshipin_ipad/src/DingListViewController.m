//
//  ListViewController.m
//  yueshipin_ipad
//
//  Created by zhang zhipeng on 12-11-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "DingListViewController.h"
#import "MovieDetailViewController.h"
#import "DramaDetailViewController.h"
#import "ShowDetailViewController.h"

@interface DingListViewController (){
    UITableView *table;
    UIImageView *titleImage;
    NSMutableArray *videoArray;
    MNMBottomPullToRefreshManager *pullToRefreshManager_;
    NSUInteger reloads_;
    int pageSize;
    UIButton *closeBtn;
}

@end

@implementation DingListViewController

- (void)viewDidUnload
{
    [super viewDidUnload];
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
    titleImage.image = [UIImage imageNamed:@"push_title"];
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
}

- (void)loadTable {
    [table reloadData];
    [pullToRefreshManager_ tableViewReloadFinished];
}


- (void)viewWillAppear:(BOOL)animated
{
    if(videoArray.count > 0){
    } else {
        [self retrieveTopsListData];
    }
}


- (void)retrieveTopsListData
{
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:@"my_support_list"];
    if(cacheResult != nil){
        [self parseVideoData:cacheResult];
    } else {
        [myHUD showProgressBar:self.view];
    }
    if([[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: @"1", @"page_num", [NSNumber numberWithInt:pageSize], @"page_size", nil];
        [[AFServiceAPIClient sharedClient] getPath:kPathUserSupport parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
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
        NSArray *videos = [result objectForKey:@"support"];
        if(videos != nil && videos.count > 0){
            [videoArray addObjectsFromArray:videos];
        }
        [[CacheUtility sharedCache] putInCache:@"my_support_list" result:result];
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
    if(videoArray.count > 0){
        return videoArray.count;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(videoArray.count > 0){
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 8, 102, 146)];
            imageView.image = [UIImage imageNamed:@"movie_frame"];
            [cell.contentView addSubview:imageView];
            
            UIImageView *contentImage = [[UIImageView alloc]initWithFrame:CGRectMake(4, 12, 94, 138)];
            contentImage.image = [UIImage imageNamed:@"test_movie"];
            contentImage.tag = 1001;
            [cell.contentView addSubview:contentImage];
            
            UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(120, 12, 306, 25)];
            nameLabel.font = CMConstants.titleFont;
            nameLabel.backgroundColor = [UIColor clearColor];
            nameLabel.tag = 2001;
            [cell.contentView addSubview:nameLabel];
            
            //        for (int i = 0; i < 5; i++){
            //            UIImageView *startImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"empty_star"]];
            //            startImage.frame = CGRectMake(160 + (16 + 5) * i, 48, 16, 16);
            //            startImage.tag = 3001 + i;
            //            [cell.contentView addSubview:startImage];
            //        }
            
            UILabel *scoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(120, 45, 45, 20)];
            scoreLabel.tag = 3001;
            scoreLabel.text = @"0 分";
            scoreLabel.backgroundColor = [UIColor clearColor];
            scoreLabel.font = [UIFont boldSystemFontOfSize:15];
            scoreLabel.textColor = CMConstants.scoreBlueColor;
            [cell.contentView addSubview:scoreLabel];
            UIImageView *doubanLogo = [[UIImageView alloc]initWithFrame:CGRectMake(170, 48, 15, 15)];
            doubanLogo.tag = 9001;
            [cell.contentView addSubview:doubanLogo];
            
            UILabel *directorLabel = [[UILabel alloc]initWithFrame:CGRectZero];
            directorLabel.tag = 4011;
            directorLabel.textColor = CMConstants.grayColor;
            directorLabel.font = [UIFont systemFontOfSize:13];
            directorLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:directorLabel];
            
            UILabel *directorNameLabel = [[UILabel alloc]initWithFrame:CGRectZero];
            directorNameLabel.font = [UIFont systemFontOfSize:13];
            directorNameLabel.textColor = CMConstants.grayColor;
            directorNameLabel.backgroundColor = [UIColor clearColor];
            directorNameLabel.tag = 4001;
            [cell.contentView addSubview:directorNameLabel];
            
            UILabel *actorLabel = [[UILabel alloc]initWithFrame:CGRectZero];
            actorLabel.tag = 5011;
            actorLabel.textColor = CMConstants.grayColor;
            actorLabel.font = [UIFont systemFontOfSize:13];
            actorLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:actorLabel];
            
            UILabel *actorName1Label = [[UILabel alloc]initWithFrame:CGRectZero];
            actorName1Label.font = [UIFont systemFontOfSize:13];
            actorName1Label.textColor = CMConstants.grayColor;
            actorName1Label.backgroundColor = [UIColor clearColor];
            actorName1Label.tag = 5001;
            [cell.contentView addSubview:actorName1Label];
            
            UILabel *areaLabel = [[UILabel alloc]initWithFrame:CGRectMake(120, 100, 220, 25)];
            areaLabel.font = [UIFont systemFontOfSize:13];
            areaLabel.textColor = CMConstants.grayColor;
            areaLabel.backgroundColor = [UIColor clearColor];
            areaLabel.tag = 8001;
            [cell.contentView addSubview:areaLabel];
            
            UILabel *areaNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(185, 100, 220, 25)];
            areaNameLabel.font = [UIFont systemFontOfSize:13];
            areaNameLabel.textColor = CMConstants.grayColor;
            areaNameLabel.backgroundColor = [UIColor clearColor];
            areaNameLabel.tag = 8002;
            [cell.contentView addSubview:areaNameLabel];
            
            UIImageView *dingNumberImage = [[UIImageView alloc]initWithFrame:CGRectMake(120, 130, 75, 24)];
            dingNumberImage.image = [UIImage imageNamed:@"pushinguser"];
            [cell.contentView addSubview:dingNumberImage];
            
            UILabel *dingNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(125, 130, 40, 24)];
            dingNumberLabel.textAlignment = NSTextAlignmentCenter;
            dingNumberLabel.backgroundColor = [UIColor clearColor];
            dingNumberLabel.font = [UIFont systemFontOfSize:13];
            dingNumberLabel.tag = 6001;
            [cell.contentView addSubview:dingNumberLabel];
            
            UIImageView *collectioNumber = [[UIImageView alloc]initWithFrame:CGRectMake(210, 130, 84, 24)];
            collectioNumber.image = [UIImage imageNamed:@"collectinguser"];
            [cell.contentView addSubview:collectioNumber];
            
            UILabel *collectionNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(215, 130, 40, 24)];
            collectionNumberLabel.textAlignment = NSTextAlignmentCenter;
            collectionNumberLabel.backgroundColor = [UIColor clearColor];
            collectionNumberLabel.font = [UIFont systemFontOfSize:13];
            collectionNumberLabel.tag = 7001;
            [cell.contentView addSubview:collectionNumberLabel];
            
            UIImageView *devidingLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, 158, table.frame.size.width, 2)];
            devidingLine.image = [UIImage imageNamed:@"dividing"];
            [cell.contentView addSubview:devidingLine];
        }
        NSDictionary *item = [videoArray objectAtIndex:indexPath.row];
        UIImageView *contentImage = (UIImageView *)[cell viewWithTag:1001];
        [contentImage setImageWithURL:[NSURL URLWithString:[item objectForKey:@"content_pic_url"]] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
        
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:2001];
        nameLabel.text = [item objectForKey:@"content_name"];
        
        UILabel *directorNameLabel = (UILabel *)[cell viewWithTag:4001];
        
        UILabel *actorLabel = (UILabel *)[cell viewWithTag:5001];
        
        UILabel *scoreLabel = (UILabel *)[cell viewWithTag:3001];
        UIImageView *doubanlogo = (UIImageView *)[cell viewWithTag:9001];
        UILabel *directorLabel = (UILabel *)[cell viewWithTag:4011];
        UILabel *actorLabel1 = (UILabel *)[cell viewWithTag:5011];
        UILabel *areaLabel = (UILabel *)[cell viewWithTag:8001];
        UILabel *areaNameLabel = (UILabel *)[cell viewWithTag:8002];
        NSString *type = [NSString stringWithFormat:@"%@", [item objectForKey:@"content_type"]];
        if([type isEqualToString:@"3"]){
            areaLabel.text = @"地区：";
            areaNameLabel.text = [NSString stringWithFormat:@"%@", [item objectForKey:@"area"]];
            scoreLabel.text = @"";
            doubanlogo.image = nil;
            directorLabel.frame = CGRectMake(120, 50, 150, 25);
            directorLabel.text = @"主持/嘉宾：";
            directorNameLabel.frame = CGRectMake(185, 50, 250, 25);
            directorNameLabel.text = [item objectForKey:@"stars"];
            actorLabel.frame = CGRectMake(185, 75, 250, 25);
            actorLabel1.text = @"首播时间：";
            actorLabel1.frame = CGRectMake(120, 75, 250, 25);
            actorLabel.text = [item objectForKey:@"publish_date"];
        } else {
            scoreLabel.text = [NSString stringWithFormat:@"%@ 分", [item objectForKey:@"score"]];
            doubanlogo.image = [UIImage imageNamed:@"douban"];
            directorLabel.frame = CGRectMake(120, 75, 150, 25);
            actorLabel.frame = CGRectMake(120, 100, 150, 25);
            directorLabel.text = @"导演：";
            directorNameLabel.frame = CGRectMake(165, 75, 250, 25);
            directorNameLabel.text = [item objectForKey:@"directors"];
            actorLabel.frame = CGRectMake(165, 100, 250, 25);
            actorLabel1.text = @"主演：";
            actorLabel1.frame = CGRectMake(120, 100, 250, 25);
            actorLabel.text = [item objectForKey:@"stars"];
            
            areaLabel.text = @"";
            areaNameLabel.text = @"";
        }
        
        UILabel *dingNumberLabel = (UILabel *)[cell viewWithTag:6001];
        dingNumberLabel.text = [NSString stringWithFormat:@"%@", [item objectForKey:@"support_num"]];
        
        UILabel *collectionNumberLabel = (UILabel *)[cell viewWithTag:7001];
        collectionNumberLabel.text = [NSString stringWithFormat:@"%@", [item objectForKey:@"favority_num"]];
        return cell;
    } else {
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"no record"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImageView *norecord = [[UIImageView alloc]initWithFrame:CGRectMake(80, 0, 250, 250)];
        norecord.image = [UIImage imageNamed:@"noding"];
        [cell.contentView addSubview:norecord];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 160;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(videoArray.count > 0){
        [table deselectRowAtIndexPath:indexPath animated:YES];
        NSDictionary *item = [videoArray objectAtIndex:indexPath.row];
        NSString *type = [NSString stringWithFormat:@"%@", [item objectForKey:@"content_type"]];
        NSString *prodId = [NSString stringWithFormat:@"%@", [item objectForKey:@"content_id"]];
        if([type isEqualToString:@"1"]){
            MovieDetailViewController *viewController = [[MovieDetailViewController alloc] initWithNibName:@"MovieDetailViewController" bundle:nil];
            viewController.prodId = prodId;
            viewController.fromViewController = self;
            viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
            [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:YES moveToLeft:self.moveToLeft];
        } else if([type isEqualToString:@"2"]){
            DramaDetailViewController *viewController = [[DramaDetailViewController alloc] initWithNibName:@"DramaDetailViewController" bundle:nil];
            viewController.prodId = prodId;
            viewController.fromViewController = self;
            viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
            [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:YES moveToLeft:self.moveToLeft];
        } else {
            ShowDetailViewController *viewController = [[ShowDetailViewController alloc] initWithNibName:@"ShowDetailViewController" bundle:nil];
            viewController.prodId = prodId;
            viewController.fromViewController = self;
            viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
            [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:YES moveToLeft:self.moveToLeft];
        }
        self.moveToLeft = NO;
    }
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
    [[AFServiceAPIClient sharedClient] getPath:kPathUserSupport parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        NSArray *tempArray;
        if(responseCode == nil){
            tempArray = [result objectForKey:@"support"];
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
