//
//  ConnectionAction.m
//  joylink
//
//  Created by joyplus1 on 13-5-6.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "SearchServerAction.h"
#import "CommonHeader.h"

@implementation SearchServerAction

- (void)trigger
{
    NSString *localIp =  [CommonMethod getIPAddress];
    if (![localIp isEqualToString:@"error"]) {        
        NSString *modalName = [CommonMethod platformString];
        NSString *sendMsg = [NSString stringWithFormat:@"%@:%@", localIp, modalName];
        NSLog(@"Search Server = %@", sendMsg);
        NSData* bytes = [sendMsg dataUsingEncoding:NSUTF8StringEncoding];
        Byte * msgByte = (Byte *)[bytes bytes];
        Byte byte[bytes.length + 1];
        byte[0] = self.event;
        for (int i = 1; i <bytes.length + 1; i++) {
            byte[i] = msgByte[i-1];
        }
        NSData *data = [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
        NSRange range = [localIp rangeOfString:@"." options:NSBackwardsSearch];
        for (int i = 1; i < 256; i++) {
            NSString *remoateIPAddress = [NSString stringWithFormat:@"%@.%i", [localIp substringToIndex:range.location], i];
            [self.sendSocket sendData:data toHost:remoateIPAddress port:DONGLE_SOCKET_SERVER_PORT withTimeout:-1 tag:1];
        }
    }
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    if (tag >= 256) {
        [sock close];
    }
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    if (tag >= 256) {
        [sock close];
    }
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port{
    NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return YES;
}
@end
