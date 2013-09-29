//
//  MoveView.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-3-1.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "UpDownScrollView.h"
#import "RemoteAction.H"
#import "ActionFactory.h"
#import "AppDelegate.h"

@interface UpDownScrollView ()

@property (nonatomic, strong)RemoteAction *tpdragAction;

@end

@implementation UpDownScrollView
@synthesize tpdragAction;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    UITouch *touch = [[allTouches allObjects]objectAtIndex:0];
    CGPoint downPoint = [touch locationInView:self];
    NSLog(@"Begin Point: %f %f", downPoint.x, downPoint.y);
    RemoteAction *action = [ActionFactory getSimpleActionByEvent:MOUSE_MODE];
    [action trigger];
    RemoteAction *scrollAction = [ActionFactory getSimpleActionByEvent:UP_AND_DOWN_SCROLL_MODE];
    [scrollAction trigger];
    RemoteAction *downAction = [ActionFactory getSimpleActionByEvent:LEFT_MOUSE_DOWN];
    [downAction trigger];
    RemoteAction *dragAction = [ActionFactory getSimpleActionByEvent:MOVE_DRAG];
    [dragAction trigger];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    NSSet *allTouches = [event allTouches];
    UITouch *touch = [[allTouches allObjects]objectAtIndex:0];
    CGPoint previousPoint = [touch previousLocationInView:self];
    CGPoint currentPoint = [touch locationInView:self];
    float deltaX = currentPoint.x - previousPoint.x;
    float deltaY = currentPoint.y - previousPoint.y;
    if (abs(deltaY) > 0) {
        if (tpdragAction == nil) {
            tpdragAction = [ActionFactory getComplexActionByEvent:TP_MODE_DRAG];
        }
        [tpdragAction trigger:deltaX deltaY:deltaY];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint endPoint = [[[touches allObjects] objectAtIndex:0] locationInView:self];
    NSLog(@"End Point: %f %f", endPoint.x, endPoint.y);
    RemoteAction *upAction = [ActionFactory getSimpleActionByEvent:LEFT_MOUSE_UP];
    [upAction trigger];
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
