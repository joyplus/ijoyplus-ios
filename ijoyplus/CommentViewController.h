//
//  CommentViewController.h
//  ijoyplus
//
//  Created by joyplus1 on 12-9-27.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"
#import "MNMBottomPullToRefreshManager.h"
#import "EGORefreshTableHeaderView.h"

@interface CommentViewController : UIViewController<HPGrowingTextViewDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, EGORefreshTableHeaderDelegate, MNMBottomPullToRefreshManagerClient> {

}

@property (nonatomic, strong)NSString *threadId;
@property (assign, nonatomic)BOOL openKeyBoard;
@property (nonatomic, readwrite, retain) IBOutlet UITableView *table;
@end
