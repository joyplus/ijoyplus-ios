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
#import "CustomBackButtonHolder.h"
#import "CustomBackButton.h"
#import "TTTTimeIntervalFormatter.h"
#import "UIImageView+WebCache.h"
#import "CMConstants.h"
#import "MessageCell.h"

@interface MessageListViewController (){
    NSMutableArray *commentArray;
}

@end

@implementation MessageListViewController

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
    CustomBackButtonHolder *backButtonHolder = [[CustomBackButtonHolder alloc]initWithViewController:self];
    CustomBackButton* backButton = [backButtonHolder getBackButton:NSLocalizedString(@"go_back", nil)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];

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
    [commentArray addObject:commentDic];}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    MessageCell *cell = (MessageCell*) [tableView dequeueReusableCellWithIdentifier:@"messageCell"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ListCellFactory" owner:self options:nil];
        cell = (MessageCell *)[nib objectAtIndex:0];
    }
    NSMutableDictionary *commentDic = [commentArray objectAtIndex:indexPath.row];
    [cell.avatarImageView setImageWithURL:[NSURL URLWithString:[commentDic valueForKey:@"avatarUrl"]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    cell.avatarImageView.layer.cornerRadius = 25;
    cell.avatarImageView.layer.masksToBounds = YES;
    cell.titleLabel.text = [commentDic objectForKey:@"username"];
    [cell.titleLabel sizeToFit];
    cell.actionTitleLabel.text = @"回复了";
    [cell.actionTitleLabel sizeToFit];
    cell.actionTitleLabel.frame = CGRectMake(cell.titleLabel.frame.origin.x + cell.titleLabel.frame.size.width + 5, cell.titleLabel.frame.origin.y, cell.actionTitleLabel.frame.size.width, cell.actionTitleLabel.frame.size.height);
    NSMutableString *actionDetailString = [[NSMutableString alloc]initWithCapacity:20];
    for (int i = 0; i < cell.titleLabel.text.length + cell.actionTitleLabel.text.length; i++) {
        [actionDetailString appendString:@"   "];
    }
    [actionDetailString appendString:@"您在《萤火之森》中的评论。"];
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

    NSInteger yPosition = cell.subtitleLabel.frame.origin.y + size.height + 10;
    cell.myCommentViewContent.text = @"是夏日，葱绿的森林，四散的流光都会染上的透亮绿意。你戴着奇怪的面具，明明看不到眉目，却一眼就觉得是个可爱的人。是夏日，葱绿的森林，四散的流光都会染上的透亮绿意。你戴着奇怪的面具，明明看不到眉目，却一眼就觉得是个可爱的人。";
    TTTTimeIntervalFormatter *timeFormatter = [[TTTTimeIntervalFormatter alloc]init];
    NSString *timeDiff;
    if(cell.myCommentViewContent.text != nil){
        cell.myCommentViewName.text = @"Joy+";
        [cell.myCommentViewContent setNumberOfLines:0];
        constraint = CGSizeMake(cell.myCommentViewContent.frame.size.width, 20000.0f);
        size = [cell.myCommentViewContent.text sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        [cell.myCommentViewContent setFrame:CGRectMake(cell.myCommentViewContent.frame.origin.x, cell.myCommentViewContent.frame.origin.y, size.width, size.height)];
        cell.myCommentViewTime.frame = CGRectMake(cell.myCommentViewTime.frame.origin.x, size.height - 10, cell.myCommentViewContent.frame.size.width, cell.myCommentViewContent.frame.size.height);
        timeDiff = [timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:(NSDate *)[commentDic valueForKey:@"date"]];
        cell.myCommentViewTime.text = timeDiff;
        cell.myCommentView.frame = CGRectMake(cell.myCommentView.frame.origin.x, yPosition, cell.myCommentView.frame.size.width, size.height + 50);
//        cell.myCommentView.backgroundColor = [UIColor clearColor];
    } else{
        cell.myCommentView.frame = CGRectZero;
        cell.myCommentViewName = nil;
        cell.myCommentViewContent = nil;
        cell.myCommentViewTime = nil;
    }
    
    yPosition = cell.subtitleLabel.frame.origin.y + cell.subtitleLabel.frame.size.height + cell.myCommentView.frame.size.height + 20;
    cell.thirdTitleLabel.frame = CGRectMake(cell.thirdTitleLabel.frame.origin.x, yPosition, cell.thirdTitleLabel.frame.size.width, cell.thirdTitleLabel.frame.size.height);
    timeDiff = [timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:(NSDate *)[commentDic valueForKey:@"date"]];
    cell.thirdTitleLabel.text = timeDiff;
    
    [cell.avatarBtn addTarget:self action:@selector(avatarClicked) forControlEvents:UIControlEventTouchUpInside];
    
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
    NSString *myCommentString = @"是夏日，葱绿的森林，四散的流光都会染上的透亮绿意。你戴着奇怪的面具，明明看不到眉目，却一眼就觉得是个可爱的人。是夏日，葱绿的森林，四散的流光都会染上的透亮绿意。你戴着奇怪的面具，明明看不到眉目，却一眼就觉得是个可爱的人。";
    CGSize constraint;
    CGSize size1;
    if(myCommentString != nil) {
        constraint = CGSizeMake(230, 20000.0f);
        size1 = [myCommentString sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    } else {
        size1 = CGSizeZero;
    }
    
    NSMutableDictionary *commentDic = [commentArray objectAtIndex:indexPath.row];
    NSString *content = [commentDic objectForKey:@"content"];
    constraint = CGSizeMake(230, 20000.0f);
    CGSize size2 = [content sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    if(myCommentString == nil){
        return size2.height + 110;
    } else {
        return size1.height + size2.height + 160;
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

@end
