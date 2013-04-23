//
//  MoreListViewController.h
//  yueshipin
//
//  Created by 08 on 12-12-26.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNMBottomPullToRefreshManager.h"
@interface MoreListViewController : UITableViewController<MNMBottomPullToRefreshManagerClient>{
    NSMutableArray *listArr_;
    int type_;
    int favLoadCount_;
     MNMBottomPullToRefreshManager *pullToRefreshManagerFAV_;
}

@property (nonatomic, strong)NSMutableArray *listArr;
@property (nonatomic, assign)int type;
@property (nonatomic, strong)MNMBottomPullToRefreshManager *pullToRefreshManagerFAV;
@end
