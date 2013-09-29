//
//  YueSearchViewController.h
//  yueshipin
//
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonHeader.h"
#import "CustomSearchBar.h"
#import "YueSearchView.h"
@interface YueSearchViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,YueSearchViewDelegate>
{
    YueSearchView * searchView;
    UITableView *   historyTable;
}
@end
