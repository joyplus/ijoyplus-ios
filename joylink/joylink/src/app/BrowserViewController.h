//
//  GroupImageViewController.h
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-21.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "GenericBaseViewController.h"

@protocol BrowserViewControllerDelegate <NSObject>

- (void)openBookmark:(NSString *)url;

@end

@interface BrowserViewController : GenericBaseViewController<BrowserViewControllerDelegate>

@property (nonatomic, strong) NSDictionary *appInfo;

@end
