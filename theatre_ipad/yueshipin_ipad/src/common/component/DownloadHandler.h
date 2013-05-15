//
//  DownloadHandler.h
//  yueshipin
//
//  Created by joyplus1 on 12-12-27.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadItem.h"

@interface DownloadHandler : NSOperation <NSURLConnectionDelegate>

@property (nonatomic, assign)NSArray *downloadUrls;
@property (nonatomic, assign)DownloadItem *item;

@end
