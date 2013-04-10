//
//  CategoryItem.h
//  yueshipin
//
//  Created by joyplus1 on 13-4-2.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMConstants.h"

typedef enum
{
    NO_TYPE = 0,
    CATEGORY_TYPE = 1,
    REGION_TYPE = 2,
    YEAR_TYPE = 3,
    ALL_CATEGORY = 4,
    ALL_REGION = 5,
    ALL_YEAR = 6
} VideoCategoryType;

@interface CategoryItem : NSObject

@property (nonatomic) VideoType type;
@property (nonatomic, strong) NSString *label;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *value;
@property (nonatomic) VideoCategoryType subtype;
@end
