//
//  ShowListViewController.h
//  yueshipin_ipad
//
//  Created by zhang zhipeng on 12-11-25.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoDetailViewController.h"

@interface CommentListViewController : UITableViewController

@property (nonatomic, strong) NSString *prodId;
@property (nonatomic, assign) int tableHeight;
@property (nonatomic, strong) NSString *videoName;
@property (nonatomic, weak)id<VideoDetailViewControllerDelegate>parentDelegate;
@end
