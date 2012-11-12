//
//  GroupMediaObject.h
//  ijoyplus
//
//  Created by joyplus1 on 12-11-9.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupMediaObject : NSObject

@property (nonatomic, strong)NSString *groupName;
@property (nonatomic, assign)int itemNum;
@property (nonatomic, strong)UIImage *groupImage;
@property (nonatomic, strong)NSArray *mediaObjectArray;

@end
