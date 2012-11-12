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

@interface FriendListViewController : UITableViewController  <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, EGORefreshTableHeaderDelegate, MNMBottomPullToRefreshManagerClient>


@property (strong, nonatomic) NSString *keyword;
@property (weak, nonatomic) IBOutlet CustomSearchBar *sBar;
@property (strong, nonatomic) NSString *sourceType;//1 sina 2 tecent

@end
