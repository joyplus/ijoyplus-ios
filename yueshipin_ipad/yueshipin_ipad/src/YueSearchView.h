//
//  YueSearchView.h
//  yueshipin
//
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

#define NUM_PER_PAGE        (10)

@protocol YueSearchViewDelegate <NSObject>

- (void)showNextPage;
- (void)keyWordClicked:(NSString *)keyWord;

@end

@interface YueSearchView : UIView
{
    NSMutableArray * _info;
}
@property (nonatomic, strong) NSMutableArray * info;
@property (nonatomic, weak) id <YueSearchViewDelegate> delegate;
- (void)setInfo:(NSMutableArray *)info;
@end
