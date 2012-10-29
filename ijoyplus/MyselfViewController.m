#import "MyselfViewController.h"
#import "MyProfileCell.h"
#import "CMConstants.h"
#import "UIImageView+WebCache.h"
#import "TTTTimeIntervalFormatter.h"
#import "StringUtility.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "DateUtility.h"
#import "HomeViewController.h"
#import "ShowPlayDetailViewController.h"
#import "DramaPlayDetailViewController.h"
#import "VideoPlayDetailViewController.h"
#import "PlayDetailViewController.h"
#import "CacheUtility.h"
#import "UIUtility.h"

@interface MyselfViewController(){
    NSMutableArray *itemsArray;
    EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
    MNMBottomPullToRefreshManager *pullToRefreshManager_;
    NSUInteger reloads_;
    int pageSize;
}

- (void)loadTable;

@end

@implementation MyselfViewController

@synthesize table;

- (void)viewDidUnload {
    [super viewDidUnload];
    itemsArray = nil;
    self.table = nil;
    _refreshHeaderView = nil;
    pullToRefreshManager_ = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.table setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    //    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"notification_center", nil) style:UIBarButtonSystemItemSearch target:self action:@selector(notificatonCenter)];
    //    self.navigationItem.leftBarButtonItem = leftButton;
    //    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"settings", nil) style:UIBarButtonSystemItemSearch target:self action:@selector(settings)];
    //    self.navigationItem.rightBarButtonItem = rightButton;
    
    pageSize = 10;
    reloads_ = 1;
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:@"MyselfViewController"];
    [self parseData:cacheResult];
    if([[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: kAppKey, @"app_key", [NSNumber numberWithInt:reloads_], @"page_num", [NSNumber numberWithInt:pageSize], @"page_size", nil];
        [[AFServiceAPIClient sharedClient] getPath:kPathUserFriendDynamics parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [self parseData:result];
            [[CacheUtility sharedCache] putInCache:@"MyselfViewController" result:result];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
            itemsArray = [[NSMutableArray alloc]initWithCapacity:pageSize];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
        }];
    }
    pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:480.0f tableView:table withClient:self];
    
    if (_refreshHeaderView == nil) {
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.table.bounds.size.height, self.view.frame.size.width, self.table.bounds.size.height)];
        view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"back_up2"]];
		view.delegate = self;
		[self.table addSubview:view];
		_refreshHeaderView = view;
		
	}
	[_refreshHeaderView refreshLastUpdatedDate];
    
}

- (void)parseData:(id)result
{
    itemsArray = [[NSMutableArray alloc]initWithCapacity:pageSize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        NSArray *item = [result objectForKey:@"dynamics"];
        if(item.count > 0){
            [itemsArray addObjectsFromArray:item];
            [self loadTable];
            reloads_ ++;
        }
    } else {
        
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    if(itemsArray == nil){
        [self showProgressBar];
    }
}

- (void)loadTable {
    
    [self.table reloadData];
    
    [pullToRefreshManager_ tableViewReloadFinished];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return itemsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    MyProfileCell *myCell = (MyProfileCell*) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(myCell == nil){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MyCellFactory" owner:self options:nil];
        myCell = (MyProfileCell *)[nib objectAtIndex:0];
        myCell.filmImageView.layer.borderWidth = 1;
        myCell.filmImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        myCell.filmImageView.layer.shadowColor = [UIColor blackColor].CGColor;
        myCell.filmImageView.layer.shadowOffset = CGSizeMake(1, 1);
        myCell.filmImageView.layer.shadowOpacity = 1;
    }
    
    NSDictionary *item = [itemsArray objectAtIndex:indexPath.row];
    NSString *imageUrl = (NSString *)[item valueForKey:@"prod_poster"];
    NSString *avatarUrl = (NSString *)[item valueForKey:@"user_pic_url"];
    NSString *actionType = [item valueForKey:@"type"];
    NSString *type = [item objectForKey:@"prod_type"];
    if([type isEqualToString:@"1"] || [type isEqualToString:@"2"]){
        if([StringUtility stringIsEmpty:imageUrl]){
            myCell.filmImageView.image = [UIImage imageNamed:@"movie_placeholder"];
        } else{
            [myCell.filmImageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"movie_placeholder"]];
        }
        myCell.filmImageView.frame = CGRectMake(myCell.filmImageView.frame.origin.x, myCell.filmImageView.frame.origin.y, MOVIE_LOGO_WIDTH, MOVIE_LOGO_HEIGHT);
    } else {
        if([StringUtility stringIsEmpty:imageUrl]){
            myCell.filmImageView.image = [UIImage imageNamed:@"video_placeholder"];
        } else{
            [myCell.filmImageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
        }
        myCell.filmImageView.frame = CGRectMake(myCell.filmImageView.frame.origin.x, myCell.filmImageView.frame.origin.y, VIDEO_LOGO_WIDTH, VIDEO_LOGO_HEIGHT);
    }
    myCell.thirdTitleLabel.center = CGPointMake(110, myCell.filmImageView.frame.origin.y + myCell.filmImageView.frame.size.height + 20);
    myCell.subtitleLabel.text = [item objectForKey:@"prod_name"];
    if([@"favority" isEqualToString:actionType]){
        myCell.actionLabel.text = @"收藏了";
        myCell.subtitleLabel.text = [item objectForKey:@"prod_name"];
    } else if([@"follow" isEqualToString:actionType]){
        myCell.actionLabel.text = @"关注了";
        myCell.subtitleLabel.text = [item objectForKey:@"friend_name"];
        imageUrl = (NSString *)[item valueForKey:@"friend_pic_url"];
        if([StringUtility stringIsEmpty:imageUrl]){
            myCell.filmImageView.image = [UIImage imageNamed:@"u2_normal"];
        } else{
            [myCell.filmImageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"u2_normal"]];
        }
        myCell.filmImageView.frame = CGRectMake(150, 50, 50, 50);
        myCell.filmImageView.layer.borderWidth = 2;
        myCell.filmImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        myCell.filmImageView.layer.cornerRadius = 25;
        myCell.filmImageView.layer.masksToBounds = YES;
        myCell.thirdTitleLabel.center = CGPointMake(110, 120);
        myCell.filmImageBtn.frame = myCell.filmImageView.frame;
    } else if([@"recommend" isEqualToString:actionType]){
        myCell.actionLabel.text = @"推荐了";
    } else {
        myCell.actionLabel.text = @"看过了";
    }
    
    if([StringUtility stringIsEmpty:avatarUrl]){
        myCell.avatarImageView.image = [UIImage imageNamed:@"u2_normal"];
    } else{
        [myCell.avatarImageView setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:[UIImage imageNamed:@"u2_normal"]];
    }
    myCell.avatarImageView.layer.cornerRadius = 25;
    myCell.avatarImageView.layer.masksToBounds = YES;
    
    myCell.titleLabel.text = [item objectForKey:@"user_name"];
    [myCell.titleLabel sizeToFit];
    myCell.titleLabel.center = CGPointMake(myCell.avatarImageView.center.x, myCell.avatarImageView.frame.origin.y + 60);
    
    TTTTimeIntervalFormatter *timeFormatter = [[TTTTimeIntervalFormatter alloc]init];
    NSString *dateString = [item valueForKey:@"create_date"];
    NSDate *date = [NSDate date];
    if(![StringUtility stringIsEmpty:dateString]){
        date = [DateUtility dateFromFormatString:dateString formatString:@"yyyy-MM-dd HH:mm:ss"];
    }
    NSString *timeDiff = [timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:date];
    myCell.thirdTitleLabel.text = timeDiff;
    
    myCell.filmImageBtn.tag = indexPath.row;
    [myCell.filmImageBtn addTarget:self action:@selector(fileImageClicked:) forControlEvents:UIControlEventTouchUpInside];
    [myCell.avatarBtn addTarget:self action:@selector(avatarClicked:) forControlEvents:UIControlEventTouchUpInside];
    return myCell;
}

- (void)fileImageClicked:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    NSDictionary *item = [itemsArray objectAtIndex:btn.tag];
    NSString *type = [item objectForKey:@"prod_type"];
    PlayDetailViewController *viewController;
    if([type isEqualToString:@"1"]){
        viewController = [[PlayDetailViewController alloc]initWithStretchImage];
    } else if([type isEqualToString:@"2"]){
        viewController = [[DramaPlayDetailViewController alloc]initWithStretchImage];
    } else if([type isEqualToString:@"3"]){
        viewController = [[ShowPlayDetailViewController alloc]initWithStretchImage];
    } else if([type isEqualToString:@"4"]){
        viewController = [[VideoPlayDetailViewController alloc]initWithStretchImage];
    } else {
        HomeViewController *viewController = [[HomeViewController alloc]initWithNibName:@"HomeViewController" bundle:nil];
        viewController.userid = [[itemsArray objectAtIndex:btn.tag] valueForKey:@"friend_id"];
        [self.navigationController pushViewController:viewController animated:YES];
    }
    viewController.programId = [[itemsArray objectAtIndex:btn.tag] valueForKey:@"prod_id"];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)avatarClicked:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    CGPoint point = btn.center;
    point = [self.table convertPoint:point fromView:btn.superview];
    NSIndexPath* indexpath = [self.table indexPathForRowAtPoint:point];
    
    HomeViewController *viewController = [[HomeViewController alloc]initWithNibName:@"HomeViewController" bundle:nil];
    viewController.userid = [[itemsArray objectAtIndex:indexpath.row] valueForKey:@"user_id"];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [itemsArray objectAtIndex:indexPath.row];
    NSString *type = [item objectForKey:@"prod_type"];
    if([type isEqualToString:@"1"] || [type isEqualToString:@"2"]){
        return MOVIE_LOGO_HEIGHT + 90;
    } else if([type isEqualToString:@"3"] || [type isEqualToString:@"4"]){
        return VIDEO_LOGO_WIDTH + 70;
    } else {
        return 135;
    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 24;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,24)];
//    customView.backgroundColor = [UIColor blackColor];
//
//    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//    headerLabel.backgroundColor = [UIColor clearColor];
//    headerLabel.font = [UIFont boldSystemFontOfSize:12];
//    NSMutableDictionary *item = [itemsArray objectAtIndex:section];
//    NSEnumerator *keys = item.keyEnumerator;
//    NSString *key = [keys nextObject];
//    headerLabel.text =  key;
//    headerLabel.textColor = [UIColor whiteColor];
//    [headerLabel sizeToFit];
//    headerLabel.center = CGPointMake(headerLabel.frame.size.width/2 + 10, customView.frame.size.height/2);
//    [customView addSubview:headerLabel];
//    return customView;
//}


#pragma mark -
#pragma mark MNMBottomPullToRefreshManagerClient

/**
 * This is the same delegate method as UIScrollView but requiered on MNMBottomPullToRefreshManagerClient protocol
 * to warn about its implementation. Here you have to call [MNMBottomPullToRefreshManager tableViewScrolled]
 *
 * Tells the delegate when the user scrolls the content view within the receiver.
 *
 * @param scrollView: The scroll-view object in which the scrolling occurred.
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    [pullToRefreshManager_ tableViewScrolled];
}

/**
 * This is the same delegate method as UIScrollView but requiered on MNMBottomPullToRefreshClient protocol
 * to warn about its implementation. Here you have to call [MNMBottomPullToRefreshManager tableViewReleased]
 *
 * Tells the delegate when dragging ended in the scroll view.
 *
 * @param scrollView: The scroll-view object that finished scrolling the content view.
 * @param decelerate: YES if the scrolling movement will continue, but decelerate, after a touch-up gesture during a dragging operation.
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    [pullToRefreshManager_ tableViewReleased];
}

/**
 * Tells client that can reload table.
 * After reloading is completed must call [pullToRefreshMediator_ tableViewReloadFinished]
 */
- (void)MNMBottomPullToRefreshManagerClientReloadTable {
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [UIUtility showNetWorkError:self.view];
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:2.0f];
        return;
    }
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: kAppKey, @"app_key", [NSNumber numberWithInt:reloads_], @"page_num", [NSNumber numberWithInt:pageSize], @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathUserFriendDynamics parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *item = [result objectForKey:@"dynamics"];
            if(item.count > 0){
                [itemsArray addObjectsFromArray:item];
                reloads_ ++;
            }
        } else {
            
        }
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:2.0f];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [UIUtility showNetWorkError:self.view];
        return;
    }
	reloads_ = 1;
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: kAppKey, @"app_key", [NSNumber numberWithInt:reloads_], @"page_num", [NSNumber numberWithInt:pageSize], @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathUserFriendDynamics parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *item = [result objectForKey:@"dynamics"];
            if(item.count > 0){
                [itemsArray addObjectsFromArray:item];
                reloads_ ++;
            }
        } else {
            
        }
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:2.0f];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
    _reloading = YES;
	
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.table];
	
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:2.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}


@end