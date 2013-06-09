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

#define VERSION @"1.0.3"

#define AMERICANVIDEOS @"0"  //1-隐藏美剧 0-显示美剧

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
#define SHOW_VIDEO_SWITCH @"showVideoSwitch99"
#define CLOSE_VIDEO_MODE @"closeVideoMode"
#define RECOMMEND_APP_SWITCH @"recommendAppSwitch"


//正式环境
#if ENVIRONMENT   
    #define kDefaultAppKey @"ijoyplus_ios_001"
    #define kDefaultCheckBindAppKey @"ijoyplus_android_0001bj"
    #define PARSE_APP_ID @"UBgv7IjGR8i6AN0nS4diS48oQTk6YErFi3LrjK4P"
    #define PARSE_CLIENT_KEY @"Y2lKxqco7mN3qBmZ05S8jxSP8nhN92hSN4OHDZR8"
    #define kABaseURLString @"http://api.joyplus.tv/"
    #define CHECKBINDURLSTRING  @"http://comet.joyplus.tv:8080/"
    #define FAYE_SERVER_URL @"ws://comet.joyplus.tv:8080/bindtv"
//测试环境
#else
    #define kDefaultAppKey @"ijoyplus_ios_001bj"
    #define kDefaultCheckBindAppKey @"ijoyplus_android_0001bj"
    #define PARSE_APP_ID @"5FNbLx7dnRAx3knxV4rOdaLMRJMByqfKjWQRQakT"
    #define PARSE_CLIENT_KEY @"RZHrZVn6MK8VGZxfpeshrC2tpxpzzMOZjU0rSS6X"
    #define kABaseURLString @"http://apitest.yue001.com/"
    #define CHECKBINDURLSTRING  @"http://comettest.joyplus.tv:8000/"
    #define FAYE_SERVER_URL @"ws://comettest.joyplus.tv:8000/bindtv"
#endif

//本地消息推送默认内容
#define LOCAL_NOTIFICATION_YUEDAN_ID (@"9823")
#define DEFAULT_LOCAL_NOTIFICATION_CONTENT @"《虎胆龙威5》从纽约到莫斯科，好莱坞铁血硬汉布鲁斯·威利斯强势归来，再次拯救世界！$《云图》六个人六个时空，从公元1850年一直延伸到后末日未来，看似毫不相干却又环环相扣！$《霍比特人1：意外之旅》灰袍巫师甘道夫与霍比特人比尔博·巴金斯的冒险之旅！$《欲体焚情》限制级女星Izna受雇于潇洒勇猛的情报官员Ayaan，接近可怕的杀手Kabir并让他掉进“甜蜜陷阱”。$《乌云背后的幸福线》两个失意的人在一起艰难探索人生，他们之间关系也开始产生了微妙的变化……"
