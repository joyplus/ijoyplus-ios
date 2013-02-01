//
//  VideoDetailViewController.h
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-29.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "GenericBaseViewController.h"
#import "SinaWeibo.h"
#import "SlideBaseViewController.h"
#import "McDownload.h"

@protocol VideoDetailViewControllerDelegate <NSObject>

- (void)refreshCommentListView:(int)tableHeight;
- (void)getTopComments:(int)num;
- (void)showSublistView:(int)num;
- (BOOL)downloadDrama:(int)num;
- (BOOL)downloadShow:(int)num;
@end

@protocol DramaDetailViewControllerDelegate <NSObject>

- (void)changePlayingEpisodeBtn:(int)currentNum;
- (void)playNextEpisode;
@end

@interface VideoDetailViewController : GenericBaseViewController  <SinaWeiboDelegate, SinaWeiboRequestDelegate, VideoDetailViewControllerDelegate, UIAlertViewDelegate, McDownloadDelegate,  DramaDetailViewControllerDelegate>{
    SinaWeibo *_sinaweibo;
    NSDictionary *video;
    NSArray *topics;
    NSInteger willPlayIndex;
    McDownload  *downloader;
    NSMutableArray *downloadUrls;
    NSArray *episodeArray;
}
@property (strong, nonatomic)NSString *prodId;
@property (nonatomic, strong)NSString *subname;
@property (assign, nonatomic)int type;
@property (strong, nonatomic)SlideBaseViewController *fromViewController;
- (void)shareBtnClicked;
- (NSString *)parseVideoUrl:(NSDictionary *)tempVideo;
- (void)addListBtnClicked;
- (void)getDownloadUrls:(int)num;
- (void)updateBadgeIcon;
- (void)playVideo:(int)num;
- (BOOL)validadUrl:(NSString *)originalUrl;
@end
