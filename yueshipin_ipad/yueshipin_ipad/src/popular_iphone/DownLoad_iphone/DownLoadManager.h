//
//  DownLoadManager.h
//  yueshipin
//
//  Created by 08 on 13-1-17.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SubdownloadItem.h"
@protocol DownloadManagerDelegate <NSObject>

-(void)downloadBeginwithId:(NSString *)itemId inClass:(NSString *)className;
- (void)reFreshProgress:(double)progress withId:(NSString *)itemId inClass:(NSString *)className;
- (void)downloadFailedwithId:(NSString *)itemId inClass:(NSString *)className;
-(void)downloadFinishwithId:(NSString *)itemId inClass:(NSString *)className;
@end

@interface DownLoadManager : NSObject{
   // id <DownloadManagerDelegate>downLoadMGdelegate_;
    NSThread *downloadThread_;
    NSString *downloadId_;
    NSArray *allItems_;
    NSArray *allSubItems_;
    DownloadItem *downloadItem_;
    SubdownloadItem *subdownloadItem_;
    int preProgress_;
}
@property (nonatomic, weak) id<DownloadManagerDelegate>downLoadMGdelegate;
@property (nonatomic, strong)NSThread *downloadThread;
@property (nonatomic, strong)NSString *downloadId;
@property (nonatomic, strong)NSArray *allItems;
@property (nonatomic, strong)NSArray *allSubItems;
@property (nonatomic, strong)DownloadItem *downloadItem;
@property (nonatomic, strong)SubdownloadItem *subdownloadItem;
+(DownLoadManager *)defaultDownLoadManager;

-(void)resumeDownLoad;

+(void)stopAndClear:(NSString *)downloadId;

+(void)stop:(NSString *)downloadId;

+(void)continueDownload:(NSString *)downloadId;

+(int)downloadTaskCount;
@end
