//
//  DownLoadManager.m
//  yueshipin
//
//  Created by 08 on 13-1-17.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "DownLoadManager.h"
#import "DownloadItem.h"
#import "SubdownloadItem.h"
#import "Reachability.h"
#import "CacheUtility.h"
#import "StringUtility.h"
#import "CMConstants.h"
#import "SegmentUrl.h"
#import "EnvConstant.h"
#import "CommonMotheds.h"
#import "DatabaseManager.h"
#define IS_M3U8(str) [str isEqualToString:@"m3u8"] ? YES: NO
#define LOADINGCOUNT 2

static DownLoadManager *downLoadManager_ = nil;
static NSMutableArray *downLoadQueue_ = nil;
static CheckDownloadUrlsManager *checkDownloadUrlsManager_;
@implementation DownLoadManager
@synthesize downloadThread = downloadThread_;
@synthesize allItems = allItems_;
@synthesize allSubItems = allSubItems_;
@synthesize downloadItem = downloadItem_;
@synthesize subdownloadItem = subdownloadItem_;
@synthesize lock = lock_;
@synthesize retryTimer = retryTimer_;
@synthesize downloadItemDic = downloadItemDic_;

+(DownLoadManager *)defaultDownLoadManager{
    if (downLoadManager_ == nil) {
        downLoadManager_ = [[DownLoadManager alloc] init];
        [downLoadManager_ initDownLoadManager];
        checkDownloadUrlsManager_ = [CheckDownloadUrlsManager defaultCheckDownloadUrlsManager];
        
    }
    return downLoadManager_;
}

-(void)initDownLoadManager{
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    netWorkStatus = [hostReach currentReachabilityStatus];
    
    downLoadQueue_ = [[NSMutableArray alloc] initWithCapacity:10];
    downloadItemDic_ = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    lock_ = [[NSLock alloc] init];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(addtoDownLoadQueue:) name:@"DOWNLOAD_MSG" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChanged:) name:NETWORK_CHANGED object:nil];
}

-(void)addtoDownLoadQueue:(id)sender{
    
    NSArray *infoArr = (NSArray *)((NSNotification *)sender).object;
    NSString *prodId = [infoArr objectAtIndex:0];
    NSString *tempUrlStr = [infoArr objectAtIndex:1];
    
    NSString *urlStr = tempUrlStr;
    if([tempUrlStr rangeOfString:@"{now_date}"].location != NSNotFound){
        int nowDate = [[NSDate date] timeIntervalSince1970];
        urlStr = [tempUrlStr stringByReplacingOccurrencesOfString:@"{now_date}" withString:[NSString stringWithFormat:@"%i", nowDate]];
    }
    
    //NSString *urlStr = [tempUrlStr stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSString *type = [infoArr objectAtIndex:4];
    int num = [[infoArr objectAtIndex:5] intValue];
    num++;
    
    NSString *fileType = [infoArr objectAtIndex:6];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    AFDownloadRequestOperation *downloadingOperation = nil;
    NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    NSString *filePath = nil;
    NSString *currentItemStatus = nil;
    if ([type isEqualToString:@"1"]){
        NSString *query = [NSString stringWithFormat:@"WHERE itemId ='%@'",prodId];
        NSArray *arr = [DatabaseManager findByCriteria:[DownloadItem class] queryString:query];
        if ([arr count] > 0) {
            DownloadItem *downloadItem = [arr objectAtIndex:0];
            downloadItem.url = urlStr;
            downloadItem.downloadType = fileType;
            //downloadItem.downloadStatus = @"waiting";
            currentItemStatus = downloadItem.downloadStatus;
            [DatabaseManager update:downloadItem];
            
        }
        
        if (!IS_M3U8(fileType)) {
            filePath = [NSString stringWithFormat:@"%@/%@.mp4", documentsDir,prodId];
        }
        else{
            NSString *subPath = [NSString stringWithFormat:@"%@_%d",prodId,num,nil];
            NSString * storeFileName = [[NSURL URLWithString:urlStr] lastPathComponent];
            filePath = [NSString stringWithFormat:@"%@/%@/%@/%@",documentsDir,prodId,subPath,storeFileName,nil];
            if (![[NSFileManager new] fileExistsAtPath:filePath isDirectory:NO]) {
                [[NSFileManager new] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
            }
            
        }
        downloadingOperation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:filePath shouldResume:YES];
        downloadingOperation.operationId = prodId;
        downloadingOperation.fileType = fileType;
        
    } else {
        NSString *subid = [NSString stringWithFormat:@"%@_%d",prodId,num];
        NSString *query = [NSString stringWithFormat:@"WHERE subitemId ='%@'",subid];
        ////NSArray *arr = [SubdownloadItem findByCriteria:query];
        NSArray *arr = [DatabaseManager findByCriteria:[SubdownloadItem class] queryString:query];
        if ([arr count] > 0) {
            SubdownloadItem *subItem = [arr objectAtIndex:0];
            subItem.url = urlStr;
            subItem.downloadType = fileType;
            currentItemStatus = subItem.downloadStatus;
            [DatabaseManager update:subItem];
        }
        
        if (!IS_M3U8(fileType)) {
            filePath = [NSString stringWithFormat:@"%@/%@_%d.mp4", documentsDir, prodId,num];
        }
        else{
            NSString *subPath = [NSString stringWithFormat:@"%@_%d",prodId,num,nil];
            NSString * storeFileName = [[NSURL URLWithString:urlStr] lastPathComponent];
            filePath = [NSString stringWithFormat:@"%@/%@/%@/%@",documentsDir,prodId,subPath,storeFileName,nil];
            if (![[NSFileManager new] fileExistsAtPath:filePath isDirectory:NO]) {
                [[NSFileManager new] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
            }
            
        }
        
        downloadingOperation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:filePath shouldResume:YES];
        downloadingOperation.operationId = [NSString stringWithFormat:@"%@_%d",prodId,num];
        downloadingOperation.fileType = fileType;
    }
    downloadingOperation.operationStatus = currentItemStatus;
    [downLoadQueue_ addObject:downloadingOperation];
    
    [self waringPlus];
    
    [self startDownLoad];
    
    
}

-(void)resumeDownLoad{
    [downLoadQueue_ removeAllObjects];
    NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    
    // NSArray *allItems = [DownloadItem allObjects];
    NSArray *allItems = [DatabaseManager allObjects:[DownloadItem class]];
    for ( DownloadItem *item in allItems) {
        if (item.type == 1) {
            if (![item.downloadStatus isEqualToString:@"finish"]) {
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:item.url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
                NSString *filePath = [NSString stringWithFormat:@"%@/%@.mp4", documentsDir,item.itemId];
                AFDownloadRequestOperation *downloadingOperation= [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:filePath shouldResume:YES];
                
                downloadingOperation.operationId = item.itemId;
                downloadingOperation.fileType = item.downloadType;
                if ([item.downloadStatus isEqualToString:@"stop"]) {
                    downloadingOperation.operationStatus = @"stop";
                }
                else if ([item.downloadStatus isEqualToString:@"loading"]) {
                    downloadingOperation.operationStatus = @"loading";
                }
                else if ([item.downloadStatus isEqualToString:@"finish"]) {
                    downloadingOperation.operationStatus = @"finish";
                }
                else if ([item.downloadStatus isEqualToString:@"waiting"]) {
                    downloadingOperation.operationStatus = @"waiting";
                }
                else if ([item.downloadStatus isEqualToString:@"fail"]) {
                    downloadingOperation.operationStatus = @"fail";
                }
                [downLoadQueue_ addObject:downloadingOperation];
            }
        }
        else{
            NSString *subquery = [NSString stringWithFormat:@"WHERE itemId = '%@' AND downloadStatus != '%@'", item.itemId,@"finish"];
            //// NSArray *tempArr = [SubdownloadItem findByCriteria:subquery];
            NSArray *tempArr = [DatabaseManager findByCriteria:[SubdownloadItem class] queryString:subquery];
            for (SubdownloadItem *sub in tempArr) {
                
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:sub.url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
                NSString *filePath = [NSString stringWithFormat:@"%@/%@.mp4", documentsDir,sub.subitemId];
                AFDownloadRequestOperation *downloadingOperation= [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:filePath shouldResume:YES];
                
                downloadingOperation.operationId = sub.subitemId;
                downloadingOperation.fileType = sub.downloadType;
                if ([sub.downloadStatus isEqualToString:@"stop"]) {
                    downloadingOperation.operationStatus = @"stop";
                }
                else if ([sub.downloadStatus isEqualToString:@"loading"]) {
                    downloadingOperation.operationStatus = @"loading";
                }
                else if ([sub.downloadStatus isEqualToString:@"finish"]) {
                    downloadingOperation.operationStatus = @"finish";
                }
                else if ([sub.downloadStatus isEqualToString:@"waiting"]) {
                    downloadingOperation.operationStatus = @"waiting";
                }
                else if ([sub.downloadStatus isEqualToString:@"fail"]) {
                    downloadingOperation.operationStatus = @"fail";
                }
                
                [downLoadQueue_ addObject:downloadingOperation];
                
            }
            
        }
        
        
    }
    
    [self resumeDownLoadStart];
    [self waringPlus];
    [self postIsloadingBoolValue];
    
}

-(void)resumeDownLoadStart{
    int downloadCount = 0;
    for (AFDownloadRequestOperation *downloadItem in downLoadQueue_) {
        if ([downloadItem.operationStatus isEqualToString:@"loading"] ) {    //0:stop 1:start 2:done 3: waiting 4:fail
            if (!IS_M3U8(downloadItem.fileType)) { //非m3u8格式
                [self beginDownloadTask:downloadItem];
            }
            else{
                
                [self beginM3u8DownloadTask:downloadItem];
            }
            downloadCount ++;
            if (downloadCount >= LOADINGCOUNT) {
                break;
            }
            
        }
    }
    
    if (downloadCount < LOADINGCOUNT) {
        for (AFDownloadRequestOperation *downloadItem in downLoadQueue_) {
            if ([downloadItem.operationStatus isEqualToString:@"waiting"]|| [downloadItem.operationStatus isEqualToString:@"fail"] ) {    //0:stop 1:start 2:done 3: waiting 4:fail
                [self beginDownloadTask:downloadItem];
                if (!IS_M3U8(downloadItem.fileType)) { //非m3u8格式
                    [self beginDownloadTask:downloadItem];
                }
                else{
                    
                    [self beginM3u8DownloadTask:downloadItem];
                }
                downloadCount ++;
                if (downloadCount >= LOADINGCOUNT) {
                    break;
                }
            }
        }
    }
    
}

-(void)startDownLoad{
    [lock_ lock];
    
    int loadingTaskCount = 0;
    for (AFDownloadRequestOperation  *downloadRequestOperation in downLoadQueue_){
        if ([downloadRequestOperation.operationStatus isEqualToString:@"loading"]) {
            loadingTaskCount++;
        }
        
    }
    
    if (loadingTaskCount < LOADINGCOUNT) {
        for (AFDownloadRequestOperation  *downloadRequestOperation in downLoadQueue_){
            if ([downloadRequestOperation.operationStatus isEqualToString:@"waiting"]/*|| [downloadRequestOperation.operationStatus isEqualToString:@"fail"]*/) {
                if (!IS_M3U8(downloadRequestOperation.fileType)) { //非m3u8格式
                    [self beginDownloadTask:downloadRequestOperation];
                }
                else{
                    
                    [self beginM3u8DownloadTask:downloadRequestOperation];
                }
                loadingTaskCount++;
                if (loadingTaskCount >= LOADINGCOUNT) {
                    break;
                }
                
            }
            
        }
        
    }
    
    [lock_ unlock];
    [self waringPlus];
    [self postIsloadingBoolValue];
}

-(void)postIsloadingBoolValue{
    if ([self isHaveLoadingTask]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:SYSTEM_IDLE_TIMER_DISABLED object:[NSNumber numberWithBool:YES]];
    }
    else{
        [[NSNotificationCenter defaultCenter]postNotificationName:SYSTEM_IDLE_TIMER_DISABLED object:[NSNumber numberWithBool:NO]];
    }
}

-(BOOL)isHaveLoadingTask{
    for (AFDownloadRequestOperation *af in downLoadQueue_) {
        if ([af.operationStatus isEqualToString:@"loading"]||[af.operationStatus isEqualToString:@"waiting"]){
            return YES;
        }
    }
    return NO;
}

-(void)retry:(NSTimer *)timer{
    AFDownloadRequestOperation *oldDownloadRequestOperation = [timer userInfo];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:oldDownloadRequestOperation.request.URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    AFDownloadRequestOperation *newDownloadingOperation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:oldDownloadRequestOperation.targetPath shouldResume:YES];
    newDownloadingOperation.operationId = oldDownloadRequestOperation.operationId;
    newDownloadingOperation.operationStatus = @"fail";
    newDownloadingOperation.fileType = oldDownloadRequestOperation.fileType;
    int index = [downLoadQueue_ indexOfObject:oldDownloadRequestOperation];
    [downLoadQueue_ replaceObjectAtIndex:index withObject:newDownloadingOperation];
    [self beginDownloadTask:newDownloadingOperation];
    
}
-(void)beginDownloadTask:(AFDownloadRequestOperation*)downloadRequestOperation{
    [self postIsloadingBoolValue];
    __block AFDownloadRequestOperation *tempdownloadRequestOperation = downloadRequestOperation;
    [downloadRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([downLoadQueue_ containsObject:operation]) {
            [downLoadQueue_ removeObject:operation];
            [downloadItemDic_ removeObjectForKey:tempdownloadRequestOperation.operationId];
            [self waringPlus];
        }
        
        NSRange range = [tempdownloadRequestOperation.operationId rangeOfString:@"_"];
        if (range.location == NSNotFound){
            [self saveDataBaseIntable:@"DownloadItem" withId:tempdownloadRequestOperation.operationId withStatus:@"finish" withPercentage:100];
            [self.downLoadMGdelegate downloadFinishwithId:tempdownloadRequestOperation.operationId inClass:@"IphoneDownloadViewController"];
            
        }
        else{
            [self saveDataBaseIntable:@"SubdownloadItem" withId:tempdownloadRequestOperation.operationId withStatus:@"finish" withPercentage:100];
            [self.downLoadMGdelegate downloadFinishwithId:tempdownloadRequestOperation.operationId inClass:@"IphoneSubdownloadViewController"];
            
        }
        [self startDownLoad];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [operation cancel];
        
        [downloadItemDic_ removeObjectForKey:tempdownloadRequestOperation.operationId];
        tempdownloadRequestOperation.operationStatus = @"fail";
        
        if (retryCount_ <= DOWNLOAD_FAIL_RETRY_TIME) {
            if (retryTimer_ != nil) {
                [retryTimer_ invalidate];
                retryTimer_ = nil;
            }
            else{
                retryCount_ ++;
                retryTimer_ = [NSTimer scheduledTimerWithTimeInterval:DOWNLOAD_FAIL_RETRY_INTERVAL
                                                               target:self
                                                             selector:@selector(retry:)
                                                             userInfo:tempdownloadRequestOperation
                                                              repeats:NO];
                
            }
        }
        else{
            
            [self downloadFail:tempdownloadRequestOperation];
            NSRange range = [tempdownloadRequestOperation.operationId rangeOfString:@"_"];
            if (range.location == NSNotFound){
                [self saveDataBaseIntable:@"DownloadItem" withId:tempdownloadRequestOperation.operationId withStatus:@"fail" withPercentage:-1];
                [self.downLoadMGdelegate downloadFailedwithId:tempdownloadRequestOperation.operationId inClass:@"IphoneDownloadViewController"];
                
            }
            else{
                [self saveDataBaseIntable:@"SubdownloadItem" withId:tempdownloadRequestOperation.operationId withStatus:@"fail" withPercentage:-1];
                [self.downLoadMGdelegate downloadFailedwithId:tempdownloadRequestOperation.operationId inClass:@"IphoneSubdownloadViewController"];
            }
            
            [self startDownLoad];
        }
        
    }];
    
    [downloadRequestOperation setProgressiveDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
        retryCount_ = 0;
        float percentDone = totalBytesReadForFile/(float)totalBytesExpectedToReadForFile;
        
        NSRange range = [tempdownloadRequestOperation.operationId rangeOfString:@"_"];
        if (range.location == NSNotFound) {
            DownloadItem *downloadItem = [downloadItemDic_ objectForKey:tempdownloadRequestOperation.operationId];
            int count = (int)(percentDone*100) - downloadItem.percentage;
            if (count >= 1){
                downloadItem.percentage = (int)(percentDone*100);
                [self.downLoadMGdelegate reFreshProgress:downloadItem withId:tempdownloadRequestOperation.operationId inClass:@"IphoneDownloadViewController"];
                if (count >=5) {
                    [DatabaseManager update:downloadItem];
                    [self updateSapce];
                }
            }
        }else{
            SubdownloadItem *subDownloadItem = [downloadItemDic_ objectForKey:tempdownloadRequestOperation.operationId];
            int count = (int)(percentDone*100) - subDownloadItem.percentage;
            if (count >= 1) {
                subDownloadItem.percentage = (int)(percentDone*100);
                [self.downLoadMGdelegate reFreshProgress:subDownloadItem withId:tempdownloadRequestOperation.operationId inClass:@"IphoneSubdownloadViewController"];
                if (count >=5) {
                    
                    [DatabaseManager update:subDownloadItem];
                    [self updateSapce];
                }
            }
        }
        
    }];
    [downloadRequestOperation start];
    downloadRequestOperation.operationStatus = @"loading";
    
    NSRange range = [downloadRequestOperation.operationId rangeOfString:@"_"];
    if (range.location == NSNotFound) {
        NSString *query = [NSString stringWithFormat:@"WHERE itemId ='%@'",downloadRequestOperation.operationId];
        NSArray *itemArr = [DatabaseManager findByCriteria:[DownloadItem class] queryString:query];
        if ([itemArr count]>0) {
            int percet = ((DownloadItem *)[itemArr objectAtIndex:0]).percentage;
            ((DownloadItem *)[itemArr objectAtIndex:0]).downloadStatus = @"loading";
            [downloadItemDic_ setObject:(DownloadItem *)[itemArr objectAtIndex:0] forKey:downloadRequestOperation.operationId];
            [self saveDataBaseIntable:@"DownloadItem" withId:downloadRequestOperation.operationId withStatus:@"loading" withPercentage:percet];
        }
        else{
            [self saveDataBaseIntable:@"DownloadItem" withId:downloadRequestOperation.operationId withStatus:@"loading" withPercentage:0];
        }
        
        [self.downLoadMGdelegate downloadBeginwithId:downloadRequestOperation.operationId inClass:@"IphoneDownloadViewController"];
        
    }
    else{
        NSString *query = [NSString stringWithFormat:@"WHERE subitemId ='%@'",downloadRequestOperation.operationId];
        NSArray *itemArr = [DatabaseManager findByCriteria:[SubdownloadItem class] queryString:query];
        if ([itemArr count]>0) {
            int percet = ((SubdownloadItem *)[itemArr objectAtIndex:0]).percentage;
            ((SubdownloadItem *)[itemArr objectAtIndex:0]).downloadStatus = @"loading";
            [downloadItemDic_ setObject:(SubdownloadItem *)[itemArr objectAtIndex:0] forKey:downloadRequestOperation.operationId];
            [self saveDataBaseIntable:@"SubdownloadItem" withId:downloadRequestOperation.operationId withStatus:@"loading" withPercentage:percet];
        }
        else{
            [self saveDataBaseIntable:@"SubdownloadItem" withId:downloadRequestOperation.operationId withStatus:@"loading" withPercentage:0];
        }
        [self.downLoadMGdelegate downloadBeginwithId:downloadRequestOperation.operationId inClass:@"IphoneSubdownloadViewController"];
        
    }
    
}

-(void)beginM3u8DownloadTask:(AFDownloadRequestOperation*)downloadRequestOperation{
    [self postIsloadingBoolValue];
    __block AFDownloadRequestOperation *tempdownloadRequestOperation = downloadRequestOperation;
    NSString *idstr = downloadRequestOperation.operationId;
    downloadRequestOperation.operationStatus = @"loading";
    NSRange range = [idstr rangeOfString:@"_"];
    DownloadItem *downloadItem = nil;
    M3u8DownLoadManager *m3u8DownloadManager = [[M3u8DownLoadManager alloc] init];
    m3u8DownloadManager.m3u8DownLoadManagerDelegate = self;
    downloadRequestOperation.m3u8MG = m3u8DownloadManager;
    
    NSArray *findArr = nil;
    if (range.location == NSNotFound) {
        NSString *query = [NSString stringWithFormat:@"WHERE itemId ='%@'",idstr];
        //findArr = [DownloadItem findByCriteria:query];
        findArr = [DatabaseManager findByCriteria:[DownloadItem class] queryString:query];
        if ([findArr count]>0) {
            downloadItem = [findArr objectAtIndex:0];
            
            if ([downloadItem.fileName hasSuffix:@"m3u8"]) {
                //resume download
                [self saveDataBaseIntable:@"DownloadItem" withId:idstr withStatus:@"loading" withPercentage:downloadItem.percentage];
                [self.downLoadMGdelegate downloadBeginwithId:idstr inClass:@"IphoneDownloadViewController"];
                
                NSArray *segArr = [DatabaseManager findByCriteria:[SegmentUrl class] queryString:query];
                [downloadRequestOperation.m3u8MG startDownloadM3u8file:segArr withId:idstr withNum:@"1"];
                return;
            }
            else{
                [self saveDataBaseIntable:@"DownloadItem" withId:idstr withStatus:@"loading" withPercentage:0];
                [self.downLoadMGdelegate downloadBeginwithId:idstr inClass:@"IphoneDownloadViewController"];
            }
        }
    }
    else{
        NSString *query = [NSString stringWithFormat:@"WHERE subitemId ='%@'",idstr];
        //findArr = [SubdownloadItem findByCriteria:query];
        findArr = [DatabaseManager findByCriteria:[SubdownloadItem class] queryString:query];
        if ([findArr count]>0) {
            downloadItem = [findArr objectAtIndex:0];
            if ([downloadItem.fileName hasSuffix:@"m3u8"]) {
                //resume download
                [self saveDataBaseIntable:@"SubdownloadItem" withId:idstr withStatus:@"loading" withPercentage:downloadItem.percentage];
                [self.downLoadMGdelegate downloadBeginwithId:idstr inClass:@"IphoneSubdownloadViewController"];
                NSArray *segArr = [DatabaseManager findByCriteria:[SegmentUrl class] queryString:[NSString stringWithFormat:@"WHERE itemId ='%@'",idstr]];
                NSArray *tempArr = [idstr componentsSeparatedByString:@"_"];
                [downloadRequestOperation.m3u8MG startDownloadM3u8file:segArr withId:idstr withNum:[tempArr objectAtIndex:1]];
                return;
            }
            else{
                [self saveDataBaseIntable:@"SubdownloadItem" withId:idstr withStatus:@"loading" withPercentage:0];
                [self.downLoadMGdelegate downloadBeginwithId:idstr inClass:@"IphoneSubdownloadViewController"];
            }
        }
    }
    
    [downloadRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"download m3u8 playList succeed");
        NSURL *url = operation.request.URL;
        if (range.location == NSNotFound){
            downloadItem.fileName = [NSString stringWithFormat:@"%@_1.m3u8",idstr];
            
            [DatabaseManager update:downloadItem];
            
            [self saveDataBaseIntable:@"DownloadItem" withId:idstr withStatus:@"loading" withPercentage:0];
            [m3u8DownloadManager setM3u8DownloadData:idstr  withNum:@"1" url:url.absoluteString withOldPath:((AFDownloadRequestOperation *)operation).targetPath];
        }
        else{
            
            downloadItem.fileName = [NSString stringWithFormat:@"%@.m3u8",idstr];
            [DatabaseManager update:downloadItem];
            [self saveDataBaseIntable:@"SubdownloadItem" withId:idstr withStatus:@"loading" withPercentage:0];
            NSArray *arr  = [idstr componentsSeparatedByString:@"_"];
            [m3u8DownloadManager setM3u8DownloadData:idstr  withNum:[arr objectAtIndex:1] url:url.absoluteString  withOldPath:((AFDownloadRequestOperation *)operation).targetPath];
        }
        
    }
     
                                                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                        
                                                        NSLog(@"failure:%@",error);
                                                        [operation cancel];
                                                        
                                                        tempdownloadRequestOperation.operationStatus = @"fail";
                                                        
                                                        NSRange range = [tempdownloadRequestOperation.operationId rangeOfString:@"_"];
                                                        if (range.location == NSNotFound){
                                                            [self saveDataBaseIntable:@"DownloadItem" withId:tempdownloadRequestOperation.operationId withStatus:@"fail" withPercentage:-1];
                                                            [self.downLoadMGdelegate downloadFailedwithId:tempdownloadRequestOperation.operationId inClass:@"IphoneDownloadViewController"];
                                                            
                                                        }
                                                        else{
                                                            [self saveDataBaseIntable:@"SubdownloadItem" withId:tempdownloadRequestOperation.operationId withStatus:@"fail" withPercentage:-1];
                                                            [self.downLoadMGdelegate downloadFailedwithId:tempdownloadRequestOperation.operationId inClass:@"IphoneSubdownloadViewController"];
                                                        }
                                                        [self startDownLoad];
                                                        
                                                    }];
    
    [downloadRequestOperation setProgressiveDownloadProgressBlock:nil];
    [downloadRequestOperation start];
    
}
-(void)downloadFail:(AFDownloadRequestOperation *)oldDownloadRequestOperation{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:oldDownloadRequestOperation.request.URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    AFDownloadRequestOperation *newDownloadingOperation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:oldDownloadRequestOperation.targetPath shouldResume:YES];
    newDownloadingOperation.operationId = oldDownloadRequestOperation.operationId;
    newDownloadingOperation.operationStatus = @"fail";
    newDownloadingOperation.fileType = oldDownloadRequestOperation.fileType;
    int index = [downLoadQueue_ indexOfObject:oldDownloadRequestOperation];
    [downLoadQueue_ replaceObjectAtIndex:index withObject:newDownloadingOperation];
}
-(void)saveDataBaseIntable:(NSString *)tableName withId:(NSString *)itenId withStatus:(NSString *)status withPercentage:(int)percentage{
    if ([tableName isEqualToString:@"DownloadItem"]) {
        // allItems_ = [DownloadItem allObjects];
        allItems_ = [DatabaseManager allObjects:[DownloadItem class]];
        for (DownloadItem *item in allItems_) {
            if ([item.itemId isEqualToString:itenId]) {
                item.downloadStatus = status;
                if (percentage >= 0) {
                    item.percentage = percentage;
                    
                }
                if (percentage == 0) {
                    // downloadItem_ = item;
                }
                
                [DatabaseManager update:item];
                break;
            }
            
        }
        
    }
    else if ([tableName isEqualToString:@"SubdownloadItem"]){
        allSubItems_ = [DatabaseManager allObjects:[SubdownloadItem class]];
        for (SubdownloadItem *item in allSubItems_) {
            if ([item.subitemId isEqualToString:itenId]){
                item.downloadStatus = status;
                if (percentage >= 0) {
                    item.percentage = percentage;
                }
                if (percentage == 0) {
                    //subdownloadItem_ = item;
                }
                
                [DatabaseManager update:item];
                break;
            }
        }
        
        
        
    }
    
}


//停止下载并清除缓存
+(void)stopAndClear:(NSString *)downloadId{
    [[DownLoadManager defaultDownLoadManager] invalidateRetryTimer];
    
    AFDownloadRequestOperation *downloadOperation = nil;
    for (AFDownloadRequestOperation *mc in downLoadQueue_) {
        if ([mc.operationId isEqualToString:downloadId]) {
            downloadOperation = mc;
            break;
        }
    }
    if (downloadOperation != nil) {
        [downloadOperation.m3u8MG stop];
        [downloadOperation pause];
        [downloadOperation cancel];
        
        [downLoadQueue_ removeObject:downloadOperation];
        
    }
    [[DownLoadManager defaultDownLoadManager] waringPlus];
    [[DownLoadManager defaultDownLoadManager] startDownLoad];
    
}

//停止下载不清除缓存
+(void)stop:(NSString *)downloadId{
    [[DownLoadManager defaultDownLoadManager] invalidateRetryTimer];
    
    AFDownloadRequestOperation *downloadOperation = nil;
    for (AFDownloadRequestOperation *mc in downLoadQueue_) {
        if ([mc.operationId isEqualToString:downloadId]) {
            downloadOperation = mc;
            break;
        }
    }
    if (downloadOperation != nil) {
        downloadOperation.operationStatus = @"stop";
        [downloadOperation.m3u8MG saveCurrentInfo];
        [downloadOperation.m3u8MG stop];
        
        [downloadOperation pause];
        [downloadOperation cancel];
        
        //AFDownloadRequestOperation cancel 之后就不能再连接了，重新初始化一个新的AFDownloadRequestOperation对象，替换原有对象；
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:downloadOperation.request.URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
        AFDownloadRequestOperation *newDownloadingOperation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:downloadOperation.targetPath shouldResume:YES];
        newDownloadingOperation.operationId = downloadOperation.operationId;
        newDownloadingOperation.operationStatus = @"stop";
        newDownloadingOperation.fileType = downloadOperation.fileType;
        int index = [downLoadQueue_ indexOfObject:downloadOperation];
        [downLoadQueue_ replaceObjectAtIndex:index withObject:newDownloadingOperation];
        
        //        BOOL isloading = NO;
        //        for (AFDownloadRequestOperation *mc in downLoadQueue_){
        //            if ([mc.operationStatus isEqualToString:@"loading"]) {
        //                isloading = YES;
        //                break;
        //            }
        //        }
        //
        //        if (!isloading) {
        //            for (AFDownloadRequestOperation *mc in downLoadQueue_) {
        //                if (![mc.operationStatus isEqualToString:@"stop"]&&![mc.operationStatus isEqualToString:@"fail_1011"] ) {
        //                    if (!IS_M3U8(mc.fileType)) { //非m3u8格式
        //                        [downLoadManager_ beginDownloadTask:mc];
        //                    }
        //                    else{
        //
        //                        [downLoadManager_ beginM3u8DownloadTask:mc];
        //                    }
        //                    break;
        //                }
        //            }
        //
        //        }
    }
    
    [downLoadManager_ startDownLoad];
    [[DownLoadManager defaultDownLoadManager] postIsloadingBoolValue];
}


+(void)continueDownload:(NSString *)downloadId{
    for (AFDownloadRequestOperation *mc in downLoadQueue_) {
        if ([mc.operationId isEqualToString:downloadId]) {
            mc.operationStatus = @"waiting";
            break;
        }
        
    }
    //    BOOL isLoading = NO;
    //    for (AFDownloadRequestOperation *mc in downLoadQueue_){
    //        if ([mc.operationStatus isEqualToString:@"loading"]) {
    //            isLoading = YES;
    //            break;
    //        }
    //    }
    //    if (!isLoading) {
    //        for (AFDownloadRequestOperation *mc in downLoadQueue_) {
    //            if (![mc.operationStatus isEqualToString:@"stop"]&&![mc.operationStatus isEqualToString:@"fail_1011"]) {
    //                if (!IS_M3U8(mc.fileType)) { //非m3u8格式
    //                    [[DownLoadManager defaultDownLoadManager] beginDownloadTask:mc];
    //                }
    //                else{
    //
    //                    [[DownLoadManager defaultDownLoadManager] beginM3u8DownloadTask:mc];
    //                }
    //
    //                break;
    //            }
    //        }
    //    }
    [downLoadManager_ startDownLoad];
    [[DownLoadManager defaultDownLoadManager] postIsloadingBoolValue];
    
}

+(int)downloadTaskCount{
    int count = 0;
    for (DownloadItem *item in [DatabaseManager allObjects:[DownloadItem class]]) {
        if (![item.downloadStatus isEqualToString:@"finish"]&& ![item.downloadStatus isEqualToString:@""]) {
            count ++;
        }
    }
    for (SubdownloadItem *item in [DatabaseManager allObjects:[SubdownloadItem class]]) {
        if (![item.downloadStatus isEqualToString:@"finish"]) {
            count ++;
        }
    }
    return count;
}

+ (int)downloadingTaskCount
{
    int count = 0;
    for (DownloadItem *item in [DatabaseManager allObjects:[DownloadItem class]]) {
        if (([item.downloadStatus isEqualToString:@"waiting"]
             || [item.downloadStatus isEqualToString:@"loading"])
            && ![item.downloadStatus isEqualToString:@""])
        {
            count ++;
        }
    }
    for (SubdownloadItem *item in [DatabaseManager allObjects:[SubdownloadItem class]])
    {
        if ([item.downloadStatus isEqualToString:@"waiting"]
            || [item.downloadStatus isEqualToString:@"loading"])
        {
            count ++;
        }
    }
    return count;
}

-(void)pauseAllTask{
    [[DownLoadManager defaultDownLoadManager] invalidateRetryTimer];
    
    for (AFDownloadRequestOperation *mc in downLoadQueue_){
        
        if (IS_M3U8(mc.fileType) && mc.m3u8MG != nil) {
            [mc.m3u8MG stop];
            
        }
        else{
            [mc pause];
            [mc cancel];
        }
        
    }
    NSMutableArray *tempQueue = [NSMutableArray arrayWithArray:downLoadQueue_];
    [downLoadQueue_ removeAllObjects];
    for (AFDownloadRequestOperation *downloadOperation in tempQueue){
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:downloadOperation.request.URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
        AFDownloadRequestOperation *newDownloadingOperation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:downloadOperation.targetPath shouldResume:YES];
        newDownloadingOperation.operationId = downloadOperation.operationId;
        newDownloadingOperation.operationStatus = downloadOperation.operationStatus;
        newDownloadingOperation.fileType = downloadOperation.fileType;
        [downLoadQueue_ addObject:newDownloadingOperation];
    }
    
}

-(void)appDidEnterForeground{
    
    [self startDownLoad];
}

- (void)M3u8DownLoadreFreshProgress:(DownloadItem *)item withId:(NSString *)itemId inClass:(NSString *)className{
    [self.downLoadMGdelegate reFreshProgress:item withId:itemId inClass:className ];
    [self updateSapce];
}

- (void)M3u8DownLoadFailedwithId:(NSString *)itemId inClass:(NSString *)className{
    NSRange range = [itemId rangeOfString:@"_"];
    if (range.location == NSNotFound){
        [self saveDataBaseIntable:@"DownloadItem" withId:itemId withStatus:@"fail" withPercentage:-1];
        [self.downLoadMGdelegate downloadFailedwithId:itemId inClass:@"IphoneDownloadViewController"];
        
    }
    else{
        [self saveDataBaseIntable:@"SubdownloadItem" withId:itemId withStatus:@"fail" withPercentage:-1];
        [self.downLoadMGdelegate downloadFailedwithId:itemId inClass:@"IphoneSubdownloadViewController"];
    }
    for (AFDownloadRequestOperation *af  in downLoadQueue_) {
        if ([af.operationId isEqualToString:itemId]) {
            [self downloadFail:af];
            break;
        }
    }
    
    [self startDownLoad];
}
-(void)M3u8DownLoadFinishwithId:(NSString *)itemId inClass:(NSString *)className{
    
    [self.downLoadMGdelegate downloadFinishwithId:itemId inClass:className];
    AFDownloadRequestOperation *downloadOperation = nil;
    for (AFDownloadRequestOperation *op in downLoadQueue_) {
        if ([op.operationId isEqualToString:itemId]) {
            downloadOperation = op;
            break;
        }
    }
    [downLoadQueue_ removeObject:downloadOperation];
    //[self waringReduce];
    [self startDownLoad];
    
}

-(void)invalidateRetryTimer{
    if (retryTimer_) {
        [retryTimer_ invalidate];
        retryTimer_ = nil;
    }
    retryCount_ = 0;
}

-(void)updateSapce{
    
    NSError *error = nil;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
    
    NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
    
    float totalSpace = [fileSystemSizeInBytes floatValue]/1024.0f/1024.0f/1024.0f;
    
    float totalFreeSpace = [freeFileSystemSizeInBytes floatValue]/1024.0f/1024.0f/1024.0f;
    
    if (totalFreeSpace*1024 <= 300 ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"空间不足，请清理磁盘后重试" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
        [alert show];
        [self pauseAllTask];
    }
    
    [self.downLoadMGdelegate updateFreeSapceWithTotalSpace:totalSpace UsedSpace:(totalSpace-totalFreeSpace)];
}

-(void)networkChanged:(NSNotification *)msg{
    int status = [(NSNumber *)(msg.object) intValue];
    if (status == netWorkStatus) {
        return;
    }
    else{
        netWorkStatus = status;
        if(netWorkStatus == 0){ //no network
            [self pauseAllTask];
        }
        else if(netWorkStatus == 1){ //3g ,2g
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            BOOL isSupport3GDownload = [[defaults objectForKey:@"isSupport3GDownload"] boolValue];
            if ([self isHaveLoadingTask]) {
                if (isSupport3GDownload) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"友情提示" message:@"你将使用2G/3G网络下载视频，若如此将会耗费大量的流量" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续下载", nil];
                    alert.tag = 199;
                    [alert show];
                }
                else{
                    [self stopAllTasksWith2GAnd3GNetWork];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"友情提示" message:@"wifi已断开，视频下载将中止，您可以在设置里将在2G/3G网络下载视频打开来继续下载" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    alert.tag = 299;
                    [alert show];
                    
                }
            }
            
        }
        else{  //wifi
            
            [self resumeDownLoadStart];
        }
    }
}

-(void)stopAllTasksWith2GAnd3GNetWork{
    [self pauseAllTask];
    for (AFDownloadRequestOperation *mc in downLoadQueue_){
        if ([mc.operationStatus isEqualToString:@"loading"] || [mc.operationStatus isEqualToString:@"waiting"]) {
            mc.operationStatus = @"stop";
            NSString *prodId = mc.operationId;
            NSRange range = [prodId rangeOfString:@"_"];
            if (range.location == NSNotFound){
                NSString *query = [NSString stringWithFormat:@"WHERE itemId ='%@'",prodId];
                NSArray *arr = [DatabaseManager findByCriteria:[DownloadItem class] queryString:query];
                if ([arr count]>0) {
                    DownloadItem *downloadItem = [arr objectAtIndex:0];
                    downloadItem.downloadStatus = @"stop";
                    [DatabaseManager update:downloadItem];
                }
            }
            else{
                NSString *query = [NSString stringWithFormat:@"WHERE subitemId ='%@'",prodId];
                NSArray *arr = [DatabaseManager findByCriteria:[SubdownloadItem class] queryString:query];
                if ([arr count]>0) {
                    SubdownloadItem *subDownloadItem = [arr objectAtIndex:0];
                    subDownloadItem.downloadStatus = @"stop";
                    [DatabaseManager update:subDownloadItem];
                }
                
            }
            
        }
    }
    [self.downLoadMGdelegate reFreshUI];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 199) {
        if (buttonIndex == 0) {
            [self stopAllTasksWith2GAnd3GNetWork];
        }
        else if (buttonIndex == 1){
            // 不做处理
        }
    }
}

-(void)waringPlus{
    NSString *numStr = [[CacheUtility sharedCache] loadFromCache:@"warning_number"];
    int num = 0;
    if (numStr != nil) {
        num = [numStr intValue];
        num++;
    }
    [[CacheUtility sharedCache] putInCache:@"warning_number" result:[NSString stringWithFormat:@"%d",num]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SET_WARING_NUM" object:nil];
}
-(void)waringReduce{
    NSString *numStr = [[CacheUtility sharedCache] loadFromCache:@"warning_number"];
    int num = 0;
    if (numStr != nil) {
        num = [numStr intValue];
        if (num >0) {
            num --;
        }
    }
    [[CacheUtility sharedCache] putInCache:@"warning_number" result:[NSString stringWithFormat:@"%d",num]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SET_WARING_NUM" object:nil];
}
@end


@implementation M3u8DownLoadManager
@synthesize downloadOperationQueue = downloadOperationQueue_;
@synthesize currentItem = currentItem_;
@synthesize segmentUrlArray = segmentUrlArray_;
@synthesize retryTimer = retryTimer_;
@synthesize operationQueueArray = operationQueueArray_;
-(void)setM3u8DownloadData:(NSString *)prodId withNum:(NSString *)num url:(NSString *)urlStr withOldPath:(NSString *)oldPath{
    NSArray *infoArr = [NSArray arrayWithObjects:prodId,num,urlStr,oldPath,nil];
    [self performSelectorInBackground:@selector(doInBackground:) withObject:infoArr];
}

-(void)doInBackground:(id)sender{
    NSArray *infoArr = (NSArray *)sender;
    NSString *prodId = [infoArr objectAtIndex:0];
    NSString *num = [infoArr objectAtIndex:1];
    NSString *urlStr = [infoArr objectAtIndex:2];
    NSString *oldPath = [infoArr objectAtIndex:3];
    
    NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    NSString *subPath = nil;
    NSRange range = [prodId rangeOfString:@"_"];
    NSString *tempPath = nil;
    DownloadItem *downloadItem = nil;
    if (range.location == NSNotFound) {
        subPath = [NSString stringWithFormat:@"%@_%@",prodId,num,nil];
        tempPath = prodId;
        NSString *query = [NSString stringWithFormat:@"WHERE itemId ='%@'",prodId];
        //NSArray *arr = [DownloadItem findByCriteria:query];
        NSArray *arr = [DatabaseManager findByCriteria:[DownloadItem class] queryString:query];
        if ([arr count]>0) {
            downloadItem = [arr objectAtIndex:0];
        }
    }
    else{
        subPath = prodId;
        tempPath = [[prodId componentsSeparatedByString:@"_"] objectAtIndex:0];
        NSString *query = [NSString stringWithFormat:@"WHERE subitemId ='%@'",prodId];
        //NSArray *arr = [SubdownloadItem findByCriteria:query];
        NSArray *arr = [DatabaseManager findByCriteria:[SubdownloadItem class] queryString:query];
        if ([arr count]>0) {
            downloadItem = [arr objectAtIndex:0];
        }
    }
    NSString *new_filePath = [NSString stringWithFormat:@"%@/%@/%@/%@.m3u8",documentsDir,tempPath,subPath,num,nil];
    [[NSFileManager new]createFileAtPath:new_filePath contents:nil attributes:nil];
    NSFileHandle *playlistFile = [NSFileHandle fileHandleForUpdatingAtPath:new_filePath];
    [playlistFile truncateFileAtOffset:[playlistFile seekToEndOfFile]];
    FILE *wordFile = fopen([oldPath UTF8String], "r");
    char word[1000];
    double duration = 0;
    NSMutableArray *videoArray = [[NSMutableArray alloc]initWithCapacity:500];
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
                    segmentDuration = [[stringContent substringFromIndex:(startRange.location+1)] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]].doubleValue;
                } else if(lastRange.location - startRange.location > 1){
                    segmentDuration = [[stringContent substringWithRange:NSMakeRange(startRange.location+1, lastRange.location-startRange.location-1)] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]].doubleValue;
                }
                duration += segmentDuration;
            }
        } else {
            if ([[stringContent lowercaseString] hasPrefix:@"http://"] || [[stringContent lowercaseString] hasPrefix:@"https://"]) {
                [videoArray addObject:stringContent];
            } else {
                NSRange endRange = [urlStr rangeOfString:@"/" options:NSBackwardsSearch];
                stringContent = [NSString stringWithFormat:@"%@/%@", [urlStr substringToIndex:endRange.location], stringContent];
                [videoArray addObject:stringContent];
            }
            NSURL *tempUrl = [NSURL URLWithString:stringContent];
            NSString *segmentName = [tempUrl lastPathComponent];
            NSRange endRange = [stringContent rangeOfString:segmentName];
            NSString *surfix = [stringContent substringFromIndex:NSMaxRange(endRange)];
            NSString *localUrlString;
            localUrlString = [NSString stringWithFormat:@"%@/%@/%@/%i_%@%@", LOCAL_HTTP_SERVER_URL, tempPath, subPath, videoArray.count, segmentName, surfix];
            
            [playlistFile writeData: [localUrlString dataUsingEncoding:NSUTF8StringEncoding]];
        }
        NSString *linebreak = @"\n";
        [playlistFile writeData:[linebreak dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [playlistFile closeFile];
    
    downloadItem.duration = duration;
    //[downloadItem save];
    [DatabaseManager update:downloadItem];
    
    if (segmentUrlArray_ == nil) {
        segmentUrlArray_ = [[NSMutableArray alloc]initWithCapacity:videoArray.count];
        for (int i = 0; i < videoArray.count; i++) {
            SegmentUrl *segUrl = [[SegmentUrl alloc]init];
            segUrl.itemId = prodId;
            
            segUrl.url = [videoArray objectAtIndex:i];
            segUrl.seqNum = i;
            //[segUrl save];
            [DatabaseManager save:segUrl];
            [segmentUrlArray_ addObject:segUrl];
        }
    }
    [self startDownloadM3u8file:segmentUrlArray_ withId:prodId withNum:num];
    
}

-(void)startDownloadM3u8file:(NSArray *)urlArr withId:(NSString *)idStr withNum:(NSString *)num{
    NSArray *infoArr = [NSArray arrayWithObjects:urlArr,idStr,num,nil];
    [self performSelector:@selector(beginDownloadM3u8file:) withObject:infoArr];
}

-(void)beginDownloadM3u8file:(NSArray *)infoArr
{
    NSArray *urlArr = [infoArr objectAtIndex:0];
    NSString *idStr = [infoArr objectAtIndex:1];
    NSString *num = [infoArr objectAtIndex:2];
    
    if (nil == operationQueueArray_)
    {
        operationQueueArray_ = [NSMutableArray array];
    }
    
    [operationQueueArray_ removeAllObjects];
    
    NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    
    NSRange range = [idStr rangeOfString:@"_"];
    if (range.location == NSNotFound)
    {
        NSString *query = [NSString stringWithFormat:@"WHERE itemId ='%@'",idStr];
        NSArray *arr = [DatabaseManager findByCriteria:[DownloadItem class] queryString:query];
        if ([arr count]>0)
        {
            currentItem_ = [arr objectAtIndex:0];
        }
    }
    else
    {
        NSString *query = [NSString stringWithFormat:@"WHERE subitemId ='%@'",idStr];
        NSArray *arr = [DatabaseManager findByCriteria:[SubdownloadItem class] queryString:query];
        if ([arr count]>0)
        {
            currentItem_ = [arr objectAtIndex:0];
        }
    }
    NSMutableArray * downloadInfo = currentItem_.m3u8DownloadInfo;
    
    for (int i = 0; i < CONCURRENT_COUNT; i ++)
    {
        NSOperationQueue * queue = [[NSOperationQueue alloc] init];
        [queue setMaxConcurrentOperationCount:1];
        [operationQueueArray_ addObject:queue];
        
        NSInteger NumPerTask;
        
        if (i == CONCURRENT_COUNT - 1)
            NumPerTask = urlArr.count - (urlArr.count / CONCURRENT_COUNT) * i;
        else
            NumPerTask = urlArr.count / CONCURRENT_COUNT;
        
        NSInteger curSegmentIndex = 0;
        if (downloadInfo.count == i)
        {
            [downloadInfo addObject:@"0"];
        }
        else if (downloadInfo.count == CONCURRENT_COUNT)
        {
            curSegmentIndex = [[downloadInfo objectAtIndex:i] intValue];
        }
        
        //url_index = curSegmentIndex + urlArr.count / CONCURRENT_COUNT * i;
        
        for (int j = curSegmentIndex;j < NumPerTask; j ++)
        {
            int segment = curSegmentIndex + urlArr.count / CONCURRENT_COUNT * i;
            SegmentUrl *segUrl = [urlArr objectAtIndex:segment];
            curSegmentIndex ++;
            NSURL *url = [NSURL URLWithString:segUrl.url];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
            NSString *segmentName = [url lastPathComponent];
            NSString *subPath = nil;
            NSString *tempPath = nil;
            if (range.location == NSNotFound) {
                subPath = [NSString stringWithFormat:@"%@_%@",idStr,num];
                tempPath = idStr;
            }
            else{
                subPath = idStr;
                NSArray *tempArr = [idStr componentsSeparatedByString:@"_"];
                tempPath = [tempArr objectAtIndex:0];
            }
            NSString*filePath = [NSString stringWithFormat:@"%@/%@/%@/%i_%@", documentsDir,tempPath,subPath,(segment+1), segmentName];
            AFDownloadRequestOperation *segmentDownloadingOp = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:filePath shouldResume:YES];
            
            segmentDownloadingOp.downloadingSegmentIndex = 0;//segmentIndex
            for (NSString * str in downloadInfo)
            {
                segmentDownloadingOp.downloadingSegmentIndex += [str intValue];
            }
            
            [segmentDownloadingOp setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                AFDownloadRequestOperation *tempDownloadRequestOperation = (AFDownloadRequestOperation*)operation;
                retryCount_ = 0;
                //url_index = tempDownloadRequestOperation.downloadingSegmentIndex;
                
                [downloadInfo replaceObjectAtIndex:i
                                        withObject:[NSString stringWithFormat:@"%d",curSegmentIndex]];
                currentItem_.m3u8DownloadInfo = downloadInfo;
                int downloadedNum = 0;
                for (NSString * str in downloadInfo)
                {
                    downloadedNum += [str intValue];
                }
                tempDownloadRequestOperation.downloadingSegmentIndex = downloadedNum;
                
                if (tempDownloadRequestOperation.downloadingSegmentIndex == [urlArr count])
                {
                    if (range.location == NSNotFound){
                        [self saveDataBaseIntable:@"DownloadItem" withId:idStr withStatus:@"finish" withPercentage:100];
                        [self.m3u8DownLoadManagerDelegate  M3u8DownLoadFinishwithId:idStr inClass:@"IphoneDownloadViewController"];
                        
                    }
                    else{
                        [self saveDataBaseIntable:@"SubdownloadItem" withId:idStr withStatus:@"finish" withPercentage:100];
                        [self.m3u8DownLoadManagerDelegate  M3u8DownLoadFinishwithId:idStr inClass:@"IphoneSubdownloadViewController"];
                    }
                    
                }
                else{
                    float percent =  downloadedNum *1.0/[urlArr count];
                    if (ENVIRONMENT == 0 ) {
                        NSLog(@"%f",percent);
                    }
                    currentItem_.isDownloadingNum = tempDownloadRequestOperation.downloadingSegmentIndex;
                    currentItem_.percentage = (int)(percent*100);
                    if (downloadedNum % 5 == 0) {
                        //[currentItem_ save];
                        [DatabaseManager update:currentItem_];
                    }
                    
                    if (range.location == NSNotFound){
                        
                        [self.m3u8DownLoadManagerDelegate M3u8DownLoadreFreshProgress:currentItem_ withId:idStr inClass:@"IphoneDownloadViewController"];
                        
                    }
                    else{
                        [self.m3u8DownLoadManagerDelegate M3u8DownLoadreFreshProgress:currentItem_ withId:idStr inClass:@"IphoneSubdownloadViewController"];
                    }
                }
            }
                                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                            
                                                            [operation cancel];
                                                            [queue cancelAllOperations];
                                                            
                                                            if (retryCount_ <= DOWNLOAD_FAIL_RETRY_TIME) {
                                                                NSArray *tempArr = [NSArray arrayWithObjects:urlArr,idStr,num,nil];
                                                                if (retryTimer_ != nil) {
                                                                    [retryTimer_ invalidate];
                                                                    retryTimer_ = nil;
                                                                }
                                                                retryTimer_ = [NSTimer scheduledTimerWithTimeInterval:DOWNLOAD_FAIL_RETRY_INTERVAL target:self selector:@selector(retry:) userInfo:tempArr repeats:NO];
                                                                //[self performSelector:@selector(retry:) withObject:tempArr afterDelay:10.0];
                                                            }
                                                            else{
                                                                if (range.location == NSNotFound){
                                                                    
                                                                    [self.m3u8DownLoadManagerDelegate M3u8DownLoadFailedwithId:idStr inClass:@"IphoneDownloadViewController"];
                                                                    
                                                                }
                                                                else{
                                                                    [self.m3u8DownLoadManagerDelegate M3u8DownLoadFailedwithId:idStr inClass:@"IphoneSubdownloadViewController"];
                                                                    
                                                                }
                                                            }
                                                            
                                                        }];
            [segmentDownloadingOp setProgressiveDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
                
            }];
            
            if (queue.operationCount > 0)
            {
                AFDownloadRequestOperation *lastOp=[[queue operations] lastObject];
                [segmentDownloadingOp addDependency:lastOp];
            }
            [queue addOperation:segmentDownloadingOp];
        }
    }
}

-(void)retry:(NSTimer *)timer{
    if ([CommonMotheds isNetworkEnbled]) {
        retryCount_++;
        NSLog(@"retry cout is %d",retryCount_);
        NSArray *arr = [timer userInfo];
        [self startDownloadM3u8file:[arr objectAtIndex:0] withId:[arr objectAtIndex:1] withNum:[arr objectAtIndex:2]];
    }
}
-(void)saveDataBaseIntable:(NSString *)tableName withId:(NSString *)itemId withStatus:(NSString *)status withPercentage:(int)percentage{
    if ([tableName isEqualToString:@"DownloadItem"]) {
        NSString *query = [NSString stringWithFormat:@"WHERE itemId ='%@'",itemId];
        //NSArray *itemArr = [DownloadItem findByCriteria:query];
        NSArray *itemArr = [DatabaseManager findByCriteria:[DownloadItem class] queryString:query];
        if ([itemArr count]>0) {
            DownloadItem *item = (DownloadItem *)[itemArr objectAtIndex:0];
            item.downloadStatus = status;
            item.percentage = percentage;
            //[item save];
            [DatabaseManager update:item];
        }
    }
    else if ([tableName isEqualToString:@"SubdownloadItem"]){
        NSString *query = [NSString stringWithFormat:@"WHERE subitemId ='%@'",itemId];
        //NSArray *itemArr = [SubdownloadItem findByCriteria:query];
        NSArray *itemArr = [DatabaseManager findByCriteria:[SubdownloadItem class] queryString:query];
        if ([itemArr count]> 0) {
            SubdownloadItem *item = (SubdownloadItem *)[itemArr objectAtIndex:0];
            item.downloadStatus = status;
            item.percentage = percentage;
            // [item save];
            [DatabaseManager update:item];
        }
    }
}
-(void)stop{
    [self invalidateRetryTimer];
    for (NSOperationQueue * op in operationQueueArray_)
    {
        [op cancelAllOperations];
    }
}

-(void)invalidateRetryTimer{
    if (retryTimer_) {
        [retryTimer_ invalidate];
        retryTimer_ = nil;
    }
    retryCount_ = 0;
}
-(void)saveCurrentInfo{
    NSLog(@"%@",currentItem_);
    if (currentItem_) {
        [DatabaseManager update:currentItem_];
    }
}

@end



@implementation CheckDownloadUrls
@synthesize downloadInfoArr = downloadInfoArr_;
@synthesize fileType = fileType_;
@synthesize allUrls = allUrls_;
@synthesize currentConnection = currentConnection_;
@synthesize oneEsp = oneEsp_;
@synthesize defaultUrlInfo = defaultUrlInfo_;
-(void)checkDownloadUrls{
    NSDictionary *infoDic = oneEsp_;
    allUrls_ = [[NSMutableArray alloc] initWithCapacity:5];
    //    NSMutableArray *mp4UrlsArr = [[NSMutableArray alloc] initWithCapacity:5];
    //    NSMutableArray *m3u8UrlsArr = [[NSMutableArray alloc] initWithCapacity:5];
    //
    NSArray *down_urlsArr = [infoDic objectForKey:@"down_urls"];
    for (NSDictionary *dic in down_urlsArr) {
        NSArray *oneSourceArr = [dic objectForKey:@"urls"];
        NSString *source = [dic objectForKey:@"source"];
        for (NSDictionary *oneUrlInfo in oneSourceArr) {
            
            NSString * str = [oneUrlInfo objectForKey:@"url"];
            NSString *tempUrl = str;
            if([str rangeOfString:@"{now_date}"].location != NSNotFound){
                int nowDate = [[NSDate date] timeIntervalSince1970];
                tempUrl = [str stringByReplacingOccurrencesOfString:@"{now_date}" withString:[NSString stringWithFormat:@"%i", nowDate]];
            }
            NSString *type = [oneUrlInfo objectForKey:@"file"];
            NSDictionary *myDic = [NSDictionary dictionaryWithObjectsAndKeys:tempUrl,@"url",type,@"type",source,@"source", nil];
            
            [allUrls_ addObject:myDic];
        }
    }
    
    NSMutableArray *tempSortArr = [NSMutableArray arrayWithCapacity:5];
    for (NSDictionary *dic in allUrls_)
    {
        NSMutableDictionary *temp_dic = [NSMutableDictionary dictionaryWithDictionary:dic];
        NSString *source_str = [temp_dic objectForKey:@"source"];
        
        if ([source_str isEqualToString:@"wangpan"]) {
            [temp_dic setObject:@"0.1" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"le_tv_fee"]) {
            [temp_dic setObject:@"0.2" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"letv"]) {
            [temp_dic setObject:@"1" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"fengxing"]){
            [temp_dic setObject:@"2" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"qiyi"]){
            [temp_dic setObject:@"3" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"youku"]){
            [temp_dic setObject:@"4" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"sinahd"]){
            [temp_dic setObject:@"5" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"sohu"]){
            [temp_dic setObject:@"6" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"56"]){
            [temp_dic setObject:@"7" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"qq"]){
            [temp_dic setObject:@"8" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"pptv"]){
            [temp_dic setObject:@"9" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"pps"]){
            [temp_dic setObject:@"10" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"m1905"]){
            [temp_dic setObject:@"11" forKey:@"level"];
        }
        else if ([source_str isEqualToString:@"baidu_wangpan"]){
            [temp_dic setObject:@"12" forKey:@"level"];
        }
        [tempSortArr addObject:temp_dic];
    }
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"level" ascending:YES comparator:sortStr];
    allUrls_ = [NSMutableArray arrayWithArray:[tempSortArr sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]]];
    
    
    defaultUrlInfo_ = [allUrls_ objectAtIndex:0];
    sendCount_ = 0;
    [self sendHttpRequest];
}

NSComparator sortStr = ^(id obj1, id obj2){
    if ([obj1 floatValue] > [obj2 floatValue]) {
        return (NSComparisonResult)NSOrderedDescending;
    }
    
    if ([obj1 floatValue] < [obj2 floatValue]) {
        return (NSComparisonResult)NSOrderedAscending;
    }
    return (NSComparisonResult)NSOrderedSame;
};

-(void)sendHttpRequest{
    if (sendCount_ < [allUrls_ count]) {
        NSDictionary *infoDic = [allUrls_ objectAtIndex:sendCount_];
        NSString *urlStr = [infoDic objectForKey:@"url"];
        NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
        currentConnection_ = [NSURLConnection connectionWithRequest:request delegate:self];
        sendCount_++;
    }
    else{
        [self resetDataBase];
        [self.checkDownloadUrlsDelegate checkUrlsFinishWithId:self.checkIndex];
    }
}


-(void)resetDataBase{
    NSString *prodId = [downloadInfoArr_ objectAtIndex:0];
    NSString *tempUrlStr = [[allUrls_ objectAtIndex:0] objectForKey:@"url"];
    NSString *type = [downloadInfoArr_ objectAtIndex:3];
    int num = [[downloadInfoArr_ objectAtIndex:4] intValue];
    num++;
    
    NSString *urlStr = tempUrlStr;
    if([tempUrlStr rangeOfString:@"{now_date}"].location != NSNotFound){
        int nowDate = [[NSDate date] timeIntervalSince1970];
        urlStr = [tempUrlStr stringByReplacingOccurrencesOfString:@"{now_date}" withString:[NSString stringWithFormat:@"%i", nowDate]];
    }
    
    //NSString *urlStr = [tempUrlStr stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSString *fileType = nil;
    for (NSDictionary *dic  in allUrls_) {
        NSString *str = [dic objectForKey:@"url"];
        if ([str isEqualToString:urlStr]) {
            fileType = [dic objectForKey:@"type"];
            break;
        }
    }
    
    if ([type isEqualToString:@"1"]){
        NSString *query = [NSString stringWithFormat:@"WHERE itemId ='%@'",prodId];
        //NSArray *arr = [DownloadItem findByCriteria:query];
        NSArray *arr = [DatabaseManager findByCriteria:[DownloadItem class] queryString:query];
        if ([arr count]>0) {
            DownloadItem *item = [arr objectAtIndex:0];
            item.url = urlStr;
            item.downloadStatus = @"fail_1011";
            item.downloadType = fileType;
            //[item save];
            [DatabaseManager update:item];
        }
        [[DownLoadManager defaultDownLoadManager].downLoadMGdelegate  downloadUrlTnvalidWithId:prodId inClass:@"IphoneDownloadViewController"];
    } else {
        NSString *subId = [NSString stringWithFormat:@"%@_%d",prodId,num];
        NSString *query = [NSString stringWithFormat:@"WHERE subitemId ='%@'",subId];
        //NSArray *arr = [SubdownloadItem findByCriteria:query];
        NSArray *arr = [DatabaseManager findByCriteria:[SubdownloadItem class] queryString:query];
        if ([arr count]>0) {
            SubdownloadItem *item = [arr objectAtIndex:0];
            item.url = urlStr;
            item.downloadStatus = @"fail_1011";
            item.downloadType = fileType;
            //[item save];
            [DatabaseManager update:item];
        }
        [[DownLoadManager defaultDownLoadManager].downLoadMGdelegate  downloadUrlTnvalidWithId:prodId inClass:@"IphoneSubdownloadViewController"];
    }
    
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    [self sendHttpRequest];
    [connection cancel];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
    
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
    int status_Code = HTTPResponse.statusCode;
    if (status_Code >= 200 && status_Code <= 299) {
        NSDictionary *headerFields = [HTTPResponse allHeaderFields];
        NSString *content_type = [headerFields objectForKey:@"Content-Type"];
        NSString *contentLength = [headerFields objectForKey:@"Content-Length"];
        if (![content_type hasPrefix:@"text/html"] && (contentLength.intValue) ) {
            
            NSString *proid = [downloadInfoArr_ objectAtIndex:0];
            NSString *urlStr = connection.originalRequest.URL.absoluteString;
            NSString *name = [downloadInfoArr_ objectAtIndex:1];
            NSString *imgUrl = [downloadInfoArr_ objectAtIndex:2];
            NSString *type = [downloadInfoArr_ objectAtIndex:3];
            NSString *num = [downloadInfoArr_ objectAtIndex:4];
            NSString *fileType = nil;
            for (NSDictionary *dic  in allUrls_) {
                NSString *str = [dic objectForKey:@"url"];
                if ([str isEqualToString:urlStr]) {
                    fileType = [dic objectForKey:@"type"];
                    break;
                }
            }
            
            if ([fileType isEqualToString:@"mp4"] && contentLength.integerValue <= MIN_MP4_FILE_SIZE)
            {
                fileType = @"m3u8";
            }
            else if ([fileType isEqualToString:@"m3u8"] && contentLength.integerValue > MAX_M3U8_FILE_SIZE)
            {
                fileType = @"mp4";
            }
            
            NSArray *arr = [NSArray arrayWithObjects:proid,urlStr,name,imgUrl,type,num,fileType,nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DOWNLOAD_MSG" object:arr];
            [connection cancel];
            [self.checkDownloadUrlsDelegate checkUrlsFinishWithId:self.checkIndex];
            return;
            
        }
        
    }
    [self sendHttpRequest];
    
}

-(void)cancelConnection{
    if (currentConnection_) {
        [currentConnection_ cancel];
        currentConnection_ = nil;
    }
    
}
-(void)dealloc{
    [self cancelConnection];
}

@end



@implementation CheckDownloadUrlsManager
static CheckDownloadUrlsManager *checkDownloadUrlsManager_ = nil;
static NSMutableArray *CheckDownloadUrlsQueue_ = nil;
+(CheckDownloadUrlsManager *)defaultCheckDownloadUrlsManager{
    if (checkDownloadUrlsManager_ == nil) {
        checkDownloadUrlsManager_ = [[CheckDownloadUrlsManager alloc] init];
        CheckDownloadUrlsQueue_ = [NSMutableArray arrayWithCapacity:5];
        checkDownloadUrlsManager_.isDone = YES;
    }
    return checkDownloadUrlsManager_;
}

+(void)addToCheckQueue:(CheckDownloadUrls *)check{
    [CheckDownloadUrlsQueue_ addObject:check];
    [CheckDownloadUrlsManager saveDataBase:check];
    check.checkIndex = arc4random()%1000000;
    //check.checkDownloadUrlsDelegate = self;
    [CheckDownloadUrlsManager startCheck];
    [[DownLoadManager defaultDownLoadManager] postIsloadingBoolValue];
    [[DownLoadManager defaultDownLoadManager] waringPlus];
}

+(void)startCheck{
    if (checkDownloadUrlsManager_.isDone) {
        if ([CheckDownloadUrlsQueue_ count]>0) {
            CheckDownloadUrls *check = [CheckDownloadUrlsQueue_ objectAtIndex:0];
            [check checkDownloadUrls];
            checkDownloadUrlsManager_.isDone = NO;
        }
    }
}
-(void)checkUrlsFinishWithId:(int)taskId{
    [self removeTask:taskId];
    checkDownloadUrlsManager_.isDone = YES;
    [CheckDownloadUrlsManager startCheck];
    NSLog(@"CheckDownloadUrlsQueue_ count is %d",[CheckDownloadUrlsQueue_ count]);
}
-(void)removeTask:(int)taskId{
    for (CheckDownloadUrls *check in CheckDownloadUrlsQueue_) {
        if (check.checkIndex == taskId) {
            [CheckDownloadUrlsQueue_ removeObject:check];
            break;
        }
    }
}

+(void)saveDataBase:(CheckDownloadUrls *)checkDownloadUrls{
    NSDictionary *oneEsp = checkDownloadUrls.oneEsp;
    NSDictionary *defaultUrlInfo = [CheckDownloadUrlsManager getDefaultUrlAndType:oneEsp];
    
    NSArray *downloadInfoArr = checkDownloadUrls.downloadInfoArr;
    NSString *prodId = [downloadInfoArr objectAtIndex:0];
    NSString *urlStr = [defaultUrlInfo objectForKey:@"url"];
    NSString *fileName = [downloadInfoArr objectAtIndex:1];
    NSString *imgUrl = [downloadInfoArr objectAtIndex:2];
    NSString *type = [downloadInfoArr objectAtIndex:3];
    int num = [[downloadInfoArr objectAtIndex:4] intValue];
    num++;
    NSString *fileType = [defaultUrlInfo objectForKey:@"type"];
    if ([type isEqualToString:@"1"]){
        DownloadItem *item = [[DownloadItem alloc]init];
        item.itemId = prodId;
        item.name = fileName;
        item.percentage = 0;
        item.type = 1;
        item.url = urlStr;
        item.imageUrl = imgUrl;
        item.downloadStatus = @"waiting";
        item.downloadType = fileType;
        [DatabaseManager save:item];
    } else {
        NSArray *itemArr = [DatabaseManager allObjects:[DownloadItem class]];
        BOOL isHave = NO;
        for (DownloadItem *item in itemArr) {
            if ([item.itemId isEqualToString:prodId]) {
                isHave = YES;
                break;
            }
        }
        if (!isHave) {
            DownloadItem *item = [[DownloadItem alloc]init];
            item.itemId = prodId;
            if ([fileName rangeOfString:@"_"].location != NSNotFound) {
                item.name = [[fileName componentsSeparatedByString:@"_"] objectAtIndex:0];
            }
            
            item.imageUrl = imgUrl;
            [DatabaseManager save:item];
        }
        
        SubdownloadItem *subItem = [[SubdownloadItem alloc] init];
        subItem.itemId = prodId;
        subItem.percentage = 0;
        subItem.type = [type intValue];
        subItem.url = urlStr;
        subItem.imageUrl = imgUrl;
        subItem.name = fileName;
        subItem.subitemId = [NSString stringWithFormat:@"%@_%d",prodId,num];
        subItem.downloadStatus = @"waiting";
        subItem.downloadType = fileType;
        [DatabaseManager save:subItem];
    }
    
}
+(NSDictionary*)getDefaultUrlAndType:(NSDictionary *)oneDic{
    NSArray *down_urlsArr = [oneDic objectForKey:@"down_urls"];
    for (NSDictionary *dic in down_urlsArr) {
        NSArray *oneSourceArr = [dic objectForKey:@"urls"];
        for (NSDictionary *oneUrlInfo in oneSourceArr) {
            
            NSString * str = [oneUrlInfo objectForKey:@"url"];
            NSString *tempUrl = str;
            if([str rangeOfString:@"{now_date}"].location != NSNotFound){
                int nowDate = [[NSDate date] timeIntervalSince1970];
                tempUrl = [str stringByReplacingOccurrencesOfString:@"{now_date}" withString:[NSString stringWithFormat:@"%i", nowDate]];
            }
            
            //NSString *tempUrl = [[oneUrlInfo objectForKey:@"url"] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
            NSString *type = [oneUrlInfo objectForKey:@"file"];
            NSDictionary *myDic = [NSDictionary dictionaryWithObjectsAndKeys:tempUrl,@"url",type,@"type", nil];
            return myDic;
            
        }
        
    }
    return nil;
}
@end
