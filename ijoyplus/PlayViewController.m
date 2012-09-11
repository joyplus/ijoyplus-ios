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

@interface PlayViewController (){
    NSMutableArray *commentArray;
}
@property (strong, nonatomic) IBOutlet PlayCell *playCell;
- (void)loadTable;
- (void)closeSelf;
@end

@implementation PlayViewController
@synthesize playCell;

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
    self.title = NSLocalizedString(@"app_name", nil);
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"go_back", nil) style:UIBarButtonSystemItemSearch target:self action:@selector(closeSelf)];
    self.navigationItem.leftBarButtonItem = leftButton;
}

- (void)closeSelf
{
    UIViewController *viewController = [self.navigationController popViewControllerAnimated:YES];
    if(viewController == nil){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)viewDidUnload
{
    [self setPlayCell:nil];
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
    NSArray *keys = [[NSArray alloc]initWithObjects:@"avatarUrl", @"username", @"content", nil];
    NSArray *values = [[NSArray alloc]initWithObjects:@"http://img5.douban.com/view/photo/thumb/public/p1686249659.jpg", @"Joy+", @"是夏日，葱绿的森林，四散的流光都会染上的透亮绿意。你戴着奇怪的面具，明明看不到眉目，却一眼就觉得是个可爱的人。", nil];
    NSMutableDictionary *commentDic = [[NSMutableDictionary alloc]initWithObjects:values forKeys:keys];
    
    [commentArray addObject:commentDic];
    [commentArray addObject:commentDic];
    [commentArray addObject:commentDic];
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
    switch (section) {
        case 0:
            return 1;
        default:
            return commentArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        return self.playCell;
    } else{
        CommentCell *cell = (CommentCell*) [tableView dequeueReusableCellWithIdentifier:@"commentCell"];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PopularCellFactory" owner:self options:nil];
            cell = (CommentCell *)[nib objectAtIndex:2];
        }
        NSMutableDictionary *commentDic = [commentArray objectAtIndex:indexPath.row];
        [cell.avatarImageView setImageWithURL:[NSURL URLWithString:[commentDic valueForKey:@"avatarUrl"]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        cell.titleLabel.text = [commentDic objectForKey:@"username"];
        cell.subtitleLabel.text = [commentDic objectForKey:@"content"];
        cell.thirdTitleLabel.text = @"10:30";
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
        CGSize labelSize = [content sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:CGSizeMake(280, 100) lineBreakMode:UILineBreakModeCharacterWrap];
        return 68 + labelSize.height + 68;
//        UILabel* label = [[UILabel alloc] init];
//        label.frame = CGRectMake(68, 39, labelSize.width, labelSize.height);
//        label.backgroundColor = [UIColor whiteColor];
//        label.text = content;
//        label.font = [UIFont systemFontOfSize:15.0f];
//        label.numberOfLines = 0;
//        label.lineBreakMode = UILineBreakModeCharacterWrap;
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    } else {
        return 24;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
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
    
    // create the imageView with the image in it
    // create image object
    //    UIImage *myImage = [UIImage imageNamed:@"someimage.png"];
    //    UIImageView *imageView = [[UIImageView alloc] initWithImage:myImage];
    //    imageView.frame = CGRectMake(10,10,50,50);
    //
    //    [customView addSubview:imageView];
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
    NSArray *keys = [[NSArray alloc]initWithObjects:@"avatarUrl", @"username", @"content", nil];
    NSArray *values = [[NSArray alloc]initWithObjects:@"http://img5.douban.com/view/photo/thumb/public/p1686249659.jpg", @"Joy+", @"是夏日，葱绿的森林，四散的流光都会染上的透亮绿意。你戴着奇怪的面具，明明看不到眉目，却一眼就觉得是个可爱的人。", nil];
    NSMutableDictionary *commentDic = [[NSMutableDictionary alloc]initWithObjects:values forKeys:keys];
    
    [commentArray addObject:commentDic];
    [commentArray addObject:commentDic];
    [commentArray addObject:commentDic];
    [commentArray addObject:commentDic];
    [commentArray addObject:commentDic];
    [self performSelector:@selector(loadTable) withObject:nil afterDelay:2.0f];
}

@end
