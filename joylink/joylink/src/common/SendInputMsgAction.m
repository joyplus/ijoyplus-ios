//
//  SendInputMsgAction.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-3-1.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "SendInputMsgAction.h"

@implementation SendInputMsgAction

- (id)initWithEvent:(ControlEvent)controlEvent
{
    self = [super initWithEvent:controlEvent];
    return self;
}

- (void)trigger:(NSString *)msg
{
    NSString *sendMsg = [NSString stringWithFormat:@"%@%@", [NSString stringWithFormat:@"%04d", msg.length], msg];
    NSData* bytes = [sendMsg dataUsingEncoding:NSUTF8StringEncoding];
    Byte * msgByte = (Byte *)[bytes bytes];
    Byte byte[bytes.length + 1];
    byte[0] = self.event;
    for (int i = 1; i <bytes.length + 1; i++) {
        byte[i] = msgByte[i-1];
    }
    NSData *data = [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
    [self.sendSocket sendData:data toHost:[AppDelegate instance].dongelSocketServerIP port:self.port withTimeout:-1 tag:1];
}

@end
