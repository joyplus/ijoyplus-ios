//
//  SegmentUrl.h
//  yueshipin
//
//  Created by joyplus1 on 13-3-22.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "DatabaseObject.h"
@interface SegmentUrl : DatabaseObject

- (id)init;

@property (nonatomic) int rowId;
@property (nonatomic, strong)NSString *itemId;
@property (nonatomic, strong)NSString *subitemId;
@property (nonatomic, strong)NSString *url;
@property (nonatomic) int seqNum;
@end
