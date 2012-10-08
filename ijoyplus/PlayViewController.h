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

@interface PlayViewController : UITableViewController<UIScrollViewDelegate, MNMBottomPullToRefreshManagerClient, IntroductionViewDelegate, EGORefreshTableHeaderDelegate> {
    /**
     * Pull to refresh manager
     */
    MNMBottomPullToRefreshManager *pullToRefreshManager_;
    
    /**
     * Reloads (for testing purposes)
     */
    NSUInteger reloads_;
}
@property (nonatomic, strong) NSString *programId;
@property (nonatomic, assign)int imageHeight;

@end
