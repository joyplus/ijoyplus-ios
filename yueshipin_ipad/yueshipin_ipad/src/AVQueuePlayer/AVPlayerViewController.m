
#import "AVPlayerViewController.h"
#import "AVPlayerView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "EpisodeListViewController.h"
#import "CommonHeader.h"
#import "CMPopTipView.h"

#define TOP_TOOLBAR_HEIGHT 50
#define BOTTOM_TOOL_VIEW_HEIGHT 150
#define BOTTOM_TOOLBAR_HEIGHT 100
#define BUTTON_HEIGHT 50
#define EPISODE_ARRAY_VIEW_TAG 76892367
#define PLAY_CACHE_VIEW 234238494

/* Asset keys */
NSString * const kTracksKey         = @"tracks";
NSString * const kPlayableKey		= @"playable";

/* PlayerItem keys */
NSString * const kStatusKey         = @"status";

/* AVPlayer keys */
NSString * const kRateKey			= @"rate";
NSString * const kCurrentItemKey	= @"currentItem";


@interface AVPlayerViewController () <UIGestureRecognizerDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) UIToolbar *topToolbar;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) MPVolumeView *volumeSlider;
@property (nonatomic, strong) MPVolumeView *routeBtn;
@property (nonatomic, strong) UILabel *currentPlaybackTimeLabel;
@property (nonatomic, strong) UILabel *totalTimeLabel;
@property (nonatomic, strong) UIButton *volumeBtn;
@property (nonatomic, strong) UIButton *selectButton;
@property (nonatomic, strong) UIButton *qualityBtn;
@property (nonatomic, strong) UIView *playCacheView;
@property (nonatomic, strong) NSLock *theLock;
@property (nonatomic, strong) NSTimer *controlVisibilityTimer;
@property (nonatomic, strong) MBProgressHUD *myHUD;
@property (nonatomic, strong) EpisodeListViewController *episodeListviewController;
@property (nonatomic, strong) CMPopTipView *resolutionPopTipView;
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
@property (atomic, strong) NSURL *workingUrl;
@property (atomic) int errorUrlNum;
@property (nonatomic) NSString *resolution;
@property (nonatomic) CMTime lastPlayTime;
@property (nonatomic) CMTime resolutionLastPlaytime;
@property (nonatomic) int resolutionNum;
@property (nonatomic, strong) NSURLRequest *request;
@end

@interface AVPlayerViewController (Player)
- (void)removePlayerTimeObserver;
- (CMTime)playerItemDuration;
- (BOOL)isPlaying;
- (void)playerItemDidReachEnd:(NSNotification *)notification ;
- (void)observeValueForKeyPath:(NSString*) path ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys;
@end

static void *AVPlayerDemoPlaybackViewControllerRateObservationContext = &AVPlayerDemoPlaybackViewControllerRateObservationContext;
static void *AVPlayerDemoPlaybackViewControllerStatusObservationContext = &AVPlayerDemoPlaybackViewControllerStatusObservationContext;
static void *AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext = &AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext;

#pragma mark -
@implementation AVPlayerViewController
@synthesize mPlayer, mPlayerItem, mPlaybackView;
@synthesize mToolbar, topToolbar, mPlayButton, mStopButton, mScrubber, mNextButton, mPrevButton, volumeSlider, mSwitchButton;
@synthesize currentPlaybackTimeLabel, totalTimeLabel, volumeBtn, qualityBtn, videoUrlsArray, selectButton;
@synthesize playCacheView, resolution, videoHttpUrl, nameLabel;
@synthesize type, isDownloaded, currentNum, errorUrlNum, theLock, closeAll;
@synthesize workingUrl, myHUD, bottomView, controlVisibilityTimer;
@synthesize episodeListviewController, subnameArray, lastPlayTime, resolutionLastPlaytime;
@synthesize resolutionPopTipView, biaoqingBtn, chaoqingBtn, gaoqingBtn, routeBtn;
@synthesize vidoeTitle, videoWebViewControllerDelegate, airplayDeviceName, deviceOutputType;
@synthesize prodId, applyTvView, resolutionNum, tipLabel, video, subname, name, request;

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
    [self removePlayerTimeObserver];
	[mPlayer removeObserver:self forKeyPath:@"rate"];
	[mPlayer.currentItem removeObserver:self forKeyPath:@"status"];
	[mPlayer pause];
    topToolbar = nil;
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
    theLock = nil;
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
    videoUrlsArray = nil;
    prodId = nil;
    name = nil;
    subname = nil;
    video = nil;
    videoHttpUrl = nil;
    self.URL = nil;
    mPlayer = nil;
    mPlayerItem = nil;
    mPlaybackView = nil;
    mToolbar = nil;
    mPrevButton = nil;
    mNextButton = nil;
    mSwitchButton = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WIFI_IS_NOT_AVAILABLE object:nil];
    [super viewDidUnload];
}

- (void)dealloc
{
    [self removePlayerTimeObserver];
	[mPlayer removeObserver:self forKeyPath:@"rate"];
	[mPlayer.currentItem removeObserver:self forKeyPath:@"status"];
	[mPlayer pause];
    topToolbar = nil;
    nameLabel = nil;
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
    theLock = nil;
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
    videoUrlsArray = nil;
    prodId = nil;
    name = nil;
    subname = nil;
    video = nil;
    videoHttpUrl = nil;
    self.URL = nil;
    mPlayer = nil;
    mPlayerItem = nil;
    mPlaybackView = nil;
    mToolbar = nil;
    mPrevButton = nil;
    mNextButton = nil;
    mSwitchButton = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WIFI_IS_NOT_AVAILABLE object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    self.view.backgroundColor = [UIColor blackColor];
    [self loadLastPlaytime];
    resolution = GAO_QING;
    [self showPlayVideoView];
    if (isDownloaded) {
        workingUrl = [[NSURL alloc] initFileURLWithPath:[videoUrlsArray objectAtIndex:0]];
        [self setURL:workingUrl];
    } else {
        [self playVideo];
    }
    [self customizeTopToolbar];
    [self customizeBottomToolbar];
    
    episodeListviewController = [[EpisodeListViewController alloc]init];
    [self addChildViewController:episodeListviewController];
    episodeListviewController.type = self.type;
    episodeListviewController.delegate = self;
    episodeListviewController.view.tag = EPISODE_ARRAY_VIEW_TAG;
    episodeListviewController.table.frame = CGRectMake(0, 0, EPISODE_TABLE_WIDTH, 0);
    episodeListviewController.view.frame = CGRectMake(topToolbar.frame.size.width - 20 - EPISODE_TABLE_WIDTH, TOP_TOOLBAR_HEIGHT + 24, EPISODE_TABLE_WIDTH, 0);
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showToolview)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.delegate = self;
    tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapRecognizer];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(wifiNotAvailable) name:WIFI_IS_NOT_AVAILABLE object:nil];
}

- (void) viewDidAppear: (BOOL) animated {
    [super viewDidAppear:animated];
    [ [UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[mPlayer pause];
    [ [UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
}

-(BOOL)shouldAutorotate {
    
    return YES;
    
}

-(NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskLandscape;
    
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationLandscapeRight;
    
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
                } else if (type == 2){
                    video = (NSDictionary *)[result objectForKey:@"tv"];
                } else if (type == 3){
                    video = (NSDictionary *)[result objectForKey:@"show"];
                }
                [self parseVideoData:[video objectForKey:@"episodes"]];
                [self parseCurrentNum];
                [self parseResolutionNum];
                [self willPlayVideo];
            } else {
                [UIUtility showSystemError:self.view];
            }
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            
            [UIUtility showSystemError:self.view];
        }];
    } else {
        [self parseVideoData:[video objectForKey:@"episodes"]];
        [self parseResolutionNum];
        [self showPlayCacheView];
        [self willPlayVideo];
    }
    
}

- (void)willPlayVideo
{
    if(videoUrlsArray.count > 0){
        theLock = [[NSLock alloc]init];
        NSArray *temp = [[videoUrlsArray objectAtIndex:currentNum] objectForKey:resolution];
        if (temp.count > 0) {
            for (NSString *url in temp) {
                int nowDate = [[NSDate date] timeIntervalSince1970];
                NSString *formattedUrl = url;
                if([url rangeOfString:@"{now_date}"].location != NSNotFound){
                    formattedUrl = [url stringByReplacingOccurrencesOfString:@"{now_date}" withString:[NSString stringWithFormat:@"%i", nowDate]];
                }
                NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:formattedUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5];
                [NSURLConnection connectionWithRequest:request delegate:self];
            }
        } else {
            [myHUD hide:NO];
            tipLabel.text = @"即将使用网页播放";
            [self performSelector:@selector(closeSelf) withObject:nil afterDelay:2];
        }
    } else {
        // TODO: should close screen
        [myHUD hide:NO];
        tipLabel.text = @"即将使用网页播放";
        [self performSelector:@selector(closeSelf) withObject:nil afterDelay:2];
    }
}

- (void)parseVideoData:(NSArray *)episodeArray
{
    // 视频地址
    videoUrlsArray = [[NSMutableArray alloc]initWithCapacity:5];
    for (int i = 0; i < episodeArray.count; i++) {
        NSArray *videoUrlArray = [[episodeArray objectAtIndex:i] objectForKey:@"down_urls"];
        if(videoUrlArray.count > 0){
            NSMutableArray *urlsDicArray = [[NSMutableArray alloc]initWithCapacity:5];
            for(NSDictionary *tempVideo in videoUrlArray){
                NSArray *urls = [tempVideo objectForKey:@"urls"];
                [urlsDicArray addObjectsFromArray:urls];
            }
            NSMutableDictionary *urlArrayDictionary = [[NSMutableDictionary alloc]initWithCapacity:3];
            NSMutableArray *gaoqingArray = [[NSMutableArray alloc]initWithCapacity:3];
            NSMutableArray *biaoqingArray = [[NSMutableArray alloc]initWithCapacity:3];
            NSMutableArray *chaoqingArray = [[NSMutableArray alloc]initWithCapacity:3];
            NSMutableArray *liuchangArray = [[NSMutableArray alloc]initWithCapacity:3];
            for (NSDictionary *url in urlsDicArray) {
                NSString *tempType = [url objectForKey:@"type"];
                NSString *tempUrl = [url objectForKey:@"url"];
                if([self validadUrl:tempUrl]){
                    if ([tempType isEqualToString:GAO_QING]) {
                        [gaoqingArray addObject:[tempUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
                    } else if ([tempType isEqualToString:BIAO_QING]) {
                        [biaoqingArray addObject:[tempUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
                    } else if ([tempType isEqualToString:CHAO_QING]) {
                        [chaoqingArray addObject:[tempUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
                    } else if ([tempType isEqualToString:LIU_CHANG]) {
                        [liuchangArray addObject:[tempUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
                    }
                }
            }
            [urlArrayDictionary setValue:gaoqingArray forKey:GAO_QING];
            [biaoqingArray addObjectsFromArray: liuchangArray];//combine biaoqing and liuchang
            [urlArrayDictionary setValue:biaoqingArray forKey:BIAO_QING];
            [urlArrayDictionary setValue:chaoqingArray forKey:CHAO_QING];
            [videoUrlsArray addObject:urlArrayDictionary];
        }
    }
    
    subnameArray = [[NSMutableArray alloc]initWithCapacity:10];
    for (NSDictionary *oneEpisode in episodeArray) {
        NSString *tempName = [NSString stringWithFormat:@"%@", [oneEpisode objectForKey:@"name"]];
        [subnameArray addObject:tempName];
    }
    
}

- (void)parseCurrentNum
{
    if (subnameArray.count > 0) {
        currentNum = [subnameArray indexOfObject:subname];
    }
}

- (void)parseResolutionNum
{
    resolutionNum = 0;
    NSArray *temp = [[videoUrlsArray objectAtIndex:currentNum] objectForKey:CHAO_QING];
    if (temp.count > 0) {
        resolutionNum++;
        resolution = CHAO_QING;
    }
    temp = [[videoUrlsArray objectAtIndex:currentNum] objectForKey:BIAO_QING];
    if (temp.count > 0) {
        resolutionNum++;
        resolution = BIAO_QING;
    }
    temp = [[videoUrlsArray objectAtIndex:currentNum] objectForKey:GAO_QING];
    if (temp.count > 0) {
        resolutionNum++;
        resolution = GAO_QING;
    }
    if (resolutionNum > 1) {
        [qualityBtn setHidden:NO];
    }
    
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"error url");
    [connection cancel];
    //如果所有的视频地址都无效，则播放网页地址
    [self checkIfShowWebView];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    @synchronized(workingUrl){
        if(workingUrl == nil){
            NSDictionary *headerFields = [(NSHTTPURLResponse *)response allHeaderFields];
            NSString *contentLength = [NSString stringWithFormat:@"%@", [headerFields objectForKey:@"Content-Length"]];
            if (contentLength.intValue > 100) {
                NSLog(@"working = %@", connection.originalRequest.URL);
                workingUrl = connection.originalRequest.URL;
//                workingUrl = [NSURL URLWithString:@"http://g3.letv.cn/24/34/17/letv-uts/1759559-AVC-536779-AAC-31586-6836000-502123506-c5c7ddad20556d60749b47b9684ae920-1359970061330.flv?format=0&tag=ios?_r0.13101591216400266"];
                [self performSelectorOnMainThread:@selector(setURL:) withObject:workingUrl waitUntilDone:NO];
                [connection cancel];
            } else {
                [self checkIfShowWebView];
            }
        } 
    }
}

- (void)checkIfShowWebView
{
    [theLock lock];
    errorUrlNum++;
    NSArray *tempArray = [[videoUrlsArray objectAtIndex:currentNum] objectForKey:resolution];
    if (errorUrlNum == tempArray.count) {
        [myHUD hide:NO];
        tipLabel.text = @"即将使用网页播放";
        [self performSelector:@selector(closeSelf) withObject:nil afterDelay:2];
    }
    [theLock unlock];
    
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
    topToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 24, self.view.frame.size.height, TOP_TOOLBAR_HEIGHT)];
    [topToolbar setBackgroundImage:[UIUtility createImageWithColor:[UIColor colorWithRed:30/255.0 green:30/255.0 blue:30/255.0 alpha:0.5] ] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    [self.view addSubview:topToolbar];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(20, 3, 67, 44);
    [closeButton setBackgroundImage:[UIImage imageNamed:@"back_bt"] forState:UIControlStateNormal];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"back_bt_pressed"] forState:UIControlStateHighlighted];
    [closeButton addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
    [topToolbar addSubview:closeButton];
    
    vidoeTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, TOP_TOOLBAR_HEIGHT)];
    vidoeTitle.center = CGPointMake(topToolbar.center.x, TOP_TOOLBAR_HEIGHT/2);
    if (video != nil) {
        name = [video objectForKey:@"name"];
        subname = [subnameArray objectAtIndex:self.currentNum];
    }
    if (type == 2) {
        vidoeTitle.text = [NSString stringWithFormat:@"%@：第%@集", name, subname];
    } else if(type == 3){
        vidoeTitle.text = [NSString stringWithFormat:@"%@：%@", name, subname];
    } else {
        vidoeTitle.text = name;
    }
    vidoeTitle.font = [UIFont boldSystemFontOfSize:18];
    vidoeTitle.textColor = [UIColor lightGrayColor];
    vidoeTitle.backgroundColor = [UIColor clearColor];
    vidoeTitle.textAlignment = UITextAlignmentCenter;
    [topToolbar addSubview:vidoeTitle];
    
    if ((type == 2 || type == 3) && !isDownloaded) {
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
    bottomView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self.view addSubview:bottomView];
    
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
    
    mScrubber = [[UISlider alloc]initWithFrame:CGRectMake(0, 0, bottomView.frame.size.width - currentPlaybackTimeLabel.frame.size.width * 2 - 60 , 10)];
    [mScrubber setEnabled:NO];
    mScrubber.center = CGPointMake(bottomView.center.x, (BOTTOM_TOOL_VIEW_HEIGHT - BOTTOM_TOOLBAR_HEIGHT)/2);
    [mScrubber setThumbImage: [UIImage imageNamed:@"progress_thumb"] forState:UIControlStateNormal];
    [mScrubber addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchCancel];
    [mScrubber addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchUpInside];
    [mScrubber addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchUpOutside];
    [mScrubber addTarget:self action:@selector(beginScrubbing:) forControlEvents:UIControlEventTouchDown];
    [mScrubber addTarget:self action:@selector(scrub:) forControlEvents:UIControlEventTouchDragInside];
    [mScrubber addTarget:self action:@selector(scrub:) forControlEvents:UIControlEventValueChanged];
    [bottomView addSubview:mScrubber];
    
    
    mToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0.0f, BOTTOM_TOOL_VIEW_HEIGHT - BOTTOM_TOOLBAR_HEIGHT, bottomView.frame.size.width, BOTTOM_TOOLBAR_HEIGHT)];
    [mToolbar setBackgroundImage:[UIUtility createImageWithColor:[UIColor colorWithRed:10/255.0 green:10/255.0 blue:10/255.0 alpha:0.8] ] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    [bottomView addSubview:mToolbar];
    
    mSwitchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    mSwitchButton.frame = CGRectMake(20, 25, 29, BUTTON_HEIGHT);
    [mSwitchButton setBackgroundImage:[UIImage imageNamed:@"full_bt"] forState:UIControlStateNormal];
    [mSwitchButton setBackgroundImage:[UIImage imageNamed:@"full_bt_pressed"] forState:UIControlStateHighlighted];
    [mSwitchButton addTarget:self action:@selector(switchBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [mToolbar addSubview:mSwitchButton];
    
    routeBtn = [[MPVolumeView alloc] initWithFrame:CGRectMake(mSwitchButton.frame.origin.x + mSwitchButton.frame.size.width + 20, 25, 37, BUTTON_HEIGHT)];
    [routeBtn setBackgroundColor:[UIColor clearColor]];
    [routeBtn setShowsVolumeSlider:NO];
    [routeBtn setShowsRouteButton:YES];
    for (UIView *asubview in routeBtn.subviews) {
        if ([NSStringFromClass(asubview.class) isEqualToString:@"MPButton"]) {
            UIButton *btn = (UIButton *)asubview;
            btn.frame = CGRectMake(0, 0, 37, BUTTON_HEIGHT);
            [btn setImage:nil forState:UIControlStateNormal];
            [btn setImage:nil forState:UIControlStateHighlighted];
            [btn setImage:nil forState:UIControlStateSelected];
            [btn setBackgroundImage:[UIImage imageNamed:@"route_bt"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"route_bt_pressed"] forState:UIControlStateHighlighted];
            break;
        }
    }
    [mToolbar addSubview:routeBtn];
    
    mPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    mPlayButton.frame = CGRectMake(0, 0, 45, BUTTON_HEIGHT);
    [mPlayButton setHidden:YES];
    [mPlayButton setEnabled:NO];
    mPlayButton.center = CGPointMake(bottomView.frame.size.width/2, BOTTOM_TOOLBAR_HEIGHT/2);
    [mPlayButton setBackgroundImage:[UIImage imageNamed:@"play_bt"] forState:UIControlStateNormal];
    [mPlayButton setBackgroundImage:[UIImage imageNamed:@"play_bt_pressed"] forState:UIControlStateHighlighted];
    [mPlayButton addTarget:self action:@selector(playBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [mToolbar addSubview:mPlayButton];
    
    mStopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    mStopButton.frame = mPlayButton.frame;
    [mStopButton setEnabled:NO];
    [mStopButton setBackgroundImage:[UIImage imageNamed:@"pause_bt"] forState:UIControlStateNormal];
    [mStopButton setBackgroundImage:[UIImage imageNamed:@"pause_bt_pressed"] forState:UIControlStateHighlighted];
    [mStopButton addTarget:self action:@selector(stopBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [mToolbar addSubview:mStopButton];
    
    mPrevButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [mPrevButton setEnabled:NO];
    mPrevButton.frame = CGRectMake(mPlayButton.frame.origin.x - mPlayButton.frame.size.width - 30, mPlayButton.frame.origin.y, mPlayButton.frame.size.width, mPlayButton.frame.size.width);
    [mPrevButton setBackgroundImage:[UIImage imageNamed:@"prev_bt"] forState:UIControlStateNormal];
    [mPrevButton setBackgroundImage:[UIImage imageNamed:@"prev_bt_pressed"] forState:UIControlStateHighlighted];
    [mPrevButton setBackgroundImage:[UIImage imageNamed:@"prev_bt_disabled"] forState:UIControlStateDisabled];
    [mPrevButton addTarget:self action:@selector(prevBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [mToolbar addSubview:mPrevButton];
    
    mNextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [mNextButton setEnabled:NO];
    mNextButton.frame = CGRectMake(mPlayButton.frame.origin.x + mPlayButton.frame.size.width + 30, mPlayButton.frame.origin.y, mPlayButton.frame.size.width, mPlayButton.frame.size.width);
    [mNextButton setBackgroundImage:[UIImage imageNamed:@"next_bt"] forState:UIControlStateNormal];
    [mNextButton setBackgroundImage:[UIImage imageNamed:@"next_bt_pressed"] forState:UIControlStateHighlighted];
    [mNextButton setBackgroundImage:[UIImage imageNamed:@"next_bt_disabled"] forState:UIControlStateDisabled];
    [mNextButton addTarget:self action:@selector(nextBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [mToolbar addSubview:mNextButton];
    
    volumeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    volumeBtn.frame = CGRectMake(mNextButton.frame.origin.x + mNextButton.frame.size.width + 40, mPlayButton.frame.origin.y, 27, BUTTON_HEIGHT);
    [volumeBtn setBackgroundImage:[UIImage imageNamed:@"volume_bt"] forState:UIControlStateNormal];
    [volumeBtn setBackgroundImage:[UIImage imageNamed:@"volume_bt_pressed"] forState:UIControlStateHighlighted];
    [volumeBtn addTarget:self action:@selector(volumeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [mToolbar addSubview:volumeBtn];
    
    volumeSlider = [[MPVolumeView alloc] initWithFrame:CGRectMake(mNextButton.frame.origin.x + mNextButton.frame.size.width + 75, 40, bottomView.frame.size.width - mNextButton.frame.origin.x - mNextButton.frame.size.width - 200, 20)];
    [volumeSlider setBackgroundColor:[UIColor clearColor]];
    [volumeSlider setShowsVolumeSlider:YES];
    [volumeSlider setShowsRouteButton:NO];
    [mToolbar addSubview:volumeSlider];
    
    //    volumeSlider = [[UISlider alloc]initWithFrame:CGRectMake(mNextButton.frame.origin.x + mNextButton.frame.size.width + 75, 40, bottomView.frame.size.width - mNextButton.frame.origin.x - mNextButton.frame.size.width - 200, 20)];
    //    [volumeSlider addTarget:self action:@selector(volumeSliderValueChanged) forControlEvents:UIControlEventValueChanged];
    //    [bottomView addSubview:volumeSlider];
    
    [self initScrubberTimer];
	[self syncPlayPauseButtons];
	[self syncScrubber];
    
    qualityBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [qualityBtn setHidden:YES];
    qualityBtn.frame = CGRectMake(mToolbar.frame.size.width - 100 - 20, mPlayButton.frame.origin.y, 100, BUTTON_HEIGHT);
    [qualityBtn setBackgroundImage:[UIImage imageNamed:@"quality_bt"] forState:UIControlStateNormal];
    [qualityBtn setBackgroundImage:[UIImage imageNamed:@"quality_bt_pressed"] forState:UIControlStateHighlighted];
    [qualityBtn addTarget:self action:@selector(qualityBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [mToolbar addSubview:qualityBtn];
    if (resolutionNum > 1 && !isDownloaded) {
        [qualityBtn setHidden:NO];
    }
}

- (void)resetControlVisibilityTimer
{
    [controlVisibilityTimer invalidate];
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
                [epsideArrayView setHidden:YES];
            }
            [topToolbar setHidden:YES];
            [resolutionPopTipView setHidden:YES];
            [bottomView setHidden:YES];
        }];
    }
}

- (void)showPlayVideoView
{
    mPlayer = nil;
    mPlaybackView = [[AVPlayerView alloc]initWithFrame:CGRectMake(0, 24, self.view.frame.size.height, self.view.frame.size.width - 24)];
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
        playCacheView = [[UIView alloc]initWithFrame:CGRectMake(0, 24, bounds.size.height, bounds.size.width - 24)];
        playCacheView.tag = PLAY_CACHE_VIEW;
        playCacheView.backgroundColor = [UIColor blackColor];
        if (topToolbar) {
            [self.view insertSubview:playCacheView belowSubview:topToolbar];
        } else {
            [self.view addSubview:playCacheView];
        }
        
        nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 400, 40)];
        nameLabel.center = CGPointMake(playCacheView.center.x, playCacheView.center.y * 0.6);
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = [UIFont systemFontOfSize:25];
        if (video != nil) {
            name = [video objectForKey:@"name"];
            subname = [subnameArray objectAtIndex:self.currentNum];
        }
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.textColor = [UIColor whiteColor];
        if (type == 2) {
            nameLabel.text = [NSString stringWithFormat:@"即将播放：%@ 第%@集", name, subname];
            vidoeTitle.text = [NSString stringWithFormat:@"%@：第%@集", name, subname];
        } else if(type == 3){
            nameLabel.text = [NSString stringWithFormat:@"即将播放：%@ %@", name, subname];
            vidoeTitle.text = [NSString stringWithFormat:@"%@：%@", name, subname];
        } else {
            nameLabel.text = [NSString stringWithFormat:@"即将播放：%@",name];
            vidoeTitle.text = [video objectForKey:@"name"];
        }
        [playCacheView addSubview:nameLabel];
        
        tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 500, 40)];
        tipLabel.center = CGPointMake(playCacheView.center.x, playCacheView.center.y * 1.4);
        tipLabel.backgroundColor = [UIColor clearColor];
        tipLabel.font = [UIFont systemFontOfSize:15];
        tipLabel.text = @"正在加载，请稍等";
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.textColor = [UIColor whiteColor];
        [playCacheView addSubview:tipLabel];
        
        myHUD = [[MBProgressHUD alloc] initWithView:playCacheView];
        myHUD.frame = CGRectMake(myHUD.frame.origin.x, myHUD.frame.origin.y + 130, myHUD.frame.size.width, myHUD.frame.size.height);
        [playCacheView addSubview:myHUD];
        myHUD.opacity = 0;
        [myHUD show:YES];
    }
}


- (void)nextBtnClicked
{
    currentNum++;
    [self disablePlayerButtons];
    [self disableScrubber];
    [self preparePlayVideo];
}

- (void)prevBtnClicked
{
    currentNum--;
    [self disablePlayerButtons];
    [self disableScrubber];
    [self preparePlayVideo];
}

- (void)preparePlayVideo
{
    if (currentNum >=0 && currentNum < videoUrlsArray.count) {
        workingUrl = nil;
        [mPlayer pause];
        mPlayer = nil;
        if (video != nil && subnameArray.count > self.currentNum) {
            if (type == 2) {
                subname = [subnameArray objectAtIndex:self.currentNum];
                nameLabel.text = [NSString stringWithFormat:@"即将播放：%@ 第%@集", name, subname];
                vidoeTitle.text = [NSString stringWithFormat:@"%@：第%@集", name, subname];
            } else if(type == 3){
                nameLabel.text = [NSString stringWithFormat:@"即将播放：%@ %@", name, subname];
                vidoeTitle.text = [NSString stringWithFormat:@"%@：%@", name, subname];
            } else {
                nameLabel.text = [NSString stringWithFormat:@"即将播放：%@",name];
                vidoeTitle.text = [video objectForKey:@"name"];
            }
        }
        [self playVideo];
    }
}

#pragma mark
#pragma mark Button Action Methods

- (void)switchBtnClicked
{
    for (UIView *asubview in routeBtn.subviews) {
        if ([NSStringFromClass(asubview.class) isEqualToString:@"MPButton"]) {
            UIButton *btn = (UIButton *)asubview;
            [btn sendActionsForControlEvents:UIControlEventTouchUpInside];
            break;
        }
    }
//    if([((AVPlayerLayer *)[mPlaybackView layer]).videoGravity isEqualToString:AVLayerVideoGravityResizeAspect]){
//        [mSwitchButton setBackgroundImage:[UIImage imageNamed:@"reduce_bt"] forState:UIControlStateNormal];
//        [mSwitchButton setBackgroundImage:[UIImage imageNamed:@"reduce_bt_pressed"] forState:UIControlStateHighlighted];
//        [mPlaybackView setVideoFillMode: AVLayerVideoGravityResizeAspectFill];
//    } else {
//        [mSwitchButton setBackgroundImage:[UIImage imageNamed:@"full_bt"] forState:UIControlStateNormal];
//        [mSwitchButton setBackgroundImage:[UIImage imageNamed:@"full_bt_pressed"] forState:UIControlStateHighlighted];
//        [mPlaybackView setVideoFillMode: AVLayerVideoGravityResizeAspect];
//    }
}

- (void)playBtnClicked:(id)sender
{
	/* If we are at the end of the movie, we must seek to the beginning first
		before starting playback. */
	if (YES == seekToZeroBeforePlay) {
		seekToZeroBeforePlay = NO;
		[mPlayer seekToTime:kCMTimeZero];
	}
    if (CMTIME_IS_VALID(resolutionLastPlaytime)) {
        [mPlayer seekToTime:resolutionLastPlaytime];
        resolutionLastPlaytime = kCMTimeInvalid;
    }
    mPlayer.allowsAirPlayVideo = YES;
	[mPlayer play];
    [self showStopButton];
    [self resetControlVisibilityTimer];
}

- (void)stopBtnClicked:(id)sender
{
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
    [[CacheUtility sharedCache]putInCache:lastPlaytimeCacheKey result: [NSNumber numberWithFloat: CMTimeGetSeconds(mPlayer.currentTime)]];
}


- (void)closeSelf
{
    [self updateWatchRecord];
    [mStopButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    [self saveLastPlaytime];
    mPlayer = nil;
    [controlVisibilityTimer invalidate];
    if (type == 2 || type == 3) {
        [videoWebViewControllerDelegate playNextEpisode:currentNum];
    }
    if (closeAll) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:NO];
    }
}

- (void)showEpisodeListView
{
    [self resetControlVisibilityTimer];
    UIView *epsideArrayView = (UIView *)[self.view viewWithTag:EPISODE_ARRAY_VIEW_TAG];
    if (epsideArrayView) {
        [selectButton setBackgroundImage:[UIImage imageNamed:@"select_bt"] forState:UIControlStateNormal];
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
            episodeListviewController.table.frame = CGRectMake(0, 0, EPISODE_TABLE_WIDTH, 0);
            episodeListviewController.view.frame = CGRectMake(topToolbar.frame.size.width - 20 - EPISODE_TABLE_WIDTH, TOP_TOOLBAR_HEIGHT + 24, EPISODE_TABLE_WIDTH, 0);
        } completion:^(BOOL finished) {
            [epsideArrayView removeFromSuperview];
        }];
    } else {
        [selectButton setBackgroundImage:[UIImage imageNamed:@"select_bt_pressed"] forState:UIControlStateNormal];
        episodeListviewController.currentNum = currentNum;
        episodeListviewController.episodeArray = subnameArray;
        [self.view addSubview:episodeListviewController.view];
        [episodeListviewController.table reloadData];
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
            episodeListviewController.table.frame = CGRectMake(0, 0, EPISODE_TABLE_WIDTH, fmin(10, subnameArray.count) * EPISODE_TABLE_CELL_HEIGHT);
            episodeListviewController.view.frame = CGRectMake(topToolbar.frame.size.width - 20 - EPISODE_TABLE_WIDTH, TOP_TOOLBAR_HEIGHT + 24, EPISODE_TABLE_WIDTH, fmin(10, subnameArray.count) * EPISODE_TABLE_CELL_HEIGHT);
        } completion:^(BOOL finished) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentNum inSection:0];
            [episodeListviewController.table scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
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
        
        NSArray *temp1 = [[videoUrlsArray objectAtIndex:currentNum] objectForKey:BIAO_QING];
        if (temp1.count > 0) {
            biaoqingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            biaoqingBtn.tag = 111001;
            biaoqingBtn.frame = CGRectMake(40, 50, 40, BUTTON_HEIGHT);
            [biaoqingBtn setBackgroundImage:[UIImage imageNamed:@"biaoqing_bt"] forState:UIControlStateNormal];
            [biaoqingBtn setBackgroundImage:[UIImage imageNamed:@"biaoqing_bt_pressed"] forState:UIControlStateHighlighted];
            [biaoqingBtn addTarget:self action:@selector(resolutionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [contentView addSubview:biaoqingBtn];
        }
        
        NSArray *temp2 = [[videoUrlsArray objectAtIndex:currentNum] objectForKey:GAO_QING];
        if (temp2.count > 0) {
            gaoqingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            gaoqingBtn.frame = CGRectMake(160, 50, 40, BUTTON_HEIGHT);
            gaoqingBtn.tag = 111002;
            [gaoqingBtn setBackgroundImage:[UIImage imageNamed:@"gaoqing_bt_pressed"] forState:UIControlStateNormal];
            [gaoqingBtn setBackgroundImage:[UIImage imageNamed:@"gaoqing_bt_pressed"] forState:UIControlStateHighlighted];
            [gaoqingBtn addTarget:self action:@selector(resolutionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [contentView addSubview:gaoqingBtn];
        }
        
        NSArray *temp3 = [[videoUrlsArray objectAtIndex:currentNum] objectForKey:CHAO_QING];
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
        resolutionPopTipView = [[CMPopTipView alloc] initWithCustomView:contentView];
        resolutionPopTipView.backgroundColor = [UIColor colorWithRed:10/255.0 green:10/255.0 blue:10/255.0 alpha:1];
        //    resolutionPopTipView.delegate = self;
        resolutionPopTipView.disableTapToDismiss = YES;
        resolutionPopTipView.animation = CMPopTipAnimationPop;
        [resolutionPopTipView presentPointingAtView:btn inView:self.view animated:YES];
        resolutionPopTipView.frame = CGRectMake(bottomView.frame.size.width - resolutionPopTipView.frame.size.width, resolutionPopTipView.frame.origin.y - 70, resolutionPopTipView.frame.size.width, resolutionPopTipView.frame.size.height);
    }
}

- (void)resolutionBtnClicked:(UIButton *)btn
{
    [self resetControlVisibilityTimer];
    [biaoqingBtn setBackgroundImage:[UIImage imageNamed:@"biaoqing_bt"] forState:UIControlStateNormal];
    [gaoqingBtn setBackgroundImage:[UIImage imageNamed:@"gaoqing_bt"] forState:UIControlStateNormal];
    [chaoqingBtn setBackgroundImage:[UIImage imageNamed:@"chaoqing_bt"] forState:UIControlStateNormal];
    if (btn.tag == 111001) {
        resolution = BIAO_QING;
        [btn setBackgroundImage:[UIImage imageNamed:@"biaoqing_bt_pressed"] forState:UIControlStateNormal];
    } else if (btn.tag == 111002) {
        resolution = GAO_QING;
        [btn setBackgroundImage:[UIImage imageNamed:@"gaoqing_bt_pressed"] forState:UIControlStateNormal];
    } else if (btn.tag == 111003) {
        resolution = CHAO_QING;
        [btn setBackgroundImage:[UIImage imageNamed:@"chaoqing_bt_pressed"] forState:UIControlStateNormal];
    }
    [qualityBtn setBackgroundImage:[UIImage imageNamed:@"quality_bt"] forState:UIControlStateNormal];
    [resolutionPopTipView dismissAnimated:YES];
    resolutionPopTipView = nil;
    resolutionLastPlaytime = [mPlayer currentTime];
    [self preparePlayVideo];
}

- (void)volumeBtnClicked:(UIButton *)btn
{
    //    AVURLAsset *asset = [[mPlayer currentItem] asset];
    //    NSArray *audioTracks = [asset tracksWithMediaType:AVMediaTypeAudio];
    //
    //    // Mute all the audio tracks
    //    NSMutableArray *allAudioParams = [NSMutableArray array];
    //    for (AVAssetTrack *track in audioTracks) {
    //        AVMutableAudioMixInputParameters *audioInputParams =    [AVMutableAudioMixInputParameters audioMixInputParameters];
    //        [audioInputParams setVolume:0.0 atTime:kCMTimeZero];
    //        [audioInputParams setTrackID:[track trackID]];
    //        [allAudioParams addObject:audioInputParams];
    //    }
    //    AVMutableAudioMix *audioZeroMix = [AVMutableAudioMix audioMix];
    //    [audioZeroMix setInputParameters:allAudioParams];
    //
    //    [[mPlayer currentItem] setAudioMix:audioZeroMix];
    
    //    float volume = 0.0f;
    //
    //    AVPlayerItem *currentItem = mPlayer.currentItem;
    //    NSArray *audioTracks = mPlayer.currentItem.tracks;
    //
    //    NSMutableArray *allAudioParams = [NSMutableArray array];
    //
    //    for (AVPlayerItemTrack *track in audioTracks)
    //    {
    //        if ([track.assetTrack.mediaType isEqual:AVMediaTypeAudio])
    //        {
    //            AVMutableAudioMixInputParameters *audioInputParams = [AVMutableAudioMixInputParameters audioMixInputParameters];
    //            [audioInputParams setVolume:volume atTime:kCMTimeZero];
    //            [audioInputParams setTrackID:[track.assetTrack trackID]];
    //            [allAudioParams addObject:audioInputParams];
    //        }
    //    }
    //
    //    if ([allAudioParams count] > 0) {
    //        AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    //        [audioMix setInputParameters:allAudioParams];
    //        [currentItem setAudioMix:audioMix];
    //    }
    //    [mPlayer play];
    
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
        
        subname = [subnameArray objectAtIndex:currentNum];
        NSString *userId = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId];
        NSString *tempPlayType = @"1";
        NSString *tempUrl = workingUrl.absoluteString; //This url should be useless. In order to simplify the replay logic, we will don't use the url any more.
        NSLog(@"%@", tempUrl);
        if (workingUrl == nil) {
            tempPlayType = @"2";
            tempUrl = videoHttpUrl;
        }
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: userId, @"userid", self.prodId, @"prod_id", [video objectForKey:@"name"], @"prod_name", subname, @"prod_subname", [NSNumber numberWithInt:self.type], @"prod_type", tempPlayType, @"play_type", [NSNumber numberWithInt:playbackTime], @"playback_time", [NSNumber numberWithInt:duration], @"duration", tempUrl, @"video_url", nil];
        [[AFServiceAPIClient sharedClient] postPath:kPathAddPlayHistory parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [[CacheUtility sharedCache] removeObjectForKey:WATCH_RECORD_CACHE_KEY];
            [[NSNotificationCenter defaultCenter] postNotificationName:WATCH_HISTORY_REFRESH object:nil];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"zz%@", error);
        }];
    }
}

- (void)loadLastPlaytime
{
    NSString *lastPlaytimeCacheKey;
    if (type == 1) {
        lastPlaytimeCacheKey = [NSString stringWithFormat:@"%@", self.prodId];
    } else {
        lastPlaytimeCacheKey = [NSString stringWithFormat:@"%@_%@", self.prodId, subname];
    }
    NSNumber *seconds = [[CacheUtility sharedCache]loadFromCache:lastPlaytimeCacheKey];
    lastPlayTime = CMTimeMakeWithSeconds(seconds.doubleValue, NSEC_PER_SEC);
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
        
        NSArray *requestedKeys = [NSArray arrayWithObjects:kTracksKey, kPlayableKey, nil];
        
        /* Tells the asset to load the values of any of the specified keys that are not already loaded. */
        [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
         ^{
             dispatch_async( dispatch_get_main_queue(),
                            ^{
                                /* IMPORTANT: Must dispatch to main queue in order to operate on the AVPlayer and AVPlayerItem. */
                                [self prepareToPlayAsset:asset withKeys:requestedKeys];
                            });
         }];
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
    [qualityBtn setEnabled:YES];
    if (subnameArray.count > 0 && type != 1){
        if (currentNum == 0) {
            [mPrevButton setEnabled:NO];
            [mNextButton setEnabled:YES];
        } else if(currentNum == subnameArray.count - 1) {
            [mPrevButton setEnabled:YES];
            [mNextButton setEnabled:NO];
        } else if(currentNum > 0 && currentNum < subnameArray.count){
            [mPrevButton setEnabled:YES];
            [mNextButton setEnabled:YES];
        }
    } else {
        [mPrevButton setEnabled:NO];
        [mNextButton setEnabled:NO];
    }
}

-(void)disablePlayerButtons
{
    [qualityBtn setEnabled:NO];
    self.mPlayButton.enabled = NO;
    self.mStopButton.enabled = NO;
    [mPrevButton setEnabled:NO];
    [mNextButton setEnabled:NO];
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

	/* Update the scrubber during normal playback. */
	mTimeObserver = [mPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
								queue:NULL /* If you pass NULL, the main queue is used. */
								usingBlock:^(CMTime time) 
                                            {
                                                [self syncScrubber];
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

			mTimeObserver = [mPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC) queue:NULL usingBlock:
			^(CMTime time)
			{
				[self syncScrubber];
			}];
		}
	}

	if (mRestoreAfterScrubbingRate)
	{
		[mPlayer setRate:mRestoreAfterScrubbingRate];
		mRestoreAfterScrubbingRate = 0.f;
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

- (void)playOneEpisode:(int)num
{
    currentNum = num;
    [self resetControlVisibilityTimer];
    [self preparePlayVideo];
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

#pragma mark -
#pragma mark Loading the Asset Keys Asynchronously

#pragma mark -
#pragma mark Error Handling - Preparing Assets for Playback Failed

/* --------------------------------------------------------------
 **  Called when an asset fails to prepare for playback for any of
 **  the following reasons:
 ** 
 **  1) values of asset keys did not load successfully, 
 **  2) the asset keys did load successfully, but the asset is not 
 **     playable
 **  3) the item did not become ready to play. 
 ** ----------------------------------------------------------- */

-(void)assetFailedToPrepareForPlayback:(NSError *)error
{
    [self removePlayerTimeObserver];
    [self syncScrubber];
    [self disableScrubber];
    [self disablePlayerButtons];
    
    /* Display the error. */
//	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
//														message:[error localizedFailureReason]
//													   delegate:nil
//											  cancelButtonTitle:@"OK"
//											  otherButtonTitles:nil];
//	[alertView show];
    [myHUD hide:NO];
    tipLabel.text = @"即将使用网页播放";
    [self performSelector:@selector(closeSelf) withObject:nil afterDelay:2];
}


#pragma mark Prepare to play asset, URL

/*
 Invoked at the completion of the loading of the values for all keys on the asset that we require.
 Checks whether loading was successfull and whether the asset is playable.
 If so, sets up an AVPlayerItem and an AVPlayer to play the asset.
 */
- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys
{
    /* Make sure that the value of each key has loaded successfully. */
	for (NSString *thisKey in requestedKeys)
	{
		NSError *error = nil;
		AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
		if (keyStatus == AVKeyValueStatusFailed)
		{
			[self assetFailedToPrepareForPlayback:error];
			return;
		}
		/* If you are also implementing -[AVAsset cancelLoading], add your code here to bail out properly in the case of cancellation. */
	}
    
    /* Use the AVAsset playable property to detect whether the asset can be played. */
    if (!asset.playable) 
    {
        /* Generate an error describing the failure. */
		NSString *localizedDescription = NSLocalizedString(@"Item cannot be played", @"Item cannot be played description");
		NSString *localizedFailureReason = NSLocalizedString(@"The assets tracks were loaded, but could not be made playable.", @"Item cannot be played failure reason");
		NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
								   localizedDescription, NSLocalizedDescriptionKey, 
								   localizedFailureReason, NSLocalizedFailureReasonErrorKey, 
								   nil];
		NSError *assetCannotBePlayedError = [NSError errorWithDomain:@"StitchedStreamPlayer" code:0 userInfo:errorDict];
        
        /* Display the error to the user. */
        [self assetFailedToPrepareForPlayback:assetCannotBePlayedError];
        
        return;
    }
	
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
    
    /* Observe the player item "status" key to determine when it is ready to play. */
    [self.mPlayerItem addObserver:self 
                      forKeyPath:kStatusKey 
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:AVPlayerDemoPlaybackViewControllerStatusObservationContext];
	
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
        [mPlayer seekToTime:lastPlayTime];
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
	
    [mScrubber setValue:0.0];
}

#pragma mark -
#pragma mark Asset Key Value Observing
#pragma mark

#pragma mark Key Value Observer for player rate, currentItem, player item status

/* ---------------------------------------------------------
**  Called when the value at the specified key path relative
**  to the given object has changed. 
**  Adjust the movie play and pause button controls when the 
**  player item "status" value changes. Update the movie 
**  scrubber control when the player item is ready to play.
**  Adjust the movie scrubber control when the player item 
**  "rate" value changes. For updates of the player
**  "currentItem" property, set the AVPlayer for which the 
**  player layer displays visual output.
**  NOTE: this method is invoked on the main queue.
** ------------------------------------------------------- */

- (void)observeValueForKeyPath:(NSString*) path 
			ofObject:(id)object 
			change:(NSDictionary*)change 
			context:(void*)context
{
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
    
    if (mPlayer.airPlayVideoActive) {
        UIView *tempView = [mPlaybackView viewWithTag:9585403];
        if (tempView == nil) {
            [mPlaybackView addSubview:applyTvView];
        }
        for (UIView *asubview in routeBtn.subviews) {
            if ([NSStringFromClass(asubview.class) isEqualToString:@"MPButton"]) {
                UIButton *btn = (UIButton *)asubview;
                [btn setBackgroundImage:[UIImage imageNamed:@"route_bt_light"] forState:UIControlStateNormal];
                break;
            }
        }
    } else {
        UIView *tempView = [mPlaybackView viewWithTag:9585403];
        [tempView removeFromSuperview];
        for (UIView *asubview in routeBtn.subviews) {
            if ([NSStringFromClass(asubview.class) isEqualToString:@"MPButton"]) {
                UIButton *btn = (UIButton *)asubview;
                [btn setBackgroundImage:[UIImage imageNamed:@"route_bt"] forState:UIControlStateNormal];
                break;
            }
        }
    }
    
	/* AVPlayerItem "status" property value observer. */
	if (context == AVPlayerDemoPlaybackViewControllerStatusObservationContext)
	{
		[self syncPlayPauseButtons];

        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
            /* Indicates that the status of the player is not yet known because 
             it has not tried to load new media resources for playback */
            case AVPlayerStatusUnknown:
            {
                [self removePlayerTimeObserver];
                [self syncScrubber];
                
                [self disableScrubber];
                [self disablePlayerButtons];
            }
            break;
                
            case AVPlayerStatusReadyToPlay:
            {
                /* Once the AVPlayerItem becomes ready to play, i.e.
                 [playerItem status] == AVPlayerItemStatusReadyToPlay,
                 its duration can be fetched from the item. */
                CMTime playerDuration = [self playerItemDuration];
                double duration = 0;
                if (CMTIME_IS_VALID(playerDuration)) {
                    duration = CMTimeGetSeconds(playerDuration);
                }
                totalTimeLabel.text = [TimeUtility formatTimeInSecond:duration];
                currentPlaybackTimeLabel.text = [TimeUtility formatTimeInSecond:CMTimeGetSeconds(mPlayerItem.currentTime)];
                
                [self initScrubberTimer];
                [self enableScrubber];
                [self enablePlayerButtons];
                [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
                    for (UIView *subview in playCacheView.subviews) {
                        [subview setAlpha:0];
                    }
                    [playCacheView setAlpha:0];
                } completion:^(BOOL finished) {
                    [playCacheView removeFromSuperview];
                    [playCacheView setHidden:YES];
                    playCacheView = nil;
                    [self resetControlVisibilityTimer];
                    [mPlayButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                }];
            }
            break;
                
            case AVPlayerStatusFailed:
            {
                AVPlayerItem *playerItem = (AVPlayerItem *)object;
                [self assetFailedToPrepareForPlayback:playerItem.error];
            }
            break;
        }
	}
	/* AVPlayer "rate" property value observer. */
	else if (context == AVPlayerDemoPlaybackViewControllerRateObservationContext)
	{
        [self syncPlayPauseButtons];
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
            
            /* Specifies that the player should preserve the video’s aspect ratio and
             fit the video within the layer’s bounds. */
            [mPlaybackView setVideoFillMode:AVLayerVideoGravityResizeAspect];
            
            [self syncPlayPauseButtons];
        }
	}
	else
	{
		[super observeValueForKeyPath:path ofObject:object change:change context:context];
	}
}

//=====================Utility methods========================

- (void)wifiNotAvailable
{
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil
                                                       message:@"当前网络为非Wifi环境，您确定要继续播放吗？"
                                                      delegate:self
                                             cancelButtonTitle:@"取消"
                                             otherButtonTitles:@"确定", nil];
    [alertView show];
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
//=====================End Utility methods========================
@end

