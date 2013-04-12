//
//  DownloadItem.h
//  yueshipin
//
//  Created by joyplus1 on 12-12-19.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseObject.h"
@interface DownloadItem : DatabaseObject

@property (nonatomic) int rowId;
@property (nonatomic, strong)NSString *itemId;
@property (nonatomic, strong)NSString *imageUrl;
@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *fileName;
@property (nonatomic, strong)NSString *downloadStatus; // start:开始 stop: 暂停 done: 完成 error:错误
@property (nonatomic, assign)int type;
@property (nonatomic, assign)int percentage;
@property (nonatomic, strong)NSArray *urlArray;
@property (nonatomic, strong)NSString *url;
@property (nonatomic) int isDownloadingNum;
@property (nonatomic, strong) NSString *downloadType;
@property (nonatomic) double duration;
@end
