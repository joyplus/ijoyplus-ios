//
//  PlayViewController.h
//  ijoyplus
//
//  Created by joyplus1 on 12-9-11.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNMBottomPullToRefreshManager.h"
#import "IntroductionView.h"
#import "EGORefreshTableHeaderView.h"

@interface LocalPlayViewController : UITableViewController<UIScrollViewDelegate, MNMBottomPullToRefreshManagerClient, IntroductionViewDelegate, EGORefreshTableHeaderDelegate> 
 

@property (nonatomic, assign)int imageHeight;
@property (nonatomic, strong) NSString *programId;
@end
