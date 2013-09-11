//
//  MenuView.h
//  joylink
//
//  Created by joyplus1 on 13-4-27.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MenuViewDelegate <NSObject>

@required
- (void)closeMenu;
- (void)homeMenuClicked;
- (void)remoteMenuClicked;
- (void)mouseMenuClicked;
- (void)settingsMenuClicked;

@end

@interface MenuView : UIView

@property (nonatomic, strong)id<MenuViewDelegate>menuDelegate;

@end
