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
#import "MyMediaPlayerViewController.h"
#import "CustomNavigationViewController.h"
#import "IphoneWebPlayerViewController.h"
@interface MoreListViewController ()

@end

@implementation MoreListViewController
@synthesize listArr = listArr_;
@synthesize type = type_;
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
    if(type_ == 0){
       self.title = @"播放纪录";
    }
    else if (type_ == 1) {
       self.title = @"我的收藏";  
    }
    else if (type_ == 2){
       self.title = @"我的悦单";  
        
    }
    [self.navigationController.navigationBar setBackgroundImage:[UIImage scaleFromImage:[UIImage imageNamed:@"top_bg_common.png"] toSize:CGSizeMake(320, 44)] forBarMetrics:UIBarMetricsDefault];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 40, 30);
    backButton.backgroundColor = [UIColor clearColor];
    [backButton setImage:[UIImage imageNamed:@"top_return_common.png"]forState:UIControlStateNormal];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    if (type_ == 0) {
        UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [clearButton addTarget:self action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
        clearButton.frame = CGRectMake(0, 0, 54, 31);
        clearButton.backgroundColor = [UIColor clearColor];
        [clearButton setImage:[UIImage imageNamed:@"clear_bt.png"]forState:UIControlStateNormal];
        [clearButton setImage:[UIImage imageNamed:@"clear_bt_pressed.png"]forState:UIControlStateHighlighted];
        //[clearButton setTitle:@"clear" forState:UIControlStateNormal];
        UIBarButtonItem *clearButtonItem = [[UIBarButtonItem alloc] initWithCustomView:clearButton];
        self.navigationItem.rightBarButtonItem = clearButtonItem;
    }
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [super viewDidLoad];

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
        cell.titleLab.frame = CGRectMake(10, 24, 220, 15);
         cell.actors.text  = [self composeContent:infoDic];
        [cell.actors setFrame:CGRectMake(12, 40, 200, 15)];
        [cell.date removeFromSuperview];
        cell.play.tag = indexPath.row;
        [cell.play addTarget:self action:@selector(continuePlay:) forControlEvents:UIControlEventTouchUpInside];
       
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
        titleLab.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:titleLab];
        
        UILabel *actors = [[UILabel alloc] initWithFrame:CGRectMake(70, 26, 170, 15)];
        actors.text = [NSString stringWithFormat:@"主演：%@",[infoDic objectForKey:@"stars"]] ;
        actors.font = [UIFont systemFontOfSize:12];
        actors.textColor = [UIColor grayColor];
        actors.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:actors];
        
        UILabel *date = [[UILabel alloc] initWithFrame:CGRectMake(70, 38, 200, 15)];
        date.text = [NSString stringWithFormat:@"年代：%@",[infoDic objectForKey:@"publish_date"]];
        date.font = [UIFont systemFontOfSize:12];
        date.textColor = [UIColor grayColor];
        date.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:date];
        
        
        UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_fen_ge_xian.png"]];
        line.frame = CGRectMake(0, 59, 320, 1);
        [cell.contentView addSubview:line];
        return cell;

    }
    else if (type_ == 2){
        RecordListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier ];
        if (cell == nil) {
            cell = [[RecordListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.titleLab.text = [infoDic objectForKey:@"name"];
         NSMutableArray *items = (NSMutableArray *)[infoDic objectForKey:@"items"];
        if (items != nil && [items count] != 0) {
         NSDictionary *item = [items objectAtIndex:0];
         cell.actors.text = [item objectForKey:@"prod_name"];
         [cell.actors setFrame:CGRectMake(12, 33, 200, 15)];
         cell.date.text = @"...";
         [cell.date setFrame:CGRectMake(14, 42, 200, 15)];
        }

        [cell.play removeFromSuperview];
        
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
        
        switch (type_) {
            case 0:
            {
                NSDictionary *infoDic = [listArr_ objectAtIndex:indexPath.row];
                NSString *topicId = [infoDic objectForKey:@"prod_id"];
                NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: topicId, @"prod_id", nil];
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
    MBProgressHUD*tempHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:tempHUD];
    tempHUD.labelText = @"加载中...";
    tempHUD.opacity = 0.5;
    [tempHUD show:YES];
    int num = ((UIButton *)sender).tag;
    NSDictionary *item = [listArr_ objectAtIndex:num];
    int type = [[item objectForKey:@"prod_type"] intValue];
    NSString *prodId = [item objectForKey:@"prod_id"];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:prodId, @"prod_id", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathProgramView parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        [tempHUD hide:YES];
        NSDictionary *videoInfo = nil;
        if (type == 1) {
            videoInfo = (NSDictionary *)[result objectForKey:@"movie"];
        }
        else if(type == 2){
            videoInfo = (NSDictionary *)[result objectForKey:@"tv"];
        }
        else if (type == 3){
            videoInfo = (NSDictionary *)[result objectForKey:@"show"];
        }
        // NSNumber *number = (NSNumber *)[item objectForKey:@"playback_time"];
        IphoneWebPlayerViewController *iphoneWebPlayerViewController = [[IphoneWebPlayerViewController alloc] init];
        iphoneWebPlayerViewController.playNum = [[item objectForKey:@"prod_subname"] intValue];
        iphoneWebPlayerViewController.nameStr = [item objectForKey:@"prod_name"];
        iphoneWebPlayerViewController.episodesArr =  [videoInfo objectForKey:@"episodes"];
        iphoneWebPlayerViewController.videoType = type;
        iphoneWebPlayerViewController.prodId = prodId;
        [self presentViewController:[[CustomNavigationViewController alloc] initWithRootViewController:iphoneWebPlayerViewController] animated:YES completion:nil];
        
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        [tempHUD hide:YES];
    }];

  
}


-(void)clear{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"确定清除播放记录？" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    [alert show];
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        for (NSDictionary *dic in listArr_) {
            NSString *type = [dic objectForKey:@"prod_type"];
            NSString *prodId = [dic objectForKey:@"prod_id"];
            NSString *subName = [dic objectForKey:@"prod_subname"];
            if ([type isEqualToString:@"1"]) {
                [[CacheUtility sharedCache] removeObjectForKey:[NSString stringWithFormat:@"%@_%d",prodId,0]];
            }
            else if([type isEqualToString:@"2"]|| [type isEqualToString:@"3"]){
                [[CacheUtility sharedCache] removeObjectForKey:[NSString stringWithFormat:@"%@_%@",prodId,subName]];
            }
            
        }
        NSString *userId = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId];
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: userId, @"user_id", nil];
        [[AFServiceAPIClient sharedClient] postPath:kPathRemoveAllPlay parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [[NSNotificationCenter defaultCenter] postNotificationName:WATCH_HISTORY_REFRESH object:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
            
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        }];

    }

}

- (NSString *)composeContent:(NSDictionary *)item
{
    NSString *content;
    int subNum = [[item objectForKey:@"prod_subname"] intValue]+1;
    NSNumber *number = (NSNumber *)[item objectForKey:@"playback_time"];
    if ([[NSString stringWithFormat:@"%@", [item objectForKey:@"prod_type"]] isEqualToString:@"1"]) {
        content = [NSString stringWithFormat:@"已观看到 %@", [TimeUtility formatTimeInSecond:number.doubleValue]];
    } else if ([[NSString stringWithFormat:@"%@", [item objectForKey:@"prod_type"]] isEqualToString:@"2"]) {
        content = [NSString stringWithFormat:@"已观看到第%d集 %@", subNum, [TimeUtility formatTimeInSecond:number.doubleValue]];
    } else if ([[NSString stringWithFormat:@"%@", [item objectForKey:@"prod_type"]] isEqualToString:@"3"]) {
        content = [NSString stringWithFormat:@"已观看 %@", [TimeUtility formatTimeInSecond:number.doubleValue]];
    }
    return content;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
    if (type_ == 1) {
        IphoneMovieDetailViewController *detailViewController = [[IphoneMovieDetailViewController alloc] init];
        detailViewController.infoDic = [self.listArr objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:detailViewController animated:YES];
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

@end
