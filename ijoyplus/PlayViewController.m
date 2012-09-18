//
//  PlayViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-11.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "PlayViewController.h"
#import "PlayCell.h"
#import "CommentCell.h"
#import "UIImageView+WebCache.h"
#import "CMConstants.h"
#import "IntroductionView.h"
#import "FriendProfileViewController.h"
#import "DateUtility.h"
#import "TTTTimeIntervalFormatter.h"

#define ANIMATION_DURATION 0.4
#define ANIMATION_DELAY 0

@interface PlayViewController (){
    NSMutableArray *commentArray;
    UIViewController *subviewController;//视图
}
- (void)avatarClicked;
- (void)loadTable;
- (void)showIntroduction;
@end

@implementation PlayViewController

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

- (void)viewDidUnload
{
    [super viewDidUnload];
    pullToRefreshManager_ = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    commentArray = [[NSMutableArray alloc]initWithCapacity:10];
    NSArray *keys = [[NSArray alloc]initWithObjects:@"avatarUrl", @"username", @"content", @"date", nil];
    NSArray *values = [[NSArray alloc]initWithObjects:@"http://img5.douban.com/view/photo/thumb/public/p1686249659.jpg", @"Joy+", @"是夏日，葱绿的森林，四散的流光都会染上的透亮绿意。你戴着奇怪的面具，明明看不到眉目，却一眼就觉得是个可爱的人。", [NSDate date], nil];
    NSMutableDictionary *commentDic = [[NSMutableDictionary alloc]initWithObjects:values forKeys:keys];
    
    NSArray *keys1 = [[NSArray alloc]initWithObjects:@"avatarUrl", @"username", @"content", @"date", nil];
    NSArray *values1 = [[NSArray alloc]initWithObjects:@"http://img5.douban.com/view/photo/thumb/public/p1686249659.jpg", @"Joy+", @"是夏日，葱绿的森林，四散的流光都会染上的透亮绿意。你戴着奇怪的面具，明明看不到眉目，却一眼就觉得是个可爱的人。是夏日，葱绿的森林，四散的流光都会染上的透亮绿意。你戴着奇怪的面具，明明看不到眉目，却一眼就觉得是个可爱的人。", [DateUtility addMinutes:[NSDate date] minutes:10], nil];
    NSMutableDictionary *commentDic1 = [[NSMutableDictionary alloc]initWithObjects:values1 forKeys:keys1];
    
    NSArray *keys2 = [[NSArray alloc]initWithObjects:@"avatarUrl", @"username", @"content", @"date", nil];
    NSArray *values2 = [[NSArray alloc]initWithObjects:@"http://img5.douban.com/view/photo/thumb/public/p1686249659.jpg", @"Joy+", @"顶。", [DateUtility dateWithDaysFromGivenDate:10 givenDate:[NSDate date]], nil];
    NSMutableDictionary *commentDic2 = [[NSMutableDictionary alloc]initWithObjects:values2 forKeys:keys2];
    
    [commentArray addObject:commentDic];
    [commentArray addObject:commentDic1];
    [commentArray addObject:commentDic2];
    [commentArray addObject:commentDic];
    [commentArray addObject:commentDic];
    
    pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f tableView:self.tableView withClient:self];
    
    [self loadTable];
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
        return commentArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==0) {
        PlayCell *playCell = (PlayCell*) [tableView dequeueReusableCellWithIdentifier:@"playCell"];
        if (playCell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PopularCellFactory" owner:self options:nil];
            playCell = (PlayCell *)[nib objectAtIndex:3];
        }
        [playCell.introuctionBtn setActionSheetButtonWithColor: CMConstants.greyColor];
        playCell.introuctionBtn.buttonBorderWidth = 0;
        [playCell.introuctionBtn setTitle: NSLocalizedString(@"introduction", nil) forState:UIControlStateNormal];
        [playCell.introuctionBtn addTarget:self action:@selector(showIntroduction) forControlEvents:UIControlEventTouchUpInside];
        return playCell;
    } else {
        CommentCell *cell = (CommentCell*) [tableView dequeueReusableCellWithIdentifier:@"commentCell"];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PopularCellFactory" owner:self options:nil];
            cell = (CommentCell *)[nib objectAtIndex:2];
        }
        NSMutableDictionary *commentDic = [commentArray objectAtIndex:indexPath.row];
        [cell.avatarImageView setImageWithURL:[NSURL URLWithString:[commentDic valueForKey:@"avatarUrl"]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        cell.avatarImageView.layer.cornerRadius = 25;
        cell.avatarImageView.layer.masksToBounds = YES;
        cell.avatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        cell.avatarImageView.layer.borderWidth = 3;
        cell.titleLabel.text = [commentDic objectForKey:@"username"];
        
        cell.subtitleLabel.text = [commentDic objectForKey:@"content"];
        [cell.subtitleLabel setNumberOfLines:0];
        CGSize constraint = CGSizeMake(cell.titleLabel.frame.size.width, 20000.0f);
        CGSize size = [[commentDic objectForKey:@"content"] sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        [cell.subtitleLabel setFrame:CGRectMake(cell.subtitleLabel.frame.origin.x, cell.subtitleLabel.frame.origin.y, size.width, size.height)];
        
        NSInteger yPosition = cell.subtitleLabel.frame.origin.y + size.height + 10;
        cell.thirdTitleLabel.frame = CGRectMake(cell.thirdTitleLabel.frame.origin.x, yPosition, cell.thirdTitleLabel.frame.size.width, cell.thirdTitleLabel.frame.size.height);
        
        TTTTimeIntervalFormatter *timeFormatter = [[TTTTimeIntervalFormatter alloc]init];
        NSString *timeDiff = [timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:(NSDate *)[commentDic valueForKey:@"date"]];
        cell.thirdTitleLabel.text = timeDiff;
        
        [cell.avatarBtn addTarget:self action:@selector(avatarClicked) forControlEvents:UIControlEventTouchUpInside];
        return cell;

    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 300;
    } else {
        NSMutableDictionary *commentDic = [commentArray objectAtIndex:indexPath.row];
        NSString *content = [commentDic objectForKey:@"content"];
        CGSize constraint = CGSizeMake(232, 20000.0f);
        CGSize size = [content sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        return 80 + size.height;
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
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10,0,self.view.bounds.size.width,24)];
    customView.backgroundColor = [UIColor blackColor];
    
    //    // create the label objects
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:12];
    headerLabel.text =  NSLocalizedString(@"user_comment", nil);
    headerLabel.textColor = [UIColor whiteColor];
    [headerLabel sizeToFit];
    headerLabel.center = CGPointMake(headerLabel.frame.size.width/2, customView.frame.size.height/2);
    [customView addSubview:headerLabel];
    
    return customView;
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
    [pullToRefreshManager_ tableViewReleased];
}

/**
 * Tells client that can reload table.
 * After reloading is completed must call [pullToRefreshMediator_ tableViewReloadFinished]
 */
- (void)MNMBottomPullToRefreshManagerClientReloadTable {
    reloads_++;
    NSArray *keys = [[NSArray alloc]initWithObjects:@"avatarUrl", @"username", @"content", @"date", nil];
    NSArray *values = [[NSArray alloc]initWithObjects:@"http://img5.douban.com/view/photo/thumb/public/p1686249659.jpg", @"Joy+", @"是夏日，葱绿的森林，四散的流光都会染上的透亮绿意。你戴着奇怪的面具，明明看不到眉目，却一眼就觉得是个可爱的人。", [DateUtility dateWithDaysFromNow:10], nil];
    NSMutableDictionary *commentDic = [[NSMutableDictionary alloc]initWithObjects:values forKeys:keys];
    
    [commentArray addObject:commentDic];
    [commentArray addObject:commentDic];
    [commentArray addObject:commentDic];
    [commentArray addObject:commentDic];
    [commentArray addObject:commentDic];
    [self performSelector:@selector(loadTable) withObject:nil afterDelay:2.0f];
}

- (void)showIntroduction{
    IntroductionView *lplv = [[IntroductionView alloc] initWithTitle:@"电影名称"];
    lplv.frame = CGRectMake(0, 0, lplv.frame.size.width, lplv.frame.size.height * 0.9);
    lplv.center = CGPointMake(160, 210);
    lplv.delegate = self;
    [lplv showInView:self.view animated:YES];
    self.tableView.scrollEnabled = NO;
}

- (void)leveyPopListViewDidCancel
{
    self.tableView.scrollEnabled = YES;
}

- (void)avatarClicked
{
    FriendProfileViewController *viewController = [[FriendProfileViewController alloc]initWithNibName:@"FriendProfileViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
