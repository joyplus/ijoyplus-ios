//
//  CMConstants.h
//  ClassManagement
//
//  Created by 永庆 李 on 12-3-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#define NAVIGATION_BAR_HEIGHT 44
#define TOOLBAR_HEIGHT 40
#define STATUS_BAR_HEIGHT 24

#define ITEM_VIEW_TAG 20110106

#define GRID_VIEW_WIDTH 232
#define GRID_VIEW_HEIGHT 340
#define TOUCH_SCREEN_WIDTH 237
#define USER_INPUT_URL_HISTORY @"user_input_url_history"
#define BOOK_MARK_LIST @"book_mark_list"
//#define APP_LIST @"app_list"
#define RELOAD_APP_LIST @"reload_app_list"
#define DONGLE_IS_CONNECTED @"dongle_is_connected"
#define RELOAD_SCREENSHOT @"reload_screenshot"
#define SHOW_DEVICE_LIST @"show_device_list"
#define RELOAD_DEVICE_LIST @"reload_device_list"
#define RELOAD_SCREEN_SETTING @"reload_screen_setting"

#define TURN_ON_GRAVITY @"turn_on_gravity"
#define GRAVITY_DIRECTION @"gravity_direction"
#define GRAVITY_SCALE @"gravity_scale"
#define TOUCH_SCALE @"touch_scale"

@interface CMConstants : NSObject 
    extern NSString * const MyString;


+ (UIColor *)menuTextColor;

+ (UIColor *)textColor;
+ (UIColor *)textBlueColor;
@end
