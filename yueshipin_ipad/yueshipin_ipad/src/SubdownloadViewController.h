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

@interface SubdownloadViewController : GenericBaseViewController

- (id)initWithFrame:(CGRect)frame;
@property (nonatomic, strong) NSString *titleContent;
@property (nonatomic, strong) NSString *itemId;
@end
