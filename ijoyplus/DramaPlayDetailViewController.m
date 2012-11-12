//
//  PlayDetailViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-10-17.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "DramaPlayDetailViewController.h"
#import "PlayCell.h"
#import "CommentCell.h"
#import "UIImageView+WebCache.h"
#import "CMConstants.h"
#import "DateUtility.h"
#import "TTTTimeIntervalFormatter.h"
#import "CommentListViewController.h"
#import "ContainerUtility.h"
#import "HomeViewController.h"
#import "CommentViewController.h"
#import "StringUtility.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "ProgramViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "NoRecordCell.h"
#import "UIUtility.h"
#import "CustomBackButton.h"
#import "MBProgressHUD.h"
#import "RecommandViewController.h"
#import "PostViewController.h"
#import "CacheUtility.h"
#import "MediaPlayerViewController.h"
#import "BlockAlertView.h"

#define ROW_HEIGHT 40

@interface DramaPlayDetailViewController (){
    NSInteger totalDramaCount;
}

@end

@implementation DramaPlayDetailViewController

- (void)viewDidUnload
{
    [super viewDidUnload];
    dramaCell = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    videoType = @"2";
    dramaCell = [[DramaCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"dramaCell"];
    dramaCell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)getProgramView
{
    commentArray = [[NSMutableArray alloc]initWithCapacity:10];
    NSString *key = [NSString stringWithFormat:@"%@%@", @"drama", self.programId];
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:key];
    if(cacheResult != nil){
        [self parseData:cacheResult];
    }
    if([[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    self.programId, @"prod_id",
                                    nil];
        
        [[AFServiceAPIClient sharedClient] getPath:kPathProgramView parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [self parseData:result];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
            [UIUtility showSystemError:self.view];
        }];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
    }
}

- (void)parseData:(id)result
{
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        NSString *key = [NSString stringWithFormat:@"%@%@", @"drama", self.programId];
        [[CacheUtility sharedCache] putInCache:key result:result];
        video = (NSDictionary *)[result objectForKey:@"tv"];
        episodeArray = [video objectForKey:@"episodes"];
        [self setPlayCellValue];
        NSArray *tempArray = (NSMutableArray *)[result objectForKey:@"comments"];
        [commentArray removeAllObjects];
        if(tempArray != nil && tempArray.count > 0){
            [commentArray addObjectsFromArray:tempArray];
        }
        [self initDramaCell];
        if(pullToRefreshManager_ == nil && commentArray.count > 0){
            pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:480.0f tableView:_tableView withClient:self];
        }
        [self loadTable];
    } else {
        [UIUtility showSystemError:self.view];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
}

- (void)setPlayCellValue
{
    name = [video objectForKey:@"name"];
    CGSize constraint = CGSizeMake(300, 20000.0f);
    CGSize size = [name sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    playCell.filmTitleLabel.text = name;
    [playCell.filmTitleLabel setNumberOfLines:0];
    [playCell.publicLabel sizeToFit];
    totalDramaCount = [[video objectForKey:@"episodes_count"] integerValue];
    if(size.height < 30){
        playCell.publicLabel.textAlignment = UITextAlignmentRight;
        playCell.introuctionBtn.frame = CGRectMake(260, playCell.scoreImageView.frame.origin.y, 47, 30);
    } else {
        playCell.publicLabel.textAlignment = UITextAlignmentLeft;
        playCell.frame = CGRectMake(0, 0, self.view.frame.size.width, size.height + 3 * ROW_HEIGHT + 20);
        [playCell.filmTitleLabel setFrame:CGRectMake(playCell.filmTitleLabel.frame.origin.x, playCell.filmImageView.frame.origin.y + 10, size.width, size.height)];
        playCell.publicLabel.frame = CGRectMake(10, size.height + 20, 260, playCell.publicLabel.frame.size.height);
        playCell.scoreImageView.frame = CGRectMake(playCell.publicLabel.frame.origin.x, playCell.publicLabel.frame.origin.y + ROW_HEIGHT - 10, playCell.scoreImageView.frame.size.width, playCell.scoreImageView.frame.size.height);
        playCell.scoreLabel.frame = CGRectMake(playCell.publicLabel.frame.origin.x, playCell.publicLabel.frame.origin.y + ROW_HEIGHT - 10, playCell.scoreLabel.frame.size.width, playCell.scoreLabel.frame.size.height);
        playCell.introuctionBtn.frame = CGRectMake(260, playCell.scoreImageView.frame.origin.y, 47, 30);
        
        playCell.watchedImageView.frame = CGRectMake(playCell.watchedImageView.frame.origin.x, playCell.scoreImageView.frame.origin.y + ROW_HEIGHT, playCell.watchedImageView.frame.size.width, playCell.watchedImageView.frame.size.height);
        playCell.watchedLabel.frame = CGRectMake(playCell.watchedLabel.frame.origin.x, playCell.scoreImageView.frame.origin.y + ROW_HEIGHT, playCell.watchedLabel.frame.size.width, playCell.watchedLabel.frame.size.height);
        playCell.likeImageView.frame = CGRectMake(playCell.likeImageView.frame.origin.x, playCell.scoreImageView.frame.origin.y + ROW_HEIGHT, playCell.likeImageView.frame.size.width, playCell.likeImageView.frame.size.height);
        playCell.likeLabel.frame = CGRectMake(playCell.likeLabel.frame.origin.x, playCell.scoreImageView.frame.origin.y + ROW_HEIGHT, playCell.likeLabel.frame.size.width, playCell.likeLabel.frame.size.height);
        playCell.collectionImageView.frame = CGRectMake(playCell.collectionImageView.frame.origin.x, playCell.scoreImageView.frame.origin.y + ROW_HEIGHT, playCell.collectionImageView.frame.size.width, playCell.collectionImageView.frame.size.height);
        playCell.collectionLabel.frame = CGRectMake(playCell.collectionLabel.frame.origin.x, playCell.scoreImageView.frame.origin.y + ROW_HEIGHT, playCell.collectionLabel.frame.size.width, playCell.collectionLabel.frame.size.height);
        
    }
    
    [_imageView setImageWithURL:[NSURL URLWithString:[video objectForKey:@"poster"]] placeholderImage:[UIImage imageNamed:@"u0_normal"]];
    NSString *score = [video objectForKey:@"score"];
    if(![StringUtility stringIsEmpty:score] && ![score isEqualToString:@"0"]){
        playCell.scoreLabel.text = score;
    } else {
        playCell.scoreLabel.text = @"未评分";
    }
    playCell.watchedLabel.text = [NSString stringWithFormat:@"%@", [video objectForKey:@"watch_num"]];
    playCell.collectionLabel.text = [NSString stringWithFormat:@"%@", [video objectForKey:@"favority_num"]];
    playCell.likeLabel.text = [NSString stringWithFormat:@"%@", [video objectForKey:@"like_num"]];
    
}

- (void)initDramaCell
{
    dramaCell.frame = CGRectMake(0, 0, self.view.frame.size.width, ceil(totalDramaCount / 5.0) * 30 + 5);
    for (int i = 0; i < totalDramaCount; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btn.tag = i+1;
        [btn setFrame:CGRectMake(10 + (i % 5) * 61, 5 + floor(i / 5.0) * 30, 59, 25)];
        [btn setTitle:[NSString stringWithFormat:@"%i", i+1] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
        [UIUtility addTextShadow:btn.titleLabel];
        btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|
        UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [btn setBackgroundImage:[[UIImage imageNamed:@"unfocus"]stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIUtility createImageWithColor:[UIColor blackColor]] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(dramaPlay:)forControlEvents:UIControlEventTouchUpInside];
        [dramaCell.contentView addSubview:btn];
    }
}

- (void)dramaPlay:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    [self playVideo:btn.tag];
}


#pragma mark - Table View Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section < 3){
        return 1;
    } else {
        if(commentArray == nil || commentArray.count == 0){
            return 1;
        } else {
            return commentArray.count;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return pictureCell;
    } else if (indexPath.section == 1) {
        return playCell;
    } else if (indexPath.section == 2){
        return dramaCell;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        return WindowHeight;
    } else if (indexPath.section == 1) {
        return playCell.frame.size.height;
    } else if(indexPath.section == 2){
        return dramaCell.frame.size.height;
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
    if(indexPath.section > 2 && commentArray.count > 0){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        CommentViewController *viewController = [[CommentViewController alloc]initWithNibName:@"CommentViewController" bundle:nil];
        viewController.threadId = [[commentArray objectAtIndex:indexPath.row] valueForKey:@"id"];
        viewController.title = @"评论回复";
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section < 2) {
        return 0;
    } else {
        return 24;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section < 2){
        return nil;
    }
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width, 24)];
    customView.backgroundColor = [UIColor blackColor];
    
    // create the label objects
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,0,self.view.bounds.size.width-10, 24)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:12];
    if(section == 2){
        headerLabel.text =  NSLocalizedString(@"drama_list", nil);
    } else {
        headerLabel.text =  NSLocalizedString(@"user_comment", nil);
    }
    headerLabel.textColor = [UIColor whiteColor];
    [customView addSubview:headerLabel];
    
    return customView;
}

- (void)playVideo
{
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [UIUtility showNetWorkError:self.view];
        return;
    }
    [self playVideo:1];
}

- (void)playVideo:(NSInteger)num
{
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isWifiReachable)]){
        BlockAlertView *alert = [BlockAlertView alertWithTitle:@"" message:@"播放视频会消耗大量流量，您确定要在非WiFi环境下播放吗？"];
        [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel", nil) block:nil];
        [alert setDestructiveButtonWithTitle:@"确定" block:^{
            [self willPlayVideo:num];
        }];
        [alert show];
    } else {
        [self willPlayVideo:num];
    }
}

- (void)willPlayVideo:(NSInteger)num
{
    NSArray *videoUrlArray = [[episodeArray objectAtIndex:num-1] objectForKey:@"down_urls"];
    for(NSDictionary *episode in episodeArray){
        if([[episode objectForKey:@"name"]integerValue] == num){
            videoUrlArray = [episode objectForKey:@"down_urls"];
            break;
        }
    }
    if(videoUrlArray.count > 0){
        NSString *videoUrl = nil;
        for(NSDictionary *tempVideo in videoUrlArray){
            if([LETV isEqualToString:[tempVideo objectForKey:@"source"]]){
                videoUrl = [self parseVideoUrl:tempVideo];
                break;
            }
        }
        if(videoUrl == nil){
            if (videoUrlArray.count > 0) {
                videoUrl = [self parseVideoUrl:[videoUrlArray objectAtIndex:0]];
            }
        }
        if(videoUrl == nil){
            [self gotoWebsite:num];
        } else {
            MediaPlayerViewController *viewController = [[MediaPlayerViewController alloc]initWithNibName:@"MediaPlayerViewController" bundle:nil];
            viewController.videoUrl = videoUrl;
            [self presentModalViewController:viewController animated:YES];
        }
    }else {
        [self gotoWebsite:num];
    }
}

- (void)gotoWebsite:(NSInteger)num
{
    ProgramViewController *viewController = [[ProgramViewController alloc]initWithNibName:@"ProgramViewController" bundle:nil];
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
    viewController.title = [video objectForKey:@"name"];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)showIntroduction{
    IntroductionView *lplv = [[IntroductionView alloc] initWithTitle:[video objectForKey:@"name"] content:[video objectForKey:@"summary"]];
    lplv.frame = CGRectMake(0, 0, lplv.frame.size.width, lplv.frame.size.height * 0.8);
    lplv.center = CGPointMake(160, 210 + _tableView.contentOffset.y);
    lplv.delegate = self;
    [lplv showInView:self.view animated:YES];
    _tableView.scrollEnabled = NO;
}

@end
