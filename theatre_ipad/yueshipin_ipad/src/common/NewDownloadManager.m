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

@interface NewDownloadManager () 
@property (nonatomic, strong)DownloadItem *downloadingItem;
@property (nonatomic, strong)AFDownloadRequestOperation *downloadingOperation;
@property (nonatomic) BOOL displayNoSpaceFlag;
@property (nonatomic, strong)NSArray *allDownloadItems;
@property (nonatomic, strong)NSArray *allSubdownloadItems;
@property (nonatomic, strong)NSLock *myLock;
@property (strong, nonatomic) NewM3u8DownloadManager *padM3u8DownloadManager;
@property (nonatomic, assign) int netWorkStatus;
@end

@implementation NewDownloadManager
@synthesize downloadingItem, myLock;
@synthesize downloadingOperation;
@synthesize delegate, subdelegate;
@synthesize displayNoSpaceFlag;
@synthesize allDownloadItems, allSubdownloadItems;
@synthesize padM3u8DownloadManager;
@synthesize netWorkStatus;
- (id)init
{
    self = [super init];
    if (self) {
        myLock = [[NSLock alloc]init];
        Reachability *hostReach = [Reachability reachabilityForInternetConnection];
        netWorkStatus = [hostReach currentReachabilityStatus];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChanged:) name:NETWORK_CHANGED object:nil];
    }
    return self;
}

- (void)startDownloadingThreads
{
    [myLock lock];
    if([AppDelegate instance].currentDownloadingNum < MAX_DOWNLOADING_THREADS){
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
    for (DownloadItem *item in allItem) {
        if([AppDelegate instance].currentDownloadingNum < MAX_DOWNLOADING_THREADS){
            if([item.downloadStatus isEqualToString:status]){
                downloadingItem = item;
                if ([item.downloadType isEqualToString:@"m3u8"]) {
                    padM3u8DownloadManager = [[NewM3u8DownloadManager alloc]init];
                    if(item.type == 1){
                        padM3u8DownloadManager.delegate = delegate == nil ? self : delegate;
                        padM3u8DownloadManager.subdelegate = nil;
                    } else {
                        padM3u8DownloadManager.subdelegate = subdelegate == nil ? self : subdelegate;
                        padM3u8DownloadManager.delegate = nil;
                    }
                    [padM3u8DownloadManager startDownloadingThreads:item];
                } else {
                    if (![StringUtility stringIsEmpty:item.url]) {
                        [AppDelegate instance].currentDownloadingNum++;
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
                        downloadingOperation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:filePath shouldResume:YES];
                        downloadingOperation.operationId = item.itemId;
                        if(item.type == 1){
                            downloadingOperation.downloadingDelegate = delegate == nil ? self : delegate;
                            downloadingOperation.isDownloadingType = 1;
                            downloadingOperation.subdownloadingDelegate = nil;
                            downloadingOperation.suboperationId = @"";
                        } else {
                            downloadingOperation.downloadingDelegate = nil;
                            downloadingOperation.isDownloadingType = 2;
                            downloadingOperation.subdownloadingDelegate = subdelegate == nil ? self : subdelegate;
                            downloadingOperation.suboperationId = ((SubdownloadItem *)item).subitemId;
                        }
                        
                        [downloadingOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                            NSLog(@"Successfully downloaded file to %@", filePath);
                            if (downloadingItem.type == 1) {
                                [self downloadSuccess:downloadingItem.itemId];
                            } else {
                                [self downloadSuccess:downloadingItem.itemId suboperationId:((SubdownloadItem *)downloadingItem).subitemId];
                            }
                            [self stopDownloading];
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            NSLog(@"Error: %@", error);
                            [operation cancel];
                        }];
                        [downloadingOperation setProgressiveDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
                        }];
                        [downloadingOperation start];
                    } else {
                        if (![item.downloadStatus isEqualToString:@"error"]) {
                            DownloadUrlFinder *finder = [[DownloadUrlFinder alloc]init];
                            finder.item = item;
                            [finder setupWorkingUrl];
                        }
                    }
                    break;
                }
            }
        }
    }
}

- (void)setDelegate:(id<DownloadingDelegate>)newdelegate
{
    delegate = newdelegate;
    if (downloadingItem.type == 1) {
        [downloadingOperation setDownloadingDelegate: newdelegate];
        [downloadingOperation setSubdownloadingDelegate: nil];
        padM3u8DownloadManager.delegate = newdelegate;
    } 
}

- (void)setSubdelegate:(id<SubdownloadingDelegate>)newdelegate
{
    subdelegate = newdelegate;
    if (downloadingItem.type != 1) {
        downloadingOperation.downloadingDelegate = nil;
        downloadingOperation.subdownloadingDelegate = newdelegate;
        padM3u8DownloadManager.subdelegate = newdelegate;
    }
}

- (void)downloadFailure:(NSString *)operationId error:(NSError *)error
{
    NSLog(@"error in download manager");
    [self stopDownloading];
    [self performSelector:@selector(restartNewDownloading) withObject:nil afterDelay:10];
}

- (void)restartNewDownloading
{
    //Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [AppDelegate instance].currentDownloadingNum = 0;
        [NSThread  detachNewThreadSelector:@selector(startDownloadingThreads) toTarget:[AppDelegate instance].padDownloadManager withObject:nil];
    }
}

- (void)downloadSuccess:(NSString *)operationId
{
    downloadingItem = (DownloadItem *)[DatabaseManager findFirstByCriteria:DownloadItem.class queryString:[NSString stringWithFormat:@"where itemId = %@", downloadingItem.itemId]];
    downloadingItem.downloadStatus = @"done";
    downloadingItem.percentage = 100;
    [DatabaseManager update:downloadingItem];
    [self stopDownloading];
    [self startNewDownloadItem];
}

- (void)startNewDownloadItem
{
    [AppDelegate instance].currentDownloadingNum = 0;
    [[AppDelegate instance].padDownloadManager startDownloadingThreads];
}

- (void)updateProgress:(NSString *)operationId progress:(float)progress
{
    [self updateProgress:progress];
}

- (void)downloadFailure:(NSString *)operationId suboperationId:(NSString *)suboperationId error:(NSError *)error
{
    NSLog(@"error in download manager");
    [self stopDownloading];
    [self performSelector:@selector(restartNewDownloading) withObject:nil afterDelay:10];
}

- (void)downloadSuccess:(NSString *)operationId suboperationId:(NSString *)suboperationId
{
    SubdownloadItem *tempDownloadingItem = (SubdownloadItem *)downloadingItem;
    tempDownloadingItem = (SubdownloadItem *)[DatabaseManager findFirstByCriteria:SubdownloadItem.class queryString:[NSString stringWithFormat:@"where itemId = %@ and subitemId = '%@'", tempDownloadingItem.itemId, tempDownloadingItem.subitemId]];
    tempDownloadingItem.downloadStatus = @"done";
    tempDownloadingItem.percentage = 100;
    [DatabaseManager update:tempDownloadingItem];
    [self stopDownloading];
    [self startNewDownloadItem];
}

- (void)updateProgress:(NSString *)operationId suboperationId:(NSString *)suboperationId progress:(float)progress
{
    [self updateProgress:progress];
}

- (void)updateProgress:(float)progress
{
    if(downloadingItem.class == DownloadItem.class) {
        downloadingItem = (DownloadItem *)[DatabaseManager findFirstByCriteria:DownloadItem.class queryString:[NSString stringWithFormat:@"where itemId = %@", downloadingItem.itemId]];
    } else if (downloadingItem.class == SubdownloadItem.class) {
        downloadingItem = (SubdownloadItem *)[DatabaseManager findFirstByCriteria:SubdownloadItem.class queryString:[NSString stringWithFormat:@"where itemId = %@ and subitemId = '%@'", downloadingItem.itemId, ((SubdownloadItem *)downloadingItem).subitemId]];
    }
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
    [downloadingOperation pause];
    [downloadingOperation cancel];
    downloadingOperation = nil;
    [padM3u8DownloadManager stopDownloading];
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
