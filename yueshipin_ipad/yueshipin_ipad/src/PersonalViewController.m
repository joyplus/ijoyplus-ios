//
//  SettingsViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-20.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "PersonalViewController.h"
#import "CustomSearchBar.h"
#import "DingListViewController.h"
#import "CollectionListViewController.h"
#import "CreateListOneViewController.h"
#import "TopicListViewController.h"
#import "WatchRecordCell.h"
#import "MovieDetailViewController.h"
#import "ShowDetailViewController.h"
#import "AvVideoWebViewController.h"
#import "EGORefreshTableHeaderView.h"

#define TABLE_VIEW_WIDTH 370
#define MIN_BUTTON_WIDTH 45
#define MAX_BUTTON_WIDTH 355
#define BUTTON_HEIGHT 33
#define BUTTON_TITLE_GAP 13

@interface PersonalViewController () <MNMBottomPullToRefreshManagerClient, EGORefreshTableHeaderDelegate>
{
    UIView *backgroundView;
    UIImageView *topImage;
    UIImageView *bgImage;
    UITableView *table;
    UIImageView *avatarImage;
    UILabel *nameLabel;
    UIImageView *personalImage;
    UIButton *supportBtn;
    UIButton *collectionBtn;
    UIButton *listBtn;
    UIImageView *myRecordImage;
    UIButton *createBtn;
    UIButton *removeAllBtn;
    UIImageView *tableBgImage;
    NSArray *sortedwatchRecordArray;
    int tableHeight;
    BOOL accessed;
    UIButton *clickedBtn;
}
@property (nonatomic, strong) MNMBottomPullToRefreshManager *pullToRefreshManager_;
@property (nonatomic) NSUInteger reloads_;
@property (nonatomic, strong) EGORefreshTableHeaderView *_refreshHeaderView;
@property (nonatomic) BOOL _reloading;
@property (nonatomic, strong)UIImageView *avatarImageBg;
@end

@implementation PersonalViewController
@synthesize pullToRefreshManager_, reloads_;
@synthesize _refreshHeaderView;
@synthesize _reloading;
@synthesize avatarImageBg;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WATCH_HISTORY_REFRESH object:nil];
    pullToRefreshManager_ = nil;
    backgroundView = nil;
    topImage = nil;
    bgImage = nil;
    table = nil;
    avatarImage = nil;
    nameLabel = nil;
    personalImage = nil;
    supportBtn = nil;
    collectionBtn = nil;
    listBtn = nil;
    myRecordImage = nil;
    createBtn = nil;
    removeAllBtn = nil;
    tableBgImage = nil;
    sortedwatchRecordArray = nil;
    clickedBtn = nil;
}
- (id)initWithFrame:(CGRect)frame {
    if (self = [super init]) {
		[self.view setFrame:frame];
        [self.view setBackgroundColor:[UIColor clearColor]];
        backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 24)];
        [backgroundView setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:backgroundView];

        topImage = [[UIImageView alloc]initWithFrame:CGRectMake(15, 40, 260, 42)];
        topImage.image = [UIImage imageNamed:@"my_title"];
        [self.view addSubview:topImage];
        
        personalImage = [[UIImageView alloc]initWithFrame:CGRectMake(50, 164, 404, 102)];
        personalImage.image = [UIImage imageNamed:@"my_summary_bg"];
        [self.view addSubview:personalImage];
        
        avatarImageBg = [[UIImageView alloc]initWithFrame:CGRectMake(50, 90, 73, 73)];
        avatarImageBg.image = [UIImage imageNamed:@"self_icon"];
        [self.view addSubview:avatarImageBg];
        
        avatarImage = [[UIImageView alloc]initWithFrame:CGRectMake(avatarImageBg.frame.origin.x + 7, avatarImageBg.frame.origin.y + 7, avatarImageBg.frame.size.width - 14, avatarImageBg.frame.size.height - 14)];
        [self.view addSubview:avatarImage];
        
        nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(155, 130, 260, 22)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = CMConstants.textColor;
        nameLabel.font = [UIFont systemFontOfSize:20];
        [self.view addSubview:nameLabel];
        
        supportBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        supportBtn.frame = CGRectMake(50, 190, 131, 79);
        supportBtn.tag = 1001;
        [supportBtn setBackgroundImage:[UIImage imageNamed:@"support_btn_bg"] forState:UIControlStateNormal];
        [supportBtn setBackgroundImage:[UIImage imageNamed:@"support_btn_bg_pressed"] forState:UIControlStateHighlighted];
        [supportBtn addTarget:self action:@selector(summaryBtnClicked:) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:supportBtn];
        
        collectionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        collectionBtn.frame = CGRectMake(185, 190, 131, 79);
        collectionBtn.tag = 1002;
        [collectionBtn setBackgroundImage:[UIImage imageNamed:@"collection_btn_bg"] forState:UIControlStateNormal];
        [collectionBtn setBackgroundImage:[UIImage imageNamed:@"collection_btn_bg_pressed"] forState:UIControlStateHighlighted];
        [collectionBtn addTarget:self action:@selector(summaryBtnClicked:) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:collectionBtn];
        
        listBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        listBtn.frame = CGRectMake(315, 190, 131, 79);
        listBtn.tag = 1003;
        [listBtn setBackgroundImage:[UIImage imageNamed:@"list_btn_bg"] forState:UIControlStateNormal];
        [listBtn setBackgroundImage:[UIImage imageNamed:@"list_btn_bg_pressed"] forState:UIControlStateHighlighted];
        [listBtn addTarget:self action:@selector(summaryBtnClicked:) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:listBtn];
        
        myRecordImage = [[UIImageView alloc]initWithFrame:CGRectMake(50, 283, 71, 18)];
        myRecordImage.image = [UIImage imageNamed:@"my_record"];
        [self.view addSubview:myRecordImage];
        
        createBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        createBtn.frame = CGRectMake(380, 265, 67, 51);
        [createBtn setBackgroundImage:[UIImage imageNamed:@"create_list"] forState:UIControlStateNormal];
        [createBtn setBackgroundImage:[UIImage imageNamed:@"create_list_pressed"] forState:UIControlStateHighlighted];
        [createBtn addTarget:self action:@selector(createBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:createBtn];
        
        removeAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        removeAllBtn.frame = CGRectMake(280, 265, 67, 51);
        [removeAllBtn setBackgroundImage:[UIImage imageNamed:@"clear_play"] forState:UIControlStateNormal];
        [removeAllBtn setBackgroundImage:[UIImage imageNamed:@"clear_play_pressed"] forState:UIControlStateHighlighted];
        [removeAllBtn addTarget:self action:@selector(removeAllBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:removeAllBtn];
        
        tableHeight = 370;
        table = [[UITableView alloc] initWithFrame:CGRectMake(50, 325, 400, tableHeight) style:UITableViewStylePlain];
        table.layer.borderWidth = 1;
        table.layer.borderColor = CMConstants.tableBorderColor.CGColor;
        table.separatorColor = CMConstants.tableBorderColor;
        [table setBackgroundColor:[UIColor clearColor]];
        table.tableFooterView = [[UIView alloc] init];
        table.showsVerticalScrollIndicator = NO;
        [table setDelegate:self];
        [table setDataSource:self];
        [table setScrollEnabled:YES];
        [self.view addSubview:table];
        
        if (_refreshHeaderView == nil) {
            EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - table.bounds.size.height, table.frame.size.width, table.bounds.size.height)];
            view.backgroundColor = [UIColor clearColor];
            view.delegate = self;
            [table addSubview:view];
            _refreshHeaderView = view;
        }
        
        pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:480.0f tableView:table withClient:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshWatchHistory:) name:WATCH_HISTORY_REFRESH object:nil];
   
    reloads_ = 2;
}

- (void)loadTable {
    if(sortedwatchRecordArray.count > 0){
        [myRecordImage setHidden:NO];
        [table setHidden:NO];
        [removeAllBtn setHidden:NO];
    } else {
        [removeAllBtn setHidden:YES];
        [myRecordImage setHidden:YES];
        [table setHidden:YES];
    }
    [table reloadData];
    [pullToRefreshManager_ tableViewReloadFinished];
}


- (void)reloadTableViewDataSource{
    reloads_ = 2;
    _reloading = YES;
    [self parseWatchHistory];
}


- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:table];
	
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	return _reloading; // should return if data source model is reloading
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]){
        return NO;
    } else if([NSStringFromClass([touch.view class]) isEqualToString:@"UIButton"]){
        return NO;
    } else {
        return YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if(sortedwatchRecordArray.count > 0){
        [myRecordImage setHidden:NO];
        [table setHidden:NO];
        [removeAllBtn setHidden:NO];
    } else {
        [removeAllBtn setHidden:YES];
        [myRecordImage setHidden:YES];
        [table setHidden:YES];
    }
    NSString *avatarUrl = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserAvatarUrl];
    [avatarImage setImageWithURL:[NSURL URLWithString:avatarUrl]];
    nameLabel.text = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserNickName];
    if (!accessed) {
        accessed = YES;
        [self parseWatchHistory];
    }
    [MobClick beginLogPageView:PERSONAL];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:PERSONAL];
}


- (void)parseWatchHistory
{
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:WATCH_RECORD_CACHE_KEY];
    if(cacheResult != nil){
        [self parseWatchResultData:cacheResult];
    }
    if([[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:(NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId], @"userid", @"1", @"page_num", [NSNumber numberWithInt:10], @"page_size", nil];
        [[AFServiceAPIClient sharedClient] getPath:kPathPlayHistory parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [self parseWatchResultData:result];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
            [UIUtility showSystemError:self.view];
        }];
    }
}

- (void)parseWatchResultData:(id)result
{
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        [[CacheUtility sharedCache] putInCache:WATCH_RECORD_CACHE_KEY result:result];
        sortedwatchRecordArray = (NSArray *)[result objectForKey:@"histories"];
        if(sortedwatchRecordArray.count > 0){
//            for (NSDictionary *tempItem in sortedwatchRecordArray) {
//                NSString *tprodId = [NSString stringWithFormat:@"%@", [tempItem objectForKey:@"prod_id"]];
//                NSString *tsubname = [NSString stringWithFormat:@"%@", [tempItem objectForKey:@"prod_subname"]];
//                NSNumber *tplaybackTime = (NSNumber *)[tempItem objectForKey:@"playback_time"];
//                NSString *key = [NSString stringWithFormat:@"%@_%@", tprodId, tsubname];
//                [[CacheUtility sharedCache] putInCache:key result:tplaybackTime];
//            }
            if (sortedwatchRecordArray.count >= 10) {
                [pullToRefreshManager_ setPullToRefreshViewVisible:YES];
            } else {
                [pullToRefreshManager_ setPullToRefreshViewVisible:NO];
            }
        }
    }
    [self loadTable];
}

- (void)refreshWatchHistory:(NSNotification *)notification
{
    [self parseWatchHistory];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [pullToRefreshManager_ tableViewScrolled];
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}
 
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [pullToRefreshManager_ tableViewReleased];
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)MNMBottomPullToRefreshManagerClientReloadTable {
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [UIUtility showNetWorkError:self.view];
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:0.0f];
        return;
    }
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:(NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId], @"userid", [NSNumber numberWithInteger:reloads_], @"page_num", [NSNumber numberWithInt:10], @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathPlayHistory parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        NSArray *tempArray;
        if(responseCode == nil){
            tempArray = (NSArray *)[result objectForKey:@"histories"];
            if(tempArray.count > 0){
                NSMutableArray *tempMutableArray = [[NSMutableArray alloc]initWithArray:sortedwatchRecordArray];
                [tempMutableArray addObjectsFromArray:tempArray];
                sortedwatchRecordArray = tempMutableArray;
                reloads_ ++;
            }
        } else {
            
        }
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:0.0f];
        if(tempArray.count < 10){
            [pullToRefreshManager_ setPullToRefreshViewVisible:NO];
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:0.0f];
    }];
}

- (void)reloadHistory
{
    [table reloadData];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return sortedwatchRecordArray.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        UILabel *movieNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 10, 280, 20)];
        movieNameLabel.backgroundColor = [UIColor clearColor];
        movieNameLabel.textColor = CMConstants.textColor;
        movieNameLabel.tag = 1001;
        movieNameLabel.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:movieNameLabel];
        
        UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        playButton.tag = 1002;
        [playButton addTarget:self action:@selector(playBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:playButton];
        
        UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 35, 280, 15)];
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.textColor = CMConstants.grayColor;
        contentLabel.tag = 1003;
        contentLabel.font = [UIFont systemFontOfSize:15];
        [contentLabel setNumberOfLines:0];
        [cell.contentView addSubview:contentLabel];
    }
    if (indexPath.row < sortedwatchRecordArray.count) {
        NSDictionary *item =  [sortedwatchRecordArray objectAtIndex:indexPath.row];
        UILabel *movieNameLabel = (UILabel *)[cell viewWithTag:1001];
        movieNameLabel.text = [item objectForKey:@"prod_name"];
        
        UILabel *contentLabel = (UILabel *)[cell viewWithTag:1003];
        contentLabel.text = [self composeContent:item];
        CGSize size = [self calculateContentSize:contentLabel.text width:280];
        [contentLabel setFrame:CGRectMake(contentLabel.frame.origin.x, contentLabel.frame.origin.y, size.width, size.height)];
        
        UIButton *playButton = (UIButton *)[cell viewWithTag:1002];
        NSNumber *playbackTime = (NSNumber *)[item objectForKey:@"playback_time"];
        NSNumber *duration = (NSNumber *)[item objectForKey:@"duration"];
        if(duration.doubleValue - playbackTime.doubleValue < 3){
            [playButton setBackgroundImage:[UIImage imageNamed:@"replay"] forState:UIControlStateNormal];
            [playButton setBackgroundImage:[UIImage imageNamed:@"replay_pressed"] forState:UIControlStateHighlighted];
        } else {
            [playButton setBackgroundImage:[UIImage imageNamed:@"continue"] forState:UIControlStateNormal];
            [playButton setBackgroundImage:[UIImage imageNamed:@"continue_pressed"] forState:UIControlStateHighlighted];
        }
        playButton.frame = CGRectMake(345, (size.height + 40 - 49)/2.0, 52, 49);
    }
    return cell;
}

- (void)playBtnClicked:(UIButton *)btn
{
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([hostReach currentReachabilityStatus] == NotReachable) {
        [UIUtility showNetWorkError:self.view];
        return;
    }
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isWifiReachable)]){
        clickedBtn = btn;
        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil
                                                           message:@"播放视频会消耗大量流量，您确定要在非WiFi环境下播放吗？"
                                                          delegate:self
                                                 cancelButtonTitle:@"取消"
                                                 otherButtonTitles:@"确定", nil];
        [alertView show];
    } else {        
        [self playVideo:btn];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        [self playVideo:clickedBtn];
    }
}

- (void)playVideo:(UIButton *)btn
{
    CGPoint point = btn.center;
    point = [table convertPoint:point fromView:btn.superview];
    NSIndexPath* indexPath = [table indexPathForRowAtPoint:point];
    NSDictionary *item = [sortedwatchRecordArray objectAtIndex:indexPath.row];
    BOOL hasVideoUrls = YES;
    NSMutableArray *httpUrlArray = [[NSMutableArray alloc]initWithCapacity:1];
    if([[NSString stringWithFormat:@"%@", [item objectForKey:@"play_type"]] isEqualToString:@"2"]){
        [httpUrlArray addObject:[item objectForKey:@"video_url"]];
        hasVideoUrls = NO;
    }
    AvVideoWebViewController *webViewController = [[AvVideoWebViewController alloc] init];
    webViewController.videoHttpUrlArray = httpUrlArray;
    webViewController.name = [item objectForKey:@"prod_name"];
    webViewController.subname = [item objectForKey:@"prod_subname"];
    webViewController.prodId = [item objectForKey:@"prod_id"];
    webViewController.playTime = [item objectForKey:@"playback_time"];
    webViewController.hasVideoUrls = hasVideoUrls;
    webViewController.type = [[NSString stringWithFormat:@"%@", [item objectForKey:@"prod_type"]] integerValue];
    webViewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [[AppDelegate instance].rootViewController pesentMyModalView:[[UINavigationController alloc]initWithRootViewController:webViewController]];

    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: [item objectForKey:@"prod_id"], @"prod_id",  [item objectForKey:@"prod_name"], @"prod_name", [item objectForKey:@"prod_subname"], @"prod_subname", [item objectForKey:@"prod_type"], @"prod_type", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathRecordPlay parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (NSString *)composeContent:(NSDictionary *)item
{
    NSString *content;
    NSNumber *number = (NSNumber *)[item objectForKey:@"playback_time"];
    if ([[NSString stringWithFormat:@"%@", [item objectForKey:@"prod_type"]] isEqualToString:@"1"]) {
        content = [NSString stringWithFormat:@"已观看到 %@", [TimeUtility formatTimeInSecond:number.doubleValue]];
    } else if ([[NSString stringWithFormat:@"%@", [item objectForKey:@"prod_type"]] isEqualToString:@"2"]) {
        content = [NSString stringWithFormat:@"已观看到《第%@集》 %@", [item objectForKey:@"prod_subname"], [TimeUtility formatTimeInSecond:number.doubleValue]];
    } else if ([[NSString stringWithFormat:@"%@", [item objectForKey:@"prod_type"]] isEqualToString:@"3"]) {
        content = [NSString stringWithFormat:@"已观看《%@》 %@", [item objectForKey:@"prod_subname"], [TimeUtility formatTimeInSecond:number.doubleValue]];
    }
    return content;
}

- (CGSize)calculateContentSize:(NSString *)content width:(int)width
{
    CGSize constraint = CGSizeMake(width, 20000.0f);
    CGSize size = [content sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    return size;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item =  [sortedwatchRecordArray objectAtIndex:indexPath.row];
    NSString *content = [self composeContent:item];
    CGSize size = [self calculateContentSize:content width:280];
    return size.height + 40;
}

- (void)summaryBtnClicked:(UIButton *)sender
{
    if(sender.tag == 1001){
//        [sender setBackgroundImage:[UIImage imageNamed:@"support_btn_bg_pressed"] forState:UIControlStateNormal];
        DingListViewController *viewController = [[DingListViewController alloc] init];
        viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:YES];
    } else if(sender.tag == 1002){
//        [sender setBackgroundImage:[UIImage imageNamed:@"collection_btn_bg_pressed"] forState:UIControlStateNormal];
        CollectionListViewController *viewController = [[CollectionListViewController alloc] init];
        viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:YES];
    } else if(sender.tag == 1003){
//        [sender setBackgroundImage:[UIImage imageNamed:@"list_btn_bg_pressed"] forState:UIControlStateNormal];
        TopicListViewController *viewController = [[TopicListViewController alloc] init];
        viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:YES];
    }
}


- (void)createBtnClicked:(id)sender
{
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([hostReach currentReachabilityStatus] == NotReachable) {
        [UIUtility showNetWorkError:self.view];
        return;
    }
    CreateListOneViewController *viewController = [[CreateListOneViewController alloc]initWithNibName:@"CreateListOneViewController" bundle:nil];
    viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
    [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row < sortedwatchRecordArray.count){
        NSDictionary *item =  [sortedwatchRecordArray objectAtIndex:indexPath.row];
        NSString *prodType = [NSString stringWithFormat:@"%@", [item objectForKey:@"prod_type"]];
        if([prodType isEqualToString:@"1"]){
            MovieDetailViewController *viewController = [[MovieDetailViewController alloc] initWithNibName:@"MovieDetailViewController" bundle:nil];
            viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
            viewController.prodId = [NSString stringWithFormat:@"%@", [item objectForKey:@"prod_id"]];
            [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE  removePreviousView:YES];
        } else if([prodType isEqualToString:@"2"]  || [prodType isEqualToString:@"131"]){
            NSDictionary *item = [sortedwatchRecordArray objectAtIndex:indexPath.row];
            NSString *prodId = [item objectForKey:@"prod_id"];
            NSString *subname = [item objectForKey:@"prod_subname"];
            NSString *lastPlaytime = [item objectForKey:@"playback_time"];
            NSString *lastPlaytimeCacheKey = [NSString stringWithFormat:@"%@_%@", prodId, subname];
            [[CacheUtility sharedCache]putInCache:lastPlaytimeCacheKey result: lastPlaytime];
            int btnTag = [[item objectForKey:@"prod_subname"] intValue];
            if (btnTag <= 0) {
                btnTag = 1;
            }
            [[CacheUtility sharedCache]putInCache:[NSString stringWithFormat:@"drama_epi_%@", prodId] result:[NSNumber numberWithInt:btnTag]];
            DramaDetailViewController *viewController = [[DramaDetailViewController alloc] initWithNibName:@"DramaDetailViewController" bundle:nil];
            viewController.prodId = [NSString stringWithFormat:@"%@", [item objectForKey:@"prod_id"]];
            viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
            [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:YES];
        } else if([prodType isEqualToString:@"3"]){
            ShowDetailViewController *viewController = [[ShowDetailViewController alloc] initWithNibName:@"ShowDetailViewController" bundle:nil];
            viewController.prodId = [NSString stringWithFormat:@"%@", [item objectForKey:@"prod_id"]];
            viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
            [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:YES];
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(sortedwatchRecordArray.count > 0){
        return UITableViewCellEditingStyleDelete;
    } else {
        return  UITableViewCellEditingStyleNone;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= 0 && indexPath.row < sortedwatchRecordArray.count ){
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            [self removeRow:indexPath.row];
            NSMutableArray *tempArray = [[NSMutableArray alloc]initWithArray:sortedwatchRecordArray];
            BOOL isReachable = [[AppDelegate instance] performSelector:@selector(isParseReachable)];
            if(!isReachable) {
                [UIUtility showNetWorkError:self.view];
            } else {
                [tempArray removeObjectAtIndex:indexPath.row];
            }
            sortedwatchRecordArray = tempArray;
            if (sortedwatchRecordArray.count == 0) {
                [removeAllBtn setHidden:YES];
                [myRecordImage setHidden:YES];
                [table setHidden:YES];
            }
//            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self loadTable];
        }
    }
}

- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [table cellForRowAtIndexPath:indexPath];
    UIButton *btn = (UIButton *)[cell viewWithTag:1002];
    [btn setHidden:YES];
}
- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [table cellForRowAtIndexPath:indexPath];
    UIButton *btn = (UIButton *)[cell viewWithTag:1002];
    [btn setHidden:NO];
}

-(void)removeRow:(int)index{
    NSDictionary *infoDic = [sortedwatchRecordArray objectAtIndex:index];
    NSString *topicId = [infoDic objectForKey:@"prod_id"];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: topicId, @"prod_id", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathHiddenPlay parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {

    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)removeAllBtnClicked
{
    BOOL isReachable = [[AppDelegate instance] performSelector:@selector(isParseReachable)];
    if(!isReachable) {
        [UIUtility showNetWorkError:self.view];
        return;
    }
    sortedwatchRecordArray = [[NSArray alloc]init];
    [self loadTable];
    [pullToRefreshManager_ setPullToRefreshViewVisible:NO];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathRemoveAllPlay parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        [removeAllBtn setHidden:YES];
        [myRecordImage setHidden:YES];
        [table setHidden:YES];
        [self loadTable];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}


@end
