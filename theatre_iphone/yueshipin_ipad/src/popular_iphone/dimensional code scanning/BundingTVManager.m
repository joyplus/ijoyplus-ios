//
//  BundingTVManager.m
//  yueshipin
//
//  Created by 08 on 13-4-16.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "BundingTVManager.h"
#import "AFCheckBindAPIClient.h"
#import "ContainerUtility.h"
#import "ServiceConstants.h"
#import "CMConstants.h"
#import "CommonMotheds.h"
#import "EnvConstant.h"

#define SERVER_URL  (FAYE_SERVER_URL)
#define KEY_APP     (@"app_key")
#define KEY_CHANNEL (@"tv_channel")
#define KEY_USER    (@"user_id")
 
static BundingTVManager * manager = nil;

@implementation BundingTVManager
@synthesize sendClient = _sendClient,isUserUnbind;

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
        isUserUnbind = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(netWorkBecomeAvailable)
                                                     name:KEY_NETWORK_BECOME_AVAILABLE
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:KEY_NETWORK_BECOME_AVAILABLE
                                                  object:nil];
}

- (void)showMsg:(NSString *)msg
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil
                                                     message:msg
                                                    delegate:nil
                                           cancelButtonTitle:@"我知道了"
                                           otherButtonTitles:nil, nil];
    [alert show];
}

- (void)netWorkBecomeAvailable
{
    [self connecteServer];
}

#pragma mark -
#pragma mark - 对外接口

- (void)connecteServer
{
    NSDictionary * data = (NSDictionary *)[[ContainerUtility sharedInstance] attributeForKey:[NSString stringWithFormat:@"%@_isBunding",_userId]];
    
    if (nil == data)
    {
        //无绑定记录
        return;
    }
    
    NSString * sendChannel = [NSString stringWithFormat:@"CHANNEL_TV_%@",[data objectForKey:KEY_MACADDRESS]];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                sendChannel,KEY_CHANNEL,
                                _userId,KEY_USER, nil];
    
    [[AFCheckBindAPIClient sharedClient] getPath:KPathCheckBinding
                                    parameters:parameters
                                       success:^(AFHTTPRequestOperation *operation, id result) {
                                            //TV与移动终端绑定
                                           NSNumber * bind = nil;
                                            if ([[result objectForKey:@"status"] isEqualToString:@"1"])
                                            {
                                                NSString * channel = [NSString stringWithFormat:@"/screencast/%@",sendChannel];
                                                FayeClient * fClient = [[FayeClient alloc] initWithURLString:SERVER_URL channel:channel];
                                                self.sendClient = fClient;
                                                [self.sendClient connectToServer];
                                                bind = [NSNumber numberWithBool:YES];
                                            }
                                           else
                                           {
                                               bind = [NSNumber numberWithBool:NO];
                                           }
                                           //添加已绑定数据缓存
                                           [[ContainerUtility sharedInstance] setAttribute:\
                                            [NSDictionary dictionaryWithObjectsAndKeys:
                                            [data objectForKey:KEY_MACADDRESS],KEY_MACADDRESS,
                                            bind,KEY_IS_BUNDING, nil]
                                                                                    forKey:\
                                            [NSString stringWithFormat:@"%@_isBunding",_userId]];
                                           [[NSNotificationCenter defaultCenter] postNotificationName:@"bundingTVSucceeded" object:nil];
                                    }
                                       failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        
                                    }];
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

- (void)reconnectToServer
{
    NSDictionary * dic = (NSDictionary *)[[ContainerUtility sharedInstance] attributeForKey:[NSString stringWithFormat:@"%@_isBunding",_userId]];
    if (nil != dic
        && [dic objectForKey:KEY_IS_BUNDING]
        && [CommonMotheds isNetworkEnbled])
    {
        self.sendClient = [[FayeClient alloc] initWithURLString:SERVER_URL channel:[NSString stringWithFormat:@"CHANNEL_TV_%@",[dic objectForKey:KEY_MACADDRESS]]];;
        [self.sendClient connectToServer];
    }
}

#pragma mark -
#pragma mark FayeObjc delegate
- (void) messageReceived:(NSDictionary *)messageDict
{
    //解除绑定
    if ([[messageDict objectForKey:@"push_type"] isEqualToString:@"33"]
        && !isUserUnbind
        && [[messageDict objectForKey:@"user_id"] isEqualToString:_userId])
    {
        [MobClick event:KEY_UNBINDED];
        //添加已绑定数据缓存
        NSDictionary * dic = (NSDictionary *)[[ContainerUtility sharedInstance] attributeForKey:[NSString stringWithFormat:@"%@_isBunding",_userId]];
        [[ContainerUtility sharedInstance] setAttribute:[NSDictionary dictionaryWithObjectsAndKeys:[dic objectForKey:KEY_MACADDRESS],KEY_MACADDRESS,[NSNumber numberWithBool:NO],KEY_IS_BUNDING, nil]
                                                 forKey:[NSString stringWithFormat:@"%@_isBunding",_userId]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"bundingTVSucceeded" object:nil];
        
        [self showMsg:@"已断开与电视端的绑定"];
    }
    isUserUnbind = NO;
}

- (void)connectedToServer
{
    NSLog(@"connect to server success");
}

- (void)disconnectedFromServer
{
    NSLog(@"disconnect to server");
    
    [self reconnectToServer];
    
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
}

@end
