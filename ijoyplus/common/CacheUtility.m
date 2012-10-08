//
//  PAPCache.m
//  Anypic
//
//  Created by Héctor Ramos on 5/31/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import "CacheUtility.h"
#import "CMConstants.h"
#import "WBEngine.h"

@interface CacheUtility()

@property (nonatomic, strong) NSCache *cache;

@end

@implementation CacheUtility
@synthesize cache;

#pragma mark - Initialization

+ (id)sharedCache {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
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
//    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kPAPUserDefaultsCacheSinaFriendsKey];
//    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)setSinaFriends:(NSArray *)friends {
    NSString *key = kPAPUserDefaultsCacheSinaFriendsKey;
    [self.cache setObject:friends forKey:key];
//    [[NSUserDefaults standardUserDefaults] setObject:friends forKey:key];
//    [[NSUserDefaults standardUserDefaults] synchronize];
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

- (void)setSinaWeiboEngineer:(WBEngine *)engineer{
    NSString *key = @"sinaWeiboEngineer";
    [self.cache setObject:engineer forKey:key];
    [[NSUserDefaults standardUserDefaults] setObject:engineer forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (WBEngine *)getSinaWeiboEngineer {
    NSString *key = @"sinaWeiboEngineer";
    if ([self.cache objectForKey:key]) {
        return [self.cache objectForKey:key];
    }
    WBEngine *engineer = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (engineer) {
        [self.cache setObject:engineer forKey:key];
    }
    
    return engineer;
}
@end
