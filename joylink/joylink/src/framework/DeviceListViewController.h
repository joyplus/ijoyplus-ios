//
//  DeviceListViewController.h
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-21.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericBaseViewController.h"
#import "HomeViewController.h"

@interface DeviceListViewController : GenericBaseViewController

@property (nonatomic, strong)NSArray *serverArray;
@property (nonatomic, strong)UITableView *table;
@property (nonatomic, weak)id<HomeViewControllerDelegate>delegate;
@end
