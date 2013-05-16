//
//  ChannelViewController.h
//  theatreiphone
//
//  Created by Rong on 13-5-13.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SegmentControlView.h"
#import "VideoTypeSegment.h"
#import "FiltrateCell.h"
#import "EGORefreshTableHeaderView.h"
#import "MNMBottomPullToRefreshManager.h"
@interface ChannelViewController : UIViewController<VideoTypeSegmentDelegate,SegmentDelegate,FiltrateViewDelegate,FiltrateCellDelegate,UITableViewDataSource,UITableViewDelegate,MNMBottomPullToRefreshManagerClient, EGORefreshTableHeaderDelegate>{
    UIButton *titleButton_;
    int typeSelectIndex_;
    int videoType_;
    BOOL isLoading_;
}
@property(nonatomic, strong)UIButton *titleButton;
@property(nonatomic, strong)SegmentControlView *segV;
@property(nonatomic, strong)VideoTypeSegment *videoTypeSeg;
@property(nonatomic, strong)FiltrateView *filtrateView;
@property(nonatomic, strong)UITableView *tableList;
@property(nonatomic, strong)NSMutableArray *dataArr;
@property(nonatomic, strong)NSMutableDictionary *parameters;
@property (strong, nonatomic) MNMBottomPullToRefreshManager *pullToRefreshManager;
@property (strong, nonatomic) EGORefreshTableHeaderView *refreshHeaderView;
@end
