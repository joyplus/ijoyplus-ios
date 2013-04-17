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
#import "SegmentUrl.h"
#import "StringUtility.h"
#import "DatabaseManager.h"

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
        [DatabaseManager update:item];
        downloadingItem = item;
        NSArray *segmentUrlArray = [DatabaseManager findByCriteria:SegmentUrl.class queryString:[NSString stringWithFormat: @"WHERE itemId = %@", item.itemId]];
        if (segmentUrlArray.count > 0 && ![StringUtility stringIsEmpty:item.fileName]) {
            segmentIndex = item.isDownloadingNum;
            if (segmentIndex < segmentUrlArray.count) {
                [self performSelectorInBackground:@selector(downloadVideoSegment:) withObject:segmentUrlArray];
            }
        } else {
            if (segmentUrlArray.count > 0) {
                [DatabaseManager performSQLAggregation:[NSString stringWithFormat: @"Delete from SegmentUrl WHERE itemId = '%@'", item.itemId]];
            }
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
        if (![[NSFileManager new] fileExistsAtPath:filePath isDirectory:NO]) {
            [[NSFileManager new] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        filePath = [NSString stringWithFormat:@"%@/%@/%@", DocumentsDirectory, item.itemId, playlistFileName];
    } else {
        filePath = [NSString stringWithFormat:@"%@/%@/%@", DocumentsDirectory, item.itemId, ((SubdownloadItem *)item).subitemId];
        if (![[NSFileManager new] fileExistsAtPath:filePath isDirectory:NO]) {
            [[NSFileManager new] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        filePath = [NSString stringWithFormat:@"%@/%@/%@/%@", DocumentsDirectory, item.itemId, ((SubdownloadItem *)item).subitemId, playlistFileName];
    }
    downloadingOperation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:filePath shouldResume:YES];
    downloadingOperation.operationId = item.itemId;
    if (item.type != 1) {        
        downloadingOperation.suboperationId = ((SubdownloadItem *)item).subitemId;
    }
    [downloadingOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Successfully downloaded file to %@", filePath);
        [self performSelector:@selector(generatePlaylistFile:) withObject:filePath];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self stopDownloading];
    }];
    [downloadingOperation setProgressiveDownloadProgressBlock:nil];
    previousProgress = 0;
    downloadingItem = item;
    [downloadingOperation start];
}

- (void)generatePlaylistFile:(NSString *)filePath
{
    DownloadItem *item = downloadingItem;
    NSString *newFilePath;
    if (item.type == 1){
        newFilePath = [DocumentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/%@.m3u8", item.itemId, item.itemId]];
    } else {
        newFilePath = [DocumentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/%@/%@_%@.m3u8", item.itemId, ((SubdownloadItem *)item).subitemId, item.itemId, ((SubdownloadItem *)item).subitemId]];
    }
    [[NSFileManager new]createFileAtPath:newFilePath contents:nil attributes:nil];
    NSFileHandle *playlistFile = [NSFileHandle fileHandleForUpdatingAtPath:newFilePath];
    [playlistFile truncateFileAtOffset:[playlistFile seekToEndOfFile]];
    FILE *wordFile = fopen([filePath UTF8String], "r");
    char word[1000];
    NSMutableArray *videoArray = [[NSMutableArray alloc]initWithCapacity:500];
    NSString *linebreak = @"\n";
    double duration = 0;
    while (fgets(word,1000,wordFile)){
        word[strlen(word)-1] ='\0';
        NSString *stringContent = [[NSString stringWithUTF8String:word] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([stringContent hasPrefix:@"#"]) {
            [playlistFile writeData: [stringContent dataUsingEncoding:NSUTF8StringEncoding]];
            NSRange startRange = [stringContent rangeOfString:@":"];
            if (startRange.length > 0) {                
                NSRange lastRange = [stringContent rangeOfString:@"," options:NSBackwardsSearch];
                double segmentDuration = 0;
                if (lastRange.length == 0) {
                    segmentDuration = [[stringContent substringFromIndex:startRange.location+1] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]].doubleValue;
                } else if(lastRange.location - startRange.location > 1){
                    segmentDuration = [[stringContent substringWithRange:NSMakeRange(startRange.location+1, lastRange.location-startRange.location-1)] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]].doubleValue;
                }
                duration += segmentDuration;
            }
        } else {
            if ([[stringContent lowercaseString] hasPrefix:@"http://"] || [[stringContent lowercaseString] hasPrefix:@"https://"]) {
                [videoArray addObject:stringContent];
            } else {
                // sample url: @"http://218.76.97.35:80/AB87334821B851A8A97C084D061D038FBC1057C3/playlist.m3u8"
                NSRange endRange = [item.url rangeOfString:@"/" options:NSBackwardsSearch];
                stringContent = [NSString stringWithFormat:@"%@/%@", [item.url substringToIndex:endRange.location], stringContent];
                [videoArray addObject:stringContent];
            }
            NSURL *tempUrl = [NSURL URLWithString:stringContent];
            NSString *segmentName = [tempUrl lastPathComponent];
            NSRange endRange = [stringContent rangeOfString:segmentName];
            NSString *surfix = [stringContent substringFromIndex:NSMaxRange(endRange)];
            NSString *localUrlString;
            if (item.type == 1) {
                localUrlString = [NSString stringWithFormat:@"%@/%@/%i_%@%@", LOCAL_HTTP_SERVER_URL, item.itemId, videoArray.count, segmentName, surfix];
            } else {
                localUrlString = [NSString stringWithFormat:@"%@/%@/%@/%i_%@%@", LOCAL_HTTP_SERVER_URL, item.itemId, ((SubdownloadItem *)item).subitemId, videoArray.count, segmentName, surfix];
            }
            if (ENVIRONMENT == 0) {
                NSLog(@"localurlstring = %@", localUrlString);
            }
            [playlistFile writeData: [localUrlString dataUsingEncoding:NSUTF8StringEncoding]];
        }
        [playlistFile writeData:[linebreak dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [playlistFile closeFile];
    item.duration = duration;
    if (item.type == 1) {
        item.fileName = [NSString stringWithFormat:@"%@.m3u8", item.itemId];
    } else {
        item.fileName = [NSString stringWithFormat:@"%@.m3u8", ((SubdownloadItem *)item).subitemId];
    }
    NSMutableArray *segmentUrlArray = [[NSMutableArray alloc]initWithCapacity:videoArray.count];
    for (int i = 0; i < videoArray.count; i++) {
        SegmentUrl *segUrl = [[SegmentUrl alloc]init];
        segUrl.itemId = item.itemId;
        if ([item isKindOfClass:[SubdownloadItem class]]) {
            segUrl.subitemId = ((SubdownloadItem *)item).subitemId;
        }
        segUrl.url = [videoArray objectAtIndex:i];
        segUrl.seqNum = i;
        [segmentUrlArray addObject:segUrl];
    }
    [DatabaseManager saveInBatch:segmentUrlArray];
    [DatabaseManager update:item];
    [self downloadVideoSegment:segmentUrlArray];
}

- (void)downloadVideoSegment:(NSArray *)segmentUrlArray
{
    queue=[[NSOperationQueue alloc] init];
    [queue setMaxConcurrentOperationCount:1];
    do {
        SegmentUrl *segUrl = [segmentUrlArray objectAtIndex:segmentIndex++];
        NSURL *url = [NSURL URLWithString:segUrl.url];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
        
        NSString *segmentName = [url lastPathComponent];
        NSString *filePath;
        if (downloadingItem.type == 1) {
            filePath = [NSString stringWithFormat:@"%@/%@/%i_%@", DocumentsDirectory, downloadingItem.itemId, segmentIndex, segmentName];
        } else {
            filePath = [NSString stringWithFormat:@"%@/%@/%@/%i_%@", DocumentsDirectory, downloadingItem.itemId, ((SubdownloadItem *)downloadingItem).subitemId, segmentIndex, segmentName];
        }
        AFDownloadRequestOperation *segmentDownloadingOp = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:filePath shouldResume:YES];
        segmentDownloadingOp.downloadingSegmentIndex = segmentIndex;
        [segmentDownloadingOp setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (ENVIRONMENT == 0) {
                NSLog(@"Successfully downloaded file to %@", filePath);
            }
            if(downloadingItem.class == DownloadItem.class) {
                downloadingItem = (DownloadItem *)[DatabaseManager findFirstByCriteria:DownloadItem.class queryString:[NSString stringWithFormat:@"where itemId = %@", downloadingItem.itemId]];
            } else if (downloadingItem.class == SubdownloadItem.class) {
                downloadingItem = (SubdownloadItem *)[DatabaseManager findFirstByCriteria:SubdownloadItem.class queryString:[NSString stringWithFormat:@"where itemId = %@ and subitemId = '%@'", downloadingItem.itemId, ((SubdownloadItem *)downloadingItem).subitemId]];
            }
            downloadingItem.percentage = (int)((segmentDownloadingOp.downloadingSegmentIndex*1.0 / segmentUrlArray.count) * 100);
            downloadingItem.isDownloadingNum = segmentDownloadingOp.downloadingSegmentIndex;
            if (segmentDownloadingOp.downloadingSegmentIndex % 5 == 0 || segmentDownloadingOp.downloadingSegmentIndex == segmentUrlArray.count) {
                [DatabaseManager update:downloadingItem];
            }
            if (segmentDownloadingOp.downloadingSegmentIndex == segmentUrlArray.count) {//All segments are downloaded successfully.
                if(downloadingItem.type == 1){
                    // will call NewDownloadManager or DownloadViewController
                    [delegate downloadSuccess:downloadingItem.itemId];
                } else {
                    [subdelegate downloadSuccess:downloadingItem.itemId suboperationId:((SubdownloadItem *)downloadingItem).subitemId];
                }
            } else {
                if(downloadingItem.type == 1){
                    [delegate updateProgress:downloadingItem.itemId progress:downloadingItem.percentage/100.0];
                } else {
                    [subdelegate updateProgress:downloadingItem.itemId suboperationId:((SubdownloadItem *)downloadingItem).subitemId progress:downloadingItem.percentage/100.0];
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
            if (ENVIRONMENT == 0) {
//                NSLog(@"in progress in M3u8 donwload manager.");
            }
        }];
        if (queue.operationCount > 0) {
             AFDownloadRequestOperation *lastOp=[[queue operations] lastObject];
            [segmentDownloadingOp addDependency:lastOp];
        }
        [queue addOperation:segmentDownloadingOp];        
    } while (segmentIndex < segmentUrlArray.count);
}

- (void)setDelegate:(id<DownloadingDelegate>)newdelegate
{
    delegate = newdelegate;
}

- (void)setSubdelegate:(id<SubdownloadingDelegate>)newdelegate
{
    subdelegate = newdelegate;
}

- (void)stopDownloading
{
    downloadingItem = nil;
    [downloadingOperation pause];
    [downloadingOperation cancel];
    downloadingOperation = nil;
    [queue cancelAllOperations];
    queue = nil;
}

@end
