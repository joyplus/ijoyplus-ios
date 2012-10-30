//
//  FriendViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-20.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "FriendViewController.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "CMConstants.h"
#import <QuartzCore/QuartzCore.h>
#import "ContainerUtility.h"
#import "CMConstants.h"
#import "StringUtility.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "FriendPlayDetailViewController.h"
#import "FriendDramaPlayDetailViewController.h"
#import "FriendVideoPlayDetailViewController.h"
#import "FriendShowPlayDetailViewController.h"
#import "CacheUtility.h"
#import "UIUtility.h"

@interface FriendViewController (){
    WaterflowView *flowView;
    NSMutableArray *imageUrls;
    NSMutableArray *videoArray;
}
- (void)addContentView;
@end

@implementation FriendViewController

- (void)didReceiveMemoryWarning
{
    NSLog(@"receive memory warning in %@", self.class);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    flowView = nil;
    imageUrls = nil;
    videoArray = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addContentView];
    //    UISwipeGestureRecognizer *downGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(hideNavigationBarAnimation)];
    //    downGesture.direction = UISwipeGestureRecognizerDirectionDown;
    //    [flowView addGestureRecognizer:downGesture];
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:@"FriendViewController"];
    if(cacheResult != nil){
        [self parseData:cacheResult];
        [flowView reloadData];
    }
    if([[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: @"1", @"page_num", @"30", @"page_size", nil];
        [[AFServiceAPIClient sharedClient] getPath:kPathFriendRecommends parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [self parseData:result];
            [flowView reloadData];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
        }];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
    }
}


- (void)parseData:(id)result
{
    videoArray = [[NSMutableArray alloc]initWithCapacity:10];
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        [[CacheUtility sharedCache] putInCache:@"FriendViewController" result:result];
        NSArray *videos = [result objectForKey:@"recommends"];
        if(videos.count > 0){
            [videoArray addObjectsFromArray:videos];
        }
    } else {
        
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    if(videoArray == nil && HUD == nil && [[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [self showProgressBar];
    }
}
- (void)addContentView
{
    if(flowView != nil){
        [flowView removeFromSuperview];
    }
    flowView = [[WaterflowView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - TAB_BAR_HEIGHT - 44)];
    [flowView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    flowView.cellSelectedNotificationName = @"friendVideoSelected";
    [flowView showsVerticalScrollIndicator];
    flowView.flowdatasource = self;
    flowView.flowdelegate = self;
    [self.view addSubview:flowView];
    
    [flowView reloadData];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark-
#pragma mark- WaterflowDataSource

- (NSInteger)numberOfColumnsInFlowView:(WaterflowView *)flowView
{
    return NUMBER_OF_COLUMNS;
}

- (NSInteger)flowView:(WaterflowView *)flowView numberOfRowsInColumn:(NSInteger)column
{
    return 10;
}

- (WaterFlowCell*)flowView:(WaterflowView *)flowView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row * 3 + indexPath.section>= videoArray.count){
        return nil;
    }
    static NSString *CellIdentifier = @"movieCell";
    WaterFlowCell *cell = [flowView_ dequeueReusableCellWithIdentifier:CellIdentifier];
	if(cell == nil){
		cell  = [[WaterFlowCell alloc] initWithReuseIdentifier:CellIdentifier];
        cell.cellSelectedNotificationName = flowView.cellSelectedNotificationName;
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        imageView.layer.borderWidth = 1;
        imageView.layer.borderColor = CMConstants.imageBorderColor.CGColor;
        imageView.layer.shadowColor = [UIColor blackColor].CGColor;
        imageView.layer.shadowOffset = CGSizeMake(1, 1);
        imageView.layer.shadowOpacity = 1;
        imageView.tag = 5001;
        [cell addSubview:imageView];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont systemFontOfSize:13];
        titleLabel.tag = 5002;
        [cell addSubview:titleLabel];
    }
    
    UIImageView *imageView  = (UIImageView *)[cell viewWithTag:5001];
    float height = [self flowView:nil heightForRowAtIndexPath:indexPath];
    if(indexPath.section == 0){
        imageView.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP, 0, MOVIE_LOGO_WIDTH, height - MOVE_NAME_LABEL_HEIGHT);
    } else if(indexPath.section == NUMBER_OF_COLUMNS - 1){
        imageView.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP/2, 0, MOVIE_LOGO_WIDTH, height - MOVE_NAME_LABEL_HEIGHT);
    } else {
        imageView.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP/2, 0, MOVIE_LOGO_WIDTH, height - MOVE_NAME_LABEL_HEIGHT);
    }
    NSString *imageUrl = [[videoArray objectAtIndex:(indexPath.row * 3 + indexPath.section)] objectForKey:@"content_pic_url"];
    [imageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"movie_placeholder"]];
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:5002];
    titleLabel.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP, height - MOVE_NAME_LABEL_HEIGHT, MOVE_NAME_LABEL_WIDTH, MOVE_NAME_LABEL_HEIGHT);
    titleLabel.text =  [[videoArray objectAtIndex:(indexPath.row  * 3+ indexPath.section)] objectForKey:@"content_name"];
    
    return cell;
    
}

#pragma mark-
#pragma mark- WaterflowDelegate
-(CGFloat)flowView:(WaterflowView *)flowView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row * 3 + indexPath.section >= videoArray.count){
        //            if((indexPath.row+1) % 10 == 0){
        //                return 120;
        //            }
        return 0;
    }
    NSString *type = [[videoArray objectAtIndex:(indexPath.row * 3 + indexPath.section)] objectForKey:@"content_type"];
    
    if([type isEqualToString:@"1"] || [type isEqualToString:@"2"]){
        return MOVE_NAME_LABEL_HEIGHT + MOVIE_LOGO_HEIGHT ;
    } else {
        return MOVE_NAME_LABEL_HEIGHT + VIDEO_LOGO_HEIGHT ;
    }
    
}

- (void)flowView:(WaterflowView *)flowView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *program = [videoArray objectAtIndex:indexPath.row * 3 + indexPath.section];
    NSString *type = [program objectForKey:@"content_type"];
    PlayDetailViewController *viewController;
    if([type isEqualToString:@"1"]){
        viewController = [[FriendPlayDetailViewController alloc]initWithStretchImage];
    } else if([type isEqualToString:@"2"]){
        viewController = [[FriendDramaPlayDetailViewController alloc]initWithStretchImage];
    } else if([type isEqualToString:@"3"]){
        viewController = [[FriendShowPlayDetailViewController alloc]initWithStretchImage];
    } else if([type isEqualToString:@"4"]){
        viewController = [[FriendVideoPlayDetailViewController alloc]initWithStretchImage];
    }
    viewController.programId = [program valueForKey:@"content_id"];
    [self.navigationController pushViewController:viewController animated:YES];
    
}

- (void)flowView:(WaterflowView *)_flowView willLoadData:(int)page
{
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [UIUtility showNetWorkError:self.view];
        return;
    }
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSString stringWithFormat:@"%i", page], @"page_num", @"30", @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathFriendRecommends parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *videos = [result objectForKey:@"recommends"];
            if(videos != nil && videos.count > 0){
                //                for(int i = 0; i < 20; i++)
                [videoArray addObjectsFromArray:videos];
                [flowView reloadData];
            }
        } else {
            
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
    
}

- (void)flowView:(WaterflowView *)_flowView refreshData:(int)page
{
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [UIUtility showNetWorkError:self.view];
        return;
    }
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSString stringWithFormat:@"%i", 1], @"page_num", @"30", @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathFriendRecommends parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *videos = [result objectForKey:@"recommends"];
            if(videos != nil && videos.count > 0){
                [videoArray removeAllObjects];
                [videoArray addObjectsFromArray:videos];
                [flowView reloadData];
            }
        } else {
            
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
    
}
@end
