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

@interface NewDownloadManager () 
@property (nonatomic, strong)DownloadItem *downloadingItem;
@property (nonatomic, strong)AFDownloadRequestOperation *downloadingOperation;
@property (nonatomic)float previousProgress;
@property (nonatomic) BOOL displayNoSpaceFlag;
@end

@implementation NewDownloadManager
@synthesize downloadingItem;
@synthesize downloadingOperation;
@synthesize delegate, subdelegate;
@synthesize previousProgress, displayNoSpaceFlag;

- (void)startDownloadingThreads
{
    [self startDownloadingThread:[AppDelegate instance].downloadItems type:@"start"];
    [self startDownloadingThread:[AppDelegate instance].subdownloadItems type:@"start"];
    [self startDownloadingThread:[AppDelegate instance].downloadItems type:@"waiting"];
    [self startDownloadingThread:[AppDelegate instance].subdownloadItems type:@"waiting"];
    [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_MENU_ITEM object:nil];// update download badge
    displayNoSpaceFlag = NO;
}

- (void)startDownloadingThread:(NSArray *)allItem type:(NSString *)type
{
    if([AppDelegate instance].currentDownloadingNum < MAX_DOWNLOADING_THREADS){
        for (DownloadItem *item in allItem) {
            if([item.downloadStatus isEqualToString:type]){
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

- (void)setDelegate:(id<DownloadingDelegate>)newdelegate
{
    delegate = newdelegate;
    downloadingOperation.downloadingDelegate = newdelegate;
}

- (void)setSubdelegate:(id<SubdownloadingDelegate>)newdelegate
{
    subdelegate = newdelegate;
    downloadingOperation.subdownloadingDelegate = newdelegate;
}

- (void)downloadFailure:(NSString *)operationId error:(NSError *)error
{
    NSLog(@"error in download manager");
    [self stopDownloading];
    [AppDelegate instance].currentDownloadingNum--;
    if([AppDelegate instance].currentDownloadingNum < 0){
        [AppDelegate instance].currentDownloadingNum = 0;
    }
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
    [downloadingOperation pause];
    [downloadingOperation cancel];
    [downloadingItem save];
    [self startNewDownloadItem];
}

- (void)startNewDownloadItem
{
    [AppDelegate instance].currentDownloadingNum--;
    if([AppDelegate instance].currentDownloadingNum < 0){
        [AppDelegate instance].currentDownloadingNum = 0;
    }
    [[AppDelegate instance].padDownloadManager startDownloadingThreads];    
}

- (void)updateProgress:(NSString *)operationId progress:(float)progress
{
    [self updateProgress:progress downloadingArray:[AppDelegate instance].downloadItems];
}

- (void)downloadFailure:(NSString *)operationId suboperationId:(NSString *)suboperationId error:(NSError *)error
{
    NSLog(@"error in download manager");
    [self stopDownloading];
    [AppDelegate instance].currentDownloadingNum--;
    if([AppDelegate instance].currentDownloadingNum < 0){
        [AppDelegate instance].currentDownloadingNum = 0;
    }
//    for (int i = 0; i < [AppDelegate instance].subdownloadItems.count; i++) {
//        SubdownloadItem *tempitem = [[AppDelegate instance].subdownloadItems objectAtIndex:i];
//        if ([tempitem.itemId isEqualToString:operationId] && [suboperationId isEqualToString:tempitem.subitemId]) {
//            tempitem.downloadStatus = @"stop";
//            [tempitem save];
//            break;
//        }
//    }
//    [self startNewDownloadItem];
}

- (void)downloadSuccess:(NSString *)operationId suboperationId:(NSString *)suboperationId
{
    [self downloadSuccess:operationId];
}

- (void)updateProgress:(NSString *)operationId  suboperationId:(NSString *)suboperationId progress:(float)progress
{
    [self updateProgress:progress downloadingArray:[AppDelegate instance].subdownloadItems];
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
    float freeSpace = [self getFreeDiskspace];
    if (freeSpace <= LEAST_DISK_SPACE) {
        [self stopDownloading];
        for (DownloadItem *item in downloadingArray) {
            if ([item.downloadStatus isEqualToString:@"start"] || [item.downloadStatus isEqualToString:@"waiting"]) {
                item.downloadStatus = @"stop";
                [item save];
                if (!displayNoSpaceFlag) {
                    displayNoSpaceFlag = YES;
                    [[NSNotificationCenter defaultCenter]postNotificationName:NO_ENOUGH_SPACE object:nil];
                }
            }
        }
    }
}

- (void)stopDownloading
{
    [downloadingOperation pause];
    [downloadingOperation cancel];
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
