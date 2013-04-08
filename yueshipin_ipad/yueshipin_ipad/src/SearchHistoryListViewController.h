//
//  SearchHistoryListViewController.h
//  yueshipin
//
//  Created by joyplus1 on 13-4-8.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchViewController.h"

@interface SearchHistoryListViewController : UITableViewController <UITableViewDelegate>
@property (nonatomic, strong)NSMutableArray *historyArray;
@property (nonatomic, weak)id<SearchViewControllerDelegate>parentDelegate;
@end
