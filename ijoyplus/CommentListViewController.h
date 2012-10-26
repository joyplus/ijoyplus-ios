//
//  CommentListViewController.h
//  ijoyplus
//
//  Created by joyplus1 on 12-9-25.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNMBottomPullToRefreshManager.h"
#import "EGORefreshTableHeaderView.h"

@interface CommentListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, EGORefreshTableHeaderDelegate, MNMBottomPullToRefreshManagerClient> {
    
}

@property (nonatomic, strong)NSString *programId;
@property (nonatomic, weak) IBOutlet UITableView *table;
@end