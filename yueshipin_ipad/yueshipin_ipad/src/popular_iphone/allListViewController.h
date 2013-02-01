//
//  allListViewController.h
//  yueshipin
//
//  Created by 08 on 12-12-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "MNMBottomPullToRefreshManager.h"
#import "CustomNavigationButtonView.h"
@interface allListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,MNMBottomPullToRefreshManagerClient, EGORefreshTableHeaderDelegate>{
    NSMutableArray *listArray_;
    UITableView *tableList_;
    MNMBottomPullToRefreshManager *pullToRefreshManager_;
    EGORefreshTableHeaderView *refreshHeaderView_;
    NSUInteger reloads_;
    BOOL reloading_;
    CustomNavigationButtonView *customNavigationButtonView_;
}
@property (strong, nonatomic) NSMutableArray *listArray;
@property (strong, nonatomic) UITableView *tableList;
@property (strong, nonatomic) MNMBottomPullToRefreshManager *pullToRefreshManager;
@property (strong, nonatomic) EGORefreshTableHeaderView *refreshHeaderView;
@property (strong, nonatomic) CustomNavigationButtonView *customNavigationButtonView;

@end
