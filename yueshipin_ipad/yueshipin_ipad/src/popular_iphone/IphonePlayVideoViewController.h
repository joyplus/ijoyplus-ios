//
//  IphonePlayVideoViewController.h
//  yueshipin
//
//  Created by 08 on 13-1-29.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IphonePlayVideoViewController : UIViewController{
    UIWebView *webView_;
    NSArray *httpUrlsArr_;
}
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSArray *httpUrlsArr;
@end
