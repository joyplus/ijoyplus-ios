//
//  CMConstants.h
//  ClassManagement
//
//  Created by 永庆 李 on 12-3-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#define NUMBER_OF_COLUMNS 3

#define NAVIGATION_BAR_HEIGHT 44
#define SEGMENT_HEIGHT 58 / 2
#define SEGMENT_WIDTH 304 
#define SEGMENT_HEIGHT_GAP 15 / 2
#define MOVIE_LOGO_HEIGHT 276 / 2
#define MOVIE_LOGO_WIDTH  190 / 2
#define MOVIE_LOGO_WIDTH_GAP 16 / 2
#define TAB_BAR_HEIGHT 58
#define MOVE_NAME_LABEL_HEIGHT 30
#define MOVE_NAME_LABEL_WIDTH 192 / 2
#define VIDEO_LOGO_WIDTH 190 / 2
#define VIDEO_LOGO_HEIGHT 144 / 2


@interface CMConstants : NSObject 
    extern NSString * const MyString;

+ (UIColor*)greyColor;

+ (UIColor *)colorLoadMore;

+ (UIFont *)fontLoadMore;

+ (UIColor *)separatorColor;

+ (UIColor *)textColor;

+ (UIFont *)titleFont;

@end
