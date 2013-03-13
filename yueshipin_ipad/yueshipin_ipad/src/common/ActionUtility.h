//
//  ActionUtility.h
//  yueshipin
//
//  Created by joyplus1 on 13-1-6.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActionUtility : NSObject

+ (void)generateUserId:(void (^)(void))completion;
+ (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time;
+ (int)getDownloadingItemNumber;
+ (BOOL)isAirPlayActive;
@end
