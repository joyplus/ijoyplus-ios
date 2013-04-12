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

@implementation DatabaseManager

+ (void)initDatabase
{
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"Could not open db in DatabaseManager!");
    }
    // Create tables
    [db executeUpdate:@"create table if not exists DownloadItem (itemId text, imageUrl text, name text, fileName text, downloadStatus text, type integer, percentage integer, url text, isDownloadingNum integer, downloadType text, duration double)"];
    [db executeUpdate:@"create table if not exists SubdownloadItem (itemId text, subitemId text, imageUrl text, name text, fileName text, downloadStatus text, type integer, percentage integer, url text, isDownloadingNum integer, downloadType text, duration double)"];
    [db executeUpdate:@"create table if not exists SegmentUrl (itemId text, subitemId text, url text, seqNum integer)"];
    
    [db close];
}

+ (NSArray *)findByCriteria:(Class)dbObjectClass queryString:(NSString *)queryString
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

+ (NSObject *)findFirstByCriteria:(Class)dbObjectClass queryString:(NSString *)queryString
{
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"Could not open db in DatabaseManager!");
        return nil;
    }
    FMResultSet *rs = [db executeQuery:queryString];
    if ([rs next]) {
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
            [rs close];
            [db close];
            
            return tempDbObj;
            
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
            [rs close];
            [db close];
            
            return tempDbObj;
            
        } else if (dbObjectClass == SegmentUrl.class) {
            
            SegmentUrl *tempDbObj = [[SegmentUrl alloc]init];
            tempDbObj.url = [rs stringForColumn:@"url"];
            tempDbObj.itemId = [rs stringForColumn:@"itemId"];
            tempDbObj.subitemId = [rs stringForColumn:@"subitemId"];
            tempDbObj.seqNum = [[rs stringForColumn:@"seqNum"] intValue];
            [rs close];
            [db close];
            
            return tempDbObj;
        }

    }
    [rs close];
    [db close];
    return nil;
   
}

+ (NSArray *)allObjects:(Class)dbObjectClass
{
   
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"Could not open db in DatabaseManager!");
        return nil;
    }
    
    //NSString *tableName = [NSString stringWithUTF8String:class_getName(dbObjectClass)];
    NSString *queryString = [NSString stringWithFormat:@"SELECT * From %@",dbObjectClass];
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
+ (BOOL)performSQLAggregation: (NSString *)query
{
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"Could not open db in DatabaseManager!");
        return NO;
    }
    BOOL result = [db executeUpdate:query];
    [db close];
    return result;
    
}

+ (void)deleteObject:(DatabaseObject *)dbObject
{
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"Could not open db in DatabaseManager!");
        return;
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
    [db close];
}
+ (void)save:(DatabaseObject *)dbObject
{
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:DATABASE_PATH];
    [queue inDatabase:^(FMDatabase *db) {
        if ([dbObject isKindOfClass:DownloadItem.class]) {
            DownloadItem *obj = (DownloadItem *)dbObject;
            [db executeUpdate:@"insert into DownloadItem(itemId, imageUrl, name, fileName, downloadStatus, type, percentage, url, isDownloadingNum, downloadType, duration) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", \
                                                     obj.itemId, obj.imageUrl, obj.name, obj.fileName, obj.downloadStatus, obj.type, obj.percentage, obj.url, obj.isDownloadingNum, obj.downloadType, obj.duration];
        } else if ([dbObject isKindOfClass:SubdownloadItem.class]) {
            SubdownloadItem *obj = (SubdownloadItem *)dbObject;
            [db executeUpdate:@"insert into SubdownloadItem(itemId, subitemId, imageUrl, name, fileName, downloadStatus, type, percentage, url, isDownloadingNum, downloadType, duration) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", \
                                                        obj.itemId, obj.subitemId, obj.imageUrl, obj.name, obj.fileName, obj.downloadStatus, obj.type, obj.percentage, obj.url, obj.isDownloadingNum, obj.downloadType, obj.duration];
        } else if ([dbObject isKindOfClass:SegmentUrl.class]) {
            SegmentUrl *obj = (SegmentUrl *)dbObject;
            [db executeUpdate:@"insert into SegmentUrl(itemId, subitemId, url, seqNum) values (?, ?, ?, ?)", \
                                                   obj.itemId, obj.subitemId, obj.url, obj.seqNum];
        }
    }];
    [queue close];
}

+(void)update:(DatabaseObject *)dbObject
{
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:DATABASE_PATH];
    {
        [queue inDatabase:^(FMDatabase *db) {
            if ([dbObject isKindOfClass:DownloadItem.class]) {
                DownloadItem *obj = (DownloadItem *)dbObject;
                [db executeUpdate:@"update DownloadItem set imageUrl = ?, name = ?, fileName = ?, downloadStatus = ?, type = ?, percentage = ?, url = ?, isDownloadingNum = ?, downloadType = ?, duration = ?) \
                                     where itemId = ?", obj.imageUrl, obj.name, obj.fileName, obj.downloadStatus, obj.type, obj.percentage, obj.url, obj.isDownloadingNum, obj.downloadType, obj.duration, \
                                       obj.itemId];
            } else if ([dbObject isKindOfClass:SubdownloadItem.class]) {
                SubdownloadItem *obj = (SubdownloadItem *)dbObject;
                [db executeUpdate:@"update SubdownloadItem set imageUrl = ?, name = ?, fileName = ?, downloadStatus = ?, type = ?, percentage = ?, url = ?, isDownloadingNum = ?, downloadType = ?, duration = ?) \
                      where itemId = ? and subitemId = ?", obj.imageUrl, obj.name, obj.fileName, obj.downloadStatus, obj.type, obj.percentage, obj.url, obj.isDownloadingNum, obj.downloadType, obj.duration, \
                        obj.itemId, obj.subitemId];
            } else if ([dbObject isKindOfClass:SegmentUrl.class]) {
                SegmentUrl *obj = (SegmentUrl *)dbObject;
                [db executeUpdate:@"update SegmentUrl set url = ?, seqNum = ? where itemId = ? and subitemId = ? ", \
                                                      obj.url, obj.seqNum, obj.itemId, obj.subitemId];
            }
        }];
    }
    [queue close];
}
+ (NSInteger)count:(Class)dbObjectClass
{
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"Could not open db in DatabaseManager!");
        return 0;
    }
    NSString *tableName = [NSString stringWithFormat:@"%@", dbObjectClass];
    FMResultSet *rs = [db executeQuery: [NSString stringWithFormat:@"select count(*) totalCount from %@", tableName]];
    int totalCount = 0;
    if ([rs next]) {
        totalCount = [rs intForColumn:@"totalCount"];
    }
    [rs close];
    [db close];

    return totalCount;    
}
+ (NSInteger)countByCriteria:(Class)dbObjectClass queryString:(NSString *)queryString
{
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"Could not open db in DatabaseManager!");
        return 0;
    }
    NSString *tableName = [NSString stringWithFormat:@"%@", dbObjectClass];
    FMResultSet *rs = [db executeQuery: [NSString stringWithFormat:@"select count(*) totalCount from %@ %@", tableName, queryString]];
    int totalCount = 0;
    if  ([rs next]) {
        totalCount = [rs intForColumn:@"totalCount"];
    }
    [rs close];
    [db close];
    return totalCount;
}
+(void)test{
    [NSThread  detachNewThreadSelector:@selector(test) toTarget:self withObject:nil];
    [NSThread  detachNewThreadSelector:@selector(test1) toTarget:self withObject:nil];

}
-(void)test{
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if ([db open]) {
        for (int i = 0; i<100; i++) {
            DownloadItem *item = [[DownloadItem alloc] init];
            item.itemId = @"123";
            item.percentage = i;
            [DatabaseManager update:item];
        }
    }
}

-(void)test1{
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if ([db open]) {
        for (int i = 0; i<100; i++) {
            DownloadItem *item = [[DownloadItem alloc] init];
            item.itemId = @"234";
            item.percentage = i;
            [DatabaseManager update:item];
        }
    }
}
@end
