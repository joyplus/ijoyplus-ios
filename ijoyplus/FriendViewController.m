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
#import "FriendPlayRootViewController.h"
#import "CMConstants.h"
#import <QuartzCore/QuartzCore.h>
#import "ContainerUtility.h"
#import "StringUtility.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "LocalPlayRootViewController.h"
#import "DramaPlayRootViewController.h"
#import "VideoPlayRootViewController.h"
#import "CMConstants.h"
#import "FriendPlayRootViewController.h"

@interface FriendViewController (){
    WaterflowView *flowView;
    NSMutableArray *imageUrls;
    NSMutableArray *videoArray;
}
- (void)addContentView;
@end

@implementation FriendViewController

- (void)viewDidUnload
{
    flowView = nil;
    imageUrls = nil;
    videoArray = nil;
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addContentView];
    //    UISwipeGestureRecognizer *downGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(hideNavigationBarAnimation)];
    //    downGesture.direction = UISwipeGestureRecognizerDirectionDown;
    //    [flowView addGestureRecognizer:downGesture];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: kAppKey, @"app_key", @"1", @"page_num", @"30", @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathFriendRecommends parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *videos = [result objectForKey:@"recommends"];
            videoArray = [[NSMutableArray alloc]initWithCapacity:10];
            if(videos.count > 0){
                //                for(int i = 0; i < 10; i++)
                [videoArray addObjectsFromArray:videos];
                
            }
            [flowView reloadData];
        } else {
            
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
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
    
    static NSString *CellIdentifier = @"movieCell";
    WaterFlowCell *cell = [[WaterFlowCell alloc] initWithReuseIdentifier:CellIdentifier];
    cell.cellSelectedNotificationName = flowView.cellSelectedNotificationName;
    if(indexPath.row * 3 + indexPath.section>= videoArray.count){
        return cell;
    }
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    if(indexPath.section == 0){
        imageView.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP, 0, MOVIE_LOGO_WIDTH, MOVIE_LOGO_HEIGHT);
    } else if(indexPath.section == NUMBER_OF_COLUMNS - 1){
        imageView.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP/2, 0, MOVIE_LOGO_WIDTH, MOVIE_LOGO_HEIGHT);
    } else {
        imageView.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP/2, 0, MOVIE_LOGO_WIDTH, MOVIE_LOGO_HEIGHT);
    }
    NSString *imageUrl = [[videoArray objectAtIndex:(indexPath.row * 3 + indexPath.section)] objectForKey:@"content_pic_url"];
    [imageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    imageView.layer.borderWidth = 1;
    imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    imageView.layer.shadowColor = [UIColor blackColor].CGColor;
    imageView.layer.shadowOffset = CGSizeMake(1, 1);
    imageView.layer.shadowOpacity = 1;
    [cell addSubview:imageView];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(MOVIE_LOGO_WIDTH_GAP, MOVIE_LOGO_HEIGHT, MOVE_NAME_LABEL_WIDTH, MOVE_NAME_LABEL_HEIGHT)];
    titleLabel.text =  [[videoArray objectAtIndex:(indexPath.row  * 3+ indexPath.section)] objectForKey:@"content_name"];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:13];
    [cell addSubview:titleLabel];
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
    NSString *type = [[videoArray objectAtIndex:(indexPath.row * 3 + indexPath.section)] objectForKey:@"content_type"];
    PlayRootViewController *viewController;
    if([type isEqualToString:@"1"]){
        viewController = [[FriendPlayRootViewController alloc]init];
    } else if([type isEqualToString:@"2"]){
        viewController = [[DramaPlayRootViewController alloc]init];
    } else if([type isEqualToString:@"3"]){
        viewController = [[LocalPlayRootViewController alloc]init];
    } else if([type isEqualToString:@"4"]){
        viewController = [[VideoPlayRootViewController alloc]init];
    }
    viewController.programId = [program valueForKey:@"content_id"];
    [self.navigationController pushViewController:viewController animated:YES];
    
}

- (void)flowView:(WaterflowView *)_flowView willLoadData:(int)page
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                kAppKey, @"app_key",
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
@end
