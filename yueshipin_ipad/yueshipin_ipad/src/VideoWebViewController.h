//
//  VideoWebViewController.h
//  yueshipin
//
//  Created by joyplus1 on 13-1-17.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DramaDetailViewController.h"

@protocol VideoWebViewControllerDelegate <NSObject>

- (void)playNextEpisode:(int)nextEpisodeNum;

@end

@interface VideoWebViewController : UIViewController <VideoWebViewControllerDelegate>

@property (nonatomic, strong)NSDictionary *video;
@property (nonatomic, strong)NSMutableArray *videoHttpUrlArray;
@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong) NSMutableArray *videoUrlsArray;
@property (nonatomic, strong)NSString *prodId;
@property (nonatomic, strong)NSArray *subnameArray;
@property (nonatomic)int type;
@property (nonatomic)BOOL isDownloaded;
@property (nonatomic)int currentNum;
@property (nonatomic, strong)NSString *playTime;
@property (nonatomic, weak)id<DramaDetailViewControllerDelegate>dramaDetailViewControllerDelegate;

@end
