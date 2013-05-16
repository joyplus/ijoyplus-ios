//
//  SendWeiboViewController.h
//  yueshipin
//
//  Created by 08 on 13-1-7.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SinaWeibo.h"

@interface SendWeiboViewController : UIViewController<SinaWeiboDelegate,SinaWeiboRequestDelegate>{

    NSDictionary *infoDic_;
    UITextView *textView_;
    SinaWeibo *sinaWeibo_;
}

@property (nonatomic, strong)NSDictionary *infoDic;
@property (nonatomic, strong)UITextView *textView;
@property (nonatomic, strong)SinaWeibo *sinaWeibo;
@end
