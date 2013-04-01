//
//  TVDetailViewController.h
//  yueshipin
//
//  Created by 08 on 12-12-28.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IphoneVideoViewController.h"
#import "MNMBottomPullToRefreshManager.h"
@interface TVDetailViewController :IphoneVideoViewController<MNMBottomPullToRefreshManagerClient>{

    NSDictionary *videoInfo_;
    int videoType_;
    NSString *summary_;
    UIScrollView *scrollView_;
    int pageCount_;
    int page_;
    NSMutableArray *commentArray_;
    int favCount_;
    int supportCount_;
    NSArray *relevantList_;
    
    UIImageView *summaryBg_;
    UILabel *summaryLabel_;
    UIButton *moreBtn_;
    MNMBottomPullToRefreshManager *pullToRefreshManager_;
    
    UIScrollView *scrollViewUp_;
    UIScrollView *scrollViewDown_;
    
    UIScrollView *scrollViewUpDL_;
    UIScrollView *scrollViewDownDL_;
    
    int currentPage_;
    int currentPageDownLoad_;
    int downScrollCount_;
    UIButton *next_;
    UIButton *pre_;
    UIButton *nextDL_;
    UIButton *preDL_;
    BOOL isDownLoad_;
    BOOL isloaded_;
    
    NSArray *arrReviewData_;
}
@property (nonatomic, strong) NSDictionary *videoInfo;
@property (nonatomic, assign) int videoType;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *commentArray;
@property (nonatomic, strong) NSArray *relevantList;
@property (nonatomic, strong) UIImageView *summaryBg;
@property (nonatomic, strong) UILabel *summaryLabel;
@property (nonatomic, strong) UIButton *moreBtn;
@property (nonatomic, strong) UIScrollView *scrollViewUp;
@property (nonatomic, strong) UIScrollView *scrollViewDown;
@property (nonatomic, strong) UIScrollView *scrollViewUpDL;
@property (nonatomic, strong) UIScrollView *scrollViewDownDL;
@property (nonatomic, strong) UIButton *next;
@property (nonatomic, strong) UIButton *pre;
@property (nonatomic, strong) UIButton *nextDL;
@property (nonatomic, strong) UIButton *preDL;
@end

