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

    if([downLoadQueue_ count] == 1){
        [self startDownLoad];
    }
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
    
    
    }
    [self startDownLoad];
}

-(void)startDownLoad{
//    if ([downLoadQueue_ count]>=1) {
//        McDownload *downloadItem = [downLoadQueue_ objectAtIndex:0];
//        [downloadItem start];
//    }
    for (McDownload *downloadItem in downLoadQueue_) {
        if (downloadItem.status == 1 || downloadItem.status == 3 || downloadItem.status == 4 ) {
            [downloadItem start];
        }
    }
}

#pragma mark -
#pragma mark McDownloadDelegate
//下载开始
- (void)downloadBegin:(McDownload *)aDownload didReceiveResponseHeaders:(NSURLResponse *)responseHeaders{
    aDownload.status = 1;
    NSRange range = [aDownload.idNum rangeOfString:@"_"];
    if (range.location == NSNotFound) {
        NSArray *allItems = [DownloadItem allObjects];
        for (DownloadItem *item in allItems) {
                if ([item.itemId isEqualToString:aDownload.idNum]) {
                    item.downloadStatus = @"loading";
                    item.percentage = 0;
                    [item save];
                    break;
                }
                    
        }
    }
   else{
        NSArray *allItems = [SubdownloadItem allObjects];
        for (SubdownloadItem *item in allItems) {
                if ([item.subitemId isEqualToString:aDownload.idNum]) {
                    item.downloadStatus = @"loading";
                    item.percentage = 0;
                    [item save];
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
                [item save];
                break;
            }
        }
        
    }

    [self startDownLoad];
}
//更新下载的进度
- (void)downloadProgressChange:(McDownload *)aDownload progress:(double)newProgress{

    NSLog(@"!!!!!!!!!!!!!!!!%d",(int)(newProgress*100));
    
    NSRange range = [aDownload.idNum rangeOfString:@"_"];
    if (range.location == NSNotFound){
        NSArray *allItems = [DownloadItem allObjects];
        for (DownloadItem *item in allItems) {
            if ([item.itemId isEqualToString:aDownload.idNum]) {
                int oldProgress = item.percentage;
                if (((int)(newProgress*100) - oldProgress) >= 1) {
                    item.percentage = (int)(newProgress*100);
                    [self.downLoadMGdelegate reFreshProgress:newProgress withId:item.itemId inClass:@"IphoneDownloadViewController"];
                    [item save];
                }
                
                break;
            }
        }
        
    }
    else{

        NSString *subquery = [NSString stringWithFormat:@"WHERE subitem_id = '%@'", aDownload.idNum];
        NSArray *tempArr = [SubdownloadItem findByCriteria:subquery];
        if (tempArr != nil && [tempArr count]>0) {
             SubdownloadItem *item = [tempArr objectAtIndex:0];
            int oldProgress = item.percentage;
            if (((int)(newProgress*100) - oldProgress) >= 1) {
                item.percentage = (int)(newProgress*100);
                [self.downLoadMGdelegate reFreshProgress:newProgress withId:item.subitemId inClass:@"IphoneSubdownloadViewController"];
                [item save];
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
}

//停止下载不清除缓存
+(void)stop:(NSString *)downloadId{
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
            if (mc.status != 0 && mc.status != 4) {
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
    for (McDownload *mc in downLoadQueue_) {
        if (mc.status != 0 && mc.status != 4) {
            [mc start];
            break;
        }
    }
}
@end
