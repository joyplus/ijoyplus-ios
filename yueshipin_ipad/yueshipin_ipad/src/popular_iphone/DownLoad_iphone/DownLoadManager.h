//
//  DownLoadManager.h
//  yueshipin
//
//  Created by 08 on 13-1-17.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "McDownload.h"
@protocol DownloadManagerDelegate <NSObject>

- (void)reFreshProgress:(double)progress withId:(NSString *)itemId inClass:(NSString *)className;
- (void)downloadFailedwithId:(NSString *)itemId inClass:(NSString *)className;

@end

@interface DownLoadManager : NSObject<McDownloadDelegate>{
   // id <DownloadManagerDelegate>downLoadMGdelegate_;
}
@property (nonatomic, weak) id<DownloadManagerDelegate>downLoadMGdelegate;
+(DownLoadManager *)defaultDownLoadManager;

-(void)resumeDownLoad;

+(void)stopAndClear:(NSString *)downloadId;

+(void)stop:(NSString *)downloadId;

+(void)continueDownload:(NSString *)downloadId;
@end
