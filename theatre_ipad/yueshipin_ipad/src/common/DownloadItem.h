//
//  DownloadItem.h
//  yueshipin
//
//  Created by joyplus1 on 12-12-19.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseObject.h"

#define MIN_MP4_FILE_SIZE   (500 * 1024)
#define MAX_M3U8_FILE_SIZE  (500 * 1024)

#define DOWNLOAD_FAIL_RETRY_INTERVAL    (10)
#define DOWNLOAD_FAIL_RETRY_TIME        (5)

#define CONCURRENT_COUNT    (2)

@interface DownloadItem : DatabaseObject

- (id)init;

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
@property (nonatomic, strong) NSMutableArray * m3u8DownloadInfo;
@property (nonatomic, strong) NSString *downloadType;
@property (nonatomic) double duration;
@property (nonatomic, strong)NSString *downloadURLSource;
@property int mp4SourceNum;

@end
