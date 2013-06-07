//
//  ListViewController.h
//  yueshipin_ipad
//
//  Created by zhang zhipeng on 12-11-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "CommonHeader.h"
#import "PullRefreshManagerClinet.h"
@interface AddSearchListViewController : GenericBaseViewController <UITableViewDataSource, UITableViewDelegate, PullRefreshManagerClinetDelegate>

@property (nonatomic, strong)NSString *keyword;

@property (nonatomic, strong)NSString *topId;

@property (nonatomic, strong)UIViewController *backToViewController;

@property (assign, nonatomic) int type;

@end
