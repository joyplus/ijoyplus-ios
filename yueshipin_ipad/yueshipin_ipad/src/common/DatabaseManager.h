//
//  DatabaseManager.h
//  yueshipin
//
//  Created by joyplus1 on 13-4-12.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseObject.h"

@interface DatabaseManager : NSObject

+ (void)initDatabase;

+ (NSArray *)findByCriteria:(Class)dbObjectClass queryString:(NSString *)queryString;
+ (NSArray *)allObjects:(Class)dbObjectClass;
+ (BOOL)performSQLAggregation: (NSString *)query;
+ (NSObject *)findFirstByCriteria:(Class)dbObjectClass queryString:(NSString *)queryString;
+ (void)deleteObject:(NSObject *)dbObject;
+ (void)save:(NSObject *)dbObject;
+ (void)saveInBatch:(NSArray *)dbObjectArray;
+ (void)update:(NSObject *)dbObject;
+ (NSInteger)count:(Class)dbObjectClass;
+(NSInteger)countByCriteria:(Class)dbObjectClass queryString:(NSString *)queryString;

@end
