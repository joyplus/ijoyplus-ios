//
//  ListViewController.m
//  yueshipin_ipad
//
//  Created by zhang zhipeng on 12-11-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "ListViewController.h"
#import "MovieDetailViewController.h"
#import "DramaDetailViewController.h"
#import "ShowDetailViewController.h"

@interface ListViewController (){
    MNMBottomPullToRefreshManager *pullToRefreshManager_;
    NSUInteger reloads_;
    int pageSize;
}

@end

@implementation ListViewController
@synthesize topId;
@synthesize listTitle;
@synthesize type;

- (void)viewDidUnload{
    [super viewDidUnload];
    [self clearMemory];
}

- (void)dealloc
{
    [self clearMemory];
}

- (void)clearMemory
{
    self.topId = nil;
    self.listTitle = nil;
    table = nil;
    [topsArray removeAllObjects];
    topsArray = nil;
    closeBtn = nil;
    titleLabel = nil;
    umengPageName = nil;    
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
    
    titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(LEFT_WIDTH, 45, 377, 30)];
    titleLabel.font = [UIFont boldSystemFontOfSize:23];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = CMConstants.titleBlueColor;
    titleLabel.layer.shadowColor = [UIColor colorWithRed:141/255.0 green:182/255.0 blue:213/255.0 alpha:1].CGColor;
    titleLabel.layer.shadowOffset = CGSizeMake(1, 1);
    [self.view addSubview:titleLabel];
    
    
    closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(456, 0, 50, 50);;
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
    pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:480.0f tableView:table withClient:self];
    
    reloads_ = 2;
    pageSize = 10;
    
    [self.view addGestureRecognizer:self.swipeRecognizer];
    
    umengPageName = TOP_LIST_DETAIL;
    
    [self setCloseTipsViewHidden:NO];
}

- (void)loadTable {    
    [table reloadData];
    [pullToRefreshManager_ tableViewReloadFinished];
}

- (void)viewWillAppear:(BOOL)animated
{
    titleLabel.text = self.listTitle;
    if(topsArray.count > 0){        
    } else {
        [self retrieveTopsListData];        
    }
    [MobClick beginLogPageView:umengPageName];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:umengPageName];
}


- (void)retrieveTopsListData
{
    BOOL isReachable = [[AppDelegate instance] performSelector:@selector(isParseReachable)];
    if(!isReachable) {
        [UIUtility showNetWorkError:self.view];
    }
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:[NSString stringWithFormat:@"top_detail_list%@", self.topId]];
    if(cacheResult != nil){
        [self parseTopsListData:cacheResult];
    } else {
        if(isReachable) {
            [myHUD showProgressBar:self.view];
        }
    }
    if([[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: @"1", @"page_num", [NSNumber numberWithInt:pageSize], @"page_size", self.topId, @"top_id", nil];
        [[AFServiceAPIClient sharedClient] getPath:kPathTopItems parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [self parseTopsListData:result];
            [myHUD hide];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
            topsArray = [[NSMutableArray alloc]initWithCapacity:10];
            [myHUD hide];
            [UIUtility showSystemError:self.view];
        }];
    }
}

- (void)parseTopsListData:(id)result
{
    topsArray = [[NSMutableArray alloc]initWithCapacity:10];
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        NSArray *tempTopsArray = [result objectForKey:@"items"];
        if(tempTopsArray.count > 0){
            [[CacheUtility sharedCache] putInCache:[NSString stringWithFormat:@"top_detail_list%@", self.topId] result:result];
            [topsArray addObjectsFromArray:tempTopsArray];
        }
        if(tempTopsArray.count < pageSize){
            [pullToRefreshManager_ setPullToRefreshViewVisible:NO];
        } else {
            [pullToRefreshManager_ setPullToRefreshViewVisible:YES];
        }
    } else {
        [UIUtility showSystemError:self.view];
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
    return topsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        UIImageView *placeHolderImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, (120-NORMAL_VIDEO_HEIGHT-8) / 2, NORMAL_VIDEO_WIDTH + 8, NORMAL_VIDEO_HEIGHT+ 8)];
        placeHolderImage.image = [UIImage imageNamed:@"video_bg_placeholder"];
        [cell.contentView addSubview:placeHolderImage];
    
        UIImageView *contentImage = [[UIImageView alloc]initWithFrame:CGRectMake(4, (120-NORMAL_VIDEO_HEIGHT) / 2, NORMAL_VIDEO_WIDTH, NORMAL_VIDEO_HEIGHT)];
        contentImage.tag = 1001;
        [cell.contentView addSubview:contentImage];
        
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(contentImage.frame.origin.x + contentImage.frame.size.width + 20, contentImage.frame.origin.y, 250, 30)];
        nameLabel.font = CMConstants.titleFont;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.tag = 2001;
        [cell.contentView addSubview:nameLabel];
        
        UILabel *scoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(nameLabel.frame.origin.x + nameLabel.frame.size.width, nameLabel.frame.origin.y, 45, 30)];
        scoreLabel.tag = 4001;
        scoreLabel.text = @"0 分";
        scoreLabel.backgroundColor = [UIColor clearColor];
        scoreLabel.font = [UIFont boldSystemFontOfSize:15];
        scoreLabel.textColor = CMConstants.scoreBlueColor;
        scoreLabel.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:scoreLabel];
        UIImageView *doubanLogo = [[UIImageView alloc]initWithFrame:CGRectMake(scoreLabel.frame.origin.x + scoreLabel.frame.size.width, scoreLabel.frame.origin.y + 10, 15, 15)];
        doubanLogo.image = [UIImage imageNamed:@"douban"];
        [cell.contentView addSubview:doubanLogo];
        
        UILabel *directorLabel = [[UILabel alloc]initWithFrame:CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y + 30, 150, 25)];
        directorLabel.text = @"导演：";
        directorLabel.textColor = CMConstants.grayColor;
        directorLabel.font = [UIFont systemFontOfSize:13];
        directorLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:directorLabel];
        
        UILabel *directorNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(nameLabel.frame.origin.x + 40, directorLabel.frame.origin.y, 250, 25)];
        directorNameLabel.font = [UIFont systemFontOfSize:13];
        directorNameLabel.textColor = CMConstants.grayColor;
        directorNameLabel.backgroundColor = [UIColor clearColor];
        directorNameLabel.tag = 6001;
        [cell.contentView addSubview:directorNameLabel];
        
        UILabel *actorLabel = [[UILabel alloc]initWithFrame:CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y + 50, 150, 25)];
        actorLabel.text = @"主演：";
        actorLabel.textColor = CMConstants.grayColor;
        actorLabel.font = [UIFont systemFontOfSize:13];
        actorLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:actorLabel];
        
        UILabel *actorName1Label = [[UILabel alloc]initWithFrame:CGRectMake(nameLabel.frame.origin.x + 40, actorLabel.frame.origin.y, 250, 25)];
        actorName1Label.font = [UIFont systemFontOfSize:13];
        actorName1Label.textColor = CMConstants.grayColor;
        actorName1Label.backgroundColor = [UIColor clearColor];
        actorName1Label.tag = 7001;
        [cell.contentView addSubview:actorName1Label];
        
        
        UIImageView *dingNumberImage = [[UIImageView alloc]initWithFrame:CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y + 80, 16, 16)];
        dingNumberImage.image = [UIImage imageNamed:@"pushinguser"];
        [cell.contentView addSubview:dingNumberImage];
        
        UILabel *dingNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(nameLabel.frame.origin.x + 20, nameLabel.frame.origin.y + 80, 40, 18)];
        dingNumberLabel.backgroundColor = [UIColor clearColor];
        dingNumberLabel.font = [UIFont systemFontOfSize:13];
        dingNumberLabel.tag = 5001;
        [cell.contentView addSubview:dingNumberLabel];
        
        UIImageView *collectioNumber = [[UIImageView alloc]initWithFrame:CGRectMake(nameLabel.frame.origin.x + 70, nameLabel.frame.origin.y + 80, 16, 16)];
        collectioNumber.image = [UIImage imageNamed:@"collectinguser"];
        [cell.contentView addSubview:collectioNumber];
        
        UILabel *collectionNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(nameLabel.frame.origin.x + 90, nameLabel.frame.origin.y + 78, 40, 18)];
        collectionNumberLabel.backgroundColor = [UIColor clearColor];
        collectionNumberLabel.font = [UIFont systemFontOfSize:13];
        collectionNumberLabel.tag = 8001;
        [cell.contentView addSubview:collectionNumberLabel];
        
        UIImageView *devidingLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, 118, table.frame.size.width, 2)];
        devidingLine.image = [UIImage imageNamed:@"dividing"];
        [cell.contentView addSubview:devidingLine];        
    }
    NSDictionary *item = [topsArray objectAtIndex:indexPath.row];
    UIImageView *contentImage = (UIImageView *)[cell viewWithTag:1001];
    [contentImage setImageWithURL:[NSURL URLWithString:[item objectForKey:@"prod_pic_url"]]];
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:2001];
    nameLabel.text = [item objectForKey:@"prod_name"];
    
    UILabel *directorNameLabel = (UILabel *)[cell viewWithTag:6001];
    directorNameLabel.text = [item objectForKey:@"directors"];
    
    UILabel *actorLabel = (UILabel *)[cell viewWithTag:7001];
    actorLabel.text = [item objectForKey:@"stars"];
    
    UILabel *scoreLabel = (UILabel *)[cell viewWithTag:4001];
    scoreLabel.text = [NSString stringWithFormat:@"%@ 分", [item objectForKey:@"score"]];
    
    UILabel *dingNumberLabel = (UILabel *)[cell viewWithTag:5001];
    dingNumberLabel.text = [NSString stringWithFormat:@"%@", [item objectForKey:@"support_num"]];
    
    UILabel *collectionNumberLabel = (UILabel *)[cell viewWithTag:8001];
    collectionNumberLabel.text = [NSString stringWithFormat:@"%@", [item objectForKey:@"favority_num"]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [table deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row >= topsArray.count){
        return;
    }
    NSDictionary *item = [topsArray objectAtIndex:indexPath.row];
    NSString *prodType = [NSString stringWithFormat:@"%@", [item objectForKey:@"prod_type"]];
    NSString *prodId = [NSString stringWithFormat:@"%@", [item objectForKey:@"prod_id"]];
    if([prodType isEqualToString:@"1"]){
        MovieDetailViewController *viewController = [[MovieDetailViewController alloc] initWithNibName:@"MovieDetailViewController" bundle:nil];
        viewController.prodId = prodId;
        viewController.fromViewController = self;
        viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:YES moveToLeft:self.moveToLeft];
    } else if([prodType isEqualToString:@"2"]  || [prodType isEqualToString:@"131"]){
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
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:reloads_], @"page_num", [NSNumber numberWithInt:pageSize], @"page_size", self.topId, @"top_id", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathTopItems parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        NSArray *tempTopsArray;
        if(responseCode == nil){
            tempTopsArray = [result objectForKey:@"items"];
            if(tempTopsArray.count > 0){
                [topsArray addObjectsFromArray:tempTopsArray];
                reloads_ ++;
            }
        } else {
            
        }
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:0.0f];
        if(tempTopsArray.count < pageSize){
            [pullToRefreshManager_ setPullToRefreshViewVisible:NO];
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:0.0f];
    }];
}

@end
