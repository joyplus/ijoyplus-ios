//
//  DownLoadManager.h
//  yueshipin
//
//  Created by 08 on 13-1-17.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SubdownloadItem.h"
#import "AFDownloadRequestOperation.h"
@protocol DownloadManagerDelegate <NSObject>

-(void)downloadBeginwithId:(NSString *)itemId inClass:(NSString *)className;
- (void)reFreshProgress:(double)progress withId:(NSString *)itemId inClass:(NSString *)className;
- (void)downloadFailedwithId:(NSString *)itemId inClass:(NSString *)className;
-(void)downloadFinishwithId:(NSString *)itemId inClass:(NSString *)className;
-(void)downloadUrlTnvalidWithId:(NSString *)itemId inClass:(NSString *)className;
-(void)updateFreeSapceWithTotalSpace:(float)total UsedSpace:(float)used;
-(void)reFreshUI;
@end


@protocol M3u8DownLoadManagerDelegate <NSObject>
- (void)M3u8DownLoadreFreshProgress:(double)progress withId:(NSString *)itemId inClass:(NSString *)className;
- (void)M3u8DownLoadFailedwithId:(NSString *)itemId inClass:(NSString *)className;
-(void)M3u8DownLoadFinishwithId:(NSString *)itemId inClass:(NSString *)className;
@end


@class CheckDownloadUrlsManager;
@interface DownLoadManager : NSObject<M3u8DownLoadManagerDelegate>{
    NSThread *downloadThread_;
    NSString *downloadId_;
    NSArray *allItems_;
    NSArray *allSubItems_;
    DownloadItem *downloadItem_;
    SubdownloadItem *subdownloadItem_;
    int preProgress_;
    int netWorkStatus;
    NSLock *lock_;
    int retryCount_;
    NSTimer *retryTimer_;
}
@property (nonatomic, weak) id<DownloadManagerDelegate>downLoadMGdelegate;
@property (nonatomic, strong)NSThread *downloadThread;
@property (nonatomic, strong)NSString *downloadId;
@property (nonatomic, strong)NSArray *allItems;
@property (nonatomic, strong)NSArray *allSubItems;
@property (nonatomic, strong)DownloadItem *downloadItem;
@property (nonatomic, strong)SubdownloadItem *subdownloadItem;
@property (nonatomic, strong)NSLock *lock;
@property (nonatomic, assign)BOOL isResetLoading;
@property (nonatomic, strong)NSTimer *retryTimer;
+(DownLoadManager *)defaultDownLoadManager;

-(void)resumeDownLoad;

+(void)stopAndClear:(NSString *)downloadId;

+(void)stop:(NSString *)downloadId;

+(void)continueDownload:(NSString *)downloadId;

+(int)downloadTaskCount;

+ (int)downloadingTaskCount;

-(void)pauseAllTask;

-(void)appDidEnterForeground;

//-(void)networkChanged:(int)status;

-(void)waringPlus;
-(void)waringReduce;
@end




@interface M3u8DownLoadManager : NSObject{
    NSOperationQueue *downloadOperationQueue_;
    int url_index;
    DownloadItem *currentItem_;
    NSMutableArray *segmentUrlArray_;
    int retryCount_;
    NSTimer *retryTimer_;
}
@property (nonatomic, strong) NSOperationQueue *downloadOperationQueue;

@property (nonatomic, weak) id<M3u8DownLoadManagerDelegate>m3u8DownLoadManagerDelegate;

@property (nonatomic, strong)DownloadItem *currentItem;

@property (nonatomic, strong)  NSMutableArray *segmentUrlArray;

@property (nonatomic, strong)  NSTimer *retryTimer;
-(void)stop;

-(void)saveCurrentInfo;

-(void)setM3u8DownloadData:(NSString *)prodId withNum:(NSString *)num url:(NSString *)urlStr withOldPath:(NSString *)oldPath;

-(void)startDownloadM3u8file:(NSArray *)urlArr withId:(NSString *)idStr withNum:(NSString *)num;

@end

@protocol CheckDownloadUrlsDelegate <NSObject>
-(void)checkUrlsFinishWithId:(int)taskId;
@end

@interface CheckDownloadUrls : NSObject{
    NSArray *downloadInfoArr_;
   int sendCount_;
    NSString *fileType_;
    NSMutableArray *allUrls_;
    NSURLConnection *currentConnection_;
    NSDictionary *oneEsp_;
    NSDictionary *defaultUrlInfo_;
}
@property (nonatomic, weak) id <CheckDownloadUrlsDelegate> checkDownloadUrlsDelegate;
@property (nonatomic, strong) NSArray *downloadInfoArr;
@property (nonatomic, strong) NSString *fileType;
@property (nonatomic, strong) NSMutableArray *allUrls;
@property (nonatomic, strong) NSURLConnection *currentConnection;
@property (nonatomic, strong) NSDictionary *oneEsp;
@property (nonatomic, assign) int checkIndex;
@property (nonatomic, strong)  NSDictionary *defaultUrlInfo;
-(void)checkDownloadUrls;
@end

@interface CheckDownloadUrlsManager : NSObject<CheckDownloadUrlsDelegate>
@property (nonatomic, assign)BOOL isDone;
+(CheckDownloadUrlsManager *)defaultCheckDownloadUrlsManager;
+(void)addToCheckQueue:(CheckDownloadUrls *)check;
@end