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
    NSDictionary *entry = [NSDictionary dictionaryWithObjectsAndKeys:attribute, @"attribute", key, @"key", nil];
    [self performSelectorInBackground:@selector(save:) withObject:entry];
}

- (void)save:(NSDictionary *)entry
{
    NSString *key = [entry objectForKey:@"key"];
    [[NSUserDefaults standardUserDefaults] setObject:[entry objectForKey:@"attribute"] forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if ([key isEqualToString:TURN_ON_GRAVITY]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TURN_ON_GRAVITY object:nil];
    }
    
}

- (NSObject *)attributeForKey:(NSString *)key {
    NSObject *object = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    return object;
}

- (void)removeObjectForKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)clear{

}
@end
