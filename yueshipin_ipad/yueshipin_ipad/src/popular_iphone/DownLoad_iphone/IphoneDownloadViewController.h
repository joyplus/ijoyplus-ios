//
//  IphoneDownloadViewController.h
//  yueshipin
//
//  Created by 08 on 13-1-21.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMGridView.h"
#import "DDProgressView.h"
#import "DownLoadManager.h"
@interface IphoneDownloadViewController : UIViewController<GMGridViewDataSource, GMGridViewActionDelegate,DownloadManagerDelegate>{
    __gm_weak GMGridView *gMGridView_;
    UIBarButtonItem *editButtonItem_;
    UIBarButtonItem *doneButtonItem_;
    NSMutableArray *itemArr_;
    NSMutableDictionary *progressLabelDic_;
    NSMutableDictionary *progressViewDic_;
    DDProgressView *diskUsedProgress_;
    float totalSpace_;
    float totalFreeSpace_;
    DownLoadManager *downLoadManager_;
    UIImageView *noItemView_;
}
@property (nonatomic, strong)UIBarButtonItem *editButtonItem;
@property (nonatomic, strong)UIBarButtonItem *doneButtonItem;
@property (nonatomic, strong)NSMutableArray *itemArr;
@property (nonatomic, strong)NSMutableDictionary *progressViewDic;
@property (nonatomic, strong)NSMutableDictionary *progressLabelDic;
@property (nonatomic, strong)DDProgressView *diskUsedProgress;
@property (nonatomic, strong)DownLoadManager *downLoadManager;
@property (nonatomic, strong) UIImageView *noItemView;
@end
