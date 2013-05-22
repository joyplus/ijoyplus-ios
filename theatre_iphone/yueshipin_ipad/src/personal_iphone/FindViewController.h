//
//  FindViewController.h
//  yueshipin
//
//  Created by 08 on 13-1-5.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRefreshManagerClinet.h"
@interface FindViewController : UIViewController<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,PullRefreshManagerClinetDelegate>{
   UISearchBar *searchBar_;
   UITableView *tableList_;
   NSMutableArray *searchResults_;
   NSMutableArray *selectedArr_;
   NSString *topicId_;
   UIBarButtonItem *rightButtonItem_;
   int type_;
   int loadCount_;
}
@property (nonatomic, strong)UISearchBar *searchBar;
@property (nonatomic, strong)UITableView *tableList;
@property (nonatomic, strong)NSMutableArray *searchResults;
@property (nonatomic, strong)NSMutableArray *selectedArr;
@property (nonatomic, strong)NSString *topicId;
@property (nonatomic, strong)UIBarButtonItem *rightButtonItem;
@property (nonatomic, assign)int type;
@property (nonatomic, strong)PullRefreshManagerClinet *pullRefreshManager;
@end
