//
//  RemoteAction.h
//  yuexiangjia
//
//  Created by joyplus1 on 13-2-28.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncUdpSocket.h"
#import "AppDelegate.h"

typedef enum {//connect event
    //connect event
    CONNECT_SERVER = 5,
    SYNC_SERVER_INFO_FOR_CONNECT = 6,
    SYNC_SERVER_INFO_FOR_SEARCH = 7,
    SEARCH_SERVER = 8,
    
    //mouse mode
    UP_AND_DOWN_SCROLL_MODE = 14,
    LEFT_AND_RIGHT_SCROLL_MODE = 15,
    MOUSE_MODE = 16,
    
    //mouse and tp event
    ONLY_MOVE_MOUSE_ICON = 20,
    SINGLE_CLICK = 21,
    LONG_CLICK = 22,
    DOUBLE_CLICK = 23,
    RIGHT_CLICK = 24,
    LEFT_MOUSE_DOWN = 25,
    LEFT_MOUSE_UP = 26,
    LEFT_MOUSE_CANCEL = 27,
    MOVE_DRAG = 28,
    MOUSE_MODE_POINTER_UP = 29,
    MOUSE_MODE_POINTER_DOWN = 30,
    MOUSE_MODE_DOUBLE_MOVE = 31,
    MOUSE_MODE_ACTION_UP = 32,
    TP_MODE_LEFT_MOUSE_DOWN = 33,
    TP_MODE_DRAG = 34,
    TP_MODE_RIGHT_MOUSE_DOWN = 35,
    TP_MODE_RIGHT_MOUSE_UP = 36,
    TP_MODE_LEFT_MOUSE_UP = 37,
    TP_MODE_DRAG_RIGHT = 38,
    //FLING((byte) 13),
    
    //Sensor
    SENSOR_TYPE = 100,
    
    //toolsbar
//    SEND_KEY_HOME = 200,
//    SEND_KEY_BACK = 201,
//    SEND_KEY_MENU = 202,
    SEND_KEY_TASK = 203,
    SCREEN_SHOT = 204,
    SYNC_SCREEN_SCALE_INFO = 205,
    SYNC_SCREEN_MODE_INFO = 206,
    SET_SCREEN_SCALE = 207,
    SET_SCREEN_MODE = 208,
    
    //keyboard event
    SEND_INPUT_MSG = 300,
    DEL_INPUT_MSG = 301,
    SYNC_EDITORINFO = 302,
    FOCES_TRUE = 303,
    FOCES_FALSE = 304,
    
    
    //Launcher
    SYNC_LAUNCHER_LIST_INFO = 400,
    OPEN_LAUNCHER_ITEM_INFO = 401,
    DELETE_LAUNCHER_ITEM_INFO = 402,
    SYNC_LAUNCHER_ADD_INFO = 403,
    SYNC_LAUNCHER_CHANGE_INFO = 404,
    SYNC_LAUNCHER_REMOVE_INFO = 405,
    
    //Browser
    BROWSER_REQUEST_URL = 500,
    BROWSER_REQUEST_HISTORY = 501,
    BROWSER_REQUEST_BOOKMARK = 502,
    BROWSER_REQUEST_CLEAR_HISTORY = 503,
    BROWSER_OPEN_BOOKMARK_ITEM_URL = 504,
    BROWSER_DELETE_BOOKMARK_ITEM_URL = 505,
    BROWSER_ADD_BOOKMARK_ITEM_URL = 506,
    
    //Wifi
    SEND_WIFI_INFO = 600,
    //AP
    OPEN_SERVER_AP = 601,
    //eck isConnected
    ISCONNECTED = 602,
    CONNECTED = 603,
    
    //		SEND_KEY_VOLUME_DOWN((byte) 700),
    //		SEND_KEY_VOLUME_MUTE((byte) 701),
    //		SEND_KEY_VOLUME_UP((byte) 702),
    //		SEND_KEY_DPAD_UP((byte) 703),
    //		SEND_KEY_DPAD_DOWN((byte) 704),
    //		SEND_KEY_DPAD_LEFT((byte) 705),
    //		SEND_KEY_DPAD_RIGHT((byte) 706),
    //		SEND_KEY_DPAD_CENTER((byte) 707),
    SEND_KEY_MEDIA_FAST_FORWARD = 708,
    SEND_KEY_MEDIA_REWIND = 709,
    //		SEND_KEY_MEDIA_PLAY_PAUSE((byte) 710),
    DEVICE_SLEEP = 710,
    DEVICE_WAKE = 711,
    CLIENT_ISCONNECTED = 606,
    CLIENT_CONNECTED = 607,
    
    SEND_KEY_CODE = 605,

    KEYCODE_HOME = 3,
    KEYCODE_MENU = 82,
    KEYCODE_BACK = 4,
    KEYCODE_VOLUME_DOWN = 25,
    KEYCODE_VOLUME_MUTE = 164,
    KEYCODE_VOLUME_UP = 24,
    KEYCODE_DPAD_UP = 19,
    KEYCODE_DPAD_DOWN = 20,
    KEYCODE_DPAD_LEFT = 21,
    KEYCODE_DPAD_RIGHT = 22,
    KEYCODE_DPAD_CENTER = 23,
    KEYCODE_MEDIA_PLAY_PAUSE = 85,
    
    CLOSE_APK = 700,
} ControlEvent;

typedef enum
{
    SYNC_SERVER_INFO_FOR_SEARCH_ID = 7,
    SYNC_LAUNCHER_LIST_INFO_ID = -112,
    CLIENT_CONNECTED_ID = 333,
    SCREEN_SHOT_ID = -52,
    SYNC_SCREEN_MODE_INFO_ID = -50,
    SYNC_SCREEN_SCALE_INFO_ID = -51    
} ControlEventId;

@interface RemoteAction : NSObject <AsyncUdpSocketDelegate>

@property (nonatomic, strong) AsyncUdpSocket *sendSocket;
@property (nonatomic) int port;
@property (nonatomic) ControlEvent event;

- (void)close;
- (id)initWithEvent:(ControlEvent)controlEvent;
- (void)trigger;
- (void)trigger:(int)deltaX deltaY:(int)deltaY;
- (void)trigger:(NSString *)msg;
- (void)triggerSensor:(float [])gravity;
@end
