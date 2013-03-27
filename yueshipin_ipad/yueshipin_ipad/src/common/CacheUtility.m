//
//  PAPCache.m
//  Anypic
//
//  Created by Héctor Ramos on 5/31/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import "CacheUtility.h"
#import "CMConstants.h"
#import "NSMutableArray+QueueAdditions.h"

@interface CacheUtility()

@property (nonatomic, strong) NSCache *cache;

@end

@implementation CacheUtility
@synthesize cache;

#pragma mark - Initialization

+ (id)sharedCache {
    static dispatch_once_t pred = 0;
    __strong static CacheUtility *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init {
    self = [super init];
    if (self) {
        self.cache = [[NSCache alloc] init];
    }
    return self;
}

#pragma mark - PAPCache

- (void)clear {
    [self.cache removeAllObjects];
}
- (void)setSinaFriends:(NSArray *)friends {
    NSString *key = kPAPUserDefaultsCacheSinaFriendsKey;
    [self.cache setObject:friends forKey:key];
    [[NSUserDefaults standardUserDefaults] setObject:friends forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray *)sinaFriends {
    NSString *key = kPAPUserDefaultsCacheSinaFriendsKey;
    if ([self.cache objectForKey:key]) {
        return [self.cache objectForKey:key];
    }
    NSArray *friends = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (friends) {
        [self.cache setObject:friends forKey:key];
    }
    return friends;
}

- (void)setSinaUID:(NSString *)uid {
    NSString *key = kSinaUID;
    [self.cache setObject:uid forKey:key];
    [[NSUserDefaults standardUserDefaults] setObject:uid forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)sinaUID {
    NSString *key = kSinaUID;
    if ([self.cache objectForKey:key]) {
        return [self.cache objectForKey:key];
    }
    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (uid) {
        [self.cache setObject:uid forKey:key];
    }
    return uid;
}

- (id)loadFromCache:(NSString *)cacheKey{   
    NSArray *cacheArray = [self.cache objectForKey:CACHE_QUEUE];
    if (cacheArray == nil) {
        cacheArray = [[NSUserDefaults standardUserDefaults] objectForKey:CACHE_QUEUE];
        if (cacheArray) {
            [self.cache setObject:cacheArray forKey:CACHE_QUEUE];
        }
    }
    if (cacheArray) {
        for (NSDictionary *cacheEntry in cacheArray) {
            NSEnumerator *it = [cacheEntry keyEnumerator];
            NSString *key = [it nextObject];
            if ([cacheKey isEqualToString:key]) {
                return [cacheEntry objectForKey:key];
            }
        }
        return nil;
    } else {
        return nil;
    }
}

- (void)putInCache:(NSString *)cacheKey result:(id)result{
    NSArray *cacheArray = [[NSUserDefaults standardUserDefaults] arrayForKey:CACHE_QUEUE];
    if (cacheArray == nil) {
        cacheArray = [[NSMutableArray alloc]initWithCapacity:100];
        for (NSString *key in [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]) {
            if (([key hasPrefix:@"movie"] || [key hasPrefix:@"drama"] || [key hasPrefix:@"show"] || [key hasPrefix:@"top_detail_list"]) && ![key hasPrefix:@"show_"]) {
                NSLog(@"removed key = %@", key);
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
            }
        }
    }
    NSMutableArray *cacheQueue = [[NSMutableArray alloc]initWithArray:cacheArray];
    for (NSDictionary *tempObj in cacheQueue) {
        id tempValue = [tempObj objectForKey:cacheKey];
        if (tempValue) {
            [cacheQueue removeObject:tempObj];
            break;
        }
    }    
    NSDictionary *cacheObject = [NSDictionary dictionaryWithObjectsAndKeys:result, cacheKey, nil];
    [cacheQueue enqueue:cacheObject];
    if (cacheQueue.count > 150) {
        for (int i = 0; i < cacheQueue.count - 150; i++) {
            [cacheQueue dequeue];
        }
    }
    NSLog(@"cache num = %i", cacheQueue.count);
    [self.cache setObject:cacheQueue forKey:CACHE_QUEUE];
    [[NSUserDefaults standardUserDefaults] setObject:cacheQueue forKey:CACHE_QUEUE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)removeObjectForKey:(NSString *)key
{
    [self.cache removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
