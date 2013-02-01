//
//  DownloadManager.h
//  yueshipin
//
//  Created by joyplus1 on 13-1-31.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFDownloadRequestOperation.h"

@interface NewDownloadManager : NSObject <DownloadingDelegate, SubdownloadingDelegate>

@property (nonatomic, weak)id<DownloadingDelegate>delegate;
@property (nonatomic, weak)id<SubdownloadingDelegate>subdelegate;
- (void)startDownloadingThreads;
- (void)stopDownloading;

@end
