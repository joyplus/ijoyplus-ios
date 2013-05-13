//
//  MoreListViewController.m
//  yueshipin
//
//  Created by 08 on 12-12-26.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "MoreListViewController.h"
#import "RecordListCell.h"
#import "IphoneMovieDetailViewController.h"
#import "CreateMyListTwoViewController.h"
#import "UIImage+Scale.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "ProgramNavigationController.h"
#import "TimeUtility.h"
#import "UIImageView+WebCache.h"
#import "CommonHeader.h"
#import "CustomNavigationViewController.h"
#import "IphoneWebPlayerViewController.h"
#import "IphoneMovieDetailViewController.h"
#import "IphoneShowDetailViewController.h"
#import "TVDetailViewController.h"
#import "CommonMotheds.h"
#import "MyListCell.h"
@interface MoreListViewController ()

@end

@implementation MoreListViewController
@synthesize listArr = listArr_;
@synthesize type = type_;
@synthesize pullToRefreshManagerFAV = pullToRefreshManagerFAV_;
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

    if(type_ == 0){
       self.title = @"播放纪录";
    }
    else if (type_ == 1) {
       self.title = @"我的收藏";  
    }
    else if (type_ == 2){
       self.title = @"我的悦单";  
        
    }
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"top_bg_common.png"] forBarMetrics:UIBarMetricsDefault];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 55, 44);
    backButton.backgroundColor = [UIColor clearColor];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"back_f.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
//    if (type_ == 0) {
//        UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [clearButton addTarget:self action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
//        clearButton.frame = CGRectMake(0, 0, 54, 31);
//        clearButton.backgroundColor = [UIColor clearColor];
//        [clearButton setImage:[UIImage imageNamed:@"clear_bt.png"]forState:UIControlStateNormal];
//        [clearButton setImage:[UIImage imageNamed:@"clear_bt_pressed.png"]forState:UIControlStateHighlighted];
//        //[clearButton setTitle:@"clear" forState:UIControlStateNormal];
//        UIBarButtonItem *clearButtonItem = [[UIBarButtonItem alloc] initWithCustomView:clearButton];
//        self.navigationItem.rightBarButtonItem = clearButtonItem;
//    }
    UIImageView *backGround = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_common.png"]];
    backGround.frame = CGRectMake(0, 0, 320, kFullWindowHeight);
    self.tableView.backgroundView = backGround;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    if (type_ == 1) {
        favLoadCount_ = 1;
        pullToRefreshManagerFAV_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:600 tableView:self.tableView withClient:self];
        [self.tableView reloadData];
        [pullToRefreshManagerFAV_ tableViewReloadFinished];
    }
    
}

- (void)viewWillAppear:(BOOL)animated{
    
}

-(void)back:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.

    return [listArr_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    NSDictionary *infoDic = [listArr_ objectAtIndex:indexPath.row];
    if (type_ == 0) {
        RecordListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier ];
        if (cell == nil) {
            cell = [[RecordListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }

        cell.titleLab.text = [infoDic objectForKey:@"prod_name"];
        cell.titleLab.frame = CGRectMake(10, 20, 220, 15);
         cell.actors.text  = [self composeContent:infoDic];
        [cell.actors setFrame:CGRectMake(12, 36, 200, 15)];
        [cell.date removeFromSuperview];
        cell.play.frame =  CGRectMake(248,8, 47, 42);
        cell.play.tag = indexPath.row;
        cell.play.hidden = NO;
        [cell.play addTarget:self action:@selector(continuePlay:) forControlEvents:UIControlEventTouchUpInside];
        cell.line.frame = CGRectMake(0,59,320, 1);
        return cell;
    }
    else if (type_ == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        NSDictionary *infoDic = [listArr_ objectAtIndex:indexPath.row];
        
        UIImageView *frame = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"listFrame.png"]];
        frame.frame = CGRectMake(14, 6, 39, 49);
        [cell.contentView addSubview:frame];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 7, 36, 45)];
        [imageView setImageWithURL:[NSURL URLWithString:[infoDic objectForKey:@"content_pic_url"]] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
        [cell.contentView addSubview:imageView];
        
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(70, 8, 170, 15)];
        titleLab.font = [UIFont systemFontOfSize:14];
        titleLab.text = [infoDic objectForKey:@"content_name"];
        titleLab.textColor = [UIColor colorWithRed:110.0/255 green:110.0/255 blue:110.0/255 alpha:1.0];
        titleLab.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:titleLab];
        
        UILabel *actors = [[UILabel alloc] initWithFrame:CGRectMake(70, 26, 170, 15)];
        actors.text = [NSString stringWithFormat:@"主演：%@",[infoDic objectForKey:@"stars"]] ;
        actors.font = [UIFont systemFontOfSize:12];
        actors.textColor = [UIColor grayColor];
        actors.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:actors];
        
        UILabel *date = [[UILabel alloc] initWithFrame:CGRectMake(70, 40, 200, 15)];
        date.text = [NSString stringWithFormat:@"年代：%@",[infoDic objectForKey:@"publish_date"]];
        date.font = [UIFont systemFontOfSize:12];
        date.textColor = [UIColor grayColor];
        date.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:date];
        
        
        UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fengexian.png"]];
        line.frame = CGRectMake(0, 59, 320, 1);
        [cell.contentView addSubview:line];
        
        UIView *selectedBg = [[UIView alloc] initWithFrame:cell.frame];
        selectedBg.backgroundColor = [UIColor colorWithRed:185.0/255 green:185.0/255 blue:174.0/255 alpha:0.4];
        cell.selectedBackgroundView = selectedBg;
        
        return cell;

    }
    else if (type_ == 2){
        MyListCell *cell = [[MyListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell initCell:infoDic];
        return cell;

    }
    
    
    return nil;
}

- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    if (type_ == 0) {
        RecordListCell *cell = (RecordListCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.play.hidden = YES;
        
    }
}

- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    if (type_ == 0) {
        RecordListCell *cell = (RecordListCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.play.hidden = NO;
    }
    
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete){
        [CommonMotheds showNetworkDisAbledAlert:self.view];
        switch (type_) {
            case 0:
            {
                NSDictionary *infoDic = [listArr_ objectAtIndex:indexPath.row];
                NSString *topicId = [infoDic objectForKey:@"id"];
                NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: topicId, @"history_id", nil];
                [[AFServiceAPIClient sharedClient] postPath:kPathHiddenPlay parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
                    [listArr_ removeObjectAtIndex:indexPath.row];
                    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    [[NSNotificationCenter defaultCenter] postNotificationName:WATCH_HISTORY_REFRESH object:nil];
                } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                }];
                break;
            }
            case 1:
            {
                NSDictionary *infoDic = [listArr_ objectAtIndex:indexPath.row];
                NSString *topicId = [infoDic objectForKey:@"content_id"];
                NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: topicId, @"prod_id", nil];
                [[AFServiceAPIClient sharedClient] postPath:kPathProgramUnfavority parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
                    [listArr_ removeObjectAtIndex:indexPath.row];
                    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_FAV" object:nil];
                } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                }];
                break;
            }
            case 2:
            {
                NSDictionary *infoDic = [listArr_ objectAtIndex:indexPath.row];
                NSString *topicId = [infoDic objectForKey:@"topic_id"];
                
                NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:topicId, @"topic_id", nil];
                [[AFServiceAPIClient sharedClient] postPath:kPathTopDelete parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
                    NSString *responseCode = [result objectForKey:@"res_code"];
                    if([responseCode isEqualToString:kSuccessResCode]){
                        [listArr_ removeObjectAtIndex:indexPath.row];
                        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    }
                    else {
                        [UIUtility showSystemError:self.view];
                    }
                } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                    [UIUtility showSystemError:self.view];
                }];

                break;
            }
            default:
                break;
        }
                   
    }
}

-(void)continuePlay:(id)sender{
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([hostReach currentReachabilityStatus] == NotReachable){
       [UIUtility showNetWorkError:self.view];
        return;
    }
    int num = ((UIButton *)sender).tag;
    NSDictionary *item = [listArr_ objectAtIndex:num];
    int type = [[item objectForKey:@"prod_type"] intValue];
    NSString *prodId = [item objectForKey:@"prod_id"];
    IphoneWebPlayerViewController *iphoneWebPlayerViewController = [[IphoneWebPlayerViewController alloc] init];
    iphoneWebPlayerViewController.videoType = type;
    iphoneWebPlayerViewController.prodId = prodId;
    iphoneWebPlayerViewController.isPlayFromRecord = YES;
    iphoneWebPlayerViewController.continuePlayInfo = item;
    [self presentViewController:[[CustomNavigationViewController alloc] initWithRootViewController:iphoneWebPlayerViewController] animated:YES completion:nil];
}




- (NSString *)composeContent:(NSDictionary *)item
{
    NSString *content;
    NSNumber *number = (NSNumber *)[item objectForKey:@"playback_time"];
    if ([[NSString stringWithFormat:@"%@", [item objectForKey:@"prod_type"]] isEqualToString:@"1"]) {
        content = [NSString stringWithFormat:@"已观看到 %@", [TimeUtility formatTimeInSecond:number.doubleValue]];
    } else if ([[NSString stringWithFormat:@"%@", [item objectForKey:@"prod_type"]] isEqualToString:@"2"]) {
        int subNum = [[item objectForKey:@"prod_subname"] intValue];
        content = [NSString stringWithFormat:@"已观看到第%d集 %@", subNum, [TimeUtility formatTimeInSecond:number.doubleValue]];
    } else if ([[NSString stringWithFormat:@"%@", [item objectForKey:@"prod_type"]] isEqualToString:@"3"]) {
        content = [NSString stringWithFormat:@"已观看 《%@》 %@", [item objectForKey:@"prod_subname"],[TimeUtility formatTimeInSecond:number.doubleValue]];
    }
    return content;
}


-(void)loadMyFavsData{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:(NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId], @"userid", [NSString stringWithFormat:@"%d",favLoadCount_], @"page_num", [NSNumber numberWithInt:10], @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathUserFavorities parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *tempTopsArray = [result objectForKey:@"favorities"];
            if(tempTopsArray.count > 0){
                [listArr_ addObjectsFromArray:tempTopsArray];
            }
        }

        [self.tableView reloadData];
        [pullToRefreshManagerFAV_ tableViewReloadFinished];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
       
    }];
    
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (type_ == 2) {
        return 74;
    }
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
      [CommonMotheds showNetworkDisAbledAlert:self.view];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (type_ == 0) {
        NSDictionary *dic = [listArr_ objectAtIndex:indexPath.row];
        NSString *type = [dic objectForKey:@"prod_type"];
        if ([type isEqualToString:@"1"]) {
            IphoneMovieDetailViewController *detailViewController = [[IphoneMovieDetailViewController alloc] init];
            detailViewController.infoDic = dic;
            detailViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:detailViewController animated:YES];
        }
        else if ([type isEqualToString:@"2"]){
            TVDetailViewController *detailViewController = [[TVDetailViewController alloc] init];
            detailViewController.infoDic = dic;
            detailViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:detailViewController animated:YES];}
        
        else if ([type isEqualToString:@"3"]){
            IphoneShowDetailViewController *detailViewController = [[IphoneShowDetailViewController alloc] init];
            detailViewController.infoDic = dic;
            detailViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:detailViewController animated:YES];
            
        }
        
    }
    else if (type_ == 1) {
            NSDictionary *dic = [listArr_ objectAtIndex:indexPath.row];
            NSString *type = [dic objectForKey:@"content_type"];
            if ([type isEqualToString:@"1"]) {
                IphoneMovieDetailViewController *detailViewController = [[IphoneMovieDetailViewController alloc] init];
                detailViewController.infoDic = dic;
                detailViewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:detailViewController animated:YES];
            }
            else if ([type isEqualToString:@"2"]||[type isEqualToString:@"131"]){
                TVDetailViewController *detailViewController = [[TVDetailViewController alloc] init];
                detailViewController.infoDic = dic;
                detailViewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:detailViewController animated:YES];}
            
            else if ([type isEqualToString:@"3"]){
                IphoneShowDetailViewController *detailViewController = [[IphoneShowDetailViewController alloc] init];
                detailViewController.infoDic = dic;
                detailViewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:detailViewController animated:YES];
                
            }
            
    }
    else if (type_ == 2){
        NSDictionary *infoDic = [listArr_ objectAtIndex:indexPath.row];
        NSMutableArray *items = (NSMutableArray *)[infoDic objectForKey:@"items"];
        CreateMyListTwoViewController *createMyListTwoViewController = [[CreateMyListTwoViewController alloc] init];
        createMyListTwoViewController.listArr = items;
        [self.navigationController pushViewController:createMyListTwoViewController animated:YES];
    }
}

-(BOOL)shouldAutorotate {
    
    return NO;
    
}

-(NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
    
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    
    return UIInterfaceOrientationPortrait;
    
}

#pragma mark -
#pragma mark ScrollViewDelegate Methods
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
        
}

- (void)scrollViewDidEndDragging:(UIScrollView *)aScrollView willDecelerate:(BOOL)decelerate {
    
    [pullToRefreshManagerFAV_ tableViewReleased];
    
}

#pragma mark -
#pragma mark MNMBottomPullToRefreshManagerClientReloadTable Methods
- (void)MNMBottomPullToRefreshManagerClientReloadTable {
     [CommonMotheds showNetworkDisAbledAlert:self.view];
    favLoadCount_++;
    [self loadMyFavsData];
}


@end
