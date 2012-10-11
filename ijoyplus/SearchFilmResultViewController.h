//
//  SearchFilmResultViewController.h
//  ijoyplus
//
//  Created by joyplus1 on 12-9-10.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomSearchBar.h"
#import "MNMBottomPullToRefreshManager.h"
#import "EGORefreshTableHeaderView.h"

@interface SearchFilmResultViewController : UITableViewController  <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, EGORefreshTableHeaderDelegate, MNMBottomPullToRefreshManagerClient> 


@property (nonatomic, strong)NSString *keyword;
@property (strong, nonatomic) IBOutlet CustomSearchBar *sBar;

@end
