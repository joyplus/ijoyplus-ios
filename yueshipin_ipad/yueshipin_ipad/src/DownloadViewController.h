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

@interface DownloadViewController : GenericBaseViewController

- (id)initWithFrame:(CGRect)frame;
@property (nonatomic, weak)id <MenuViewControllerDelegate> menuViewControllerDelegate;
@end
