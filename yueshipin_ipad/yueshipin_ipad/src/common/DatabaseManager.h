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

- (id)initWithPath:(NSString*)aPath;

- (NSArray *)findByCriteria:(Class)dbObjectClass queryString:(NSString *)queryString;
- (DatabaseObject *)findFirstByCriteria:(Class *)dbObjectClass queryString:(NSString *)queryString;
- (NSArray *)allObjects:(Class )dbObjectClass;
- (double)performSQLAggregation: (NSString *)query;
- (void)deleteObject:(DatabaseObject *)dbObject;
- (void)save:(DatabaseObject *)dbObject;
- (NSInteger)count:(Class*)dbObjectClass;
- (NSInteger)countByCriteria:(Class *)dbObjectClass queryString:(NSString *)queryString;
@end
