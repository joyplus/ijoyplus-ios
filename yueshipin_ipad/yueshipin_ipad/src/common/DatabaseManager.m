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
            tempDbObj.rowId =  [rs intForColumn:@"rowid"];
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
            tempDbObj.rowId =  [rs intForColumn:@"rowid"];
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
    FMResultSet *rs = [db executeQuery:queryString];
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
            tempDbObj.isDownloadingNum = [[rs stringForColumn:@"isDownloadingNum"] intValue];
            tempDbObj.downloadType = [rs stringForColumn:@"downloadType"];
            tempDbObj.duration = [[rs stringForColumn:@"duration"] doubleValue];
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
            tempDbObj.isDownloadingNum = [[rs stringForColumn:@"isDownloadingNum"] intValue];
            tempDbObj.downloadType = [rs stringForColumn:@"downloadType"];
            tempDbObj.duration = [[rs stringForColumn:@"duration"] doubleValue];
            tempDbObj.subitemId = [rs stringForColumn:@"subitemId"];
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
    NSString *queryString = [NSString stringWithFormat:@"SELECT * From %@",dbObjectClass];
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
            tempDbObj.isDownloadingNum = [[rs stringForColumn:@"isDownloadingNum"] intValue];
            tempDbObj.downloadType = [rs stringForColumn:@"downloadType"];
            tempDbObj.duration = [[rs stringForColumn:@"duration"] doubleValue];
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
            tempDbObj.isDownloadingNum = [[rs stringForColumn:@"isDownloadingNum"] intValue];
            tempDbObj.downloadType = [rs stringForColumn:@"downloadType"];
            tempDbObj.duration = [[rs stringForColumn:@"duration"] doubleValue];
            tempDbObj.subitemId = [rs stringForColumn:@"subitemId"];
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
        [db executeQuery:sqlString];
    }
   else if (dbObject.class == [SubdownloadItem class]) {
        NSString *subitemId = ((SubdownloadItem *)dbObject).subitemId;
        NSString *sqlString = [NSString stringWithFormat:@"delete from DownloadItem where subitemId = '%@'",subitemId];
        [db executeQuery:sqlString];
    }
   else if (dbObject.class == [SegmentUrl class]) {
        NSString *itemId = ((SegmentUrl *)dbObject).itemId;
        NSString *sqlString = [NSString stringWithFormat:@"delete from DownloadItem where itemId = '%@'",itemId];
        [db executeQuery:sqlString];
    }
    [db close];
}
+ (void)save:(NSObject *)dbObject
{
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:DATABASE_PATH];
    [queue inDatabase:^(FMDatabase *db) {
        if (dbObject.class == DownloadItem.class) {
            DownloadItem *obj = (DownloadItem *)dbObject;
            NSArray *parameterArray = [NSArray arrayWithObjects:obj.itemId, obj.imageUrl, obj.name, obj.fileName, obj.downloadStatus, [NSNumber numberWithInt:obj.type], [NSNumber numberWithInt:obj.percentage], obj.url, [NSNumber numberWithInt:obj.isDownloadingNum], obj.downloadType, [NSNumber numberWithDouble:obj.duration], nil];
            [db executeUpdate:@"insert into DownloadItem(itemId, imageUrl, name, fileName, downloadStatus, type, percentage, url, isDownloadingNum, downloadType, duration) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" withArgumentsInArray:parameterArray];
        } else if (dbObject.class == SubdownloadItem.class) {
            SubdownloadItem *obj = (SubdownloadItem *)dbObject;
            NSArray *parameterArray = [NSArray arrayWithObjects:obj.itemId, obj.subitemId, obj.imageUrl, obj.name, obj.fileName, obj.downloadStatus, [NSNumber numberWithInt:obj.type], [NSNumber numberWithInt:obj.percentage], obj.url, [NSNumber numberWithInt:obj.isDownloadingNum], obj.downloadType, [NSNumber numberWithDouble:obj.duration], nil];
            [db executeUpdate:@"insert into SubdownloadItem(itemId, subitemId, imageUrl, name, fileName, downloadStatus, type, percentage, url, isDownloadingNum, downloadType, duration) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" withArgumentsInArray:parameterArray];
        } else if (dbObject.class == SegmentUrl.class) {
            SegmentUrl *obj = (SegmentUrl *)dbObject;
            NSArray *parameterArray = [NSArray arrayWithObjects:obj.itemId, obj.subitemId, obj.url, [NSNumber numberWithInt:obj.seqNum], nil];
            [db executeUpdate:@"insert into SegmentUrl(itemId, subitemId, url, seqNum) values (?, ?, ?, ?)"  withArgumentsInArray:parameterArray];
        }
    }];
    [queue close];
}

+ (void)saveInBatch:(NSArray *)dbObjectArray
{
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:DATABASE_PATH];
    [queue inDatabase:^(FMDatabase *db) {
        for (NSObject *dbObject in dbObjectArray) {            
            if (dbObject.class == DownloadItem.class) {
                DownloadItem *obj = (DownloadItem *)dbObject;
                NSArray *parameterArray = [NSArray arrayWithObjects:obj.itemId, obj.imageUrl, obj.name, obj.fileName, obj.downloadStatus, [NSNumber numberWithInt:obj.type], [NSNumber numberWithInt:obj.percentage], obj.url, [NSNumber numberWithInt:obj.isDownloadingNum], obj.downloadType, [NSNumber numberWithDouble:obj.duration], nil];
                [db executeUpdate:@"insert into DownloadItem(itemId, imageUrl, name, fileName, downloadStatus, type, percentage, url, isDownloadingNum, downloadType, duration) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" withArgumentsInArray:parameterArray];
            } else if (dbObject.class == SubdownloadItem.class) {
                SubdownloadItem *obj = (SubdownloadItem *)dbObject;
                NSArray *parameterArray = [NSArray arrayWithObjects:obj.itemId, obj.subitemId, obj.imageUrl, obj.name, obj.fileName, obj.downloadStatus, [NSNumber numberWithInt:obj.type], [NSNumber numberWithInt:obj.percentage], obj.url, [NSNumber numberWithInt:obj.isDownloadingNum], obj.downloadType, [NSNumber numberWithDouble:obj.duration], nil];
                [db executeUpdate:@"insert into SubdownloadItem(itemId, subitemId, imageUrl, name, fileName, downloadStatus, type, percentage, url, isDownloadingNum, downloadType, duration) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" withArgumentsInArray:parameterArray];
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
+(void)test{
//    [NSThread  detachNewThreadSelector:@selector(test) toTarget:self withObject:nil];
//    [NSThread  detachNewThreadSelector:@selector(test1) toTarget:self withObject:nil];
    for (int i= 0; i< 10; i++) {
        NSThread *test = [[NSThread alloc] initWithTarget:[[DatabaseManager alloc] init] selector:@selector(testSegmentUrl:) object:[NSNumber numberWithInt:i] ];
        [test start];
        
//        NSThread *test1 = [[NSThread alloc] initWithTarget:[[DatabaseManager alloc] init] selector:@selector(test1) object:nil];
//        [test1 start];
    }
}
-(void)testSegmentUrl:(NSNumber *)num{
    // FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    // if ([db open]) {
    for (int i = 0; i<100; i++) {
        SegmentUrl *item = [[SegmentUrl alloc] init];
        item.itemId = [NSString stringWithFormat:@"%i", 100+[num intValue]];
        item.subitemId = [NSString stringWithFormat:@"%i", [num intValue]];
        item.seqNum = i;
        
        [DatabaseManager update:item];
    }
    // }
}
-(void)test{
   // FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
   // if ([db open]) {
        for (int i = 0; i<100; i++) {
            DownloadItem *item = [[DownloadItem alloc] init];
            item.itemId = @"123";
            item.imageUrl = @"testImageUrl1";
            item.name = @"testName1";
            item.fileName = @"testFileName1";
            item.downloadStatus = @"testDownloadStatus";
            item.type = 1;
            item.percentage = i;
            item.url = @"testurl";
            item.isDownloadingNum = 25;
            item.downloadType = @"mp4";
            item.duration = 339.0;

            [DatabaseManager update:item];
        }
   // }
}

-(void)test1{
   // FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    //if ([db open]) {
        for (int i = 0; i<100; i++) {
            DownloadItem *item = [[DownloadItem alloc] init];
            item.itemId = @"234";
            item.imageUrl = @"testImageUrl1";
            item.name = @"testName1";
            item.fileName = @"testFileName1";
            item.downloadStatus = @"testDownloadStatus";
            item.type = 1;
            item.percentage = i;
            item.url = @"testurl";
            item.isDownloadingNum = 25;
            item.downloadType = @"mp4";
            item.duration = 339.0;
            [DatabaseManager update:item];
        }
    //}
}

- (void)stevenTest
{
    DownloadItem *item = [[DownloadItem alloc]init];
    item.itemId = @"testItem1";
    item.imageUrl = @"testImageUrl1";
    item.name = @"testName1";
    item.fileName = @"testFileName1";
    item.downloadStatus = @"testDownloadStatus";
    item.type = 1;
    item.percentage = 25;
    item.url = @"testurl";
    item.isDownloadingNum = 25;
    item.downloadType = @"mp4";
    item.duration = 339.0;
    [DatabaseManager save:item];
    
    item.name = @"testItemUpdated";
    [DatabaseManager update:item];
    
    SubdownloadItem *item1 = [[SubdownloadItem alloc]init];
    item1.itemId = @"testItem1";
    item1.subitemId = @"subitemId1";
    item1.imageUrl = @"testImageUrl1";
    item1.name = @"testName1";
    item1.fileName = @"testFileName1";
    item1.downloadStatus = @"testDownloadStatus";
    item1.type = 1;
    item1.percentage = 25;
    item1.url = @"testurl";
    item1.isDownloadingNum = 25;
    item1.downloadType = @"mp4";
    item1.duration = 339.0;
    [DatabaseManager save:item1];
    
    item1.name = @"testSubitemUpdated";
    [DatabaseManager update:item1];
    
    SegmentUrl *item2 = [[SegmentUrl alloc]init];
    item2.itemId = @"testItem1";
    item2.url = @"testurl";
    item2.subitemId = @"testSubitme1";
    item2.seqNum = 3;
    [DatabaseManager save:item2];
    
    item2.url = @"testSegmentUpdated";
    [DatabaseManager update:item2];
    
    
    SegmentUrl *item3 = [[SegmentUrl alloc]init];
    item3.itemId = @"testItem1batch";
    item3.url = @"testurl";
    item3.subitemId = @"testSubitme1";
    item3.seqNum = 3;
    NSArray *temp = [NSArray arrayWithObjects:item2, item3, nil];
    [DatabaseManager saveInBatch:temp];
    
    int num = [DatabaseManager count:DownloadItem.class];
    int num1 = [DatabaseManager countByCriteria:DownloadItem.class queryString:@"where itemId = 'testItem1'"];
    NSLog(@"ok");
}
@end
