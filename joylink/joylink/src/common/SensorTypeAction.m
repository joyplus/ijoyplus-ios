//
//  SensorTypeAction.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-3-1.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "SensorTypeAction.h"
#import "EnvConstant.h"
#import "AppDelegate.h"

@implementation SensorTypeAction

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
    [self.sendSocket sendData:data toHost:[AppDelegate instance].dongelSocketServerIP port:DONGEL_SENSOR_SOCKET_SERVER_PORT withTimeout:-1 tag:1];
}

- (void)putFloat:(Byte[])byteArray x:(float)x index:(int)index
{
    int l = floatToIntBits(x);
    for (int i = 0; i < 4; i++) {
        byteArray[index + i] = l;
        l = l >> 8;
    }
}

int floatToIntBits(float  x)
{
    union {
        float f;  // assuming 32-bit IEEE 754 single-precision
        int i;    // assuming 32-bit 2's complement int
    } u;
    
    if (isnan(x)) {
        return 0x7fc00000;
    } else {
        u.f = x;
        return u.i;
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
