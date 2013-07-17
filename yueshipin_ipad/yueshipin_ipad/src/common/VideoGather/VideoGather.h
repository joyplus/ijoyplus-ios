//
//  VideoGather.h
//  yueshipin
//
//  Created by lily on 13-7-17.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFHpple.h"
@interface VideoGather : NSObject<NSXMLParserDelegate>
+(VideoGather *)Create;

//Letv
-(NSArray *)getLetvUrls:(NSString *)htmlUrl;

//fengxing
@end
