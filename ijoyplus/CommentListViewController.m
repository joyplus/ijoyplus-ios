//
//  CommentViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-27.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "CommentListViewController.h"
#import "CMConstants.h"
#import "UIUtility.h"
#import "CustomBackButton.h"
#import "StringUtility.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "CommentCell.h"
#import "TTTTimeIntervalFormatter.h"
#import "UIImageView+WebCache.h"
#import "DateUtility.h"
#import "HomeViewController.h"
#import "CommentViewController.h"
#import "ContainerUtility.h"

@interface CommentListViewController (){
    UIToolbar *containerView;
    MNMBottomPullToRefreshManager *pullToRefreshManager_;
    NSUInteger reloads_;
    EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
    NSMutableArray *commentArray;
    int pageSize;
}
-(void)resignTextView;
@end

@implementation CommentListViewController
@synthesize programId;
@synthesize table;
- (void)viewDidUnload
{
    [super viewDidUnload];
    pullToRefreshManager_ = nil;
    _refreshHeaderView = nil;
    commentArray = nil;
    self.programId = nil;
    self.table = nil;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CustomBackButton *backButton = [[CustomBackButton alloc] initWith:[UIImage imageNamed:@"back-button"] highlight:[UIImage imageNamed:@"back-button"] leftCapWidth:14.0 text:NSLocalizedString(@"back", nil)];
    [backButton addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.table setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    pageSize = 10;
    reloads_ = 1;
    commentArray = [[NSMutableArray alloc]initWithCapacity:pageSize];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: kAppKey, @"app_key", self.programId, @"prod_id",[NSNumber numberWithInt:reloads_], @"page_num", [NSNumber numberWithInt:pageSize], @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathProgramComments parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *comments = (NSArray *)[result objectForKey:@"comments"];
            if(comments != nil && comments.count > 0){
                [commentArray addObjectsFromArray:comments];
                reloads_++;
                pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:480.0f tableView:self.table withClient:self];
            }
            [self loadTable];
        } else {
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
    if (_refreshHeaderView == nil) {
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.table.bounds.size.height, self.view.frame.size.width, self.table.bounds.size.height)];
        view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"back_up2"]];
		view.delegate = self;
		[self.table addSubview:view];
		_refreshHeaderView = view;
		
	}
	[_refreshHeaderView refreshLastUpdatedDate];
}

- (void)loadTable {
    
    [self.table reloadData];
    
    [pullToRefreshManager_ tableViewReloadFinished];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)closeSelf
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return commentArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentCell *cell = (CommentCell*) [tableView dequeueReusableCellWithIdentifier:@"commentCell"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PopularCellFactory" owner:self options:nil];
        cell = (CommentCell *)[nib objectAtIndex:2];
    }
    NSMutableDictionary *commentDic = [commentArray objectAtIndex:indexPath.row];
    NSString *ownerPicUrl = [commentDic valueForKey:@"owner_pic_url"];
    if([StringUtility stringIsEmpty:ownerPicUrl]){
        cell.avatarImageView.image = [UIImage imageNamed:@"u2_normal"];
    } else {
        [cell.avatarImageView setImageWithURL:[NSURL URLWithString:ownerPicUrl] placeholderImage:[UIImage imageNamed:@"u2_normal"]];
    }
    cell.avatarImageView.layer.cornerRadius = 25;
    cell.avatarImageView.layer.masksToBounds = YES;
    //        cell.avatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    //        cell.avatarImageView.layer.borderWidth = 3;
    cell.titleLabel.text = [commentDic objectForKey:@"owner_name"];
    
    NSString *content =  [commentDic objectForKey:@"content"];
    if([StringUtility stringIsEmpty:content]){
        content = @"";
    }
    cell.subtitleLabel.text = content;
    [cell.subtitleLabel setNumberOfLines:0];
    CGSize constraint = CGSizeMake(cell.titleLabel.frame.size.width, 20000.0f);
    CGSize size = [content sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    [cell.subtitleLabel setFrame:CGRectMake(cell.subtitleLabel.frame.origin.x, cell.subtitleLabel.frame.origin.y, size.width, size.height)];
    
    NSInteger yPosition = cell.subtitleLabel.frame.origin.y + size.height + 10;
    cell.thirdTitleLabel.frame = CGRectMake(cell.thirdTitleLabel.frame.origin.x, yPosition, cell.thirdTitleLabel.frame.size.width, cell.thirdTitleLabel.frame.size.height);
    
    TTTTimeIntervalFormatter *timeFormatter = [[TTTTimeIntervalFormatter alloc]init];
    NSString *createDate = [commentDic valueForKey:@"create_date"];
    if([StringUtility stringIsEmpty:createDate]){
        cell.thirdTitleLabel.text = @"很早以前";
    } else {
        NSDate *commentDate = [DateUtility dateFromFormatString:createDate formatString: @"yyyy-MM-dd HH:mm:ss"];
        NSString *timeDiff = [timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:commentDate];
        cell.thirdTitleLabel.text = timeDiff;
    }
    [cell.replyBtn setHidden:NO];
    cell.replyBtn.frame = CGRectMake(cell.thirdTitleLabel.frame.origin.x + 210, yPosition, 40, 20);
    [cell.replyBtn setTitle:NSLocalizedString(@"reply", nil) forState:UIControlStateNormal];
    [cell.replyBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [cell.replyBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    cell.replyBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|
    UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [cell.replyBtn setBackgroundImage:[UIImage imageNamed:@"background"] forState:UIControlStateNormal];
    [cell.replyBtn setBackgroundImage:[UIImage imageNamed:@"background"] forState:UIControlStateHighlighted];
    [cell.replyBtn addTarget:self action:@selector(replyBtnClicked:)forControlEvents:UIControlEventTouchUpInside];
    
    [cell.avatarBtn addTarget:self action:@selector(avatarClicked:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *commentDic = [commentArray objectAtIndex:indexPath.row];
    NSString *content =  [commentDic objectForKey:@"content"];
    if([StringUtility stringIsEmpty:content]){
        content = @"";
    }
    CGSize constraint = CGSizeMake(232, 20000.0f);
    CGSize size = [content sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    return 80 + size.height;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CommentViewController *viewController = [[CommentViewController alloc]initWithNibName:@"CommentViewController" bundle:nil];
    viewController.threadId = [[commentArray objectAtIndex:indexPath.row] valueForKey:@"id"];
    viewController.title = @"评论回复";
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)avatarClicked:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    CGPoint point = btn.center;
    point = [self.table convertPoint:point fromView:btn.superview];
    NSIndexPath* indexpath = [self.table indexPathForRowAtPoint:point];
    
    HomeViewController *viewController = [[HomeViewController alloc]initWithNibName:@"HomeViewController" bundle:nil];
    viewController.userid = [[commentArray objectAtIndex:indexpath.row] valueForKey:@"owner_id"];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)replyBtnClicked:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    CGPoint point = btn.center;
    point = [self.table convertPoint:point fromView:btn.superview];
    NSIndexPath* indexpath = [self.table indexPathForRowAtPoint:point];
    
    CommentViewController *viewController = [[CommentViewController alloc]initWithNibName:@"CommentViewController" bundle:nil];
    viewController.threadId = [[commentArray objectAtIndex:indexpath.row] valueForKey:@"id"];
    viewController.title = @"评论回复";
    viewController.openKeyBoard = YES;
    [self.navigationController pushViewController:viewController animated:YES];
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
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: kAppKey, @"app_key", self.programId, @"prod_id",[NSNumber numberWithInt:reloads_], @"page_num", [NSNumber numberWithInt:pageSize], @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathProgramComments parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *comments = (NSArray *)[result objectForKey:@"comments"];
            if(comments != nil && comments.count > 0){
                reloads_++;
                [commentArray addObjectsFromArray:comments];
            }
            [self performSelector:@selector(loadTable) withObject:nil afterDelay:2.0f];
        } else {
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    reloads_ = 1;
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: kAppKey, @"app_key", self.programId, @"prod_id",[NSNumber numberWithInt:reloads_], @"page_num", [NSNumber numberWithInt:pageSize], @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathProgramComments parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *comments = (NSArray *)[result objectForKey:@"comments"];
            if(comments != nil && comments.count > 0){
                reloads_++;
                [commentArray removeAllObjects];
                [commentArray addObjectsFromArray:comments];
            }
            [self performSelector:@selector(loadTable) withObject:nil afterDelay:2.0f];
        } else {
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        
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
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

@end
