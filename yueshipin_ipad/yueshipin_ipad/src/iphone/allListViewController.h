//
//  allListViewController.h
//  yueshipin
//
//  Created by 08 on 12-12-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface allListViewController : UIViewController<UITabBarDelegate,UITableViewDataSource>{
    NSMutableArray *listArray_;
    UITableView *tableList_;
}
@property (strong, nonatomic) NSMutableArray *listArray;
@property (strong, nonatomic) UITableView *tableList;
@end
