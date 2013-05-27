//
//  ReviewViewController.h
//  yueshipin
//
//  Created by 08 on 13-4-7.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReviewViewController : UIViewController
{
    UIWebView   *_webView;
}
@property (nonatomic, strong) NSString *    reqURL;
@end
