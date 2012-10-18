//
//  PlayDetailViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-10-17.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "VideoPlayDetailViewController.h"
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
#import "CustomBackButtonHolder.h"
#import "CustomBackButton.h"
#import "MBProgressHUD.h"
#import "RecommandViewController.h"
#import "SendCommentViewController.h"
#import "PostViewController.h"

#define ROW_HEIGHT 40

@interface VideoPlayDetailViewController (){
    NSInteger totalDramaCount;
}

@end

@implementation VideoPlayDetailViewController

- (void)viewDidUnload
{
    show = nil;
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)getProgramView
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                kAppKey, @"app_key",
                                self.programId, @"prod_id",
                                nil];
    
    [[AFServiceAPIClient sharedClient] getPath:kPathProgramView parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            show = (NSDictionary *)[result objectForKey:@"video"];
            [self setPlayCellValue];
            commentArray = (NSMutableArray *)[result objectForKey:@"comments"];
            if(commentArray == nil || commentArray.count == 0){
                commentArray = [[NSMutableArray alloc]initWithCapacity:10];
            }
            [self loadTable];
            if(pullToRefreshManager_ == nil && commentArray.count > 0){
                pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f tableView:_tableView withClient:self];
            }
        } else {

        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {

    }];
}

- (void)setPlayCellValue
{
    NSString *name = [show objectForKey:@"name"];
    CGSize constraint = CGSizeMake(300, 20000.0f);
    CGSize size = [name sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    playCell.filmTitleLabel.text = name;
    [playCell.filmTitleLabel setNumberOfLines:0];
    [playCell.publicLabel sizeToFit];
    //            totalDramaCount = [[show objectForKey:@"episodes_count"] integerValue];
    if(size.height < 30){
        playCell.publicLabel.textAlignment = UITextAlignmentRight;
    } else {
        playCell.publicLabel.textAlignment = UITextAlignmentLeft;
        playCell.frame = CGRectMake(0, 0, self.view.frame.size.width, size.height + 2 * ROW_HEIGHT + 20);
        [playCell.filmTitleLabel setFrame:CGRectMake(playCell.filmTitleLabel.frame.origin.x, playCell.filmImageView.frame.origin.y + 10, size.width, size.height)];
        playCell.publicLabel.frame = CGRectMake(10, size.height + 20, 260, playCell.publicLabel.frame.size.height);
        playCell.scoreImageView.frame = CGRectMake(playCell.publicLabel.frame.origin.x, playCell.publicLabel.frame.origin.y, playCell.scoreImageView.frame.size.width, playCell.scoreImageView.frame.size.height);
        playCell.scoreLabel.frame = CGRectMake(playCell.publicLabel.frame.origin.x, playCell.publicLabel.frame.origin.y, playCell.scoreLabel.frame.size.width, playCell.scoreLabel.frame.size.height);
        playCell.introuctionBtn.frame = CGRectMake(playCell.introuctionBtn.frame.origin.x, playCell.scoreImageView.frame.origin.y, playCell.introuctionBtn.frame.size.width, playCell.introuctionBtn.frame.size.height);
        
        playCell.watchedImageView.frame = CGRectMake(playCell.watchedImageView.frame.origin.x, playCell.scoreImageView.frame.origin.y + ROW_HEIGHT, playCell.watchedImageView.frame.size.width, playCell.watchedImageView.frame.size.height);
        playCell.watchedLabel.frame = CGRectMake(playCell.watchedLabel.frame.origin.x, playCell.scoreImageView.frame.origin.y + ROW_HEIGHT, playCell.watchedLabel.frame.size.width, playCell.watchedLabel.frame.size.height);
        playCell.likeImageView.frame = CGRectMake(playCell.likeImageView.frame.origin.x, playCell.scoreImageView.frame.origin.y + ROW_HEIGHT, playCell.likeImageView.frame.size.width, playCell.likeImageView.frame.size.height);
        playCell.likeLabel.frame = CGRectMake(playCell.likeLabel.frame.origin.x, playCell.scoreImageView.frame.origin.y + ROW_HEIGHT, playCell.likeLabel.frame.size.width, playCell.likeLabel.frame.size.height);
        playCell.collectionImageView.frame = CGRectMake(playCell.collectionImageView.frame.origin.x, playCell.scoreImageView.frame.origin.y + ROW_HEIGHT, playCell.collectionImageView.frame.size.width, playCell.collectionImageView.frame.size.height);
        playCell.collectionLabel.frame = CGRectMake(playCell.collectionLabel.frame.origin.x, playCell.scoreImageView.frame.origin.y + ROW_HEIGHT, playCell.collectionLabel.frame.size.width, playCell.collectionLabel.frame.size.height);
        
    }
    
    [_imageView setImageWithURL:[NSURL URLWithString:[show objectForKey:@"poster"]] placeholderImage:nil];
    NSString *score = [show objectForKey:@"score"];
    if(![StringUtility stringIsEmpty:score] && ![score isEqualToString:@"0"]){
        playCell.scoreLabel.text = score;
    } else {
        playCell.scoreLabel.text = @"未评分";
    }
    playCell.watchedLabel.text = [show objectForKey:@"watch_num"];
    playCell.collectionLabel.text = [show objectForKey:@"favority_num"];
    playCell.likeLabel.text = [show objectForKey:@"like_num"];
}

@end
