//
//  DownloadItem.h
//  yueshipin
//
//  Created by joyplus1 on 12-12-19.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLitePersistentObject.h"

@interface DownloadItem : SQLitePersistentObject

@property (nonatomic, strong)NSString *itemId;
@property (nonatomic, strong)NSString *imageUrl;
@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *fileName;
@property (nonatomic, assign)int type;
@property (nonatomic, assign)int percentage;
@property (nonatomic, strong)NSString *url;
@property (nonatomic, strong)NSString *downloadingStatus; // 0:开始 1: 暂停 2: 完成
@end
