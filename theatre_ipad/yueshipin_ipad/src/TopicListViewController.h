//
//  ListViewController.h
//  yueshipin_ipad
//
//  Created by zhang zhipeng on 12-11-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "CommonHeader.h"
#import "PullRefreshManagerClinet.h"
@interface TopicListViewController : SlideBaseViewController <UITableViewDataSource, UITableViewDelegate, PullRefreshManagerClinetDelegate>

@end
