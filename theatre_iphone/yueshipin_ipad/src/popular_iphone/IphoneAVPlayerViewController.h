//
//  IphoneAVPlayerViewController.h
//  mediaplayer
//
//  Created by 08 on 13-2-26.
//  Copyright (c) 2013年 iplusjoy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CMPopTipView.h"
#import "BundingTVManager.h"
@interface IphoneAVPlayerViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,BundingTVManagerDelegate>{
    UIToolbar *topToolBar_;
    UIToolbar *bottomToolBar_;
    AVPlayerView *avplayerView_;
    NSURL* mURL;
	AVPlayer* mPlayer;
    AVPlayerItem * mPlayerItem;
    BOOL seekToZeroBeforePlay;
    UISlider* mScrubber;
    id mTimeObserver;
    float mRestoreAfterScrubbingRate;
    UIImageView *playCacheView_;
    
    UIButton *selectButton_;
    UIButton *clarityButton_;
    UIButton *playButton_;
    UIButton *pauseButton_;
    UIImageView *bottomView_;
    UILabel *seeTimeLabel_;
    UILabel *totalTimeLable_;
    NSString *nameStr_;
    CMPopTipView *clearBgView_;
    
    NSMutableArray *sortEpisodesArr_;
    NSArray *episodesArr_;
    int playNum;
    
    UITableView *tableList_;
    NSMutableArray *superClearArr;
    NSMutableArray *highClearArr;
    NSMutableArray *plainClearArr;
    
    NSMutableArray *play_index_tag;
    
    int play_url_index;
    
    NSString *local_file_path_;
    BOOL islocalFile_;
    
    int clear_type;
    CMTime lastPlayTime_;
    
    NSTimer *myTimer_;
    
    int videoType_;
    
    MBProgressHUD *myHUD;
    
    NSString *prodId_;
    NSString *webPlayUrl_;
    
    NSTimer *timeLabelTimer_;
    
    MPVolumeView *volumeView_;
    
    UIImageView * ariplayView;
    UIImageView * cloudTVView;
    UILabel *airPlayLabel_;
    
    UIImageView *sourceLogo_;
    
    UILabel *willPlayLabel_;
    
    NSString *workingUrl_;

    UILabel *titleLabel_;
    
    NSString *webUrlSource_;
    
    BOOL isM3u8_;
    
    NSDictionary *continuePlayInfo_;
    
    BOOL isPlayFromRecord_;
    NSString * videoSource_;
    
    BOOL    isPlayOnTV;
    BOOL    isTVReady;
    
    AVMutableAudioMix *audioMix_;
    NSArray * localPlaylist;
}
@property (nonatomic, strong) UIToolbar *topToolBar;
@property (nonatomic, strong) UIToolbar *bottomToolBar;
@property (nonatomic, strong) AVPlayerView *avplayerView;
@property (nonatomic, strong) AVPlayerItem *mPlayerItem;
@property (readwrite, retain, setter=setPlayer:, getter=player) AVPlayer* mPlayer;
@property (nonatomic, strong) NSURL* mURL;
@property (nonatomic, strong) UISlider* mScrubber;
@property (nonatomic, strong) UIButton *selectButton;
@property (nonatomic, strong) UIButton *clarityButton;
@property (nonatomic, strong) UIButton *cloundTVButton;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UILabel *seeTimeLabel;
@property (nonatomic, strong) UILabel *totalTimeLablel;
@property (nonatomic, strong) UIImageView *playCacheView;
@property (nonatomic, strong) UIImageView *bottomView;
@property (nonatomic, strong) CMPopTipView *clearBgView;
@property (nonatomic, strong) NSString *nameStr;
@property (nonatomic, strong) NSArray *episodesArr;
@property (nonatomic, assign) int playNum;
@property (nonatomic, strong) NSMutableArray *sortEpisodesArr;
@property (nonatomic, strong) UITableView *tableList;
@property (nonatomic, strong) NSMutableArray *superClearArr;
@property (nonatomic, strong) NSMutableArray *highClearArr;
@property (nonatomic, strong) NSMutableArray *plainClearArr;
@property (nonatomic, strong) NSMutableArray *play_index_tag;
@property (nonatomic, strong) NSString *local_file_path;
@property (nonatomic, assign)  BOOL islocalFile;
@property (nonatomic, strong) NSTimer *myTimer;
@property (nonatomic, strong) NSTimer *timeLabelTimer;
@property (nonatomic, assign) int videoType;
@property (nonatomic, strong) MBProgressHUD *myHUD;
@property (nonatomic, strong)  NSString *prodId;
@property (nonatomic, strong) NSString *webPlayUrl;
@property (nonatomic, assign) CMTime lastPlayTime;
@property (nonatomic, strong) MPVolumeView *volumeView;
@property (nonatomic, strong) UILabel *airPlayLabel;
@property (nonatomic, strong) UIImageView *sourceLogo;
@property (nonatomic, strong) UILabel *willPlayLabel;
@property (nonatomic, strong) NSString *workingUrl;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) NSString *webUrlSource;
@property (nonatomic, strong) NSMutableArray *subnameArray;
@property (nonatomic, assign)  BOOL isM3u8;
@property (nonatomic, assign) double playDuration;
@property (nonatomic, strong)NSDictionary *continuePlayInfo;
@property (nonatomic, assign) BOOL isPlayFromRecord;
@property (nonatomic, strong) NSArray * localPlaylist;
@property (nonatomic, strong) UIButton * localLogoBtn;
- (void)setURL:(NSURL*)URL;
- (NSURL*)URL;
- (void)clearPlayerData;
@end
