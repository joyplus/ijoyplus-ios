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
#import "MobClick.h"

@protocol BundingTVManagerDelegate;

/*
 ue_screencast_binded	绑定成功
 修改 重置
 ue_screencast_binding	发出绑定消息
 修改 重置
 ue_screencast_unbinded	解除绑定事件
 修改 重置
 ue_screencast_video_push	云端推送视频
 */

#define KEY_BIND_SUCCESS        (@"ue_screencast_binded")
#define KEY_BINDING             (@"ue_screencast_binding")
#define KEY_UNBINDED            (@"ue_screencast_unbinded")
#define KEY_PUSH_VIDEO          (@"ue_screencast_video_push")

#define KEY_MAX_RESPOND_TIME    (5)

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
