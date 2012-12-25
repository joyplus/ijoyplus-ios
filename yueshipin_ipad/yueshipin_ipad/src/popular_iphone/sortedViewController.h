//
//  sortedViewController.h
//  yueshipin
//
//  Created by 08 on 12-12-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface sortedViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *listArr_;
    UITableView *tableList_;
    int type_;
}
@property (strong, nonatomic) NSMutableArray *listArr;
@property (strong, nonatomic) UITableView *tableList;
@property (assign, nonatomic) int type;
@end
