//
//  IphoneShowViewController.h
//  yueshipin
//
//  Created by 08 on 12-12-28.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IphoneVideoViewController.h"
#import "MNMBottomPullToRefreshManager.h"
@interface IphoneShowDetailViewController : IphoneVideoViewController<MNMBottomPullToRefreshManagerClient>{
    NSDictionary *infoDic_;
    NSDictionary *videoInfo_;
    NSArray *episodesArr_;
    int videoType_;
    NSString *summary_;
    UIScrollView *scrollView_;
    int pageCount_;
    int currentPage_;
    UIButton *next_;
    UIButton *pre_;
    NSMutableArray *commentArray_;
    int favCount_;
    int supportCount_;
    UIImageView *summaryBg_;
    UILabel *summaryLabel_;
    UIButton *moreBtn_;
    MNMBottomPullToRefreshManager *pullToRefreshManager_;
}
@property (nonatomic, strong) NSDictionary *infoDic;
@property (nonatomic, strong) NSDictionary *videoInfo;
@property (nonatomic, strong) NSArray *episodesArr;
@property (nonatomic, assign) int videoType;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIButton *next;
@property (nonatomic, strong) UIButton *pre;
@property (nonatomic, strong) NSMutableArray *commentArray;
@property (nonatomic, strong) UIImageView *summaryBg;
@property (nonatomic, strong) UILabel *summaryLabel;
@property (nonatomic, strong) UIButton *moreBtn;
@property (strong, nonatomic) MNMBottomPullToRefreshManager *pullToRefreshManager;
@end
