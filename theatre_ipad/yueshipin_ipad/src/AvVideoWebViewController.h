//
//  VideoWebViewController.h
//  yueshipin
//
//  Created by joyplus1 on 13-1-17.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DramaDetailViewController.h"

@protocol AvVideoWebViewControllerDelegate <NSObject>

- (void)playNextEpisode:(int)nextEpisodeNum;
- (void)reshowWebView:(BOOL)fromBaidu;

@end

@interface AvVideoWebViewController : UIViewController <AvVideoWebViewControllerDelegate>

@property (nonatomic, strong)NSDictionary *video;
@property (nonatomic, strong)NSMutableArray *videoHttpUrlArray;
@property (nonatomic, strong)NSString *prodId;
@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *subname;
@property (nonatomic)int type;
@property (nonatomic)BOOL isDownloaded;
@property (nonatomic) BOOL hasVideoUrls;
@property (nonatomic)int currentNum;
@property (nonatomic, strong)NSString *playTime;
@property (nonatomic, assign)BOOL hasVideoUrl;
@property (nonatomic, weak)id<DramaDetailViewControllerDelegate>dramaDetailViewControllerDelegate;

@end
