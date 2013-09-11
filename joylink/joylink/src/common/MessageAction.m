//
//  MessageAction.m
//  joylink
//
//  Created by joyplus1 on 13-5-8.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "MessageAction.h"

@implementation MessageAction

- (void)trigger:(NSString *)msg
{
    NSData* bytes = [msg dataUsingEncoding:NSUTF8StringEncoding];
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
