//
//  PlayViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-11.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "MyShowPlayDetailViewController.h"
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
#import "NoRecordCell.h"
#import "CommentViewController.h"
#define MAX_FRIEND_COMMENT_COUNT 10
#define MAX_COMMENT_COUNT 10

@interface MyShowPlayDetailViewController (){
    CGSize reasonSize;
}

@end

@implementation MyShowPlayDetailViewController

- (void)viewDidUnload
{
    [super viewDidUnload];
    reasonCell = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ListCellFactory" owner:self options:nil];
    reasonCell = (RecommendReasonCell *)[nib objectAtIndex:2];
    reasonCell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section < 2){
        return 1;
    } else if (section == 2) {
        return episodeArray.count;
    } else if (section == 3) {
        return 1;
    } else if (section == 4) {
        if(friendCommentArray == nil || friendCommentArray.count == 0){
            return 1;
        } else {
            return friendCommentArray.count;
        }
    }else {
        if(commentArray == nil || commentArray.count == 0){
            return 1;
        } else if (commentArray.count >= MAX_COMMENT_COUNT){
            return MAX_COMMENT_COUNT + 1;
        } else {
            return commentArray.count;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return pictureCell;
    } else if (indexPath.section == 1) {
        return playCell;
    } else if (indexPath.section == 2){
        UITableViewCell *cell = [self displayEpisodeCell:tableView cellForRowAtIndexPath:indexPath cellIdentifier:@"episodeCell"];
        return cell;
    } else if (indexPath.section == 3) {
        return reasonCell;
    } else if (indexPath.section == 4) {
        if(friendCommentArray == nil || friendCommentArray.count == 0){
            NoRecordCell *cell = [self displayNoRecordCell:tableView];
            cell.textField.text = @"暂无观看好友";
            return cell;
        } else {
            CommentCell *cell = [self displayFriendCommentCell:tableView cellForRowAtIndexPath:indexPath commentArray:friendCommentArray cellIdentifier:@"commentCell"];
            return cell;
        }
    }else {
        if(commentArray == nil || commentArray.count == 0){
            NoRecordCell *cell = [self displayNoRecordCell:tableView];
            cell.textField.text = @"暂无评论";
            return cell;
        } else if(indexPath.row == MAX_COMMENT_COUNT){
            LoadMoreCell *cell = [self displayLoadMoreCell:tableView];
            return cell;
        } else {
            CommentCell *cell = [self displayCommentCell:tableView cellForRowAtIndexPath:indexPath commentArray:commentArray cellIdentifier:@"commentCell"];
            return cell;
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return WindowHeight;
    } else if (indexPath.section == 1) {
        return playCell.frame.size.height;
    } else if(indexPath.section == 2){
        if(episodeArray.count > 1){
            return 44;
        } else {
            return 0;
        }
    } else if (indexPath.section == 3) {
        return reasonSize.height + 20;
    } else if (indexPath.section == 4) {
        if(friendCommentArray == nil || friendCommentArray.count == 0){
            return 44;
        } else {
            CGFloat height = [self caculateCommentCellHeight:indexPath.row dataArray:friendCommentArray];
            return height;
        }
    } else {
        if(commentArray == nil || commentArray.count == 0 || indexPath.row == MAX_COMMENT_COUNT){
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
    if(indexPath.section == 2 && episodeArray.count > 1){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self gotoWebsite:indexPath.row];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if (indexPath.section == 5 && commentArray.count > 0) {
        if(indexPath.row == MAX_COMMENT_COUNT){
            CommentListViewController *viewController = [[CommentListViewController alloc]initWithNibName:@"CommentListViewController" bundle:nil];
            viewController.programId = self.programId;
            viewController.title = @"全部评论";
            [self.navigationController pushViewController:viewController animated:YES];
        } else{
            CommentViewController *viewController = [[CommentViewController alloc]initWithNibName:@"CommentViewController" bundle:nil];
            viewController.threadId = [[commentArray objectAtIndex:indexPath.row] objectForKey:@"id"];
            viewController.title = @"评论回复";
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section < 2) {
        return 0;
    } else if (section == 2) {
        if(episodeArray.count > 1){
            return 24;
        } else {
            return 0;
        }
    } else {
        return 24;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section < 2){
        return nil;
    }
    if (section == 2) {
        if(episodeArray.count > 1
           ){
        } else {
            return nil;
        }
    }
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width, 24)];
    customView.backgroundColor = [UIColor blackColor];
    
    // create the label objects
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,0,self.view.bounds.size.width-10, 24)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:12];
    if(section == 2){
        headerLabel.text = NSLocalizedString(@"show_list", nil);
    } else if(section == 3){
        headerLabel.text =  NSLocalizedString(@"recommend_reason", nil);
    } else if(section == 4){
        headerLabel.text =  NSLocalizedString(@"friend_comment", nil);
    } else {
        headerLabel.text =  NSLocalizedString(@"user_comment", nil);
    }
    headerLabel.textColor = [UIColor whiteColor];
    [customView addSubview:headerLabel];
    
    return customView;
}

- (void)avatarClicked:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    CGPoint point = btn.center;
    point = [_tableView convertPoint:point fromView:btn.superview];
    NSIndexPath* indexpath = [_tableView indexPathForRowAtPoint:point];
    
    HomeViewController *viewController = [[HomeViewController alloc]initWithNibName:@"HomeViewController" bundle:nil];
    if(indexpath.section == 4){
        viewController.userid = [[friendCommentArray objectAtIndex:indexpath.row] valueForKey:@"user_id"];
    } else if(indexpath.section == 5){
        viewController.userid = [[commentArray objectAtIndex:indexpath.row] valueForKey:@"owner_id"];
        
    }
    [self.navigationController pushViewController:viewController animated:YES];
}


- (void) postInitialization:(NSDictionary *)result;
{
    NSString *content = [result objectForKey:@"reason"];
    if([StringUtility stringIsEmpty:content]){
        content = @"";
    }
    reasonCell.reasonContent.text = content;
    [reasonCell.reasonContent setNumberOfLines:0];
    CGSize constraint = CGSizeMake(reasonCell.reasonContent.frame.size.width, 20000.0f);
    reasonSize = [content sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    reasonSize = [content sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    [reasonCell.reasonContent setFrame:CGRectMake(reasonCell.reasonContent.frame.origin.x, 10, reasonCell.reasonContent.frame.size.width, reasonSize.height)];
}
@end
