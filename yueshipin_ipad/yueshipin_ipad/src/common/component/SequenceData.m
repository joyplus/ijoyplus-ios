//
//  SequenceData.m
//  yueshipin
//
//  Created by joyplus1 on 12-12-28.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "SequenceData.h"

@implementation SequenceData
@synthesize newDownloadItemNum;
@synthesize type;

- (id)initWithType:(int)seqType
{
    self = [self init];
    self.type = seqType;
    return self;
}

@end
