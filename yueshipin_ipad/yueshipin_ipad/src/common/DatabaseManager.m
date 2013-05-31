//
//  DatabaseManager.m
//  yueshipin
//
//  Created by joyplus1 on 13-4-12.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseManager.h"
#import "FMDatabaseQueue.h"
#import "FMDatabase.h"
#import "DownloadItem.h"
#import "SubdownloadItem.h"
#import "SegmentUrl.h"
#define DocumentsDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]
#define DATABASE_PATH [DocumentsDirectory stringByAppendingPathComponent:@"yueshipin.db"]
#define OLD_DATABASE_PATH [DocumentsDirectory stringByAppendingPathComponent:@"yueshipin.sqlite3"]
@implementation DatabaseManager

+ (void)transferFinishedDownloadFiles
{
    NSFileManager *fileManager = [NSFileManager new];
    if ([fileManager fileExistsAtPath:OLD_DATABASE_PATH]) {
        FMDatabase *db = [FMDatabase databaseWithPath:OLD_DATABASE_PATH];
        if (![db open]) {
            NSLog(@"No old database!");
            return;
        }
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * From subdownload_item"]];
        NSMutableArray *subdownloadArray = [[NSMutableArray alloc]initWithCapacity:5];
        while ([rs next]) {
            SubdownloadItem *tempDbObj = [[SubdownloadItem alloc]init];
            tempDbObj.itemId =  [rs stringForColumn:@"item_id"];
            tempDbObj.name = [rs stringForColumn:@"name"];
            tempDbObj.imageUrl = [rs stringForColumn:@"image_url"];
            tempDbObj.fileName = [rs stringForColumn:@"file_name"];
            tempDbObj.downloadStatus = [rs stringForColumn:@"download_status"];
            tempDbObj.type = [[rs stringForColumn:@"type"] intValue];
            tempDbObj.percentage = [[rs stringForColumn:@"percentage"] intValue];
            tempDbObj.url = [rs stringForColumn:@"url"];
            tempDbObj.isDownloadingNum = [[rs stringForColumn:@"is_downloading_num"] intValue];
            tempDbObj.downloadType = [rs stringForColumn:@"download_type"];
            tempDbObj.duration = [[rs stringForColumn:@"duration"] doubleValue];
            tempDbObj.subitemId = [rs stringForColumn:@"subitem_id"];
            tempDbObj.mp4SourceNum = [[rs stringForColumn:@"mp4SourceNum"] intValue];
            [subdownloadArray addObject:tempDbObj];
        }
        [rs close];
        
        NSMutableArray *downloadArray = [[NSMutableArray alloc]initWithCapacity:5];
        rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * From download_item"]];
        while ([rs next]) {
            DownloadItem *tempDbObj = [[DownloadItem alloc]init];
            tempDbObj.itemId =  [rs stringForColumn:@"item_id"];
            tempDbObj.name = [rs stringForColumn:@"name"];
            tempDbObj.imageUrl = [rs stringForColumn:@"image_url"];
            tempDbObj.fileName = [rs stringForColumn:@"file_name"];
            tempDbObj.downloadStatus = [rs stringForColumn:@"download_status"];
            tempDbObj.type = [[rs stringForColumn:@"type"] intValue];
            tempDbObj.percentage = [[rs stringForColumn:@"percentage"] intValue];
            tempDbObj.url = [rs stringForColumn:@"url"];
            tempDbObj.isDownloadingNum = [[rs stringForColumn:@"is_downloading_num"] intValue];
            tempDbObj.downloadType = [rs stringForColumn:@"download_type"];
            tempDbObj.duration = [[rs stringForColumn:@"duration"] doubleValue];
            tempDbObj.mp4SourceNum = [[rs stringForColumn:@"mp4SourceNum"] intValue];
            [downloadArray addObject:tempDbObj];
        }
        [rs close];
        [db close];
        
        for (DownloadItem *item in downloadArray) {
            if (item.type == 1 && (item.percentage == 100 || [item.downloadStatus isEqualToString:@"done"] || [item.downloadStatus isEqualToString:@"finish"])) {
                [self save:item];
            } else {
                if ([item.downloadType isEqualToString:@"m3u8"]) {
                    NSString *m3u8FilePath = [NSString stringWithFormat:@"%@/%@", DocumentsDirectory, item.itemId];
                    if ([fileManager fileExistsAtPath:m3u8FilePath]) {
                        [fileManager removeItemAtPath:m3u8FilePath error:NULL];
                    }
                }
            }
        }
        for (SubdownloadItem *subdownloadItem in subdownloadArray) {
            if (subdownloadItem.percentage == 100 || [subdownloadItem.downloadStatus isEqualToString:@"done"] || [subdownloadItem.downloadStatus isEqualToString:@"finish"]) {
                for (DownloadItem *item in downloadArray) {
                    if ([item.itemId isEqualToString:subdownloadItem.itemId]) {
                        int num = [self countByCriteria:DownloadItem.class queryString: [NSString stringWithFormat:@"where itemId = '%@'", item.itemId]];
                        if (num == 0) {
                            [self save:item];
                        }
                        [self save:subdownloadItem];
                        break;
                    }
                }
            } else {
                if ([subdownloadItem.downloadType isEqualToString:@"m3u8"]) {
                    NSString *m3u8FilePath = [NSString stringWithFormat:@"%@/%@/%@", DocumentsDirectory, subdownloadItem.itemId, subdownloadItem.subitemId];
                    if ([fileManager fileExistsAtPath:m3u8FilePath]) {
                        [fileManager removeItemAtPath:m3u8FilePath error:NULL];
                    }
                }
            }
        }
        
        NSArray *contents = [fileManager contentsOfDirectoryAtPath:DocumentsDirectory error:NULL];
        NSEnumerator *e = [contents objectEnumerator];
        NSString *filename;
        while ((filename = [e nextObject])) {
            if ([filename hasSuffix:@"TEMP"]) {
                [fileManager removeItemAtPath:[DocumentsDirectory stringByAppendingPathComponent:filename] error:NULL];
            }
        }
        
        [fileManager removeItemAtPath:OLD_DATABASE_PATH error:NULL];
    }
    
}

+ (void)initDatabase
{
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"Could not open db in DatabaseManager!");
    }
    // Create tables
    [db executeUpdate:@"create table if not exists DownloadItem (itemId text PRIMARY KEY, imageUrl text, name text, fileName text, downloadStatus text, type integer, percentage integer, url text, urlArray text, isDownloadingNum integer, downloadType text, duration double, mp4SourceNum integer)"];
    [db executeUpdate:@"create table if not exists SubdownloadItem (itemId text, subitemId text, imageUrl text, name text, fileName text, downloadStatus text, type integer, percentage integer, url text, urlArray text, isDownloadingNum integer, downloadType text, duration double, mp4SourceNum integer)"];
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
    FMResultSet *rs = [db executeQuery: [NSString stringWithFormat:@"SELECT rowid, * From %@ %@",dbObjectClass, queryString]];
    NSMutableArray *resultArray = [[NSMutableArray alloc]initWithCapacity:5];
    while ([rs next]) {
        if (dbObjectClass == DownloadItem.class) {
            DownloadItem *tempDbObj = [[DownloadItem alloc]init];
            tempDbObj.rowId =  [rs intForColumn:@"rowid"];
            tempDbObj.itemId =  [rs stringForColumn:@"itemId"];
            tempDbObj.name = [rs stringForColumn:@"name"];
            tempDbObj.imageUrl = [rs stringForColumn:@"imageUrl"];
            tempDbObj.fileName = [rs stringForColumn:@"fileName"];
            tempDbObj.downloadStatus = [rs stringForColumn:@"downloadStatus"];
            tempDbObj.type = [[rs stringForColumn:@"type"] intValue];
            tempDbObj.percentage = [[rs stringForColumn:@"percentage"] intValue];
            tempDbObj.url = [rs stringForColumn:@"url"];
            NSString *urls = [rs stringForColumn:@"urlArray"];
            tempDbObj.urlArray = [urls componentsSeparatedByString:@"{array}"];
            tempDbObj.isDownloadingNum = [[rs stringForColumn:@"isDownloadingNum"] intValue];
            tempDbObj.downloadType = [rs stringForColumn:@"downloadType"];
            tempDbObj.duration = [[rs stringForColumn:@"duration"] doubleValue];
            tempDbObj.mp4SourceNum = [[rs stringForColumn:@"mp4SourceNum"] intValue];
            [resultArray addObject:tempDbObj];
            
        } else if (dbObjectClass == SubdownloadItem.class) {
            SubdownloadItem *tempDbObj = [[SubdownloadItem alloc]init];
            tempDbObj.rowId =  [rs intForColumn:@"rowid"];
            tempDbObj.itemId =  [rs stringForColumn:@"itemId"];
            tempDbObj.name = [rs stringForColumn:@"name"];
            tempDbObj.imageUrl = [rs stringForColumn:@"imageUrl"];
            tempDbObj.fileName = [rs stringForColumn:@"fileName"];
            tempDbObj.downloadStatus = [rs stringForColumn:@"downloadStatus"];
            tempDbObj.type = [[rs stringForColumn:@"type"] intValue];
            tempDbObj.percentage = [[rs stringForColumn:@"percentage"] intValue];
            tempDbObj.url = [rs stringForColumn:@"url"];
            NSString *urls = [rs stringForColumn:@"urlArray"];
            tempDbObj.urlArray = [urls componentsSeparatedByString:@"{array}"];
            tempDbObj.isDownloadingNum = [[rs stringForColumn:@"isDownloadingNum"] intValue];
            tempDbObj.downloadType = [rs stringForColumn:@"downloadType"];
            tempDbObj.duration = [[rs stringForColumn:@"duration"] doubleValue];
            tempDbObj.subitemId = [rs stringForColumn:@"subitemId"];
            tempDbObj.mp4SourceNum = [[rs stringForColumn:@"mp4SourceNum"] intValue];
            [resultArray addObject:tempDbObj];
            
        } else if (dbObjectClass == SegmentUrl.class) {
            
            SegmentUrl *tempDbObj = [[SegmentUrl alloc]init];
            tempDbObj.rowId =  [rs intForColumn:@"rowid"];
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
    FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT rowid, * From %@ %@",dbObjectClass, queryString]];
    if ([rs next]) {
        if (dbObjectClass == DownloadItem.class) {
            DownloadItem *tempDbObj = [[DownloadItem alloc]init];
            tempDbObj.rowId =  [rs intForColumn:@"rowid"];
            tempDbObj.itemId =  [rs stringForColumn:@"itemId"];
            tempDbObj.name = [rs stringForColumn:@"name"];
            tempDbObj.imageUrl = [rs stringForColumn:@"imageUrl"];
            tempDbObj.fileName = [rs stringForColumn:@"fileName"];
            tempDbObj.downloadStatus = [rs stringForColumn:@"downloadStatus"];
            tempDbObj.type = [[rs stringForColumn:@"type"] intValue];
            tempDbObj.percentage = [[rs stringForColumn:@"percentage"] intValue];
            tempDbObj.url = [rs stringForColumn:@"url"];
            NSString *urls = [rs stringForColumn:@"urlArray"];
            tempDbObj.urlArray = [urls componentsSeparatedByString:@"{array}"];
            tempDbObj.isDownloadingNum = [[rs stringForColumn:@"isDownloadingNum"] intValue];
            tempDbObj.downloadType = [rs stringForColumn:@"downloadType"];
            tempDbObj.duration = [[rs stringForColumn:@"duration"] doubleValue];
            tempDbObj.mp4SourceNum = [[rs stringForColumn:@"mp4SourceNum"] intValue];
            [rs close];
            [db close];
            
            return tempDbObj;
            
        } else if (dbObjectClass == SubdownloadItem.class) {
            SubdownloadItem *tempDbObj = [[SubdownloadItem alloc]init];
            tempDbObj.rowId =  [rs intForColumn:@"rowid"];
            tempDbObj.itemId =  [rs stringForColumn:@"itemId"];
            tempDbObj.name = [rs stringForColumn:@"name"];
            tempDbObj.imageUrl = [rs stringForColumn:@"imageUrl"];
            tempDbObj.fileName = [rs stringForColumn:@"fileName"];
            tempDbObj.downloadStatus = [rs stringForColumn:@"downloadStatus"];
            tempDbObj.type = [[rs stringForColumn:@"type"] intValue];
            tempDbObj.percentage = [[rs stringForColumn:@"percentage"] intValue];
            tempDbObj.url = [rs stringForColumn:@"url"];
            NSString *urls = [rs stringForColumn:@"urlArray"];
            tempDbObj.urlArray = [urls componentsSeparatedByString:@"{array}"];
            tempDbObj.isDownloadingNum = [[rs stringForColumn:@"isDownloadingNum"] intValue];
            tempDbObj.downloadType = [rs stringForColumn:@"downloadType"];
            tempDbObj.duration = [[rs stringForColumn:@"duration"] doubleValue];
            tempDbObj.subitemId = [rs stringForColumn:@"subitemId"];
            tempDbObj.mp4SourceNum = [[rs stringForColumn:@"mp4SourceNum"] intValue];
            [rs close];
            [db close];
            
            return tempDbObj;
            
        } else if (dbObjectClass == SegmentUrl.class) {
            
            SegmentUrl *tempDbObj = [[SegmentUrl alloc]init];
            tempDbObj.rowId =  [rs intForColumn:@"rowid"];
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
    NSString *queryString = [NSString stringWithFormat:@"SELECT rowid, * From %@",dbObjectClass];
    FMResultSet *rs = [db executeQuery:queryString];
    NSMutableArray *resultArray = [[NSMutableArray alloc]initWithCapacity:5];
    while ([rs next]) {
        if (dbObjectClass == DownloadItem.class) {
            DownloadItem *tempDbObj = [[DownloadItem alloc]init];
            tempDbObj.rowId =  [rs intForColumn:@"rowid"];
            tempDbObj.itemId =  [rs stringForColumn:@"itemId"];
            tempDbObj.name = [rs stringForColumn:@"name"];
            tempDbObj.imageUrl = [rs stringForColumn:@"imageUrl"];
            tempDbObj.fileName = [rs stringForColumn:@"fileName"];
            tempDbObj.downloadStatus = [rs stringForColumn:@"downloadStatus"];
            tempDbObj.type = [[rs stringForColumn:@"type"] intValue];
            tempDbObj.percentage = [[rs stringForColumn:@"percentage"] intValue];
            tempDbObj.url = [rs stringForColumn:@"url"];
            NSString *urls = [rs stringForColumn:@"urlArray"];
            tempDbObj.urlArray = [urls componentsSeparatedByString:@"{array}"];
            tempDbObj.isDownloadingNum = [[rs stringForColumn:@"isDownloadingNum"] intValue];
            tempDbObj.downloadType = [rs stringForColumn:@"downloadType"];
            tempDbObj.duration = [[rs stringForColumn:@"duration"] doubleValue];
            tempDbObj.mp4SourceNum = [[rs stringForColumn:@"mp4SourceNum"] intValue];
            [resultArray addObject:tempDbObj];
            
        } else if (dbObjectClass == SubdownloadItem.class) {
            SubdownloadItem *tempDbObj = [[SubdownloadItem alloc]init];
            tempDbObj.rowId =  [rs intForColumn:@"rowid"];
            tempDbObj.itemId =  [rs stringForColumn:@"itemId"];
            tempDbObj.name = [rs stringForColumn:@"name"];
            tempDbObj.imageUrl = [rs stringForColumn:@"imageUrl"];
            tempDbObj.fileName = [rs stringForColumn:@"fileName"];
            tempDbObj.downloadStatus = [rs stringForColumn:@"downloadStatus"];
            tempDbObj.type = [[rs stringForColumn:@"type"] intValue];
            tempDbObj.percentage = [[rs stringForColumn:@"percentage"] intValue];
            tempDbObj.url = [rs stringForColumn:@"url"];
            NSString *urls = [rs stringForColumn:@"urlArray"];
            tempDbObj.urlArray = [urls componentsSeparatedByString:@"{array}"];
            tempDbObj.isDownloadingNum = [[rs stringForColumn:@"isDownloadingNum"] intValue];
            tempDbObj.downloadType = [rs stringForColumn:@"downloadType"];
            tempDbObj.duration = [[rs stringForColumn:@"duration"] doubleValue];
            tempDbObj.subitemId = [rs stringForColumn:@"subitemId"];
            tempDbObj.mp4SourceNum = [[rs stringForColumn:@"mp4SourceNum"] intValue];
            [resultArray addObject:tempDbObj];
        } else if (dbObjectClass == SegmentUrl.class) {
            
            SegmentUrl *tempDbObj = [[SegmentUrl alloc]init];
            tempDbObj.rowId =  [rs intForColumn:@"rowid"];
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

+ (void)deleteObject:(NSObject *)dbObject
{
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"Could not open db in DatabaseManager!");
        return;
    }
    if ( dbObject.class == [DownloadItem class]) {
        NSString *itemId = ((DownloadItem *)dbObject).itemId;
        NSString *sqlString = [NSString stringWithFormat:@"delete from DownloadItem where itemId = '%@'",itemId];
        [db executeUpdate:sqlString];
    }
    else if (dbObject.class == [SubdownloadItem class]) {
        NSString *itemId = ((SubdownloadItem *)dbObject).itemId;
        NSString *subitemId = ((SubdownloadItem *)dbObject).subitemId;
        NSString *sqlString = [NSString stringWithFormat:@"delete from SubdownloadItem where itemId = '%@' and subitemId = '%@'",itemId, subitemId];
        [db executeUpdate:sqlString];
    }
    else if (dbObject.class == [SegmentUrl class]) {
        NSString *itemId = ((SegmentUrl *)dbObject).itemId;
        NSString *sqlString = [NSString stringWithFormat:@"delete from SegmentUrl where itemId = '%@'",itemId];
        [db executeUpdate:sqlString];
    }
    [db close];
}
+ (void)save:(NSObject *)dbObject
{
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:DATABASE_PATH];
    [queue inDatabase:^(FMDatabase *db) {
        if (dbObject.class == DownloadItem.class) {
            DownloadItem *obj = (DownloadItem *)dbObject;
            NSArray *parameterArray = [NSArray arrayWithObjects:obj.itemId, obj.imageUrl, obj.name, obj.fileName == nil ? @"":obj.fileName, obj.downloadStatus == nil ?@"":obj.downloadStatus, [NSNumber numberWithInt:obj.type], [NSNumber numberWithInt:obj.percentage], obj.url == nil ? @"":obj.url, [self getUrls:obj.urlArray], [NSNumber numberWithInt:obj.isDownloadingNum], obj.downloadType == nil ?@"":obj.downloadType, [NSNumber numberWithDouble:obj.duration],[NSNumber numberWithInt:obj.mp4SourceNum], nil];
            [db executeUpdate:@"insert into DownloadItem(itemId, imageUrl, name, fileName, downloadStatus, type, percentage, url, urlArray, isDownloadingNum, downloadType, duration, mp4SourceNum) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" withArgumentsInArray:parameterArray];
        } else if (dbObject.class == SubdownloadItem.class) {
            SubdownloadItem *obj = (SubdownloadItem *)dbObject;
            NSArray *parameterArray = [NSArray arrayWithObjects:obj.itemId, obj.subitemId, obj.imageUrl, obj.name, obj.fileName ==nil?@"":obj.fileName, obj.downloadStatus, [NSNumber numberWithInt:obj.type], [NSNumber numberWithInt:obj.percentage], obj.url, [self getUrls:obj.urlArray], [NSNumber numberWithInt:obj.isDownloadingNum], obj.downloadType, [NSNumber numberWithDouble:obj.duration],[NSNumber numberWithInt:obj.mp4SourceNum], nil];
            [db executeUpdate:@"insert into SubdownloadItem(itemId, subitemId, imageUrl, name, fileName, downloadStatus, type, percentage, url, urlArray, isDownloadingNum, downloadType, duration, mp4SourceNum) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" withArgumentsInArray:parameterArray];
        } else if (dbObject.class == SegmentUrl.class) {
            SegmentUrl *obj = (SegmentUrl *)dbObject;
            NSArray *parameterArray = [NSArray arrayWithObjects:obj.itemId, obj.subitemId, obj.url, [NSNumber numberWithInt:obj.seqNum], nil];
            [db executeUpdate:@"insert into SegmentUrl(itemId, subitemId, url, seqNum) values (?, ?, ?, ?)"  withArgumentsInArray:parameterArray];
        }
    }];
    [queue close];
}

+ (NSString *)getUrls:(NSArray *)urlArray
{
    if (urlArray == nil || urlArray.count == 0) {
        return @"";
    }
    NSMutableString *urls = [[NSMutableString alloc]initWithCapacity:7];
    for (NSString *url in urlArray) {
        [urls appendFormat:@"%@{array}", url];
    }
    if (urls.length > 7) {
        return [urls substringToIndex:urls.length - 7];
    } else {
        return @"";
    }
}

+ (void)saveInBatch:(NSArray *)dbObjectArray
{
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:DATABASE_PATH];
    [queue inDatabase:^(FMDatabase *db) {
        for (NSObject *dbObject in dbObjectArray) {
            if (dbObject.class == DownloadItem.class) {
                DownloadItem *obj = (DownloadItem *)dbObject;
                NSArray *parameterArray = [NSArray arrayWithObjects:obj.itemId, obj.imageUrl, obj.name, obj.fileName == nil ? @"":obj.fileName, obj.downloadStatus == nil ?@"":obj.downloadStatus, [NSNumber numberWithInt:obj.type], [NSNumber numberWithInt:obj.percentage], obj.url, [self getUrls:obj.urlArray], [NSNumber numberWithInt:obj.isDownloadingNum], obj.downloadType == nil ?@"":obj.downloadType, [NSNumber numberWithDouble:obj.duration],[NSNumber numberWithInt:obj.mp4SourceNum], nil];
                [db executeUpdate:@"insert into DownloadItem(itemId, imageUrl, name, fileName, downloadStatus, type, percentage, url, urlArray, isDownloadingNum, downloadType, duration, mp4SourceNum) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" withArgumentsInArray:parameterArray];
            } else if (dbObject.class == SubdownloadItem.class) {
                SubdownloadItem *obj = (SubdownloadItem *)dbObject;
                NSArray *parameterArray = [NSArray arrayWithObjects:obj.itemId, obj.subitemId, obj.imageUrl, obj.name, obj.fileName, obj.downloadStatus, [NSNumber numberWithInt:obj.type], [NSNumber numberWithInt:obj.percentage], obj.url, [self getUrls:obj.urlArray], [NSNumber numberWithInt:obj.isDownloadingNum], obj.downloadType, [NSNumber numberWithDouble:obj.duration],[NSNumber numberWithInt:obj.mp4SourceNum], nil];
                [db executeUpdate:@"insert into SubdownloadItem(itemId, subitemId, imageUrl, name, fileName, downloadStatus, type, percentage, url, urlArray, isDownloadingNum, downloadType, duration, mp4SourceNum) values (?, ?, ?, ?, ?, ?, ?,?, ?, ?, ?, ?, ?, ?)" withArgumentsInArray:parameterArray];
            } else if (dbObject.class == SegmentUrl.class) {
                SegmentUrl *obj = (SegmentUrl *)dbObject;
                NSArray *parameterArray = [NSArray arrayWithObjects:obj.itemId, obj.subitemId, obj.url, [NSNumber numberWithInt:obj.seqNum], nil];
                [db executeUpdate:@"insert into SegmentUrl(itemId, subitemId, url, seqNum) values (?, ?, ?, ?)"  withArgumentsInArray:parameterArray];
            }
        }
    }];
    [queue close];
}

+(void)update:(NSObject *)dbObject
{
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:DATABASE_PATH];
    {
        [queue inDatabase:^(FMDatabase *db) {
            if (dbObject.class == DownloadItem.class) {
                DownloadItem *obj = (DownloadItem *)dbObject;
                NSArray *parameterArray = [NSArray arrayWithObjects:obj.imageUrl, obj.name, obj.fileName, obj.downloadStatus, [NSNumber numberWithInt:obj.type], [NSNumber numberWithInt:obj.percentage], obj.url, [NSNumber numberWithInt:obj.isDownloadingNum], obj.downloadType, [NSNumber numberWithDouble:obj.duration], obj.itemId, nil];
                BOOL b =  [db executeUpdate:@"update DownloadItem set imageUrl = ?, name = ?, fileName = ?, downloadStatus = ?, type = ?, percentage = ?, url = ?, isDownloadingNum = ?, downloadType = ?, duration = ? \
                           where itemId = ? " withArgumentsInArray:parameterArray];
                NSLog(@"%@",b? @"YES":@"NO");
            } else if (dbObject.class == SubdownloadItem.class) {
                SubdownloadItem *obj = (SubdownloadItem *)dbObject;
                NSArray *parameterArray = [NSArray arrayWithObjects:obj.imageUrl, obj.name, obj.fileName, obj.downloadStatus, [NSNumber numberWithInt:obj.type], [NSNumber numberWithInt:obj.percentage], obj.url, [NSNumber numberWithInt:obj.isDownloadingNum], obj.downloadType, [NSNumber numberWithDouble:obj.duration],  obj.itemId, obj.subitemId, nil];
                [db executeUpdate:@"update SubdownloadItem set imageUrl = ?, name = ?, fileName = ?, downloadStatus = ?, type = ?, percentage = ?, url = ?, isDownloadingNum = ?, downloadType = ?, duration = ? \
                 where itemId = ? and subitemId = ? " withArgumentsInArray:parameterArray];
            } else if (dbObject.class == SegmentUrl.class) {
                SegmentUrl *obj = (SegmentUrl *)dbObject;
                [db executeUpdate:@"update SegmentUrl set url = ?, seqNum = ? where itemId = ? and subitemId = ? ", \
                 obj.url, [NSNumber numberWithInt:obj.seqNum], obj.itemId, obj.subitemId];
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
@end
