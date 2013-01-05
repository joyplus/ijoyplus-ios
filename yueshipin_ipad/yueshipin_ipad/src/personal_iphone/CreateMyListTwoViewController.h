//
//  CreateMyListTwoViewController.h
//  yueshipin
//
//  Created by 08 on 13-1-5.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateMyListTwoViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    UITableView *tableList_;
    NSMutableArray *listArr_;
    NSMutableDictionary *infoDic_;
    NSString *topicId_;
}
@property (nonatomic, strong)UITableView *tableList;
@property (nonatomic, strong)NSMutableArray *listArr;
@property (nonatomic, strong)NSMutableDictionary *infoDic;
@property (nonatomic, strong)NSString *topicId;
@end
