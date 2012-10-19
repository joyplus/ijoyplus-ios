//
//  WaterflowView.h
//  WaterFlowDisplay
//
//  Created by B.H. Liu on 12-3-29.
//  Copyright (c) 2012年 Appublisher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
@class WaterflowView;

////TableCell for WaterFlow
@interface WaterFlowCell:UIView
{
    NSIndexPath *_indexPath;
    NSString *_reuseIdentifier;
    NSString *cellSelectedNotificationName;
}

@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic, retain) NSString *reuseIdentifier;
@property (nonatomic, strong) NSString *cellSelectedNotificationName;
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end

////DataSource and Delegate
@protocol WaterflowViewDatasource <NSObject>
@required
- (NSInteger)numberOfColumnsInFlowView:(WaterflowView*)flowView;
- (NSInteger)flowView:(WaterflowView *)flowView numberOfRowsInColumn:(NSInteger)column;
- (WaterFlowCell *)flowView:(WaterflowView *)flowView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@protocol WaterflowViewDelegate <NSObject>
@required
- (CGFloat)flowView:(WaterflowView *)flowView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
@optional
- (void)flowView:(WaterflowView *)flowView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)flowView:(WaterflowView *)flowView willLoadData:(int)page;
- (void)flowView:(WaterflowView *)flowView refreshData:(int)page;
@end

////Waterflow View
@interface WaterflowView : UIScrollView<UIScrollViewDelegate>
{
    NSInteger numberOfColumns ; 
    NSInteger currentPage;
	
	NSMutableArray *_cellHeight; 
	NSMutableArray *_visibleCells; 
	NSMutableDictionary *_reusedCells; 
}

- (void)reloadData;
- (id)initWithFrameWithoutHeader:(CGRect)frame;
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (void)removeCellObserver;

@property (nonatomic, strong) NSMutableArray *cellHeight; //array of cells height arrays, count = numberofcolumns, and elements in each single child array represents is a total height from this cell to the top
@property (nonatomic, strong) NSMutableArray *visibleCells;  //array of visible cell arrays, count = numberofcolumns
@property (nonatomic, strong) NSMutableDictionary *reusableCells;  //key- identifier, value- array of cells
@property (nonatomic, weak) id <WaterflowViewDelegate> flowdelegate;
@property (nonatomic, weak) id <WaterflowViewDatasource> flowdatasource;
@property (nonatomic, strong) NSString *cellSelectedNotificationName;
@property (nonatomic, assign) BOOL mergeCell;
@property (nonatomic, assign) int mergeRow;
@property (nonatomic, strong) NSString *parentControllerName;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) int defaultScrollViewHeight;
@property(nonatomic, retain) EGORefreshTableHeaderView * refreshHeaderView;  //下拉刷新
@end
