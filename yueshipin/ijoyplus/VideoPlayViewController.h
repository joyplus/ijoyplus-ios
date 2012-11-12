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
#import "CommentCell.h"
#import "NoRecordCell.h"
#import "PlayCell.h"
#import "DramaCell.h"

@interface VideoPlayViewController : UITableViewController<UIScrollViewDelegate, MNMBottomPullToRefreshManagerClient, IntroductionViewDelegate, EGORefreshTableHeaderDelegate> {
    NSMutableArray *commentArray;
    UIViewController *subviewController;//视图
    PlayCell *playCell;
    DramaCell *dramaCell;
    //    NSInteger totalDramaCount;
    NSDictionary *show;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    MNMBottomPullToRefreshManager *pullToRefreshManager_;
    NSUInteger reloads_;
}
 
- (void)loadTable;
- (void)setPlayCellValue;
- (void)avatarClicked:(id)sender;
- (CommentCell *)displayCommentCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath commentArray:(NSArray *)dataArray cellIdentifier:(NSString *)cellIdentifier;
- (NoRecordCell *)displayNoRecordCell:(UITableView *)tableView;
- (CGFloat)caculateCommentCellHeight:(NSInteger)row dataArray:(NSArray *)dataArray;
@property (nonatomic, assign)int imageHeight;
@property (nonatomic, strong) NSString *programId;
@end
