//
//  YueSouViewController.h
//  yueshipin
//
//  Created by huokun on 13-9-9.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YueSouViewCell.h"
@interface YueSouViewController : UIViewController <UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,YueSouViewCellDelegate>
{
    UISearchBar * searchBar_;
    UITableView * table_;
    UITableView * historyTable_;
}

@end
