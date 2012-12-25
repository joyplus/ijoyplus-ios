//
//  ShowListViewController.m
//  yueshipin_ipad
//
//  Created by zhang zhipeng on 12-11-25.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "CommentListViewController.h"
#import "CommonHeader.h"
#import "CommentCell.h"

@interface CommentListViewController (){

}

@end

@implementation CommentListViewController
@synthesize listData;
@synthesize parentDelegate;
@synthesize prodId;
@synthesize tableHeight;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    listData  = nil;
    prodId = nil;
    [super viewDidUnload];
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
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view setBackgroundColor:[UIColor clearColor]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(listData.count == self.totalCommentNum){
        return listData.count;
    } else {
        return listData.count + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(listData.count == 0){
        return [self getNoCommentCell:tableView cellForRowAtIndexPath:indexPath];
    } else if(listData.count == self.totalCommentNum){
        return [self getCommentCell:tableView cellForRowAtIndexPath:indexPath];
    } else {
        if(indexPath.row == listData.count){//at last line, add LoadMore cell
            return [self getLoadMoreCell:tableView cellForRowAtIndexPath:indexPath];
        } else {
            return [self getCommentCell:tableView cellForRowAtIndexPath:indexPath];
        }
    }
}

- (UITableViewCell *)getNoCommentCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"noComment";
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.textLabel.text = @"no comment";
    return cell;
}

- (UITableViewCell *)getLoadMoreCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"loadMoreComment";
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    UIButton *showMoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    showMoreBtn.frame = CGRectMake(0, 0, 440, 33);
    [showMoreBtn setBackgroundImage:[UIImage imageNamed:@"morecomments"] forState:UIControlStateNormal];
    [showMoreBtn setBackgroundImage:[UIImage imageNamed:@"morecomments_pressed"] forState:UIControlStateHighlighted];
    [showMoreBtn addTarget:self action:@selector(showMoreBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.contentView addSubview:showMoreBtn];
    return cell;
}

- (void)showMoreBtnClicked
{
    [self retrieveComment];
}


- (UITableViewCell *)getCommentCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[CommentCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 10, cell.bounds.size.width, 15)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.tag = 1001;
        nameLabel.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:nameLabel];
        
        UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(cell.bounds.size.width - 15, 11, 120, 15)];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textAlignment = NSTextAlignmentRight;
        timeLabel.textColor = CMConstants.grayColor;
        timeLabel.tag = 1002;
        timeLabel.font = [UIFont systemFontOfSize:14];
        [cell.contentView addSubview:timeLabel];
        
        UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 35, cell.bounds.size.width, 15)];
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.textColor = CMConstants.grayColor;
        contentLabel.tag = 1003;
        contentLabel.font = [UIFont systemFontOfSize:15];
        [contentLabel setNumberOfLines:0];
        [cell.contentView addSubview:contentLabel];
    }
    NSDictionary *item =  [listData objectAtIndex:indexPath.row];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:1001];
    NSString *name = [item objectForKey:@"owner_name"];
    if([StringUtility stringIsEmpty:name]){
        name = @"网友评论";
    }
    nameLabel.text = [NSString stringWithFormat:@"%@", name];
    
    UILabel *timeLabel = (UILabel *)[cell viewWithTag:1002];
    NSString *createDate = [item valueForKey:@"create_date"];
    if(createDate.length > 10){
        timeLabel.text = [createDate substringToIndex:10];
    } else {
        timeLabel.text = createDate;
    }
    
    NSString *content = [item objectForKey:@"content"];
    UILabel *contentLabel = (UILabel *)[cell viewWithTag:1003];
    contentLabel.text = content;
    CGSize size = [self calculateContentSize:content width:420];
    [contentLabel setFrame:CGRectMake(contentLabel.frame.origin.x, contentLabel.frame.origin.y, 420, size.height)];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        tableHeight = 0;
    }
    if(indexPath.row == listData.count){//loadmore cell
        tableHeight += 40;
        return 40;
    }
    NSDictionary *item =  [listData objectAtIndex:indexPath.row];
    NSString *content = [item objectForKey:@"content"];
    CGSize size = [self calculateContentSize:content width:420];
    tableHeight += size.height + 40;
    return size.height + 40;
}

- (CGSize)calculateContentSize:(NSString *)content width:(int)width
{
    CGSize constraint = CGSizeMake(width, 20000.0f);
    CGSize size = [content sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    return size;
}


- (void)retrieveComment
{
    int pageNum = ceil(listData.count / 10.0)+1;
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: self.prodId, @"prod_id",[NSNumber numberWithInt:pageNum], @"page_num", [NSNumber numberWithInt:10], @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathProgramComments parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *comments = (NSArray *)[result objectForKey:@"comments"];
            if(comments != nil && comments.count > 0){
                [self.listData addObjectsFromArray:comments];
                tableHeight = 0;
                [self.tableView reloadData];
                [parentDelegate refreshCommentListView:tableHeight];
            }
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        [[AppDelegate instance].rootViewController showFailureModalView:1.5];
    }];
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

@end
