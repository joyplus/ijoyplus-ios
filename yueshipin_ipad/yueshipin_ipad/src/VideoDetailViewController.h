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

@protocol VideoDetailViewControllerDelegate <NSObject>

- (void)refreshCommentListView:(int)tableHeight;
- (void)getTopComments:(int)num;
- (void)showSublistView:(int)num;
- (BOOL)downloadDrama:(int)num;
- (BOOL)downloadShow:(int)num;
- (void)showCommentDetail:(NSDictionary *)commentItem;
@end

@protocol DramaDetailViewControllerDelegate <NSObject>

- (void)changePlayingEpisodeBtn:(int)currentNum;
- (void)playNextEpisode;
- (void)hideCloseBtn;
- (void)showCloseBtn;;
@end

@interface VideoDetailViewController : SlideBaseViewController  <SinaWeiboDelegate, SinaWeiboRequestDelegate, VideoDetailViewControllerDelegate, UIAlertViewDelegate,  DramaDetailViewControllerDelegate>{
    SinaWeibo *_sinaweibo;
    NSDictionary *video;
    NSArray *topics;
    NSInteger willPlayIndex;
    NSArray *episodeArray;
    NSString *umengPageName;
}
@property (strong, nonatomic)NSString *prodId;
@property (nonatomic, strong)NSString *subname;
@property (assign, nonatomic)int type;
@property (strong, nonatomic)SlideBaseViewController *fromViewController;
@property (strong, nonatomic)NSMutableArray *mp4DownloadUrls;
@property (strong, nonatomic)NSMutableArray *m3u8DownloadUrls;
@property (strong, nonatomic)NSString *downloadSource;
@property (nonatomic)BOOL canPlayVideo;
- (void)checkCanPlayVideo;
- (BOOL)isDownloadURLExit;
- (void)shareBtnClicked;
- (NSString *)parseVideoUrl:(NSDictionary *)tempVideo;
- (void)addListBtnClicked;
- (void)getDownloadUrls:(int)num;
- (void)updateBadgeIcon;
- (void)playVideo:(int)num;
- (BOOL)validadUrl:(NSString *)originalUrl;
- (NSMutableArray *)tureWangpanDownloadURL:(NSArray *)wangpanHTML;
@end
