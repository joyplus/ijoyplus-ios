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
#import "DownloadItem.h"
#import "SubdownloadItem.h"
#import "AppDelegate.h"
#import "DatabaseManager.h"

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

+ (int)getDownloadingItemNumber
{
    NSInteger movieNum = [DatabaseManager countByCriteria:DownloadItem.class queryString: @"WHERE type = 1 and downloadStatus != 'done'"];
    NSInteger subitemNum = [DatabaseManager countByCriteria:SubdownloadItem.class queryString: @"WHERE downloadStatus != 'done'"];
    return movieNum + subitemNum;    
}

+ (int)getStartItemNumber
{
    NSInteger movieNum = [DatabaseManager countByCriteria:DownloadItem.class queryString: @"WHERE type = 1 and downloadStatus = 'start'"];
    NSInteger subitemNum = [DatabaseManager countByCriteria:SubdownloadItem.class queryString: @"WHERE downloadStatus = 'start'"];
    return movieNum + subitemNum;
}

+ (int)getReadyItemNumber
{
    NSInteger movieNum = [DatabaseManager countByCriteria:DownloadItem.class queryString: @"WHERE type = 1 and (downloadStatus = 'start' or downloadStatus = 'waiting')"];
    NSInteger subitemNum = [DatabaseManager countByCriteria:SubdownloadItem.class queryString: @"WHERE downloadStatus = 'start' or downloadStatus = 'waiting'"];
    return movieNum + subitemNum;
}

+ (DownloadItem *)getDownloadingItem
{
    DownloadItem *downloadingItem = (DownloadItem *)[DatabaseManager findFirstByCriteria:DownloadItem.class queryString:@"WHERE type = 1 and downloadStatus = 'start'"];
    if (downloadingItem == nil) {
        downloadingItem = (SubdownloadItem *)[DatabaseManager findFirstByCriteria:SubdownloadItem.class queryString:@"WHERE downloadStatus = 'start'"];
    }
    return downloadingItem;
}

+ (BOOL)isAirPlayActive{
    CFDictionaryRef currentRouteDescriptionDictionary = nil;
    UInt32 dataSize = sizeof(currentRouteDescriptionDictionary);
    AudioSessionGetProperty(kAudioSessionProperty_AudioRouteDescription, &dataSize, &currentRouteDescriptionDictionary);
    if (currentRouteDescriptionDictionary) {
        CFArrayRef outputs = CFDictionaryGetValue(currentRouteDescriptionDictionary, kAudioSession_AudioRouteKey_Outputs);
        if (nil == outputs)
            return NO;
        if(CFArrayGetCount(outputs) > 0) {
            CFDictionaryRef currentOutput = CFArrayGetValueAtIndex(outputs, 0);
            CFStringRef outputType = CFDictionaryGetValue(currentOutput, kAudioSession_AudioRouteKey_Type);
            return (CFStringCompare(outputType, kAudioSessionOutputRoute_AirPlay, 0) == kCFCompareEqualTo);
        }
    }
    
    return NO;
}


+ (float)getFreeDiskspace
{
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    float totalFreeSpace_ = 0;
    if (dictionary) {
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalFreeSpace_ = [freeFileSystemSizeInBytes floatValue]/1024.0f/1024.0f/1024.0f;
    }
    return totalFreeSpace_;
}


+ (BOOL)changeItemStatusToStop:(DownloadItem *)item
{
    if ([item isKindOfClass:[SubdownloadItem class]]) {
        item = (SubdownloadItem *)item;
    }
    if ([item.downloadStatus isEqualToString:@"start"] || [item.downloadStatus isEqualToString:@"waiting"]) {
        item.downloadStatus = @"stop";
        [DatabaseManager update:item];
        return YES;
    } else {
        return NO;
    }
}

@end
