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
#define VERSION @"0.9.8alpha"

// for App Store
#define CHANNEL_ID @""
// for 91 Store
//#define CHANNEL_ID @"91store"
// for PP Live
//#define CHANNEL_ID @"pp"
// for sohu
//#define CHANNEL_ID @"b005001"

//#define CHANNEL_ID @"b006001"


//友盟在线参数
#define SHOW_VIDEO_SWITCH @"showVideoSwitch2"
#define CLOSE_VIDEO_MODE @"closeVideoMode3"


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
    #define kABaseURLString @"http://apitest.joyplus.tv/"
#endif
