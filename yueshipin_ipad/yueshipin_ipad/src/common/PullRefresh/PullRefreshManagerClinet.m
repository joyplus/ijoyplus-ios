//
//  PullRefreshManagerClinet.m
//  tableViewDemo
//
//  Created by Rong on 13-5-20.
//  Copyright (c) 2013年 Rong. All rights reserved.
//

#import "PullRefreshManagerClinet.h"
#import "DemoTableHeaderView.h"
#import "DemoTableFooterView.h"
#import "QuartzCore/QuartzCore.h"
#define DEFAULT_HEIGHT_OFFSET 52.0f

@implementation PullRefreshManagerClinet
@synthesize tableView;
@synthesize headerView;
@synthesize footerView;

@synthesize isDragging;
@synthesize isRefreshing;
@synthesize isLoadingMore;

@synthesize canLoadMore;

@synthesize pullToRefreshEnabled;

@synthesize clearsSelectionOnViewWillAppear;

@synthesize delegate = delegate_;

@synthesize isShowHeaderView = isShowHeaderView_;

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) initialize
{
    pullToRefreshEnabled = YES;
    
    canLoadMore = YES;
    
    clearsSelectionOnViewWillAppear = YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id) initWithTableView:(UITableView *)atableview
{
    if (self = [super init]){
        [self initialize];
        
        self.tableView = atableview;
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DemoTableHeaderView" owner:self options:nil];
        
        isShowHeaderView_ = YES;
        DemoTableHeaderView *headerV = (DemoTableHeaderView *)[nib objectAtIndex:0];
        headerV.frame = CGRectMake(headerV.frame.origin.x, headerV.frame.origin.y, atableview.frame.size.width, headerV.frame.size.height);
        headerV.title.center = CGPointMake(headerV.center.x, headerV.title.center.y);
        headerV.dateLabel.center = CGPointMake(headerV.center.x, headerV.dateLabel.center.y);
        
        CALayer *layer = [CALayer layer];
		layer.frame = CGRectMake(25, headerV.frame.size.height - 65.0f, 30.0f, 55.0f);
		layer.contentsGravity = kCAGravityResizeAspect;
		layer.contents = (id)[UIImage imageNamed:@"blueArrow.png"].CGImage;
        arrowImageView = layer;
        [[headerV layer] addSublayer:layer];
        
        self.headerView = headerV;
        
        // set the custom view for "load more". See DemoTableFooterView.xib.
        nib = [[NSBundle mainBundle] loadNibNamed:@"DemoTableFooterView" owner:self options:nil];
        DemoTableFooterView *footerV = (DemoTableFooterView *)[nib objectAtIndex:0];
        footerV.frame = CGRectMake(footerV.frame.origin.x, footerV.frame.origin.y, atableview.frame.size.width, footerV.frame.size.height);
        footerV.activityIndicator.center = footerV.center;
        
        NSLog(@"%f %f %f %f",footerV.frame.origin.x,footerV.frame.origin.y,footerV.frame.size.width,footerV.frame.size.height);
        self.footerView = footerV;
    }
    return self;
}

#pragma mark - Pull to Refresh

-(void)setShowHeaderView:(BOOL) boolValue{
    isShowHeaderView_ = boolValue;
    DemoTableHeaderView *hv = (DemoTableHeaderView *)self.headerView;
    hv.hidden = !boolValue;
}
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setHeaderView:(UIView *)aView
{
    if (!tableView)
        return;
    
    if (headerView && [headerView isDescendantOfView:tableView])
        [headerView removeFromSuperview];
         headerView = nil;
    
    if (aView) {
        headerView = aView;
        
        CGRect f = headerView.frame;
        headerView.frame = CGRectMake(f.origin.x, 0 - f.size.height, f.size.width, f.size.height);
        headerViewFrame = headerView.frame;
        
        [tableView addSubview:headerView];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat) headerRefreshHeight
{
    if (!CGRectIsEmpty(headerViewFrame))
        return headerViewFrame.size.height;
    else
        return DEFAULT_HEIGHT_OFFSET;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) pinHeaderView
{
    [UIView animateWithDuration:0.3 animations:^(void) {
        self.tableView.contentInset = UIEdgeInsetsMake([self headerRefreshHeight], 0, 0, 0);
    }];
    DemoTableHeaderView *hv = (DemoTableHeaderView *)self.headerView;
    [hv.activityIndicator startAnimating];
    hv.title.text = @"努力加载中...";
    arrowImageView.hidden = YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) unpinHeaderView
{
    [UIView animateWithDuration:0.3 animations:^(void) {
        self.tableView.contentInset = UIEdgeInsetsZero;
    }];
    [[(DemoTableHeaderView *)self.headerView activityIndicator] stopAnimating];
    arrowImageView.hidden = NO;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) willBeginRefresh
{
    if (pullToRefreshEnabled)
        [self pinHeaderView];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) willShowHeaderView:(UIScrollView *)scrollView
{
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) headerViewDidScroll:(BOOL)willRefreshOnRelease scrollView:(UIScrollView *)scrollView
{
    if (!isShowHeaderView_) {
        return;
    }
    DemoTableHeaderView *hv = (DemoTableHeaderView *)self.headerView;
    if (willRefreshOnRelease){
        hv.title.text = @"松开可以刷新...";
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.18];
        arrowImageView.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
        [CATransaction commit];
    }
    else{
        hv.title.text = @"下拉可以刷新...";
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.18];
        arrowImageView.transform = CATransform3DIdentity;
        [CATransaction commit];
        
        NSDate *date = [NSDate date];
		
		[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehaviorDefault];
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterShortStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        
		hv.dateLabel.text = [NSString stringWithFormat:@"更新于：%@", [dateFormatter stringFromDate:date]];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) refresh
{
    if (!isShowHeaderView_) {
        return NO;
    }
    if (isRefreshing)
        return NO;
    
    [self willBeginRefresh];
    isRefreshing = YES;
    [delegate_ pulltoReFresh];
    return YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) refreshCompleted
{
    isRefreshing = NO;
    
    if (pullToRefreshEnabled)
        [self unpinHeaderView];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Load More

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setFooterView:(UIView *)aView
{
    if (!tableView)
        return;
    
    tableView.tableFooterView = nil;
    footerView = nil;
    
    if (aView) {
        footerView = aView;
        
        tableView.tableFooterView = footerView;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) willBeginLoadingMore
{
    DemoTableFooterView *fv = (DemoTableFooterView *)self.footerView;
    [fv.activityIndicator startAnimating];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) loadMoreCompleted
{
    isLoadingMore = NO;
    DemoTableFooterView *fv = (DemoTableFooterView *)self.footerView;
    [fv.activityIndicator stopAnimating];
    
    if (!self.canLoadMore) {
        // Do something if there are no more items to load
        
        // We can hide the footerView by: [self setFooterViewVisibility:NO];
        
        // Just show a textual info that there are no more items to load
        fv.infoLabel.hidden = NO;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) loadMore
{
    if (isLoadingMore)
        return NO;
    
    [self willBeginLoadingMore];
    isLoadingMore = YES;
    [delegate_ pulltoLoadMore];
    return YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat) footerLoadMoreHeight
{
    if (footerView)
        return footerView.frame.size.height;
    else
        return DEFAULT_HEIGHT_OFFSET;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setFooterViewVisibility:(BOOL)visible
{
    if (visible && self.tableView.tableFooterView != footerView)
        self.tableView.tableFooterView = footerView;
    else if (!visible)
        self.tableView.tableFooterView = nil;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) allLoadingCompleted
{
    if (isRefreshing)
        [self refreshCompleted];
    if (isLoadingMore)
        [self loadMoreCompleted];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)scrollViewBegin{
    if (isRefreshing)
        return;
    isDragging = YES;
}

-(void)scrollViewScrolled:(UIScrollView *)scrollView{
    if (!isRefreshing && isDragging && scrollView.contentOffset.y < 0) {
        [self headerViewDidScroll:scrollView.contentOffset.y < 0 - [self headerRefreshHeight]
                       scrollView:scrollView];
    } else if (!isLoadingMore && canLoadMore) {
        
        CGFloat scrollPosition = scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y;
        if (scrollPosition < [self footerLoadMoreHeight]) {
            NSLog(@"%f",[self footerLoadMoreHeight]);
            NSLog(@"%f - %f - %f",scrollView.contentSize.height,scrollView.frame.size.height,scrollView.contentOffset.y);
            [self loadMore];
        }
    }
}

-(void)scrollViewEnd:(UIScrollView *)scrollView{

    if (isRefreshing)
        return;
    
    isDragging = NO;
    if (scrollView.contentOffset.y <= 0 - [self headerRefreshHeight]) {
        if (pullToRefreshEnabled)
            [self refresh];
    }
}


@end
