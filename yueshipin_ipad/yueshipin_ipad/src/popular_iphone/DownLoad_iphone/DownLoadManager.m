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
#define IS_M3U8(str) [str isEqualToString:@"m3u8"] ? YES: NO
static DownLoadManager *downLoadManager_ = nil;
static NSMutableArray *downLoadQueue_ = nil;
@implementation DownLoadManager
@synthesize downloadThread = downloadThread_;
@synthesize downloadId = downloadId_;
@synthesize allItems = allItems_;
@synthesize allSubItems = allSubItems_;
@synthesize downloadItem = downloadItem_;
@synthesize subdownloadItem = subdownloadItem_;
@synthesize lock = lock_;
//@synthesize fileType = fileType_;
+(DownLoadManager *)defaultDownLoadManager{
    if (downLoadManager_ == nil) {
        downLoadManager_ = [[DownLoadManager alloc] init];
        [downLoadManager_ initDownLoadManager];
        
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
    if ([self getFreeSpace]< 500) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"剩余磁盘容量已不足500M." delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    NSArray *infoArr = (NSArray *)((NSNotification *)sender).object;
    NSString *prodId = [infoArr objectAtIndex:0];
    NSString *tempUrlStr = [infoArr objectAtIndex:1];
    NSString *urlStr = [tempUrlStr stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSString *fileName = [infoArr objectAtIndex:2];
    NSString *imgUrl = [infoArr objectAtIndex:3];
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
        DownloadItem *item = [[DownloadItem alloc]init];
        item.itemId = prodId;
        item.name = fileName;
        item.percentage = 0;
        item.type = 1;
        item.url = urlStr;
        item.imageUrl = imgUrl;
        item.downloadStatus = @"waiting";
        item.downloadType = fileType;
        [item save];
        if (!IS_M3U8(fileType)) {
            filePath = [NSString stringWithFormat:@"%@/%@.mp4", documentsDir,prodId];
        }
        else{
            NSString *subPath = [NSString stringWithFormat:@"%@_%d",prodId,num,nil];
            NSString * storeFileName = [urlStr lastPathComponent];
            filePath = [NSString stringWithFormat:@"%@/%@/%@/%@",documentsDir,prodId,subPath,storeFileName,nil];
            if (![[NSFileManager new] fileExistsAtPath:filePath isDirectory:NO]) {
                [[NSFileManager new] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
            }
        
        }
        downloadingOperation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:filePath shouldResume:YES];
        downloadingOperation.operationId = prodId;
        downloadingOperation.fileType = fileType;
        
    } else {
        NSArray *itemArr = [DownloadItem allObjects];
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
            [item save];
        }

        SubdownloadItem *subItem = [[SubdownloadItem alloc] init];
        subItem.itemId = prodId;
        subItem.percentage = 0;
        subItem.type = [type intValue];
        subItem.url = urlStr;
        subItem.imageUrl = imgUrl;
//        int num = [[infoArr objectAtIndex:5] intValue];
//        num++;
        subItem.name = fileName;
        subItem.subitemId = [NSString stringWithFormat:@"%@_%d",prodId,num];
        subItem.downloadStatus = @"waiting";
        subItem.downloadType = fileType;
        [subItem save];
        if (!IS_M3U8(fileType)) {
          filePath = [NSString stringWithFormat:@"%@/%@_%d.mp4", documentsDir, prodId,num];
        }
        else{
            NSString *subPath = [NSString stringWithFormat:@"%@_%d",prodId,num,nil];
            NSString * storeFileName = [urlStr lastPathComponent];
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
    
     [self waringPlus];
    
}

-(void)resumeDownLoad{
    [downLoadQueue_ removeAllObjects];
    NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    
    NSArray *allItems = [DownloadItem allObjects];
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
            NSString *subquery = [NSString stringWithFormat:@"WHERE item_id = '%@' AND download_status != '%@'", item.itemId,@"finish"];
            NSArray *tempArr = [SubdownloadItem findByCriteria:subquery];
            
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
                if ([downloadRequestOperation.operationStatus isEqualToString:@"waiting"]|| [downloadRequestOperation.operationStatus isEqualToString:@"fail"]) {
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

-(void)restartDownload{
     for (AFDownloadRequestOperation  *downloadRequestOperation in downLoadQueue_){
        if ([downloadRequestOperation.operationStatus isEqualToString:@"loading"]) {
            if (!IS_M3U8(downloadRequestOperation.fileType)) {
                [self beginDownloadTask:downloadRequestOperation];
            }
            else{
                [self beginM3u8DownloadTask:downloadRequestOperation];
            
            }
           
            return;
        }
        
    }
    for (AFDownloadRequestOperation  *downloadRequestOperation in downLoadQueue_){
         if ([downloadRequestOperation.operationStatus isEqualToString:@"waiting"]|| [downloadRequestOperation.operationStatus isEqualToString:@"fail"]) {
             if (!IS_M3U8(downloadRequestOperation.fileType)) {
                 [self beginDownloadTask:downloadRequestOperation];
             }
             else{
                 [self beginM3u8DownloadTask:downloadRequestOperation];
                 
             }
            return;
        }
        
    }
}

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
        [self waringReduce];
        [self startDownLoad];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [operation cancel];
        if (error.code == -1011) {
            tempdownloadRequestOperation.operationStatus = @"fail_1011";
            
            NSRange range = [downloadId_ rangeOfString:@"_"];
            if (range.location == NSNotFound){
                [self saveDataBaseIntable:@"DownloadItem" withId:downloadId_ withStatus:@"fail_1011" withPercentage:-1];
                [self.downLoadMGdelegate downloadUrlTnvalidWithId:downloadId_ inClass:@"IphoneDownloadViewController"];
                
            }
            else{
                [self saveDataBaseIntable:@"SubdownloadItem" withId:downloadId_ withStatus:@"fail_1011" withPercentage:-1];
                [self.downLoadMGdelegate downloadUrlTnvalidWithId:downloadId_ inClass:@"IphoneSubdownloadViewController"];
                
            }

            
        }
        else{
            tempdownloadRequestOperation.operationStatus = @"fail";
            NSRange range = [downloadId_ rangeOfString:@"_"];
            if (range.location == NSNotFound){
                [self saveDataBaseIntable:@"DownloadItem" withId:downloadId_ withStatus:@"fail" withPercentage:-1];
                [self.downLoadMGdelegate downloadFailedwithId:downloadId_ inClass:@"IphoneDownloadViewController"];
                
            }
            else{
                [self saveDataBaseIntable:@"SubdownloadItem" withId:downloadId_ withStatus:@"fail" withPercentage:-1];
                [self.downLoadMGdelegate downloadFailedwithId:downloadId_ inClass:@"IphoneSubdownloadViewController"];
                
            }
}
        if ([downLoadQueue_ containsObject:tempdownloadRequestOperation]) {
            [downLoadQueue_ removeObject:tempdownloadRequestOperation];
        }
        
        
        [self startDownLoad];
    }];
    
    [downloadRequestOperation setProgressiveDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
        
        float percentDone = totalBytesReadForFile/(float)totalBytesExpectedToReadForFile;
           
            NSRange range = [downloadId_ rangeOfString:@"_"];
            if (range.location == NSNotFound) {
             int count = (int)(percentDone*100) - downloadItem_.percentage;
//                NSLog(@"!!!!!!!!!!!!!!!!%d",(int)(percentDone*100));
                downloadItem_.percentage = (int)(percentDone*100);
                if (count >= 1){     
                    [self.downLoadMGdelegate reFreshProgress:percentDone withId:downloadId_ inClass:@"IphoneDownloadViewController"];
                    if (count >=5) {
                        [downloadItem_ save];
                    }
                }
            }else{
                 int count = (int)(percentDone*100) - subdownloadItem_.percentage;
//                 NSLog(@"!!!!!!!!!!!!!!!!%d",(int)(percentDone*100));
                 subdownloadItem_.percentage = (int)(percentDone*100);
                  if (count >= 1) {
                    [self.downLoadMGdelegate reFreshProgress:percentDone withId:downloadId_ inClass:@"IphoneSubdownloadViewController"];
                    if (count >=5) {
                        [subdownloadItem_ save];
                    }
                }
         }
            
      }];
    
    [downloadRequestOperation start];
    downloadId_ = downloadRequestOperation.operationId;
    downloadRequestOperation.operationStatus = @"loading";
     NSRange range = [downloadId_ rangeOfString:@"_"];
    if (range.location == NSNotFound) {
         NSString *query = [NSString stringWithFormat:@"WHERE item_id ='%@'",downloadId_];
         NSArray *itemArr = [DownloadItem findByCriteria:query];
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
        NSString *query = [NSString stringWithFormat:@"WHERE subitem_id ='%@'",downloadId_];
        NSArray *itemArr = [SubdownloadItem findByCriteria:query];
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
             NSString *query = [NSString stringWithFormat:@"WHERE item_id ='%@'",idstr];
            findArr = [DownloadItem findByCriteria:query];
            if ([findArr count]>0) {
                downloadItem = [findArr objectAtIndex:0];
                
                if ([downloadItem.fileName hasSuffix:@"m3u8"]) {
                    //resume download
                    [self saveDataBaseIntable:@"DownloadItem" withId:idstr withStatus:@"loading" withPercentage:downloadItem.percentage];
                    [self.downLoadMGdelegate downloadBeginwithId:idstr inClass:@"IphoneDownloadViewController"];
                    
                    NSArray *segArr = [SegmentUrl findByCriteria:query];
                    [downloadRequestOperation.m3u8MG startDownloadM3u8file:segArr withId:idstr withNum:@"1"];
                    return;
                }
                else{
                    // remove temp m3u8 file;
                
                    [self saveDataBaseIntable:@"DownloadItem" withId:idstr withStatus:@"loading" withPercentage:0];
                    [self.downLoadMGdelegate downloadBeginwithId:idstr inClass:@"IphoneDownloadViewController"];
                }
            }
            else{
            
            }
        }
        else{
            NSString *query = [NSString stringWithFormat:@"WHERE subitem_id ='%@'",idstr];
            findArr = [SubdownloadItem findByCriteria:query];
            if ([findArr count]>0) {
                downloadItem = [findArr objectAtIndex:0];
                if ([downloadItem.fileName hasSuffix:@"m3u8"]) {
                    //resume download
                    [self saveDataBaseIntable:@"SubdownloadItem" withId:idstr withStatus:@"loading" withPercentage:downloadItem.percentage];
                    [self.downLoadMGdelegate downloadBeginwithId:idstr inClass:@"IphoneSubdownloadViewController"];
                    NSArray *segArr = [SegmentUrl findByCriteria:[NSString stringWithFormat:@"WHERE item_id ='%@'",idstr]];
                    NSArray *tempArr = [idstr componentsSeparatedByString:@"_"];
                    [downloadRequestOperation.m3u8MG startDownloadM3u8file:segArr withId:idstr withNum:[tempArr objectAtIndex:1]];
                    return;
                }
                else{
                    [self saveDataBaseIntable:@"SubdownloadItem" withId:idstr withStatus:@"loading" withPercentage:0];
                    [self.downLoadMGdelegate downloadBeginwithId:idstr inClass:@"IphoneSubdownloadViewController"];
                }
            }
            else{
                
            }
        
        }
         
        [downloadRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
            NSLog(@"download m3u8 playList succeed");
            NSURL *url = operation.request.URL;
            if (range.location == NSNotFound){
                downloadItem.fileName = [NSString stringWithFormat:@"%@_1.m3u8",idstr];
                [downloadItem save];
            
                [self saveDataBaseIntable:@"DownloadItem" withId:idstr withStatus:@"loading" withPercentage:0];
                [self.downLoadMGdelegate downloadBeginwithId:idstr inClass:@"IphoneDownloadViewController"];
                [m3u8DownloadManager setM3u8DownloadData:idstr  withNum:@"1" url:url.absoluteString withOldPath:((AFDownloadRequestOperation *)operation).targetPath];
            }
            else{
                
                downloadItem.fileName = [NSString stringWithFormat:@"%@.m3u8",idstr];
                [downloadItem save];
                [self saveDataBaseIntable:@"SubdownloadItem" withId:idstr withStatus:@"loading" withPercentage:0];
                [self.downLoadMGdelegate downloadBeginwithId:idstr inClass:@"IphoneSubdownloadViewController"];
                NSArray *arr  = [idstr componentsSeparatedByString:@"_"];
                [m3u8DownloadManager setM3u8DownloadData:idstr  withNum:[arr objectAtIndex:1] url:url.absoluteString  withOldPath:((AFDownloadRequestOperation *)operation).targetPath];
            }
            
        }
        
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"failure:%@",error);
            [operation cancel];
            if (error.code == -1011) {
                tempdownloadRequestOperation.operationStatus = @"fail_1011";
                
                NSRange range = [tempdownloadRequestOperation.operationId rangeOfString:@"_"];
                if (range.location == NSNotFound){
                    [self saveDataBaseIntable:@"DownloadItem" withId:tempdownloadRequestOperation.operationId withStatus:@"fail_1011" withPercentage:-1];
                    [self.downLoadMGdelegate downloadUrlTnvalidWithId:tempdownloadRequestOperation.operationId inClass:@"IphoneDownloadViewController"];
                    
                }
                else{
                    [self saveDataBaseIntable:@"SubdownloadItem" withId:tempdownloadRequestOperation.operationId withStatus:@"fail_1011" withPercentage:-1];
                    [self.downLoadMGdelegate downloadUrlTnvalidWithId:tempdownloadRequestOperation.operationId inClass:@"IphoneSubdownloadViewController"];
                    
                }
                
                
            }
            else{
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
            }
            if ([downLoadQueue_ containsObject:tempdownloadRequestOperation]) {
                [downLoadQueue_ removeObject:tempdownloadRequestOperation];
            }
            
            
            [self startDownLoad];

            
        }];
    
       [downloadRequestOperation setProgressiveDownloadProgressBlock:nil];
       [downloadRequestOperation start];
}
-(void)saveDataBaseIntable:(NSString *)tableName withId:(NSString *)itenId withStatus:(NSString *)status withPercentage:(int)percentage{
    if ([tableName isEqualToString:@"DownloadItem"]) {
        allItems_ = [DownloadItem allObjects];
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
                [item save];
                break;
            }
            
        }

    }
    else if ([tableName isEqualToString:@"SubdownloadItem"]){
        allSubItems_ = [SubdownloadItem allObjects];
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
                [item save];
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
    }
    [[DownLoadManager defaultDownLoadManager] startDownLoad];
    [[DownLoadManager defaultDownLoadManager] waringReduce];
}

//停止下载不清除缓存
+(void)stop:(NSString *)downloadId{
    if ([DownLoadManager defaultDownLoadManager].downloadItem != nil) {
         [[DownLoadManager defaultDownLoadManager].downloadItem save];
    }
    
    if ([DownLoadManager defaultDownLoadManager].subdownloadItem != nil) {
        [[DownLoadManager defaultDownLoadManager].subdownloadItem save];
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
    for (AFDownloadRequestOperation *mc in downLoadQueue_) {
        if (![mc.operationStatus isEqualToString:@"finish" ]) { //0:stop 1:start 2:done 3: waiting 4:error
            count++;
        }
    }
    return count;
}
-(void)appDidEnterBackground{
    for (AFDownloadRequestOperation *mc in downLoadQueue_){
        
        if (IS_M3U8(mc.fileType) && mc.m3u8MG != nil) {
            [mc.m3u8MG stop];
        }
        else{
            [mc pause];
            [mc cancel];
        }
    }
}
-(void)appDidEnterForeground{
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
}
- (void)M3u8DownLoadFailedwithId:(NSString *)itemId inClass:(NSString *)className{
    
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
    [self waringReduce];
    [self startDownLoad];
    
}

-(void)networkChanged:(int)status{
    if (status == netWorkStatus) {
        return;
    }
    else{
        netWorkStatus = status;
        if(netWorkStatus == 0){
            [self appDidEnterBackground];
        }
        else{
            [self appDidEnterForeground];
        }
    }
}
-(float)getFreeSpace{
    NSError *error = nil;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
          
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
       return [freeFileSystemSizeInBytes floatValue]/1024.0f/1024.0f;
    }
    return 0.0;


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
-(void)setM3u8DownloadData:(NSString *)prodId withNum:(NSString *)num url:(NSString *)urlStr withOldPath:(NSString *)oldPath{
    
    NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    NSString *subPath = nil;
    NSRange range = [prodId rangeOfString:@"_"];
    NSString *tempPath = nil;
    DownloadItem *downloadItem = nil;
    if (range.location == NSNotFound) {
        subPath = [NSString stringWithFormat:@"%@_%@",prodId,num,nil];
        tempPath = prodId;
        NSString *query = [NSString stringWithFormat:@"WHERE item_id ='%@'",prodId];
        NSArray *arr = [DownloadItem findByCriteria:query];
        if ([arr count]>0) {
            downloadItem = [arr objectAtIndex:0];
        }
    }
    else{
        subPath = prodId;
        tempPath = [[prodId componentsSeparatedByString:@"_"] objectAtIndex:0];
        NSString *query = [NSString stringWithFormat:@"WHERE subitem_id ='%@'",prodId];
        NSArray *arr = [SubdownloadItem findByCriteria:query];
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
    [downloadItem save];
    
    NSMutableArray *segmentUrlArray = [[NSMutableArray alloc]initWithCapacity:videoArray.count];
    for (int i = 0; i < videoArray.count; i++) {
        SegmentUrl *segUrl = [[SegmentUrl alloc]init];
        segUrl.itemId = prodId;
        
        segUrl.url = [videoArray objectAtIndex:i];
        segUrl.seqNum = i;
        [segUrl save];
        [segmentUrlArray addObject:segUrl];
    }
    [self startDownloadM3u8file:segmentUrlArray withId:prodId withNum:num];
}

-(void)startDownloadM3u8file:(NSArray *)urlArr withId:(NSString *)idStr withNum:(NSString *)num{
    
    downloadOperationQueue_ = [[NSOperationQueue alloc] init];
    [downloadOperationQueue_ setMaxConcurrentOperationCount:1];
    
    NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    
   
    NSRange range = [idStr rangeOfString:@"_"];
    if (range.location == NSNotFound) {
         NSString *query = [NSString stringWithFormat:@"WHERE item_id ='%@'",idStr];
         NSArray *arr = [DownloadItem findByCriteria:query];
        if ([arr count]>0) {
            currentItem_ = [arr objectAtIndex:0];
        }
        
    }
    else{
         NSString *query = [NSString stringWithFormat:@"WHERE subitem_id ='%@'",idStr];
         NSArray *arr = [SubdownloadItem findByCriteria:query];
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
        [segmentDownloadingOp setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            url_index++;
            
            if (url_index == [urlArr count]){
            
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
                NSLog(@"%f",percent);
                currentItem_.isDownloadingNum = url_index;             
                currentItem_.percentage = (int)(percent*100);
                if (url_index % 5 == 0) {
                    [currentItem_ save];
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

-(void)saveDataBaseIntable:(NSString *)tableName withId:(NSString *)itemId withStatus:(NSString *)status withPercentage:(int)percentage{
    if ([tableName isEqualToString:@"DownloadItem"]) {
      NSString *query = [NSString stringWithFormat:@"WHERE item_id ='%@'",itemId];
      NSArray *itemArr = [DownloadItem findByCriteria:query];
        if ([itemArr count]>0) {
            DownloadItem *item = (DownloadItem *)[itemArr objectAtIndex:0];
            item.downloadStatus = status;
            item.percentage = percentage;
            [item save];
        }
    }
    else if ([tableName isEqualToString:@"SubdownloadItem"]){
        NSString *query = [NSString stringWithFormat:@"WHERE subitem_id ='%@'",itemId];
        NSArray *itemArr = [SubdownloadItem findByCriteria:query];
        if ([itemArr count]> 0) {
            SubdownloadItem *item = (SubdownloadItem *)[itemArr objectAtIndex:0];
            item.downloadStatus = status;
            item.percentage = percentage;
            [item save];
        }   
    }
}
-(void)stop{
    [downloadOperationQueue_ cancelAllOperations];
}
-(void)saveCurrentInfo{
    if (currentItem_) {
         [currentItem_ save];
    }
}

@end



@implementation CheckDownloadUrls
@synthesize myConditionArr = myConditionArr_;
@synthesize downloadInfoArr = downloadInfoArr_;
@synthesize fileType = fileType_;
@synthesize allUrls = allUrls_;
-(void)checkDownloadUrls:(NSDictionary *)infoDic{
    allUrls_ = [[NSMutableArray alloc] initWithCapacity:5];
    myConditionArr_ = [[NSMutableArray alloc] initWithCapacity:5];
    NSArray *down_urlsArr = [infoDic objectForKey:@"down_urls"];
    for (NSDictionary *dic in down_urlsArr) {
        NSArray *oneSourceArr = [dic objectForKey:@"urls"];
        for (NSDictionary *oneUrlInfo in oneSourceArr) {
            NSString *tempUrl = [[oneUrlInfo objectForKey:@"url"] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
            NSString *type = [oneUrlInfo objectForKey:@"file"];
            NSDictionary *myDic = [NSDictionary dictionaryWithObjectsAndKeys:tempUrl,@"url",type,@"type", nil];
            
            [allUrls_ addObject:myDic];
        }
        
    }
//     NSDictionary *myDic = [NSDictionary dictionaryWithObjectsAndKeys:@"http://v.youku.com/player/getM3U8/vid/127814846/type/flv/ts/%7Bnow_date%7D/useKeyframe/0/v.m3u8",@"url",@"m3u8",@"type", nil];
    //[allUrls_ addObject:myDic];
    reponseCount_ = 0;
    isReceiveR_ = NO;
    for (NSDictionary *dic  in allUrls_) {
        NSString *tempStr = [dic objectForKey:@"url"];
        NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:tempStr] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
         NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
        [myConditionArr_  addObject:connection];
        
    }
}



-(void)saveDataBase{
    NSString *prodId = [downloadInfoArr_ objectAtIndex:0];
    NSString *tempUrlStr = [[allUrls_ objectAtIndex:0] objectForKey:@"url"];
    NSString *urlStr = [tempUrlStr stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSString *fileName = [downloadInfoArr_ objectAtIndex:1];
    NSString *imgUrl = [downloadInfoArr_ objectAtIndex:2];
    NSString *type = [downloadInfoArr_ objectAtIndex:3];
    int num = [[downloadInfoArr_ objectAtIndex:4] intValue];
    num++;
    NSString *fileType = nil;
    for (NSDictionary *dic  in allUrls_) {
        NSString *str = [dic objectForKey:@"url"];
        if ([str isEqualToString:urlStr]) {
            fileType = [dic objectForKey:@"type"];
            break;
        }
    }
    
    if ([type isEqualToString:@"1"]){
        DownloadItem *item = [[DownloadItem alloc]init];
        item.itemId = prodId;
        item.name = fileName;
        item.percentage = -1;
        item.type = 1;
        item.url = urlStr;
        item.imageUrl = imgUrl;
        item.downloadStatus = @"fail_1011";
        item.downloadType = fileType;
        [item save];
        [[DownLoadManager defaultDownLoadManager].downLoadMGdelegate  downloadUrlTnvalidWithId:prodId inClass:@"IphoneDownloadViewController"];
        [[DownLoadManager defaultDownLoadManager] waringPlus];
    } else {
        NSArray *itemArr = [DownloadItem allObjects];
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
            [item save];
        }
        
        SubdownloadItem *subItem = [[SubdownloadItem alloc] init];
        subItem.itemId = prodId;
        subItem.percentage = -1;
        subItem.type = [type intValue];
        subItem.url = urlStr;
        subItem.imageUrl = imgUrl;
        subItem.name = fileName;
        subItem.subitemId = [NSString stringWithFormat:@"%@_%d",prodId,num];
        subItem.downloadStatus = @"fail_1011";
        subItem.downloadType = fileType;
        [subItem save];
       
        [[DownLoadManager defaultDownLoadManager].downLoadMGdelegate  downloadUrlTnvalidWithId:prodId inClass:@"IphoneSubdownloadViewController"];
        [[DownLoadManager defaultDownLoadManager] waringPlus];
    }


}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    reponseCount_ ++;
    if (reponseCount_ == [myConditionArr_ count]) {
        [self saveDataBase];
        
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    if (isReceiveR_) {
        return;
    }
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
    int status_Code = HTTPResponse.statusCode;
    if (status_Code >= 200 && status_Code <= 299) {
        NSDictionary *headerFields = [HTTPResponse allHeaderFields];
        NSString *content_type = [headerFields objectForKey:@"Content-Type"];
         NSString *contentLength = [headerFields objectForKey:@"Content-Length"];
        if (![content_type hasPrefix:@"text/html"] && contentLength.intValue >100) {
            isReceiveR_ = YES;
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
            return;
        }
        
    }
    
    reponseCount_++;
    if (reponseCount_ == [myConditionArr_ count]) {
        [self saveDataBase];        
    }
}
-(void)cancelAllconnection{
    
    for (NSURLConnection *c in myConditionArr_) {
        [c cancel];
    }
}
-(void)dealloc{
    [self cancelAllconnection];
    myConditionArr_ = nil;
}
@end
