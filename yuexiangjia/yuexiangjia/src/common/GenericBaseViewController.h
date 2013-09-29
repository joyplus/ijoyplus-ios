//
//  GenericBaseViewController.h
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-21.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VolumeGestureDelegate <NSObject>

- (void)changeVolume:(float)value;

@end

@interface GenericBaseViewController : UIViewController

@property (nonatomic)CGRect bounds;
@property (nonatomic)BOOL showMiddleBtn;
@property (nonatomic, strong) UINavigationBar *navBar;
@property (nonatomic, strong) UIToolbar *toolbar;


- (void)moveToUpSide:(UIView *)view;

- (void)homeButtonClicked;
- (void)backButtonClicked;
- (void)showNavigationBar:(NSString *)titleContent;
- (void)showToolbar;
- (void)showToolbar:(int)offsetY;
@end
