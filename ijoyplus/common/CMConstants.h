//
//  CMConstants.h
//  ClassManagement
//
//  Created by 永庆 李 on 12-3-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#define NUMBER_OF_COLUMNS 3

#define NAVIGATION_BAR_HEIGHT 44
#define SEGMENT_HEIGHT 58 / 2
#define SEGMENT_WIDTH 304 
#define SEGMENT_HEIGHT_GAP 15 / 2
#define MOVIE_LOGO_HEIGHT 270 / 2
#define MOVIE_LOGO_WIDTH  190 / 2
#define MOVIE_LOGO_WIDTH_GAP 16 / 2
#define TAB_BAR_HEIGHT 96 / 2
#define MOVE_NAME_LABEL_HEIGHT 60 / 2
#define MOVE_NAME_LABEL_WIDTH 192 / 2
#define VIDEO_LOGO_WIDTH 190 / 2
#define VIDEO_LOGO_HEIGHT 144 / 2
#define LOG_BTN_WIDTH 296 / 2
#define LOG_BTN_HEIGHT 76 / 2
#define MAX_COMMENT_NUMBER 10

#define kTecentAppId @"100317415"   // for login

#define kTencentAppKey @"100666407"
#define kTencentAppSecret @"2a35faffc945dc9f5e432167cc4a1b5a"

#define kSinaWeiboAppKey  @"1490285522"
#define kSinaWeiboAppSecret  @"f9ebc3ca95991b6dfce2c1608687e92b"
#define kPAPUserDefaultsCacheSinaFriendsKey @"sinaFriendKey"
#define kSinaWeiboAccessToken @"sinaAccessToken"
#define kSinaWeiboUID @"sinaUid"

#define kUserLoggedIn @"userLoggedIn"
#define kSinaUID @"kSinaUID"
#define kTencentUserLoggedIn @"tencentUserLoggedIn"

#define kUserLoginService @"joypluslogin"
#define kUserId @"kUserId"
#define kUserName @"kUserName"
#define kUserNickName @"kUserNickName"
#define kSessionRenew @"kSessionRenew"
#define kPhoneNumber @"kPhoneNumber"

#define LOCAL_KEYS_NUMBER 5
#define umengAppKey @"5074db485270155fcd000093"

#define YOU_KU @"youku"
#define TU_DOU @"tudou"
#define PPTV @"pptv"
#define LETV @"letv"

#define GAO_QING @"mp4"
#define BIAO_QING @"flv"
#define CHAO_QING @"hd2"
#define LIU_CHANG @"3gp"

@interface CMConstants : NSObject 
    extern NSString * const MyString;

+ (UIColor*)greyColor;

+ (UIColor *)colorLoadMore;

+ (UIFont *)fontLoadMore;

+ (UIColor *)separatorColor;

+ (UIColor *)textColor;

+ (UIFont *)titleFont;

+ (UIColor *)imageBorderColor;

@end
