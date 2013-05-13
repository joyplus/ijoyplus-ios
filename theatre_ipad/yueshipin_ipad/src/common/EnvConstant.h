//
//  EnvConstant.h
//  yueshipin
//
//  Created by joyplus1 on 13-3-13.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <Foundation/Foundation.h>

 //0: 测试环境     1. 正式环境
#define ENVIRONMENT 0

#define VERSION @"1.0.0alpha"

//0: 关闭loglog      1. 打开log      Log功能只有再测试环境才生效
#define LOG_ENABLED 0

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
#define SHOW_VIDEO_SWITCH @"showVideoSwitch6"
#define CLOSE_VIDEO_MODE @"closeVideoMode7"


//正式环境
#if ENVIRONMENT
    #define kDefaultAppKey @"ijoyplus_ios_001"
    #define kDefaultCheckBindAppKey @"ijoyplus_android_0001bj"
    #define PARSE_APP_ID @"7HBtATmC6bXLoghbMcRkyPanB83XJwwqSmqsoGX8"
    #define PARSE_CLIENT_KEY @"eLUjCZRbuh1i7BGRrVeRZxSrUVYhP9ytZe0TMd1T"
    #define kABaseURLString @"http://api.joyplus.tv/"
    #define CHECKBINDURLSTRING  @"http://comet.joyplus.tv:8080/"
    #define FAYE_SERVER_URL @"ws://comet.joyplus.tv:8080/bindtv"
//测试环境
#else
    #define kDefaultAppKey @"ijoyplus_ios_001bj"
    #define kDefaultCheckBindAppKey @"ijoyplus_android_0001bj"
    #define PARSE_APP_ID @"ogHl2PzmqLRcT5g1gKPSktVsZZertTEMeMs2Majg"
    #define PARSE_CLIENT_KEY @"i3AYeFb8URtzW7gnL5twCBIrJRgwpopVBX8kPyqK"
    #define kABaseURLString @"http://apitest.yue001.com/"
    #define CHECKBINDURLSTRING  @"http://comettest.joyplus.tv:8000/"
    #define FAYE_SERVER_URL @"ws://comettest.joyplus.tv:8000/bindtv"
#endif
