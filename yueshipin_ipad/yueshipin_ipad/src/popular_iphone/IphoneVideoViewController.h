//
//  IphoneVideoViewController.h
//  yueshipin
//
//  Created by 08 on 13-1-10.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SinaWeibo.h"
#import "FayeClient.h"
#define DING 1
#define ADDFAV  2
#define UN_ADDFAV 5
#define REPORT 3
#define ADDEXPECT   4
@interface IphoneVideoViewController : UITableViewController<SinaWeiboDelegate,SinaWeiboRequestDelegate,UIActionSheetDelegate>{
    SinaWeibo *_mySinaWeibo;
    NSDictionary *infoDic_;
    NSArray *episodesArr_;
    NSString *prodId_;
    NSString *subName_;
    int type_;
    NSString *name_;
    NSMutableArray *videoUrlsArray_;
    NSMutableArray *httpUrlArray_;
    BOOL isNotification_;
    UISegmentedControl *segmentedControl_;
    NSString *wechatImgStr_;
    int playNum_;
    BOOL isTVReady;
    NSMutableArray *sortEpisodesArr_;
    int sendCount_;
    BOOL haveVideoUrl_;
}
@property (nonatomic, strong) SinaWeibo *mySinaWeibo;
@property (nonatomic, strong) NSDictionary *infoDic;
@property (nonatomic, strong) NSArray *episodesArr;
@property (nonatomic, strong) NSString *prodId;
@property (nonatomic, strong) NSString *subName;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *videoUrlsArray;
@property (nonatomic, strong) NSMutableArray *httpUrlArray;
@property (nonatomic, assign) BOOL isNotification;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) NSString *wechatImgStr;
@property (nonatomic) BOOL canPlayVideo;
@property (nonatomic, assign) BOOL haveVideoUrl;
- (void)showOpSuccessModalView:(float)closeTime with:(int)type;
- (void)showOpFailureModalView:(float)closeTime with:(int)type;
-(void)playVideo:(int)num;
-(BOOL)checkNetWork;
-(NSMutableDictionary *)checkDownloadUrls:(NSDictionary *)infoDic;
- (void)checkCanPlayVideo;
-(void)wechatShare:(int)sence;
@end
