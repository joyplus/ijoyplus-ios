//
//  MyUncaughtExceptionHandler.h
//  ijoyplus
//
//  Created by joyplus1 on 12-11-8.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MyUncaughtExceptionHandler : NSObject{
    BOOL dismissed;
}

@end
void InstallMyUncaughtExceptionHandler();
