//
//  BookMarkViewController.h
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-28.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "GenericBaseViewController.h"
#import "BrowserViewController.h"

@interface BookMarkViewController : GenericBaseViewController

@property (nonatomic, strong)NSString *httpUrl;
@property (nonatomic, weak)id<BrowserViewControllerDelegate>delegate;
@end
