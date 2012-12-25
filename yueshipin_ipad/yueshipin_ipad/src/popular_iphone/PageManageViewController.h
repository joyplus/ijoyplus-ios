//
//  PageManageViewController.h
//  yueshipin
//
//  Created by 08 on 12-12-25.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageManageViewController : UIViewController<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>{

    UIScrollView *scrollView_;
    UIPageControl *pageControl_;
    NSMutableArray *listArr_;
    NSMutableArray *tvListArr_;
    NSMutableArray *movieListArr_;
    NSMutableArray *showListArr_;
    UITableView *tvTableList_;
    UITableView *movieTableList_;
    UITableView *showTableList_;
    
}
@property (strong, nonatomic)UIScrollView *scrollView;
@property (strong, nonatomic)UIPageControl *pageControl;
@property (strong, nonatomic)NSMutableArray *listArr;
@property (strong, nonatomic)NSMutableArray *tvListArr;
@property (strong, nonatomic)NSMutableArray *movieListArr;
@property (strong, nonatomic)NSMutableArray *showListArr;
@property (strong, nonatomic)UITableView *tvTableList;
@property (strong, nonatomic)UITableView *movieTableList;
@property (strong, nonatomic)UITableView *showTableList;
@end
