//
//  ActionUtility.m
//  yueshipin
//
//  Created by joyplus1 on 13-1-6.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "ActionUtility.h"
#import "Reachability.h"
#import "AFServiceAPIClient.h"
#import "ContainerUtility.h"
#import "CMConstants.h"
#import "OpenUDID.h"
#import "ServiceConstants.h"

@implementation ActionUtility


+ (void)generateUserId:(void (^)(void))completion
{
    NSString *userId = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId];
    if(userId == nil){
        Reachability *tempHostReach = [Reachability reachabilityForInternetConnection];
        if([tempHostReach currentReachabilityStatus] != NotReachable) {
            NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:  [OpenUDID value], @"uiid", nil];
            [[AFServiceAPIClient sharedClient] postPath:kPathGenerateUIID parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
                NSString *responseCode = [result objectForKey:@"res_code"];
                if (responseCode == nil) {
                    NSString *user_id = [result objectForKey:@"user_id"];
                    NSString *nickname = [result objectForKey:@"nickname"];
                    NSString *username = [result objectForKey:@"username"];
                    [[ContainerUtility sharedInstance] setAttribute:user_id forKey:kUserId];
                    [[ContainerUtility sharedInstance] setAttribute:[NSString stringWithFormat:@"%@", nickname] forKey:kUserNickName];
                    [[ContainerUtility sharedInstance] setAttribute:username forKey:kUserName];
                    [[AFServiceAPIClient sharedClient] setDefaultHeader:@"user_id" value:user_id];
                    if(completion){
                        completion();
                    }
                }
            } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"%@", error);
            }];
        }
    } else {
        [[AFServiceAPIClient sharedClient] setDefaultHeader:@"user_id" value:userId];
    }
}

@end
