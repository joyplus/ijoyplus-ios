//
//  ListViewController.h
//  yueshipin_ipad
//
//  Created by zhang zhipeng on 12-11-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "CommonHeader.h"

@interface ListViewController : GenericBaseViewController <UITableViewDataSource, UITableViewDelegate, MNMBottomPullToRefreshManagerClient>{
    UITableView *table;
    NSMutableArray *topsArray;
}

@property (nonatomic, strong)NSString *listTitle;
@property (nonatomic, strong)NSString *topId;

@end
