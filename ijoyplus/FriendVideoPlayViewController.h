//
//  PlayViewController.h
//  ijoyplus
//
//  Created by joyplus1 on 12-9-11.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNMBottomPullToRefreshManager.h"
#import "IntroductionView.h"
#import "EGORefreshTableHeaderView.h"
#import "VideoPlayViewController.h"
#import "LoadMoreCell.h"
@interface FriendVideoPlayViewController : VideoPlayViewController{
    NSMutableArray *friendCommentArray;
}

- (CommentCell *)displayFriendCommentCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath commentArray:(NSArray *)dataArray cellIdentifier:(NSString *)cellIdentifier;
- (LoadMoreCell *)displayLoadMoreCell:(UITableView *)tableView;
- (void)postInitialization:(NSDictionary *)result;
@end
