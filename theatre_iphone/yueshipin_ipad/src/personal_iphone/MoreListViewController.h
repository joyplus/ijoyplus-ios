//
//  MoreListViewController.h
//  yueshipin
//
//  Created by 08 on 12-12-26.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRefreshManagerClinet.h"
@interface MoreListViewController : UITableViewController<PullRefreshManagerClinetDelegate>{
    NSMutableArray *listArr_;
    int type_;
    int favLoadCount_;
    PullRefreshManagerClinet *pullToRefreshManagerFAV_;
}

@property (nonatomic, strong)NSMutableArray *listArr;
@property (nonatomic, assign)int type;
@property (nonatomic, strong)PullRefreshManagerClinet *pullToRefreshManagerFAV;
@end
