//
//  ShowListViewController.h
//  yueshipin_ipad
//
//  Created by zhang zhipeng on 12-11-25.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoDetailViewController.h"

@interface SublistViewController : UITableViewController

@property (nonatomic, strong)NSArray *listData;
@property (nonatomic, weak)id <VideoDetailViewControllerDelegate>videoDelegate;
@end
