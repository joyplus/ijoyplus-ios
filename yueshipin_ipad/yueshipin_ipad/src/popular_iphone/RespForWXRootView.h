//
//  RespForWXRootView.h
//  yueshipin
//
//  Created by 08 on 13-4-2.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

enum
{
    SEARCH_VIEW_TYPE = 1,
    SEGMENT_VIEW_TYPE
};

enum
{
    DATA_TYPE_HOT,
    DATA_TYPE_FAV,
    DATA_TYPE_REC
};

#define HOT_BUTTON_TAG          (101)
#define FAV_BUTTON_TAG          (102)
#define REC_BUTTON_TAG          (103)

@protocol RespForWXRootViewDelegate;

@interface RespForWXRootView : UIView <UITableViewDataSource,UITableViewDelegate>
{
    //View
    UIView      *_viewSegment;
    UITableView *_tableHot;
    UITableView *_tableFavAndRec;
    
    UILabel     *_labNoData;
    
    //Data
    NSInteger        _dataType;
    NSInteger        _viewType;
    
    NSArray         *_arrSearch;
    
    NSArray         *_arrHot;
    NSArray         *_arrFav;
    NSArray         *_arrRec;
}

@property (nonatomic) NSInteger        dataType;
@property (nonatomic) NSInteger        viewType;
@property (nonatomic, weak) id <RespForWXRootViewDelegate> delegate;

- (void)setViewType:(NSInteger)type;
- (void)refreshTableView:(NSArray *)data;

@end

@protocol RespForWXRootViewDelegate <NSObject>

- (void)gotoMoviewDetail:(NSDictionary *)data;
- (void)segmentBtnClicked:(NSInteger)type;

@end
