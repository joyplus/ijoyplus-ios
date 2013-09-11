//
//  MoveAction.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-2-28.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "ComplexRemoateAction.h"

@implementation ComplexRemoateAction

- (id)initWithEvent:(ControlEvent)controlEvent
{
    self = [super initWithEvent:controlEvent];
    return self;
}

- (void)trigger:(int)deltaX deltaY:(int)deltaY
{
    [super trigger:deltaX deltaY:deltaY];
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{

}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{

}
@end
