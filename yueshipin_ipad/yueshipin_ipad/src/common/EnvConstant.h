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

#define VERSION @"1.0.7"

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
#define SHOW_VIDEO_SWITCH @"showVideoSwitch10"
#define CLOSE_VIDEO_MODE @"closeVideoMode10"
#define RECOMMEND_APP_SWITCH @"recommendAppSwitch10"
#define AMERICANVIDEOS @"1"  //1-隐藏美剧 0-显示美剧
#define HIDDEN_AMERICAN_VIDEOS @"HiddenAmericanVideos10"
//正式环境
#if ENVIRONMENT   
    #define kDefaultAppKey @"ijoyplus_ios_001"
    #define kDefaultCheckBindAppKey @"ijoyplus_android_0001bj"
    #define PARSE_APP_ID @"UBgv7IjGR8i6AN0nS4diS48oQTk6YErFi3LrjK4P"
    #define PARSE_CLIENT_KEY @"Y2lKxqco7mN3qBmZ05S8jxSP8nhN92hSN4OHDZR8"
    #define kABaseURLString @"http://api.joyplus.tv/"
    #define CHECKBINDURLSTRING  @"http://comet.joyplus.tv:8080/"
    #define FAYE_SERVER_URL @"ws://comet.joyplus.tv:8080/bindtv"
    #define PARSEURL_TEMP_URL @"http://tt.showkey.tv/getAnalyzedUrl?url="
//测试环境
#else
    #define kDefaultAppKey @"ijoyplus_ios_001bj"
    #define kDefaultCheckBindAppKey @"ijoyplus_android_0001bj"
    #define PARSE_APP_ID @"5FNbLx7dnRAx3knxV4rOdaLMRJMByqfKjWQRQakT"
    #define PARSE_CLIENT_KEY @"RZHrZVn6MK8VGZxfpeshrC2tpxpzzMOZjU0rSS6X"
    #define kABaseURLString @"http://apitest.yue001.com/"
    #define CHECKBINDURLSTRING  @"http://comettest.joyplus.tv:8000/"
    #define FAYE_SERVER_URL @"ws://comettest.joyplus.tv:8000/bindtv"
    #define PARSEURL_TEMP_URL  @"http://tt.yue001.com:8080/getAnalyzedUrl?url="
#endif

//本地消息推送默认内容
#define LOCAL_NOTIFICATION_YUEDAN_ID (@"9823")
#define DEFAULT_LOCAL_NOTIFICATION_CONTENT @"美剧回归季，尽在悦视频！美剧《性爱大师》惹火上线，解密男女相处之道。$《神盾局特工》超级英雄让位特工，《复仇者联盟》续集电视剧版看过瘾！$《抹布女也有春天》举抹布的女汉子你威武雄壮，21世纪强气生活之我擦！$《僵尸世界大战》电影院不让播的限制级灾难片，布拉德·皮特身陷末日尸海。$《一夜惊喜》范冰冰意外怀孕，最二的事竟然不知道孩子他爹是谁！"
