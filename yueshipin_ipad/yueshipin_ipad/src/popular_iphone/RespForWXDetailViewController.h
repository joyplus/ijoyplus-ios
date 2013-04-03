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
    
    UILabel             *_labName;
    UILabel             *_labActors;
    UILabel             *_labDirectors;
    UILabel             *_labArea;
    UILabel             *_labReleaseDate;
    
    UIImageView         *_imgViewPoster;
    
}

@property (nonatomic, strong) NSDictionary        *dicDataSource;
@property (nonatomic, weak) id <RespForWXDetailViewControllerDelegate>delegate;

@end

@protocol RespForWXDetailViewControllerDelegate <NSObject>

- (void)back;
-(void) RespVideoContent:(NSDictionary *)data;

@end