//
//  CategoryUtility.m
//  yueshipin
//
//  Created by joyplus1 on 13-4-3.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "CategoryUtility.h"
#import "CategoryItem.h"

@implementation CategoryUtility

+ (NSArray *)getHightlightCategoryByType:(VideoType)type
{
    if (type == MOVIE_TYPE) {
        return [self getMovieHighlightCategory];
    } else if (type == DRAMA_TYPE){
        return [self getDramaHighlightCategory];
    } else if (type == SHOW_TYPE){
        return [self getShowHighlightCategory];
    } else if (type == COMIC_TYPE){
        return [self getComicHighlightCategory];
    } else {
        return nil;
    }
}
+ (NSArray *)getCategoryByType:(VideoType)type
{
    if (type == MOVIE_TYPE) {
        return [self getMovieCategory];
    } else if (type == DRAMA_TYPE){
        return [self getDramaCategory];
    } else if (type == SHOW_TYPE){
        return [self getShowCategory];
    } else if (type == COMIC_TYPE){
        return [self getComicCategory];
    } else {
        return nil;
    }
}
+ (NSArray *)getRegionTypeByType:(VideoType)type
{
    if (type == MOVIE_TYPE) {
        return [self getMovieRegionType];
    } else if (type == DRAMA_TYPE){
        return [self getDramaRegionType];
    } else if (type == SHOW_TYPE){
        return [self getShowRegionType];
    } else if (type == COMIC_TYPE){
        return [self getComicRegionType];
    } else {
        return nil;
    }
}
+ (NSArray *)getYearTypeByType:(VideoType)type
{
    if (type == MOVIE_TYPE) {
        return [self getMovieYearType];
    } else if (type == DRAMA_TYPE){
        return [self getDramaYearType];
    } else if (type == SHOW_TYPE){
        return [self getShowYearType];
    } else if (type == COMIC_TYPE){
        return [self getComicYearType];
    } else {
        return nil;
    }
}


+ (NSArray *)getComicHighlightCategory
{
    NSMutableArray *categoryArray = [[NSMutableArray alloc]initWithCapacity:10];
    CategoryItem *item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = NO_TYPE;
    item.label = @"全部";
    item.key = @"all";
    item.value = @"全部";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"日本";
    item.key = @"japan";
    item.value = @"日本";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"欧美";
    item.key = @"europe";
    item.value = @"欧美";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"国产";
    item.key = @"china";
    item.value = @"国产";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"情感";
    item.key = @"emotion";
    item.value = @"情感";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"科幻";
    item.key = @"fiction";
    item.value = @"科幻";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"热血";
    item.key = @"blood";
    item.value = @"热血";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"推理";
    item.key = @"logic";
    item.value = @"推理";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"搞笑";
    item.key = @"hilarious";
    item.value = @"搞笑";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = MORE_TYPE;
    item.label = @"更多";
    item.key = @"other";
    item.value = @"更多";
    [categoryArray addObject:item];
    
    return categoryArray;
}

+ (NSArray *)getComicCategory
{
    NSMutableArray *categoryArray = [[NSMutableArray alloc]initWithCapacity:23];
    CategoryItem *item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = ALL_CATEGORY;
    item.label = @"全部";
    item.key = @"all";
    item.value = @"全部";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"情感";
    item.key = @"emotion";
    item.value = @"情感";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"科幻";
    item.key = @"fiction";
    item.value = @"科幻";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"热血";
    item.key = @"blood";
    item.value = @"热血";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"推理";
    item.key = @"logic";
    item.value = @"推理";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"搞笑";
    item.key = @"hilarious";
    item.value = @"搞笑";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"冒险";
    item.key = @"venture";
    item.value = @"冒险";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"萝莉";
    item.key = @"fightgirl";
    item.value = @"萝莉";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"校园";
    item.key = @"school";
    item.value = @"校园";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"动作";
    item.key = @"action";
    item.value = @"动作";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"机战";
    item.key = @"fight";
    item.value = @"机战";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"运动";
    item.key = @"sport";
    item.value = @"运动";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"耽美";
    item.key = @"gay";
    item.value = @"耽美";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"战争";
    item.key = @"war";
    item.value = @"战争";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"少年";
    item.key = @"boy";
    item.value = @"少年";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"少女";
    item.key = @"girl";
    item.value = @"少女";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"社会";
    item.key = @"socity";
    item.value = @"社会";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"原创";
    item.key = @"create";
    item.value = @"原创";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"亲子";
    item.key = @"parent";
    item.value = @"亲子";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"益智";
    item.key = @"bright";
    item.value = @"益智";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"励志";
    item.key = @"working";
    item.value = @"励志";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"百合";
    item.key = @"lesbian";
    item.value = @"百合";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"其他";
    item.key = @"other";
    item.value = @"其他";
    [categoryArray addObject:item];
    
    return categoryArray;
}

+ (NSArray *)getComicRegionType
{
    NSMutableArray *categoryArray = [[NSMutableArray alloc]initWithCapacity:5];
    CategoryItem *item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = ALL_REGION;
    item.label = @"全部";
    item.key = @"all";
    item.value = @"全部";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"日本";
    item.key = @"japan";
    item.value = @"日本";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"欧美";
    item.key = @"europe";
    item.value = @"欧美";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"国产";
    item.key = @"china";
    item.value = @"国产";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"其他";
    item.key = @"other";
    item.value = @"其他";
    [categoryArray addObject:item];
    
    return categoryArray;
}

+ (NSArray *)getComicYearType
{
    NSArray *yearLabelArray = [self getYearType];
    NSMutableArray *categoryArray = [[NSMutableArray alloc]initWithCapacity:5];
    CategoryItem *item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = ALL_YEAR;
    item.label = [yearLabelArray objectAtIndex:0];
    item.key = @"all";
    item.value = [yearLabelArray objectAtIndex:0];
    [categoryArray addObject:item];
    
    for (int i = 1; i < yearLabelArray.count - 2; i++) {
        item = [[CategoryItem alloc]init];
        item.type = COMIC_TYPE;
        item.subtype = YEAR_TYPE;
        item.label = [yearLabelArray objectAtIndex:i];
        item.key = [yearLabelArray objectAtIndex:i];
        item.value = [yearLabelArray objectAtIndex:i];
        [categoryArray addObject:item];
    }
    
    item = [[CategoryItem alloc]init];
    item.type = COMIC_TYPE;
    item.subtype = YEAR_TYPE;
    item.label = [yearLabelArray objectAtIndex:yearLabelArray.count-1];
    item.key = @"other";
    item.value = [yearLabelArray objectAtIndex:yearLabelArray.count-1];
    [categoryArray addObject:item];
    
    return categoryArray;
}

+ (NSArray *)getYearType
{
    NSDate * nowDate = [NSDate date];
    NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
    [dateformat setDateFormat:@"yyyy"];
    int year = [[dateformat stringFromDate:nowDate] integerValue];
    NSMutableArray *yearLabelArray = [[NSMutableArray alloc]initWithCapacity:12];
    [yearLabelArray addObject:@"全部"];
    for (int i = 0; i < 10; i++) {
        [yearLabelArray addObject:[NSString stringWithFormat:@"%i", year - i]];
    }
    [yearLabelArray addObject:@"其他"];
    return yearLabelArray;
}

+ (NSArray *)getMovieHighlightCategory
{
    NSMutableArray *categoryArray = [[NSMutableArray alloc]initWithCapacity:10];
    CategoryItem *item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = NO_TYPE;
    item.label = @"全部";
    item.key = @"all";
    item.value = @"全部";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"内地";
    item.key = @"china";
    item.value = @"内地";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"香港";
    item.key = @"hongkang";
    item.value = @"香港";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"台湾";
    item.key = @"taiwan";
    item.value = @"台湾";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"美国";
    item.key = @"america";
    item.value = @"美国";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"科幻";
    item.key = @"fiction";
    item.value = @"科幻";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"动作";
    item.key = @"action";
    item.value = @"动作";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"恐怖";
    item.key = @"horrible";
    item.value = @"恐怖";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"喜剧";
    item.key = @"comedy";
    item.value = @"喜剧";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = MORE_TYPE;
    item.label = @"更多";
    item.key = @"other";
    item.value = @"更多";
    [categoryArray addObject:item];
    return categoryArray;
}

+ (NSArray *)getMovieCategory
{
    NSMutableArray *categoryArray = [[NSMutableArray alloc]initWithCapacity:23];
    CategoryItem *item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = ALL_CATEGORY;
    item.label = @"全部";
    item.key = @"all";
    item.value = @"全部";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"恐怖";
    item.key = @"horrible";
    item.value = @"恐怖";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"惊悚";
    item.key = @"thriller";
    item.value = @"惊悚";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"悬疑";
    item.key = @"blood";
    item.value = @"悬疑";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"伦理";
    item.key = @"logic";
    item.value = @"伦理";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"爱情";
    item.key = @"love";
    item.value = @"爱情";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"剧情";
    item.key = @"plot";
    item.value = @"剧情";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"喜剧";
    item.key = @"comedy";
    item.value = @"喜剧";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"科幻";
    item.key = @"fiction";
    item.value = @"科幻";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"动作";
    item.key = @"action";
    item.value = @"动作";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"战争";
    item.key = @"war";
    item.value = @"战争";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"冒险";
    item.key = @"venture";
    item.value = @"冒险";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"音乐";
    item.key = @"music";
    item.value = @"音乐";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"动画";
    item.key = @"comic";
    item.value = @"动画";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"运动";
    item.key = @"sport";
    item.value = @"运动";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"奇幻";
    item.key = @"fantacy";
    item.value = @"奇幻";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"传记";
    item.key = @"biography";
    item.value = @"传记";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"古装";
    item.key = @"ancient";
    item.value = @"古装";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"犯罪";
    item.key = @"crime";
    item.value = @"犯罪";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"武侠";
    item.key = @"fight";
    item.value = @"武侠";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"其他";
    item.key = @"other";
    item.value = @"其他";
    [categoryArray addObject:item];
    
    return categoryArray;
}

+ (NSArray *)getMovieRegionType
{
    NSMutableArray *categoryArray = [[NSMutableArray alloc]initWithCapacity:5];
    CategoryItem *item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = ALL_REGION;
    item.label = @"全部";
    item.key = @"all";
    item.value = @"全部";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"内地";
    item.key = @"china";
    item.value = @"内地";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"香港";
    item.key = @"hongkang";
    item.value = @"香港";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"台湾";
    item.key = @"taiwan";
    item.value = @"台湾";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"美国";
    item.key = @"america";
    item.value = @"美国";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"日本";
    item.key = @"japan";
    item.value = @"日本";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"韩国";
    item.key = @"korea";
    item.value = @"韩国";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"东南亚";
    item.key = @"asia";
    item.value = @"东南亚";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"欧洲";
    item.key = @"europe";
    item.value = @"欧洲";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"其他";
    item.key = @"other";
    item.value = @"其他";
    [categoryArray addObject:item];
    
    return categoryArray;
}

+ (NSArray *)getMovieYearType
{
    NSArray *yearLabelArray = [self getYearType];
    NSMutableArray *categoryArray = [[NSMutableArray alloc]initWithCapacity:5];
    CategoryItem *item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = ALL_YEAR;
    item.label = [yearLabelArray objectAtIndex:0];
    item.key = @"all";
    item.value = [yearLabelArray objectAtIndex:0];
    [categoryArray addObject:item];
    
    for (int i = 1; i < yearLabelArray.count - 2; i++) {
        item = [[CategoryItem alloc]init];
        item.type = MOVIE_TYPE;
        item.subtype = YEAR_TYPE;
        item.label = [yearLabelArray objectAtIndex:i];
        item.key = [yearLabelArray objectAtIndex:i];
        item.value = [yearLabelArray objectAtIndex:i];
        [categoryArray addObject:item];
    }
    
    item = [[CategoryItem alloc]init];
    item.type = MOVIE_TYPE;
    item.subtype = YEAR_TYPE;
    item.label = [yearLabelArray objectAtIndex:yearLabelArray.count-1];
    item.key = @"other";
    item.value = [yearLabelArray objectAtIndex:yearLabelArray.count-1];
    [categoryArray addObject:item];
    
    return categoryArray;
}

+ (NSArray *)getDramaHighlightCategory
{
    NSMutableArray *categoryArray = [[NSMutableArray alloc]initWithCapacity:10];
    CategoryItem *item = [[CategoryItem alloc]init];
    item.type = DRAMA_TYPE;
    item.subtype = NO_TYPE;
    item.label = @"全部";
    item.key = @"all";
    item.value = @"全部";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = DRAMA_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"内地";
    item.key = @"china";
    item.value = @"内地";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = DRAMA_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"美国";
    item.key = @"america";
    item.value = @"美国";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = DRAMA_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"香港";
    item.key = @"hongkang";
    item.value = @"香港";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = DRAMA_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"台湾";
    item.key = @"taiwan";
    item.value = @"台湾";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = DRAMA_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"韩国";
    item.key = @"korea";
    item.value = @"韩国";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = DRAMA_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"犯罪";
    item.key = @"crime";
    item.value = @"犯罪";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = DRAMA_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"战争";
    item.key = @"war";
    item.value = @"战争";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = DRAMA_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"古装";
    item.key = @"actient";
    item.value = @"古装";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = DRAMA_TYPE;
    item.subtype = MORE_TYPE;
    item.label = @"更多";
    item.key = @"other";
    item.value = @"更多";
    [categoryArray addObject:item];
    
    return categoryArray;
}


+ (NSArray *)getDramaCategory
{
    NSMutableArray *categoryArray = [[NSMutableArray alloc]initWithCapacity:23];
    CategoryItem *item = [[CategoryItem alloc]init];
    item.type = DRAMA_TYPE;
    item.subtype = ALL_CATEGORY;
    item.label = @"全部";
    item.key = @"all";
    item.value = @"全部";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = DRAMA_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"剧情";
    item.key = @"plot";
    item.value = @"剧情";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = DRAMA_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"喜剧";
    item.key = @"comedy";
    item.value = @"喜剧";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = DRAMA_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"犯罪";
    item.key = @"crime";
    item.value = @"犯罪";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = DRAMA_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"战争";
    item.key = @"war";
    item.value = @"战争";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = DRAMA_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"青春偶像";
    item.key = @"youth";
    item.value = @"青春偶像";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = DRAMA_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"古装";
    item.key = @"actient";
    item.value = @"古装";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = DRAMA_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"动作";
    item.key = @"action";
    item.value = @"动作";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = DRAMA_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"奇幻";
    item.key = @"fantacy";
    item.value = @"奇幻";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = DRAMA_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"历史";
    item.key = @"history";
    item.value = @"历史";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = DRAMA_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"乡村";
    item.key = @"country";
    item.value = @"乡村";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = DRAMA_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"家庭伦理";
    item.key = @"family";
    item.value = @"家庭伦理";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = DRAMA_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"商战";
    item.key = @"business";
    item.value = @"商战";
    [categoryArray addObject:item];
    

    
    item = [[CategoryItem alloc]init];
    item.type = DRAMA_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"情景";
    item.key = @"sport";
    item.value = @"情景";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = DRAMA_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"TVB";
    item.key = @"TVB";
    item.value = @"TVB";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = DRAMA_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"其他";
    item.key = @"other";
    item.value = @"其他";
    [categoryArray addObject:item];    
    
    return categoryArray;
}

+ (NSArray *)getDramaRegionType
{
    NSMutableArray *categoryArray = [[NSMutableArray alloc]initWithCapacity:5];
    CategoryItem *item = [[CategoryItem alloc]init];
    item.type = DRAMA_TYPE;
    item.subtype = ALL_REGION;
    item.label = @"全部";
    item.key = @"all";
    item.value = @"全部";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = DRAMA_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"内地";
    item.key = @"china";
    item.value = @"内地";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = DRAMA_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"香港";
    item.key = @"hongkang";
    item.value = @"香港";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = DRAMA_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"台湾";
    item.key = @"taiwan";
    item.value = @"台湾";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = DRAMA_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"韩国";
    item.key = @"korea";
    item.value = @"韩国";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = DRAMA_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"美国";
    item.key = @"america";
    item.value = @"美国";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = DRAMA_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"日本";
    item.key = @"japan";
    item.value = @"日本";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = DRAMA_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"其他";
    item.key = @"other";
    item.value = @"其他";
    [categoryArray addObject:item];
    
    return categoryArray;
}

+ (NSArray *)getDramaYearType
{
    NSArray *yearLabelArray = [self getYearType];
    NSMutableArray *categoryArray = [[NSMutableArray alloc]initWithCapacity:5];
    CategoryItem *item = [[CategoryItem alloc]init];
    item.type = DRAMA_TYPE;
    item.subtype = ALL_YEAR;
    item.label = [yearLabelArray objectAtIndex:0];
    item.key = @"all";
    item.value = [yearLabelArray objectAtIndex:0];
    [categoryArray addObject:item];
    
    for (int i = 1; i < yearLabelArray.count - 2; i++) {
        item = [[CategoryItem alloc]init];
        item.type = DRAMA_TYPE;
        item.subtype = YEAR_TYPE;
        item.label = [yearLabelArray objectAtIndex:i];
        item.key = [yearLabelArray objectAtIndex:i];
        item.value = [yearLabelArray objectAtIndex:i];
        [categoryArray addObject:item];
    }
    
    item = [[CategoryItem alloc]init];
    item.type = DRAMA_TYPE;
    item.subtype = YEAR_TYPE;
    item.label = [yearLabelArray objectAtIndex:yearLabelArray.count-1];
    item.key = @"other";
    item.value = [yearLabelArray objectAtIndex:yearLabelArray.count-1];
    [categoryArray addObject:item];
    
    return categoryArray;
}

+ (NSArray *)getShowHighlightCategory
{
    NSMutableArray *categoryArray = [[NSMutableArray alloc]initWithCapacity:10];
    CategoryItem *item = [[CategoryItem alloc]init];
    item.type = SHOW_TYPE;
    item.subtype = NO_TYPE;
    item.label = @"全部";
    item.key = @"all";
    item.value = @"全部";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = SHOW_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"港台";
    item.key = @"kang-tai";
    item.value = @"港台";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = SHOW_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"内地";
    item.key = @"china";
    item.value = @"内地";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = SHOW_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"日韩";
    item.key = @"japan-korea";
    item.value = @"日韩";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = SHOW_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"欧美";
    item.key = @"europe";
    item.value = @"欧美";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = SHOW_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"综艺";
    item.key = @"show";
    item.value = @"综艺";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = SHOW_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"选秀";
    item.key = @"choice";
    item.value = @"选秀";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = SHOW_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"情感";
    item.key = @"emotion";
    item.value = @"情感";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = SHOW_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"访谈";
    item.key = @"dialog";
    item.value = @"访谈";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = SHOW_TYPE;
    item.subtype = MORE_TYPE;
    item.label = @"更多";
    item.key = @"other";
    item.value = @"更多";
    [categoryArray addObject:item];

    return categoryArray;
}


+ (NSArray *)getShowCategory
{
    NSMutableArray *categoryArray = [[NSMutableArray alloc]initWithCapacity:23];
    CategoryItem *item = [[CategoryItem alloc]init];
    item.type = SHOW_TYPE;
    item.subtype = ALL_CATEGORY;
    item.label = @"全部";
    item.key = @"all";
    item.value = @"全部";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = SHOW_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"综艺";
    item.key = @"show";
    item.value = @"综艺";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = SHOW_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"选秀";
    item.key = @"choice";
    item.value = @"选秀";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = SHOW_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"情感";
    item.key = @"emotion";
    item.value = @"情感";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = SHOW_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"访谈";
    item.key = @"dialog";
    item.value = @"访谈";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = SHOW_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"播报";
    item.key = @"talk";
    item.value = @"播报";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = SHOW_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"旅游";
    item.key = @"travel";
    item.value = @"旅游";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = SHOW_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"音乐";
    item.key = @"music";
    item.value = @"音乐";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = SHOW_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"美食";
    item.key = @"food";
    item.value = @"美食";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = SHOW_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"纪实";
    item.key = @"reality";
    item.value = @"纪实";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = SHOW_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"曲艺";
    item.key = @"performance";
    item.value = @"曲艺";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = SHOW_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"生活";
    item.key = @"life";
    item.value = @"生活";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = SHOW_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"游戏";
    item.key = @"game";
    item.value = @"游戏";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = SHOW_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"互动";
    item.key = @"interactive";
    item.value = @"互动";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = SHOW_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"财经";
    item.key = @"commerce";
    item.value = @"财经";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = SHOW_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"求职";
    item.key = @"interview";
    item.value = @"求职";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = SHOW_TYPE;
    item.subtype = CATEGORY_TYPE;
    item.label = @"其他";
    item.key = @"other";
    item.value = @"其他";
    [categoryArray addObject:item];
    
    return categoryArray;
}

+ (NSArray *)getShowRegionType
{
    NSMutableArray *categoryArray = [[NSMutableArray alloc]initWithCapacity:5];
    CategoryItem *item = [[CategoryItem alloc]init];
    item.type = SHOW_TYPE;
    item.subtype = ALL_REGION;
    item.label = @"全部";
    item.key = @"all";
    item.value = @"全部";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = SHOW_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"港台";
    item.key = @"kang-tai";
    item.value = @"港台";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = SHOW_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"内地";
    item.key = @"china";
    item.value = @"内地";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = SHOW_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"日韩";
    item.key = @"japan-korea";
    item.value = @"日韩";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = SHOW_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"欧美";
    item.key = @"europe";
    item.value = @"欧美";
    [categoryArray addObject:item];
    
    item = [[CategoryItem alloc]init];
    item.type = SHOW_TYPE;
    item.subtype = REGION_TYPE;
    item.label = @"其他";
    item.key = @"other";
    item.value = @"其他";
    [categoryArray addObject:item];
    
    return categoryArray;
}

+ (NSArray *)getShowYearType
{
    NSArray *yearLabelArray = [self getYearType];
    NSMutableArray *categoryArray = [[NSMutableArray alloc]initWithCapacity:5];
    CategoryItem *item = [[CategoryItem alloc]init];
    item.type = SHOW_TYPE;
    item.subtype = ALL_YEAR;
    item.label = [yearLabelArray objectAtIndex:0];
    item.key = @"all";
    item.value = [yearLabelArray objectAtIndex:0];
    [categoryArray addObject:item];
    
    for (int i = 1; i < yearLabelArray.count - 2; i++) {
        item = [[CategoryItem alloc]init];
        item.type = SHOW_TYPE;
        item.subtype = YEAR_TYPE;
        item.label = [yearLabelArray objectAtIndex:i];
        item.key = [yearLabelArray objectAtIndex:i];
        item.value = [yearLabelArray objectAtIndex:i];
        [categoryArray addObject:item];
    }
    
    item = [[CategoryItem alloc]init];
    item.type = SHOW_TYPE;
    item.subtype = YEAR_TYPE;
    item.label = [yearLabelArray objectAtIndex:yearLabelArray.count-1];
    item.key = @"other";
    item.value = [yearLabelArray objectAtIndex:yearLabelArray.count-1];
    [categoryArray addObject:item];
    
    return categoryArray;
}


@end
