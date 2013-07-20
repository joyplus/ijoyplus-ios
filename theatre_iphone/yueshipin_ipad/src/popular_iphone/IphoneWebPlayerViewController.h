//
//  IphoneWebPlayerViewController.h
//  yueshipin
//
//  Created by 08 on 13-2-28.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IphoneWebPlayerViewController : UIViewController<UIWebViewDelegate>{

    NSArray *episodesArr_;
    int playNum;
    NSURL *webUrl_;
    UIWebView *webView_;
    NSString *nameStr_;
    int videoType_;
    NSString *prodId_;
    NSNumber *playBackTime_;
    NSString *webUrlSource_;
    BOOL isPlayFromRecord_;
    NSDictionary *continuePlayInfo_;
    BOOL hasVideoUrl_;
}
@property (nonatomic, strong) NSArray *episodesArr;
@property (nonatomic, assign) int playNum;
@property (nonatomic, strong) NSURL *webUrl;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSString *nameStr;
@property (nonatomic, assign) int videoType;
@property (nonatomic, strong) NSString *prodId;
@property (nonatomic, strong) NSNumber *playBackTime;
@property (nonatomic, strong) NSString *webUrlSource;
@property (nonatomic, strong) NSMutableArray *subnameArray;
@property (nonatomic, assign) BOOL isPlayFromRecord;
@property (nonatomic, strong) NSDictionary *continuePlayInfo;
@property (nonatomic, assign) BOOL hasVideoUrl;
-(void)initWebView;

@end
