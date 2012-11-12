//
//  PAPCache.m
//  Anypic
//
//  Created by Héctor Ramos on 5/31/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import "CacheUtility.h"
#import "CMConstants.h"

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
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSinaUID];
    [[NSUserDefaults standardUserDefaults] synchronize];
//    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
//    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
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
   if ([self.cache objectForKey:cacheKey]) {
        return [self.cache objectForKey:cacheKey];
    }
    id result = [[NSUserDefaults standardUserDefaults] objectForKey:cacheKey];
    if (result) {
        [self.cache setObject:result forKey:cacheKey];
    }
    return result;
}
- (void)putInCache:(NSString *)cacheKey result:(id)result{
    [self.cache setObject:result forKey:cacheKey];
    [[NSUserDefaults standardUserDefaults] setObject:result forKey:cacheKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
