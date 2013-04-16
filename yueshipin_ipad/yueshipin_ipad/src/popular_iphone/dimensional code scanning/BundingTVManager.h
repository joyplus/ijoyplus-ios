//
//  BundingTVManager.h
//  yueshipin
//
//  Created by 08 on 13-4-16.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FayeClient.h"
#import "ContainerUtility.h"
@protocol BundingTVManagerDelegate;

#define KEY_MAX_RESPOND_TIME    (6.0)

#define KEY_MACADDRESS      (@"macAddress")
#define KEY_IS_BUNDING      (@"isBunding")

#define KEY_TYPE_BUNDING        (@"31")
#define KEY_TYPE_UNBUNDING      (@"33")
#define KEY_TYPE_SEND_VIDEO     (@"41")

@interface BundingTVManager : NSObject 
{
    FayeClient *_sendClient;
    NSString   *_userId;
}
@property (nonatomic, strong) FayeClient *sendClient;

+ (BundingTVManager *)shareInstance;
- (BOOL)isConnected;
- (void)connecteServer;
- (void)connecteServerWithChannel:(NSString *)channel;
- (void)sendMsg:(NSDictionary *)data;

@end

@protocol BundingTVManagerDelegate <NSObject>



@end
