//
//  RespForWXDetailViewController.h
//  yueshipin
//
//  Created by 08 on 13-4-2.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RespForWXDetailViewControllerDelegate;

@interface RespForWXDetailViewController : UIViewController
{
    NSDictionary        *_dicDataSource;
    NSDictionary        *_dicVideoInfo;
}

@property (nonatomic, strong) NSDictionary        *dicDataSource;
@property (nonatomic, weak) id <RespForWXDetailViewControllerDelegate>delegate;

@end

@protocol RespForWXDetailViewControllerDelegate <NSObject>

- (void)back;
-(void) RespVideoContent:(NSDictionary *)data;

@end