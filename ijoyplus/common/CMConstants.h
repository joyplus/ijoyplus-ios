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


#define kTencentAppKey @"801232108"
#define kTencentAppSecret @"c041e953e68e7fea950b7edd769e7e21"

#define kSinaWeiboAppKey  @"2591167999"
#define kSinaWeiboAppSecret  @"9daabc29b950d8b46c6c916141ea6ec9"
#define kPAPUserDefaultsCacheSinaFriendsKey @"sinaFriendKey"
#define kSinaWeiboAccessToken @"sinaAccessToken"
#define kSinaWeiboUID @"sinaUid"

#define kUserLoggedIn @"userLoggedIn"
#define kSinaUID @"kSinaUID"
#define kTencentUserLoggedIn @"tencentUserLoggedIn"

#define kUserName @"kUserName"
#define kUserNickName @"kUserNickName"
#define kSessionRenew @"kSessionRenew"
#define kPhoneNumber @"kPhoneNumber"

#define LOCAL_KEYS_NUMBER 5
#define umengAppKey @"507cbb595270153d48000005"

@interface CMConstants : NSObject 
    extern NSString * const MyString;

+ (UIColor*)greyColor;

+ (UIColor *)colorLoadMore;

+ (UIFont *)fontLoadMore;

+ (UIColor *)separatorColor;

+ (UIColor *)textColor;

+ (UIFont *)titleFont;

@end
