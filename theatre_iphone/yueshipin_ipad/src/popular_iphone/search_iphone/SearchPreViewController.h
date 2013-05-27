//
//  SearchPreViewController.h
//  yueshipin
//
//  Created by 08 on 12-12-27.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRefreshManagerClinet.h"
@interface SearchPreViewController : UIViewController<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,PullRefreshManagerClinetDelegate>{
    UISearchBar *searchBar_;
    UIImageView *hotView_;
    UITableView *tableList_;
    UITableView *searchResultList_;
    NSMutableArray *searchResults_;
    NSMutableArray *listArr_;
    int loadCount_;
}
@property (nonatomic, strong)UISearchBar *searchBar;
@property (nonatomic, strong)UIImageView *hotView;
@property (nonatomic, strong)UITableView *tableList;
@property (nonatomic, strong)UITableView *searchResultList;
@property (nonatomic, strong)NSMutableArray *listArr;
@property (nonatomic, strong)NSMutableArray *searchResults;
@property (nonatomic, strong)PullRefreshManagerClinet *pullRefreshManager;
@property (nonatomic, strong)NSString *currentSearchKey;
@end
