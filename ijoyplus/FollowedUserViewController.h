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

@interface FollowedUserViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, EGORefreshTableHeaderDelegate, MNMBottomPullToRefreshManagerClient>


@property (nonatomic, strong)NSString *userid;
@property (nonatomic, strong)NSString *type;
@property (nonatomic, strong)NSString *nickname;

@end
