//
//  IphoneSubdownloadViewController.h
//  yueshipin
//
//  Created by 08 on 13-1-22.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMGridView.h"
#import "DownLoadManager.h"
@interface IphoneSubdownloadViewController : UIViewController<GMGridViewDataSource, GMGridViewActionDelegate,DownloadManagerDelegate,UIAlertViewDelegate>{
    __gm_weak GMGridView *gMGridView_;
    UIBarButtonItem *editButtonItem_;
    UIBarButtonItem *doneButtonItem_;
    NSString *prodId_;
    NSMutableArray *itemArr_;
    NSURL *imageUrl_;
    
    NSMutableDictionary *progressLabelDic_;
    NSMutableDictionary *progressViewDic_;
    DownLoadManager *downLoadManager_;
}

@property (nonatomic, strong)UIBarButtonItem *editButtonItem;
@property (nonatomic, strong)UIBarButtonItem *doneButtonItem;
@property (nonatomic, strong)NSString *prodId;
@property (nonatomic, strong)NSMutableArray *itemArr;
@property (nonatomic, strong)NSURL *imageUrl;
@property (nonatomic, strong) NSMutableDictionary *progressViewDic;
@property (nonatomic, strong) NSMutableDictionary *progressLabelDic;
@end
