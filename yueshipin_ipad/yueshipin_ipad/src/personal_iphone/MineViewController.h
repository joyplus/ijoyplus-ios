//
//  mineViewController.h
//  yueshipin
//
//  Created by 08 on 12-12-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MineViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{

    UISegmentedControl *segControl_;
    UIView *bgView_;
    NSMutableArray *recordArr_;
    NSMutableArray *favArr_;
    NSArray *redShowArr_;
    NSArray *favShowArr_;
    UITableView *recordTableList_;
    UITableView *favTableList_;
    UIView *moreView_;
    UIButton *moreButton_;
}
@property (nonatomic, strong)UISegmentedControl *segControl;
@property (nonatomic, strong)UIView *bgView;
@property (nonatomic, strong)NSMutableArray *recordArr;
@property (nonatomic, strong)NSArray *redShowArr;
@property (nonatomic, strong)NSMutableArray *favArr;
@property (nonatomic, strong)NSArray *favShowArr;
@property (nonatomic, strong)UITableView *recordTableList;
@property (nonatomic, strong)UITableView *favTableList;
@property (nonatomic, strong)UIView *moreView;
@property (nonatomic, strong)UIButton *moreButton;
@end
