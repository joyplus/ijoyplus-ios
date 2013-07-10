//
//  DownloadItem.m
//  yueshipin
//
//  Created by joyplus1 on 12-12-19.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "DownloadItem.h"

@implementation DownloadItem
@synthesize rowId;
@synthesize itemId;
@synthesize name;
@synthesize imageUrl;
@synthesize percentage;
@synthesize downloadStatus;
@synthesize fileName;
@synthesize url;
@synthesize urlArray;
@synthesize type;
@synthesize isDownloadingNum;
@synthesize downloadType;
@synthesize duration;
@synthesize downloadURLSource;
@synthesize mp4SourceNum;
@synthesize m3u8DownloadInfo;

- (id)init
{
    self = [super init];
    name = @"";
    imageUrl = @"";
    percentage = 0;
    downloadStatus = @"";
    fileName = @"";
    url = @"";
    type = 0;
    isDownloadingNum = 0;
    duration = 0;
    downloadType = @"";
    return self;
}

@end
