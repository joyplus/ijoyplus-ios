//
//  AppDelegate.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-21.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import "RemoteAction.h"
#import "ActionFactory.h"

@interface AppDelegate ()

@property (nonatomic, strong) UIImageView *zView;//Z图片ImageView
@property (nonatomic, strong) UIImageView *fView;//F图片ImageView
@property (nonatomic, strong) UIView *rView;//图片的UIView
@property (readonly) CMMotionManager *motionManager;
@property (nonatomic, strong) RemoteAction *sensorRemoteAction;
@end

@implementation AppDelegate
@synthesize zView, fView, rView;
@synthesize moviePlayer;
@synthesize castingType;
@synthesize imageObjectArray;
@synthesize displayingImageIndex;
@synthesize musicPlayer;
@synthesize scaleX, scaleY;
@synthesize motionManager;
@synthesize sensorRemoteAction;

+ (AppDelegate *)instance
{
    return [UIApplication sharedApplication].delegate;
}

- (CMMotionManager *)motionManager
{
    if(!motionManager) {
        motionManager = [[CMMotionManager alloc] init];
    }
    return motionManager;
}

- (void)customizeAppearance
{
    // Set the background image for *all* UINavigationBars
    UIImage *gradientImage44 = [UIImage imageNamed:@"nav_bg"];
    [[UINavigationBar appearance] setBackgroundImage:gradientImage44 forBarMetrics:UIBarMetricsDefault];
    
//    UIImage *minImage = [[UIImage imageNamed:@"slider_min"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
//    UIImage *maxImage = [[UIImage imageNamed:@"slider_max"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    UIImage *thumbImage = [UIImage imageNamed:@"slider_thumb"];
    
//    [[UISlider appearance] setMaximumTrackImage:maxImage forState:UIControlStateNormal];
//    [[UISlider appearance] setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:thumbImage forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:thumbImage forState:UIControlStateHighlighted];
    [[UISlider appearance] setMinimumTrackTintColor:[UIColor colorWithRed:86/255.0 green:139/255.0 blue:217/255.0 alpha:1.0]];
    [[UISlider appearance] setMaximumTrackTintColor:[UIColor colorWithRed:80/255.0 green:80/255.0 blue:80/255.0 alpha:1.000]];
    
    UIImage *toobarImage = [UIImage imageNamed:@"toolbar_bg"];
    [[UIToolbar appearance] setBackgroundImage:toobarImage forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if(self.window.bounds.size.height == 568){
        self.iphone5 = YES;
    } else {
        self.iphone5 = NO;
    }
    musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.rootViewController = [[RootViewController alloc] init];
    self.window.rootViewController = self.rootViewController;
    [self.window makeKeyAndVisible];
    
    fView =[[UIImageView alloc]initWithFrame:self.window.frame];//初始化fView
    fView.image=[UIImage imageNamed:@"f.png"];//图片f.png 到fView
    zView=[[UIImageView alloc]initWithFrame:self.window.frame];//初始化zView
    zView.image=[UIImage imageNamed:@"z.png"];//图片z.png 到zView
    rView=[[UIView alloc]initWithFrame:self.window.frame];//初始化rView
    [rView addSubview:fView];//add 到rView
    [rView addSubview:zView];//add 到rView
    [self.window addSubview:rView];//add 到window
    
    float serverScreenWidth = 1280;
	float serverScreenHeight = 720;
    [self setScaleXY:serverScreenWidth serverScreenHeight:(float)serverScreenHeight];
    [self startGravitySender];
    [self customizeAppearance];
    [self performSelector:@selector(TheAnimation) withObject:nil afterDelay:1];//5秒后执行TheAnimation
    return YES;
}


- (void)TheAnimation
{
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.7 ;  // 动画持续时间(秒)
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = kCATransitionFade;//淡入淡出效果
    NSUInteger f = [[rView subviews] indexOfObject:fView];
    NSUInteger z = [[rView subviews] indexOfObject:zView];
    [rView exchangeSubviewAtIndex:z withSubviewAtIndex:f];
    [[rView layer] addAnimation:animation forKey:@"animation"];
    [self performSelector:@selector(moveToUpSide) withObject:nil afterDelay:1];//2秒后执行TheAnimation
}

- (void)moveToUpSide {
    [UIView animateWithDuration:0.7 animations:^{//修改rView坐标
        rView.frame = CGRectMake(self.window.frame.origin.x, -self.window.frame.size.height, self.window.frame.size.width, self.window.frame.size.height);
    } completion:^(BOOL finished){
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)setScaleXY:(float)serverScreenWidth serverScreenHeight:(float)serverScreenHeight
{
    //    scaleX = (float) serverScreenWidth / bounds.size.width;
    //    scaleY = (float) serverScreenHeight / bounds.size.height;
    scaleX = 3;
    scaleY = 3;
}

- (void)startGravitySender
{
    [self.motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        dispatch_sync(dispatch_get_main_queue(), ^(void) {
            float gx = accelerometerData.acceleration.x;
            float gy = accelerometerData.acceleration.y;
            float gz = accelerometerData.acceleration.z;
            
            float gravity[3];
            gravity[2] = gz;
            int mSensorModeType = 1;
            if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown){
                if (mSensorModeType == 0) {
                    gravity[0] = gx;
                    gravity[1] = gy;
                } else if (mSensorModeType == 1) {
                    gravity[0] = gy;
                    gravity[1] = -gx;
                }
            } else {
                if (mSensorModeType == 0) {
                    gravity[0] = -gy;
                    gravity[1] = gx;
                } else if (mSensorModeType == 1) {
                    gravity[0] = gx;
                    gravity[1] = gy;
                }
            }
            if (sensorRemoteAction == nil) {                
                sensorRemoteAction = [ActionFactory getSensorTypeActionByEventType:SENSOR_TYPE];
            }
            [sensorRemoteAction triggerSensor:gravity];
        });
    }];
}

- (void)stopGravitySender
{
    if ([motionManager isAccelerometerActive]) {
        [motionManager stopAccelerometerUpdates];
    }
}
@end
