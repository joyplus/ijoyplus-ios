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

#define HOME_VIEW_TAG 19801127
#define HOME_MUSIC_CONTAINER_TAG 19801203
#define HOME_VIDEO_CONTAINER_TAG 19801204
#define HOME_IMAGE_CONTAINER_TAG 19801205

#define ITEM_VIEW_TAG 20110106

#define GRID_VIEW_WIDTH 232
#define GRID_VIEW_HEIGHT 340

#define USER_INPUT_URL_HISTORY @"user_input_url_history"
#define BOOK_MARK_LIST @"book_mark_list"


@interface CMConstants : NSObject 
    extern NSString * const MyString;


+ (UIColor *)blackBackgroundColor;

+ (UIColor *)whiteBackgroundColor;

+ (UIColor *)textGreyColor;

+ (UIColor *)textBlueColor;

@end
