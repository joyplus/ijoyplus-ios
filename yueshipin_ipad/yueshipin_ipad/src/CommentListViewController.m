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
#import "CommentWebViewController.h"

@interface CommentListViewController ()

@property (nonatomic, strong) NSMutableArray *commentArray;

@end

@implementation CommentListViewController
@synthesize commentArray;
@synthesize prodId;
@synthesize tableHeight;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [commentArray removeAllObjects];
    commentArray  = nil;
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
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    commentArray = [[NSMutableArray alloc]initWithCapacity:3];
    [self retrieveData];
}

- (void)retrieveData
{
    BOOL isReachable = [[AppDelegate instance] performSelector:@selector(isParseReachable)];
    if(!isReachable) {
        [UIUtility showNetWorkError:self.view];
    }
    NSString *key = [NSString stringWithFormat:@"%@%@", @"movie_comment", self.prodId];
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:key];
    if(cacheResult != nil){
        [self parseData:cacheResult];
    } 
    if([[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        NSDictionary * reqData = [NSDictionary dictionaryWithObjectsAndKeys:self.prodId, @"prod_id", @"1", @"page_num", @"4" ,@"page_size", nil];
        [[AFServiceAPIClient sharedClient] getPath:kPathProgramReviews parameters:reqData success:^(AFHTTPRequestOperation *operation, id result) {
            NSArray *tempArray = [result objectForKey:@"reviews"];
            if (tempArray.count > 0) {
                [commentArray addObjectsFromArray:tempArray];
                [commentArray addObjectsFromArray:tempArray];
            }
            [self.tableView reloadData];
            [self.parentDelegate refreshCommentListView:tableHeight];
         } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
         }];

    } 
}

- (void)parseData:(id)result
{
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        NSString *key = [NSString stringWithFormat:@"%@%@", @"movie_comment", self.prodId];
        [[CacheUtility sharedCache] putInCache:key result:result];
        
        
    } 
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (commentArray.count > 3) {
        return 4;
    } else {
        return commentArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"commentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellEditingStyleNone];
        UIImageView *bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 160)];
        bgImageView.tag = 6503;
        [cell.contentView addSubview:bgImageView];
        
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 100, 30)];
        nameLabel.tag = 6501;
        nameLabel.font = [UIFont systemFontOfSize:15];
        [nameLabel setBackgroundColor:[UIColor yellowColor]];
        nameLabel.textColor = CMConstants.grayColor;
        [cell.contentView addSubview:nameLabel];
        
        UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 30, bgImageView.frame.size.width - 10, 120)];
        contentLabel.tag = 6502;
        contentLabel.font = [UIFont systemFontOfSize:13];
        contentLabel.textColor = CMConstants.grayColor;
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.numberOfLines = 0;
        contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [cell.contentView addSubview:contentLabel];
        
        UILabel *allLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        allLabel.font = [UIFont systemFontOfSize:12];
        allLabel.backgroundColor = [UIColor clearColor];
        allLabel.textColor = CMConstants.yellowColor;
        allLabel.tag = 6504;
        [cell.contentView addSubview:allLabel];
    }
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:6501];
    UITextView *contentLabel = (UITextView *)[cell.contentView viewWithTag:6502];
    UIImageView *bgImageView = (UIImageView *)[cell.contentView viewWithTag:6503];
    UILabel *allLabel = (UILabel *)[cell.contentView viewWithTag:6504];
    if (indexPath.row < fmin(commentArray.count, 3)) {
        NSDictionary *item = [commentArray objectAtIndex:indexPath.row];
        nameLabel.text = [item objectForKey:@"title"];
        contentLabel.text = [item objectForKey:@"comments"];
        bgImageView.image = [UIImage imageNamed:@"comment_bg"];
        allLabel.frame = CGRectMake(tableView.frame.size.width-40, 140, 100, 30);
        allLabel.text = @"全部 》";
    } else if (indexPath.row == 3){
        nameLabel.text = @"";
        contentLabel.text = @"";
        bgImageView.image = nil;
        allLabel.frame = CGRectMake(tableView.frame.size.width-60, 5, 100, 30);
        allLabel.text = @"更多影评 》";
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        tableHeight = 0;
    }
    if(indexPath.row < 3){//loadmore cell
        tableHeight += 170;
        return 170;
    } else {
        tableHeight += 30;
        return 30;
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
    if (indexPath.row < fmin(commentArray.count, 3)) {
        
    } else if (indexPath.row == 3){
        NSDictionary *item = [commentArray objectAtIndex:indexPath.row];
        CommentWebViewController *viewController = [[CommentWebViewController alloc]init];
        viewController.commentUrl = [item objectForKey:@""];
        viewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        [[AppDelegate instance].rootViewController pesentMyModalView:[[UINavigationController alloc]initWithRootViewController:viewController]];
    }
}

@end
