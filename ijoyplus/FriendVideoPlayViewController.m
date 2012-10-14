//
//  PlayViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-11.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "FriendVideoPlayViewController.h"
#import "PlayCell.h"
#import "CommentCell.h"
#import "UIImageView+WebCache.h"
#import "CMConstants.h"
#import "DateUtility.h"
#import "TTTTimeIntervalFormatter.h"
#import "CommentListViewController.h"
#import "ContainerUtility.h"
#import "PostViewController.h"
#import "HomeViewController.h"
#import "LoadMoreCell.h"
#import "DramaCell.h"
#import "UIUtility.h"
#import "StringUtility.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "ProgramViewController.h"
#import "NoRecordCell.h"
#import "CommentViewController.h"
#define MAX_FRIEND_COMMENT_COUNT 10
#define MAX_COMMENT_COUNT 10
@interface FriendVideoPlayViewController (){
    NSMutableArray *friendCommentArray;
}

@end

@implementation FriendVideoPlayViewController

- (void)viewDidUnload
{
    [super viewDidUnload];
    subviewController = nil;
    playCell = nil;
    dramaCell = nil;
    commentArray = nil;
    self.programId = nil;
    show = nil;
    _refreshHeaderView = nil;
    friendCommentArray = nil;
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
}

- (void)getProgramView
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                kAppKey, @"app_key",
                                self.programId, @"prod_id",
                                nil];
    
    [[AFServiceAPIClient sharedClient] getPath:kPathProgramViewRecommend parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        //        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        //        HUD.mode = MBProgressHUDModeCustomView;
        //        [self.view addSubview:HUD];
        if(responseCode == nil){
            show = (NSDictionary *)[result objectForKey:@"video"];
            [self setPlayCellValue];
            
            friendCommentArray = (NSMutableArray *)[result objectForKey:@"dynamics"];
            if(friendCommentArray == nil || friendCommentArray.count == 0){
                friendCommentArray = [[NSMutableArray alloc]initWithCapacity:5];
            }
            
            commentArray = (NSMutableArray *)[result objectForKey:@"comments"];
            if(commentArray == nil || commentArray.count == 0){
                commentArray = [[NSMutableArray alloc]initWithCapacity:10];
            }
//            [self initDramaCell];
            [self loadTable];
            if(pullToRefreshManager_ == nil){
                pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f tableView:self.tableView withClient:self];
            }
        } else {

        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {

    }];
}



//- (void)initDramaCell
//{
//    dramaCell = [[DramaCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"dramaCell"];
//    dramaCell.frame = CGRectMake(0, 0, self.view.frame.size.width, ceil(totalDramaCount / 5.0) * 35);
//    dramaCell.selectionStyle = UITableViewCellSelectionStyleNone;
//    for (int i = 0; i < totalDramaCount; i++) {        
//        UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        btn.tag = i+1;
//        [btn setFrame:CGRectMake(10 + (i % 5) * 61, 5 + floor(i / 5.0) * 30, 59, 25)];
//        [btn setTitle:[NSString stringWithFormat:@"%i", i+1] forState:UIControlStateNormal];
//        [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
//        [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
//        [UIUtility addTextShadow:btn.titleLabel];
//        btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|
//        UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
//        [btn setBackgroundImage:[[UIImage imageNamed:@"unfocus"]stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
//        [btn setBackgroundImage:[UIUtility createImageWithColor:[UIColor blackColor]] forState:UIControlStateHighlighted];
//        [btn addTarget:self action:@selector(dramaPlay:)forControlEvents:UIControlEventTouchUpInside];
//        [dramaCell.contentView addSubview:btn];
//    }
//}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return 1;
    } else if (section == 1){
        return friendCommentArray.count;
    } else {
        if(commentArray == nil || commentArray.count == 0){
            return 1;
        } else {
            return commentArray.count;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return playCell;
    } else if (indexPath.section == 1) {
            CommentCell *cell = [self displayFriendCommentCell:tableView cellForRowAtIndexPath:indexPath commentArray:friendCommentArray cellIdentifier:@"commentCell"];
            return cell;
        
    }else {
        if(commentArray == nil || commentArray.count == 0){
            NoRecordCell *cell = [self displayNoRecordCell:tableView];
            cell.textField.text = @"暂无评论";
            return cell;
        } else {
            CommentCell *cell = [self displayCommentCell:tableView cellForRowAtIndexPath:indexPath commentArray:commentArray cellIdentifier:@"commentCell"];
            return cell;
        }
    }
}

- (NoRecordCell *)displayNoRecordCell:(UITableView *)tableView
{
    NoRecordCell *cell = (NoRecordCell*) [tableView dequeueReusableCellWithIdentifier:@"noRecordCell"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CommonCellFactory" owner:self options:nil];
        cell = (NoRecordCell *)[nib objectAtIndex:0];
    }
    return cell;
}

- (CommentCell *)displayFriendCommentCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath commentArray:(NSArray *)dataArray cellIdentifier:(NSString *)cellIdentifier
{
    CommentCell *cell = (CommentCell*) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PopularCellFactory" owner:self options:nil];
        cell = (CommentCell *)[nib objectAtIndex:2];
    }
    NSMutableDictionary *commentDic = [dataArray objectAtIndex:indexPath.row];
    NSString *ownerPicUrl = [commentDic valueForKey:@"owner_pic_url"];
    if([StringUtility stringIsEmpty:ownerPicUrl]){
        cell.avatarImageView.image = [UIImage imageNamed:@"u2_normal"];
    } else {
        [cell.avatarImageView setImageWithURL:[NSURL URLWithString:ownerPicUrl] placeholderImage:[UIImage imageNamed:@"u2_normal"]];
    }
    cell.avatarImageView.layer.cornerRadius = 25;
    cell.avatarImageView.layer.masksToBounds = YES;
    cell.titleLabel.text = [commentDic objectForKey:@"user_name"];
    
    NSString *type = [commentDic objectForKey:@"type"];
    if([type isEqualToString:@"comment"]){
        cell.subtitleLabel.text = @"评论了该视频。";
    } else if([type isEqualToString:@"favority"]){
        cell.subtitleLabel.text = @"收藏了该视频。";
    } else if([type isEqualToString:@"recommend"]){
        cell.subtitleLabel.text = @"推荐了该视频。";
    } else{
        cell.subtitleLabel.text = @"看过该视频。";
    }
    
    NSInteger yPosition = cell.subtitleLabel.frame.origin.y + 20;
    cell.thirdTitleLabel.frame = CGRectMake(cell.thirdTitleLabel.frame.origin.x, yPosition, cell.thirdTitleLabel.frame.size.width, cell.thirdTitleLabel.frame.size.height);
    
    TTTTimeIntervalFormatter *timeFormatter = [[TTTTimeIntervalFormatter alloc]init];
    NSString *createDate = [commentDic valueForKey:@"create_date"];
    NSDate *commentDate = [DateUtility dateFromFormatString:createDate formatString: @"yyyy-MM-dd HH:mm:ss"];
    NSString *timeDiff = [timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:commentDate];
    cell.thirdTitleLabel.text = timeDiff;
    [cell.replyBtn setHidden:YES];
    [cell.avatarBtn addTarget:self action:@selector(avatarClicked:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (LoadMoreCell *)displayLoadMoreCell:(UITableView *)tableView
{
    LoadMoreCell *cell = (LoadMoreCell*) [tableView dequeueReusableCellWithIdentifier:@"loadMoreCell"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FriendCellFactory" owner:self options:nil];
        cell = (LoadMoreCell *)[nib objectAtIndex:0];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return playCell.frame.size.height;
    } else if (indexPath.section == 1) {
        if(friendCommentArray == nil || friendCommentArray.count == 0){
            return 44;
        } else {
            CGFloat height = [self caculateCommentCellHeight:indexPath.row dataArray:friendCommentArray];
            return height;
        }
    } else {
        if(commentArray == nil || commentArray.count == 0){
            return 44;
        } else {
            CGFloat height = [self caculateCommentCellHeight:indexPath.row dataArray:commentArray];
            return height;
        }
    }
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
    if(indexPath.section > 0){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if(indexPath.section == 1) {
            
        } else if (indexPath.section == 2) {
            if(indexPath.row == MAX_COMMENT_COUNT){
                CommentListViewController *viewController = [[CommentListViewController alloc]initWithNibName:@"CommentListViewController" bundle:nil];
                viewController.programId = self.programId;
                viewController.title = @"全部评论";
                [self.navigationController pushViewController:viewController animated:YES];
            } else{
                CommentViewController *viewController = [[CommentViewController alloc]initWithNibName:@"CommentViewController" bundle:nil];
                viewController.threadId = [[commentArray objectAtIndex:indexPath.row] objectForKey:@"thread_id"];
                viewController.title = @"评论回复";
                [self.navigationController pushViewController:viewController animated:YES];
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    } else {
        return 24;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return nil;
    }
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width, 24)];
    customView.backgroundColor = [UIColor blackColor];
    
    // create the label objects
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,0,self.view.bounds.size.width-10, 24)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:12];
    if(section == 2){
        headerLabel.text =  NSLocalizedString(@"friend_comment", nil);
    } else {
        headerLabel.text =  NSLocalizedString(@"user_comment", nil);
    }
    headerLabel.textColor = [UIColor whiteColor];
    [customView addSubview:headerLabel];
    
    return customView;
}

@end
