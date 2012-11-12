//
//  FollowedUserViewController.h
//  ijoyplus
//
//  Created by joyplus1 on 12-9-20.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNMBottomPullToRefreshManager.h"
#import "EGORefreshTableHeaderView.h"

@interface PopularUserViewController : UITableViewController<UITableViewDataSource, UIScrollViewDelegate, EGORefreshTableHeaderDelegate, MNMBottomPullToRefreshManagerClient>


@property (nonatomic, strong)NSString *fromController;

@end
