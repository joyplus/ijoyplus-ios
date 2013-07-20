//
//  WXShareRecord.m
//  yueshipin
//
//  Created by lily on 13-7-5.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "WXShareRecord.h"

@implementation WXShareRecord
@synthesize  prodId;
@synthesize extend1;
@synthesize extend2;
@synthesize extend3;

-(id)init{
    self = [super init];
    if (self) {
        self.extend1 = @"";
        self.extend2 = @"";
        self.extend3 = 0;
        return self;
    }
    return nil;
}
@end
