//
//  AppDelegate.h
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-21.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "RootViewController.h"
#import "TestSocketViewController.h"
#import <CoreMotion/CoreMotion.h>

enum {
    YueImageCasting,
    YueMusicCasting,
    YueVideoCasting
};
typedef NSInteger YueCastingContentType;


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) RootViewController *rootViewController;
@property (nonatomic)int musicRepeatMode;
@property (nonatomic)BOOL iphone5;
@property (nonatomic, strong)MPMoviePlayerController *moviePlayer;
@property (nonatomic, strong)MPMusicPlayerController *musicPlayer;
@property (nonatomic) YueCastingContentType castingType;
@property (nonatomic, strong)NSArray *imageObjectArray;
@property (nonatomic)int displayingImageIndex;
@property (nonatomic) float scaleX;
@property (nonatomic) float scaleY;

+ (AppDelegate *)instance;

- (void)startGravitySender;
- (void)stopGravitySender;

@end
