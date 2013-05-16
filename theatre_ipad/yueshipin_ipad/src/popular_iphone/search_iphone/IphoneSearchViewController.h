//
//  IphoneSearchViewController.h
//  yueshipin
//
//  Created by 08 on 12-12-27.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIUtility.h"

@interface IphoneSearchViewController : UIViewController<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>{
    UISearchBar *searchBar_;
    NSMutableArray *searchResults_;
    UITableView *tableList_;
    NSString *keyWords_;
}
@property (nonatomic, strong)UISearchBar *searchBar;
@property (nonatomic, strong)NSMutableArray *searchResults;
@property (nonatomic, strong)UITableView *tableList;
@property (nonatomic, strong)NSString *keyWords;
@end
