//
//  ShowDownlooadViewController.h
//  yueshipin
//
//  Created by 08 on 13-1-25.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShowDownloadViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *listArr_;
    UITableView *tableList_;
    NSString *prodId_;
    NSString *imageviewUrl_;
    NSMutableArray *EpisodeIdArr_;
}
@property (nonatomic, strong) NSMutableArray *listArr;
@property (nonatomic, strong) UITableView *tableList;
@property (nonatomic, strong) NSString *prodId;
@property (nonatomic, strong) NSString *imageviewUrl;
@property (nonatomic, strong) NSMutableArray *EpisodeIdArr;
@end
