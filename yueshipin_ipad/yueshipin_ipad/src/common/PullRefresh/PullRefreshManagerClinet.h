//
//  PullRefreshManagerClinet.h
//  tableViewDemo
//
//  Created by Rong on 13-5-20.
//  Copyright (c) 2013年 Rong. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PullRefreshManagerClinetDelegate <NSObject>
@optional
-(void)pulltoReFresh;
-(void)pulltoLoadMore;
@end

@interface PullRefreshManagerClinet : NSObject<UITableViewDelegate, UITableViewDataSource>{
@protected
    
    BOOL isDragging;
    BOOL isRefreshing;
    BOOL isLoadingMore;
    
    // had to store this because the headerView's frame seems to be changed somewhere during scrolling
    // and I couldn't figure out why >.<
    CGRect headerViewFrame;
    
    CALayer *arrowImageView;
}
// The view used for "pull to refresh"
@property (nonatomic, weak) id <PullRefreshManagerClinetDelegate> delegate;

@property (nonatomic, strong) UIView *headerView;

// The view used for "load more"
@property (nonatomic, strong) UIView *footerView;

@property (nonatomic, strong) UITableView *tableView;
@property (readonly) BOOL isDragging;
@property (readonly) BOOL isRefreshing;
@property (readonly) BOOL isLoadingMore;
@property (nonatomic) BOOL canLoadMore;

@property (nonatomic) BOOL pullToRefreshEnabled;

// Defaults to YES
@property (nonatomic) BOOL clearsSelectionOnViewWillAppear;

// Defaults to YES
@property (nonatomic, assign) BOOL isShowHeaderView;

// Just a common initialize method
- (void) initialize;

- (id) initWithTableView:(UITableView *)tableview;

#pragma mark - Pull to Refresh

-(void)scrollViewBegin;

-(void)scrollViewScrolled:(UIScrollView *)scrollView;

-(void)scrollViewEnd:(UIScrollView *)scrollView;

-(void)setShowHeaderView:(BOOL) boolValue;
// The minimum height that the user should drag down in order to trigger a "refresh" when
// dragging ends.
- (CGFloat) headerRefreshHeight;

// Will be called if the user drags down which will show the header view. Override this to
// update the header view (e.g. change the label to "Pull down to refresh").
- (void) willShowHeaderView:(UIScrollView *)scrollView;

// If the user is dragging, will be called on every scroll event that the headerView is shown.
// The value of willRefreshOnRelease will be YES if the user scrolled down enough to trigger a
// "refresh" when the user releases the drag.
- (void) headerViewDidScroll:(BOOL)willRefreshOnRelease scrollView:(UIScrollView *)scrollView;

// By default, will permanently show the headerView by setting the tableView's contentInset.
- (void) pinHeaderView;

// Reverse of pinHeaderView.
- (void) unpinHeaderView;

// Called when the user stops dragging and, if the conditions are met, will trigger a refresh.
- (void) willBeginRefresh;

// Override to perform fetching of data. The parent method [super refresh] should be called first.
// If the value is NO, -refresh should be aborted.
- (BOOL) refresh;

// Call to signal that refresh has completed. This will then hide the headerView.
- (void) refreshCompleted;

#pragma mark - Load More

// The value of the height starting from the bottom that the user needs to scroll down to in order
// to trigger -loadMore. By default, this will be the height of -footerView.
- (CGFloat) footerLoadMoreHeight;

// Override to perform fetching of next page of data. It's important to call and get the value of
// of [super loadMore] first. If it's NO, -loadMore should be aborted.
- (BOOL) loadMore;

// Called when all the conditions are met and -loadMore will begin.
- (void) willBeginLoadingMore;

// Call to signal that "load more" was completed. This should be called so -isLoadingMore is
// properly set to NO.
- (void) loadMoreCompleted;

// Helper to show/hide -footerView
- (void) setFooterViewVisibility:(BOOL)visible;

#pragma mark -

// A helper method that calls refreshCompleted and/or loadMoreCompleted if any are active.
- (void) allLoadingCompleted;
@end
