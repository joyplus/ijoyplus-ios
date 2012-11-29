//
//  SearchListViewController.h
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-29.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "GenericBaseViewController.h"

@interface SearchListViewController : GenericBaseViewController<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong)NSString *keyword;
@end
