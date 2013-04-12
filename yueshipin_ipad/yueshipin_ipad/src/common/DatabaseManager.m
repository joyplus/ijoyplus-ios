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

#define DATABASE_PATH @""

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
        } else if (dbObjectClass == DownloadItem.class) {
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
    
}

- (NSArray *)allObjects:(Class *)dbObjectClass
{
    
}
- (double)performSQLAggregation: (NSString *)query
{
    
}
- (void)deleteObject:(DatabaseObject *)dbObject
{
    
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
