//
//  ShowListViewController.h
//  yueshipin_ipad
//
//  Created by zhang zhipeng on 12-11-25.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericBaseViewController.h"

@interface SelectListViewController : GenericBaseViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)NSString *prodId;


@end
