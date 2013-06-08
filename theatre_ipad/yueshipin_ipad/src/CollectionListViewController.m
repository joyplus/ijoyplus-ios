//
//  ListViewController.m
//  yueshipin_ipad
//
//  Created by zhang zhipeng on 12-11-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "CollectionListViewController.h"
#import "MovieDetailViewController.h"
#import "DramaDetailViewController.h"
#import "ShowDetailViewController.h"
#import <Parse/Parse.h>
@interface CollectionListViewController (){
    UITableView *table;
    UIImageView *titleImage;
    NSMutableArray *videoArray;
    PullRefreshManagerClinet *pullToRefreshManager_;
    NSUInteger reloads_;
    int pageSize;
    UIButton *closeBtn;
}

@end

@implementation CollectionListViewController

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
    self.bgImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.frame.size.height)];
    self.bgImage.image = [UIImage imageNamed:@"left_background@2x.jpg"];
    [self.view addSubview:self.bgImage];
    
    titleImage = [[UIImageView alloc]initWithFrame:CGRectMake(LEFT_WIDTH, 35, 132, 42)];
    titleImage.image = [UIImage imageNamed:@"collect_title"];
    [self.view addSubview:titleImage];
    
    closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(456, 0, 50, 50);
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
    [closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    
    table = [[UITableView alloc]initWithFrame:CGRectMake(LEFT_WIDTH, 80, 420, self.view.frame.size.height - 390)];
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor = [UIColor clearColor];
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.showsVerticalScrollIndicator = NO;
    [self.view addSubview:table];
    reloads_ = 2;
    pageSize = 10;
    pullToRefreshManager_ = [[PullRefreshManagerClinet alloc] initWithTableView:table];
    pullToRefreshManager_.delegate =self;
    [pullToRefreshManager_ setShowHeaderView:NO];
    
    [self loadTable];
    
    [self.view addGestureRecognizer:self.swipeRecognizer];
}

- (void)loadTable {
    [table reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    if(videoArray.count > 0){
    } else {
        [self retrieveTopsListData];
    }
    [MobClick beginLogPageView:COLLECTION_LIST];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:COLLECTION_LIST];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"collectionListViewDisappear" object:self userInfo:nil];
}


- (void)retrieveTopsListData
{
    BOOL isReachable = [[AppDelegate instance] performSelector:@selector(isParseReachable)];
    if(!isReachable) {
        [UIUtility showNetWorkError:self.view];
    }
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:@"my_collection_list"];
    if(cacheResult != nil){
        [self parseVideoData:cacheResult];
    } else {
        if(isReachable) {
            [myHUD showProgressBar:self.view];
        }
    }
    if([[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: @"1", @"page_num", [NSNumber numberWithInt:pageSize], @"page_size", nil];
        [[AFServiceAPIClient sharedClient] getPath:kPathUserFavorities parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [self parseVideoData:result];
            [myHUD hide];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
            [myHUD hide];
            [videoArray removeAllObjects];
        }];
    }
}

- (void)parseVideoData:(id)result
{
    videoArray = [[NSMutableArray alloc]initWithCapacity:10];
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        NSArray *videos = [result objectForKey:@"favorities"];
        if(videos != nil && videos.count > 0){
            [videoArray addObjectsFromArray:videos];
        }
        [[CacheUtility sharedCache] putInCache:@"my_collection_list" result:result];
        if(videos.count < pageSize){
             pullToRefreshManager_.canLoadMore = NO;
        } else {
             pullToRefreshManager_.canLoadMore = YES;
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
            UIImageView *placeHolderImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, (120-NORMAL_VIDEO_HEIGHT-8) / 2, NORMAL_VIDEO_WIDTH + 8, NORMAL_VIDEO_HEIGHT+ 8)];
            placeHolderImage.image = [UIImage imageNamed:@"video_bg_placeholder"];
            [cell.contentView addSubview:placeHolderImage];
            
            UIImageView *contentImage = [[UIImageView alloc]initWithFrame:CGRectMake(4, (120-NORMAL_VIDEO_HEIGHT) / 2 + 1.5, NORMAL_VIDEO_WIDTH, NORMAL_VIDEO_HEIGHT)];
            contentImage.tag = 1001;
            [cell.contentView addSubview:contentImage];
            
            
            UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(contentImage.frame.origin.x + contentImage.frame.size.width + 20, contentImage.frame.origin.y, 250, 30)];
            nameLabel.font = CMConstants.titleFont;
            nameLabel.backgroundColor = [UIColor clearColor];
            nameLabel.tag = 2001;
            [cell.contentView addSubview:nameLabel];
            nameLabel.textColor = CMConstants.textColor;
            
            UILabel *scoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(nameLabel.frame.origin.x + nameLabel.frame.size.width, nameLabel.frame.origin.y, 45, 30)];
            scoreLabel.tag = 3001;
            scoreLabel.text = @"0 分";
            scoreLabel.backgroundColor = [UIColor clearColor];
            scoreLabel.font = [UIFont boldSystemFontOfSize:15];
            scoreLabel.textColor = CMConstants.yellowColor;//[UIColor colorWithRed:1 green:167.0/255.0 blue:41.0/255.0 alpha:1];
            scoreLabel.textAlignment = NSTextAlignmentRight;
            [cell.contentView addSubview:scoreLabel];
            UIImageView *doubanLogo = [[UIImageView alloc]initWithFrame:CGRectMake(scoreLabel.frame.origin.x + scoreLabel.frame.size.width, scoreLabel.frame.origin.y + 8, 15, 15)];
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
            
//            UILabel *areaLabel = [[UILabel alloc]initWithFrame:CGRectMake(120, 100, 220, 25)];
//            areaLabel.font = [UIFont systemFontOfSize:13];
//            areaLabel.textColor = CMConstants.grayColor;
//            areaLabel.backgroundColor = [UIColor clearColor];
//            areaLabel.tag = 8001;
//            [cell.contentView addSubview:areaLabel];
//            
//            UILabel *areaNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(185, 100, 220, 25)];
//            areaNameLabel.font = [UIFont systemFontOfSize:13];
//            areaNameLabel.textColor = CMConstants.grayColor;
//            areaNameLabel.backgroundColor = [UIColor clearColor];
//            areaNameLabel.tag = 8002;
//            [cell.contentView addSubview:areaNameLabel];
            
            UIImageView *dingNumberImage = [[UIImageView alloc]initWithFrame:CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y + 80, 16, 16)];
            dingNumberImage.image = [UIImage imageNamed:@"pushinguser"];
            [cell.contentView addSubview:dingNumberImage];
            
            UILabel *dingNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(nameLabel.frame.origin.x + 20, nameLabel.frame.origin.y + 80, 40, 18)];
            dingNumberLabel.backgroundColor = [UIColor clearColor];
            dingNumberLabel.font = [UIFont systemFontOfSize:13];
            dingNumberLabel.tag = 6001;
            [cell.contentView addSubview:dingNumberLabel];
            
            UIImageView *collectioNumber = [[UIImageView alloc]initWithFrame:CGRectMake(nameLabel.frame.origin.x + 70, nameLabel.frame.origin.y + 80, 16, 16)];
            collectioNumber.image = [UIImage imageNamed:@"collectinguser"];
            [cell.contentView addSubview:collectioNumber];
            
            UILabel *collectionNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(nameLabel.frame.origin.x + 90, nameLabel.frame.origin.y + 78, 40, 18)];
            collectionNumberLabel.backgroundColor = [UIColor clearColor];
            collectionNumberLabel.font = [UIFont systemFontOfSize:13];
            collectionNumberLabel.tag = 7001;
            [cell.contentView addSubview:collectionNumberLabel];
            
            UIImageView *devidingLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, 118, table.frame.size.width, 2)];
            devidingLine.image = [UIImage imageNamed:@"dividing"];
            [cell.contentView addSubview:devidingLine];
        }
        NSDictionary *item = [videoArray objectAtIndex:indexPath.row];
        UIImageView *contentImage = (UIImageView *)[cell viewWithTag:1001];
        [contentImage setImageWithURL:[NSURL URLWithString:[item objectForKey:@"content_pic_url"]]];
        
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
            directorLabel.text = @"主持/嘉宾：";
            directorLabel.frame = CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y + 30, 150, 25);
            directorNameLabel.frame = CGRectMake(nameLabel.frame.origin.x + 70, directorLabel.frame.origin.y, 250, 25);
            directorNameLabel.text = [item objectForKey:@"stars"];
            actorLabel1.text = @"首播时间：";
            actorLabel1.frame = CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y + 50, 150, 25);
            actorLabel.frame = CGRectMake(nameLabel.frame.origin.x + 70, actorLabel1.frame.origin.y, 250, 25);
            actorLabel.text = [item objectForKey:@"publish_date"];
        } else {
            scoreLabel.text = [NSString stringWithFormat:@"%@ 分", [item objectForKey:@"score"]];
            doubanlogo.image = [UIImage imageNamed:@"douban"];
            directorLabel.text = @"导演：";
            directorLabel.frame = CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y + 30, 150, 25);
            directorNameLabel.frame = CGRectMake(nameLabel.frame.origin.x + 40, directorLabel.frame.origin.y, 250, 25);
            directorNameLabel.text = [item objectForKey:@"directors"];
            actorLabel1.text = @"主演：";
            actorLabel1.frame = CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y + 50, 150, 25);
            actorLabel.frame = CGRectMake(nameLabel.frame.origin.x + 40, actorLabel1.frame.origin.y, 250, 25);
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
        UIImageView *norecord = [[UIImageView alloc]initWithFrame:CGRectMake(80, 70, 250, 250)];
        norecord.image = [UIImage imageNamed:@"nocollection"];
        [cell.contentView addSubview:norecord];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(videoArray.count > 0){
        return UITableViewCellEditingStyleDelete;
    } else {
        return  UITableViewCellEditingStyleNone;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"commitEditingStyle");
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary *tempItem = [videoArray objectAtIndex:indexPath.row];
        NSString *itemId = [NSString stringWithFormat:@"%@", [tempItem objectForKey:@"content_id"]];
        int contentType = [[tempItem objectForKey:@"content_type"] integerValue];
        if (contentType == DRAMA_TYPE || contentType == COMIC_TYPE) {
            [self unSubscribingToChannels:itemId];
        }
        [self deleteVideo:itemId];
        [videoArray removeObjectAtIndex:indexPath.row];
        if(videoArray.count > 1){
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } else{
            [tableView reloadData];
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    
}

- (void)unSubscribingToChannels:(NSString *)Id
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    NSArray *channels = [NSArray arrayWithObjects:[NSString stringWithFormat:@"CHANNEL_PROD_%@",Id], nil];
    //[currentInstallation addUniqueObjectsFromArray:channels forKey:@"channels"];
    [currentInstallation removeObjectsInArray:channels forKey:@"channels"];
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

- (void)deleteVideo:(NSString *)itemId
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: itemId, @"prod_id", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathProgramUnfavority parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:PERSONAL_VIEW_REFRESH object:nil];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
    }];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(videoArray.count > 0) {
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
        } else if([type isEqualToString:@"2"] || [type isEqualToString:@"131"]){
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
#pragma mark - UIScrollviewDelegate

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [pullToRefreshManager_ scrollViewBegin];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [pullToRefreshManager_ scrollViewScrolled:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [pullToRefreshManager_ scrollViewEnd:scrollView];
}

#pragma mark -
#pragma mark - PullRefreshManagerClinetDelegate 
-(void)pulltoLoadMore{
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [UIUtility showNetWorkError:self.view];
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:2.0f];
        return;
    }
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:reloads_], @"page_num", [NSNumber numberWithInt:pageSize], @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathUserFavorities parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        NSArray *tempArray;
        if(responseCode == nil){
            tempArray = [result objectForKey:@"favorities"];
            if(tempArray.count > 0){
                [videoArray addObjectsFromArray:tempArray];
                reloads_ ++;
            }
        } else {
            
        }
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:0.0f];
        if(tempArray.count < pageSize){
            pullToRefreshManager_.canLoadMore = NO;
        }
        else{
            pullToRefreshManager_.canLoadMore = YES;
        }
        [pullToRefreshManager_ loadMoreCompleted];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        [pullToRefreshManager_ loadMoreCompleted];
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:0.0f];
    }];
}
@end
