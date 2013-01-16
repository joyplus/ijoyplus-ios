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
#import <AVFoundation/AVFoundation.h>

@implementation ActionUtility


+ (void)generateUserId:(void (^)(void))completion
{
    NSString *userId = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId];
    if(userId == nil){
        Reachability *tempHostReach = [Reachability reachabilityForInternetConnection];
        if([tempHostReach currentReachabilityStatus] != NotReachable) {
            NSString *uuid = [OpenUDID value];
            NSLog(@"uuid = %@", uuid);
            NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:  uuid, @"uiid", nil];
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

+ (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time
{    
//    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];    
//    NSParameterAssert(asset); AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];    
//    assetImageGenerator.appliesPreferredTrackTransform = YES;    
//    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;    
//    CGImageRef thumbnailImageRef = NULL;    
//    CFTimeInterval thumbnailImageTime = time;    
//    NSError *thumbnailImageGenerationError = nil;    
//    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 1) actualTime:NULL error:&thumbnailImageGenerationError];
//    if (!thumbnailImageRef){
//        NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
//        return nil;
//    }
//    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] : nil;
//    return thumbnailImage;
    return  nil;
}


@end
