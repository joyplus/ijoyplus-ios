//
//  ListViewController.h
//  yueshipin_ipad
//
//  Created by zhang zhipeng on 12-11-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "CommonHeader.h"

@interface AddSearchListViewController : GenericBaseViewController <UITableViewDataSource, UITableViewDelegate, MNMBottomPullToRefreshManagerClient>

@property (nonatomic, strong)NSString *keyword;

@property (nonatomic, strong)NSString *topId;

@end
