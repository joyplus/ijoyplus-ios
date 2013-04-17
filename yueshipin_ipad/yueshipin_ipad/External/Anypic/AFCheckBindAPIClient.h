//
//  AFCheckBindAPIClient.h
//  yueshipin
//
//  Created by 08 on 13-4-17.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"
@interface AFCheckBindAPIClient : AFHTTPClient
+ (AFCheckBindAPIClient *)sharedClient;

@end
