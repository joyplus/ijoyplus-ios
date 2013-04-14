//
//  DownloadItem.h
//  yueshipin
//
//  Created by joyplus1 on 12-12-19.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadItem.h"
@interface SubdownloadItem : DownloadItem

- (id)init;

@property (nonatomic, strong)NSString *subitemId;
@end
