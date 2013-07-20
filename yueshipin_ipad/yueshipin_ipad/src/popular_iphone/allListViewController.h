//
//  allListViewController.h
//  yueshipin
//
//  Created by 08 on 12-12-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRefreshManagerClinet.h"
#import "CustomNavigationButtonView.h"
@interface allListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate, PullRefreshManagerClinetDelegate>{
    NSMutableArray *listArray_;
    UITableView *tableList_;
    NSUInteger reloads_;
    BOOL reloading_;
    CustomNavigationButtonView *customNavigationButtonView_;
}
@property (strong, nonatomic) NSMutableArray *listArray;
@property (strong, nonatomic) UITableView *tableList;
@property (strong, nonatomic) PullRefreshManagerClinet *pullToRefreshManager;
@property (strong, nonatomic) CustomNavigationButtonView *customNavigationButtonView;
-(void)reFreshViewController;
@end
