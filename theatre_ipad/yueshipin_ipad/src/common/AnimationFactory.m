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

+ (CATransition *)initAnimation;
@end
@implementation AnimationFactory

+ (CATransition *)initAnimation
{
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = kDuration;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    return animation;
}

+ (CATransition *)pushToLeftAnimation:(void (^)(void))animations
{
    CATransition *animation = [self initAnimation];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromLeft;
    animations();
    return animation;
}

+ (CATransition *)pushToRightAnimation:(void (^)(void))animations
{
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromRight;
    animations();
    return animation;
}

+ (CATransition *)pushToRippleAnimation:(void (^)(void))animations
{
    CATransition *animation = [CATransition animation];
    animation.type = @"rippleEffect";
    animation.subtype = kCATransitionFromLeft;
    animations();
    return animation;
}

@end
