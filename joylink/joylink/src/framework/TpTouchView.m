//
//  TpTouchView.m
//  joylink
//
//  Created by joyplus1 on 13-5-7.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "TpTouchView.h"
#import "RemoteAction.H"
#import "ActionFactory.h"
#import "AppDelegate.h"

@interface TpTouchView ()

@property (nonatomic, strong)RemoteAction *moveAction;

@end

@implementation TpTouchView
@synthesize moveAction;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleClicked)];
//        tapGesture.numberOfTapsRequired = 1;
//        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)singleClicked
{
//    RemoteAction *action = [ActionFactory getSimpleActionByEvent:SINGLE_CLICK];
//    [action trigger];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    UITouch *touch = [[allTouches allObjects]objectAtIndex:0];
    CGPoint downPoint = [touch locationInView:self];
    RemoteAction *action1 = [ActionFactory getComplexActionByEvent:TP_MODE_LEFT_MOUSE_DOWN];
    [action1 trigger:downPoint.x*[AppDelegate instance].scaleX deltaY:downPoint.y*[AppDelegate instance].scaleY];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    UITouch *touch = [[allTouches allObjects]objectAtIndex:0];
    CGPoint previousPoint = [touch previousLocationInView:self];
    CGPoint currentPoint = [touch locationInView:self];
    float deltaX = currentPoint.x - previousPoint.x;
    float deltaY = currentPoint.y - previousPoint.y;
    if (abs(deltaX) > 0 || abs(deltaY) > 0) {
        if (moveAction == nil) {
            moveAction = [ActionFactory getComplexActionByEvent:TP_MODE_DRAG];
        }
        [moveAction trigger:deltaX*[AppDelegate instance].scaleX deltaY:deltaY*[AppDelegate instance].scaleY];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint endPoint = [[[touches allObjects] objectAtIndex:0] locationInView:self];
    NSLog(@"End Point: %f %f", endPoint.x, endPoint.y);
    RemoteAction *action1 = [ActionFactory getComplexActionByEvent:TP_MODE_LEFT_MOUSE_UP];
    [action1 trigger:endPoint.x*[AppDelegate instance].scaleX deltaY:endPoint.y*[AppDelegate instance].scaleY];
}

@end
