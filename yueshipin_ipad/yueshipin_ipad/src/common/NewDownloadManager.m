//
//  DownloadManager.m
//  yueshipin
//
//  Created by joyplus1 on 13-1-31.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "NewDownloadManager.h"
#import "DownloadItem.h"
#import "CMConstants.h"
#import "AppDelegate.h"
#import "DownloadUrlFinder.h"
#import "ActionUtility.h"
#import "DatabaseManager.h"
#import "Reachability.h"
#import "StringUtility.h"
#import "CommonMotheds.h"

@interface NewDownloadManager () 
@property (nonatomic, strong)DownloadItem *downloadingItem;
@property (nonatomic, strong)AFDownloadRequestOperation *downloadingOperation;
@property (nonatomic) BOOL displayNoSpaceFlag;
@property (nonatomic, strong)NSArray *allDownloadItems;
@property (nonatomic, strong)NSArray *allSubdownloadItems;
@property (nonatomic, strong)NSLock *myLock;
@property (strong, nonatomic) NewM3u8DownloadManager *padM3u8DownloadManager;
@property NSInteger retryConut;
@property int netWorkStatus;
@end

@implementation NewDownloadManager
@synthesize downloadingItem, myLock;
@synthesize downloadingOperation;
@synthesize delegate, subdelegate;
@synthesize displayNoSpaceFlag;
@synthesize allDownloadItems, allSubdownloadItems;
@synthesize padM3u8DownloadManager;
@synthesize netWorkStatus,retryConut,retryCountInfo;
- (id)init
{
    self = [super init];
    if (self) {
        myLock = [[NSLock alloc]init];
        
        Reachability *hostReach = [Reachability reachabilityForInternetConnection];
        netWorkStatus = [hostReach currentReachabilityStatus];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChanged:) name:NETWORK_CHANGED object:nil];
        retryConut = 0;
        retryCountInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)startDownloadingThreads
{
    [myLock lock];
    
    for (id obj in [AppDelegate instance].curDownloadingTask)
    {
        if ([obj isKindOfClass:[NewM3u8DownloadManager class]])
        {
            NewM3u8DownloadManager *manager = (NewM3u8DownloadManager *)obj;
            [manager stopDownloading];
        }
        else
        {
            AFDownloadRequestOperation * reqOperation = (AFDownloadRequestOperation *)obj;
            [reqOperation pause];
            [reqOperation cancel];
        }
    }
    
    [[AppDelegate instance].curDownloadingTask removeAllObjects];
    
    if([AppDelegate instance].curDownloadingTask.count < MAX_DOWNLOADING_THREADS){
        allDownloadItems = [DatabaseManager allObjects:DownloadItem.class];
        allSubdownloadItems = [DatabaseManager allObjects:SubdownloadItem.class];
        [self startDownloadingThread:allDownloadItems status:@"start"];
        [self startDownloadingThread:allSubdownloadItems status:@"start"];
        [self startDownloadingThread:allDownloadItems status:@"waiting"];
        [self startDownloadingThread:allSubdownloadItems status:@"waiting"];
        displayNoSpaceFlag = NO;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_DOWNLOAD_ITEM_NUM object:nil];// update download badge
    if ([ActionUtility getReadyItemNumber] > 0) {
        [[NSNotificationCenter defaultCenter]postNotificationName:SYSTEM_IDLE_TIMER_DISABLED object:[NSNumber numberWithBool:YES]];
    } else {
        [[NSNotificationCenter defaultCenter]postNotificationName:SYSTEM_IDLE_TIMER_DISABLED object:[NSNumber numberWithBool:NO]];
    }
    [myLock unlock];
}

- (void)startDownloadingThread:(NSArray *)allItem status:(NSString *)status
{
    for (DownloadItem *item in allItem)
    {
        if([AppDelegate instance].curDownloadingTask.count < MAX_DOWNLOADING_THREADS)
        {
            if([item.downloadStatus isEqualToString:status])
            {
                downloadingItem = item;
                if ([item.downloadType isEqualToString:@"m3u8"])
                {
                    padM3u8DownloadManager = [[NewM3u8DownloadManager alloc]init];
                    if(item.type == 1){
                        padM3u8DownloadManager.delegate = delegate == nil ? self : delegate;
                        padM3u8DownloadManager.subdelegate = nil;
                    } else {
                        padM3u8DownloadManager.subdelegate = subdelegate == nil ? self : subdelegate;
                        padM3u8DownloadManager.delegate = nil;
                    }
                    //[AppDelegate instance].currentDownloadingNum ++;
                    [[AppDelegate instance].curDownloadingTask addObject:padM3u8DownloadManager];
                    [padM3u8DownloadManager startDownloadingThreads:item];
                }
                else
                {
                    if (![StringUtility stringIsEmpty:item.url])
                    {
                        item.downloadStatus = @"start";
                        [DatabaseManager update:item];
                        NSURL *url = [NSURL URLWithString:item.url];
                        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
                        
                        NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                        NSString *documentsDir = [documentPaths objectAtIndex:0];
                        NSString *filePath;
                        if (item.type == 1) {
                            filePath = [NSString stringWithFormat:@"%@/%@.mp4", documentsDir, item.itemId];
                        } else {
                            filePath = [NSString stringWithFormat:@"%@/%@_%@.mp4", documentsDir, item.itemId, ((SubdownloadItem *)item).subitemId];
                        }
                        AFDownloadRequestOperation *DLOperation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:filePath shouldResume:YES];
                        DLOperation.operationId = item.itemId;
                        if(item.type == 1){
                            DLOperation.downloadingDelegate = delegate == nil ? self : delegate;
                            DLOperation.isDownloadingType = 1;
                            DLOperation.subdownloadingDelegate = nil;
                            DLOperation.suboperationId = @"";
                        } else {
                            DLOperation.downloadingDelegate = nil;
                            DLOperation.isDownloadingType = 2;
                            DLOperation.subdownloadingDelegate = subdelegate == nil ? self : subdelegate;
                            DLOperation.suboperationId = ((SubdownloadItem *)item).subitemId;
                        }
                        
                        __block AFDownloadRequestOperation * afOperation = DLOperation;
                        [DLOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                            NSLog(@"Successfully downloaded file to %@", filePath);
                            downloadingOperation = afOperation;
                            if (afOperation.isDownloadingType == 1) {
                                [self downloadSuccess:afOperation.operationId];
                            } else {
                                [self downloadSuccess:afOperation.operationId suboperationId:afOperation.suboperationId];
                            }
                            //[self stopDownloading];
                            //[AppDelegate instance].currentDownloadingNum --;
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            NSLog(@"Download mp4 file error: %@", error);
                            [operation cancel];
                        }];
                        [DLOperation setProgressiveDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
                        }];
                        //[AppDelegate instance].currentDownloadingNum ++;
                        [[AppDelegate instance].curDownloadingTask addObject:DLOperation];
                        [DLOperation start];
                    }
                    else
                    {
                        if (![item.downloadStatus isEqualToString:@"error"]) {
                            DownloadUrlFinder *finder = [[DownloadUrlFinder alloc]init];
                            finder.item = item;
                            [finder setupWorkingUrl];
                        }
                    }
                    //break;
                }
            }
        }
    }
}

- (void)setDelegate:(id<DownloadingDelegate>)newdelegate
{
    delegate = newdelegate;
    if (downloadingItem.type == 1)
    {
        
        for (id obj in [AppDelegate instance].curDownloadingTask)
        {
            if (![obj isKindOfClass:[NewM3u8DownloadManager class]])
            {
                AFDownloadRequestOperation * DLOperation = (AFDownloadRequestOperation *)obj;
                [DLOperation setDownloadingDelegate: newdelegate];
                [DLOperation setSubdownloadingDelegate: nil];
            }
            else
            {
                NewM3u8DownloadManager *manager = (NewM3u8DownloadManager *)obj;
                manager.delegate = newdelegate;
            }
        }
    } 
}

- (void)setSubdelegate:(id<SubdownloadingDelegate>)newdelegate
{
    subdelegate = newdelegate;
    if (downloadingItem.type != 1)
    {
        for (id obj in [AppDelegate instance].curDownloadingTask)
        {
            if (![obj isKindOfClass:[NewM3u8DownloadManager class]])
            {
                AFDownloadRequestOperation * DLOperation = (AFDownloadRequestOperation *)obj;
                DLOperation.downloadingDelegate = nil;
                DLOperation.subdownloadingDelegate = newdelegate;
            }
            else
            {
                NewM3u8DownloadManager *manager = (NewM3u8DownloadManager *)obj;
                manager.subdelegate = newdelegate;
            }
        }
    }
}

- (void)downloadFailure:(NSString *)operationId error:(NSError *)error
{
    NSLog(@"error in download manager");
    if (![CommonMotheds isNetworkEnbled])
    {
        NSLog(@"网络异常");
        return;
    }
    
    NSInteger retryNum = 0;
    if ([retryCountInfo objectForKey:operationId])
    {
        retryNum = [[retryCountInfo objectForKey:operationId] intValue];
    }
    
    if (retryNum <= DOWNLOAD_FAIL_RETRY_TIME)
    {
        retryNum ++;
        [retryCountInfo setObject:[NSString stringWithFormat:@"%d",retryNum] forKey:operationId];
        //[self stopDownloading];
        [self performSelector:@selector(restartNewDownloading) withObject:nil afterDelay:DOWNLOAD_FAIL_RETRY_INTERVAL];
    }
    else
    {
        [retryCountInfo setObject:@"0" forKey:operationId];
        DownloadItem * dlItem = (DownloadItem *)[DatabaseManager findFirstByCriteria:DownloadItem.class queryString:[NSString stringWithFormat:@"where itemId = %@", operationId]];
        dlItem.downloadStatus = @"fail";
        [DatabaseManager update:dlItem];
        [self stopDownloading];
        [self startNewDownloadItem];
    }
}

- (void)restartNewDownloading
{
    //Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        //[AppDelegate instance].currentDownloadingNum = 0;
        [NSThread  detachNewThreadSelector:@selector(startDownloadingThreads) toTarget:[AppDelegate instance].padDownloadManager withObject:nil];
    }
}

- (void)downloadSuccess:(NSString *)operationId
{
    downloadingItem = (DownloadItem *)[DatabaseManager findFirstByCriteria:DownloadItem.class queryString:[NSString stringWithFormat:@"where itemId = %@", operationId]];
    downloadingItem.downloadStatus = @"done";
    downloadingItem.percentage = 100;
    [DatabaseManager update:downloadingItem];
    [self stopDownloading];
    [self startNewDownloadItem];
}

- (void)startNewDownloadItem
{
    //[AppDelegate instance].currentDownloadingNum = 0;
    [[AppDelegate instance].padDownloadManager startDownloadingThreads];
}

- (void)updateProgress:(NSString *)operationId progress:(float)progress
{
    [retryCountInfo setObject:@"0" forKey:operationId];
    downloadingItem = (DownloadItem *)[DatabaseManager findFirstByCriteria:DownloadItem.class queryString:[NSString stringWithFormat:@"where itemId = %@", operationId]];
    [self updateProgress:progress];
}

- (void)downloadFailure:(NSString *)operationId suboperationId:(NSString *)suboperationId error:(NSError *)error
{
    NSLog(@"error in download manager");
    if (![CommonMotheds isNetworkEnbled])
    {
        NSLog(@"网络异常");
        return;
    }
    
    NSInteger retryNum = 0;
    NSString * numberStr = [retryCountInfo objectForKey:[NSString stringWithFormat:@"%@_%@",operationId,suboperationId]];
    if (numberStr)
    {
        retryNum = [numberStr intValue];
    }
    
    if (retryNum <= DOWNLOAD_FAIL_RETRY_TIME)
    {
        retryNum ++;
        [retryCountInfo setObject:[NSString stringWithFormat:@"%d",retryNum] forKey:[NSString stringWithFormat:@"%@_%@",operationId,suboperationId]];
        //[self stopDownloading];
        [self performSelector:@selector(restartNewDownloading) withObject:nil afterDelay:DOWNLOAD_FAIL_RETRY_INTERVAL];
    }
    else
    {
        [retryCountInfo setObject:@"0" forKey:[NSString stringWithFormat:@"%@_%@",operationId,suboperationId]];
        downloadingItem = (SubdownloadItem *)[DatabaseManager findFirstByCriteria:SubdownloadItem.class queryString:[NSString stringWithFormat:@"where itemId = %@ and subitemId = '%@'", operationId, suboperationId]];
        downloadingItem.downloadStatus = @"fail";
        [DatabaseManager update:downloadingItem];
        [self stopDownloading];
        [self startNewDownloadItem];
    }
}

- (void)downloadSuccess:(NSString *)operationId suboperationId:(NSString *)suboperationId
{
    downloadingItem = (SubdownloadItem *)[DatabaseManager findFirstByCriteria:SubdownloadItem.class queryString:[NSString stringWithFormat:@"where itemId = %@ and subitemId = '%@'", operationId, suboperationId]];
    downloadingItem.downloadStatus = @"done";
    downloadingItem.percentage = 100;
    [DatabaseManager update:downloadingItem];
    [self stopDownloading];
    [self startNewDownloadItem];
}

- (void)updateProgress:(NSString *)operationId suboperationId:(NSString *)suboperationId progress:(float)progress
{
    [retryCountInfo setObject:@"0" forKey:[NSString stringWithFormat:@"%@_%@",operationId,suboperationId]];
    downloadingItem = (SubdownloadItem *)[DatabaseManager findFirstByCriteria:SubdownloadItem.class queryString:[NSString stringWithFormat:@"where itemId = %@ and subitemId = '%@'", operationId, suboperationId]];
    [self updateProgress:progress];
}

- (void)updateProgress:(float)progress
{
    int thisProgress = progress * 100;
    if (thisProgress < 1 && downloadingItem.percentage != 0) {
        downloadingItem.percentage = 0;
        [DatabaseManager update:downloadingItem];
    }
    if (thisProgress - downloadingItem.percentage > 5) {
        NSLog(@"percent in downloadmanager= %f", progress);
        downloadingItem.percentage = thisProgress;
        [DatabaseManager update:downloadingItem];
        [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_DISK_STORAGE object:nil];
    }
    float freeSpace = [ActionUtility getFreeDiskspace];
    if (freeSpace <= LEAST_DISK_SPACE) {
        [self stopDownloading];
        if (!displayNoSpaceFlag) {
            displayNoSpaceFlag = YES;
            [ActionUtility triggerSpaceNotEnough];
        }
    }
}

- (void)stopDownloading
{
    downloadingItem = nil;
//    [downloadingOperation pause];
//    [downloadingOperation cancel];
//    downloadingOperation = nil;
    for (id obj in [AppDelegate instance].curDownloadingTask)
    {
        if (![obj isKindOfClass:[NewM3u8DownloadManager class]])
        {
            AFDownloadRequestOperation * DLOperation = (AFDownloadRequestOperation *)obj;
            [DLOperation pause];
            [DLOperation cancel];
        }
        else
        {
            NewM3u8DownloadManager * m3u8Manager = (NewM3u8DownloadManager *)obj;
            [m3u8Manager stopDownloading];
        }
    }
//    [padM3u8DownloadManager stopDownloading];
}

- (float)getFreeDiskspace
{
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    float totalFreeSpace_ = 0;
    if (dictionary) {
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalFreeSpace_ = [freeFileSystemSizeInBytes floatValue]/1024.0f/1024.0f/1024.0f;
    }
    return totalFreeSpace_;
}

-(void)networkChanged:(NSNotification *)msg
{
    int status = [(NSNumber *)(msg.object) intValue];
    if (status == netWorkStatus) {
        return;
    }
    else{
        netWorkStatus = status;
        if(netWorkStatus == 0){ //no network
            [self stopDownloading];
        }
        else if(netWorkStatus == 1){ //3g ,2g
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            BOOL isSupport3GDownload = [[defaults objectForKey:@"isSupport3GDownload"] boolValue];
            if ([ActionUtility getReadyItemNumber] > 0)
            {
                if (isSupport3GDownload)
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"友情提示"
                                                                    message:@"你将使用2G/3G网络下载视频，若如此将会耗费大量的流量"
                                                                   delegate:self
                                                          cancelButtonTitle:@"取消"
                                                          otherButtonTitles:@"继续下载", nil];
                    alert.tag = 199;
                    [alert show];
                }
                else
                {
                    [self stopDownloading];
                    [ActionUtility updateDBAfterStopDownload];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateDownloadView"
                                                                        object:nil];
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"友情提示"
                                                                    message:@"wifi已断开，视频下载将中止，您可以在设置里将在2G/3G网络下载视频打开来继续下载"
                                                                   delegate:self
                                                          cancelButtonTitle:@"确定"
                                                          otherButtonTitles:nil, nil];
                    alert.tag = 299;
                    [alert show];
                    
                }
            }
            
        }
        else
        {
            //wifi
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 199) {
        
        if (buttonIndex == 0)
        {
            [self stopDownloading];
            [ActionUtility updateDBAfterStopDownload];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateDownloadView"
                                                                object:nil];
        }
        else if (buttonIndex == 1)
        {
            // 不做处理
        }
    }
}

+ (int)downloadingTaskCount
{
    int count = 0;
    for (DownloadItem *item in [DatabaseManager allObjects:[DownloadItem class]]) {
        if (([item.downloadStatus isEqualToString:@"waiting"]
             || [item.downloadStatus isEqualToString:@"start"])
            && ![item.downloadStatus isEqualToString:@""])
        {
            count ++;
        }
    }
    for (SubdownloadItem *item in [DatabaseManager allObjects:[SubdownloadItem class]])
    {
        if ([item.downloadStatus isEqualToString:@"waiting"]
            || [item.downloadStatus isEqualToString:@"start"])
        {
            count ++;
        }
    }
    return count;
}

@end
