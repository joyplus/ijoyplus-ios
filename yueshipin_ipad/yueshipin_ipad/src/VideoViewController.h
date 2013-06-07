//
//  HomeViewController.h
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-20.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "CommonHeader.h"
#import "MenuViewController.h"
#import "PullRefreshManagerClinet.h"
#define SLIDER_VIEW_TAG 8924355
#define VIDEO_LOGO_HEIGHT 108
#define VIDEO_LOGO_WIDTH 78

@interface VideoViewController : SlideBaseViewController<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate,PullRefreshManagerClinetDelegate>{
    UIImageView *sloganImageView;
    UITableView *table;
    PullRefreshManagerClinet *pullToRefreshManager_;
    NSUInteger reloads_;
    int pageSize;
    BOOL _reloading;
    NSString *umengPageName;
}
@property (nonatomic, strong) NSArray *hightLightCategoryArray;
@property (nonatomic, strong) NSArray *regionCategoryArray;
@property (nonatomic, strong) NSArray *categoryArray;
@property (nonatomic, strong) NSArray *yearCategoryArray;
@property (nonatomic, strong) UIView *topCategoryView;
@property (nonatomic, strong) UIView *subcategoryView;
@property (nonatomic, strong) NSMutableArray *videoArray;
@property (nonatomic, strong) NSString *categoryType;
@property (nonatomic, strong) NSString * regionType;
@property (nonatomic, strong) NSString * yearType;
@property (nonatomic, strong) NSString *lastSelectCategoryKey;
@property (nonatomic, strong) NSString *lastSelectRegionKey;
@property (nonatomic, strong) NSString *lastSelectYearKey;
@property (nonatomic)VideoType videoType;
@property (nonatomic)BOOL revertSearchCriteria;

- (id)initWithFrame:(CGRect)frame;

@end
