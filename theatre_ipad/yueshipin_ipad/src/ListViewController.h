//
//  ListViewController.h
//  yueshipin_ipad
//
//  Created by zhang zhipeng on 12-11-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "CommonHeader.h"

@interface ListViewController : SlideBaseViewController <UITableViewDataSource, UITableViewDelegate, MNMBottomPullToRefreshManagerClient>{
    UITableView *table;
    NSMutableArray *topsArray;
    UIButton *closeBtn;
    UILabel *titleLabel;
    NSString *umengPageName;
}

@property (nonatomic, strong)NSString *listTitle;
@property (nonatomic, strong)NSString *topId;
@property (nonatomic, assign)int type;
- (void)retrieveTopsListData;

@end
