//
//  AppDelegate.m
//  joylink
//
//  Created by joyplus1 on 13-4-25.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "FTAnimation.h"
#import "CommonMethod.h"
#import "RemoteAction.h"
#import "ActionFactory.h"
#import "MobClick.h"
#import "EnvConstant.h"
#import "CommonHeader.h"
#import "JSONKit.h"
#import "AsyncSocket.h"

@interface AppDelegate ()<AsyncUdpSocketDelegate>
{
    AsyncSocket *acceptSocket;
}

@property (nonatomic, strong)UIView *rView;
@property (readonly) CMMotionManager *motionManager;
@property (nonatomic, strong) RemoteAction *sensorRemoteAction;
@property (nonatomic, strong) AsyncSocket *tcpServerSocket;
@property (nonatomic, strong) AsyncUdpSocket *udpServerSocket;
@property (nonatomic, strong) NSMutableString *contentString;
@property (nonatomic, strong) NSTimer *connectDongleTimer;
@property (nonatomic, strong) NSTimer *healthyTimer;
@property (nonatomic) int connectDongleIndex;
@property (nonatomic) int specialIndex;
@property (nonatomic) int frequency;
@end

@implementation AppDelegate
@synthesize lastApp;
@synthesize rView;
@synthesize window = _window;
@synthesize scaleX, scaleY;
@synthesize motionManager;
@synthesize sensorRemoteAction;
@synthesize dongelSocketServerIP;
@synthesize tcpServerSocket;
@synthesize contentString;
@synthesize CLIENT_CONNECT_INDEX;
@synthesize udpServerSocket;
@synthesize dongleServerName;
@synthesize tvScreenHeight, tvScreenWidth;
@synthesize connectDongleTimer;
@synthesize connectDongleIndex;
@synthesize screenshotImage;
@synthesize healthyTimer;
@synthesize deviceArray;
@synthesize appList;
@synthesize scaleInfo, screenModeInfo;
@synthesize touchScale;
@synthesize specialIndex;
@synthesize frequency;
@synthesize videoMedia;
@synthesize musicMedia;

+ (AppDelegate *) instance {
	return (AppDelegate *) [[UIApplication sharedApplication] delegate];
}

- (void)customizeAppearance
{
    // Set the background image for *all* UINavigationBars
    UIImage *gradientImage44 = [UIImage imageNamed:@"top_bg"];
    [[UINavigationBar appearance] setFrame:CGRectMake(0, 0, 320, 49)];
    [[UINavigationBar appearance] setBackgroundImage:gradientImage44 forBarMetrics:UIBarMetricsDefault];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    HomeViewController *mainController = [[HomeViewController alloc] init];
    self.window.rootViewController = mainController;
    [self.window makeKeyAndVisible];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startGravityControl:) name:TURN_ON_GRAVITY object:nil];
    
    [MobClick startWithAppkey:kUmengAppkey reportPolicy:REALTIME channelId:CHANNEL_ID];
    [MobClick checkUpdate];
    
    connectDongleTimer = [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(findDongleServerIP) userInfo:nil repeats:YES];
    [connectDongleTimer fire];
    deviceArray = [[NSMutableArray alloc]initWithCapacity:3];
    [self startTcpSocketServer];
    
    [self customizeAppearance];
    [self showStartAnimation];
    touchScale = ((NSString *)[[ContainerUtility sharedInstance] attributeForKey:TOUCH_SCALE]).integerValue;
    [self performSelectorInBackground:@selector(setDefaultValue) withObject:nil];
    return YES;
}

- (void)setDefaultValue
{
    touchScale = ((NSString *)[[ContainerUtility sharedInstance] attributeForKey:TOUCH_SCALE]).integerValue;
    if (touchScale == 0) {
        [[ContainerUtility sharedInstance] setAttribute:[NSString stringWithFormat:@"%i", 3] forKey:TOUCH_SCALE];
    }
    int gravityScale = ((NSString *)[[ContainerUtility sharedInstance] attributeForKey:GRAVITY_SCALE]).integerValue;
    if (gravityScale == 0) {
         [[ContainerUtility sharedInstance] setAttribute:[NSString stringWithFormat:@"%i", 8] forKey:GRAVITY_SCALE];
    }
}

- (void)showStartAnimation
{
    UIImageView *fView =[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height)];
    if ([CommonMethod isIphone5]) {
        fView.image=[UIImage imageNamed:@"Default-568h"];
    } else {
        fView.image=[UIImage imageNamed:@"Default"];
    }
    rView=[[UIView alloc]initWithFrame:fView.frame];
    [rView addSubview:fView];
    [self.window addSubview:rView];
    [self performSelector:@selector(theAnimation) withObject:nil afterDelay:1];//5秒后执行TheAnimation
}

- (void)theAnimation
{
    [rView flyOut:1 delegate:nil];
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
    [self stopGravitySender];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self startGravityControl:nil];
}

- (void)startGravityControl:(NSNotification *)notification
{
    int turnon = [[NSString stringWithFormat:@"%@", [[ContainerUtility sharedInstance]attributeForKey:TURN_ON_GRAVITY]] integerValue];
    if (turnon == 1) {
        [self startGravitySender];
    } else {
        [self stopGravitySender];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)startTcpSocketServer
{
    tcpServerSocket=[[AsyncSocket alloc] initWithDelegate:self];
    NSError *err = nil;
    if ([tcpServerSocket acceptOnPort:LOCAL_SOCKET_SERVER_PORT error:&err]) {
        NSLog(@"TCP server is listening...");
    }else {
        NSLog(@"Start TCP server error!");
    }    
    if (err) {
        NSLog(@"TCP server error: %@",err);
    }
}


- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket{
    if (newSocket) {
        acceptSocket=newSocket;
        NSLog(@"did accept new socket");
    }
}

- (NSRunLoop *)onSocket:(AsyncSocket *)sock wantsRunLoopForNewSocket:(AsyncSocket *)newSocket{
    NSLog(@"wants runloop for new socket.");
    return [NSRunLoop currentRunLoop];
}

- (BOOL)onSocketWillConnect:(AsyncSocket *)sock{
    NSLog(@"will connect");
    return YES;
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
    NSLog(@"did connect to host");
    [sock readDataWithTimeout:-1 tag:1];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSLog(@"Retrieving Data...");
    [sock readDataWithTimeout:-1 tag:1];
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (contentString == nil) {
        contentString = [[NSMutableString alloc]initWithCapacity:100000];
    }
    if (message) {
        [contentString appendString:message];
    }
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    if (err) {
        NSLog(@"error in willDisconnectWithError %@", err);
    }
}
- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    NSLog(@"Finished in retrieving Data!");
    NSDictionary *jsonResponse = [contentString objectFromJSONString];
    int dataType = [[jsonResponse objectForKey:@"Data_Type"] intValue];
    if (SYNC_LAUNCHER_LIST_INFO_ID == dataType) {
        appList = [[jsonResponse objectForKey:@"Data"] objectForKey:@"mappData"];
        [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_APP_LIST object:nil];
    } else if(SCREEN_SHOT_ID == dataType ) {
        NSArray *screenshotArray = [jsonResponse objectForKey:@"Data"];
        Byte byte[screenshotArray.count];
        for (int i = 0; i < screenshotArray.count; i++) {
            NSString *bStr = [screenshotArray objectAtIndex:i];
            Byte b = bStr.intValue;
            byte[i] = b;
        }
        NSData *imageData = [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
        screenshotImage = [UIImage imageWithData:imageData];
        [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_SCREENSHOT object:nil];
    } else if(SYNC_SCREEN_MODE_INFO_ID == dataType){
        screenModeInfo = [jsonResponse objectForKey:@"Data"];
        specialIndex++;
        [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_SCREEN_SETTING object:nil];
    } else if(SYNC_SCREEN_SCALE_INFO_ID == dataType){
        scaleInfo = [jsonResponse objectForKey:@"Data"];
        specialIndex++;
        [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_SCREEN_SETTING object:nil];
    }
    contentString = nil;
}

- (void)reconnectDongle
{
    connectDongleIndex = 0;
    CLIENT_CONNECT_INDEX = 0;
    if (connectDongleTimer) {
        [connectDongleTimer invalidate];
    }
    connectDongleTimer = [NSTimer scheduledTimerWithTimeInterval:15.0f target:self selector:@selector(findDongleServerIP) userInfo:nil repeats:YES];
    [connectDongleTimer fire];
    
}

- (void)findDongleServerIP
{
    if (connectDongleIndex >= 5) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DONGLE_IS_CONNECTED object:[NSNumber numberWithBool:NO]];
    } else {
        [self resetServerInfo];
        [self startUdpServer];
        RemoteAction *searchServerAction = [ActionFactory getSearchServerAction:SEARCH_SERVER];
        [searchServerAction trigger];
        connectDongleIndex++;
    }
}

- (void)startUdpServer
{
    if (udpServerSocket) {
        udpServerSocket.delegate = nil;
        udpServerSocket = nil;
    }
    udpServerSocket = [[AsyncUdpSocket alloc]initWithDelegate:self];
    NSError *error = nil;
    [udpServerSocket bindToAddress:[CommonMethod getIPAddress] port:LOCAL_SOCKET_SERVER_PORT error:&error];
    if (error) {
        NSLog(@"start upd server error: %@",error);
    }
    [udpServerSocket receiveWithTimeout:-1 tag:1];
    NSLog(@"start udp server");
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port{
    [sock receiveWithTimeout:-1 tag:tag];
    if (sock.isClosed) {
        NSLog(@"UDP socket server is closed!!!");
    }
    NSString *response = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    Byte *dataByte = (Byte *)[data bytes];
    int firstByte = dataByte[0];
    if(SYNC_SERVER_INFO_FOR_SEARCH_ID == firstByte){
        NSLog(@"UDP message = %@", response);
        if (response.length > 1) {
            NSDictionary *responseDic = [[response substringFromIndex:1] objectFromJSONString];
            if ([StringUtility stringIsEmpty:dongelSocketServerIP]) {
                [self saveServerInfo:responseDic];
            }
            if (![deviceArray containsObject:responseDic]) {
                [deviceArray addObject:responseDic];
            }
            if (deviceArray.count == 1) {
                [self startGravityControl:nil];
            }
            connectDongleIndex = 0;
            [connectDongleTimer invalidate];
            connectDongleTimer = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_DEVICE_LIST object:deviceArray];
        }
    }
    CLIENT_CONNECT_INDEX = 0; // whatever recevied from server, that means the connection is established.
    return YES;
}

- (void)saveServerInfo:(NSDictionary *)responseDic
{
    dongelSocketServerIP = [responseDic objectForKey:@"serverWifiAddress"];
    dongleServerName = [responseDic objectForKey:@"deviceName"];
    tvScreenWidth = [[responseDic objectForKey:@"screenWidth"] floatValue];
    tvScreenHeight = [[responseDic objectForKey:@"screenHeight"] floatValue];
    [self setScaleXY];
    [[NSNotificationCenter defaultCenter] postNotificationName:DONGLE_IS_CONNECTED object:[NSNumber numberWithBool:YES]];
    [self performSelectorOnMainThread:@selector(startCheckServerStateTimer) withObject:nil waitUntilDone:YES];
    
}
- (void)resetServerInfo
{
    dongelSocketServerIP = @"";
    dongleServerName = @"";
    appList = nil;
    screenModeInfo = nil;
    scaleInfo = nil;
    specialIndex = 0;
    [self stopGravitySender];
    if (deviceArray) {
        [deviceArray removeAllObjects];
    } else {
        deviceArray = [[NSMutableArray alloc]initWithCapacity:3];
    }
    
}

- (void)startCheckServerStateTimer
{
    if (healthyTimer) {        
        [healthyTimer invalidate];
        healthyTimer = nil;
    }
    healthyTimer = [NSTimer scheduledTimerWithTimeInterval:20.0f target:self selector:@selector(checkServerState) userInfo:nil repeats:YES];
    [healthyTimer fire];
}

- (void)checkServerState
{
    if (CLIENT_CONNECT_INDEX < MAX_CHECK_SERVER_STATE_RETRY_TIMES) {
        RemoteAction *action = [ActionFactory getMessageAction:CLIENT_ISCONNECTED];
        NSString *msg = [NSString stringWithFormat:@"{\"clientWifiAddress\":\"%@\"}", [CommonMethod getIPAddress]];
        NSLog(@"Check Server: %@", msg);
        [action trigger:msg];
        CLIENT_CONNECT_INDEX ++;
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:DONGLE_IS_CONNECTED object:[NSNumber numberWithBool:NO]];
        [self resetServerInfo];
        [healthyTimer invalidate];
        healthyTimer = nil;
    }
}

- (CMMotionManager *)motionManager
{
    if(!motionManager) {
        motionManager = [[CMMotionManager alloc] init];
    }
    return motionManager;
}

- (void)setScaleXY
{
    scaleX = (float) tvScreenWidth / (self.window.frame.size.height - NAVIGATION_BAR_HEIGHT - 61 - 5);
    scaleY = (float) tvScreenHeight / TOUCH_SCREEN_WIDTH;
}

- (void)startGravitySender
{
    if ([StringUtility stringIsEmpty:dongelSocketServerIP]) {
        return;
    }
    if (sensorRemoteAction == nil) {
        sensorRemoteAction = [ActionFactory getSensorTypeActionByEventType:SENSOR_TYPE];
    }
    if ([motionManager isAccelerometerActive]) {
        return;
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [self.motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        dispatch_sync(dispatch_get_main_queue(), ^(void) {
            float scale = [((NSNumber *)[[ContainerUtility sharedInstance]attributeForKey:GRAVITY_SCALE]) floatValue];
            float gx = accelerometerData.acceleration.x * scale;
            float gy = accelerometerData.acceleration.y * scale;
            float gz = -accelerometerData.acceleration.z * scale;
            
            float gravity[3];
            gravity[2] = gz;
            int direction = [[NSString stringWithFormat:@"%@", [[ContainerUtility sharedInstance]attributeForKey:GRAVITY_DIRECTION]] integerValue];
            if (direction == 1){//横屏
                gravity[0] = -gx;
                gravity[1] = -gy;
            } else {//竖屏
                gravity[0] = gy;
                gravity[1] = gx;
            }
            if (frequency % 4 == 0) {
                [sensorRemoteAction triggerSensor:gravity];
            }
            frequency++;
            if (frequency > 1000000) {
                frequency = 0;
            }
        });
    }];
}

- (void)stopGravitySender
{
    if (sensorRemoteAction) {
        [sensorRemoteAction close];
        sensorRemoteAction = nil;
    }
    if ([motionManager isAccelerometerActive]) {
        [motionManager stopAccelerometerUpdates];
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)closePreviousApp
{
    if (lastApp) {
        RemoteAction *action = [ActionFactory getMessageAction:CLOSE_APK];
        NSDictionary *sendInfo = [NSDictionary dictionaryWithObjectsAndKeys:[[AppDelegate instance].lastApp objectForKey:@"packegeName"], @"packegeName", nil];
        NSString *msg = [sendInfo JSONString];
        [action trigger:msg];
        lastApp = nil;
    }
}

- (void)startNewApp:(NSDictionary *)appInfo
{
    RemoteAction *action = [ActionFactory getMessageAction:OPEN_LAUNCHER_ITEM_INFO];
    NSString *msg = [appInfo JSONString];
    [action trigger:msg];
    lastApp = appInfo;
}
@end
