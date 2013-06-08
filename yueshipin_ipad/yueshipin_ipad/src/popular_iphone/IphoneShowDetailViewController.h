//
//  IphoneShowViewController.h
//  yueshipin
//
//  Created by 08 on 12-12-28.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IphoneVideoViewController.h"
#import "PullRefreshManagerClinet.h"
@interface IphoneShowDetailViewController : IphoneVideoViewController<PullRefreshManagerClinetDelegate>{
  
    NSDictionary *videoInfo_;
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
    PullRefreshManagerClinet *pullToRefreshManager_;
    BOOL isloaded_ ;
}
@property (nonatomic, strong) NSDictionary *videoInfo;
@property (nonatomic, assign) int videoType;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIButton *next;
@property (nonatomic, strong) UIButton *pre;
@property (nonatomic, strong) NSMutableArray *commentArray;
@property (nonatomic, strong) UIImageView *summaryBg;
@property (nonatomic, strong) UILabel *summaryLabel;
@property (nonatomic, strong) UIButton *moreBtn;
@property (strong, nonatomic) PullRefreshManagerClinet *pullToRefreshManager;
@end
