//
//  CMConstants.h
//  ClassManagement
//
//  Created by 永庆 李 on 12-3-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#define MOVIE_POSTER_WIDTH 71
#define MOVIE_POSTER_HEIGHT 95 

#define kJoyplusWebSite @"http://app.joyplus.tv"
#define kSinaWeiboBaseUrl @"https://api.weibo.com"
#define kSinaWeiboUpdateUrl @"statuses/update.json"
#define kSinaWeiboUpdateWithImageUrl @"statuses/upload_url_text.json"

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

#define kUserLoginService @"joypluslogin"
#define kUserId @"kUserId"
#define kUserName @"kUserName"
#define kUserNickName @"kUserNickName"
#define kUserAvatarUrl @"kUserAvatarUrl"
#define kSessionRenew @"kSessionRenew"
#define kPhoneNumber @"kPhoneNumber"

#define LOCAL_KEYS_NUMBER 5
#define umengAppKey @"50c069e25270154e81000056"

#define YOU_KU @"youku"
#define TU_DOU @"tudou"
#define PPTV @"pptv"
#define LETV @"letv"

#define GAO_QING @"mp4"
#define BIAO_QING @"flv"
#define CHAO_QING @"hd2"
#define LIU_CHANG @"3gp"

#define WATCH_RECORD_NUMBER 5

#define LAST_UPDATE_DATE_FOR_TOPS @"last_update_date_for_tops"

#define LEFT_VIEW_WIDTH 529

#define RIGHT_VIEW_WIDTH 760

#define degreesToRadian(x) (3.14159265358979323846 * x/ 180.0)

#define APPIRATER_APP_ID				301377083

@interface CMConstants : NSObject 
    extern NSString * const MyString;

+ (UIColor*)grayColor;

+ (UIColor *)scoreBlueColor;

+ (UIColor *)titleBlueColor;

+ (UIFont *)titleFont;

+ (UIColor *)tableBorderColor;

@end
