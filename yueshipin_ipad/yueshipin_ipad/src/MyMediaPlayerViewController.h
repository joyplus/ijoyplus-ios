//
//  MyMediaPlayerViewController.h
//  yueshipin
//
//  Created by joyplus1 on 13-1-9.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericBaseViewController.h"
#import "VideoWebViewController.h"

@interface MyMediaPlayerViewController : GenericBaseViewController

@property (nonatomic, strong) NSMutableArray *videoUrls;
@property (nonatomic, strong) NSString *videoHttpUrl;
@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *prodId;
@property (nonatomic, strong)NSString *subname;
@property (nonatomic, strong)NSString *playTime;
@property (nonatomic)int type;
@property (nonatomic)int currentNum;
@property (nonatomic)BOOL isDownloaded;
@property (nonatomic, weak)id <VideoWebViewControllerDelegate>videoWebViewControllerDelegate;
@property (nonatomic, weak)id<DramaDetailViewControllerDelegate>dramaDetailViewControllerDelegate;
@property (nonatomic)BOOL closeAll;

@end
