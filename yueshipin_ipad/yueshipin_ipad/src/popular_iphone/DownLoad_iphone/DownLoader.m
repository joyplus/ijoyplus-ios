//
//  DownLoader.m
//  yueshipin
//
//  Created by Rong on 13-4-11.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "DownLoader.h"

@implementation DownLoader
@synthesize downloadRequestOperation = downloadRequestOperation_;
-(void)downLoaderStart{
    [downloadRequestOperation_ setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    
    
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               
        
    }];
    
    [downloadRequestOperation_ setProgressiveDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
                
    }];
    [downloadRequestOperation_ start];
}
@end
