//
//  ItemDetailViewController.h
//  yueshipin
//
//  Created by 08 on 12-12-25.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemDetailViewController : UITableViewController{
    NSDictionary *infoDic_;
    NSDictionary *videoInfo_;
    NSArray *episodesArr_;
}
@property (nonatomic, strong) NSDictionary *infoDic;
@property (nonatomic, strong) NSDictionary *videoInfo;
@property (nonatomic, strong) NSArray *episodesArr;
@end
