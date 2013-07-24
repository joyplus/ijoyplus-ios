
#import "AVPlayerViewController.h"
#import "AVPlayerView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "EpisodeListViewController.h"
#import "CommonHeader.h"
#import "CommonMotheds.h"
#import "CMPopTipView.h"
#import "ActionUtility.h"

#define TOP_TOOLBAR_HEIGHT 50
#define BOTTOM_TOOL_VIEW_HEIGHT 150
#define BOTTOM_TOOLBAR_HEIGHT 100
#define BUTTON_HEIGHT 50
#define EPISODE_ARRAY_VIEW_TAG 76892367
#define PLAY_CACHE_VIEW 234238494
#define RESOLUTION_KEY @"resolution_key"
#define URL_KEY @"url_key"
#define MAX_EPISODE_NUM 10
#define TRACK_BUTTON_TAG 10013
/* Asset keys */
static NSString * const kTracksKey         = @"tracks";
static NSString * const kPlayableKey		= @"playable";

/* PlayerItem keys */
static NSString * const kStatusKey         = @"status";
static NSString * const k_BufferEmpty       = @"playbackBufferEmpty";
static NSString * const k_ToKeepUp          = @"playbackLikelyToKeepUp";

/* AVPlayer keys */
static NSString * const kRateKey			= @"rate";
static NSString * const kCurrentItemKey	= @"currentItem";


@interface AVPlayerViewController () <UIGestureRecognizerDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) NSURLConnection   *urlConnection;
@property (nonatomic, strong) UIToolbar *topToolbar;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UISlider *volumeSlider;
@property (nonatomic, strong) MPVolumeView *routeBtn;
@property (nonatomic, strong) UILabel *currentPlaybackTimeLabel;
@property (nonatomic, strong) UILabel *totalTimeLabel;
@property (nonatomic, strong) UIButton *volumeBtn;
@property (nonatomic, strong) UIButton *selectButton;
@property (nonatomic, strong) UIButton *qualityBtn;
@property (nonatomic, strong) UIButton *downloadLogoBtn;
@property (nonatomic, strong) UIView *playCacheView;
@property (nonatomic, strong) NSTimer *controlVisibilityTimer;
@property (nonatomic, strong) MBProgressHUD *myHUD;
@property (nonatomic, strong) EpisodeListViewController *episodeListviewController;
@property (nonatomic, strong) CMPopTipView *resolutionPopTipView;
@property (nonatomic, strong) CMPopTipView *changeTrackView ;
@property (nonatomic, strong) UIButton *biaoqingBtn;
@property (nonatomic, strong) UIButton *gaoqingBtn;
@property (nonatomic, strong) UIButton *chaoqingBtn;
@property (nonatomic, strong) UILabel *vidoeTitle;
@property (nonatomic, strong) NSString *airplayDeviceName;
@property (nonatomic, strong) NSString *deviceOutputType;
@property (nonatomic, strong) UIView *applyTvView;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) NSMutableArray *subnameArray;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) NSMutableArray *superClearArr;
@property (nonatomic, strong) NSMutableArray *highClearArr;
@property (nonatomic, strong) NSMutableArray *plainClearArr;
@property (nonatomic, strong) NSMutableArray *combinedArr;
@property (nonatomic, strong) NSString *defaultErrorMessage;
@property (nonatomic) BOOL resolutionInvalid;
@property (nonatomic) int combinedIndex;
@property (nonatomic, strong) NSMutableDictionary *urlArrayDictionary;
@property (atomic, strong) NSURL *workingUrl;
@property (nonatomic, strong) NSString *resolution;
@property (nonatomic) CMTime resolutionLastPlaytime;
@property (nonatomic) int resolutionNum;
@property (nonatomic, strong) UILabel *sourceLabel;
@property (nonatomic, strong) UIImageView *sourceImage;
@property (nonatomic) int tableWidth;
@property (nonatomic) int tableCellHeight;
@property (nonatomic) int maxEpisodeNum;
@property (nonatomic, strong) NSString *umengPageName;
@property (nonatomic) BOOL isFromSelectBtn;
@property (nonatomic) BOOL isAppEnterBackground;
@property BOOL isChangeQuality;
@property (nonatomic, strong) UIButton *trackSelect;
@property (nonatomic) BOOL fromBaidu;
@end

@interface AVPlayerViewController (Player)
- (void)removePlayerTimeObserver;
- (CMTime)playerItemDuration;
- (BOOL)isPlaying;
- (void)playerItemDidReachEnd:(NSNotification *)notification ;
- (void)observeValueForKeyPath:(NSString*) path ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
- (void)prepareToPlayAsset:(AVURLAsset *)asset;
- (void)closeAllTimer;
- (void)getVideoInfo;
- (void)changeTracks:(int)type;

@end

static void *AVPlayerDemoPlaybackViewControllerRateObservationContext = &AVPlayerDemoPlaybackViewControllerRateObservationContext;
static void *AVPlayerDemoPlaybackViewControllerStatusObservationContext = &AVPlayerDemoPlaybackViewControllerStatusObservationContext;
static void *AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext = &AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext;
static void *AVPlayerDemoPlaybackViewControllerCurrentItemBufferingContext = &AVPlayerDemoPlaybackViewControllerCurrentItemBufferingContext;

#pragma mark -
@implementation AVPlayerViewController
@synthesize mPlayer, mPlayerItem, mPlaybackView;
@synthesize mToolbar, topToolbar, mPlayButton, mStopButton, mScrubber, mNextButton, mPrevButton, volumeSlider, mSwitchButton,trackSelect;
@synthesize currentPlaybackTimeLabel, totalTimeLabel, volumeBtn, qualityBtn, selectButton;
@synthesize playCacheView, resolution, videoHttpUrl, nameLabel;
@synthesize type, isDownloaded, currentNum, closeAll;
@synthesize workingUrl, myHUD, bottomView, controlVisibilityTimer;
@synthesize episodeListviewController, subnameArray, lastPlayTime, resolutionLastPlaytime;
@synthesize resolutionPopTipView, biaoqingBtn, chaoqingBtn, gaoqingBtn, routeBtn,changeTrackView;
@synthesize vidoeTitle, videoWebViewControllerDelegate, airplayDeviceName, deviceOutputType;
@synthesize prodId, applyTvView, resolutionNum, tipLabel, video, subname, name;
@synthesize superClearArr, plainClearArr, highClearArr, urlArrayDictionary;
@synthesize combinedArr, combinedIndex, videoUrl, defaultErrorMessage;
@synthesize sourceImage, sourceLabel, resolutionInvalid, isFromSelectBtn;
@synthesize tableCellHeight, tableWidth, maxEpisodeNum, umengPageName,urlConnection,isAppEnterBackground, videoFormat;
@synthesize m3u8Duration,isChangeQuality;
@synthesize localPlaylists;
@synthesize downloadLogoBtn, fromBaidu;
#pragma mark
#pragma mark View Controller

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
		mPlayer = nil;
		[self setWantsFullScreenLayout:YES];
	}
	
	return self;
}

- (id)init
{
    self = [super init];
    mPlayer = nil;
    [self setWantsFullScreenLayout:YES];
    return self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)dealloc
{
    sourceLabel = nil;
    sourceImage = nil;
    superClearArr = nil;
    plainClearArr = nil;
    highClearArr = nil;
    
    topToolbar = nil;
    nameLabel = nil;
    combinedArr = nil;
    videoUrl = nil;
    defaultErrorMessage = nil;
    
    self.mPlaybackView = nil;
    self.mToolbar = nil;
    self.mPlayButton = nil;
    self.mStopButton = nil;
    self.mScrubber = nil;
    
    topToolbar = nil;
    bottomView = nil;
    volumeSlider = nil;
    routeBtn = nil;
    currentPlaybackTimeLabel = nil;
    
    totalTimeLabel = nil;
    volumeBtn = nil;
    selectButton = nil;
    qualityBtn = nil;
    playCacheView = nil;
    
    controlVisibilityTimer = nil;
    myHUD = nil;
    episodeListviewController = nil;
    resolutionPopTipView = nil;
    biaoqingBtn = nil;
    
    gaoqingBtn = nil;
    chaoqingBtn = nil;
    vidoeTitle = nil;
    airplayDeviceName = nil;
    deviceOutputType = nil;
    
    applyTvView = nil;
    tipLabel = nil;
    subnameArray = nil;
    prodId = nil;
    name = nil;
    
    subname = nil;
    video = nil;
    videoHttpUrl = nil;
    //self.URL = nil;
    mPlaybackView = nil;
    
    mToolbar = nil;
    mPrevButton = nil;
    mNextButton = nil;
    mSwitchButton = nil;
    umengPageName = nil;
    
    resolution = nil;
    workingUrl = nil;
    urlArrayDictionary = nil;
    urlConnection = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    self.view.backgroundColor = [UIColor blackColor];
    //isAppEnterBackground = NO;
    isClosed = NO;
    if (type == 1) {
        umengPageName = MOVIE_PLAY;
    } else if(type == 2 || type == 131){
        umengPageName = TV_PLAY;
    } else {
        umengPageName = SHOW_PLAY;
    }
    defaultErrorMessage = @"即将使用网页播放";
    resolution = GAO_QING;
    [self showPlayVideoView];
    
    if (video) {
        [self getSubname:[video objectForKey:@"episodes"]];
    }
    [self customizeTopToolbar];
    [self customizeBottomToolbar];
    
    if (isDownloaded) {
        [self getVideoInfo];
        [self loadLastPlaytime];
        if ([videoFormat isEqualToString:@"m3u8"]) {
            [[AppDelegate instance] startHttpServer];
            workingUrl = [NSURL URLWithString: videoUrl];
        } else {
            workingUrl = [[NSURL alloc] initFileURLWithPath:videoUrl];
        }
        [self setURL:workingUrl];
        [self showToolview];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wifiNotAvailable:) name:WIFI_IS_NOT_AVAILABLE object:nil];
        [self playVideo];
    }
    
    tableCellHeight = EPISODE_TABLE_CELL_HEIGHT;
    tableWidth = EPISODE_TABLE_WIDTH;
    maxEpisodeNum = MAX_EPISODE_NUM;
    if (type == 3) {
        tableCellHeight = EPISODE_TABLE_CELL_HEIGHT * 1.1;
        tableWidth = EPISODE_TABLE_WIDTH * 1.2;
        maxEpisodeNum = 8;
    }
    episodeListviewController = [[EpisodeListViewController alloc]init];
    [self addChildViewController:episodeListviewController];
    episodeListviewController.type = self.type;
    episodeListviewController.delegate = self;
    episodeListviewController.view.tag = EPISODE_ARRAY_VIEW_TAG;
    episodeListviewController.table.frame = CGRectMake(0, 0, tableWidth, 0);
    episodeListviewController.view.frame = CGRectMake(topToolbar.frame.size.width - 20 - tableWidth, TOP_TOOLBAR_HEIGHT + 24, tableWidth, 0);
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showToolview)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.delegate = self;
    tapRecognizer.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:tapRecognizer];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    panGesture.delegate = self;
    [self.view addGestureRecognizer:panGesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(systemVolumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:APPLICATION_DID_ENTER_BACKGROUND_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:APPLICATION_DID_BECOME_ACTIVE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChanged:) name:NETWORK_CHANGED object:nil];
}

- (void)viewDidAppear: (BOOL) animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([videoFormat isEqualToString:@"m3u8"]) {
        [[AppDelegate instance] startHttpServer];
    }
    [MobClick beginLogPageView:umengPageName];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
	[mPlayer pause];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    if ([videoFormat isEqualToString:@"m3u8"]) {
        [[AppDelegate instance] stopHttpServer];
    }
    [MobClick endLogPageView:umengPageName];
}

-(BOOL)shouldAutorotate {
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}


- (void)playVideo
{
    if (video == nil) {
        [self showPlayCacheView];
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: self.prodId, @"prod_id", nil];
        [[AFServiceAPIClient sharedClient] getPath:kPathProgramView parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            NSString *responseCode = [result objectForKey:@"res_code"];
            if(responseCode == nil){
                if (type == 1) {
                    video = (NSDictionary *)[result objectForKey:@"movie"];
                } else if (type == 2 || type == 131){
                    video = (NSDictionary *)[result objectForKey:@"tv"];
                } else if (type == 3){
                    video = (NSDictionary *)[result objectForKey:@"show"];
                }
//                [self parseVideoData:[video objectForKey:@"episodes"]];
//                [self parseCurrentNum];
//                [self parseResolutionNum];
//                [self sendRequest];
                if (video) {
                    [self getSubname:[video objectForKey:@"episodes"]];
                }
                dispatch_async( dispatch_queue_create("newQueue", NULL), ^{
                    [self parseCurrentNum];
                    [self parseVideoData:[video objectForKey:@"episodes"]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self parseResolutionNum];
                        [self sendRequest];
                    });
                });
            } else {
                [UIUtility showSystemError:self.view];
            }
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            
            [UIUtility showSystemError:self.view];
        }];
    } else {
        dispatch_async( dispatch_queue_create("newQueue", NULL), ^{
              [self parseVideoData:[video objectForKey:@"episodes"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self parseResolutionNum];
                [self showPlayCacheView];
                [self sendRequest];
            });
        });
    }
    
}

-(void)getSubname:(NSArray *)episodeArray{
    if (subnameArray == nil) {
        subnameArray = [[NSMutableArray alloc]initWithCapacity:10];
        for (NSDictionary *oneEpisode in episodeArray) {
            NSString *tempName = [NSString stringWithFormat:@"%@", [oneEpisode objectForKey:@"name"]];
            [subnameArray addObject:tempName];
        }
    }
    if (video != nil) {
        name = [video objectForKey:@"name"];
        if ([StringUtility stringIsEmpty:subname] && self.currentNum < subnameArray.count) {
            subname = [subnameArray objectAtIndex:self.currentNum];
        }
    }
}
- (void)parseVideoData:(NSArray *)episodeArray
{
    // 视频地址
    NSDictionary *episodesInfo = [episodeArray objectAtIndex:currentNum];
    NSArray *down_load_urls = [episodesInfo objectForKey:@"down_urls"];
    NSArray * video_urls = [episodesInfo objectForKey:@"video_urls"];
    
    NSMutableArray *tempSortArr = [NSMutableArray arrayWithCapacity:5];
    for (NSDictionary *dic in down_load_urls) {
        fromBaidu = NO;
        NSMutableDictionary *temp_dic = [NSMutableDictionary dictionaryWithDictionary:dic];
        NSString *source_str = [temp_dic objectForKey:@"source"];
        if ([source_str isEqualToString:@"wangpan"]) {
            [temp_dic setObject:@"0.1" forKey:@"level"];
        } else if ([source_str isEqualToString:@"le_tv_fee"]) {
            [temp_dic setObject:@"0.2" forKey:@"level"];
            if (isResetLetvData_) {
                NSString *htmlUrl = nil;
                for (NSDictionary *dd in [episodesInfo objectForKey:@"video_urls"]) {
                    if ([[dd objectForKey:@"source"] isEqualToString:@"le_tv_fee"]) {
                        htmlUrl = [dd objectForKey:@"url"];
                        break;
                    }
                }
                if (htmlUrl != nil) {
                    NSString *subnameStr = [episodesInfo objectForKey:@"name"];
                    NSDictionary *resultDic = [CommonMotheds getLetvRealUrlWithHtml:htmlUrl prodId:prodId subname:subnameStr];
                    if (resultDic != nil) {
                       [temp_dic setObject:[[resultDic objectForKey:@"down_urls"] objectForKey:@"urls"] forKey:@"urls"];
                    }
                }
            }
        
        } else if ([source_str isEqualToString:@"letv"]) {
            [temp_dic setObject:@"1" forKey:@"level"];
            
            if (isResetLetvData_) {
                NSString *htmlUrl = nil;
                for (NSDictionary *dd in [episodesInfo objectForKey:@"video_urls"]) {
                    if ([[dd objectForKey:@"source"] isEqualToString:@"letv"]) {
                        htmlUrl = [dd objectForKey:@"url"];
                        break;
                    }
                }
                if (htmlUrl != nil) {
                    NSString *subnameStr = [episodesInfo objectForKey:@"name"];
                    NSDictionary *resultDic = [CommonMotheds getLetvRealUrlWithHtml:htmlUrl prodId:prodId subname:subnameStr];
                    if (resultDic != nil) {
                        [temp_dic setObject:[[resultDic objectForKey:@"down_urls"] objectForKey:@"urls"] forKey:@"urls"];
                    }
                }
            }
        } else if ([source_str isEqualToString:@"fengxing"]){
            [temp_dic setObject:@"2" forKey:@"level"];
        } else if ([source_str isEqualToString:@"qiyi"]){
            [temp_dic setObject:@"3" forKey:@"level"];
        } else if ([source_str isEqualToString:@"youku"]){
            [temp_dic setObject:@"4" forKey:@"level"];
        } else if ([source_str isEqualToString:@"sinahd"]){
            [temp_dic setObject:@"5" forKey:@"level"];
        } else if ([source_str isEqualToString:@"sohu"]){
            [temp_dic setObject:@"6" forKey:@"level"];
        } else if ([source_str isEqualToString:@"56"]){
            [temp_dic setObject:@"7" forKey:@"level"];
        } else if ([source_str isEqualToString:@"qq"]){
            [temp_dic setObject:@"8" forKey:@"level"];
        } else if ([source_str isEqualToString:@"pptv"]){
            [temp_dic setObject:@"9" forKey:@"level"];
        } else if ([source_str isEqualToString:@"m1905"]){
            [temp_dic setObject:@"10" forKey:@"level"];
        }else if ([source_str isEqualToString:@"pps"]){
            [temp_dic setObject:@"11" forKey:@"level"];
        }else if ([source_str isEqualToString:@"baidu_wangpan"]){
            fromBaidu = YES;
            [temp_dic setObject:@"9" forKey:@"level"];
            NSArray * dURL = [temp_dic objectForKey:@"urls"];
            if (0 == dURL.count)
                return;
            NSMutableArray *newUrls = [NSMutableArray arrayWithCapacity:5];
            for (NSDictionary *oneDic in dURL) {
                NSString * downloadURL = [CommonMotheds getDownloadURLWithHTML:[oneDic objectForKey:@"url"]];
                NSMutableDictionary * newDic = [NSMutableDictionary dictionary];
                if (nil != downloadURL)
                {
                    [newDic setObject:downloadURL forKey:@"url"];
                    [newDic setObject:[oneDic objectForKey:@"file"] forKey:@"file"];
                    [newDic setObject:[oneDic objectForKey:@"type"] forKey:@"type"];
                    [newUrls addObject:newDic];
                }
            }
            [temp_dic setObject:newUrls forKey:@"urls"];
        }
        else {
            [temp_dic setObject:@"100" forKey:@"level"];
        }
        [tempSortArr addObject:temp_dic];
    }
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"level" ascending:YES comparator:cmpStr];
    NSMutableArray *sortEpisodesArr_ = [NSMutableArray arrayWithArray:[tempSortArr sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]]];
    
    if (superClearArr == nil) {  //存放某一剧集所有来源的超清的地址;
        superClearArr = [NSMutableArray arrayWithCapacity:5];
    }
    [superClearArr removeAllObjects];
    
    if (highClearArr == nil) {  //存放某一剧集所有来源的高清的地址;
        highClearArr = [NSMutableArray arrayWithCapacity:5];
    }
    [highClearArr removeAllObjects];
    
    if (plainClearArr == nil) {  //存放某一剧集所有来源的标清的地址;
        plainClearArr = [NSMutableArray arrayWithCapacity:5];
    }
    [plainClearArr removeAllObjects];
    
    for (NSDictionary *url_info_dic in sortEpisodesArr_) {
        NSArray *urls = [url_info_dic objectForKey:@"urls"];
        NSString * level = [url_info_dic objectForKey:@"level"];
        NSString *source_str = [url_info_dic objectForKey:@"source"];
        
        //若数据来自网盘，重新设置source来源
        if ([level isEqualToString:@"100"]
            && [source_str isEqualToString:@"wangpan"])
        {
            NSDictionary * videoDic = nil;
            if (nil != video_urls)
            {
                //取出第一个数据
                videoDic = [video_urls objectAtIndex:0];
            }
            source_str = [videoDic objectForKey:@"source"];
        }
        
        
        for (NSDictionary *url_dic in urls)  {
            NSString *type_str = [[url_dic objectForKey:@"type"] lowercaseString];
            NSString *url_str = [url_dic objectForKey:@"url"];
            NSString *file_str = [url_dic objectForKey:@"file"];
            NSDictionary *urlDic = [NSDictionary dictionaryWithObjectsAndKeys:source_str, @"source", url_str, @"url", file_str, @"file", nil];
            if ([type_str isEqualToString:CHAO_QING]) {
                [superClearArr addObject:urlDic];
            }
            else if ([type_str isEqualToString:GAO_QING]){
                [highClearArr addObject:urlDic];
            }
            else if ([type_str isEqualToString:BIAO_QING]||[type_str isEqualToString:LIU_CHANG]){
                [plainClearArr addObject:urlDic];
            }
        }
    }
    if (urlArrayDictionary == nil) {
        urlArrayDictionary = [[NSMutableDictionary alloc]initWithCapacity:3];
    }
    [urlArrayDictionary removeAllObjects];
    [urlArrayDictionary setValue:highClearArr forKey:GAO_QING];
    [urlArrayDictionary setValue:plainClearArr forKey:BIAO_QING];
    [urlArrayDictionary setValue:superClearArr forKey:CHAO_QING];
    
    [self loadLastPlaytime];
    if (combinedArr == nil) {
        combinedArr = [[NSMutableArray alloc]initWithCapacity:10];
    }
    [combinedArr removeAllObjects];
    combinedIndex = 0;
    [self createCombinedArray:GAO_QING urlArray:highClearArr];
    [self createCombinedArray:CHAO_QING urlArray:superClearArr];
    [self createCombinedArray:BIAO_QING urlArray:plainClearArr];
}

- (void)createCombinedArray:(NSString *)resolutionKey urlArray:(NSMutableArray *)urlArray
{
    for (NSDictionary *urlDic in urlArray) {
        NSDictionary *tempDic = [NSDictionary dictionaryWithObjectsAndKeys:resolutionKey, RESOLUTION_KEY, urlDic, URL_KEY, nil];
        [combinedArr addObject:tempDic];
    }
}

- (void)parseCurrentNum
{
    if (subnameArray.count > 0) {
        //currentNum = [subnameArray indexOfObject:subname];
        for (NSString *nameStr in subnameArray) {
            if ([nameStr hasPrefix:subname]||[subname hasPrefix:nameStr]) {
                currentNum = [subnameArray indexOfObject:nameStr];
                break;
            }
        }
        if (currentNum < 0 || currentNum >= subnameArray.count) {
            currentNum = 0;
        }
    }
}

- (void)parseResolutionNum
{
    resolutionNum = 0;
    NSArray *temp = [urlArrayDictionary objectForKey:BIAO_QING];
    if (temp.count > 0) {
        resolutionNum++;
        resolution = BIAO_QING;
    }
    temp = [urlArrayDictionary objectForKey:CHAO_QING];
    if (temp.count > 0) {
        resolutionNum++;
        resolution = CHAO_QING;
    }
    temp = [urlArrayDictionary objectForKey:GAO_QING];
    if (temp.count > 0) {
        resolutionNum++;
        resolution = GAO_QING;
    }
    if (resolutionNum > 1 && !isDownloaded)
    {
        [qualityBtn setHidden:NO];
    }
    
}

- (void)sendRequest
{
    if (combinedIndex < combinedArr.count) {
        NSDictionary *tempDic = [combinedArr objectAtIndex:combinedIndex];
        resolution = [tempDic objectForKey:RESOLUTION_KEY];
        NSDictionary *urlDic = [tempDic objectForKey:URL_KEY];
        NSString *url = [urlDic objectForKey:@"url"];
        //        url = @"http://gslb.tv.sohu.com/live?cid=8&type=hls";
        NSString *formattedUrl = url;
        if([url rangeOfString:@"{now_date}"].location != NSNotFound){
            int nowDate = [[NSDate date] timeIntervalSince1970];
            formattedUrl = [url stringByReplacingOccurrencesOfString:@"{now_date}" withString:[NSString stringWithFormat:@"%i", nowDate]];
        }
        NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:formattedUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5];
        self.urlConnection = [NSURLConnection connectionWithRequest:request delegate:self];
    } else {
        [myHUD hide:NO];
        tipLabel.text = defaultErrorMessage;
        resolutionInvalid = YES;
        if ([defaultErrorMessage hasPrefix:@"即"]) {
            [self performSelector:@selector(showWebView) withObject:nil afterDelay:2];
            [self reportErrorVideo];
        } else {
            if (!isDownloaded)
            {
                qualityBtn.hidden = NO;
                downloadLogoBtn.hidden = YES;
            }
        }
    }
}

-(void)proceedForLetv{
    NSDictionary *tempDic = [combinedArr objectAtIndex:combinedIndex];
    resolution = [tempDic objectForKey:RESOLUTION_KEY];
    NSDictionary *urlDic = [tempDic objectForKey:URL_KEY];
    if ([[urlDic objectForKey:@"source"]isEqualToString:@"le_tv_fee"]||[[urlDic objectForKey:@"source"]isEqualToString:@"letv"]) {
        isResetLetvData_ = YES;
        dispatch_async( dispatch_queue_create("newQueue", NULL), ^{
            [self parseVideoData:[video objectForKey:@"episodes"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self parseResolutionNum];
                [self showPlayCacheView];
                [self sendRequest];
            });
        });
    }
    else{
         combinedIndex++;
        [self sendRequest];
    }
}

- (void)showWebView
{
    [self updateWatchRecord];
    [mStopButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    [self saveLastPlaytime];
    mPlayer = nil;
    [controlVisibilityTimer invalidate];
    if (type == 2 || type == 3 || type == 131) {
        [videoWebViewControllerDelegate playNextEpisode:currentNum];
    }
    if (closeAll) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [videoWebViewControllerDelegate reshowWebView:fromBaidu];
        [self.navigationController popViewControllerAnimated:NO];
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"error url");
    [connection cancel];
    //如果所有的视频地址都无效，则播放网页地址
//    combinedIndex++;
//    [self sendRequest];
    [self proceedForLetv];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
    NSDictionary *headerFields = [(NSHTTPURLResponse *)response allHeaderFields];
    NSString *contentLength = [NSString stringWithFormat:@"%@", [headerFields objectForKey:@"Content-Length"]];
    NSString *contentType = [NSString stringWithFormat:@"%@", [headerFields objectForKey:@"Content-Type"]];
    int status_Code = HTTPResponse.statusCode;
    if (combinedIndex < combinedArr.count) {
        NSDictionary *tempDic = [combinedArr objectAtIndex:combinedIndex];
        NSString *fileType = [[tempDic objectForKey:URL_KEY] objectForKey:@"file"];
        NSString *source = [[tempDic objectForKey:URL_KEY] objectForKey:@"source"];
        if (status_Code >= 200 && status_Code <= 299){
            if ([source isEqualToString:@"sohu"] && ([fileType isEqualToString:@"m3u8"] || [fileType isEqualToString:@"m3u"])) {
                NSLog(@"working = %@", connection.originalRequest.URL);
                workingUrl = connection.originalRequest.URL;
                [self performSelectorOnMainThread:@selector(setURL:) withObject:workingUrl waitUntilDone:NO];
            } else if (status_Code >= 200 && status_Code <= 299 && ![contentType hasPrefix:@"text/html"] && contentLength.intValue > 100) {
                NSLog(@"working = %@", connection.originalRequest.URL);
                workingUrl = connection.originalRequest.URL;
                [self performSelectorOnMainThread:@selector(setURL:) withObject:workingUrl waitUntilDone:NO];
            } else {
//                combinedIndex++;
//                [self sendRequest];
                [self proceedForLetv];
            }
        } else {
//            combinedIndex++;
//            [self sendRequest];
            [self proceedForLetv];
        }
    }
    [connection cancel];
}

- (BOOL) canBecomeFirstResponder {return YES;}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]){
        return NO;
    } else if ([NSStringFromClass([touch.view class]) isEqualToString:@"UIButton"]){
        [self resetControlVisibilityTimer];
        return NO;
    } else if ([NSStringFromClass([touch.view class]) isEqualToString:@"MPButton"]){
        [self resetControlVisibilityTimer];
        return NO;
    } else if ([NSStringFromClass([touch.view class]) isEqualToString:@"UIToolbar"]){
        [self resetControlVisibilityTimer];
        return NO;
    } else if ([NSStringFromClass([touch.view class]) isEqualToString:@"UISlider"]){
        [self resetControlVisibilityTimer];
        return NO;
    }else {
        return YES;
    }
}

- (void)customizeTopToolbar
{
    topToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.height, TOP_TOOLBAR_HEIGHT)];
    
    [topToolbar setBackgroundImage:[[UIImage imageNamed:@"top_toolbar_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 5, 5, 5)] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    [self.view addSubview:topToolbar];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(20, 7, 58, 38);
    [closeButton setBackgroundImage:[UIImage imageNamed:@"back_bt"] forState:UIControlStateNormal];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"back_bt_pressed"] forState:UIControlStateHighlighted];
    [closeButton addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
    [topToolbar addSubview:closeButton];
    
    sourceLabel = [[UILabel alloc]initWithFrame:CGRectMake(closeButton.frame.origin.x + closeButton.frame.size.width + 20, 10, 40, 30)];
    [sourceLabel setFont:[UIFont systemFontOfSize:15]];
    [sourceLabel setBackgroundColor:[UIColor clearColor]];
    [sourceLabel setText:@"来源: "];
    [sourceLabel sizeToFit];
    sourceLabel.center = CGPointMake(sourceLabel.center.x, TOP_TOOLBAR_HEIGHT/2);
    [sourceLabel setHidden:YES];
    [sourceLabel setTextColor:[UIColor colorWithRed:228/255.0 green:228/255.0 blue:228/255.0 alpha:1]];
    [topToolbar addSubview:sourceLabel];
    
    sourceImage = [[UIImageView alloc]initWithFrame:CGRectZero];
    sourceImage.image = [UIImage imageNamed:@"play_pic"];
    [sourceImage setHidden:YES];
    sourceImage.center = CGPointMake(sourceImage.center.x, TOP_TOOLBAR_HEIGHT/2);
    [topToolbar addSubview:sourceImage];
    
    vidoeTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 600, TOP_TOOLBAR_HEIGHT)];
    vidoeTitle.center = CGPointMake(topToolbar.center.x, TOP_TOOLBAR_HEIGHT/2);
    if (type == 2 || type == 131) {
        vidoeTitle.text = [NSString stringWithFormat:@"%@：第%@集", name, subname];
    } else if(type == 3){
        vidoeTitle.text = [NSString stringWithFormat:@"%@", subname];
    } else {
        vidoeTitle.text = name;
    }
    vidoeTitle.font = [UIFont boldSystemFontOfSize:18];
    vidoeTitle.textColor = [UIColor colorWithRed:228/255.0 green:228/255.0 blue:228/255.0 alpha:1];
    vidoeTitle.backgroundColor = [UIColor clearColor];
    vidoeTitle.textAlignment = UITextAlignmentCenter;
    [topToolbar addSubview:vidoeTitle];
    
    if ((type == 2 || type == 3 || type == 131)) {
        selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        selectButton.frame = CGRectMake(topToolbar.frame.size.width - 20 - 100, 0, 100, BUTTON_HEIGHT);
        [selectButton setBackgroundImage:[UIImage imageNamed:@"select_bt"] forState:UIControlStateNormal];
        [selectButton setBackgroundImage:[UIImage imageNamed:@"select_bt_pressed"] forState:UIControlStateHighlighted];
        [selectButton addTarget:self action:@selector(showEpisodeListView) forControlEvents:UIControlEventTouchUpInside];
        [topToolbar addSubview:selectButton];
    }
}

- (void)customizeBottomToolbar
{
    bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.width - BOTTOM_TOOL_VIEW_HEIGHT, self.view.frame.size.height, BOTTOM_TOOL_VIEW_HEIGHT)];
    bottomView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bottomView];
    
    UIImageView *bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, bottomView.frame.size.width, BOTTOM_TOOL_VIEW_HEIGHT - BOTTOM_TOOLBAR_HEIGHT)];
    bgImageView.image = [[UIImage imageNamed:@"slider_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    [bottomView addSubview:bgImageView];
    
    currentPlaybackTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, 80, 30)];
    [currentPlaybackTimeLabel setBackgroundColor:[UIColor clearColor]];
    [currentPlaybackTimeLabel setFont:[UIFont boldSystemFontOfSize:15]];
    currentPlaybackTimeLabel.textColor = [UIColor whiteColor];
    currentPlaybackTimeLabel.text = @"00:00:00";
    [bottomView addSubview:currentPlaybackTimeLabel];
    
    totalTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(bottomView.frame.size.width - 80 - 20, 10, 80, 30)];
    [totalTimeLabel setTextAlignment:NSTextAlignmentRight];
    [totalTimeLabel setBackgroundColor:[UIColor clearColor]];
    [totalTimeLabel setFont:[UIFont boldSystemFontOfSize:15]];
    totalTimeLabel.textColor = [UIColor whiteColor];
    totalTimeLabel.text = @"";
    [bottomView addSubview:totalTimeLabel];
    
    mScrubber = [[UISlider alloc]initWithFrame:CGRectMake(0, 0, bottomView.frame.size.width - currentPlaybackTimeLabel.frame.size.width * 2 - 60 , 23)];
    [mScrubber setEnabled:NO];
    mScrubber.center = CGPointMake(bottomView.center.x, (BOTTOM_TOOL_VIEW_HEIGHT - BOTTOM_TOOLBAR_HEIGHT)/2 + 1);
    UIImage *minImage = [[UIImage imageNamed:@"progress_slider_min"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    float ver = [[[UIDevice currentDevice] systemVersion] floatValue];
    UIImage *maxImage;
    if (ver >= 6.0){
        maxImage = [[UIImage imageNamed:@"progress_slider_max"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
    } else {
        maxImage = [[UIImage imageNamed:@"progress_slider_max"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    }
    [mScrubber setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [mScrubber setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [mScrubber setThumbImage: [UIImage imageNamed:@"progress_thumb"] forState:UIControlStateNormal];
    [mScrubber setThumbImage:[UIImage imageNamed:@"progress_thumb_pressed"] forState:UIControlStateHighlighted];
    [mScrubber addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchCancel];
    [mScrubber addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchUpInside];
    [mScrubber addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchUpOutside];
    [mScrubber addTarget:self action:@selector(beginScrubbing:) forControlEvents:UIControlEventTouchDown];
    [mScrubber addTarget:self action:@selector(scrub:) forControlEvents:UIControlEventTouchDragInside];
    [mScrubber addTarget:self action:@selector(scrub:) forControlEvents:UIControlEventValueChanged];
    [bottomView addSubview:mScrubber];
    
    
    mToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0.0f, BOTTOM_TOOL_VIEW_HEIGHT - BOTTOM_TOOLBAR_HEIGHT, bottomView.frame.size.width, BOTTOM_TOOLBAR_HEIGHT)];
    [mToolbar setBackgroundImage:[UIUtility createImageWithColor:[UIColor colorWithRed:10/255.0 green:10/255.0 blue:10/255.0 alpha:0.9] ] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    [bottomView addSubview:mToolbar];
    
    mSwitchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    mSwitchButton.frame = CGRectMake(20, 25, 55, BUTTON_HEIGHT);
    [mSwitchButton setBackgroundImage:[UIImage imageNamed:@"full_bt"] forState:UIControlStateNormal];
    [mSwitchButton setBackgroundImage:[UIImage imageNamed:@"full_bt_pressed"] forState:UIControlStateHighlighted];
    [mSwitchButton addTarget:self action:@selector(switchBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [mToolbar addSubview:mSwitchButton];
    
    routeBtn = [[MPVolumeView alloc] initWithFrame:CGRectMake(mSwitchButton.frame.origin.x + mSwitchButton.frame.size.width + 20, 25, 55, BUTTON_HEIGHT)];
    [routeBtn setBackgroundColor:[UIColor clearColor]];
    [routeBtn setShowsVolumeSlider:NO];
    [routeBtn setShowsRouteButton:YES];
    for (UIView *asubview in routeBtn.subviews) {
        if ([NSStringFromClass(asubview.class) isEqualToString:@"MPButton"]) {
            airPlayButton_ = (UIButton *)asubview;
            airPlayButton_.frame = CGRectMake(0, 0, 55, BUTTON_HEIGHT);
            [airPlayButton_ setImage:nil forState:UIControlStateNormal];
            [airPlayButton_ setImage:nil forState:UIControlStateHighlighted];
            [airPlayButton_ setImage:nil forState:UIControlStateSelected];
            [airPlayButton_ setBackgroundImage:[UIImage imageNamed:@"route_bt"] forState:UIControlStateNormal];
            [airPlayButton_ setBackgroundImage:[UIImage imageNamed:@"route_bt_light"] forState:UIControlStateHighlighted];
            break;
        }
    }
    
    if(!(isDownloaded && [videoFormat isEqualToString:@"m3u8"])){
     [mToolbar addSubview:routeBtn];
     [self disableAirPlayButton];
    }
    
    NSString *userId = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:@"kUserId"];
    NSDictionary * data = (NSDictionary *)[[ContainerUtility sharedInstance] attributeForKey:[NSString stringWithFormat:@"%@_isBunding",userId]];
    NSNumber * isbunding = [data objectForKey:KEY_IS_BUNDING];
    if ([isbunding boolValue])
    {
        
        if (![BundingTVManager shareInstance].isConnected)
        {
            NSString * sendChannel = [NSString stringWithFormat:@"/screencast/CHANNEL_TV_%@",[data objectForKey:KEY_MACADDRESS]];
            [[BundingTVManager shareInstance] connecteServerWithChannel:sendChannel];
        }
        
    [BundingTVManager shareInstance].sendClient.delegate = self;
    cloudPlayButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
    cloudPlayButton_.frame = CGRectMake(routeBtn.frame.origin.x+routeBtn.frame.size.width+20, 25, 55, BUTTON_HEIGHT);
    [cloudPlayButton_ setBackgroundImage:[UIImage imageNamed:@"ipad_cloud_tv"] forState:UIControlStateNormal];
    [cloudPlayButton_ setBackgroundImage:[UIImage imageNamed:@"ipad_cloud_tv_f"] forState:UIControlStateHighlighted];
     [cloudPlayButton_ setBackgroundImage:[UIImage imageNamed:@"ipad_cloud_tv_f"] forState:UIControlStateSelected];
        [cloudPlayButton_ addTarget:self action:@selector(couldPlayButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    cloudPlayButton_.enabled = NO;
    [mToolbar addSubview:cloudPlayButton_];
    }
    
    mPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    mPlayButton.frame = CGRectMake(0, 0, 55, BUTTON_HEIGHT);
    [mPlayButton setHidden:YES];
    mPlayButton.center = CGPointMake(bottomView.frame.size.width/2, BOTTOM_TOOLBAR_HEIGHT/2);
    [mPlayButton setBackgroundImage:[UIImage imageNamed:@"play_bt"] forState:UIControlStateNormal];
    [mPlayButton setBackgroundImage:[UIImage imageNamed:@"play_bt_pressed"] forState:UIControlStateHighlighted];
    [mPlayButton addTarget:self action:@selector(playBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [mToolbar addSubview:mPlayButton];
    
    mStopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    mStopButton.frame = mPlayButton.frame;
    [mStopButton setBackgroundImage:[UIImage imageNamed:@"pause_bt"] forState:UIControlStateNormal];
    [mStopButton setBackgroundImage:[UIImage imageNamed:@"pause_bt_pressed"] forState:UIControlStateHighlighted];
    [mStopButton addTarget:self action:@selector(stopBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [mToolbar addSubview:mStopButton];
    
    mPrevButton = [UIButton buttonWithType:UIButtonTypeCustom];
    mPrevButton.frame = CGRectMake(mPlayButton.frame.origin.x - mPlayButton.frame.size.width - 30, mPlayButton.frame.origin.y, mPlayButton.frame.size.width, mPlayButton.frame.size.height);
    [mPrevButton setBackgroundImage:[UIImage imageNamed:@"prev_bt"] forState:UIControlStateNormal];
    [mPrevButton setBackgroundImage:[UIImage imageNamed:@"prev_bt_pressed"] forState:UIControlStateHighlighted];
    [mPrevButton addTarget:self action:@selector(prevBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [mToolbar addSubview:mPrevButton];
    
    mNextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    mNextButton.frame = CGRectMake(mPlayButton.frame.origin.x + mPlayButton.frame.size.width + 30, mPlayButton.frame.origin.y, mPlayButton.frame.size.width, mPlayButton.frame.size.height);
    [mNextButton setBackgroundImage:[UIImage imageNamed:@"next_bt"] forState:UIControlStateNormal];
    [mNextButton setBackgroundImage:[UIImage imageNamed:@"next_bt_pressed"] forState:UIControlStateHighlighted];
    [mNextButton addTarget:self action:@selector(nextBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [mToolbar addSubview:mNextButton];
    
    volumeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    volumeBtn.frame = CGRectMake(mNextButton.frame.origin.x + mNextButton.frame.size.width + 40, mPlayButton.frame.origin.y, 27, BUTTON_HEIGHT);
    volumeBtn.tag = 9877;
    [volumeBtn setBackgroundImage:[UIImage imageNamed:@"volume_bt"] forState:UIControlStateNormal];
    [volumeBtn setBackgroundImage:[UIImage imageNamed:@"volume_bt_pressed"] forState:UIControlStateHighlighted];
    [volumeBtn addTarget:self action:@selector(volumeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [mToolbar addSubview:volumeBtn];
    
    volumeSlider = [[UISlider alloc]initWithFrame:CGRectMake(mNextButton.frame.origin.x + mNextButton.frame.size.width + 75, 90, bottomView.frame.size.width - mNextButton.frame.origin.x - mNextButton.frame.size.width - 200, 20)];
    minImage = [[UIImage imageNamed:@"volume_slider_min"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    if (ver >= 6.0){
        maxImage = [[UIImage imageNamed:@"volume_slider_max"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
    } else {
        maxImage = [[UIImage imageNamed:@"volume_slider_max"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    }
    [volumeSlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [volumeSlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [volumeSlider setThumbImage: [UIImage imageNamed:@"volume_thumb"] forState:UIControlStateNormal];
    volumeSlider.value = [AppDelegate instance].mediaVolumeValue;
    [volumeSlider addTarget:self action:@selector(volumeSliderValueChanged) forControlEvents:UIControlEventValueChanged];
    [bottomView addSubview:volumeSlider];
    
    qualityBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [qualityBtn setHidden:YES];
    qualityBtn.frame = CGRectMake(mToolbar.frame.size.width - 100 - 20, mPlayButton.frame.origin.y, 100, BUTTON_HEIGHT);
    [qualityBtn setBackgroundImage:[UIImage imageNamed:@"quality_bt"] forState:UIControlStateNormal];
    [qualityBtn setBackgroundImage:[UIImage imageNamed:@"quality_bt_pressed"] forState:UIControlStateHighlighted];
    [qualityBtn addTarget:self action:@selector(qualityBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [mToolbar addSubview:qualityBtn];
    
    downloadLogoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [downloadLogoBtn setEnabled:NO];
    downloadLogoBtn.frame = CGRectMake(mToolbar.frame.size.width - 100 - 20, mPlayButton.frame.origin.y, 55, BUTTON_HEIGHT);
    [downloadLogoBtn setBackgroundImage:[UIImage imageNamed:@"bendi_icon"] forState:UIControlStateDisabled];
    [mToolbar addSubview:downloadLogoBtn];
    downloadLogoBtn.hidden = YES;
    
    if (isDownloaded)
    {
        [downloadLogoBtn setHidden:NO];
    }
    else
    {
        if (resolutionNum > 1)
        {
            [qualityBtn setHidden:NO];
        }
    }
    
    [self initScrubberTimer];
    [self syncPlayPauseButtons];
    [self syncScrubber];
    [self disablePlayerButtons];
    [self enableNextButton];
}

- (void)resetControlVisibilityTimer
{
    if (nil != controlVisibilityTimer)
    {
        [controlVisibilityTimer invalidate];
        controlVisibilityTimer = nil;
    }
    controlVisibilityTimer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(showToolview) userInfo:nil repeats:NO];
}

- (void)showToolview
{
    if (bottomView.hidden) {
        topToolbar.alpha = 1;
        bottomView.alpha = 1;
        resolutionPopTipView.alpha = 0.9;
        [topToolbar setHidden:NO];
        [bottomView setHidden:NO];
        [resolutionPopTipView setHidden:NO];
        UIView *epsideArrayView = (UIView *)[self.view viewWithTag:EPISODE_ARRAY_VIEW_TAG];
        if (epsideArrayView) {
            epsideArrayView.alpha = 1;
            [epsideArrayView setHidden:NO];
        }
        [self resetControlVisibilityTimer];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    } else {
        [controlVisibilityTimer invalidate];
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
            UIView *epsideArrayView = (UIView *)[self.view viewWithTag:EPISODE_ARRAY_VIEW_TAG];
            if (epsideArrayView) {
                epsideArrayView.alpha = 0;
            }
            topToolbar.alpha = 0;
            bottomView.alpha = 0;
            resolutionPopTipView.alpha = 0;
        } completion:^(BOOL finished) {
            UIView *epsideArrayView = (UIView *)[self.view viewWithTag:EPISODE_ARRAY_VIEW_TAG];
            if (epsideArrayView) {
                [epsideArrayView removeFromSuperview];
                episodeListviewController.table.frame = CGRectMake(0, 0, tableWidth, 0);
                episodeListviewController.view.frame = CGRectMake(episodeListviewController.view.frame.origin.x, episodeListviewController.view.frame.origin.y, episodeListviewController.view.frame.size.width, 0);
                [selectButton setBackgroundImage:[UIImage imageNamed:@"select_bt"] forState:UIControlStateNormal];
            }
            [topToolbar setHidden:YES];
            
            [resolutionPopTipView dismissAnimated:NO];
            resolutionPopTipView = nil;
            [bottomView setHidden:YES];
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
        }];
    }
    
    UIButton *tack = (UIButton *)[mToolbar viewWithTag:TRACK_BUTTON_TAG];
    if (tack.selected) {
        [self hiddenChangeTrackView];
    }
    
}

- (void)showPlayVideoView
{
    mPlayer = nil;
    mPlaybackView = [[AVPlayerView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width)];
    mPlaybackView.backgroundColor = [UIColor clearColor];
    if (bottomView) {
        [self.view insertSubview:mPlaybackView aboveSubview:bottomView];
    } else {
        [self.view addSubview:mPlaybackView];
    }
}

- (void)showPlayCacheView
{
    playCacheView = [self.view viewWithTag:PLAY_CACHE_VIEW];
    if (playCacheView == nil) {
        CGRect bounds = [UIScreen mainScreen].bounds;
        playCacheView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, bounds.size.height, bounds.size.width)];
        playCacheView.tag = PLAY_CACHE_VIEW;
        playCacheView.backgroundColor = [UIColor clearColor];
        if (topToolbar) {
            [self.view insertSubview:playCacheView belowSubview:topToolbar];
        } else {
            [self.view addSubview:playCacheView];
        }
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 1024, 768)];
        imageView.center = CGPointMake(playCacheView.center.x, playCacheView.center.y- 44);
        imageView.image = [UIImage imageNamed:@"video_cache_img"];
        [playCacheView addSubview:imageView];
        
        nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 400, 40)];
        nameLabel.center = CGPointMake(playCacheView.center.x, playCacheView.center.y * 0.90 + 50);
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = [UIFont systemFontOfSize:18];
        if (video != nil) {
            name = [video objectForKey:@"name"];
            subname = [subnameArray objectAtIndex:self.currentNum];
        }
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.textColor = [UIColor whiteColor];
        if (type == 2 || type == 131) {
            nameLabel.text = [NSString stringWithFormat:@"即将播放：%@ 第%@集", name, subname];
            vidoeTitle.text = [NSString stringWithFormat:@"%@：第%@集", name, subname];
        } else if(type == 3){
            nameLabel.text = [NSString stringWithFormat:@"即将播放：%@", subname];
            vidoeTitle.text = [NSString stringWithFormat:@"%@", subname];
        } else {
            nameLabel.text = [NSString stringWithFormat:@"即将播放：%@",name];
            if (video) {
                vidoeTitle.text = [video objectForKey:@"name"];
            }
        }
        [playCacheView addSubview:nameLabel];
        
        if (CMTIME_IS_VALID(lastPlayTime) && CMTimeGetSeconds(lastPlayTime) > 1) {
            UILabel *lastLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 300, 40)];
            lastLabel.tag = 3232947504;
            lastLabel.center = CGPointMake(playCacheView.center.x, playCacheView.center.y*0.9 + 80);
            lastLabel.backgroundColor = [UIColor clearColor];
            lastLabel.textAlignment = NSTextAlignmentCenter;
            lastLabel.textColor = [UIColor lightGrayColor];
            lastLabel.text = [NSString stringWithFormat:@"上次播放到 %@", [TimeUtility formatTimeInSecond:CMTimeGetSeconds(lastPlayTime)]];
            lastLabel.font = [UIFont systemFontOfSize:15];
            if (!isChangeQuality)
            {
                [playCacheView addSubview:lastLabel];
                isChangeQuality = NO;
            }
        }
        
        tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 500, 40)];
        tipLabel.center = CGPointMake(playCacheView.center.x, playCacheView.center.y * 1.4);
        tipLabel.backgroundColor = [UIColor clearColor];
        tipLabel.font = [UIFont systemFontOfSize:15];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.textColor = [UIColor whiteColor];
        [playCacheView addSubview:tipLabel];
        
        myHUD = [[MBProgressHUD alloc] initWithView:playCacheView];
        myHUD.frame = CGRectMake(myHUD.frame.origin.x, myHUD.frame.origin.y + 130, myHUD.frame.size.width, myHUD.frame.size.height);
        myHUD.opacity = 0;
    }
    UILabel *lastLabel = (UILabel *)[playCacheView viewWithTag:3232947504];
    if(lastLabel && isFromSelectBtn){
        [lastLabel removeFromSuperview];
        lastLabel = nil;
        lastPlayTime = kCMTimeZero;
    }
    tipLabel.text = nil;
    [myHUD show:YES];
    myHUD.labelText = @"正在加载，请稍等";
    [playCacheView bringSubviewToFront:myHUD];
    myHUD.userInteractionEnabled = NO;
    if (!myHUD.superview)
    {
        [playCacheView addSubview:myHUD];
    }
}


- (void)nextBtnClicked
{
    isDownloaded = NO;
    NSArray * playlists = [CommonMotheds localPlaylists:self.prodId type:self.type];
    NSInteger nextNum = currentNum + 1;
    NSArray * epArr = [video objectForKey:@"episodes"];
    if (nextNum >= epArr.count)
    {
        [self closeSelf];
        return;
    }
    NSDictionary * playInfo = [epArr objectAtIndex:nextNum];
    
    NSDictionary * curPlayInfo = nil;
    for (NSDictionary * dic in playlists)
    {
        if ([[dic objectForKey:@"name"] isEqualToString:[playInfo objectForKey:@"name"]])
        {
            isDownloaded = YES;
            curPlayInfo = dic;
            break;
        }
    }
    
    if (isDownloaded)
    {
        [self destoryPlayer];
        currentNum ++;
        //设置Button'enable
        [self enableNextButton];
        
        self.videoFormat = [curPlayInfo objectForKey:@"downloadType"];
        self.m3u8Duration = [[curPlayInfo objectForKey:@"duration"] doubleValue];
        self.videoUrl = [curPlayInfo objectForKey:@"videoUrl"];
        self.type = [[curPlayInfo objectForKey:@"type"] intValue];
        //self.name = [subnameArray objectAtIndex:currentNum];//[curPlayInfo objectForKey:@"name"];
        
        //[self loadLastPlaytime];
        lastPlayTime = CMTimeMakeWithSeconds(1, NSEC_PER_SEC);
        if ([videoFormat isEqualToString:@"m3u8"])
        {
            [[AppDelegate instance] startHttpServer];
            workingUrl = [NSURL URLWithString: videoUrl];
        } else {
            workingUrl = [[NSURL alloc] initFileURLWithPath:videoUrl];
        }
        [self setURL:workingUrl];
        
        //刷新视图
        if (type == DRAMA_TYPE || type == COMIC_TYPE) {
            subname = [subnameArray objectAtIndex:self.currentNum];
            vidoeTitle.text = [NSString stringWithFormat:@"%@：第%@集", name, subname];
        } else if(type == SHOW_TYPE){
            subname = [subnameArray objectAtIndex:self.currentNum];
            vidoeTitle.text = [NSString stringWithFormat:@"%@", subname];
        }
        qualityBtn.hidden = YES;
        downloadLogoBtn.hidden = NO;
    }
    else
    {
        [self destoryPlayer];
        isFromSelectBtn = YES;
        [self resetControlVisibilityTimer];
        currentNum++;
        currentPlaybackTimeLabel.text = @"00:00:00";
        mScrubber.value = 0;
        if ((type == 2 || type == 3 || type == 131) && subnameArray.count > self.currentNum)
        {
            episodeListviewController.currentNum = currentNum;
            [episodeListviewController.table reloadData];
            [self disablePlayerButtons];
            [self disableScrubber];
            if (subnameArray.count - 1 == self.currentNum) {
                [self disableNextButton];
            }
            lastPlayTime = CMTimeMakeWithSeconds(1, NSEC_PER_SEC);
            isResetLetvData_ = NO;
            [self preparePlayVideo];
            [self recordPlayStatics];
            if (resolutionNum > 1)
            {
                [qualityBtn setHidden:NO];
                downloadLogoBtn.hidden = YES;
            }
            else
            {
                [qualityBtn setHidden:YES];
                downloadLogoBtn.hidden = YES;
            }
        }
        else
        {
            currentNum--;
            [self closeSelf];
        }
    }
    
}

- (void)prevBtnClicked
{
    if (isPlayOnTV)
    {
        [self controlCloundTV:CLOUND_TV_SEEK_TO_TIME];
    }
    [self resetControlVisibilityTimer];
    int currentTime = 0;
    if (CMTIME_IS_VALID(mPlayer.currentTime)) {
        currentTime = CMTimeGetSeconds(mPlayer.currentTime);
        currentTime = fmax(0, currentTime - 30);
    }
    [mPlayer seekToTime:CMTimeMakeWithSeconds(currentTime, NSEC_PER_SEC)];
}

- (void)preparePlayVideo
{
    if (video != nil && subnameArray.count > self.currentNum) {
        workingUrl = nil;
        [mPlayer pause];
        mPlayer = nil;
        if (type == 2 || type == 131) {
            subname = [subnameArray objectAtIndex:self.currentNum];
            nameLabel.text = [NSString stringWithFormat:@"即将播放：%@ 第%@集", name, subname];
            vidoeTitle.text = [NSString stringWithFormat:@"%@：第%@集", name, subname];
        } else if(type == 3){
            subname = [subnameArray objectAtIndex:self.currentNum];
            nameLabel.text = [NSString stringWithFormat:@"即将播放：%@", subname];
            vidoeTitle.text = [NSString stringWithFormat:@"%@", subname];
        } else {
            nameLabel.text = [NSString stringWithFormat:@"即将播放：%@",name];
            vidoeTitle.text = [video objectForKey:@"name"];
        }
    }
    [self playVideo];
}

- (void)getVideoInfo
{
    BOOL isReachable = [[AppDelegate instance] performSelector:@selector(isParseReachable)];
    if(!isReachable) {
        [UIUtility showNetWorkError:self.view];
        return;
    }
    
    NSString *key = nil;
    if (type == SHOW_TYPE)
    {
        key = [NSString stringWithFormat:@"%@%@", @"show", self.prodId];
    }
    else if (type == DRAMA_TYPE || type == COMIC_TYPE)
    {
        key = [NSString stringWithFormat:@"%@%@", @"drama", self.prodId];
    }
    else
    {
        return;
    }
    
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:key];
    if(cacheResult != nil)
    {
        NSString *responseCode = [cacheResult objectForKey:@"res_code"];
        if(responseCode == nil)
        {
            if (type == SHOW_TYPE)
            {
                video = (NSDictionary *)[cacheResult objectForKey:@"show"];
            }
            else if (type == DRAMA_TYPE || type == COMIC_TYPE)
            {
                video = (NSDictionary *)[cacheResult objectForKey:@"tv"];
            }
            
            NSArray * episodes = [video objectForKey:@"episodes"];
            [self prepareOnlinePlay:episodes];
        }
    }
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: self.prodId, @"prod_id", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathProgramView parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil)
        {
            NSString *key = nil;
            
            if (type == SHOW_TYPE)
            {
                video = (NSDictionary *)[result objectForKey:@"show"];
                key = [NSString stringWithFormat:@"%@%@", @"show", self.prodId];
            }
            else if (type == DRAMA_TYPE || type == COMIC_TYPE)
            {
                video = (NSDictionary *)[result objectForKey:@"tv"];
                key = [NSString stringWithFormat:@"%@%@", @"drama", self.prodId];
            }
            
            [[CacheUtility sharedCache] putInCache:key result:result];
            
            NSArray * episodes = [video objectForKey:@"episodes"];
            [self prepareOnlinePlay:episodes];
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        [UIUtility showSystemError:self.view];
    }];
}

- (void)prepareOnlinePlay:(NSArray *)episodes
{
    if (type == SHOW_TYPE)
    {
        for (int i =0;i < episodes.count; i ++)
        {
            NSDictionary * dic = [episodes objectAtIndex:i];
            if ([[dic objectForKey:@"name"] isEqualToString:subname])
            {
                currentNum = i;
                break;
            }
        }
    }
    else
    {
        currentNum = [subname intValue] - 1;
    }
    
    if (subnameArray == nil) {
        subnameArray = [[NSMutableArray alloc]initWithCapacity:10];
        for (NSDictionary *oneEpisode in episodes)
        {
            NSString *tempName = [NSString stringWithFormat:@"%@", [oneEpisode objectForKey:@"name"]];
            [subnameArray addObject:tempName];
        }
    }
    
    [self enableNextButton];
}

#pragma mark
#pragma mark Button Action Methods

- (void)switchBtnClicked
{
    if([((AVPlayerLayer *)[mPlaybackView layer]).videoGravity isEqualToString:AVLayerVideoGravityResizeAspect]){
        [mSwitchButton setBackgroundImage:[UIImage imageNamed:@"reduce_bt"] forState:UIControlStateNormal];
        [mSwitchButton setBackgroundImage:[UIImage imageNamed:@"reduce_bt_pressed"] forState:UIControlStateHighlighted];
        [mPlaybackView setVideoFillMode: AVLayerVideoGravityResizeAspectFill];
    } else {
        [mSwitchButton setBackgroundImage:[UIImage imageNamed:@"full_bt"] forState:UIControlStateNormal];
        [mSwitchButton setBackgroundImage:[UIImage imageNamed:@"full_bt_pressed"] forState:UIControlStateHighlighted];
        [mPlaybackView setVideoFillMode: AVLayerVideoGravityResizeAspect];
    }
}

- (void)playBtnClicked:(id)sender
{
	/* If we are at the end of the movie, we must seek to the beginning first
     before starting playback. */
    if (isPlayOnTV && isTVReady)
    {
        [self controlCloundTV:CLOUND_TV_PLAY];
    }
	if (YES == seekToZeroBeforePlay) {
		seekToZeroBeforePlay = NO;
		[mPlayer seekToTime:kCMTimeZero];
	}
    if (CMTIME_IS_VALID(resolutionLastPlaytime)) {
        [mPlayer seekToTime:resolutionLastPlaytime];
        resolutionLastPlaytime = kCMTimeInvalid;
    }
    [self dismissActivityView];
    mPlayer.allowsAirPlayVideo = YES;
	[mPlayer play];
    [self showStopButton];
    [self resetControlVisibilityTimer];
}

- (void)stopBtnClicked:(id)sender
{
    if (isPlayOnTV && isTVReady)
    {
        [self controlCloundTV:CLOUND_TV_PAUSE];
    }
	[mPlayer pause];
    [self showPlayButton];
    [self resetControlVisibilityTimer];
}

- (void)saveLastPlaytime
{
    NSString *lastPlaytimeCacheKey;
    if (type == 1) {
        lastPlaytimeCacheKey = [NSString stringWithFormat:@"%@", self.prodId];
    } else {
        lastPlaytimeCacheKey = [NSString stringWithFormat:@"%@_%@", self.prodId, subname];
    }
    float lastPlaytimeNum = CMTimeGetSeconds(mPlayer.currentTime);
    lastPlayTime = mPlayer.currentTime;
    double duration = 0;
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_VALID(playerDuration)) {
        duration = CMTimeGetSeconds(playerDuration);
    }
    if (duration - lastPlaytimeNum <= 5) {
        [[CacheUtility sharedCache]putInCache:lastPlaytimeCacheKey result: [NSNumber numberWithInt:0]];
    } else {
        [[CacheUtility sharedCache]putInCache:lastPlaytimeCacheKey result: [NSNumber numberWithFloat:lastPlaytimeNum]];
    }
}

- (void)destoryPlayer
{
    if (isDownloaded)
    {
        [[AppDelegate instance] stopHttpServer];
    }
    [self.mPlayer removeObserver:self forKeyPath:kRateKey];
	[self.mPlayerItem removeObserver:self forKeyPath:kStatusKey];
    [self.mPlayer removeObserver:self forKeyPath:kCurrentItemKey];
    //buffering
    [self.mPlayerItem removeObserver:self forKeyPath:k_BufferEmpty];
    [self.mPlayerItem removeObserver:self forKeyPath:k_ToKeepUp];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WIFI_IS_NOT_AVAILABLE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:APPLICATION_DID_BECOME_ACTIVE_NOTIFICATION
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:APPLICATION_DID_ENTER_BACKGROUND_NOTIFICATION
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NETWORK_CHANGED object:nil];
    
    [self closeAllTimer];
    [self.urlConnection cancel];
    self.urlConnection = nil;
    [self updateWatchRecord];
    [self saveLastPlaytime];
	
    [mPlayer pause];
    mPlayer = nil;
    mPlayerItem = nil;
    
    if (type == 2 || type == 3 || type == 131) {
        [videoWebViewControllerDelegate playNextEpisode:currentNum];
    }
    if (myHUD.superview)
    {
        [myHUD removeFromSuperview];
    }
}

- (void)closeSelf
{
    if (isPlayOnTV)
    {
        [self controlCloundTV:CLOUND_TV_CLOSE];
    }
    [BundingTVManager shareInstance].sendClient.delegate = (id)[BundingTVManager shareInstance];
    
    [self destoryPlayer];
    if ([@"0" isEqualToString:[AppDelegate instance].closeVideoMode]){
        [self dismissViewControllerAnimated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
        }];
    } else {
        if (closeAll) {
            [self dismissViewControllerAnimated:YES completion:^{
                [[UIApplication sharedApplication] setStatusBarHidden:NO];
            }];
        } else {
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
    isClosed = YES;
}

- (void)showEpisodeListView
{
    [self resetControlVisibilityTimer];
    UIView *epsideArrayView = (UIView *)[self.view viewWithTag:EPISODE_ARRAY_VIEW_TAG];
    if (epsideArrayView) {
        [selectButton setBackgroundImage:[UIImage imageNamed:@"select_bt"] forState:UIControlStateNormal];
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
            episodeListviewController.table.frame = CGRectMake(0, 0, tableWidth, 0);
            episodeListviewController.view.frame = CGRectMake(episodeListviewController.view.frame.origin.x, episodeListviewController.view.frame.origin.y, episodeListviewController.view.frame.size.width, 0);
        } completion:^(BOOL finished) {
            [epsideArrayView removeFromSuperview];
        }];
    }
    else
    {
        NSMutableArray * downloadedIndex = [[NSMutableArray alloc] init];
        NSArray * downloadedItem = [CommonMotheds localPlaylists:self.prodId  type:self.type];
        NSArray * episodes = [video objectForKey:@"episodes"];
        if (type == SHOW_TYPE)
        {
            for (int i =0;i < episodes.count; i ++)
            {
                NSDictionary * dic = [episodes objectAtIndex:i];
                for (int j = 0; j < downloadedItem.count; j ++)
                {
                    NSDictionary * item = [downloadedItem objectAtIndex:j];
                    if ([[dic objectForKey:@"name"] isEqualToString:[item objectForKey:@"name"]])
                    {
                        [downloadedIndex addObject:[NSString stringWithFormat:@"%d",i]];
                        continue;
                    }
                }
            }
        }
        else
        {
            for (int j = 0; j < downloadedItem.count; j ++)
            {
                NSDictionary * item = [downloadedItem objectAtIndex:j];
                NSString * index = [item objectForKey:@"name"];
                [downloadedIndex addObject:[NSString stringWithFormat:@"%d",([index intValue] - 1)]];
                continue;
            }
        }
        
        [selectButton setBackgroundImage:[UIImage imageNamed:@"select_bt_pressed"] forState:UIControlStateNormal];
        [episodeListviewController.view setHidden:NO];
        episodeListviewController.view.alpha = 1;
        episodeListviewController.currentNum = currentNum;
        episodeListviewController.episodeArray = subnameArray;
        episodeListviewController.downloadedIndex = downloadedIndex;
        [self.view addSubview:episodeListviewController.view];
        [episodeListviewController.table reloadData];
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
            episodeListviewController.table.frame = CGRectMake(0, 0, tableWidth, fmin(maxEpisodeNum, subnameArray.count) * tableCellHeight);
            episodeListviewController.view.frame = CGRectMake(episodeListviewController.view.frame.origin.x, episodeListviewController.view.frame.origin.y, episodeListviewController.view.frame.size.width, fmin(maxEpisodeNum, subnameArray.count) * tableCellHeight);
        } completion:^(BOOL finished) {
            if (currentNum >= 0 && currentNum < subnameArray.count) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentNum inSection:0];
                [episodeListviewController.table scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            }
        }];
    }
}

- (void)qualityBtnClicked:(UIButton *)btn
{
    [self resetControlVisibilityTimer];
    if (resolutionPopTipView) {
        [qualityBtn setBackgroundImage:[UIImage imageNamed:@"quality_bt"] forState:UIControlStateNormal];
        [resolutionPopTipView dismissAnimated:YES];
        resolutionPopTipView = nil;
    } else {
        [qualityBtn setBackgroundImage:[UIImage imageNamed:@"quality_bt_pressed"] forState:UIControlStateNormal];
        UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 360, 130)];
        if (resolutionNum == 2) {
            contentView.frame = CGRectMake(0, 0, 240, 130);
        }
        contentView.backgroundColor = [UIColor clearColor];
        
        UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 320, 30)];
        tLabel.backgroundColor = [UIColor clearColor];
        tLabel.font = [UIFont systemFontOfSize:20];
        tLabel.text = @"请选择影片清晰度：";
        tLabel.textAlignment = NSTextAlignmentLeft;
        tLabel.textColor = [UIColor whiteColor];
        [contentView addSubview:tLabel];
        
        NSArray *temp1 = [urlArrayDictionary objectForKey:BIAO_QING];
        if (temp1.count > 0) {
            biaoqingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            biaoqingBtn.tag = 111001;
            biaoqingBtn.frame = CGRectMake(40, 50, 40, BUTTON_HEIGHT);
            [biaoqingBtn setBackgroundImage:[UIImage imageNamed:@"biaoqing_bt"] forState:UIControlStateNormal];
            [biaoqingBtn setBackgroundImage:[UIImage imageNamed:@"biaoqing_bt_pressed"] forState:UIControlStateHighlighted];
            [biaoqingBtn addTarget:self action:@selector(resolutionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [contentView addSubview:biaoqingBtn];
        }
        
        NSArray *temp2 = [urlArrayDictionary objectForKey:GAO_QING];
        if (temp2.count > 0) {
            gaoqingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            gaoqingBtn.frame = CGRectMake(160, 50, 40, BUTTON_HEIGHT);
            gaoqingBtn.tag = 111002;
            [gaoqingBtn setBackgroundImage:[UIImage imageNamed:@"gaoqing_bt"] forState:UIControlStateNormal];
            [gaoqingBtn setBackgroundImage:[UIImage imageNamed:@"gaoqing_bt_pressed"] forState:UIControlStateHighlighted];
            [gaoqingBtn addTarget:self action:@selector(resolutionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [contentView addSubview:gaoqingBtn];
        }
        
        NSArray *temp3 = [urlArrayDictionary objectForKey:CHAO_QING];
        if (temp3.count > 0) {
            chaoqingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            chaoqingBtn.frame = CGRectMake(280, 50, 40, BUTTON_HEIGHT);
            chaoqingBtn.tag = 111003;
            [chaoqingBtn setBackgroundImage:[UIImage imageNamed:@"chaoqing_bt"] forState:UIControlStateNormal];
            [chaoqingBtn setBackgroundImage:[UIImage imageNamed:@"chaoqing_bt_pressed"] forState:UIControlStateHighlighted];
            [chaoqingBtn addTarget:self action:@selector(resolutionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [contentView addSubview:chaoqingBtn];
        }
        if (resolutionNum == 3) {
            UIView *separatorView = [[UIView alloc]initWithFrame:CGRectMake(120, 65, 1, 40)];
            separatorView.backgroundColor = [UIColor colorWithRed:80/255.0 green:80/255.0 blue:80/255.0 alpha:0.5];
            [contentView addSubview:separatorView];
            
            UIView *separatorView1 = [[UIView alloc]initWithFrame:CGRectMake(240, 65, 1, 40)];
            separatorView1.backgroundColor = [UIColor colorWithRed:80/255.0 green:80/255.0 blue:80/255.0 alpha:0.5];
            [contentView addSubview:separatorView1];
        } else if (resolutionNum == 2){
            if (temp1.count > 0 && temp2.count > 0) {
                biaoqingBtn.frame = CGRectMake(40, 50, 40, BUTTON_HEIGHT);
                gaoqingBtn.frame = CGRectMake(160, 50, 40, BUTTON_HEIGHT);
            } else if (temp1.count > 0 && temp3.count > 0) {
                biaoqingBtn.frame = CGRectMake(40, 50, 40, BUTTON_HEIGHT);
                chaoqingBtn.frame = CGRectMake(160, 50, 40, BUTTON_HEIGHT);
            } else if (temp2.count > 0 && temp3.count > 0) {
                gaoqingBtn.frame = CGRectMake(40, 50, 40, BUTTON_HEIGHT);
                chaoqingBtn.frame = CGRectMake(160, 50, 40, BUTTON_HEIGHT);
            }
            UIView *separatorView = [[UIView alloc]initWithFrame:CGRectMake(120, 65, 1, 40)];
            separatorView.backgroundColor = [UIColor colorWithRed:80/255.0 green:80/255.0 blue:80/255.0 alpha:0.5];
            [contentView addSubview:separatorView];
        }
        if ([resolution isEqualToString:BIAO_QING]) {
            [biaoqingBtn setBackgroundImage:[UIImage imageNamed:@"biaoqing_bt_pressed"] forState:UIControlStateNormal];
        } else if ([resolution isEqualToString:CHAO_QING]){
            [chaoqingBtn setBackgroundImage:[UIImage imageNamed:@"chaoqing_bt_pressed"] forState:UIControlStateNormal];
        } else {
            [gaoqingBtn setBackgroundImage:[UIImage imageNamed:@"gaoqing_bt_pressed"] forState:UIControlStateNormal];
        }
        resolutionPopTipView = [[CMPopTipView alloc] initWithCustomView:contentView];
        resolutionPopTipView.backgroundColor = [UIColor colorWithRed:10/255.0 green:10/255.0 blue:10/255.0 alpha:1];
        //    resolutionPopTipView.delegate = self;
        resolutionPopTipView.disableTapToDismiss = YES;
        resolutionPopTipView.animation = CMPopTipAnimationPop;
        [resolutionPopTipView presentPointingAtView:btn inView:self.view animated:YES];
        resolutionPopTipView.frame = CGRectMake(bottomView.frame.size.width - resolutionPopTipView.frame.size.width, resolutionPopTipView.frame.origin.y, resolutionPopTipView.frame.size.width, resolutionPopTipView.frame.size.height);
    }
}

- (void)resolutionBtnClicked:(UIButton *)btn
{
    [self resetControlVisibilityTimer];
    if (!resolutionInvalid){ //如果分辨率已失效，不记录播放时间
        resolutionLastPlaytime = [mPlayer currentTime];
    }
    [self destoryPlayer];
    [biaoqingBtn setBackgroundImage:[UIImage imageNamed:@"biaoqing_bt"] forState:UIControlStateNormal];
    [gaoqingBtn setBackgroundImage:[UIImage imageNamed:@"gaoqing_bt"] forState:UIControlStateNormal];
    [chaoqingBtn setBackgroundImage:[UIImage imageNamed:@"chaoqing_bt"] forState:UIControlStateNormal];
    combinedIndex = 0;
    if (combinedArr == nil) {
        combinedArr = [[NSMutableArray alloc]initWithCapacity:3];
    }
    [combinedArr removeAllObjects];
    if (btn.tag == 111001) {
        resolution = BIAO_QING;
        [self createCombinedArray:BIAO_QING urlArray:plainClearArr];
        [btn setBackgroundImage:[UIImage imageNamed:@"biaoqing_bt_pressed"] forState:UIControlStateNormal];
    } else if (btn.tag == 111002) {
        resolution = GAO_QING;
        [self createCombinedArray:GAO_QING urlArray:highClearArr];
        [btn setBackgroundImage:[UIImage imageNamed:@"gaoqing_bt_pressed"] forState:UIControlStateNormal];
    } else if (btn.tag == 111003) {
        resolution = CHAO_QING;
        [self createCombinedArray:CHAO_QING urlArray:superClearArr];
        [btn setBackgroundImage:[UIImage imageNamed:@"chaoqing_bt_pressed"] forState:UIControlStateNormal];
    }
    [qualityBtn setBackgroundImage:[UIImage imageNamed:@"quality_bt"] forState:UIControlStateNormal];
    [resolutionPopTipView dismissAnimated:YES];
    resolutionPopTipView = nil;
    
    workingUrl = nil;
    [mPlayer pause];
    mPlayer = nil;
    defaultErrorMessage = @"此分辨率已失效，请选择其他分辨率。";
    
    isChangeQuality = YES;
    
    [self showPlayCacheView];
    [self loadLastPlaytime];
    [self sendRequest];
    
}

- (void)volumeBtnClicked:(UIButton *)btn
{
    if (btn.tag == 9877) {
        [self setVolumeValue:0];
    } else {
        [self setVolumeValue:volumeSlider.value];
    }
}

- (void)volumeSliderValueChanged
{
    [self setVolumeValue:volumeSlider.value];
}

- (void)systemVolumeChanged:(id)obj
{
    volumeSlider.value = [MPMusicPlayerController applicationMusicPlayer].volume;
    [AppDelegate instance].mediaVolumeValue = volumeSlider.value;
    [self changeVolumeBtn:volumeSlider.value];
}

- (void)changeVolumeBtn:(float)value
{
    if (value > 0) {
        volumeBtn.tag = 9877;
        [volumeBtn setBackgroundImage:[UIImage imageNamed:@"volume_bt"] forState:UIControlStateNormal];
        [volumeBtn setBackgroundImage:[UIImage imageNamed:@"volume_bt_pressed"] forState:UIControlStateHighlighted];
    } else {
        volumeBtn.tag = 9878;
        [volumeBtn setBackgroundImage:[UIImage imageNamed:@"volume_mute_bt"] forState:UIControlStateNormal];
        [volumeBtn setBackgroundImage:[UIImage imageNamed:@"volume_mute_bt_pressed"] forState:UIControlStateHighlighted];
    }
}

- (void)setVolumeValue:(float)value
{
    volumeSlider.value = value;
    [AppDelegate instance].mediaVolumeValue = volumeSlider.value;
    [MPMusicPlayerController applicationMusicPlayer].volume = volumeSlider.value;
    [self changeVolumeBtn:value];
    //    AVURLAsset *asset = [[mPlayer currentItem] asset];
    //    NSMutableArray *allAudioParams = [NSMutableArray array];
    //    NSArray *audioTracks = [asset tracksWithMediaType:AVMediaTypeAudio];
    //    if (audioTracks.count > 0) {
    //        for (AVAssetTrack *track in audioTracks) {
    //            AVMutableAudioMixInputParameters *audioInputParams =    [AVMutableAudioMixInputParameters audioMixInputParameters];
    //            [audioInputParams setVolume:value atTime:kCMTimeZero];
    //            [audioInputParams setTrackID:[track trackID]];
    //            [allAudioParams addObject:audioInputParams];
    //        }
    //    } else {
    //        NSArray *tempaudioTracks = self.player.currentItem.tracks;
    //        AVAssetTrack *track = [tempaudioTracks objectAtIndex:1];
    //        AVMutableAudioMixInputParameters *audioInputParams =    [AVMutableAudioMixInputParameters audioMixInputParameters];
    //        [audioInputParams setVolume:value atTime:kCMTimeZero];
    //        [audioInputParams setTrackID:[track trackID]];
    //        [allAudioParams addObject:audioInputParams];
    //    }
    //    AVMutableAudioMix *audioZeroMix = [AVMutableAudioMix audioMix];
    //    [audioZeroMix setInputParameters:allAudioParams];
    //    [[mPlayer currentItem] setAudioMix:audioZeroMix];
}

- (void)updateWatchRecord
{
    if(!isDownloaded){
        int playbackTime = 0;
        if(CMTimeGetSeconds(mPlayer.currentTime) > 0){
            playbackTime = CMTimeGetSeconds(mPlayer.currentTime);
        }
        double duration = 0;
        CMTime playerDuration = [self playerItemDuration];
        if (CMTIME_IS_VALID(playerDuration)) {
            duration = CMTimeGetSeconds(playerDuration);
        }
        if (subname == nil && currentNum >=0 && currentNum < subnameArray.count) {
            subname = [subnameArray objectAtIndex:currentNum];
        }
        NSString *userId = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId];
        NSString *tempPlayType = @"1";
        NSString *tempUrl = workingUrl.absoluteString; //This url should be useless. In order to simplify the replay logic, we will don't use the url any more.
        NSLog(@"%@", tempUrl);
        if (workingUrl == nil) {
            tempPlayType = @"2";
            tempUrl = videoHttpUrl;
        }
        NSString *durationStr = nil;
        if (duration == 0) {
            durationStr = @"";
        }
        else{
            durationStr = [NSString stringWithFormat:@"%f",duration];
        }
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: userId, @"userid", self.prodId, @"prod_id", [video objectForKey:@"name"], @"prod_name", subname, @"prod_subname", [NSNumber numberWithInt:self.type], @"prod_type", tempPlayType, @"play_type", [NSNumber numberWithInt:playbackTime], @"playback_time", durationStr, @"duration", tempUrl, @"video_url", nil];
        [[AFServiceAPIClient sharedClient] postPath:kPathAddPlayHistory parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [[CacheUtility sharedCache] removeObjectForKey:WATCH_RECORD_CACHE_KEY];
            [[NSNotificationCenter defaultCenter] postNotificationName:WATCH_HISTORY_REFRESH object:nil];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"zz%@", error);
        }];
    }
}

-(void)reportErrorVideo{
    NSString *userId = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId];
    if (subname == nil && currentNum >=0 && currentNum < subnameArray.count) {
        subname = [subnameArray objectAtIndex:currentNum];
    }
    NSString *tempPlayType = @"1";
    NSString *playUrl = ((AVURLAsset *)mPlayerItem.asset).URL.absoluteString;
    if (playUrl == nil) {
        tempPlayType = @"2";
    }
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: userId, @"userid", self.prodId, @"prod_id", [video objectForKey:@"name"], @"prod_name", subname, @"prod_subname", [NSNumber numberWithInt:self.type], @"prod_type", tempPlayType, @"play_type", [NSNumber numberWithInt:0], @"playback_time", @"-1", @"duration", videoHttpUrl, @"video_url", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathAddPlayHistory parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
}

- (void)loadLastPlaytime
{
    if (CMTIME_IS_INVALID(lastPlayTime) || CMTimeCompare(lastPlayTime, kCMTimeZero) == 0) {
        NSString *lastPlaytimeCacheKey;
        if (type == 1) {
            lastPlaytimeCacheKey = [NSString stringWithFormat:@"%@", self.prodId];
        } else {
            lastPlaytimeCacheKey = [NSString stringWithFormat:@"%@_%@", self.prodId, subname];
        }
        NSNumber *seconds = [[CacheUtility sharedCache]loadFromCache:lastPlaytimeCacheKey];
        if (seconds.intValue > 1) {
            lastPlayTime = CMTimeMakeWithSeconds(seconds.doubleValue, NSEC_PER_SEC);
        } else {
            lastPlayTime = CMTimeMakeWithSeconds(1, NSEC_PER_SEC);
        }
    }
}

-(void)couldPlayButtonPressed:(UIButton *)btn{

    btn.selected = !btn.selected;
    isPlayOnTV = btn.selected;
    if (isPlayOnTV)
    {
        [self pushWebURLToCloudTV:@"41"];
    }
    else
    {
        [self controlCloundTV:CLOUND_TV_CLOSE];
    }

}
#pragma mark -
#pragma mark Play, Stop buttons

- (void)setURL:(NSURL*)URL
{
	if (mURL != URL)
	{
		mURL = URL;
		
        /*
         Create an asset for inspection of a resource referenced by a given URL.
         Load the values for the asset keys "tracks", "playable".
         */
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:mURL options:nil];
        
        NSString * nameStr = @"myQueue";
        const char * queueName = [nameStr UTF8String];
        dispatch_queue_t queue = dispatch_queue_create(queueName, NULL);
        dispatch_async(queue, ^(void){
            NSMutableArray *allAudioParams = [NSMutableArray array];
            NSArray *audioTracks =  [asset tracksWithMediaType:AVMediaTypeAudio];
            if ([audioTracks count]>1)
            {
                for (int i = 0; i < [audioTracks count]; i++)
                {
                    AVMutableAudioMixInputParameters *audioInputParams =
                    [AVMutableAudioMixInputParameters audioMixInputParameters];
                    if (i != 0)
                    {
                        [audioInputParams setVolume:0.0 atTime:kCMTimeZero];
                    }
                    AVAssetTrack *track = [audioTracks objectAtIndex:i];
                    [audioInputParams setTrackID:[track trackID]];
                    [allAudioParams addObject:audioInputParams];
                }
                audioMix_ = [AVMutableAudioMix audioMix];
                [audioMix_ setInputParameters:allAudioParams];
                [self showTrackSelectButton];
            }
            if (!isClosed)
                [self prepareToPlayAsset:asset];
        });
        
        /* Tells the asset to load the values of any of the specified keys that are not already loaded. */
//        __block typeof (self) myself = self;
//        [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
//         ^{
//             dispatch_async( dispatch_get_main_queue(),
//                            ^{
//                                /* IMPORTANT: Must dispatch to main queue in order to operate on the AVPlayer and AVPlayerItem. */
//                                
//                            });
//         }];
	}
}

- (NSURL*)URL
{
	return mURL;
}

/* Show the stop button in the movie player controller. */
-(void)showStopButton
{
    [mPlayButton setHidden:YES];
    [mStopButton setHidden:NO];
}

/* Show the play button in the movie player controller. */
-(void)showPlayButton
{
    [mPlayButton setHidden:NO];
    [mStopButton setHidden:YES];
}

/* If the media is playing, show the stop button; otherwise, show the play button. */
- (void)syncPlayPauseButtons
{
	if ([self isPlaying])
	{
        [self showStopButton];
	}
	else
	{
        [self showPlayButton];
	}
}

-(void)enablePlayerButtons
{
    mPlayButton.enabled = YES;
    mStopButton.enabled = YES;
    if (!isDownloaded)
    {
        [qualityBtn setEnabled:YES];
    }
    [mSwitchButton setEnabled:YES];
    for (UIView *asubview in routeBtn.subviews) {
        if ([NSStringFromClass(asubview.class) isEqualToString:@"MPButton"]) {
            UIButton *btn = (UIButton *)asubview;
            [btn setImage:nil forState:UIControlStateNormal];
            [btn setImage:nil forState:UIControlStateHighlighted];
            [btn setImage:nil forState:UIControlStateSelected];
            [btn setEnabled:YES];
            break;
        }
    }
    [mPrevButton setEnabled:YES];
    [volumeBtn setEnabled:YES];
}

-(void)disablePlayerButtons
{
    self.mPlayButton.enabled = NO;
    self.mStopButton.enabled = NO;
    [mPrevButton setEnabled:NO];
    [volumeBtn setEnabled:NO];
    [mSwitchButton setEnabled:NO];
}

- (void)enableNextButton
{
    if (!isDownloaded)
    {
        if (subnameArray.count > 0 && type != 1){
            if (currentNum == 0) {
                [mNextButton setEnabled:YES];
            } else if(currentNum == subnameArray.count - 1) {
                [mNextButton setEnabled:NO];
            } else if(currentNum > 0 && currentNum < subnameArray.count){
                [mNextButton setEnabled:YES];
            }
        } else {
            [mNextButton setEnabled:NO];
        }
    }
    else
    {
        NSArray * playlist = [video objectForKey:@"episodes"];
        if (playlist.count > 0 && type != 1){
            if (currentNum == 0) {
                [mNextButton setEnabled:YES];
            } else if(currentNum == playlist.count - 1) {
                [mNextButton setEnabled:NO];
            } else if(currentNum > 0 && currentNum < playlist.count){
                [mNextButton setEnabled:YES];
            }
        } else {
            [mNextButton setEnabled:NO];
        }
    }
}

- (void)disableNextButton
{
    [mNextButton setEnabled:NO];
}

- (void)closeAllTimer
{
    if (nil != controlVisibilityTimer)
    {
        [controlVisibilityTimer invalidate];
        controlVisibilityTimer = nil;
    }
    [self removePlayerTimeObserver];
}

#pragma mark -
#pragma mark Movie scrubber control

/* ---------------------------------------------------------
 **  Methods to handle manipulation of the movie scrubber control
 ** ------------------------------------------------------- */

/* Requests invocation of a given block during media playback to update the movie scrubber control. */
-(void)initScrubberTimer
{
	double interval = .1f;
	
	CMTime playerDuration = [self playerItemDuration];
	if (CMTIME_IS_INVALID(playerDuration))
	{
		return;
	}
	double duration = CMTimeGetSeconds(playerDuration);
	if (isfinite(duration))
	{
		CGFloat width = CGRectGetWidth([mScrubber bounds]);
		interval = 0.5f * duration / width;
	}
    
    if (nil != mTimeObserver)
    {
        [self removePlayerTimeObserver];
    }
	/* Update the scrubber during normal playback. */
    if (isnan(interval) || interval < 0.1f) {
        interval = 0.1f;
    }
    __block typeof (self) myself = self;
	mTimeObserver = [mPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                                                          queue:NULL /* If you pass NULL, the main queue is used. */
                                                     usingBlock:^(CMTime time)
                     {
                         [myself syncScrubber];
                     }];
    
}

/* Set the scrubber based on the player current time. */
- (void)syncScrubber
{
	CMTime playerDuration = [self playerItemDuration];
	if (CMTIME_IS_INVALID(playerDuration))
	{
		mScrubber.minimumValue = 0.0;
		return;
	}
    
	double duration = CMTimeGetSeconds(playerDuration);
	if (isfinite(duration))
	{
		float minValue = [mScrubber minimumValue];
		float maxValue = [mScrubber maximumValue];
		double time = CMTimeGetSeconds([mPlayer currentTime]);
        if (isnan(time)) {
            time = 0;
        }
		[mScrubber setValue:(maxValue - minValue) * time / duration + minValue];
	}
    
    currentPlaybackTimeLabel.text = [TimeUtility formatTimeInSecond:CMTimeGetSeconds(mPlayerItem.currentTime)];
}

/* The user is dragging the movie controller thumb to scrub through the movie. */
- (void)beginScrubbing:(id)sender
{
	mRestoreAfterScrubbingRate = [mPlayer rate];
	[mPlayer setRate:0.f];
	
	/* Remove previous timer. */
	[self removePlayerTimeObserver];
}

/* Set the player current time to match the scrubber position. */
- (void)scrub:(id)sender
{
	if ([sender isKindOfClass:[UISlider class]])
	{
		UISlider* slider = sender;
		
		CMTime playerDuration = [self playerItemDuration];
		if (CMTIME_IS_INVALID(playerDuration)) {
			return;
		}
		
		double duration = CMTimeGetSeconds(playerDuration);
		if (isfinite(duration))
		{
			float minValue = [slider minimumValue];
			float maxValue = [slider maximumValue];
			float value = [slider value];
			
			double time = duration * (value - minValue) / (maxValue - minValue);
			
			[mPlayer seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
		}
	}
}

/* The user has released the movie thumb control to stop scrubbing through the movie. */
- (void)endScrubbing:(id)sender
{
    [self resetControlVisibilityTimer];
	if (!mTimeObserver)
	{
		CMTime playerDuration = [self playerItemDuration];
		if (CMTIME_IS_INVALID(playerDuration)) {
			return;
		}
		
		double duration = CMTimeGetSeconds(playerDuration);
		if (isfinite(duration))
		{
			CGFloat width = CGRectGetWidth([mScrubber bounds]);
			double tolerance = 0.5f * duration / width;
            if (isnan(tolerance) || tolerance < 0.1f) {
                tolerance = 0.1f;
            }
            __block typeof (self) myself = self;
			mTimeObserver = [mPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC) queue:NULL usingBlock:
                             ^(CMTime time) {
                                 [myself syncScrubber];
                             }];
		}
	}
    
	if (mRestoreAfterScrubbingRate)
	{
		[mPlayer setRate:mRestoreAfterScrubbingRate];
		mRestoreAfterScrubbingRate = 0.f;
	}
    if (isPlayOnTV)
    {
        [self controlCloundTV:CLOUND_TV_SEEK_TO_TIME];
    }
}

- (BOOL)isScrubbing
{
	return mRestoreAfterScrubbingRate != 0.f;
}

-(void)enableScrubber
{
    self.mScrubber.enabled = YES;
}

-(void)disableScrubber
{
    self.mScrubber.enabled = NO;
}
- (void)playOneEpisode:(int)num isDownload:(BOOL)isDownload
{
    [self destoryPlayer];
    isFromSelectBtn = YES;
    currentNum = num;
    currentPlaybackTimeLabel.text = @"00:00:00";
    mScrubber.value = 0;
    [self disablePlayerButtons];
    [self enableNextButton];
    [self disableScrubber];
    [self resetControlVisibilityTimer];
    lastPlayTime = CMTimeMakeWithSeconds(1, NSEC_PER_SEC);
    self.isDownloaded = isDownload;
    if (isDownload)
    {
        NSArray * playlists = [CommonMotheds localPlaylists:self.prodId type:self.type];
        NSDictionary * playInfo = [[video objectForKey:@"episodes"] objectAtIndex:currentNum];
        
        NSDictionary * curPlayInfo = nil;
        for (NSDictionary * dic in playlists)
        {
            if ([[dic objectForKey:@"name"] isEqualToString:[playInfo objectForKey:@"name"]])
            {
                curPlayInfo = dic;
                break;
            }
        }
        
        self.videoFormat = [curPlayInfo objectForKey:@"downloadType"];
        self.m3u8Duration = [[curPlayInfo objectForKey:@"duration"] doubleValue];
        self.videoUrl = [curPlayInfo objectForKey:@"videoUrl"];
        self.type = [[curPlayInfo objectForKey:@"type"] intValue];
        if ([videoFormat isEqualToString:@"m3u8"])
        {
            [[AppDelegate instance] startHttpServer];
            workingUrl = [NSURL URLWithString: videoUrl];
        } else {
            workingUrl = [[NSURL alloc] initFileURLWithPath:videoUrl];
        }
        [self setURL:workingUrl];
        
        //刷新视图
        if (type == DRAMA_TYPE || type == COMIC_TYPE) {
            subname = [subnameArray objectAtIndex:self.currentNum];
            vidoeTitle.text = [NSString stringWithFormat:@"%@：第%@集", name, subname];
        } else if(type == SHOW_TYPE){
            subname = [subnameArray objectAtIndex:self.currentNum];
            vidoeTitle.text = [NSString stringWithFormat:@"%@", subname];
        }
        downloadLogoBtn.hidden = NO;
        qualityBtn.hidden = YES;
    }
    else
    {
        isResetLetvData_ = NO;
        [self preparePlayVideo];
        [self recordPlayStatics];
        if (resolutionNum > 1)
        {
            [qualityBtn setHidden:NO];
            downloadLogoBtn.hidden = YES;
        }
        else
        {
            [qualityBtn setHidden:YES];
            downloadLogoBtn.hidden = YES;
        }
    }
}

- (void)scrollViewBeginDragging:(UIScrollView *)scrollView
{
    if (nil != controlVisibilityTimer)
    {
        [controlVisibilityTimer invalidate];
        controlVisibilityTimer = nil;
    }
}
- (void)scrollViewEndDecelerating:(UIScrollView *)scrollView
{
    [self resetControlVisibilityTimer];
}

- (void)recordPlayStatics
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: self.prodId, @"prod_id", [video objectForKey:@"name"], @"prod_name", subname, @"prod_subname", [NSNumber numberWithInt:type], @"prod_type", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathRecordPlay parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (BOOL)isPlaying
{
	return mRestoreAfterScrubbingRate != 0.f || [mPlayer rate] != 0.f;
}

/* Called when the player item has played to its end time. */
- (void)playerItemDidReachEnd:(NSNotification *)notification
{
	/* After the movie has played to its end time, seek back to time zero
     to play it again. */
	seekToZeroBeforePlay = YES;
    [mNextButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}

/* ---------------------------------------------------------
 **  Get the duration for a AVPlayerItem.
 ** ------------------------------------------------------- */

- (CMTime)playerItemDuration
{
	AVPlayerItem *playerItem = [mPlayer currentItem];
    if (isDownloaded && m3u8Duration > 0) {
        return  CMTimeMakeWithSeconds(m3u8Duration, NSEC_PER_SEC);
    }
	if (playerItem.status == AVPlayerItemStatusReadyToPlay)
	{
        /*
         NOTE:
         Because of the dynamic nature of HTTP Live Streaming Media, the best practice
         for obtaining the duration of an AVPlayerItem object has changed in iOS 4.3.
         Prior to iOS 4.3, you would obtain the duration of a player item by fetching
         the value of the duration property of its associated AVAsset object. However,
         note that for HTTP Live Streaming Media the duration of a player item during
         any particular playback session may differ from the duration of its asset. For
         this reason a new key-value observable duration property has been defined on
         AVPlayerItem.
         
         See the AV Foundation Release Notes for iOS 4.3 for more information.
         */
        
		return([playerItem duration]);
	}
	
	return(kCMTimeInvalid);
}


/* Cancels the previously registered time observer. */
-(void)removePlayerTimeObserver
{
	if (mTimeObserver)
	{
		[mPlayer removeTimeObserver:mTimeObserver];
		mTimeObserver = nil;
	}
}

- (void)showActivityView
{
    if (!playCacheView && !(self.view == myHUD.superview))
    {
        [myHUD show:YES];
        [self.view bringSubviewToFront:myHUD];
        //myHUD.labelText = @"正在加载，请稍等";
        myHUD.userInteractionEnabled = NO;
        [self.view addSubview:myHUD];
    }
}
- (void)dismissActivityView
{
    if (!playCacheView && (self.view == myHUD.superview))
    {
        [myHUD removeFromSuperview];
    }
}

#pragma mark -
#pragma mark panAction
-(void)panAction:(UIPanGestureRecognizer *)pan{//左右拖动设置进度，上下推动设置音量；
    CGPoint offset = [pan translationInView:self.view];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{
            if (fabs(offset.x)>=fabs(offset.y)){
                [self beginScrubbing:mScrubber];
            }
            break;
        }
        case UIGestureRecognizerStateChanged:
            if (fabs(offset.x)>=fabs(offset.y)) {//左右拖动
                float nowValue = mScrubber.value;
                nowValue = nowValue + 0.01*offset.x/kFullWindowHeight;
                if (nowValue > 1) {
                    nowValue = 1;
                }
                else if (nowValue < 0){
                    nowValue = 0;
                }
                mScrubber.value = nowValue;
                [self scrub:mScrubber];
            }
            else{//上下拖动
                float nowValue = [MPMusicPlayerController applicationMusicPlayer].volume;
                nowValue = nowValue - 0.02*offset.y/320;
                if (nowValue > 1) {
                    nowValue = 1;
                }
                else if (nowValue < 0){
                    nowValue = 0;
                }
                [MPMusicPlayerController applicationMusicPlayer].volume = nowValue;
            }
            break;
        case UIGestureRecognizerStateEnded:{
            if (fabs(offset.x)>=fabs(offset.y)){
                [self endScrubbing:mScrubber];
            }
            break;
        }
        default:
            break;
    }
    
    
}

#pragma mark - 
#pragma mark trackChange
-(void)showTrackSelectButton{
    trackSelect = [UIButton buttonWithType:UIButtonTypeCustom];
    trackSelect.frame = CGRectMake( 280,25, 55, 50);
    [trackSelect setBackgroundImage:[UIImage imageNamed:@"ipad_shengdao"] forState:UIControlStateNormal];
    [trackSelect setBackgroundImage:[UIImage imageNamed:@"ipad_shengdao_s"] forState:UIControlStateHighlighted];
    [trackSelect setBackgroundImage:[UIImage imageNamed:@"ipad_shengdao_s"] forState:UIControlStateSelected];
    //trackSelect.adjustsImageWhenHighlighted = NO;
    trackSelect.tag = TRACK_BUTTON_TAG;
      trackSelect.enabled = NO;
    [trackSelect addTarget:self action:@selector(trackButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [mToolbar addSubview:trackSelect];
  
}
-(void)trackButtonPressed:(UIButton *)btn{
    btn.selected = !btn.selected;
    if (btn.selected) {
        [self showChangeTrackView];
    }
    else{
        [self hiddenChangeTrackView];
    }

}
-(void)showChangeTrackView{
    if (changeTrackView == nil) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 240, 145)];
        imageView.image = [UIImage imageNamed:@"ipad_shengdao_bg"];
        imageView.userInteractionEnabled = YES;
        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftBtn setBackgroundImage:[UIImage imageNamed:@"ipad_shegdao1.png"] forState:UIControlStateNormal];
        [leftBtn setBackgroundImage:[UIImage imageNamed:@"ipad_shegdao1_s.png"] forState:UIControlStateDisabled];
        [leftBtn setBackgroundImage:[UIImage imageNamed:@"ipad_shegdao1_s.png"] forState:UIControlStateHighlighted];
        leftBtn.enabled = NO;
        leftBtn.tag = 300001;
        [leftBtn addTarget:self action:@selector(trackButtonSelected:) forControlEvents:UIControlEventTouchUpInside];

        leftBtn.frame = CGRectMake(10, 55, 99, 54);
        [imageView addSubview:leftBtn];

        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightBtn setBackgroundImage:[UIImage imageNamed:@"ipad_shegdao2.png"] forState:UIControlStateNormal];
        [rightBtn setBackgroundImage:[UIImage imageNamed:@"ipad_shegdao2_s.png"] forState:UIControlStateDisabled];
        [rightBtn setBackgroundImage:[UIImage imageNamed:@"ipad_shegdao2_s.png"] forState:UIControlStateHighlighted];
        rightBtn.tag = 300002;
        [rightBtn addTarget:self action:@selector(trackButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        rightBtn.frame = CGRectMake(130, 55, 99, 54);
        [imageView addSubview:rightBtn];

        changeTrackView  = [[CMPopTipView alloc] initWithCustomView:imageView];
        changeTrackView.backgroundColor = [UIColor clearColor];
        changeTrackView.disableTapToDismiss = YES;
        changeTrackView.animation = CMPopTipAnimationPop;
        UIButton *button = (UIButton *)[mToolbar viewWithTag:TRACK_BUTTON_TAG];
        [changeTrackView presentPointingAtView:button inView:self.view animated:YES];
    }
    [self.view bringSubviewToFront:changeTrackView];
    changeTrackView.hidden = NO;
    
}

-(void)hiddenChangeTrackView{
         changeTrackView.hidden = YES;
          UIButton *button = (UIButton *)[mToolbar viewWithTag:TRACK_BUTTON_TAG];
          button.selected = NO;
}

-(void)trackButtonSelected:(UIButton *)btn{
        for (UIView *view in changeTrackView.customView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
                   UIButton *subBtn = (UIButton *)view;
                    subBtn.enabled = YES;
            }
        }
        btn.enabled = NO;
        if (btn.tag == 300001){
            [self changeTracks:0];
            
        }
       else if(btn.tag == 300002){
            [self changeTracks:1];
           
       }
    
}
-(void)enableTracksSelectButton{
    trackSelect.hidden = NO;
    trackSelect.enabled = YES;
}

-(void)disableAirPlayButton{
    routeBtn.userInteractionEnabled = NO;
    UIView *tempView = [mPlaybackView viewWithTag:9585403];
    [tempView removeFromSuperview];
    if (airPlayButton_) {
        airPlayButton_.enabled = NO;
        [airPlayButton_ setBackgroundImage:[UIImage imageNamed:@"iphone_route_bt"] forState:UIControlStateNormal];
    }
}
-(void)enaleAirPlayButton{
     routeBtn.userInteractionEnabled = YES;
    if (mPlayer.airPlayVideoActive) {
        UIView *tempView = [mPlaybackView viewWithTag:9585403];
        if (tempView == nil) {
            [mPlaybackView addSubview:applyTvView];
        }
        for (UIView *asubview in routeBtn.subviews) {
            if ([NSStringFromClass(asubview.class) isEqualToString:@"MPButton"]) {
                UIButton *btn = (UIButton *)asubview;
                [btn setImage:nil forState:UIControlStateNormal];
                [btn setImage:nil forState:UIControlStateHighlighted];
                [btn setImage:nil forState:UIControlStateSelected];
                [btn setBackgroundImage:[UIImage imageNamed:@"route_bt_light"] forState:UIControlStateNormal];
                [btn setEnabled:YES];
                break;
            }
        }
    } else {
        UIView *tempView = [mPlaybackView viewWithTag:9585403];
        [tempView removeFromSuperview];
        for (UIView *asubview in routeBtn.subviews) {
            if ([NSStringFromClass(asubview.class) isEqualToString:@"MPButton"]) {
                UIButton *btn = (UIButton *)asubview;
                [btn setImage:nil forState:UIControlStateNormal];
                [btn setImage:nil forState:UIControlStateHighlighted];
                [btn setImage:nil forState:UIControlStateSelected];
                [btn setBackgroundImage:[UIImage imageNamed:@"route_bt"] forState:UIControlStateNormal];
                [btn setEnabled:YES];
                break;
            }
        }
    }

}

-(void)enableCloudPlayButton{
    if (cloudPlayButton_) {
        cloudPlayButton_.enabled = YES;
    }
}
- (void)changeTracks:(int)atype{    //0-第1个音轨；1-第2个音轨；
        if (audioMix_) {
                    NSArray *inputParametersArray = audioMix_.inputParameters;
                    for (int i = 0; i < [inputParametersArray count]; i++) {
                                AVMutableAudioMixInputParameters *oneAudioMixInPut = [inputParametersArray objectAtIndex:i];
                                if (i == atype) {
                                            [oneAudioMixInPut setVolume:0.6 atTime:[mPlayer currentTime]];
                                        }
                                else{
                                            [oneAudioMixInPut setVolume:0.0 atTime:[mPlayer currentTime]];
                                        }
                        
                            }
                    [self.mPlayerItem setAudioMix:audioMix_];
                }
}

#pragma mark -
#pragma mark Loading the Asset Keys Asynchronously

#pragma mark -
/*
 Invoked at the completion of the loading of the values for all keys on the asset that we require.
 Checks whether loading was successfull and whether the asset is playable.
 If so, sets up an AVPlayerItem and an AVPlayer to play the asset.
 */
- (void)prepareToPlayAsset:(AVURLAsset *)asset
{
    /* Make sure that the value of each key has loaded successfully. */
    //	for (NSString *thisKey in requestedKeys)
    //	{
    //		NSError *error = nil;
    //		AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
    //		if (keyStatus == AVKeyValueStatusFailed)
    //		{
    ////			[self assetFailedToPrepareForPlayback:error];
    //            NSLog(@"%@", error);
    //            [self performSelectorOnMainThread:@selector(checkNextUrlToPlay) withObject:nil waitUntilDone:NO];
    //			return;
    //		}
    //		/* If you are also implementing -[AVAsset cancelLoading], add your code here to bail out properly in the case of cancellation. */
    //	}
    //
    //    /* Use the AVAsset playable property to detect whether the asset can be played. */
    //    if (!asset.playable)
    //    {
    //        /* Generate an error describing the failure. */
    //		NSString *localizedDescription = NSLocalizedString(@"Item cannot be played", @"Item cannot be played description");
    //		NSString *localizedFailureReason = NSLocalizedString(@"The assets tracks were loaded, but could not be made playable.", @"Item cannot be played failure reason");
    //		NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
    //								   localizedDescription, NSLocalizedDescriptionKey,
    //								   localizedFailureReason, NSLocalizedFailureReasonErrorKey,
    //								   nil];
    //		NSError *assetCannotBePlayedError = [NSError errorWithDomain:@"StitchedStreamPlayer" code:0 userInfo:errorDict];
    //
    //        /* Display the error to the user. */
    ////        [self assetFailedToPrepareForPlayback:assetCannotBePlayedError];
    //        NSLog(@"%@", assetCannotBePlayedError);
    //        [self performSelectorOnMainThread:@selector(checkNextUrlToPlay) withObject:nil waitUntilDone:NO];
    //
    //        return;
    //    }
	
	/* At this point we're ready to set up for playback of the asset. */
    
    /* Stop observing our prior AVPlayerItem, if we have one. */
    if (self.mPlayerItem)
    {
        /* Remove existing player item key value observers and notifications. */
        
        [self.mPlayerItem removeObserver:self forKeyPath:kStatusKey];
		
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:self.mPlayerItem];
    }
	
    /* Create a new instance of AVPlayerItem from the now successfully loaded AVAsset. */
    self.mPlayerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    if (audioMix_) {
        [self.mPlayerItem setAudioMix:audioMix_];
    }
    
    /* Observe the player item "status" key to determine when it is ready to play. */
    [self.mPlayerItem addObserver:self
                       forKeyPath:kStatusKey
                          options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          context:AVPlayerDemoPlaybackViewControllerStatusObservationContext];
	
    //buffering
	[self.mPlayerItem addObserver:self
                       forKeyPath:k_BufferEmpty
                          options:NSKeyValueObservingOptionNew
                          context:AVPlayerDemoPlaybackViewControllerCurrentItemBufferingContext];
    [self.mPlayerItem addObserver:self
                       forKeyPath:k_ToKeepUp
                          options:NSKeyValueObservingOptionNew
                          context:AVPlayerDemoPlaybackViewControllerCurrentItemBufferingContext];
    
    /* When the player item has played to its end time we'll toggle
     the movie controller Pause button to be the Play button */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.mPlayerItem];
	
    seekToZeroBeforePlay = NO;
	
    /* Create new player, if we don't already have one. */
    if (![self player])
    {
        [self setPlayer:[AVPlayer playerWithPlayerItem:self.mPlayerItem]];
        if (CMTIME_IS_VALID(lastPlayTime)) {            
            [mPlayer seekToTime:lastPlayTime];
        }
        /* Observe the AVPlayer "currentItem" property to find out when any
         AVPlayer replaceCurrentItemWithPlayerItem: replacement will/did
         occur.*/
        [self.player addObserver:self
                      forKeyPath:kCurrentItemKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext];
        
        /* Observe the AVPlayer "rate" property to update the scrubber control. */
        [self.player addObserver:self
                      forKeyPath:kRateKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:AVPlayerDemoPlaybackViewControllerRateObservationContext];
    }
    
    /* Make our new AVPlayerItem the AVPlayer's current item. */
    if (self.player.currentItem != self.mPlayerItem)
    {
        /* Replace the player item with a new player item. The item replacement occurs
         asynchronously; observe the currentItem property to find out when the
         replacement will/did occur*/
        [[self player] replaceCurrentItemWithPlayerItem:self.mPlayerItem];
        
        [self syncPlayPauseButtons];
    }
	
    
}

#pragma mark -
#pragma mark Asset Key Value Observing
#pragma mark

#pragma mark Key Value Observer for player rate, currentItem, player item status

- (void)observeValueForKeyPath:(NSString*) path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
//    if (isAppEnterBackground)
//        return;
    if (applyTvView == nil) {
        applyTvView = [[UIView alloc]initWithFrame:mPlaybackView.frame];
        applyTvView.tag = 9585403;
        applyTvView.backgroundColor = [UIColor clearColor];
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 260, 192)];
        imageView.center = CGPointMake(mPlaybackView.center.x, applyTvView.center.y - 100);
        imageView.image = [UIImage imageNamed:@"play_pic"];
        [applyTvView addSubview:imageView];
        
        UILabel *airlabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 300, 40)];
        airlabel.center = CGPointMake(mPlaybackView.center.x, applyTvView.center.y + 80);
        airlabel.backgroundColor = [UIColor clearColor];
        airlabel.textColor = [UIColor lightGrayColor];
        airlabel.text = @"此视频正在通过 AirPlay 播放。";
        airlabel.font = [UIFont systemFontOfSize:18];
        airlabel.textAlignment = NSTextAlignmentCenter;
        [applyTvView addSubview:airlabel];
    }
   
	/* AVPlayerItem "status" property value observer. */
	if (context == AVPlayerDemoPlaybackViewControllerStatusObservationContext)
	{
		[self syncPlayPauseButtons];
        
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        
        switch (status)
        {
            case AVPlayerStatusUnknown:
            {
                [self removePlayerTimeObserver];
                [self syncScrubber];
                [self disableScrubber];
                [self disablePlayerButtons];
                [mPlayer play];
            }
                break;
                
            case AVPlayerStatusReadyToPlay:
            {
                CMTime playerDuration = [self playerItemDuration];
                double duration = 0;
                if (CMTIME_IS_VALID(playerDuration)) {
                    duration = CMTimeGetSeconds(playerDuration);
                }
                [self initScrubberTimer];
                if (duration > 0) {
                    [self enableScrubber];
                    totalTimeLabel.text = [TimeUtility formatTimeInSecond:duration];
                } else {
                    totalTimeLabel.text = @"";
                }
                [self enablePlayerButtons];
                [self enableNextButton];
                [self enableTracksSelectButton];
                [self enaleAirPlayButton];
                [self enableCloudPlayButton];
                
                [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
                    for (UIView *subview in playCacheView.subviews) {
                        [subview setAlpha:0];
                    }
                    [playCacheView setAlpha:0];
                } completion:^(BOOL finished) {
                    currentPlaybackTimeLabel.text = [TimeUtility formatTimeInSecond:CMTimeGetSeconds(mPlayerItem.currentTime)];
                    [playCacheView removeFromSuperview];
                    [playCacheView setHidden:YES];
                    playCacheView = nil;
                    [self resetControlVisibilityTimer];
                    resolutionInvalid = NO;
                    [mPlayButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                    NSDictionary *tempDic = [combinedArr objectAtIndex:combinedIndex];
                    //                    NSLog(@"%@", tempDic);
                    sourceStr = [[tempDic objectForKey:URL_KEY] objectForKey:@"source"];
                    BOOL exists = YES;
                    if ([sourceStr isEqualToString:@"letv"] || [sourceStr isEqualToString:@"le_tv_fee"]) {
                        sourceStr = @"letv";
                        sourceImage.frame = CGRectMake(sourceLabel.frame.origin.x + sourceLabel.frame.size.width, 17, 58, 17);
                    } else if ([sourceStr isEqualToString:@"fengxing"]){
                        sourceImage.frame = CGRectMake(sourceLabel.frame.origin.x + sourceLabel.frame.size.width, 17, 17, 17);
                    } else if ([sourceStr isEqualToString:@"qiyi"]){
                        sourceImage.frame = CGRectMake(sourceLabel.frame.origin.x + sourceLabel.frame.size.width, 17, 58, 17);
                    } else if ([sourceStr isEqualToString:@"youku"]){
                        sourceImage.frame = CGRectMake(sourceLabel.frame.origin.x + sourceLabel.frame.size.width, 17, 86, 17);
                    } else if ([sourceStr isEqualToString:@"sinahd"]){
                        sourceImage.frame = CGRectMake(sourceLabel.frame.origin.x + sourceLabel.frame.size.width, 17, 23, 17);
                    } else if ([sourceStr isEqualToString:@"sohu"]){
                        sourceImage.frame = CGRectMake(sourceLabel.frame.origin.x + sourceLabel.frame.size.width, 17, 43, 17);
                    } else if ([sourceStr isEqualToString:@"56"]){
                        sourceImage.frame = CGRectMake(sourceLabel.frame.origin.x + sourceLabel.frame.size.width, 17, 54, 17);
                    } else if ([sourceStr isEqualToString:@"qq"]){
                        sourceImage.frame = CGRectMake(sourceLabel.frame.origin.x + sourceLabel.frame.size.width, 17, 17, 17);
                    } else if ([sourceStr isEqualToString:@"pptv"]
                               || [sourceStr isEqualToString:@"wangpan"]
                               || [sourceStr isEqualToString:@"baidu_wangpan"]){
                        sourceStr = @"pptv";
                        sourceImage.frame = CGRectMake(sourceLabel.frame.origin.x + sourceLabel.frame.size.width, 17, 56, 17);
                    } else if ([sourceStr isEqualToString:@"m1905"]){
                        sourceImage.frame = CGRectMake(sourceLabel.frame.origin.x + sourceLabel.frame.size.width, 16, 45, 17);
                    } else if ([sourceStr isEqualToString:@"pps"]){
                        sourceImage.frame = CGRectMake(sourceLabel.frame.origin.x + sourceLabel.frame.size.width, 17, 53, 17);
                    } else {
                        exists = NO;
                    }
                    if (exists) {
                        sourceImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"logo_%@", sourceStr]];
                        [sourceLabel setHidden:NO];
                        [sourceImage setHidden:NO];
                    }
                }];
            }
                
                break;
                
            case AVPlayerStatusFailed:
            {
                AVPlayerItem *playerItem = (AVPlayerItem *)object;
                NSLog(@"%@", playerItem.error);
                combinedIndex++;
                [self performSelectorOnMainThread:@selector(sendRequest) withObject:nil waitUntilDone:NO];
            }
                break;
        }
	}
	/* AVPlayer "rate" property value observer. */
	else if (context == AVPlayerDemoPlaybackViewControllerRateObservationContext)
	{
        //[self syncPlayPauseButtons];
	}
	/* AVPlayer "currentItem" property observer.
     Called when the AVPlayer replaceCurrentItemWithPlayerItem:
     replacement will/did occur. */
	else if (context == AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext)
	{
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        
        /* Is the new player item null? */
        if (newPlayerItem == (id)[NSNull null])
        {
            [self disablePlayerButtons];
            [self disableScrubber];
        }
        else /* Replacement of player currentItem has occurred */
        {
            /* Set the AVPlayer for which the player layer displays visual output. */
            [mPlaybackView setPlayer:mPlayer];
            [mPlaybackView setVideoFillMode:AVLayerVideoGravityResizeAspect];
            
            [self syncPlayPauseButtons];
        }
	}
    else if (context == AVPlayerDemoPlaybackViewControllerCurrentItemBufferingContext)
    {
        AVPlayerItem * pItem = (AVPlayerItem *)object;
        if (k_BufferEmpty == path)
        {
            if (pItem.playbackBufferEmpty)
            {
                [self showActivityView];
                NSLog(@"buffer empty");
            }
            else
            {
                
            }
        }
        else if (k_ToKeepUp == path)
        {
            if (pItem.playbackLikelyToKeepUp)
            {
                [self dismissActivityView];
                BOOL isPlaying = [self isPlaying];
                BOOL isHidden = mPlayButton.hidden;
                if (!isPlaying && isHidden)
                {
                    [mPlayer play];
                }
                NSLog(@"KeepUp YES");
            }
            else
            {
                if (![self isPlaying])
                {
                    [self showActivityView];
                }
                NSLog(@"KeepUp NO");
            }
        }
    }
	else
	{
		[super observeValueForKeyPath:path ofObject:object change:change context:context];
	}
}

//=====================Utility methods========================

- (void)wifiNotAvailable:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WIFI_IS_NOT_AVAILABLE object:nil];
    NSString *show3GAlert = (NSString *)notification.object;
    if ([show3GAlert isEqualToString:@"0"]) {
        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil message:@"当前网络为非Wifi环境，您确定要继续播放吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0){
        [self closeSelf];
    }
}

- (void)getAirplayDeviceType
{
    //    if ([[AirPlayDetector defaultDetector] isAirPlayAvailable]) {
    CFDictionaryRef currentRouteDescriptionDictionary = nil;
    UInt32 dataSize = sizeof(currentRouteDescriptionDictionary);
    AudioSessionGetProperty(kAudioSessionProperty_AudioRouteDescription, &dataSize, &currentRouteDescriptionDictionary);
    if (currentRouteDescriptionDictionary) {
        CFArrayRef outputs = CFDictionaryGetValue(currentRouteDescriptionDictionary, kAudioSession_AudioRouteKey_Outputs);
        if(CFArrayGetCount(outputs) > 0) {
            CFDictionaryRef currentOutput = CFArrayGetValueAtIndex(outputs, 0);
            //Get the output type (will show airplay / hdmi etc
            CFStringRef outputType = CFDictionaryGetValue(currentOutput, kAudioSession_AudioRouteKey_Type);
            //If you're using Apple TV as your ouput - this will get the name of it (Apple TV Kitchen) etc
            CFStringRef outputName = CFDictionaryGetValue(currentOutput, @"RouteDetailedDescription_Name");
            deviceOutputType = (__bridge NSString *)outputType;
            airplayDeviceName = (__bridge NSString*)outputName;
            NSLog(@"%@  %@", deviceOutputType, airplayDeviceName);
            CFRelease(outputType);
            CFRelease(outputName);
        }
    }
    //    }
}


- (BOOL)validadUrl:(NSString *)originalUrl
{
    NSString *formatUrl = [[originalUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    if([formatUrl hasPrefix:@"http://"] || [formatUrl hasPrefix:@"https://"]){
        return YES;
    }
    return NO;
}

NSComparator cmpStr = ^(id obj1, id obj2){
    if ([obj1 floatValue] > [obj2 floatValue]) {
        return (NSComparisonResult)NSOrderedDescending;
    }
    
    if ([obj1 floatValue] < [obj2 floatValue]) {
        return (NSComparisonResult)NSOrderedAscending;
    }
    return (NSComparisonResult)NSOrderedSame;
};

//=====================End Utility methods========================

#pragma mark -
#pragma mark - NetworkChangedNSNotification

-(void)networkChanged:(NSNotification *)notify{
    int status = [(NSNumber *)(notify.object) intValue];
    if (status == 0) {
        myHUD.labelText = @"亲，网络出问题了，请检查后重试！";
    }
    else{
        myHUD.labelText = @"正在加载，请稍等";
    }
}


#pragma mark -
#pragma mark - app进入后台/重新激活
- (void)appDidEnterBackground:(NSNotification *)niti
{
    //isAppEnterBackground = YES;
    if (![ActionUtility isAirPlayActive])
    {
        if (self.isPlaying)
        {
            [mPlayer pause];
        }
        [self updateWatchRecord];
        [self saveLastPlaytime];
    }
}

- (void)appDidBecomeActive:(NSNotification *)niti
{
    //isAppEnterBackground = NO;
}

#pragma mark -
#pragma mark FayeObjc delegate
- (void) messageReceived:(NSDictionary *)messageDict
{
    if ([[messageDict objectForKey:@"push_type"] isEqualToString:@"31"])
    {
        
    }
    else if ([[messageDict objectForKey:@"push_type"] isEqualToString:@"32"])
    {
        
    }
    else if ([[messageDict objectForKey:@"push_type"] isEqualToString:@"42"])
    {
        isTVReady = YES;
    }
}

- (void)connectedToServer
{
    
}

- (void)disconnectedFromServer
{
    [[BundingTVManager shareInstance] reconnectToServer];
    [BundingTVManager shareInstance].sendClient.delegate = self;
}

- (void)socketDidSendMessage:(ZTWebSocket *)aWebSocket
{
    
}

- (void)subscriptionFailedWithError:(NSString *)error
{
    
}
- (void)subscribedToChannel:(NSString *)channel
{
    
}

#pragma mark -
#pragma mark - 控制投放TV接口(private)
- (void)controlCloundTV:(NSInteger)controlType
{
    NSString *userId = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:@"kUserId"];
    NSDictionary * data = (NSDictionary *)[[ContainerUtility sharedInstance] attributeForKey:[NSString stringWithFormat:@"%@_isBunding",userId]];
    NSString * sendChannel = [NSString stringWithFormat:@"CHANNEL_TV_%@",[data objectForKey:KEY_MACADDRESS]];
    double curTime = mScrubber.value * CMTimeGetSeconds([self playerItemDuration]);//CMTimeGetSeconds([self.mPlayer currentTime]);
    NSNumber * videoType = [NSNumber numberWithInt:type];
    NSString * cType = nil;
    switch (controlType)
    {
        case CLOUND_TV_PLAY:
        {
            cType = @"403";
        }
            break;
        case CLOUND_TV_PAUSE:
        {
            cType = @"405";
        }
            break;
        case CLOUND_TV_CLOSE:
        {
            cType = @"409";
        }
            break;
        case CLOUND_TV_SEEK_TO_TIME:
        {
            cType = @"407";
        }
            break;
        default:
            break;
    }
    
    NSDictionary *reqData = [NSDictionary dictionaryWithObjectsAndKeys:
                             cType, @"push_type",
                             userId, @"user_id",
                             sendChannel, @"tv_channel",
                             [NSNumber numberWithFloat:curTime],@"prod_time",
                             workingUrl.absoluteString,@"prod_url",
                             prodId,@"prod_id",
                             name,@"prod_name",
                             videoType,@"prod_type",
                             nil];
    
    [[BundingTVManager shareInstance] sendMsg:reqData];
}

- (void)pushWebURLToCloudTV:(NSString *)pushType
{
    NSNumber * videotype = [NSNumber numberWithInt:type];
    NSString *userId = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:@"kUserId"];
    double curTime = CMTimeGetSeconds([self.mPlayer currentTime]);
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          pushType, @"push_type",
                          userId, @"user_id",
                          workingUrl.absoluteString,@"prod_url",
                          [NSString stringWithFormat:@"%@",sourceStr],@"prod_src",
                          [NSNumber numberWithFloat:curTime],@"prod_time",
                          prodId,@"prod_id",
                          name,@"prod_name",
                          videotype,@"prod_type",
                          [NSNumber numberWithInt:0],@"prod_qua",
                          subname,@"prod_subname",
                          nil];
    
    [[BundingTVManager shareInstance] sendMsg:data];
    [MobClick event:KEY_PUSH_VIDEO];
    isTVReady = NO;
}

@end

