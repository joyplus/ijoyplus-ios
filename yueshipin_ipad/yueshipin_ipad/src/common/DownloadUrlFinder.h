//
//  DownloadManager.h
//  yueshipin
//
//  Created by joyplus1 on 13-1-31.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadItem.h"

@interface DownloadUrlFinder : NSObject

@property (nonatomic, strong)DownloadItem *item;

- (void)setupWorkingUrl;

@end
