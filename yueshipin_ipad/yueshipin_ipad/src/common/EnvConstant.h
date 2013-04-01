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
#define VERSION @"0.9.9"

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
#define SHOW_VIDEO_SWITCH @"showVideoSwitch3"
#define CLOSE_VIDEO_MODE @"closeVideoMode4"


//正式环境
#if ENVIRONMENT   
    #define kDefaultAppKey @"ijoyplus_ios_001"
    #define PARSE_APP_ID @"UBgv7IjGR8i6AN0nS4diS48oQTk6YErFi3LrjK4P"
    #define PARSE_CLIENT_KEY @"Y2lKxqco7mN3qBmZ05S8jxSP8nhN92hSN4OHDZR8"
    #define kABaseURLString @"http://api.joyplus.tv/"
//测试环境
#else
    #define kDefaultAppKey @"ijoyplus_ios_001bj"
    #define PARSE_APP_ID @"FtAzML5ln4zKkcL28zc9XR6kSlSGwXLdnsQ2WESB"
    #define PARSE_CLIENT_KEY @"YzMYsyKNV7ibjZMfIDSGoV5zxsylV4evtO8x64tl"
    #define kABaseURLString @"http://apitest.yue001.com/"
#endif
