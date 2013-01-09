//
//  FindViewController.h
//  yueshipin
//
//  Created by 08 on 13-1-5.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FindViewController : UIViewController<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>{
   UISearchBar *searchBar_;
   UITableView *tableList_;
   NSMutableArray *searchResults_;
   NSMutableArray *selectedArr_;
   NSString *topicId_;
   UIBarButtonItem *rightButtonItem_;
}
@property (nonatomic, strong)UISearchBar *searchBar;
@property (nonatomic, strong)UITableView *tableList;
@property (nonatomic, strong)NSMutableArray *searchResults;
@property (nonatomic, strong)NSMutableArray *selectedArr;
@property (nonatomic, strong)NSString *topicId;
@property (nonatomic, strong)UIBarButtonItem *rightButtonItem;
@end
