//
//  ShowDownlooadViewController.h
//  yueshipin
//
//  Created by 08 on 13-1-25.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShowDownlooadViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *listArr_;
    UITableView *tableList_;
    NSString *prodId_;
    NSString *imageviewUrl_;
    NSMutableArray *EpisodeIdArr_;
    NSString *download_file_type_;
}
@property (nonatomic, strong) NSMutableArray *listArr;
@property (nonatomic, strong) UITableView *tableList;
@property (nonatomic, strong) NSString *prodId;
@property (nonatomic, strong) NSString *imageviewUrl;
@property (nonatomic, strong) NSMutableArray *EpisodeIdArr;
@property (nonatomic, strong) NSString *download_file_type;
@end
