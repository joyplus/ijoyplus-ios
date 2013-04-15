//
//  PageManageViewController.h
//  yueshipin
//
//  Created by 08 on 12-12-25.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDPageControl.h"
#import "EGORefreshTableHeaderView.h"
#import "MNMBottomPullToRefreshManager.h"
#import "DimensionalCodeScanViewController.h"
@interface PageManageViewController : UIViewController<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,MNMBottomPullToRefreshManagerClient,EGORefreshTableHeaderDelegate>{

    UIScrollView *scrollView_;
    DDPageControl *pageControl_;
    NSMutableArray *listArr_;
    NSMutableArray *tvListArr_;
    NSMutableArray *movieListArr_;
    NSMutableArray *showListArr_;
    NSMutableArray *comicListArr_;
    
    UITableView *tvTableList_;
    UITableView *movieTableList_;
    UITableView *showTableList_;
    UITableView *comicTableList_;
    
    UIButton *movieBtn_;
    UIButton *tvBtn_;
    UIButton *showBtn_;
    UIButton *comicBtn_;
    
    UIImageView *slider_;
    
    UIImageView *pageMGIcon_;
    UIImageView *bundingTipsView;
    EGORefreshTableHeaderView *refreshHeaderViewForMovieList_;
    EGORefreshTableHeaderView *refreshHeaderViewForTvList_;
    EGORefreshTableHeaderView *refreshHeaderViewForShowList_;
    EGORefreshTableHeaderView *refreshHeaderViewForComicList_;
    
    MNMBottomPullToRefreshManager *pullToRefreshManager_;
    
    BOOL reloading_;
    int movieLoadCount_;
    int tvLoadCount_;
    int showLoadCount_;
    int comicLoadCount_;
    NSString *showTopId_;
}
@property (strong, nonatomic)UIScrollView *scrollView;
@property (strong, nonatomic)DDPageControl *pageControl;
@property (strong, nonatomic)NSMutableArray *listArr;
@property (strong, nonatomic)NSMutableArray *tvListArr;
@property (strong, nonatomic)NSMutableArray *movieListArr;
@property (strong, nonatomic)NSMutableArray *showListArr;
@property (strong, nonatomic)NSMutableArray *comicListArr;
@property (strong, nonatomic)UITableView *comicTableList;
@property (strong, nonatomic)UIButton *comicBtn;
@property (strong, nonatomic)UITableView *tvTableList;
@property (strong, nonatomic)UITableView *movieTableList;
@property (strong, nonatomic)UITableView *showTableList;
@property (strong, nonatomic)UIButton *movieBtn;
@property (strong, nonatomic)UIButton *tvBtn;
@property (strong, nonatomic)UIButton *showBtn;
@property (strong, nonatomic)UIImageView *slider;
@property (strong, nonatomic)UIImageView *pageMGIcon;
@property (strong, nonatomic) NSString *showTopId;

@property (strong, nonatomic)EGORefreshTableHeaderView *refreshHeaderViewForComicList;
@property (strong, nonatomic)EGORefreshTableHeaderView *refreshHeaderViewForMovieList;
@property (strong, nonatomic)EGORefreshTableHeaderView *refreshHeaderViewForTvList;
@property (strong, nonatomic)EGORefreshTableHeaderView *refreshHeaderViewForShowList;

@property (strong, nonatomic) MNMBottomPullToRefreshManager *pullToRefreshManager;
@end
