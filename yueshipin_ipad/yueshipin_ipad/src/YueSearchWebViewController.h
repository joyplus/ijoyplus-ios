//
//  YueSearchWebViewController.h
//  yueshipin
//
//  Created by huokun on 13-9-6.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YueSearchWebViewController : UIViewController <UIWebViewDelegate>
{
    UIWebView * webView;
}
- (id)initWithUrl:(NSString *)url;
@end
