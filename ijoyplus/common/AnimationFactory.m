//
//  AnimationFactory.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-7.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "AnimationFactory.h"
#define kDuration 0.7   // 动画持续时间(秒)

@interface AnimationFactory ()

@end
@implementation AnimationFactory

+ (CATransition *)pushToLeftAnimation
{
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = kDuration;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromLeft;
    return animation;
}


@end
