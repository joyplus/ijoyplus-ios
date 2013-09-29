//
//  GenericBaseViewController.h
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-21.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuView.h"

#define TITLE_TAG 4849354

@protocol VolumeGestureDelegate <NSObject>

- (void)changeVolume:(float)value;

@end

@interface GenericBaseViewController : UIViewController

@property (nonatomic)CGRect bounds;
@property (nonatomic)BOOL showMiddleBtn;
@property (nonatomic, strong) UINavigationBar *navBar;
@property (nonatomic, strong) UIToolbar *toolbar;

- (UIViewController *)getViewControllerWithRightMenu:(UIViewController *)viewController;
- (void)showMenuBtnForNavController;
- (void)showBackBtnForNavController;
- (void)showBackBtn;
- (void)addContententView:(int)offsetY;
- (void)addMenuView:(int)offsetY;
- (void)homeButtonClicked;
- (void)backButtonClicked;
- (void)showNavigationBar:(NSString *)titleContent;
- (void)showMenuBtn;
- (void)showAvplayerBtn;
- (void)addInContentView:(UIView *)subview;
- (BOOL)serverIsConnected;
@end
