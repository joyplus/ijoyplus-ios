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
    NSArray *sortedwatchRecordArray_;
    NSMutableArray *favArr_;
    NSArray *favShowArr_;
    NSMutableArray *myListArr_;
    UITableView *recordTableList_;
    UITableView *favTableList_;
    UITableView *myTableList_;
    UIView *moreView_;
    UIButton *moreButton_;
    UIImageView *avatarImage_;
    UILabel *nameLabel_;
    NSString *userId_;
    UIButton *createList_;
    UIImageView *noRecordBg_;
    UIButton *button1_;
    UIButton *button2_;
    UIButton *button3_;
}
@property (nonatomic, strong)UISegmentedControl *segControl;
@property (nonatomic, strong)UIView *bgView;
@property (nonatomic, strong)NSArray *sortedwatchRecordArray;
@property (nonatomic, strong)NSMutableArray *favArr;
@property (nonatomic, strong)NSArray *favShowArr;
@property (nonatomic, strong)NSMutableArray *myListArr;
@property (nonatomic, strong)UITableView *recordTableList;
@property (nonatomic, strong)UITableView *favTableList;
@property (nonatomic, strong)UIView *moreView;
@property (nonatomic, strong)UIButton *moreButton;
@property (nonatomic, strong)UIImageView *avatarImage;
@property (nonatomic, strong)UILabel *nameLabel;
@property (nonatomic, strong)NSString *userId;
@property (nonatomic, strong)UIButton *createList;
@property (nonatomic, strong)UITableView *myTableList;
@property (nonatomic, strong)UIButton *button1;
@property (nonatomic, strong)UIButton *button2;
@property (nonatomic, strong)UIButton *button3;


@end
