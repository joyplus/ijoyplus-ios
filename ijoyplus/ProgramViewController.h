//
//  ProgramViewController.h
//  ijoyplus
//
//  Created by joyplus1 on 12-10-8.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgramViewController : UIViewController<UIWebViewDelegate>

@property (nonatomic, strong) IBOutlet UIWebView* webView;

@property (nonatomic, strong) NSString *programUrl;

@end
