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
static DownLoadManager *downLoadManager_ = nil;
static NSMutableArray *downLoadQueue_ = nil;
static CheckDownloadUrlsManager *checkDownloadUrlsManager_;
@implementation DownLoadManager
@synthesize downloadThread = downloadThread_;
@synthesize downloadId = downloadId_;
@synthesize allItems = allItems_;
@synthesize allSubItems = allSubItems_;
@synthesize downloadItem = downloadItem_;
@synthesize subdownloadItem = subdownloadItem_;
@synthesize lock = lock_;
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
    lock_ = [[NSLock alloc] init];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(addtoDownLoadQueue:) name:@"DOWNLOAD_MSG" object:nil];
}

-(void)addtoDownLoadQueue:(id)sender{
  
    NSArray *infoArr = (NSArray *)((NSNotification *)sender).object;
    NSString *prodId = [infoArr objectAtIndex:0];
    NSString *tempUrlStr = [infoArr objectAtIndex:1];
    NSString *urlStr = [tempUrlStr stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSString *type = [infoArr objectAtIndex:4];
    int num = [[infoArr objectAtIndex:5] intValue];
    num++;
    
    NSString *fileType = [infoArr objectAtIndex:6];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    AFDownloadRequestOperation *downloadingOperation = nil;
    NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    NSString *filePath = nil;
    if ([type isEqualToString:@"1"]){
        NSString *query = [NSString stringWithFormat:@"WHERE itemId ='%@'",prodId];
       //// NSArray *arr = [DownloadItem findByCriteria:query];
        NSArray *arr = [DatabaseManager findByCriteria:[DownloadItem class] queryString:query];
        if ([arr count] > 0) {
            DownloadItem *downloadItem = [arr objectAtIndex:0];
            downloadItem.url = urlStr;
            downloadItem.downloadType = fileType;
            downloadItem.downloadStatus = @"waiting";
            ////[downloadItem save];
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
            subItem.downloadStatus = @"waiting";
            [DatabaseManager update:subItem];
            ////[subItem save];
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
       downloadingOperation.operationStatus = @"waiting";
      [downLoadQueue_ addObject:downloadingOperation];
  
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
    BOOL isdownloading = NO;
    for (AFDownloadRequestOperation *downloadItem in downLoadQueue_) {
        if ([downloadItem.operationStatus isEqualToString:@"loading"] ) {    //0:stop 1:start 2:done 3: waiting 4:fail
            if (!IS_M3U8(downloadItem.fileType)) { //非m3u8格式
                [self beginDownloadTask:downloadItem];
            }
            else{
                
                [self beginM3u8DownloadTask:downloadItem];
            }
            isdownloading = YES;
            break;
        }
    }
    
    if (!isdownloading) {
        for (AFDownloadRequestOperation *downloadItem in downLoadQueue_) {
            if ([downloadItem.operationStatus isEqualToString:@"waiting"]|| [downloadItem.operationStatus isEqualToString:@"fail"] ) {    //0:stop 1:start 2:done 3: waiting 4:fail
                [self beginDownloadTask:downloadItem];
                if (!IS_M3U8(downloadItem.fileType)) { //非m3u8格式
                    [self beginDownloadTask:downloadItem];
                }
                else{
                    
                    [self beginM3u8DownloadTask:downloadItem];
                }
                break;
            }
        }
    }
    
}

-(void)startDownLoad{
        [lock_ lock];
        BOOL isDownloading = NO;
        for (AFDownloadRequestOperation  *downloadRequestOperation in downLoadQueue_){
            if ([downloadRequestOperation.operationStatus isEqualToString:@"loading"]) {
                isDownloading = YES;
                break;
            }
            
        }
        if (!isDownloading) {
            for (AFDownloadRequestOperation  *downloadRequestOperation in downLoadQueue_){
                if ([downloadRequestOperation.operationStatus isEqualToString:@"waiting"]/*|| [downloadRequestOperation.operationStatus isEqualToString:@"fail"]*/) {
                    if (!IS_M3U8(downloadRequestOperation.fileType)) { //非m3u8格式
                        [self beginDownloadTask:downloadRequestOperation];
                    }
                    else{
                    
                        [self beginM3u8DownloadTask:downloadRequestOperation];
                    }
                    
                    break;
                }
                
            }
        }
    [lock_ unlock];
}


//-(void)retry:(AFDownloadRequestOperation*)downloadRequestOperation{
//    if (![CommonMotheds isNetworkEnbled]) {
//        return;
//    }
//    if (retryCount_ > 3) {
//        return;
//    }
//    retryCount_ ++;
//    
//    
//    [self beginDownloadTask:newDownloadingOperation];
//}
-(void)beginDownloadTask:(AFDownloadRequestOperation*)downloadRequestOperation{
    __block AFDownloadRequestOperation *tempdownloadRequestOperation = downloadRequestOperation;
    [downloadRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([downLoadQueue_ containsObject:operation]) {
            [downLoadQueue_ removeObject:operation];
        }
    
        NSRange range = [downloadId_ rangeOfString:@"_"];
        if (range.location == NSNotFound){
             [self saveDataBaseIntable:@"DownloadItem" withId:downloadId_ withStatus:@"finish" withPercentage:100];
             [self.downLoadMGdelegate downloadFinishwithId:downloadId_ inClass:@"IphoneDownloadViewController"];
            
        }
        else{
            [self saveDataBaseIntable:@"SubdownloadItem" withId:downloadId_ withStatus:@"finish" withPercentage:100];
            [self.downLoadMGdelegate downloadFinishwithId:downloadId_ inClass:@"IphoneSubdownloadViewController"];
            
        }
        [self startDownLoad];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        [operation cancel];
      
        tempdownloadRequestOperation.operationStatus = @"fail";
           
//        if (retryCount_ <= 3) {
//            [self performSelector:@selector(retry:) withObject:tempdownloadRequestOperation afterDelay:10];
//        }
       // else{
        [self downloadFail:tempdownloadRequestOperation];
        NSRange range = [downloadId_ rangeOfString:@"_"];
        if (range.location == NSNotFound){
            [self saveDataBaseIntable:@"DownloadItem" withId:downloadId_ withStatus:@"fail" withPercentage:-1];
            [self.downLoadMGdelegate downloadFailedwithId:downloadId_ inClass:@"IphoneDownloadViewController"];
            
        }
        else{
            [self saveDataBaseIntable:@"SubdownloadItem" withId:downloadId_ withStatus:@"fail" withPercentage:-1];
            [self.downLoadMGdelegate downloadFailedwithId:downloadId_ inClass:@"IphoneSubdownloadViewController"];
        }

        //}
        
    [self startDownLoad];
    }];
    
    [downloadRequestOperation setProgressiveDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
        retryCount_ = 0;
        float percentDone = totalBytesReadForFile/(float)totalBytesExpectedToReadForFile;
           
            NSRange range = [downloadId_ rangeOfString:@"_"];
            if (range.location == NSNotFound) {
             int count = (int)(percentDone*100) - downloadItem_.percentage;
//                NSLog(@"!!!!!!!!!!!!!!!!%d",(int)(percentDone*100));
                
                if (count >= 1){
                    
                    [self.downLoadMGdelegate reFreshProgress:percentDone withId:downloadId_ inClass:@"IphoneDownloadViewController"];
                    if (count >=5) {
                        downloadItem_.percentage = (int)(percentDone*100);
                        [DatabaseManager update:downloadItem_];
                       //// [downloadItem_ save];
                        [self updateSapce];
                    }
                }
            }else{
                 int count = (int)(percentDone*100) - subdownloadItem_.percentage;
//                 NSLog(@"!!!!!!!!!!!!!!!!%d",(int)(percentDone*100));
                 
                  if (count >= 1) {
                    
                    [self.downLoadMGdelegate reFreshProgress:percentDone withId:downloadId_ inClass:@"IphoneSubdownloadViewController"];
                    if (count >=5) {
                        subdownloadItem_.percentage = (int)(percentDone*100);
                        [DatabaseManager update:subdownloadItem_];
                        ////[subdownloadItem_ save];
                        [self updateSapce];
                    }
                }
         }
            
      }];
    [downloadRequestOperation start];
    downloadId_ = downloadRequestOperation.operationId;
    downloadRequestOperation.operationStatus = @"loading";

     NSRange range = [downloadId_ rangeOfString:@"_"];
    if (range.location == NSNotFound) {
         NSString *query = [NSString stringWithFormat:@"WHERE itemId ='%@'",downloadId_];
        // NSArray *itemArr = [DownloadItem findByCriteria:query];
        NSArray *itemArr = [DatabaseManager findByCriteria:[DownloadItem class] queryString:query];
        if ([itemArr count]>0) {
            int percet = ((DownloadItem *)[itemArr objectAtIndex:0]).percentage;
             downloadItem_ = (DownloadItem *)[itemArr objectAtIndex:0];
            [self saveDataBaseIntable:@"DownloadItem" withId:downloadId_ withStatus:@"loading" withPercentage:percet];
        }
        else{
            [self saveDataBaseIntable:@"DownloadItem" withId:downloadId_ withStatus:@"loading" withPercentage:0];
        }
        
         [self.downLoadMGdelegate downloadBeginwithId:downloadId_ inClass:@"IphoneDownloadViewController"];

    }
    else{
        NSString *query = [NSString stringWithFormat:@"WHERE subitemId ='%@'",downloadId_];
        ////NSArray *itemArr = [SubdownloadItem findByCriteria:query];
        NSArray *itemArr = [DatabaseManager findByCriteria:[SubdownloadItem class] queryString:query];
        if ([itemArr count]>0) {
            int percet = ((SubdownloadItem *)[itemArr objectAtIndex:0]).percentage;
            subdownloadItem_ = (SubdownloadItem *)[itemArr objectAtIndex:0];
            [self saveDataBaseIntable:@"SubdownloadItem" withId:downloadId_ withStatus:@"loading" withPercentage:percet];
        }
        else{
            [self saveDataBaseIntable:@"SubdownloadItem" withId:downloadId_ withStatus:@"loading" withPercentage:0];
        }
        [self.downLoadMGdelegate downloadBeginwithId:downloadId_ inClass:@"IphoneSubdownloadViewController"];

    }
 
}

-(void)beginM3u8DownloadTask:(AFDownloadRequestOperation*)downloadRequestOperation{
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
                    
                    ////NSArray *segArr = [SegmentUrl findByCriteria:query];
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
                //[downloadItem save];
                
                [DatabaseManager update:downloadItem];
            
                [self saveDataBaseIntable:@"DownloadItem" withId:idstr withStatus:@"loading" withPercentage:0];
                [m3u8DownloadManager setM3u8DownloadData:idstr  withNum:@"1" url:url.absoluteString withOldPath:((AFDownloadRequestOperation *)operation).targetPath];
            }
            else{
                
                downloadItem.fileName = [NSString stringWithFormat:@"%@.m3u8",idstr];
                //[downloadItem save];
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

                NSRange range = [downloadId_ rangeOfString:@"_"];
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
                    downloadItem_ = item;
                }
               // downloadItem_ = item;
                //[item save];
                [DatabaseManager update:item];
                break;
            }
            
        }

    }
    else if ([tableName isEqualToString:@"SubdownloadItem"]){
        //allSubItems_ = [SubdownloadItem allObjects];
        allSubItems_ = [DatabaseManager allObjects:[SubdownloadItem class]];
        for (SubdownloadItem *item in allSubItems_) {
            if ([item.subitemId isEqualToString:itenId]){
                item.downloadStatus = status;
                if (percentage >= 0) {
                    item.percentage = percentage;
                }
                if (percentage == 0) {
                    subdownloadItem_ = item;
                }
                //subdownloadItem_ = item;
                //[item save];
                [DatabaseManager update:item];
                break;
            }
        }

    
    
    }

}


//停止下载并清除缓存
+(void)stopAndClear:(NSString *)downloadId{
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
        //[[DownLoadManager defaultDownLoadManager] waringReduce];
    }
    [[DownLoadManager defaultDownLoadManager] startDownLoad];
   
}

//停止下载不清除缓存
+(void)stop:(NSString *)downloadId{
    if ([DownLoadManager defaultDownLoadManager].downloadItem != nil) {
         //[[DownLoadManager defaultDownLoadManager].downloadItem save];
        [DatabaseManager update:[DownLoadManager defaultDownLoadManager].downloadItem];
    }
    
    if ([DownLoadManager defaultDownLoadManager].subdownloadItem != nil) {
        //[[DownLoadManager defaultDownLoadManager].subdownloadItem save];
        [DatabaseManager update:[DownLoadManager defaultDownLoadManager].subdownloadItem ];
    }
    
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
        
        BOOL isloading = NO;
        for (AFDownloadRequestOperation *mc in downLoadQueue_){
            if ([mc.operationStatus isEqualToString:@"loading"]) {
                isloading = YES;
                break;
            }
        }
        
        if (!isloading) {
            for (AFDownloadRequestOperation *mc in downLoadQueue_) {
                if (![mc.operationStatus isEqualToString:@"stop"]&&![mc.operationStatus isEqualToString:@"fail_1011"] ) {
                    if (!IS_M3U8(mc.fileType)) { //非m3u8格式
                        [downLoadManager_ beginDownloadTask:mc];
                    }
                    else{
                        
                        [downLoadManager_ beginM3u8DownloadTask:mc];
                    }
                    break;
                }
            }

        }
    }

}
+(void)continueDownload:(NSString *)downloadId{
    for (AFDownloadRequestOperation *mc in downLoadQueue_) {
        if ([mc.operationId isEqualToString:downloadId]) {
            mc.operationStatus = @"waiting";
            break;
        }
    
    }
    BOOL isLoading = NO;
    for (AFDownloadRequestOperation *mc in downLoadQueue_){
        if ([mc.operationStatus isEqualToString:@"loading"]) {
            isLoading = YES;
            break;
        }
    }
    if (!isLoading) {
        for (AFDownloadRequestOperation *mc in downLoadQueue_) {
            if (![mc.operationStatus isEqualToString:@"stop"]&&![mc.operationStatus isEqualToString:@"fail_1011"]) {
                if (!IS_M3U8(mc.fileType)) { //非m3u8格式
                    [[DownLoadManager defaultDownLoadManager] beginDownloadTask:mc];
                }
                else{
                    
                    [[DownLoadManager defaultDownLoadManager] beginM3u8DownloadTask:mc];
                }

                break;
            }
        }
    }
  
    
}

+(int)downloadTaskCount{
    int count = 0;
    for (DownloadItem *item in [DatabaseManager allObjects:[DownloadItem class]]) {
        if (![item.downloadStatus isEqualToString:@"finish"]&& item.downloadStatus != nil) {
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
-(void)pauseAllTask{
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
    
    for (AFDownloadRequestOperation  *downloadRequestOperation in downLoadQueue_){
        if ([downloadRequestOperation.operationStatus isEqualToString:@"loading"]) {
            if (!IS_M3U8(downloadRequestOperation.fileType)) { //非m3u8格式
                [self beginDownloadTask:downloadRequestOperation];
            }
            else{
                
                [self beginM3u8DownloadTask:downloadRequestOperation];
            }
           
            return;
        }
        
    }
    for (AFDownloadRequestOperation  *downloadRequestOperation in downLoadQueue_){
        if ([downloadRequestOperation.operationStatus isEqualToString:@"fail"]) {
            if (!IS_M3U8(downloadRequestOperation.fileType)) { //非m3u8格式
                [self beginDownloadTask:downloadRequestOperation];
            }
            else{
                
                [self beginM3u8DownloadTask:downloadRequestOperation];
            }
           
            return;
        }
        
    }
    
    for (AFDownloadRequestOperation  *downloadRequestOperation in downLoadQueue_){
        if ([downloadRequestOperation.operationStatus isEqualToString:@"waiting"]) {
            if (!IS_M3U8(downloadRequestOperation.fileType)) { //非m3u8格式
                [self beginDownloadTask:downloadRequestOperation];
            }
            else{
                
                [self beginM3u8DownloadTask:downloadRequestOperation];
            }
            
            return;
        }
        
        
    }
    
    
}
- (void)M3u8DownLoadreFreshProgress:(double)progress withId:(NSString *)itemId inClass:(NSString *)className{
    [self.downLoadMGdelegate reFreshProgress:progress withId:itemId inClass:className ];
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

-(void)networkChanged:(int)status{
    if (status == netWorkStatus) {
        return;
    }
    else{
        netWorkStatus = status;
        if(netWorkStatus == 0){
            [self pauseAllTask];
        }
        else{
            [self appDidEnterForeground];
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
-(void)setM3u8DownloadData:(NSString *)prodId withNum:(NSString *)num url:(NSString *)urlStr withOldPath:(NSString *)oldPath{
    NSArray *infoArr = [NSArray arrayWithObjects:prodId,num,urlStr,oldPath,nil];
    [self performSelectorInBackground:@selector(doInBackground:) withObject:infoArr];
}

-(void)doInBackground:(id)sender{
    NSLog(@"begin!!!!!!!!!!!!!!!!!!!!");
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
                    segmentDuration = [[stringContent substringFromIndex:startRange.location] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]].doubleValue;
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
    NSLog(@"end!!!!!!!!!!!!!!!!!!!!");
    [self startDownloadM3u8file:segmentUrlArray_ withId:prodId withNum:num];
   
}

-(void)startDownloadM3u8file:(NSArray *)urlArr withId:(NSString *)idStr withNum:(NSString *)num{
    NSArray *infoArr = [NSArray arrayWithObjects:urlArr,idStr,num,nil];
    //[self performSelectorInBackground:@selector(beginDownloadM3u8file:) withObject:infoArr];
    [self performSelector:@selector(beginDownloadM3u8file:) withObject:infoArr];
}

-(void)beginDownloadM3u8file:(NSArray *)infoArr{
    NSArray *urlArr = [infoArr objectAtIndex:0];
    NSString *idStr = [infoArr objectAtIndex:1];
    NSString *num = [infoArr objectAtIndex:2];
    
    downloadOperationQueue_ = [[NSOperationQueue alloc] init];
    [downloadOperationQueue_ setMaxConcurrentOperationCount:1];
    
    NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    
    
    NSRange range = [idStr rangeOfString:@"_"];
    if (range.location == NSNotFound) {
        NSString *query = [NSString stringWithFormat:@"WHERE itemId ='%@'",idStr];
       // NSArray *arr = [DownloadItem findByCriteria:query];
        NSArray *arr = [DatabaseManager findByCriteria:[DownloadItem class] queryString:query];
        if ([arr count]>0) {
            currentItem_ = [arr objectAtIndex:0];
        }
        
    }
    else{
        NSString *query = [NSString stringWithFormat:@"WHERE subitemId ='%@'",idStr];
        //NSArray *arr = [SubdownloadItem findByCriteria:query];
        NSArray *arr = [DatabaseManager findByCriteria:[SubdownloadItem class] queryString:query];
        if ([arr count]>0) {
            currentItem_ = [arr objectAtIndex:0];
        }
        
    }
    
    url_index = currentItem_.isDownloadingNum;
    for (int i = url_index;i<[urlArr count];i++) {
        SegmentUrl *segUrl = [urlArr objectAtIndex:i];
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
        NSString*filePath = [NSString stringWithFormat:@"%@/%@/%@/%i_%@", documentsDir,tempPath,subPath,(i+1), segmentName];
        AFDownloadRequestOperation *segmentDownloadingOp = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:filePath shouldResume:YES];
        segmentDownloadingOp.downloadingSegmentIndex = i;
        [segmentDownloadingOp setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            AFDownloadRequestOperation *tempDownloadRequestOperation = (AFDownloadRequestOperation*)operation;
            retryCount_ = 0;
            url_index = tempDownloadRequestOperation.downloadingSegmentIndex;
            NSLog(@"url_index is %d",url_index);
            NSLog(@"[urlArr count] is %d",[urlArr count]);
            if (tempDownloadRequestOperation.downloadingSegmentIndex == [urlArr count]-1){
                
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
                float percent =  url_index *1.0/[urlArr count];
                if (ENVIRONMENT == 0 ) {
                    NSLog(@"%f",percent);
                }
                currentItem_.isDownloadingNum = tempDownloadRequestOperation.downloadingSegmentIndex;
                currentItem_.percentage = (int)(percent*100);
                if (url_index % 5 == 0) {
                    //[currentItem_ save];
                    [DatabaseManager update:currentItem_];
                }
                
                if (range.location == NSNotFound){
                    
                    [self.m3u8DownLoadManagerDelegate M3u8DownLoadreFreshProgress:percent withId:idStr inClass:@"IphoneDownloadViewController"];
                    
                }
                else{
                    [self.m3u8DownLoadManagerDelegate M3u8DownLoadreFreshProgress:percent withId:idStr inClass:@"IphoneSubdownloadViewController"];
                }
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [operation cancel];
            [downloadOperationQueue_ cancelAllOperations];
            
            //            if (retryCount_ <= 3) {
            //                NSArray *tempArr = [NSArray arrayWithObjects:urlArr,idStr,num,nil];
            //                [self performSelector:@selector(retry:) withObject:tempArr afterDelay:10.0];
            //            }
            
            if (range.location == NSNotFound){
                
                [self.m3u8DownLoadManagerDelegate M3u8DownLoadFailedwithId:idStr inClass:@"IphoneDownloadViewController"];
                
            }
            else{
                [self.m3u8DownLoadManagerDelegate M3u8DownLoadFailedwithId:idStr inClass:@"IphoneSubdownloadViewController"];
                
            }
         
            
        }];
        [segmentDownloadingOp setProgressiveDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
            
        }];
        
        if (downloadOperationQueue_.operationCount > 0) {
            AFDownloadRequestOperation *lastOp=[[downloadOperationQueue_ operations] lastObject];
            [segmentDownloadingOp addDependency:lastOp];
        }
        [downloadOperationQueue_ addOperation:segmentDownloadingOp];
    }

}

-(void)retry:(id)sender{
    if ([CommonMotheds isNetworkEnbled]) {
        retryCount_++;
        NSArray *arr = (NSArray *)sender;
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
    [downloadOperationQueue_ cancelAllOperations];
}
-(void)saveCurrentInfo{
    if (currentItem_) {
         //[currentItem_ save];
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
-(void)checkDownloadUrls{
    NSDictionary *infoDic = oneEsp_;
    allUrls_ = [[NSMutableArray alloc] initWithCapacity:5];
    NSMutableArray *mp4UrlsArr = [[NSMutableArray alloc] initWithCapacity:5];
    NSMutableArray *m3u8UrlsArr = [[NSMutableArray alloc] initWithCapacity:5];
    
    NSArray *down_urlsArr = [infoDic objectForKey:@"down_urls"];
    for (NSDictionary *dic in down_urlsArr) {
        NSArray *oneSourceArr = [dic objectForKey:@"urls"];
        for (NSDictionary *oneUrlInfo in oneSourceArr) {
            NSString *tempUrl = [[oneUrlInfo objectForKey:@"url"] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
            NSString *type = [oneUrlInfo objectForKey:@"file"];
            NSDictionary *myDic = [NSDictionary dictionaryWithObjectsAndKeys:tempUrl,@"url",type,@"type", nil];
            if ([type isEqualToString:@"mp4"]) {
                [mp4UrlsArr addObject:myDic];
            }
            else if ([type isEqualToString:@"m3u8"]){
                [m3u8UrlsArr addObject:myDic];
            }
           
        }
        
    }
   [allUrls_ addObjectsFromArray:mp4UrlsArr];
   [allUrls_ addObjectsFromArray:m3u8UrlsArr];
    
//     NSDictionary *myDic = [NSDictionary dictionaryWithObjectsAndKeys:@"http://meta.video.qiyi.com/460/7c5df554d7d2477ab7c46d8195d670da.m3u8",@"url",@"m3u8",@"type", nil];
//    [allUrls_ addObject:myDic];
    sendCount_ = 0;
    [self saveDataBase];
    [self sendHttpRequest];
}

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

-(void)saveDataBase{
    NSString *prodId = [downloadInfoArr_ objectAtIndex:0];
    NSString *urlStr = @"";
    NSString *fileName = [downloadInfoArr_ objectAtIndex:1];
    NSString *imgUrl = [downloadInfoArr_ objectAtIndex:2];
    NSString *type = [downloadInfoArr_ objectAtIndex:3];
    int num = [[downloadInfoArr_ objectAtIndex:4] intValue];
    num++;
    NSString *fileType = @"";
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
        //[item save];
        [DatabaseManager save:item];
    } else {
        //NSArray *itemArr = [DownloadItem allObjects];
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
            //[item save];
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
        //[subItem save];
        [DatabaseManager save:subItem];
    }
      //[[DownLoadManager defaultDownLoadManager] waringPlus];
}

-(void)resetDataBase{
    NSString *prodId = [downloadInfoArr_ objectAtIndex:0];
    NSString *tempUrlStr = [[allUrls_ objectAtIndex:0] objectForKey:@"url"];
    NSString *type = [downloadInfoArr_ objectAtIndex:3];
    int num = [[downloadInfoArr_ objectAtIndex:4] intValue];
    num++;
    NSString *urlStr = [tempUrlStr stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
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
        if (![content_type hasPrefix:@"text/html"] && contentLength.intValue >100) {
      
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
            NSArray *arr = [NSArray arrayWithObjects:proid,urlStr,name,imgUrl,type,num,fileType,nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DOWNLOAD_MSG" object:arr];
            [connection cancel];
             [self.checkDownloadUrlsDelegate checkUrlsFinishWithId:self.checkIndex];
            return;
            
        }
        
    }
       [self sendHttpRequest];
    
}

-(void)dealloc{
    [currentConnection_ cancel];
    currentConnection_ = nil;
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
    check.checkIndex = arc4random()%1000000;
     //check.checkDownloadUrlsDelegate = self;
    [CheckDownloadUrlsManager startCheck];
    
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
@end
