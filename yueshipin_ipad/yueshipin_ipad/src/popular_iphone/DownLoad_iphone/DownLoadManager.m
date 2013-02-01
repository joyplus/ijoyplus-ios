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
static DownLoadManager *downLoadManager_ = nil;
static NSMutableArray *downLoadQueue_ = nil;
@implementation DownLoadManager
@synthesize downloadThread = downloadThread_;
@synthesize downloadId = downloadId_;
@synthesize allItems = allItems_;
@synthesize allSubItems = allSubItems_;
@synthesize downloadItem = downloadItem_;
@synthesize subdownloadItem = subdownloadItem_;
+(DownLoadManager *)defaultDownLoadManager{
    if (downLoadManager_ == nil) {
        downLoadManager_ = [[DownLoadManager alloc] init];
        [downLoadManager_ initDownLoadManager];
    }
    return downLoadManager_;
}

-(void)initDownLoadManager{
    downLoadQueue_ = [[NSMutableArray alloc] initWithCapacity:10];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(addtoDownLoadQueue:) name:@"DOWNLOAD_MSG" object:nil];
}

-(void)addtoDownLoadQueue:(id)sender{
    NSArray *infoArr = (NSArray *)((NSNotification *)sender).object;
    NSString *prodId = [infoArr objectAtIndex:0];
    NSString *urlStr = [infoArr objectAtIndex:1];
    NSString *fileName = [infoArr objectAtIndex:2];
    NSString *imgUrl = [infoArr objectAtIndex:3];
    NSString *type = [infoArr objectAtIndex:4];
    
    if ([type isEqualToString:@"1"]) {
        McDownload *mcDownload = [[McDownload alloc] init];
        mcDownload.delegate = self;
        mcDownload.idNum = prodId;
        mcDownload.url = [NSURL URLWithString:urlStr];
        mcDownload.fileName = [fileName stringByAppendingFormat:@"%@",@".mp4"];
        mcDownload.status = 3;
        [downLoadQueue_ addObject:mcDownload];
        
        DownloadItem *item = [[DownloadItem alloc]init];
        item.itemId = prodId;
        item.name = fileName;
        item.percentage = 0;
        item.type = 1;
        item.url = urlStr;
        item.imageUrl = imgUrl;
        item.downloadStatus = @"wait";
        [item save];
    }
    else{
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
            item.name = fileName;
            item.imageUrl = imgUrl;
            [item save];
        }
        SubdownloadItem *subItem = [[SubdownloadItem alloc] init];
        subItem.itemId = prodId;
        subItem.percentage = 0;
        subItem.type = [type intValue];
        subItem.url = urlStr;
        subItem.imageUrl = imgUrl;
        int num = [[infoArr objectAtIndex:5] intValue];
        num++;
        subItem.name = [fileName stringByAppendingFormat:@"_%d",num];
        subItem.subitemId = [prodId stringByAppendingFormat:@"_%d",num];
        subItem.downloadStatus = @"wait";
        [subItem save];
        
        McDownload *mcDownload = [[McDownload alloc] init];
        mcDownload.delegate = self;
        mcDownload.idNum =[prodId stringByAppendingFormat:@"_%d",num];
        mcDownload.url = [NSURL URLWithString:urlStr];
        mcDownload.fileName = [fileName stringByAppendingFormat:@"_%d%@",num,@".mp4"];
        mcDownload.status = 3;
        [downLoadQueue_ addObject:mcDownload];
    }

    
        [self startDownLoad];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SET_WARING_NUM" object:nil];
    
}

-(void)resumeDownLoad{
 NSArray *allItems = [DownloadItem allObjects];
    for ( DownloadItem *item in allItems) {
        if (item.type == 1) {
            if (![item.downloadStatus isEqualToString:@"finish"]) {
                McDownload *mcDownload = [[McDownload alloc] init];
                mcDownload.delegate = self;
                mcDownload.idNum = item.itemId;
                mcDownload.url = [NSURL URLWithString:item.url];
                mcDownload.fileName = [item.name stringByAppendingString:@".mp4"];
                if ([item.downloadStatus isEqualToString:@"stop"]) {
                    mcDownload.status = 0;
                }
                else if ([item.downloadStatus isEqualToString:@"loading"]) {
                    mcDownload.status = 1;
                }
                else if ([item.downloadStatus isEqualToString:@"finish"]) {
                    mcDownload.status = 2;
                }
                else if ([item.downloadStatus isEqualToString:@"wait"]) {
                    mcDownload.status = 3;
                }
                else if ([item.downloadStatus isEqualToString:@"fail"]) {
                    mcDownload.status = 4;
                }
                [downLoadQueue_ addObject:mcDownload];
            }
        }
        else{
            NSString *subquery = [NSString stringWithFormat:@"WHERE item_id = '%@' AND download_status != '%@'", item.itemId,@"finish"];
            NSArray *tempArr = [SubdownloadItem findByCriteria:subquery];
            
            for (SubdownloadItem *sub in tempArr) {
                McDownload *mcDownload = [[McDownload alloc] init];
                mcDownload.delegate = self;
                mcDownload.idNum = sub.subitemId;
                mcDownload.url = [NSURL URLWithString:sub.url];
                mcDownload.fileName = [sub.name stringByAppendingString:@".mp4"];
                if ([sub.downloadStatus isEqualToString:@"stop"]) {
                    mcDownload.status = 0;
                }
                else if ([sub.downloadStatus isEqualToString:@"loading"]) {
                    mcDownload.status = 1;
                }
                else if ([sub.downloadStatus isEqualToString:@"finish"]) {
                    mcDownload.status = 2;
                }
                else if ([sub.downloadStatus isEqualToString:@"wait"]) {
                    mcDownload.status = 3;
                }
                else if ([sub.downloadStatus isEqualToString:@"fail"]) {
                    mcDownload.status = 4;
                }

                [downLoadQueue_ addObject:mcDownload];
                
            }
        
        }
    
    
    }
    BOOL isdownloading = NO;
    for (McDownload *downloadItem in downLoadQueue_) {
        if (downloadItem.status == 1 ) {    //0:stop 1:start 2:done 3: waiting 4:error
            [downloadItem start];
            isdownloading = YES;
            break;
        }
    }
    
    if (!isdownloading) {
        for (McDownload *downloadItem in downLoadQueue_) {
            if (downloadItem.status == 3 || downloadItem.status == 4 ) {    //0:stop 1:start 2:done 3: waiting 4:error
                [downloadItem start];
                break;
            }
        }
    }
    
}

-(void)startDownLoad{
    BOOL isDownloading = NO;
    for (McDownload *downloadItem in downLoadQueue_){
        if (downloadItem.status == 1) {
            isDownloading = YES;
            break;
        }
    
    }
    if (!isDownloading) {
        for (McDownload *downloadItem in downLoadQueue_) {
            if (/*downloadItem.status == 1 ||*/ downloadItem.status == 3 || downloadItem.status == 4 ) {
                [downloadItem start];
                 break;
            }
        }
    }
    
}

#pragma mark -
#pragma mark McDownloadDelegate
//下载开始
- (void)downloadBegin:(McDownload *)aDownload didReceiveResponseHeaders:(NSURLResponse *)responseHeaders{
    downloadId_ = aDownload.idNum;
    aDownload.status = 1;
    NSRange range = [aDownload.idNum rangeOfString:@"_"];
    if (range.location == NSNotFound) {
        allItems_ = [DownloadItem allObjects];
        for (DownloadItem *item in allItems_) {
                if ([item.itemId isEqualToString:aDownload.idNum]) {
                    item.downloadStatus = @"loading";
                    item.percentage = 0;
                    downloadItem_ = item;
                    [item save];
                    [self.downLoadMGdelegate downloadBeginwithId:item.itemId inClass:@"IphoneDownloadViewController"];
                    break;
                }
                    
        }
    }
   else{
        allSubItems_ = [SubdownloadItem allObjects];
        for (SubdownloadItem *item in allSubItems_) {
                if ([item.subitemId isEqualToString:aDownload.idNum]) {
                    item.downloadStatus = @"loading";
                    item.percentage = 0;
                    subdownloadItem_ = item;
                    [item save];
                    [self.downLoadMGdelegate downloadBeginwithId:item.subitemId inClass:@"IphoneSubdownloadViewController"];
                    break;
                }
        }
    
    }

}

//下载失败
- (void)downloadFaild:(McDownload *)aDownload didFailWithError:(NSError *)error{
    aDownload.status = 4;
    NSRange range = [aDownload.idNum rangeOfString:@"_"];
    if (range.location == NSNotFound){
        NSArray *allItems = [DownloadItem allObjects];
        for (DownloadItem *item in allItems) {
            if ([item.itemId isEqualToString:aDownload.idNum]) {
                item.downloadStatus = @"fail";
                [item save];
                [self.downLoadMGdelegate downloadFailedwithId:item.itemId inClass:@"IphoneDownloadViewController"];
                break;
            }
        }
      

    }
    else{
    
        NSArray *allItems = [SubdownloadItem allObjects];
        for (SubdownloadItem *item in allItems) {
            if ([item.subitemId isEqualToString:aDownload.idNum]) {
                item.downloadStatus = @"fail";
                [item save];
                [self.downLoadMGdelegate downloadFailedwithId:item.subitemId inClass:@"IphoneSubdownloadViewController"];
                break;
            }
        }

    }
    
    if ([downLoadQueue_ containsObject:aDownload]) {
        int index = [downLoadQueue_ indexOfObject:downLoadQueue_];
        index++;
        if (index < [downLoadQueue_ count]) {
            McDownload *mcdownload = [downLoadQueue_ objectAtIndex:index];
            [mcdownload start];
        }
    }
    
}

//下载结束
- (void)downloadFinished:(McDownload *)aDownload{
    if ([downLoadQueue_ containsObject:aDownload]) {
        [downLoadQueue_ removeObject:aDownload];
    }
    
    NSRange range = [aDownload.idNum rangeOfString:@"_"];
    if (range.location == NSNotFound){
        NSArray *allItems = [DownloadItem allObjects];
        for (DownloadItem *item in allItems) {
            if ([item.itemId isEqualToString:aDownload.idNum]) {
                item.downloadStatus = @"finish";
                item.percentage = 100;
                [self.downLoadMGdelegate downloadFinishwithId:item.itemId inClass:@"IphoneDownloadViewController"];
                [item save];
                break;
            }
        }
        
    }
    else{
        
        NSArray *allItems = [SubdownloadItem allObjects];
        for (SubdownloadItem *item in allItems) {
            if ([item.subitemId isEqualToString:aDownload.idNum]) {
                item.downloadStatus = @"finish";
                 item.percentage = 100;
                [self.downLoadMGdelegate downloadFinishwithId:item.subitemId inClass:@"IphoneSubdownloadViewController"];
                //[item save];
                break;
            }
        }
        
    }

    [self startDownLoad];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SET_WARING_NUM" object:nil];
}
//更新下载的进度
- (void)downloadProgressChange:(McDownload *)aDownload progress:(double)newProgress{
    if (aDownload.idNum != downloadId_) {
        return;
    }
   
    NSRange range = [aDownload.idNum rangeOfString:@"_"];
    if (range.location == NSNotFound){
        int count = (int)(newProgress*100) - downloadItem_.percentage;
        if (count >= 1){
        [self.downLoadMGdelegate reFreshProgress:newProgress withId:downloadId_ inClass:@"IphoneDownloadViewController"];
             NSLog(@"!!!!!!!!!!!!!!!!%d",(int)(newProgress*100));
            downloadItem_.percentage = (int)(newProgress*100);
            if (count >=5) {
                [downloadItem_ save];
            }
        }
        
    }
    else{

//        NSString *subquery = [NSString stringWithFormat:@"WHERE subitem_id = '%@'", aDownload.idNum];
//        NSArray *tempArr = [SubdownloadItem findByCriteria:subquery];
//        if (tempArr != nil && [tempArr count]>0) {
//             SubdownloadItem *item = [tempArr objectAtIndex:0];
//            int oldProgress = item.percentage;
//            if (((int)(newProgress*100) - oldProgress) >= 1) {
//                item.percentage = (int)(newProgress*100);
//                [self.downLoadMGdelegate reFreshProgress:newProgress withId:item.subitemId inClass:@"IphoneSubdownloadViewController"];
//                //[item save];
//            }
//
//        }
        int count = (int)(newProgress*100) - subdownloadItem_.percentage;
        if (count >= 1){
            [self.downLoadMGdelegate reFreshProgress:newProgress withId:downloadId_ inClass:@"IphoneSubdownloadViewController"];
             NSLog(@"!!!!!!!!!!!!!!!!%d",(int)(newProgress*100));
            subdownloadItem_.percentage = (int)(newProgress*100);
            if (count >=5) {
                [subdownloadItem_ save];
            }
        }
        
        
    }
}

//停止下载并清除缓存
+(void)stopAndClear:(NSString *)downloadId{
    McDownload *mcDownload = nil;
    for (McDownload *mc in downLoadQueue_) {
        if ([mc.idNum isEqualToString:downloadId]) {
            mcDownload = mc;
            break;
        }
    }
    if (mcDownload != nil) {
         [mcDownload stopAndClear];
        [downLoadQueue_ removeObject:mcDownload];
    }
    [[DownLoadManager defaultDownLoadManager] startDownLoad];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SET_WARING_NUM" object:nil];
}

//停止下载不清除缓存
+(void)stop:(NSString *)downloadId{
    if ([DownLoadManager defaultDownLoadManager].downloadItem != nil) {
         [[DownLoadManager defaultDownLoadManager].downloadItem save];
    }
    
    if ([DownLoadManager defaultDownLoadManager].subdownloadItem != nil) {
        [[DownLoadManager defaultDownLoadManager].subdownloadItem save];
    }
    
    McDownload *mcDownload = nil;
    for (McDownload *mc in downLoadQueue_) {
        if ([mc.idNum isEqualToString:downloadId]) {
            mcDownload = mc;
            break;
        }
    }
    if (mcDownload != nil) {
        [mcDownload stop];
        mcDownload.status = 0;
        for (McDownload *mc in downLoadQueue_) {
            if (mc.status != 0 && mc.status != 4) {//0:stop 1:start 2:done 3: waiting 4:error
                [mc start];
                break;
            }
        }
    }

}
+(void)continueDownload:(NSString *)downloadId{
    for (McDownload *mc in downLoadQueue_) {
        if ([mc.idNum isEqualToString:downloadId]) {
            mc.status = 3;
            break;
        }
    
    }
    BOOL isLoading = NO;
    for (McDownload *mc in downLoadQueue_){
        if (mc.status == 1) {
            isLoading = YES;
            break;
        }
    }
    if (!isLoading) {
        for (McDownload *mc in downLoadQueue_) {
            if (mc.status != 0 && mc.status != 4) {
                [mc start];
                break;
            }
        }
    }
    
}

+(int)downloadTaskCount{
    int count = 0;
    for (McDownload *mc in downLoadQueue_) {
        if (mc.status != 2) { //0:stop 1:start 2:done 3: waiting 4:error
            count++;
        }
    }
    return count;
}
@end
