//
//  DatabaseManager.m
//  yueshipin
//
//  Created by joyplus1 on 13-4-12.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "DatabaseManager.h"
#import "FMDatabaseQueue.h"
#import "FMDatabase.h"
#import "DownloadItem.h"
#import "SubdownloadItem.h"
#import "SegmentUrl.h"
#define DocumentsDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]
#define DATABASE_PATH [DocumentsDirectory stringByAppendingPathComponent:@"yueshipin.db"]

@interface DatabaseManager (){
    NSString *path;
}

@end

@implementation DatabaseManager

+ (void)initDatabase
{
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"Could not open db in DatabaseManager!");
    }
    // CREATE TABEL
    [db close];
}

- (void)createTable
{
    
}

- (NSArray *)findByCriteria:(Class)dbObjectClass queryString:(NSString *)queryString
{
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"Could not open db in DatabaseManager!");
        return nil;
    }
    FMResultSet *rs = [db executeQuery:queryString];
    NSMutableArray *resultArray = [[NSMutableArray alloc]initWithCapacity:5];
    while ([rs next]) {
        if (dbObjectClass == DownloadItem.class) {
            DownloadItem *tempDbObj = [[DownloadItem alloc]init];
            tempDbObj.name = [rs stringForColumn:@"name"];
            [resultArray addObject:tempDbObj];
        } else if (dbObjectClass ==  [SubdownloadItem class]) {
            SubdownloadItem *tempDbObj = [[SubdownloadItem alloc]init];
            tempDbObj.name = [rs stringForColumn:@"name"];
        } else if (dbObjectClass == SegmentUrl.class) {
            SegmentUrl *tempDbObj = [[SegmentUrl alloc]init];
            tempDbObj.url = [rs stringForColumn:@"url"];
        }
    }
    [rs close];
    [db close];
    return  resultArray;
}

- (DatabaseObject *)findFirstByCriteria:(Class *)dbObjectClass queryString:(NSString *)queryString
{
//    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
//    if (![db open]) {
//        NSLog(@"Could not open db in DatabaseManager!");
//        return nil;
//    }
//    FMResultSet *rs = [db executeQuery:queryString];
}

- (NSArray *)allObjects:(Class)dbObjectClass
{
   
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"Could not open db in DatabaseManager!");
        return nil;
    }
    
    NSString *tableName = [NSString stringWithUTF8String:class_getName(dbObjectClass)];
    NSString *queryString = [NSString stringWithFormat:@"SELECT * From %@",tableName];
    FMResultSet *rs = [db executeQuery:queryString];
    NSMutableArray *resultArray = [[NSMutableArray alloc]initWithCapacity:5];
    while ([rs next]) {
        if (dbObjectClass == DownloadItem.class) {
            DownloadItem *tempDbObj = [[DownloadItem alloc]init];
            tempDbObj.itemId =  [rs stringForColumn:@"itemId"];
            tempDbObj.name = [rs stringForColumn:@"name"];
            tempDbObj.imageUrl = [rs stringForColumn:@"imageUrl"];
            tempDbObj.fileName = [rs stringForColumn:@"fileName"];
            tempDbObj.downloadStatus = [rs stringForColumn:@"downloadStatus"];
            tempDbObj.type = [[rs stringForColumn:@"type"] intValue];
            tempDbObj.percentage = [[rs stringForColumn:@"percentage"] intValue];
            tempDbObj.url = [rs stringForColumn:@"url"];
            tempDbObj.isDownloadingNum = [[rs stringForColumn:@"isDownloadingNum"] intValue];
            tempDbObj.downloadType = [rs stringForColumn:@"downloadType"];
            tempDbObj.duration = [[rs stringForColumn:@"duration"] doubleValue];
            [resultArray addObject:tempDbObj];
            
        } else if (dbObjectClass == SubdownloadItem.class) {
            SubdownloadItem *tempDbObj = [[SubdownloadItem alloc]init];
            tempDbObj.itemId =  [rs stringForColumn:@"itemId"];
            tempDbObj.name = [rs stringForColumn:@"name"];
            tempDbObj.imageUrl = [rs stringForColumn:@"imageUrl"];
            tempDbObj.fileName = [rs stringForColumn:@"fileName"];
            tempDbObj.downloadStatus = [rs stringForColumn:@"downloadStatus"];
            tempDbObj.type = [[rs stringForColumn:@"type"] intValue];
            tempDbObj.percentage = [[rs stringForColumn:@"percentage"] intValue];
            tempDbObj.url = [rs stringForColumn:@"url"];
            tempDbObj.isDownloadingNum = [[rs stringForColumn:@"isDownloadingNum"] intValue];
            tempDbObj.downloadType = [rs stringForColumn:@"downloadType"];
            tempDbObj.duration = [[rs stringForColumn:@"duration"] doubleValue];
            tempDbObj.subitemId = [rs stringForColumn:@"subitemId"];
            [resultArray addObject:tempDbObj];
        } else if (dbObjectClass == SegmentUrl.class) {
        
            SegmentUrl *tempDbObj = [[SegmentUrl alloc]init];
            tempDbObj.url = [rs stringForColumn:@"url"];
            tempDbObj.itemId = [rs stringForColumn:@"itemId"];
            tempDbObj.subitemId = [rs stringForColumn:@"subitemId"];
            tempDbObj.seqNum = [[rs stringForColumn:@"seqNum"] intValue];
            [resultArray addObject:tempDbObj];
        }
    }
    [rs close];
    [db close];
    return  resultArray;

    
}
- (double)performSQLAggregation: (NSString *)query
{
    
}

- (void)deleteObject:(DatabaseObject *)dbObject
{
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"Could not open db in DatabaseManager!");
    }
    if ([dbObject isKindOfClass:[DownloadItem class]]) {
        NSString *itemId = ((DownloadItem *)dbObject).itemId;
        NSString *sqlString = [NSString stringWithFormat:@"delete from DownloadItem where itemId = '%@'",itemId];
        [db executeQuery:sqlString];
    }
   else if ([dbObject isKindOfClass:[SubdownloadItem class]]) {
        NSString *subitemId = ((SubdownloadItem *)dbObject).subitemId;
        NSString *sqlString = [NSString stringWithFormat:@"delete from DownloadItem where subitemId = '%@'",subitemId];
        [db executeQuery:sqlString];
    }
   else if ([dbObject isKindOfClass:[SegmentUrl class]]) {
        NSString *itemId = ((SegmentUrl *)dbObject).itemId;
        NSString *sqlString = [NSString stringWithFormat:@"delete from DownloadItem where itemId = '%@'",itemId];
        [db executeQuery:sqlString];
    }
}
- (void)save:(DatabaseObject *)dbObject
{
    
}
- (NSInteger)count:(Class *)dbObjectClass
{
    
}
- (NSInteger)countByCriteria:(Class *)dbObjectClass queryString:(NSString *)queryString
{
    
}

@end
