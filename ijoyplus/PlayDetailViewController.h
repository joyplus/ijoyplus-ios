//
//  PlayDetailViewController.h
//  ijoyplus
//
//  Created by joyplus1 on 12-10-17.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNMBottomPullToRefreshManager.h"
#import "IntroductionView.h"
#import "PlayCell.h"
#import "CommentCell.h"
#import "NoRecordCell.h"
#import "LoadMoreCell.h"
#import "UIGenericViewController.h"

@interface PlayDetailViewController : UIGenericViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, MNMBottomPullToRefreshManagerClient, IntroductionViewDelegate, UIGestureRecognizerDelegate> {
    UIImageView     *_imageView;
    UIScrollView    *_imageScroller;
    UITableView     *_tableView;
    NSMutableArray *commentArray;
    PlayCell *playCell;
    UITableViewCell *pictureCell;
    NSDictionary *movie;
    BOOL _reloading;
    MNMBottomPullToRefreshManager *pullToRefreshManager_;
    UIImageView *playImageView;
    UIButton *playButton;
    UIToolbar *bottomToolbar;
    int pageSize;
    CGFloat WindowHeight;
    CGFloat ImageHeight;
    int reload;
    NSString *name;
}

- (void)avatarClicked;
- (void)showIntroduction;
- (void)playVideo;
- (void)getProgramView;
- (void)loadTable;
- (void)setPlayCellValue;
- (void)initPlayCell;
- (void)initPictureCell;
- (CommentCell *)displayCommentCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath commentArray:(NSArray *)dataArray cellIdentifier:(NSString *)cellIdentifier;
- (NoRecordCell *)displayNoRecordCell:(UITableView *)tableView;
- (CGFloat)caculateCommentCellHeight:(NSInteger)row dataArray:(NSArray *)dataArray;

- (CommentCell *)displayFriendCommentCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath commentArray:(NSArray *)dataArray cellIdentifier:(NSString *)cellIdentifier;
- (LoadMoreCell *)displayLoadMoreCell:(UITableView *)tableView;
- (void)postInitialization:(NSDictionary *)result;
- (NSString *)parseVideoUrl:(NSDictionary *)video;
- (id)initWithStretchImage;
- (void)layoutImage;
- (void)updateOffsets;
@property (nonatomic, strong) NSString *programId;
@property (nonatomic, strong)NSString *userId;
@end;