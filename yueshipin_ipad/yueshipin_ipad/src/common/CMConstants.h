//
//  CMConstants.h
//  ClassManagement
//
//  Created by 永庆 李 on 12-3-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#define LEFT_WIDTH 40

#define MOVIE_POSTER_WIDTH 70
#define MOVIE_POSTER_HEIGHT 100 

// for App Store
#define CHANNEL_ID @""
// for 91 Store
//#define CHANNEL_ID @"91store"
// for PP Live
//#define CHANNEL_ID @"pp"
// for sohu 
//#define CHANNEL_ID @"b005001"

//#define CHANNEL_ID @"b006001"

#define kJoyplusWebSite @"http://app.joyplus.tv"
#define kSinaWeiboBaseUrl @"https://api.weibo.com"
#define kSinaWeiboUpdateUrl @"statuses/update.json"
#define kSinaWeiboUpdateWithImageUrl @"statuses/upload_url_text.json"
#define kFollowUserURI @"friendships/create.json"

#define kTecentBaseURL @"https://graph.qq.com/"
#define kTecentAddShare @"share/add_share"
#define kTecentAppId @"100317415"   // for login

#define kTencentAppKey @"100666407"
#define kTencentAppSecret @"2a35faffc945dc9f5e432167cc4a1b5a"

#define kSinaWeiboAppKey  @"1490285522"
#define kSinaWeiboAppSecret  @"f9ebc3ca95991b6dfce2c1608687e92b"
#define kSinaWeiboRedirectURL @"https://api.weibo.com/oauth2/default.html"
#define kPAPUserDefaultsCacheSinaFriendsKey @"sinaFriendKey"
#define kSinaWeiboAccessToken @"sinaAccessToken"
#define kSinaWeiboUID @"sinaUid"

#define kUserLoggedIn @"userLoggedIn"
#define kSinaUID @"kSinaUID"

//WeChat
#define KWeChatAppID @"wxc8ea1cbc355fe2d0"
#define KWeChatAppKey @"5843781cb092af97588a827e3f2e6eac"

#define kUserLoginService @"joypluslogin"
#define kUserId @"kUserId"
#define kUserName @"kUserName"
#define kUserNickName @"kUserNickName"
#define kUserAvatarUrl @"kUserAvatarUrl"
#define kSessionRenew @"kSessionRenew"
#define kPhoneNumber @"kPhoneNumber"

#define kIpadAppKey @"kIpadAppkey"

#define LOCAL_KEYS_NUMBER 5
#define MAX_DOWNLOADING_THREADS 1
#define umengAppKey @"50c069e25270154e81000056"

#define YOU_KU @"youku"
#define TU_DOU @"tudou"
#define PPTV @"pptv"
#define LETV @"letv"

#define GAO_QING @"mp4"
#define BIAO_QING @"flv"
#define CHAO_QING @"hd2"
#define LIU_CHANG @"3gp"

#define PERSONAL_VIEW_REFRESH @"PersonalViewRefresh"
#define WATCH_HISTORY_REFRESH @"PersonalWatchHistoryViewRefresh"
#define MY_LIST_VIEW_REFRESH @"MyListViewRefresh"

#define UPDATE_DOWNLOAD_ITEM_NUM @"update_download_item_num"
#define RELOAD_MENU_ITEM @ "reload_menu_item"
#define UPDATE_DISK_STORAGE @"update_disk_storage"

#define WATCH_RECORD_NUMBER 5

#define LAST_UPDATE_DATE_FOR_TOPS @"last_update_date_for_tops"

#define LEFT_VIEW_WIDTH 529

#define RIGHT_VIEW_WIDTH 515

#define degreesToRadian(x) (3.14159265358979323846 * x/ 180.0)

#define APPIRATER_APP_ID				587246114

#define SHOW_VIDEO_SWITCH @"showVideoSwitch2"
#define CLOSE_VIDEO_MODE @"closeVideoMode3"

#define WATCH_RECORD_CACHE_KEY @"watch_record2"

#define SHOW_MENU_INTRO @"show_menu_intro"
#define SHOW_PLAY_INTRO @"show_play_intro"
#define DOWNLOAD_SETTING_INTRO @"download_setting_intro"
#define WEIBO_INTRO @"weibbo_intro"
#define SHOW_DOWNLOAD_INTRO @"show_download_intro"
#define SHOW_PLAY_INTRO_WITH_DOWNLOAD @"show_play_intro_with_download"
#define WIFI_IS_NOT_AVAILABLE @"wifi_is_not_available"

@interface CMConstants : NSObject 
    extern NSString * const MyString;

+ (UIColor*)grayColor;

+ (UIColor *)scoreBlueColor;

+ (UIColor *)titleBlueColor;

+ (UIFont *)titleFont;

+ (UIColor *)tableBorderColor;

+ (UIColor *)backgroundColor;

@end
