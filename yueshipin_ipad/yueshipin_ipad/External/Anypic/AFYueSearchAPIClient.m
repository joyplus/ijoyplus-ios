//
//  AFYueSearchAPIClient.m
//  yueshipin
//
//  Created by huokun on 13-9-5.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "AFYueSearchAPIClient.h"
#import "AFJSONRequestOperation.h"
#import "EnvConstant.h"
#import "CMConstants.h"
#import "ContainerUtility.h"

#define YUE_SEARCH_URL_STRING   (@"http://tt.showkey.tv")

@implementation AFYueSearchAPIClient

static AFYueSearchAPIClient *_sharedClient = nil;
+ (AFYueSearchAPIClient *)sharedClient
{
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:YUE_SEARCH_URL_STRING]];
        //NSString *appKey = (NSString *)[[ContainerUtility sharedInstance] attributeForKey:kIpadAppKey];
        [_sharedClient setDefaultHeader:@"app_key" value:kDefaultCheckBindAppKey];
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
