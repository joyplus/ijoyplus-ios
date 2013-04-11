//
//  SearchListViewController.h
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-29.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "CommonHeader.h"

@interface SearchListViewController : SlideBaseViewController<UITableViewDataSource, UITableViewDelegate, MNMBottomPullToRefreshManagerClient>
@property (nonatomic, strong)NSString *keyword;
@property (nonatomic, weak)UIViewController *fromViewController;
@end
