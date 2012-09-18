//
//  CustomBackButtonHolder.h
//  ijoyplus
//
//  Created by joyplus1 on 12-9-17.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomBackButton.h"

@interface CustomBackButtonHolder : NSObject
- (id)initWithViewController:(UIViewController *)viewController;
- (id)getBackButton:(NSString *)text;
- (id)getNavgiationButton:(NSString *)text;

@end
