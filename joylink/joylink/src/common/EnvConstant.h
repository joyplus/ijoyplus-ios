//
//  EnvConstant.h
//  yueshipin
//
//  Created by joyplus1 on 13-3-13.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <Foundation/Foundation.h>

 //0: 测试环境     1. 正式环境
#define ENVIRONMENT 1

#define DONGLE_SOCKET_SERVER_PORT 1202
#define LOCAL_SOCKET_SERVER_PORT 1204
#define DONGEL_SENSOR_SOCKET_SERVER_PORT 1203
// App Store
#define CHANNEL_ID @""
// 机客
//#define CHANNEL_ID @"b001001"
// 同步推
//#define CHANNEL_ID @"b002001"
// 91
//#define CHANNEL_ID @"b003001"
// PP助手
//#define CHANNEL_ID @"b004001"
// 搜狐
//#define CHANNEL_ID @"b005001"
// 威锋
//#define CHANNEL_ID @"b006001"

//友盟在线参数

//正式环境
#if ENVIRONMENT   
    #define kUmengAppkey @"51836a5056240b78de0080b6"
//测试环境
#else
    #define kUmengAppkey @"51836a5056240b78de0080b6"
#endif
