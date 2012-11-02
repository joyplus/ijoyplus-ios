//
//  ContainerUtility.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-25.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "ContainerUtility.h"
#import "CMConstants.h"

@interface ContainerUtility ()

@property (nonatomic, strong) NSCache *cache;

@end

@implementation ContainerUtility
@synthesize cache;

+ (id)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static ContainerUtility *_sharedObject = nil;
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

- (void)setAttribute:(NSObject *)attribute forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:attribute forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSObject *)attributeForKey:(NSString *)key {
    NSObject *object = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    return object;
}

- (void)clear{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTencentUserLoggedIn];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserLoggedIn];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserName];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserNickName];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserId];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"search_history"];
    [[NSUserDefaults standardUserDefaults] synchronize];
//    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
//    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
//    [[NSUserDefaults standardUserDefaults] setObject:@"aaa" forKey:@"aaa"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
