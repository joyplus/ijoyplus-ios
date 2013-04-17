//
//  AFCheckBindAPIClient.m
//  yueshipin
//
//  Created by 08 on 13-4-17.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "AFCheckBindAPIClient.h"
#import "AFJSONRequestOperation.h"
#import "EnvConstant.h"
#import "CMConstants.h"
#import "ContainerUtility.h"
@implementation AFCheckBindAPIClient
static AFCheckBindAPIClient *_sharedClient = nil;
+ (AFCheckBindAPIClient *)sharedClient
{
    
    static dispatch_once_t oncePredicate;
    NSString *appKey = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kIpadAppKey];
    [_sharedClient setDefaultHeader:@"app_key" value:appKey];
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:CHECKBINDURLSTRING]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    return self;
}


@end
