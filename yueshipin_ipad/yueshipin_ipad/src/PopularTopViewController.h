//
//  HomeViewController.h
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-20.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "CommonHeader.h"
#import "MenuViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "PullRefreshManagerClinet.h"
@interface PopularTopViewController : SlideBaseViewController<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, MNMBottomPullToRefreshManagerClient, EGORefreshTableHeaderDelegate,PullRefreshManagerClinetDelegate, UIGestureRecognizerDelegate>

- (id)initWithFrame:(CGRect)frame;

@end
