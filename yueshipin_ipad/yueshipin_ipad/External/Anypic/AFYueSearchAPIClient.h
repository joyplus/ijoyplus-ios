//
//  AFYueSearchAPIClient.h
//  yueshipin
//
//  Created by huokun on 13-9-5.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"
@interface AFYueSearchAPIClient : AFHTTPClient

+ (AFYueSearchAPIClient *)sharedClient;

@end
