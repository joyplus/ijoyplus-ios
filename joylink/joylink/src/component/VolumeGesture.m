//
//  VolumeGesture.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-25.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "VolumeGesture.h"

@interface VolumeGesture ()

@property (nonatomic)CGPoint previousPt;

@end

@implementation VolumeGesture
@synthesize delegate;
@synthesize previousPt;

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    previousPt = [[touches anyObject] locationInView:self.view];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    const CGPoint p = [[touches anyObject] locationInView:self.view];
    if(abs(p.y - previousPt.y) > 10){
    if (p.y - previousPt.y > 20) {
        if ([delegate respondsToSelector:@selector(changeVolume:)]) {
            [delegate changeVolume:-0.01];
        }
    }
    else if  (p.y - previousPt.y < 20) {
        if ([delegate respondsToSelector:@selector(changeVolume:)]) {
            [delegate changeVolume:+0.01];
        }
    }
    }
}
@end
