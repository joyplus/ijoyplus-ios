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
    //解除绑定
    if ([[messageDict objectForKey:@"push_type"] isEqualToString:@"33"])
    {
        NSString *userId = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:@"kUserId"];
        //添加已绑定数据缓存
        NSDictionary * dic = (NSDictionary *)[[ContainerUtility sharedInstance] attributeForKey:[NSString stringWithFormat:@"%@_isBunding",userId]];
        [[ContainerUtility sharedInstance] setAttribute:[NSDictionary dictionaryWithObjectsAndKeys:[dic objectForKey:KEY_MACADDRESS],KEY_MACADDRESS,[NSNumber numberWithBool:NO],KEY_IS_BUNDING, nil]
                                                 forKey:[NSString stringWithFormat:@"%@_isBunding",userId]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"bundingTVSucceeded" object:nil];
    }
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
