//
//  SearchFilmResultViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-10.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "FriendListViewController.h"
#import "UIImageView+WebCache.h"
#import "FriendDetailViewController.h"
#import "CustomBackButtonHolder.h"
#import "CustomBackButton.h"
#import "CustomCellBlackBackground.h"
#import "CustomCellBackground.h"
#import "CMConstants.h"
#import "CustomColoredAccessory.h"
#import "StringUtility.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "CacheUtility.h"
#import "HomeViewController.h"
#import "WeiBoInviteViewController.h"

@interface FriendListViewController (){
    NSMutableArray *itemsArray;
    NSMutableArray *joinedFriendArray;
    NSMutableArray *joinedFriendUserId;
    NSMutableArray *unjoinedFriendArray;
    EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
    MNMBottomPullToRefreshManager *pullToRefreshManager_;
    NSUInteger reloads_;
    int pageSize;
}
- (void)closeSelf;
@end

@implementation FriendListViewController

@synthesize keyword;
@synthesize sBar;
@synthesize sourceType;

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setSBar:nil];
    self.keyword = nil;
    _refreshHeaderView = nil;
    pullToRefreshManager_ = nil;
    self.sourceType = nil;
    itemsArray = nil;
    joinedFriendArray = nil;
    unjoinedFriendArray = nil;
}

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
    self.title = NSLocalizedString(@"search", nil);
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    CustomBackButtonHolder *backButtonHolder = [[CustomBackButtonHolder alloc]initWithViewController:self];
    CustomBackButton* backButton = [backButtonHolder getBackButton:NSLocalizedString(@"go_back", nil)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.sBar setText:self.keyword];
    self.sBar.delegate = self;
    pageSize = 10;
    reloads_ = 1;
    [self getFriendData];
//    if (_refreshHeaderView == nil) {
//		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
//        view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"back_up"]];
//		view.delegate = self;
//		[self.tableView addSubview:view];
//		_refreshHeaderView = view;
//		
//	}
//	[_refreshHeaderView refreshLastUpdatedDate];
}

- (void)getFriendData
{
    NSArray *sinaFriends = [[CacheUtility sharedCache] sinaFriends];
    joinedFriendArray  = [[NSMutableArray alloc]initWithCapacity:10];
    joinedFriendUserId  = [[NSMutableArray alloc]initWithCapacity:10];
    unjoinedFriendArray  = [[NSMutableArray alloc]initWithCapacity:10];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: kAppKey, @"app_key", self.sourceType, @"source_type", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathUserThirdPartyUsers parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *item = [result objectForKey:@"users"];
            itemsArray = [[NSMutableArray alloc]initWithCapacity:pageSize];
            [itemsArray addObjectsFromArray:item];
            for(NSDictionary *friend in sinaFriends){
                BOOL exists = NO;
                for(NSDictionary *user in item){
                    if([[user objectForKey:@"thirdpart_id"] isEqualToString:[friend objectForKey:@"idstr"]]){
                        [joinedFriendUserId addObject:[user objectForKey:@"friend_id"]];
                        exists = YES;
                        break;
                    }
                }
                if(exists){
                    [joinedFriendArray addObject:friend];
                } else {
                    [unjoinedFriendArray addObject:friend];
                }
            }
            //            pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f tableView:self.tableView withClient:self];
            [self loadTable];
            reloads_ ++;
        } else {
            
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)closeSelf
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadTable {
    
    [self.tableView reloadData];
    
    [pullToRefreshManager_ tableViewReloadFinished];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return joinedFriendArray.count;
    } else {
        return unjoinedFriendArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    switch (indexPath.section) {
        case 0:
        {
            NSDictionary *friend = [joinedFriendArray objectAtIndex:indexPath.row];
            cell.textLabel.text = [friend objectForKey:@"screen_name"];
            cell.detailTextLabel.text = @"+关注";
            cell.detailTextLabel.textColor = [UIColor colorWithRed:6/255.0 green:131/255.0 blue:239/255.0 alpha:1.0];
            break;
        }
        case 1:
        {
            NSDictionary *friend = [unjoinedFriendArray objectAtIndex:indexPath.row];
            cell.textLabel.text = [friend objectForKey:@"screen_name"];
            cell.detailTextLabel.text = @"邀请";
            cell.detailTextLabel.textColor = [UIColor colorWithRed:10/255.0 green:126/255.0 blue:32/255.0 alpha:1.0];
            break;
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    CustomColoredAccessory *accessory = [CustomColoredAccessory accessoryWithColor:[UIColor lightGrayColor]];
    accessory.highlightedColor = [UIColor whiteColor];
    cell.accessoryView = accessory;
    UIView *backgroundView;
    if(indexPath.row % 2 == 0){
        backgroundView = [[CustomCellBlackBackground alloc]init];
    } else {
        backgroundView = [[CustomCellBackground alloc]init];
    }
    [cell setBackgroundView:backgroundView];
    return cell;
}

- (NSDictionary *)findSinaFriend:(NSDictionary *)user
{
    NSArray *sinaFriends = [[CacheUtility sharedCache] sinaFriends];
    for(NSDictionary *friend in sinaFriends){
        if([[user objectForKey:@"thirdpart_id"] isEqualToString:[friend objectForKey:@"id"]]){
            return friend;
        }
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,24)];
    customView.backgroundColor = [UIColor blackColor];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bgwithline"]];
    imageView.frame = customView.frame;
    [customView addSubview:imageView];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:14];
    
    if (section == 0) {
        headerLabel.text =  @"好友列表";
    } else {
        headerLabel.text =  @"邀请好友";
    }
    headerLabel.textColor = [UIColor lightGrayColor];
    [headerLabel sizeToFit];
    headerLabel.center = CGPointMake(headerLabel.frame.size.width/2 + 10, customView.frame.size.height/2);
    [customView addSubview:headerLabel];
    return customView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
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
    [self.sBar resignFirstResponder];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 0){
        HomeViewController *viewController = [[HomeViewController alloc]initWithNibName:@"HomeViewController" bundle:nil];
        viewController.userid = [joinedFriendUserId objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        WeiBoInviteViewController *viewController = [[WeiBoInviteViewController alloc]initWithNibName:@"WeiBoInviteViewController" bundle:nil];
        viewController.friendInfo = [unjoinedFriendArray objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
}


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
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: kAppKey, @"app_key", self.sourceType, @"source_type", [NSNumber numberWithInt:reloads_], @"page_num", [NSNumber numberWithInt:pageSize], @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathUserThirdPartyUsers parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *item = [result objectForKey:@"users"];
            itemsArray = [[NSMutableArray alloc]initWithCapacity:pageSize];
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

- (void)reloadTableViewDataSource
{
//	[self getFriendData];
	_reloading = YES;
	
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
	
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

@end
