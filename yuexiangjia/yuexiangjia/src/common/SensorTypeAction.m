//
//  SensorTypeAction.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-3-1.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "SensorTypeAction.h"

@implementation SensorTypeAction

- (id)initWithEvent:(ControlEvent)controlEvent
{
    self = [super init];
    if (self) {
        self.event = controlEvent;
        self.port = 1203;
        self.remoateIPAddress = @"192.168.1.109";
        self.sendSocket=[[AsyncUdpSocket alloc]initWithDelegate:self];
    }
    return self;
}

- (void)triggerSensor:(float [])gravity
{
    Byte buffer[17];
    buffer[0] = self.event;
    
    int sensor = 1; //重力感应类型
    [self putInt:buffer x:sensor index:1];
    for (int i = 0; i < 3; i++) {
        int index = i * 4 + 5;
        float f = gravity[i];
        [self putFloat:buffer x:f index:index];
    }
    NSData *data = [[NSData alloc] initWithBytes:buffer length:sizeof(buffer)];
    [self.sendSocket sendData:data toHost:self.remoateIPAddress port:self.port withTimeout:-1 tag:1];
}

- (void)putFloat:(Byte[])byteArray x:(float)x index:(int)index
{
    unsigned l;
    memcpy(&l, &x, 4);
    for (int i = 0; i < 4; i++) {
        byteArray[index + i] = l;
        l = l >> 8;
    }
}

- (void) putInt:(Byte[])byteArray x:(int)x index:(int)index
{
    byteArray[index + 3] = (Byte) (x >> 24);
    byteArray[index + 2] = (Byte) (x >> 16);
    byteArray[index + 1] = (Byte) (x >> 8);
    byteArray[index + 0] = (Byte) (x >> 0);
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    
}
@end
