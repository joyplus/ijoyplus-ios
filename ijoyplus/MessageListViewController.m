//
//  CommentListViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-25.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "MessageListViewController.h"
#import "DateUtility.h"
#import "CommentCell.h"
#import "CustomBackButton.h"
#import "TTTTimeIntervalFormatter.h"
#import "UIImageView+WebCache.h"
#import "CMConstants.h"
#import "MessageCell.h"
#import "StringUtility.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "ContainerUtility.h"
#import "HomeViewController.h"
#import "CacheUtility.h"
#import "UIUtility.h"

@interface MessageListViewController (){
    NSMutableArray *commentArray;
    int pageSize;
    EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
    MNMBottomPullToRefreshManager *pullToRefreshManager_;
    NSUInteger reloads_;
    MBProgressHUD *HUD;
}

@end

@implementation MessageListViewController

- (void)viewDidUnload
{
    [super viewDidUnload];
    [commentArray removeAllObjects];
    commentArray = nil;
    _refreshHeaderView = nil;
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
    self.title = NSLocalizedString(@"my_message", nil);
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    CustomBackButton *backButton = [[CustomBackButton alloc] initWith:[UIImage imageNamed:@"back-button"] highlight:[UIImage imageNamed:@"back-button"] leftCapWidth:14.0 text:NSLocalizedString(@"back", nil)];
    [backButton addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideProgressBar) name:@"top_segment_clicked" object:nil];
    pageSize = 10;
    reloads_++;
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:@"MessageListViewController"];
    if(cacheResult != nil){
        [self parseData:cacheResult];
    }
    if([[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:reloads_], @"page_num", [NSNumber numberWithInt:pageSize], @"page_size", nil];
        [[AFServiceAPIClient sharedClient] getPath:kPathUserMsgs parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [self parseData:result];
            reloads_ ++;
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
            commentArray = [[NSMutableArray alloc]initWithCapacity:pageSize];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
        }];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
        [UIUtility showNetWorkError:self.view];
    }
    pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:480.0f tableView:self.tableView withClient:self];
}

- (void)parseData:(id)result
{
    commentArray = [[NSMutableArray alloc]initWithCapacity:pageSize];
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        [[CacheUtility sharedCache] putInCache:@"MessageListViewController" result:result];
        NSArray *comment = [result objectForKey:@"msgs"];
        if(comment.count > 0){
            [commentArray addObjectsFromArray:comment];
            [self loadTable];
        }
    } else {

    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
}

- (void) hideProgressBar
{
    [HUD hide:YES afterDelay:0.3];
}

- (void)viewWillAppear:(BOOL)animated
{
    if(commentArray == nil){
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        HUD.opacity = 0;
        [HUD show:YES];
    }
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return commentArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ListCellFactory" owner:self options:nil];
    MessageCell *cell = (MessageCell *)[nib objectAtIndex:0];
    NSMutableDictionary *commentDic = [commentArray objectAtIndex:indexPath.row];
    NSString *avatarUrl = (NSString *)[commentDic valueForKey:@"user_pic_url"];
    if([StringUtility stringIsEmpty:avatarUrl]){
        cell.avatarImageView.image = [UIImage imageNamed:@"u2_normal"];
    } else{
        [cell.avatarImageView setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:[UIImage imageNamed:@"u2_normal"]];
    }
    cell.avatarImageView.layer.cornerRadius = 25;
    cell.avatarImageView.layer.masksToBounds = YES;
    cell.titleLabel.text = [commentDic objectForKey:@"user_name"];
    [cell.titleLabel sizeToFit];
    cell.titleLabel.center = CGPointMake(cell.avatarImageView.center.x, cell.avatarImageView.frame.origin.y + 60);
    NSString *type = [commentDic valueForKey:@"type"];
    NSInteger yPosition;
    TTTTimeIntervalFormatter *timeFormatter = [[TTTTimeIntervalFormatter alloc]init];
    NSString *timeDiff;
    if([@"follow" isEqualToString:type]){
        cell.actionTitleLabel.text = @"关注了您！";
        [cell.actionTitleLabel sizeToFit];
        yPosition = cell.actionTitleLabel.frame.origin.y + 35;
        cell.myCommentView.frame = CGRectZero;
        cell.subtitleLabel.text = @"";
        cell.actionDetailTitleLabel.text = @"";
        cell.myCommentViewName = nil;
        cell.myCommentViewContent = nil;
        cell.myCommentViewContent.text = @"";
        cell.myCommentViewTime = nil;
    } else if([@"comment" isEqualToString:type]){
        cell.myCommentView.frame = CGRectZero;
        cell.actionTitleLabel.text = @"评论了";
        [cell.actionTitleLabel sizeToFit];
        NSMutableString *actionDetailString = [[NSMutableString alloc]initWithCapacity:20];
        for (int i = 0; i < cell.actionTitleLabel.text.length; i++) {
            [actionDetailString appendString:@"    "];
        }
        NSString *filmName = [commentDic objectForKey:@"prod_name"];
        [actionDetailString appendString:[NSString stringWithFormat:@"你推荐的视频《%@》。", filmName]];
        cell.actionDetailTitleLabel.text = actionDetailString;
        [cell.actionDetailTitleLabel setNumberOfLines:0];
        CGSize constraint = CGSizeMake(cell.actionDetailTitleLabel.frame.size.width, 20000.0f);
        CGSize size1 = [actionDetailString sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        [cell.actionDetailTitleLabel setFrame:CGRectMake(cell.actionDetailTitleLabel.frame.origin.x, cell.actionDetailTitleLabel.frame.origin.y, size1.width, size1.height)];
        
        cell.subtitleLabel.text = [commentDic objectForKey:@"content"];
        [cell.subtitleLabel setNumberOfLines:0];
        constraint = CGSizeMake(cell.subtitleLabel.frame.size.width, 20000.0f);
        CGSize size = [[commentDic objectForKey:@"content"] sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        [cell.subtitleLabel setFrame:CGRectMake(cell.subtitleLabel.frame.origin.x, cell.actionDetailTitleLabel.frame.origin.y + size1.height, size.width, size.height)];
        yPosition = cell.subtitleLabel.frame.origin.y + size.height + 10;
    } else {
        cell.actionTitleLabel.text = @"回复了";
        [cell.actionTitleLabel sizeToFit];
        NSMutableString *actionDetailString = [[NSMutableString alloc]initWithCapacity:20];
        for (int i = 0; i < cell.actionTitleLabel.text.length; i++) {
            [actionDetailString appendString:@"    "];
        }
        NSString *filmName = [commentDic objectForKey:@"prod_name"];
        [actionDetailString appendString:[NSString stringWithFormat:@"您在《%@》中的评论。", filmName]];
        cell.actionDetailTitleLabel.text = actionDetailString;
        [cell.actionDetailTitleLabel setNumberOfLines:0];
        CGSize constraint = CGSizeMake(cell.actionDetailTitleLabel.frame.size.width, 20000.0f);
        CGSize size = [actionDetailString sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        [cell.actionDetailTitleLabel setFrame:CGRectMake(cell.actionDetailTitleLabel.frame.origin.x, cell.actionDetailTitleLabel.frame.origin.y, size.width, size.height)];
        
        cell.subtitleLabel.text = [commentDic objectForKey:@"content"];
        [cell.subtitleLabel setNumberOfLines:0];
        constraint = CGSizeMake(cell.subtitleLabel.frame.size.width, 20000.0f);
        size = [[commentDic objectForKey:@"content"] sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        [cell.subtitleLabel setFrame:CGRectMake(cell.subtitleLabel.frame.origin.x, cell.subtitleLabel.frame.origin.y, size.width, size.height)];
        yPosition = cell.subtitleLabel.frame.origin.y + size.height + 10;
        cell.myCommentViewContent.text = [commentDic objectForKey:@"thread_comment"];
        if(cell.myCommentViewContent.text != nil){
            NSString *loginUserName = (NSString *)[[ContainerUtility sharedInstance] attributeForKey:kUserNickName];
            cell.myCommentViewName.text = loginUserName;
            [cell.myCommentViewContent setNumberOfLines:0];
            constraint = CGSizeMake(cell.myCommentViewContent.frame.size.width, 20000.0f);
            size = [cell.myCommentViewContent.text sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
            [cell.myCommentViewContent setFrame:CGRectMake(cell.myCommentViewContent.frame.origin.x, cell.myCommentViewContent.frame.origin.y, size.width, size.height)];
            
            cell.myCommentViewTime.frame = CGRectMake(cell.myCommentViewTime.frame.origin.x, cell.myCommentViewTime.frame.origin.y, cell.myCommentViewContent.frame.size.width, cell.myCommentViewContent.frame.size.height);
            NSString *dateString = [commentDic valueForKey:@"create_date"];
            NSDate *date = [NSDate date];
            if(![StringUtility stringIsEmpty:dateString]){
                date = [DateUtility dateFromFormatString:dateString formatString:@"yyyy-MM-dd HH:mm:ss"];
            }
            timeDiff = [timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:date];
            cell.myCommentViewTime.text = timeDiff;
            [cell.myCommentViewTime sizeToFit];
            cell.myCommentView.frame = CGRectMake(cell.myCommentView.frame.origin.x, yPosition, cell.myCommentView.frame.size.width, size.height + 50);
            //        cell.myCommentView.backgroundColor = [UIColor clearColor];
        } else{
            cell.myCommentView.frame = CGRectZero;
            cell.myCommentViewName = nil;
            cell.myCommentViewContent = nil;
            cell.myCommentViewTime = nil;
        }
        yPosition = cell.subtitleLabel.frame.origin.y + cell.subtitleLabel.frame.size.height + cell.myCommentView.frame.size.height + 20;
    }
    cell.thirdTitleLabel.frame = CGRectMake(cell.thirdTitleLabel.frame.origin.x, yPosition, cell.thirdTitleLabel.frame.size.width, cell.thirdTitleLabel.frame.size.height);
    NSString *dateString = [commentDic valueForKey:@"create_date"];
    NSDate *date = [NSDate date];
    if(![StringUtility stringIsEmpty:dateString]){
        date = [DateUtility dateFromFormatString:dateString formatString:@"yyyy-MM-dd HH:mm:ss"];
    }
    timeDiff = [timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:date];
    cell.thirdTitleLabel.text = timeDiff;
    
    [cell.avatarBtn addTarget:self action:@selector(avatarClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)avatarClicked:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    CGPoint point = btn.center;
    point = [self.tableView convertPoint:point fromView:btn.superview];
    NSIndexPath* indexpath = [self.tableView indexPathForRowAtPoint:point];
    
    HomeViewController *viewController = [[HomeViewController alloc]initWithNibName:@"HomeViewController" bundle:nil];
    viewController.userid = [[commentArray objectAtIndex:indexpath.row] valueForKey:@"user_id"];
    [self.navigationController pushViewController:viewController animated:YES];
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
    NSString *type = [commentDic valueForKey:@"type"];
    if([@"follow" isEqualToString:type]){
        return 80;
    } else {
        NSString *myCommentString = (NSString *)[commentDic valueForKey:@"content"];
        CGSize constraint;
        CGSize size1;
        if(myCommentString != nil) {
            constraint = CGSizeMake(220, 20000.0f);
            size1 = [myCommentString sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        } else {
            size1 = CGSizeZero;
        }
        
        NSString *content = [commentDic objectForKey:@"thread_comment"];
        constraint = CGSizeMake(220, 20000.0f);
        CGSize size2 = [content sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        if(content == nil){
            return size1.height + 110;
        } else {
            return size1.height + size2.height + 160;
        }
    }
    
}

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
    [self dismissModalViewControllerAnimated:YES];
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
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [UIUtility showNetWorkError:self.view];
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:2.0f];
        return;
    }
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:reloads_], @"page_num", [NSNumber numberWithInt:pageSize], @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathUserMsgs parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *comment = [result objectForKey:@"msgs"];
            if(comment.count > 0){
                [commentArray addObjectsFromArray:comment];
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
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
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
