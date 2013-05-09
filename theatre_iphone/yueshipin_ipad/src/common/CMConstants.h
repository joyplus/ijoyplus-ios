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
#define KWeChatAppID @"wx69b5a1b792f39532"
#define KWeChatAppKey @"a0a96148d869831a1e135b7f82a1b849"

#define kUserLoginService @"joypluslogin"
#define kUserId @"kUserId"
#define kUserName @"kUserName"
#define kUserNickName @"kUserNickName"
#define kUserAvatarUrl @"kUserAvatarUrl"
#define kSessionRenew @"kSessionRenew"
#define kPhoneNumber @"kPhoneNumber"

#define kIpadAppKey @"kIpadAppkey"
#define KWXCODENUM  @"weixinImageNum"

#define LOCAL_KEYS_NUMBER 10
#define MAX_DOWNLOADING_THREADS 1
#define umengAppKey @"5188664c56240b42b7010a45"

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
#define SEARCH_LIST_VIEW_REFRESH @"SearchListViewRefresh"
#define SYSTEM_IDLE_TIMER_DISABLED @"system_idle_timer_disabled"

#define UPDATE_DOWNLOAD_ITEM_NUM @"update_download_item_num"
#define UPDATE_DISK_STORAGE @"update_disk_storage"
#define NO_ENOUGH_SPACE @"no_enough_space"
#define LEAST_DISK_SPACE 300.0/1024.0

#define MOVE_TO_CLOSE_TAG 867394029

#define WATCH_RECORD_NUMBER 5

#define LAST_UPDATE_DATE_FOR_TOPS @"last_update_date_for_tops"

#define LEFT_VIEW_WIDTH 529
#define FULL_SCREEN_WIDTH (940)

#define NORMAL_VIDEO_WIDTH 70
#define NORMAL_VIDEO_HEIGHT 100

#define RIGHT_VIEW_WIDTH 515

#define SLIDE_VIEWS_MINUS_X_POSITION -0

#define LEFT_MENU_DIPLAY_WIDTH 80

#define degreesToRadian(x) (3.14159265358979323846 * x/ 180.0)

#define APPIRATER_APP_ID				646683195

#define WATCH_RECORD_CACHE_KEY @"watch_record2"

#define SHOW_MENU_INTRO @"show_menu_intro"
#define WEIBO_INTRO @"weibbo_intro"
#define SHOW_MENU_INTRO_YUEDAN @"show_menu_intro_yuedan"
#define SHOW_PLAY_INTRO_WITH_DOWNLOAD @"show_play_intro_with_download"
#define WIFI_IS_NOT_AVAILABLE @"wifi_is_not_available"
#define KEY_NETWORK_BECOME_AVAILABLE    (@"network_available")
#define APPLICATION_DID_ENTER_BACKGROUND_NOTIFICATION   (@"applicationDidEnterBackground")
#define APPLICATION_DID_BECOME_ACTIVE_NOTIFICATION      (@"applicationDidBecomeActive")

#define LOCAL_HTTP_SERVER_URL @"http://127.0.0.1:12580"

#define CACHE_QUEUE @"MY_CACHE_QUEUE"

#define DocumentsDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]

typedef enum {
    MOVIE_TYPE = 1,
    DRAMA_TYPE = 2,
    SHOW_TYPE = 3,
    COMIC_TYPE = 131,
} VideoType;

typedef enum {
    MOVIE_TOPIC = 1,
    DRAMA_TOPIC = 2,
} TopicType;

typedef enum {
    MOVIE_TOP = 1,
    DRAMA_TOP = 2,
    COMIC_TOP = 3,
    SHOW_TOP = 4,
} TopType;

@interface CMConstants : NSObject 
    extern NSString * const MyString;

+ (UIColor*)grayColor;

+ (UIColor*)yellowColor;

+ (UIColor *)scoreBlueColor;

+ (UIColor *)titleBlueColor;

+ (UIFont *)titleFont;

+ (UIColor *)tableBorderColor;

+ (UIColor *)backgroundColor;

+ (UIColor *)textColor;

@end
