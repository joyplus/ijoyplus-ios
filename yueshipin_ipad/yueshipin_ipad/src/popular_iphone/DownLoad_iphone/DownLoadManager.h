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
@end


@protocol M3u8DownLoadManagerDelegate <NSObject>
- (void)M3u8DownLoadreFreshProgress:(double)progress withId:(NSString *)itemId inClass:(NSString *)className;
- (void)M3u8DownLoadFailedwithId:(NSString *)itemId inClass:(NSString *)className;
-(void)M3u8DownLoadFinishwithId:(NSString *)itemId inClass:(NSString *)className;
@end

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
    
}
@property (nonatomic, weak) id<DownloadManagerDelegate>downLoadMGdelegate;
@property (nonatomic, strong)NSThread *downloadThread;
@property (nonatomic, strong)NSString *downloadId;
@property (nonatomic, strong)NSArray *allItems;
@property (nonatomic, strong)NSArray *allSubItems;
@property (nonatomic, strong)DownloadItem *downloadItem;
@property (nonatomic, strong)SubdownloadItem *subdownloadItem;
@property (nonatomic, strong)NSLock *lock;
//@property (nonatomic, strong) NSString *fileType;
+(DownLoadManager *)defaultDownLoadManager;

-(void)resumeDownLoad;

+(void)stopAndClear:(NSString *)downloadId;

+(void)stop:(NSString *)downloadId;

+(void)continueDownload:(NSString *)downloadId;

+(int)downloadTaskCount;

-(void)restartDownload;

-(void)appDidEnterBackground;

-(void)appDidEnterForeground;

-(void)networkChanged:(int)status;
@end




@interface M3u8DownLoadManager : NSObject{
    NSOperationQueue *downloadOperationQueue_;
    int url_index;
   
}
@property (nonatomic, strong) NSOperationQueue *downloadOperationQueue;

@property (nonatomic, weak) id<M3u8DownLoadManagerDelegate>m3u8DownLoadManagerDelegate;
-(void)stop;

-(void)setM3u8DownloadData:(NSString *)prodId withNum:(NSString *)num url:(NSString *)urlStr withOldPath:(NSString *)oldPath;

-(void)startDownloadM3u8file:(NSArray *)urlArr withId:(NSString *)idStr withNum:(NSString *)num;
@end