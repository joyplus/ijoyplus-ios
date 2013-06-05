//
//  CommonMotheds.m
//  yueshipin
//
//  Created by Rong on 13-3-22.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "CommonMotheds.h"
#import "Reachability.h"
#import "UIUtility.h"
#import "DatabaseManager.h"
#import "SubdownloadItem.h"
#import "CMConstants.h"
#import "TFHpple.h"

@implementation CommonMotheds
+(BOOL)isNetworkEnbled{
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([hostReach currentReachabilityStatus]  != NotReachable){
        return YES;
    }
    else{
        return NO;
    }
}

+(void)showNetworkDisAbledAlert:(UIView *)view{
    if (![CommonMotheds isNetworkEnbled]) {
         [UIUtility showNetWorkError:view];
    }
}

+(void)showInternetError:(NSError *)error inView:(UIView *)view{
    if (error.code == -1001) {
         [UIUtility showNetWorkError:view];
    }
}

+(BOOL)isFirstTimeRun{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"App_version"]==nil){
        
        return YES;
    }
    else{
        return NO;
    }
}

+(BOOL)isVersionUpdate{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *oldVersion = [defaults objectForKey:@"App_version"];
    if(oldVersion!=nil){
        NSString *newVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
        NSComparisonResult result = [oldVersion compare:newVersion];
        if (result == NSOrderedAscending) {
            return YES;
        }
    }

    return NO;
}
+(void)setVersion{
     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
     NSString *bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
     NSLog(@" %@is app version", bundleVersion);
     [defaults setObject:bundleVersion forKey:@"App_version"];
     [defaults synchronize];
}

+ (NSArray *)localPlaylists:(NSString *)mediaId
                       type:(NSInteger)type
{
    NSArray * tmpSubitems = nil;
    if (MOVIE_TYPE == type)
    {
        tmpSubitems = [DatabaseManager findByCriteria:DownloadItem.class
                                          queryString:[NSString stringWithFormat:@"WHERE itemId = %@", mediaId]];
    }
    else
    {
        tmpSubitems = [DatabaseManager findByCriteria:SubdownloadItem.class
                                          queryString:[NSString stringWithFormat:@"WHERE itemId = %@", mediaId]];
    }
    
    NSArray * playlists = [tmpSubitems sortedArrayUsingComparator:^(SubdownloadItem *a, SubdownloadItem *b) {
        NSNumber *first =  [NSNumber numberWithInt:a.subitemId.intValue];
        NSNumber *second = [NSNumber numberWithInt:b.subitemId.intValue];
        return [first compare:second];
    }];
    
    NSMutableArray * playlistInfo = [[NSMutableArray alloc] init];
    
    if (MOVIE_TYPE == type)
    {
        if (0 != playlists.count)
        {
            NSMutableDictionary * playInfo = [NSMutableDictionary dictionary];
            DownloadItem *item = [playlists objectAtIndex:0];
            item = (SubdownloadItem *)[DatabaseManager findFirstByCriteria:DownloadItem.class
                                                               queryString:[NSString stringWithFormat:@"where itemId = %@", item.itemId]];
            if([item.downloadStatus isEqualToString:@"done"] || item.percentage == 100)
            {
                NSString *filePath;
                if ([item.downloadType isEqualToString:@"m3u8"])
                {
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                    {
                        filePath = [NSString stringWithFormat:@"%@/%@/%@.m3u8", LOCAL_HTTP_SERVER_URL, item.itemId, item.itemId];
                    }
                    else
                    {
                        NSString *subPath = [NSString stringWithFormat:@"%@_%@",item.itemId,@"1"];
                        filePath = [NSString stringWithFormat:@"%@/%@/%@/1.m3u8",LOCAL_HTTP_SERVER_URL, item.itemId,subPath];
                    }
                }
                else
                {
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                    {
                        filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.mp4", item.itemId]];
                    }
                    else
                    {
                        NSString * fileName = [item.itemId stringByAppendingString:@".mp4"];
                        filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
                    }
                }
                [playInfo setObject:filePath forKey:@"videoUrl"];
                [playInfo setObject:item.downloadType forKey:@"downloadType"];
                [playInfo setObject:[NSNumber numberWithDouble:item.duration] forKey:@"duration"];
                [playInfo setObject:item.name forKey:@"name"];
                [playInfo setObject:item.itemId forKey:@"itemId"];
                [playInfo setObject:[NSString stringWithFormat:@"%d",item.type] forKey:@"type"];
                
                [playlistInfo addObject:playInfo];
            }
        }
    }
    else
    {
        for (int i = 0; i < playlists.count; i ++)
        {
            NSMutableDictionary * playInfo = [NSMutableDictionary dictionary];
            SubdownloadItem *item = [playlists objectAtIndex:i];
            item = (SubdownloadItem *)[DatabaseManager findFirstByCriteria:SubdownloadItem.class queryString:[NSString stringWithFormat:@"where itemId = %@ and subitemId = '%@'", item.itemId, item.subitemId]];
            if([item.downloadStatus isEqualToString:@"done"] || item.percentage == 100)
            {
                NSString *filePath;
                if ([item.downloadType isEqualToString:@"m3u8"])
                {
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                    {
                        filePath = [NSString stringWithFormat:@"%@/%@/%@/%@_%@.m3u8", LOCAL_HTTP_SERVER_URL, item.itemId, item.subitemId, item.itemId, item.subitemId];
                    }
                    else
                    {
                        NSString *idStr = item.subitemId ;
                        NSArray *tempArr =  [idStr componentsSeparatedByString:@"_"];
                        filePath = [NSString stringWithFormat:@"%@/%@/%@/%@.m3u8",LOCAL_HTTP_SERVER_URL,item.itemId,idStr,[tempArr objectAtIndex:1]];
                    }
                }
                else
                {
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                    {
                        filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@_%@.mp4", item.itemId, item.subitemId]];
                    }
                    else
                    {
                        filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.mp4", item.subitemId]];
                    }
                }
                [playInfo setObject:filePath forKey:@"videoUrl"];
                [playInfo setObject:item.downloadType forKey:@"downloadType"];
                [playInfo setObject:[NSNumber numberWithDouble:item.duration] forKey:@"duration"];
                
                NSString * videoName = nil;
                if (item.type == SHOW_TYPE)
                {
                    videoName = item.name;
                }
                else
                {
                    videoName = item.subitemId;//[NSString stringWithFormat:@"%@: 第%@集",self.titleContent,item.subitemId];
                }
                
                [playInfo setObject:videoName forKey:@"name"];
                [playInfo setObject:item.itemId forKey:@"itemId"];
                [playInfo setObject:item.subitemId forKey:@"subItemId"];
                [playInfo setObject:[NSString stringWithFormat:@"%d",item.type] forKey:@"type"];
                
                [playlistInfo addObject:playInfo];
            }
        }
    }
    
    return playlistInfo;
}

+(int)getOnlineConfigValue{
   NSString *valueStr = [AppDelegate instance].showVideoSwitch;
   return [valueStr intValue];
}

+ (NSString *)getDownloadURLWithHTML:(NSString *)url
{
    NSData *htmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    NSArray *elements  = [xpathParser searchWithXPathQuery:@"//a"]; // get the title
    
    NSString * downloadURL = nil;
    for (TFHppleElement * element in elements)
    {
        NSDictionary * dic = [element attributes];
        
        //        NSLog(@"%@",[dic objectForKey:@"class"]);
        //        NSLog(@"%@",[dic objectForKey:@"id"]);
        NSLog(@"%@",[element content]);
        
        if (([[dic objectForKey:@"class"] isEqualToString:@"new-dbtn"]
             && [[dic objectForKey:@"id"] isEqualToString:@"downFileButtom"]) ||
            ([[dic objectForKey:@"class"] isEqualToString:@"btn blue-btn"]
             && [[dic objectForKey:@"id"] isEqualToString:@"fileDownload"]))
        {
            downloadURL = [element objectForKey:@"href"];
            [downloadURL stringByReplacingOccurrencesOfString:@"amp;" withString:@""];
            //            NSLog(@"%@",downloadURL);
            return downloadURL;
        }
    }
    return downloadURL;
}


@end
