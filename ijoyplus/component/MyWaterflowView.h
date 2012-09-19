//
//  WaterflowView.h
//  WaterFlowDisplay
//
//  Created by B.H. Liu on 12-3-29.
//  Copyright (c) 2012年 Appublisher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaterflowView.h"

@class MyWaterflowView;

////DataSource and Delegate
@protocol MyWaterflowViewDatasource <NSObject>
@required
- (NSInteger)numberOfColumnsInFlowView:(MyWaterflowView*)flowView;
- (NSInteger)flowView:(MyWaterflowView *)flowView numberOfRowsInColumn:(NSInteger)column;
- (WaterFlowCell *)flowView:(MyWaterflowView *)flowView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@protocol MyWaterflowViewDelegate <NSObject>
@required
- (CGFloat)flowView:(MyWaterflowView *)flowView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
@optional
- (void)flowView:(MyWaterflowView *)flowView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)flowView:(MyWaterflowView *)flowView willLoadData:(int)page;
@end

////Waterflow View
@interface MyWaterflowView : UIScrollView<UIScrollViewDelegate>
{
    NSInteger numberOfColumns ; 
    NSInteger currentPage;
	
	NSMutableArray *_cellHeight; 
	NSMutableArray *_visibleCells; 
	NSMutableDictionary *_reusedCells; 
	
	id <MyWaterflowViewDelegate> _flowdelegate;
    id <MyWaterflowViewDatasource> _flowdatasource;
}

- (void)reloadData;

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;

@property (nonatomic, strong) NSMutableArray *cellHeight; //array of cells height arrays, count = numberofcolumns, and elements in each single child array represents is a total height from this cell to the top
@property (nonatomic, strong) NSMutableArray *visibleCells;  //array of visible cell arrays, count = numberofcolumns
@property (nonatomic, strong) NSMutableDictionary *reusableCells;  //key- identifier, value- array of cells
@property (nonatomic, strong) id <MyWaterflowViewDelegate> flowdelegate;
@property (nonatomic, strong) id <MyWaterflowViewDatasource> flowdatasource;
@property (nonatomic, strong) NSString *cellSelectedNotificationName;

@end
