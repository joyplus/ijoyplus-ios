//
//  mineViewController.h
//  yueshipin
//
//  Created by 08 on 12-12-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
@interface MineViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{

    UIView *bgView_;
    NSMutableArray *sortedwatchRecordArray_;
    NSMutableArray *favArr_;
    NSArray *favShowArr_;
    NSMutableArray *myListArr_;
    UITableView *recordTableList_;
    UITableView *favTableList_;
    UITableView *myTableList_;
    UIButton *moreButton_;
    UIImageView *avatarImage_;
    UILabel *nameLabel_;
    NSString *userId_;
    UIButton *createList_;
    UIImageView *noRecordBg_;
    UIButton *button2_;
    UIButton *button3_;
    UIImageView *noRecord_;
    UIImageView *noFav_;
    UIImageView *noPersonalList_;
    UIImageView *typeLabel_;
    UIButton *clearRecord_;
    UIScrollView *scrollBg;
}
@property (nonatomic, strong)UISegmentedControl *segControl;
@property (nonatomic, strong)UIView *bgView;
@property (nonatomic, strong)NSMutableArray *sortedwatchRecordArray;
@property (nonatomic, strong)NSMutableArray *favArr;
@property (nonatomic, strong)NSArray *favShowArr;
@property (nonatomic, strong)NSMutableArray *myListArr;
@property (nonatomic, strong)UITableView *recordTableList;
@property (nonatomic, strong)UITableView *favTableList;
@property (nonatomic, strong)UIButton *moreButton;
@property (nonatomic, strong)UIImageView *avatarImage;
@property (nonatomic, strong)UILabel *nameLabel;
@property (nonatomic, strong)NSString *userId;
@property (nonatomic, strong)UIButton *createList;
@property (nonatomic, strong)UITableView *myTableList;
@property (nonatomic, strong)UIButton *button1;
@property (nonatomic, strong)UIButton *button2;
@property (nonatomic, strong)UIButton *button3;
@property (nonatomic, strong)UIImageView *noRecord;
@property (nonatomic, strong)UIImageView *noFav;
@property (nonatomic, strong)UIImageView *noPersonalList;
@property (nonatomic, strong)UIImageView *typeLabel;
@property (nonatomic, strong)UIButton *clearRecord;
@property (nonatomic, strong)UIScrollView *scrollBg;
@property (nonatomic, strong)MBProgressHUD *progressHUD;
@end
