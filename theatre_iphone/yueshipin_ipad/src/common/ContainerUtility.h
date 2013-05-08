//
//  ContainerUtility.h
//  ijoyplus
//
//  Created by joyplus1 on 12-9-25.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContainerUtility : NSObject

+ (id)sharedInstance;
- (void)setAttribute:(NSObject *)attribute forKey:(NSString *)key;
- (NSObject *)attributeForKey:(NSString *)key;
- (void)removeObjectForKey:(NSString *)key;
- (void)clear;
@end
