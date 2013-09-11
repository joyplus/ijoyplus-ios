//
//  ActionFactory.h
//  yuexiangjia
//
//  Created by joyplus1 on 13-2-28.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteAction.h"


@interface ActionFactory : NSObject

+ (RemoteAction *) getSimpleActionByEvent:(ControlEvent)event;
+ (RemoteAction *) getComplexActionByEvent:(ControlEvent)event;
+ (RemoteAction *) getSendInputMsgAction:(ControlEvent)event;
+ (RemoteAction *) getSensorTypeActionByEventType:(ControlEvent)event;
+ (RemoteAction *) getSearchServerAction:(ControlEvent)event;
+ (RemoteAction *) getMessageAction:(ControlEvent)event;
@end
