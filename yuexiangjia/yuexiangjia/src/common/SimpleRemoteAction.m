//
//  DownAction.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-2-28.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "SimpleRemoteAction.h"

@implementation SimpleRemoteAction

- (id)initWithEvent:(ControlEvent)controlEvent
{
    self = [super initWithEvent:controlEvent];
    return self;
}

- (void)trigger
{
    Byte type[] = {self.event};
    NSData *data = [[NSData alloc] initWithBytes:type length:sizeof(type)];
    [self.sendSocket sendData:data toHost:self.remoateIPAddress port:self.port withTimeout:-1 tag:1];
}

@end
