//
//  SequenceData.h
//  yueshipin
//
//  Created by joyplus1 on 12-12-28.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "SQLitePersistentObject.h"

@interface SequenceData : SQLitePersistentObject

- (id)initWithType:(int)seqType;

@property (nonatomic, assign)int newDownloadItemNum;
@property (nonatomic, assign)int type;// 0 : for downloading item

@end
