//
//  MoveView.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-3-1.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "MoveView.h"
#import "RemoteAction.H"
#import "ActionFactory.h"
#import "AppDelegate.h"

@interface MoveView ()

@property (nonatomic, strong)RemoteAction *moveAction;

@end

@implementation MoveView
@synthesize moveAction;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleClicked)];
        tapGesture.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)singleClicked
{
    RemoteAction *action = [ActionFactory getSimpleActionByEvent:SINGLE_CLICK];
    [action trigger];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    UITouch *touch = [[allTouches allObjects]objectAtIndex:0];
    CGPoint downPoint = [touch locationInView:self];
    NSLog(@"Begin Point: %f %f", downPoint.x, downPoint.y);
    RemoteAction *action = [ActionFactory getSimpleActionByEvent:MOUSE_MODE];
    [action trigger];
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
            moveAction = [ActionFactory getComplexActionByEvent:ONLY_MOVE_MOUSE_ICON];
        }
        [moveAction trigger:deltaX*[AppDelegate instance].scaleX deltaY:deltaY*[AppDelegate instance].scaleY];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint endPoint = [[[touches allObjects] objectAtIndex:0] locationInView:self];
    NSLog(@"End Point: %f %f", endPoint.x, endPoint.y);
    RemoteAction *action1 = [ActionFactory getSimpleActionByEvent:LEFT_MOUSE_UP];
    [action1 trigger];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
