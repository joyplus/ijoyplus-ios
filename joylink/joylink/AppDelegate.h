//
//  AppDelegate.h
//  joylink
//
//  Created by joyplus1 on 13-4-25.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreMotion/CoreMotion.h>
#import "MediaObject.h"

#define MAX_CHECK_SERVER_STATE_RETRY_TIMES 3
enum {
    YueImageCasting,
    YueMusicCasting,
    YueVideoCasting
};
typedef NSInteger YueCastingContentType;


@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    NSMutableArray *connectedSockets;
    NSNetService *netService;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic)int musicRepeatMode;
@property (nonatomic, strong)MPMoviePlayerController *moviePlayer;
@property (nonatomic, strong)MPMusicPlayerController *musicPlayer;
@property (nonatomic, strong)MediaObject *videoMedia;
@property (nonatomic, strong)MPMediaItem *musicMedia;
@property (nonatomic) YueCastingContentType castingType;
@property (nonatomic, strong)NSArray *imageObjectArray;
@property (nonatomic)int displayingImageIndex;
@property (nonatomic) float touchScale;
@property (nonatomic) float scaleX;
@property (nonatomic) float scaleY;
@property (nonatomic, strong) NSString *dongelSocketServerIP;
@property (nonatomic) int CLIENT_CONNECT_INDEX;
@property (nonatomic, strong) NSString *dongleServerName;
@property (nonatomic) float tvScreenWidth;
@property (nonatomic) float tvScreenHeight;
@property (nonatomic, strong) UIImage *screenshotImage;
@property (nonatomic, strong) NSDictionary *lastApp;
@property (nonatomic, strong) NSMutableArray *deviceArray;
@property (nonatomic, strong) NSArray *appList;
@property (nonatomic, strong) NSDictionary *scaleInfo;
@property (nonatomic, strong) NSDictionary *screenModeInfo;
+ (AppDelegate *) instance;

- (void)startGravitySender;
- (void)stopGravitySender;
- (void)reconnectDongle;
- (void)closePreviousApp;
- (void)startNewApp:(NSDictionary *)appInfo;
- (void)resetServerInfo;
- (void)saveServerInfo:(NSDictionary *)responseDic;
@end
