//
//  DownloadManager.m
//  yueshipin
//
//  Created by joyplus1 on 13-1-31.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "NewM3u8DownloadManager.h"
#import "CMConstants.h"
#import "EnvConstant.h"
#import "AppDelegate.h"
#import "ActionUtility.h"
#import "DownloadUrlFinder.h"

#define DocumentsDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]

@interface NewM3u8DownloadManager () 
@property (nonatomic, strong)DownloadItem *downloadingItem;
@property (nonatomic, strong)AFDownloadRequestOperation *downloadingOperation;
@property (nonatomic)float previousProgress;
@property (nonatomic) BOOL displayNoSpaceFlag;
@property (nonatomic) int segmentIndex;
@end

@implementation NewM3u8DownloadManager
@synthesize downloadingItem;
@synthesize downloadingOperation;
@synthesize delegate, subdelegate;
@synthesize previousProgress, displayNoSpaceFlag;
@synthesize segmentIndex;
@synthesize queue;

- (void)startDownloadingThreads:(DownloadItem *)item
{
    displayNoSpaceFlag = NO;
    downloadingItem = item;    
    if (item.url) {
        [AppDelegate instance].currentDownloadingNum++;
        item.downloadStatus = @"start";
        [item save];
        downloadingItem = item;
        if (item.segmentUrlArray > 0) {
            segmentIndex = item.isDownloadingNum;
            [self downloadVideoSegment];
        } else {
            segmentIndex = 0;
            // download m3u8 playlist
            [self downloadVideoFromScratch];
        }
    } else {
        if (![item.downloadStatus isEqualToString:@"error"]) {
            DownloadUrlFinder *finder = [[DownloadUrlFinder alloc]init];
            finder.item = item;
            [finder setupWorkingUrl];
        }
    }
    
}

- (void)downloadVideoFromScratch
{
    DownloadItem *item = downloadingItem;
    NSURL *url = [NSURL URLWithString:item.url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    
    NSString *playlistFileName = [url lastPathComponent];
    NSString *filePath;
    if (item.type == 1) {
        filePath = [NSString stringWithFormat:@"%@/%@", DocumentsDirectory, item.itemId];
        if (![[NSFileManager new] fileExistsAtPath:filePath isDirectory:YES]) {
            [[NSFileManager new] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        filePath = [NSString stringWithFormat:@"%@/%@/%@", DocumentsDirectory, item.itemId, playlistFileName];
    } else {
        //                        filePath = [NSString stringWithFormat:@"%@/%@_%@.mp4", documentsDir, item.itemId, ((SubdownloadItem *)item).subitemId];
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
        NSString *newFilePath = [DocumentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/playlist.m3u8", item.itemId]];
        [[NSFileManager new]createFileAtPath:newFilePath contents:nil attributes:nil];
        NSFileHandle *playlistFile = [NSFileHandle fileHandleForUpdatingAtPath:newFilePath];
        [playlistFile truncateFileAtOffset:[playlistFile seekToEndOfFile]];
        FILE *wordFile = fopen([filePath UTF8String], "r");
        char word[1000];
        NSMutableArray *videoArray = [[NSMutableArray alloc]initWithCapacity:500];
        NSString *linebreak = @"\n";
        while (fgets(word,1000,wordFile)){
            word[strlen(word)-1] ='\0';
            NSString *stringContent = [NSString stringWithUTF8String:word];
            if ([stringContent hasPrefix:@"#"]) {
                [playlistFile writeData: [stringContent dataUsingEncoding:NSUTF8StringEncoding]];
            } else {
                [videoArray addObject:stringContent];
                NSString *segmentName;
                NSRange endRange;
                if ([[stringContent lowercaseString] hasPrefix:@"http://"] || [[stringContent lowercaseString] hasPrefix:@"https://"]) {
                    NSURL *tempUrl = [NSURL URLWithString:stringContent];
                    segmentName = [tempUrl lastPathComponent];
                    endRange = [stringContent rangeOfString:segmentName];
                } else {
                    NSRange startRange = [stringContent rangeOfString:@"/" options:NSBackwardsSearch];
                    NSRange endRange = [stringContent rangeOfString:@"?"];
                    segmentName = [stringContent substringWithRange:NSMakeRange(startRange.location, endRange.location)];
                }
                NSString *surfix = [stringContent substringFromIndex:NSMaxRange(endRange)];
                NSString *localUrlString = [NSString stringWithFormat:@"%@/%@/%i_%@%@", LOCAL_HTTP_SERVER_URL, item.itemId, videoArray.count, segmentName, surfix];
                if (ENVIRONMENT == 0) {
                    NSLog(@"localurlstring = %@", localUrlString);
                }
                [playlistFile writeData: [localUrlString dataUsingEncoding:NSUTF8StringEncoding]];
            }
            [playlistFile writeData:[linebreak dataUsingEncoding:NSUTF8StringEncoding]];
        }
        [playlistFile closeFile];
        item.segmentUrlArray = videoArray;
        [item save];
        
        [self downloadVideoSegment];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [operation cancel];
        [queue cancelAllOperations];
    }];
    [downloadingOperation setProgressiveDownloadProgressBlock:nil];
    previousProgress = 0;
    downloadingItem = item;
    [downloadingOperation start];
}

- (void)downloadVideoSegment
{
    DownloadItem *item = downloadingItem;
    queue=[[NSOperationQueue alloc] init];
    [queue setMaxConcurrentOperationCount:1];
    do {
        NSURL *url = [NSURL URLWithString:[item.segmentUrlArray objectAtIndex:segmentIndex++]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
        
        NSString *segmentName = [url lastPathComponent];
        NSString *filePath;
        if (item.type == 1) {
            filePath = [NSString stringWithFormat:@"%@/%@/%i_%@", DocumentsDirectory, item.itemId, segmentIndex, segmentName];
        } else {
            //                        filePath = [NSString stringWithFormat:@"%@/%@_%@.mp4", documentsDir, item.itemId, ((SubdownloadItem *)item).subitemId];
        }
        AFDownloadRequestOperation *segmentDownloadingOp = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:filePath shouldResume:YES];
        segmentDownloadingOp.downloadingSegmentIndex = segmentIndex;
        [segmentDownloadingOp setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (ENVIRONMENT == 0) {
                NSLog(@"Successfully downloaded file to %@", filePath);
            }
            item.percentage = (int)((segmentDownloadingOp.downloadingSegmentIndex*1.0 / item.segmentUrlArray.count) * 100);
            item.isDownloadingNum = segmentDownloadingOp.downloadingSegmentIndex;
            [item save];
            if (segmentDownloadingOp.downloadingSegmentIndex == item.urlArray.count) {//All segments are downloaded successfully.
                if(item.type == 1){
                    [delegate downloadSuccess:item.itemId];
                } else {
                    [subdelegate downloadSuccess:item.itemId suboperationId:((SubdownloadItem *)item).subitemId];
                }
            } else {
                if(item.type == 1){
                    [delegate updateProgress:item.itemId progress:item.percentage];
                } else {
                    [subdelegate updateProgress:item.itemId suboperationId:((SubdownloadItem *)item).subitemId progress:item.percentage];
                }
            }
            float freeSpace = [ActionUtility getFreeDiskspace];
            if (freeSpace <= LEAST_DISK_SPACE) {
                [self stopDownloading];
                if (!displayNoSpaceFlag) {
                    displayNoSpaceFlag = YES;
                    [ActionUtility triggerSpaceNotEnough];
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            [operation cancel];
            [queue cancelAllOperations];
            segmentIndex = 9999999; // To break the loop;
        }];
        [segmentDownloadingOp setProgressiveDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
            NSLog(@"in progress");
        }];
        if (queue.operationCount > 0) {
             AFDownloadRequestOperation *lastOp=[[queue operations] lastObject];
            [segmentDownloadingOp addDependency:lastOp];
        }
        [queue addOperation:segmentDownloadingOp];        
    } while (segmentIndex < item.segmentUrlArray.count);
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
    downloadingItem.downloadStatus = @"error";
    [downloadingItem save];
    [[AppDelegate instance].padDownloadManager startDownloadingThreads];
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
    //do nothing
}

- (void)downloadFailure:(NSString *)operationId suboperationId:(NSString *)suboperationId error:(NSError *)error
{
    [self downloadFailure:operationId error:error];
}

- (void)downloadSuccess:(NSString *)operationId suboperationId:(NSString *)suboperationId
{
    [self downloadSuccess:operationId];
}

- (void)updateProgress:(NSString *)operationId  suboperationId:(NSString *)suboperationId progress:(float)progress
{
     //do nothing
}

- (void)stopDownloading
{
    [queue cancelAllOperations];
    [downloadingOperation pause];
    [downloadingOperation cancel];
}

@end
