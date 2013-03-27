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

@interface NewDownloadManager () 
@property (nonatomic, strong)DownloadItem *downloadingItem;
@property (nonatomic, strong)AFDownloadRequestOperation *downloadingOperation;
@property (nonatomic)float previousProgress;
@property (nonatomic) BOOL displayNoSpaceFlag;
@property (nonatomic, strong)NSArray *allDownloadItems;
@property (nonatomic, strong)NSArray *allSubdownloadItems;
@end

@implementation NewDownloadManager
@synthesize downloadingItem;
@synthesize downloadingOperation;
@synthesize delegate, subdelegate;
@synthesize previousProgress, displayNoSpaceFlag;
@synthesize allDownloadItems, allSubdownloadItems;

- (void)startDownloadingThreads
{
    if([AppDelegate instance].currentDownloadingNum < MAX_DOWNLOADING_THREADS){
        allDownloadItems = [DownloadItem allObjects];
        allSubdownloadItems = [SubdownloadItem allObjects];
        [self startDownloadingThread:allDownloadItems status:@"start"];
        [self startDownloadingThread:allSubdownloadItems status:@"start"];
        [self startDownloadingThread:allDownloadItems status:@"waiting"];
        [self startDownloadingThread:allSubdownloadItems status:@"waiting"];
        [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_MENU_ITEM object:nil];// update download badge
        displayNoSpaceFlag = NO;
    }
}

- (void)startDownloadingThread:(NSArray *)allItem status:(NSString *)status
{
    for (DownloadItem *item in allItem) {
        if([AppDelegate instance].currentDownloadingNum < MAX_DOWNLOADING_THREADS){
            if([item.downloadStatus isEqualToString:status]){
                if ([item.downloadType isEqualToString:@"m3u8"]) {
                    if(item.type == 1){
                        [AppDelegate instance].padM3u8DownloadManager.delegate = delegate == nil ? self : delegate;
                    } else {
                        [AppDelegate instance].padM3u8DownloadManager.subdelegate = subdelegate == nil ? self : subdelegate;
                    }
                    [[AppDelegate instance].padM3u8DownloadManager startDownloadingThreads:item];
                } else {
                    if (item.url) {
                        [AppDelegate instance].currentDownloadingNum++;
                        item.downloadStatus = @"start";
                        [item save];
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
                            downloadingOperation.suboperationId = @"";
                        } else {
                            downloadingOperation.subdownloadingDelegate = subdelegate == nil ? self : subdelegate;
                            downloadingOperation.suboperationId = ((SubdownloadItem *)item).subitemId;
                        }
                        
                        [downloadingOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                            NSLog(@"Successfully downloaded file to %@", filePath);
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            NSLog(@"Error: %@", error);
                            [operation cancel];
                        }];
                        [downloadingOperation setProgressiveDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
                        }];
                        previousProgress = 0;
                        downloadingItem = item;
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
    downloadingOperation.downloadingDelegate = newdelegate;
    [AppDelegate instance].padM3u8DownloadManager.delegate = newdelegate;
}

- (void)setSubdelegate:(id<SubdownloadingDelegate>)newdelegate
{
    subdelegate = newdelegate;
    downloadingOperation.subdownloadingDelegate = newdelegate;
    [AppDelegate instance].padM3u8DownloadManager.subdelegate = newdelegate;
}

- (void)downloadFailure:(NSString *)operationId error:(NSError *)error
{
    NSLog(@"error in download manager");
    [self stopDownloading];
    [AppDelegate instance].currentDownloadingNum = 0;
    //    for (int i = 0; i < [AppDelegate instance].downloadItems.count; i++) {
//        DownloadItem *item = [[AppDelegate instance].downloadItems objectAtIndex:i];
//        if (item.type == 1 && [item.itemId isEqualToString:operationId]) {
//            item.downloadStatus = @"stop";
//            [item save];
//            break;
//        }
//    }
//    [self startNewDownloadItem];
}

- (void)downloadSuccess:(NSString *)operationId
{
    downloadingItem.downloadStatus = @"done";
    downloadingItem.percentage = 100;
    [downloadingItem save];
    [downloadingOperation pause];
    [downloadingOperation cancel];
    [self startNewDownloadItem];
}

- (void)startNewDownloadItem
{
    [AppDelegate instance].currentDownloadingNum = 0;
    [[AppDelegate instance].padDownloadManager startDownloadingThreads];
}

- (void)updateProgress:(NSString *)operationId progress:(float)progress
{
    [self updateProgress:progress downloadingArray:allDownloadItems];
}

- (void)downloadFailure:(NSString *)operationId suboperationId:(NSString *)suboperationId error:(NSError *)error
{
    NSLog(@"error in download manager");
    [self stopDownloading];
    [AppDelegate instance].currentDownloadingNum = 0;
}

- (void)downloadSuccess:(NSString *)operationId suboperationId:(NSString *)suboperationId
{
    if([downloadingItem isKindOfClass:[SubdownloadItem class]]){
        SubdownloadItem *tempDownloadingItem = (SubdownloadItem *)downloadingItem;
        tempDownloadingItem.downloadStatus = @"done";
        tempDownloadingItem.percentage = 100;
        [tempDownloadingItem save];
    }
    [downloadingOperation pause];
    [downloadingOperation cancel];
    [self startNewDownloadItem];        
}

- (void)updateProgress:(NSString *)operationId suboperationId:(NSString *)suboperationId progress:(float)progress
{
    [self updateProgress:progress downloadingArray:allSubdownloadItems];
}

- (void)updateProgress:(float)progress downloadingArray:(NSArray *)downloadingArray
{
    if (progress * 100 - previousProgress * 100 > 5) {
        NSLog(@"percent in downloadmanager= %f", progress);
        previousProgress = progress;
        downloadingItem.percentage = progress;
        [downloadingItem save];
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
    [downloadingOperation pause];
    [downloadingOperation cancel];
    [[AppDelegate instance].padM3u8DownloadManager stopDownloading];
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

@end
