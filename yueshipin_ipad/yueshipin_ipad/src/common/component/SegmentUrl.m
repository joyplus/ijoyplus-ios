//
//  SegmentUrl.m
//  yueshipin
//
//  Created by joyplus1 on 13-3-22.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "SegmentUrl.h"

@implementation SegmentUrl

@synthesize rowId;
@synthesize url;
@synthesize itemId;
@synthesize subitemId;
@synthesize seqNum;

- (id)init
{
    self = [super init];
    url = @"";
    subitemId = @"";
    seqNum = 0;
    return self;
}
@end
