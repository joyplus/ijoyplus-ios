//
//  DownloadViewController.h
//  yueshipin
//
//  Created by joyplus1 on 12-12-19.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "GenericBaseViewController.h"
#import "MenuViewController.h"
#import "McDownload.h"

@protocol DownloadViewControllerDelegate <NSObject>

- (void)reloadItems;

@end

@interface DownloadViewController : GenericBaseViewController<DownloadViewControllerDelegate, UIGestureRecognizerDelegate>

- (id)initWithFrame:(CGRect)frame;

@end
