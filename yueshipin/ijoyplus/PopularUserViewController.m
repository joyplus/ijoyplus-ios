//
//  FollowedUserViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-20.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "PopularUserViewController.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "CMConstants.h"
#import "CustomBackButton.h"
#import "HomeViewController.h"
#import "StringUtility.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "ContainerUtility.h"
#import "FriendCell.h"
#import "UIUtility.h"
#import "CacheUtility.h"

#define LEFT_GAP 25
#define AVATAR_IMAGE_WIDTH 60

@interface PopularUserViewController (){
    NSMutableArray *userArray;
    int pageSize;
    //    EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
    MNMBottomPullToRefreshManager *pullToRefreshManager_;
    NSUInteger reloads_;
    MBProgressHUD *HUD;
}
- (void)cancelFollow:(id)sender;
- (void)viewUser:(id)sender;
@end

@implementation PopularUserViewController

@synthesize fromController;

- (void)viewDidUnload
{
    [super viewDidUnload];
    [userArray removeAllObjects];
    userArray = nil;
    self.fromController = nil;
    //    _refreshHeaderView = nil;
    pullToRefreshManager_ = nil;
    HUD = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"top_segment_clicked" object:nil];
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
	[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    if([fromController isEqualToString:@"SearchFriendViewController"]){
        CustomBackButton *backButton = [[CustomBackButton alloc] initWith:[UIImage imageNamed:@"back-button"] highlight:[UIImage imageNamed:@"back-button"] leftCapWidth:14.0 text:NSLocalizedString(@"back", nil)];
        [backButton addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    } else {
        [self.navigationItem setHidesBackButton:YES];
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"done", nil) style:UIBarButtonSystemItemSearch target:self action:@selector(finishRegister)];
        self.navigationItem.rightBarButtonItem = rightButton;
    }
    self.title = @"达人推荐";
    pageSize = 18;
    reloads_ = 1;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideProgressBar) name:@"top_segment_clicked" object:nil];
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:@"PopularUserViewController"];
    if(cacheResult != nil){
        [self parseData:cacheResult];
        [self loadTable];
    }
    if([[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:reloads_], @"page_num",[NSNumber numberWithInt:pageSize], @"page_size",
                                    nil];
        [[AFServiceAPIClient sharedClient] getPath:kPathPopularUser parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [self parseData:result];
            [self loadTable];
            reloads_++;
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
        }];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
    }
    pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:480.0f tableView:self.tableView withClient:self];
    [self loadTable];
    
}

- (void)parseData:(id)result
{
    userArray = [[NSMutableArray alloc]initWithCapacity:18];
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        [[CacheUtility sharedCache] putInCache:@"PopularUserViewController" result:result];
        NSArray *friends = [result objectForKey:@"prestiges"];
        [userArray removeAllObjects];
        if(friends != nil && friends.count > 0){
            [userArray addObjectsFromArray:friends];
        }
    } else {
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    if(userArray == nil && [[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [self showProgressBar];
    }
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadTable {
    
    [self.tableView reloadData];
    
    [pullToRefreshManager_ tableViewReloadFinished];
}

- (void)showProgressBar
{
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.opacity = 0;
    [HUD show:YES];
}
- (void) hideProgressBar
{
    [HUD hide:YES afterDelay:0.2];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int num = ceil(userArray.count / 3.0);
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"friendCell";
    if(indexPath.row == ceil(userArray.count / 3.0)-1){
        CellIdentifier = @"LastRow";
    }
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        for (int i = 0; i < 3; i ++){
            UIImageView *avatarImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, AVATAR_IMAGE_WIDTH, AVATAR_IMAGE_WIDTH)];
            avatarImageView.layer.cornerRadius = 27.5;
            avatarImageView.layer.masksToBounds = YES;
            if(i == 0){
                avatarImageView.center = CGPointMake(LEFT_GAP + AVATAR_IMAGE_WIDTH / 2, LEFT_GAP + AVATAR_IMAGE_WIDTH / 2);
            } else if (i == 1){
                avatarImageView.center = CGPointMake(self.view.frame.size.width / 2, LEFT_GAP + AVATAR_IMAGE_WIDTH / 2);
            } else {
                avatarImageView.center = CGPointMake(self.view.frame.size.width - LEFT_GAP - AVATAR_IMAGE_WIDTH / 2, LEFT_GAP + AVATAR_IMAGE_WIDTH / 2);
            }
            avatarImageView.tag = 1001 + i;
            [cell.contentView addSubview:avatarImageView];
            
            UIButton *imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            imageBtn.frame = avatarImageView.frame;
            [imageBtn addTarget:self action:@selector(viewUser:) forControlEvents:UIControlEventTouchUpInside];
            imageBtn.tag = 2001 + i;
            [cell.contentView addSubview:imageBtn];
            
            UIImageView *roundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 74, 74)];
            roundImageView.image = [UIImage imageNamed:@"user_big"];
            roundImageView.center = avatarImageView.center;
            roundImageView.tag = 3001 + i;
            [cell.contentView addSubview:roundImageView];
            
            UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 58, 21)];
            nameLabel.textColor = [UIColor whiteColor];
            nameLabel.font = [UIFont systemFontOfSize:15];
            [nameLabel setBackgroundColor:[UIColor clearColor]];
            nameLabel.tag = 4001 + i;
            [cell.contentView addSubview:nameLabel];
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            btn.frame = CGRectMake(0, 0, 96, 25);
            btn.center = CGPointMake(avatarImageView.center.x, avatarImageView.center.y + AVATAR_IMAGE_WIDTH / 2 + 45);
            [btn addTarget:self action:@selector(cancelFollow:) forControlEvents:UIControlEventTouchUpInside];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"unfocus"] forState:UIControlStateNormal];
            btn.tag = 5001 + i;
            [cell.contentView addSubview:btn];
        }
    }
    int num = 3;
    if(userArray.count < (indexPath.row+1) * 3){
        num = userArray.count - indexPath.row * 3;
    }
    for (int i = 0; i < 3; i ++){
        UIImageView *avatarImageView = (UIImageView *)[cell viewWithTag:1001 + i];
        UIImageView *roundImageView = (UIImageView *)[cell viewWithTag:3001 + i];
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:4001 + i];
        UIButton *imageBtn = (UIButton *)[cell viewWithTag:2001 + i];
        UIButton *btn = (UIButton *)[cell viewWithTag:5001 + i];
        
        if(i < num){
            NSDictionary *user = [userArray objectAtIndex:indexPath.row * 3 + i];
            NSString *url = [user valueForKey:@"user_pic_url"];
            if([StringUtility stringIsEmpty:url]){
                avatarImageView.image = [UIImage imageNamed:@"u2_normal"];
            } else {
                [avatarImageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"u2_normal"]];
                
            }
            
            nameLabel.text = [user objectForKey:@"nickname"];
            [nameLabel sizeToFit];
            nameLabel.center = CGPointMake(avatarImageView.center.x, avatarImageView.center.y + AVATAR_IMAGE_WIDTH / 2 + 12);
            
            NSString *isFollowed = [NSString stringWithFormat:@"%@", [user objectForKey:@"is_follow"]];
            if([isFollowed isEqualToString:@"1"]){
                [btn setTitle:NSLocalizedString(@"cancel_follow", nil) forState:UIControlStateNormal];
            } else {
                [btn setTitle:NSLocalizedString(@"follow", nil) forState:UIControlStateNormal];
            }            
        } else {
            [avatarImageView removeFromSuperview];
            [roundImageView removeFromSuperview];
            [nameLabel removeFromSuperview];
            [imageBtn removeFromSuperview];
            [btn removeFromSuperview];
        }
        
        
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 292 / 2;
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)closeSelf
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelFollow:(id)sender;
{
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [UIUtility showNetWorkError:self.view];
        return;
    }
    UIButton *btn = (UIButton *)sender;
    CGPoint point = btn.center;
    point = [self.tableView convertPoint:point fromView:btn.superview];
    NSIndexPath* indexPath = [self.tableView indexPathForRowAtPoint:point];
    int index = indexPath.row * 3 + btn.tag - 5001;
    NSString *friendId = [[userArray objectAtIndex:index] objectForKey:@"id"];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:friendId, @"friend_ids", nil];
    if([btn.titleLabel.text isEqualToString:NSLocalizedString(@"follow", nil)]){
        [btn setTitle:NSLocalizedString(@"cancel_follow", nil) forState:UIControlStateNormal];
        [[AFServiceAPIClient sharedClient] postPath:kPathFriendFollow parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            NSString *responseCode = [result objectForKey:@"res_code"];
            if([responseCode isEqualToString:kSuccessResCode]){
            } else {
                
            }
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
        }];
    } else {
        [btn setTitle:NSLocalizedString(@"follow", nil) forState:UIControlStateNormal];
        [[AFServiceAPIClient sharedClient] postPath:kPathFriendDestory parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            NSString *responseCode = [result objectForKey:@"res_code"];
            if([responseCode isEqualToString:kSuccessResCode]){
                
            } else {
                
            }
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
        }];
        
    }
    
}

- (void)viewUser:(id)sender
{
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [UIUtility showNetWorkError:self.view];
        return;
    }
    UIButton *btn = (UIButton *)sender;
    CGPoint point = btn.center;
    point = [self.tableView convertPoint:point fromView:btn.superview];
    NSIndexPath* indexPath = [self.tableView indexPathForRowAtPoint:point];
    int index = indexPath.row * 3 + btn.tag - 2001;
    HomeViewController *viewController = [[HomeViewController alloc]initWithNibName:@"HomeViewController" bundle:nil];
    viewController.userid = [[userArray objectAtIndex:index] valueForKey:@"id"];
    [self.navigationController pushViewController:viewController animated:YES];
    
}

- (void)finishRegister
{
    [[ContainerUtility sharedInstance]setAttribute:[NSNumber numberWithBool:YES] forKey:kUserLoggedIn];
    [self dismissModalViewControllerAnimated:YES];
    //    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    //    [appDelegate refreshRootView];
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
    //    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
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
    //    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
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
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithInt:reloads_], @"page_num",[NSNumber numberWithInt:pageSize], @"page_size",
                                nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathPopularUser parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *friends = [result objectForKey:@"prestiges"];
            if(friends != nil && friends.count > 0){
                [userArray addObjectsFromArray:friends];
                reloads_++;
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
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
	
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
    //	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
	
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
