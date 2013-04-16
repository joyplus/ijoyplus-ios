//
//  BundingTVManager.m
//  yueshipin
//
//  Created by 08 on 13-4-16.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "BundingTVManager.h"


#define SERVER_URL  (@"ws://comettest.joyplus.tv:8000/bindtv")
static BundingTVManager * manager = nil;

@implementation BundingTVManager
@synthesize sendClient = _sendClient;

+ (BundingTVManager *)shareInstance
{
    if (nil == manager)
    {
        manager = [[BundingTVManager alloc] init];
    }
    return manager;
}

- (id)init
{
    if ([super init])
    {
        _userId = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:@"kUserId"];
    }
    return self;
}

#pragma mark -
#pragma mark - 对外接口

- (void)connecteServer
{
    NSDictionary * data = (NSDictionary *)[[ContainerUtility sharedInstance] attributeForKey:[NSString stringWithFormat:@"%@_isBunding",_userId]];
    
    NSString * sendChannel = [NSString stringWithFormat:@"/screencast/CHANNEL_TV_%@",[data objectForKey:KEY_MACADDRESS]];
    
    if ([[data objectForKey:KEY_IS_BUNDING] boolValue])
    {
        FayeClient * fClient = [[FayeClient alloc] initWithURLString:SERVER_URL channel:sendChannel];
        self.sendClient = fClient;
        [self.sendClient connectToServer];
    }
}

- (void)connecteServerWithChannel:(NSString *)channel
{
    self.sendClient = nil;
    self.sendClient = [[FayeClient alloc] initWithURLString:SERVER_URL channel:channel];;
    [self.sendClient connectToServer];
}

- (BOOL)isConnected
{
    return self.sendClient.webSocketConnected;
}

- (void)sendMsg:(NSDictionary *)data
{
    [self.sendClient sendMessage:data];
}

#pragma mark -
#pragma mark FayeObjc delegate
- (void) messageReceived:(NSDictionary *)messageDict
{
    
}

- (void)connectedToServer
{
    NSLog(@"connect to server success");
}

- (void)disconnectedFromServer
{
    NSLog(@"disconnect to server");
}

@end
