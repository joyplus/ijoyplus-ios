//
//  AnimationFactory.h
//  ijoyplus
//
//  Created by joyplus1 on 12-9-7.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnimationFactory : NSObject

+ (CATransition *)pushToLeftAnimation:(void (^)(void))animations;
+ (CATransition *)pushToRightAnimation:(void (^)(void))animations;
@end
