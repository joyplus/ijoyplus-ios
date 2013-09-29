//
//  YueSouWebViewController.h
//  yueshipin
//
//  Created by huokun on 13-9-9.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YueSouWebViewController : UIViewController <UIWebViewDelegate>
{
    UIWebView * webView;
}

- (id)initWithUrl:(NSString *)url title:(NSString *)title;

@end
