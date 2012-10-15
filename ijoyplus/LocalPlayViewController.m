//
//  PlayViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-11.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "LocalPlayViewController.h"
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

#define ANIMATION_DURATION 0.4
#define ANIMATION_DELAY 0

#define ROW_HEIGHT 40
#define PUBLISH_HEIGHT 15

@interface LocalPlayViewController (){

}
- (void)showIntroduction;
- (void)playVideo;
- (void)getProgramView;
@end

@implementation LocalPlayViewController
@synthesize imageHeight;
@synthesize programId;

- (void)viewDidUnload
{
    [super viewDidUnload];
    subviewController = nil;
    playCell = nil;
    dramaCell = nil;
    commentArray = nil;
    programId = nil;
    show = nil;
    _refreshHeaderView = nil;
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
    self.imageHeight = 160;
    [self initPlayCell];
    totalDramaCount = 0;
    [self getProgramView];
//    [self initDramaCell];
    
    if (_refreshHeaderView == nil) {
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
        view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"back_up"]];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
		
	}
	[_refreshHeaderView refreshLastUpdatedDate];
}

- (void)initPlayCell
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PopularCellFactory" owner:self options:nil];
    playCell = (PlayCell *)[nib objectAtIndex:3];
    playCell.filmImageView.frame = CGRectMake(0, 0, playCell.filmImageView.frame.size.width, self.imageHeight);
    //    [playCell.introuctionBtn setTitle: NSLocalizedString(@"introduction", nil) forState:UIControlStateNormal];
    [playCell.introuctionBtn addTarget:self action:@selector(showIntroduction) forControlEvents:UIControlEventTouchUpInside];
    playCell.playBtn.center = CGPointMake(playCell.playBtn.center.x, self.imageHeight / 2);
    playCell.playImageView.center = CGPointMake(playCell.playImageView.center.x, self.imageHeight / 2);
    [playCell.playBtn setTitle:@"" forState:UIControlStateNormal];
    [playCell.playBtn addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
    
    //    NSString *name = @"电影名称电影名称电影名称电影名称电影名称电影名称电影名称电影名称电影名称电影名称电影名称1234567890";
    //    playCell.publicLabel.text = @"发布者名称";
}


- (void)getProgramView
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                kAppKey, @"app_key",
                                self.programId, @"prod_id",
                                nil];
    
    [[AFServiceAPIClient sharedClient] getPath:kPathProgramView parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        //        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        //        HUD.mode = MBProgressHUDModeCustomView;
        //        [self.view addSubview:HUD];
        if(responseCode == nil){
            show = (NSDictionary *)[result objectForKey:@"show"];
            [self setPlayCellValue];
            
            commentArray = (NSMutableArray *)[result objectForKey:@"comments"];
            if(commentArray == nil || commentArray.count == 0){
                commentArray = [[NSMutableArray alloc]initWithCapacity:10];
            }
//            [self initDramaCell];
            [self loadTable];
            if(pullToRefreshManager_ == nil && commentArray.count > 0){
                pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f tableView:self.tableView withClient:self];
            }
        } else {
            //            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
            //            NSString *msg = [NSString stringWithFormat:@"msg_%@", responseCode];
            //            HUD.labelText = NSLocalizedString(msg, nil);
            //            [HUD showWhileExecuting:@selector(showError) onTarget:self withObject:nil animated:YES];
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        //        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        //        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
        //        HUD.mode = MBProgressHUDModeCustomView;
        //        [self.view addSubview:HUD];
        //        HUD.labelText = NSLocalizedString(@"message.systemfailure", nil);
        //        HUD.minSize = CGSizeMake(135.f, 135.f);
        //        [HUD show:YES];
        //        [HUD hide:YES afterDelay:2];
    }];
}

- (void)setPlayCellValue
{
    NSString *name = [show objectForKey:@"name"];
    CGSize constraint = CGSizeMake(290, 20000.0f);
    CGSize size = [name sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    playCell.filmTitleLabel.text = name;
    [playCell.filmTitleLabel setNumberOfLines:0];
    [playCell.publicLabel sizeToFit];
    totalDramaCount = [[show objectForKey:@"episodes_count"] integerValue];
    if(size.height < 30){
        playCell.publicLabel.textAlignment = UITextAlignmentRight;
    } else {
        playCell.publicLabel.textAlignment = UITextAlignmentLeft;
        playCell.frame = CGRectMake(0, 0, self.view.frame.size.width, self.imageHeight + size.height + 2 * ROW_HEIGHT + 20);
        [playCell.filmTitleLabel setFrame:CGRectMake(playCell.filmTitleLabel.frame.origin.x, playCell.filmImageView.frame.origin.y + self.imageHeight + 10, size.width, size.height)];
        playCell.publicLabel.frame = CGRectMake(10, self.imageHeight + size.height + 20, 260, playCell.publicLabel.frame.size.height);
        playCell.scoreImageView.frame = CGRectMake(playCell.publicLabel.frame.origin.x, playCell.publicLabel.frame.origin.y, playCell.scoreImageView.frame.size.width, playCell.scoreImageView.frame.size.height);
        playCell.scoreLabel.frame = CGRectMake(playCell.publicLabel.frame.origin.x, playCell.publicLabel.frame.origin.y, playCell.scoreLabel.frame.size.width, playCell.scoreLabel.frame.size.height);
        playCell.introuctionBtn.frame = CGRectMake(playCell.introuctionBtn.frame.origin.x, playCell.scoreImageView.frame.origin.y, playCell.introuctionBtn.frame.size.width, playCell.introuctionBtn.frame.size.height);
        
        playCell.watchedImageView.frame = CGRectMake(playCell.watchedImageView.frame.origin.x, playCell.scoreImageView.frame.origin.y + ROW_HEIGHT, playCell.watchedImageView.frame.size.width, playCell.watchedImageView.frame.size.height);
        playCell.watchedLabel.frame = CGRectMake(playCell.watchedLabel.frame.origin.x, playCell.scoreImageView.frame.origin.y + ROW_HEIGHT, playCell.watchedLabel.frame.size.width, playCell.watchedLabel.frame.size.height);
        playCell.likeImageView.frame = CGRectMake(playCell.likeImageView.frame.origin.x, playCell.scoreImageView.frame.origin.y + ROW_HEIGHT, playCell.likeImageView.frame.size.width, playCell.likeImageView.frame.size.height);
        playCell.likeLabel.frame = CGRectMake(playCell.likeLabel.frame.origin.x, playCell.scoreImageView.frame.origin.y + ROW_HEIGHT, playCell.likeLabel.frame.size.width, playCell.likeLabel.frame.size.height);
        playCell.collectionImageView.frame = CGRectMake(playCell.collectionImageView.frame.origin.x, playCell.scoreImageView.frame.origin.y + ROW_HEIGHT, playCell.collectionImageView.frame.size.width, playCell.collectionImageView.frame.size.height);
        playCell.collectionLabel.frame = CGRectMake(playCell.collectionLabel.frame.origin.x, playCell.scoreImageView.frame.origin.y + ROW_HEIGHT, playCell.collectionLabel.frame.size.width, playCell.collectionLabel.frame.size.height);
        
    }
    
    [playCell.filmImageView setImageWithURL:[NSURL URLWithString:[show objectForKey:@"poster"]] placeholderImage:nil];
    playCell.scoreLabel.text = @"未知";
    playCell.watchedLabel.text = [show objectForKey:@"watch_num"];
    playCell.collectionLabel.text = [show objectForKey:@"favority_num"];
    playCell.likeLabel.text = [show objectForKey:@"like_num"];
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

- (void)dramaPlay:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    [self gotoWebsite:btn.tag];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadTable {
    
    [self.tableView reloadData];
    
    [pullToRefreshManager_ tableViewReloadFinished];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return 1;
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
    } else {
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

- (CommentCell *)displayCommentCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath commentArray:(NSArray *)dataArray cellIdentifier:(NSString *)cellIdentifier
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
    cell.titleLabel.text = [commentDic objectForKey:@"owner_name"];
    
    CGSize size = CGSizeZero;
    CGSize constraint = CGSizeMake(cell.titleLabel.frame.size.width, 20000.0f);
    if([StringUtility stringIsEmpty:[commentDic objectForKey:@"content"]]){
        cell.subtitleLabel.text = @"";
    } else {
        cell.subtitleLabel.text = [commentDic objectForKey:@"content"];
        size = [[commentDic objectForKey:@"content"] sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    }
    [cell.subtitleLabel setNumberOfLines:0];
    [cell.subtitleLabel setFrame:CGRectMake(cell.subtitleLabel.frame.origin.x, cell.subtitleLabel.frame.origin.y, size.width, size.height)];
    
    NSInteger yPosition = cell.subtitleLabel.frame.origin.y + size.height + 10;
    cell.thirdTitleLabel.frame = CGRectMake(cell.thirdTitleLabel.frame.origin.x, yPosition, cell.thirdTitleLabel.frame.size.width, cell.thirdTitleLabel.frame.size.height);
    
    TTTTimeIntervalFormatter *timeFormatter = [[TTTTimeIntervalFormatter alloc]init];
    NSString *timeDiff = [timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:(NSDate *)[commentDic valueForKey:@"date"]];
    cell.thirdTitleLabel.text = timeDiff;
    
    NSNumber *num = (NSNumber *)[[ContainerUtility sharedInstance]attributeForKey:kUserLoggedIn];
    if([num boolValue]){
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
    } else{
        [cell.replyBtn setHidden:YES];
    }
    [cell.avatarBtn addTarget:self action:@selector(avatarClicked:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return playCell.frame.size.height;
    } else {
        if(commentArray == nil || commentArray.count == 0){
            return 44;
        } else {
            CGFloat height = [self caculateCommentCellHeight:indexPath.row dataArray:commentArray];
            return height;
        }
    }
}

- (CGFloat)caculateCommentCellHeight:(NSInteger)row dataArray:(NSArray *)dataArray
{
    NSMutableDictionary *commentDic = [dataArray objectAtIndex:row];
    NSString *content = [commentDic objectForKey:@"content"];
    if([StringUtility stringIsEmpty:content]){
        return 80;
    }
    CGSize constraint = CGSizeMake(230, 20000.0f);
    CGSize size = [content sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    return 80 + size.height;
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
    if(indexPath.section > 1){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        CommentListViewController *viewController = [[CommentListViewController alloc]initWithNibName:@"CommentListViewController" bundle:nil];
        viewController.title = @"评论回复";
        [self.navigationController pushViewController:viewController animated:YES];
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
    headerLabel.text =  NSLocalizedString(@"user_comment", nil);
    headerLabel.textColor = [UIColor whiteColor];
    [customView addSubview:headerLabel];
    
    return customView;
}

- (void)showIntroduction{
    IntroductionView *lplv = [[IntroductionView alloc] initWithTitle:[show objectForKey:@"name"] content:[show objectForKey:@"summary"]];
    lplv.frame = CGRectMake(0, 0, lplv.frame.size.width, lplv.frame.size.height * 0.8);
    lplv.center = CGPointMake(160, 210 + self.tableView.contentOffset.y);
    lplv.delegate = self;
    [lplv showInView:self.view animated:YES];
    self.tableView.scrollEnabled = NO;
}

- (void)leveyPopListViewDidCancel
{
    self.tableView.scrollEnabled = YES;
}

- (void)avatarClicked:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    CGPoint point = btn.center;
    point = [self.tableView convertPoint:point fromView:btn.superview];
    NSIndexPath* indexpath = [self.tableView indexPathForRowAtPoint:point];
    
    HomeViewController *viewController = [[HomeViewController alloc]initWithNibName:@"HomeViewController" bundle:nil];
    viewController.userid = [[commentArray objectAtIndex:indexpath.row] valueForKey:@"owner_id"];
    [self.navigationController pushViewController:viewController animated:YES];
}


- (void)replyBtnClicked:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    CGPoint point = btn.center;
    point = [self.tableView convertPoint:point fromView:btn.superview];
    NSIndexPath* indexpath = [self.tableView indexPathForRowAtPoint:point];
    
    CommentViewController *viewController = [[CommentViewController alloc]initWithNibName:@"CommentViewController" bundle:nil];
    viewController.threadId = [[commentArray objectAtIndex:indexpath.row] valueForKey:@"id"];
    viewController.title = @"评论回复";
    viewController.openKeyBoard = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}


- (void)playVideo
{
    [self gotoWebsite:1];
}

- (void)gotoWebsite:(NSInteger)num
{
    ProgramViewController *viewController = [[ProgramViewController alloc]initWithNibName:@"ProgramViewController" bundle:nil];
    NSArray *episodeArray = [show objectForKey:@"episodes"];
    NSString *url = nil;
    for(NSDictionary *episode in episodeArray){
        if([[episode objectForKey:@"name"]integerValue] == num){
            NSArray *urlArray = [episode objectForKey:@"video_urls"];
            url = [[urlArray objectAtIndex:0] objectForKey:@"url"];
            break;
        }
    }
    if(url == nil){
        url = [[[[episodeArray objectAtIndex:0] objectForKey:@"video_urls"] objectAtIndex:0] objectForKey:@"url"];
    } 
    viewController.programUrl = url;
    viewController.title = [show objectForKey:@"name"];
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
    reloads_++;
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:kAppKey, @"app_key", self.programId, @"prod_id", [NSNumber numberWithInt:reloads_ + 1 ], @"page_num",[NSNumber numberWithInt:10], @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathProgramComments parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *comArray = (NSMutableArray *)[result objectForKey:@"comments"];
            if(comArray != nil && comArray.count > 0){
                [commentArray addObjectsFromArray:comArray];
            }
            [self performSelector:@selector(loadTable) withObject:nil afterDelay:2.0f];
        } else {
            //            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
            //            NSString *msg = [NSString stringWithFormat:@"msg_%@", responseCode];
            //            HUD.labelText = NSLocalizedString(msg, nil);
            //            [HUD showWhileExecuting:@selector(showError) onTarget:self withObject:nil animated:YES];
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	[self getProgramView];
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
