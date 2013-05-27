//
//  DownLoader.h
//  yueshipin
//
//  Created by Rong on 13-4-11.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFDownloadRequestOperation.h"
@interface DownLoader : NSObject

@property (nonatomic,strong)AFDownloadRequestOperation *downloadRequestOperation;

-(void)downLoaderStart;
@end
