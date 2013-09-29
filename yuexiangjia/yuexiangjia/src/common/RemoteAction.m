//
//  RemoteAction.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-2-28.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "RemoteAction.h"

@implementation RemoteAction
@synthesize sendSocket;
@synthesize remoateIPAddress;
@synthesize port;
@synthesize event;

- (id)initWithEvent:(ControlEvent)controlEvent
{
    self = [super init];
    if (self) {
        event = controlEvent;
        port = 1202;
        remoateIPAddress = @"192.168.2.135";
        sendSocket=[[AsyncUdpSocket alloc]initWithDelegate:self];
    }
    return self;
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    [sock close];
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    [sock close];
}

- (void)trigger
{
    NSLog(@"Should not go here, but in subclasses!!!");
}

- (void)trigger:(NSString *)msg
{
    NSLog(@"Should not go here, but in subclasses!!!");
}

- (void)trigger:(int)deltaX deltaY:(int)deltaY
{
    Byte byte[5];
    byte[0]= self.event;
    byte[1] = deltaX;
    byte[2] = deltaX >> 8;
    byte[3] = deltaY;
    byte[4] = deltaY >> 8;
    NSData *data = [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
    [self.sendSocket sendData:data toHost:self.remoateIPAddress port:self.port withTimeout:-1 tag:1];
}

- (void)triggerSensor:(float [])gravity
{
     NSLog(@"Should not go here, but in subclasses!!!");
}
@end
