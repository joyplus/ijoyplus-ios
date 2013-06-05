//
//  HomeViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-20.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "PopularTopViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DDPageControl.h"
#import "MovieDetailViewController.h"
#import "DramaDetailViewController.h"
#import "ShowDetailViewController.h"
#import "ListViewController.h"
#import "SubsearchViewController.h"
#import "CommonHeader.h" 

#define TOP_IMAGE_HEIGHT 170
#define VIDEO_BUTTON_WIDTH 120
#define VIDEO_BUTTON_HEIGHT 45
#define TOP_SOLGAN_HEIGHT 93
#define SHOW_LOGO_HEIGHT 125
#define SHOW_LOGO_WEIGHT 486
#define MOVIE_NUMBER 10
#define DRAMA_NUMBER 10

@interface PopularTopViewController (){
    UIScrollView *scrollView;
    UIImageView *sloganImageView;
    UITableView *table;
    DDPageControl *pageControl;
    NSArray *lunboArray;
    PullRefreshManagerClinet *showPullToRefreshManager_;
    NSUInteger showReloads;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    int pageSize;
    int selectedRowNumber;
    NSTimer *timer;
    UIImageView *lastSelectedOverlay;
    NSString *umengPageName;
}
@property (nonatomic, strong) UIView *customHeaderView;
@property (nonatomic, strong) UIButton *movieListBtn;
@property (nonatomic, strong) UIButton *dramaListBtn;
@property (nonatomic, strong) UIButton *comicListBtn;
@property (nonatomic, strong) UIButton *showListBtn;
@property (nonatomic) TopType topType; // 1: 电影悦榜 2: 电视剧悦榜 3:动漫 4:综艺
@property (nonatomic, strong) NSMutableArray *movieTopsArray;
@property (nonatomic, strong) NSMutableArray *tvTopsArray;
@property (nonatomic, strong) NSMutableArray *comicTopsArray;
@property (nonatomic, strong) NSMutableArray *showTopsArray;
@property (nonatomic) int showTopicId;

- (void)setAutoScrollTimer;
- (void)cancelAutoScrollTimer;

@end

@implementation PopularTopViewController
@synthesize customHeaderView, movieListBtn, dramaListBtn, topType, comicListBtn, showListBtn;
@synthesize movieTopsArray, tvTopsArray, comicTopsArray, showTopsArray;
@synthesize showTopicId;

- (void)viewDidUnload{
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (id)initWithFrame:(CGRect)frame {
    if (self = [super init]) {
		[self.view setFrame:frame];
        [self.view setBackgroundColor:[UIColor clearColor]];
        
        sloganImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"slogan"]];
        sloganImageView.frame = CGRectMake(15, 36, 316, 42);
        [self.view addSubview:sloganImageView];
        
        table = [[UITableView alloc] initWithFrame:CGRectMake(3, 92, self.view.frame.size.width - 16, self.view.frame.size.height - TOP_SOLGAN_HEIGHT - 20) style:UITableViewStylePlain];
        [table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
		[table setDelegate:self];
		[table setDataSource:self];
        [table setBackgroundColor:[UIColor clearColor]];
        [table setShowsVerticalScrollIndicator:NO];
		[self.view addSubview:table];
        
        showPullToRefreshManager_ = [[PullRefreshManagerClinet alloc] initWithTableView:table];
        showPullToRefreshManager_.delegate = self;
        [showPullToRefreshManager_ setShowHeaderView:NO];
        showReloads = 2;
        if (_refreshHeaderView == nil) {
            EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - table.bounds.size.height, self.view.frame.size.width, table.bounds.size.height)];
            view.backgroundColor = [UIColor clearColor];
            view.delegate = self;
            [table addSubview:view];
            _refreshHeaderView = view;
            
        }
        //[_refreshHeaderView refreshLastUpdatedDate];
	}
    return self;
}

- (void)loadTable {
    [table reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (0 == lunboArray.count)
    {
        [self retrieveLunboData];
    }
    if (0 == movieTopsArray.count)
    {
        [self retrieveMovieTopsData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[AppDelegate instance].rootViewController showIntroModalView:SHOW_MENU_INTRO introImage:[UIImage imageNamed:@"menu_intro_yuebang"]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (umengPageName) {
        [MobClick endLogPageView:umengPageName];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self setAutoScrollTimer];
    
    pageSize = 20;
    topType = MOVIE_TOP;
    movieTopsArray = [[NSMutableArray alloc]initWithCapacity:pageSize];
    tvTopsArray = [[NSMutableArray alloc]initWithCapacity:pageSize];
    comicTopsArray = [[NSMutableArray alloc]initWithCapacity:pageSize];
    showTopsArray = [[NSMutableArray alloc]initWithCapacity:pageSize];
    
    [self performSelectorInBackground:@selector(transferDataFromOldDb) withObject:nil];
}

- (void)transferDataFromOldDb
{
    transferDataFromOldDbWithCatch();
}

void transferDataFromOldDbWithCatch()
{
    @try {
        [DatabaseManager transferFinishedDownloadFiles];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
}

- (void)retrieveLunboData
{
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:@"lunbo_list"];
    if(cacheResult != nil){
        [self parseLunboData:cacheResult];
    }
    //Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: nil];
        [[AFServiceAPIClient sharedClient] getPath:kPathLunbo parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [self parseLunboData:result];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
        }];
    }
}

- (void)parseLunboData:(id)result
{
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        lunboArray = [result objectForKey:@"results"];
        if(lunboArray.count > 0){
            [[CacheUtility sharedCache] putInCache:@"lunbo_list" result:result];
            [table reloadData];
        }
    }
}


- (void)retrieveMovieTopsData
{
    if (umengPageName) {
        [MobClick endLogPageView:umengPageName];
    }
    umengPageName = POPULAR_MOVIE_TOP_LIST;
    [MobClick beginLogPageView:umengPageName];
    //Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:@"movie_top_list"];
    if(cacheResult != nil){
        [self parseMovieTopsData:cacheResult];
    } else {
        [myHUD showProgressBar:self.view];
    }
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [myHUD hide];
        [UIUtility showNetWorkError:self.view];
    } else {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: @"1", @"page_num", [NSNumber numberWithInt:10], @"page_size", nil];
        [[AFServiceAPIClient sharedClient] getPath:kPathMoiveTops parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [self parseMovieTopsData:result];
            [myHUD hide];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
            [myHUD hide];
            [UIUtility showDetailError:self.view error:error];
        }];
    }
}

- (void)parseMovieTopsData:(id)result
{
    [movieTopsArray removeAllObjects];
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        NSArray *tempTopsArray = [result objectForKey:@"tops"];
        if(tempTopsArray.count > 0){
            [[CacheUtility sharedCache] putInCache:@"movie_top_list" result:result];
            [movieTopsArray addObjectsFromArray:tempTopsArray];
        }
    } else {
        [UIUtility showSystemError:self.view];
    }
    [table reloadData];
}


- (void)retrieveTvTopsData
{
    if (umengPageName) {
        [MobClick endLogPageView:umengPageName];
    }
    umengPageName = POPULAR_TV_TOP_LIST;
    [MobClick beginLogPageView:umengPageName];
    //Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:@"tv_top_list"];
    if(cacheResult != nil){
        [self parseTvTopsData:cacheResult];
    } else {
        [myHUD showProgressBar:self.view];
    }
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [myHUD hide];
        [UIUtility showNetWorkError:self.view];
    } else {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: @"1", @"page_num", [NSNumber numberWithInt:10], @"page_size", nil];
        [[AFServiceAPIClient sharedClient] getPath:kPathTvTops parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [self parseTvTopsData:result];
            [myHUD hide];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            [myHUD hide];
            [UIUtility showDetailError:self.view error:error];
        }];
    }
}

- (void)parseTvTopsData:(id)result
{
    [tvTopsArray removeAllObjects];
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        NSArray *tempTopsArray = [result objectForKey:@"tops"];
        if(tempTopsArray.count > 0){
            [[CacheUtility sharedCache] putInCache:@"tv_top_list" result:result];
            [tvTopsArray addObjectsFromArray:tempTopsArray];
        }
    } else {
        [UIUtility showSystemError:self.view];
    }
    [table reloadData];
}


- (void)retrieveComicTopsData
{
    if (umengPageName) {
        [MobClick endLogPageView:umengPageName];
    }
    umengPageName = POPULAR_COMIC_TOP_LIST;
    [MobClick beginLogPageView:umengPageName];
    //Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:@"comic_top_list"];
    if(cacheResult != nil){
        [self parseComicTopsData:cacheResult];
    } else {
        [myHUD showProgressBar:self.view];
    }
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [myHUD hide];
        [UIUtility showNetWorkError:self.view];
    } else {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: @"1", @"page_num", [NSNumber numberWithInt:10], @"page_size", nil];
        [[AFServiceAPIClient sharedClient] getPath:kPathComicTops parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [self parseComicTopsData:result];
            [myHUD hide];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
            [myHUD hide];
            [UIUtility showDetailError:self.view error:error];
        }];
    }
}

- (void)parseComicTopsData:(id)result
{
    [comicTopsArray removeAllObjects];
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        NSArray *tempTopsArray = [result objectForKey:@"tops"];
        if(tempTopsArray.count > 0){
            [[CacheUtility sharedCache] putInCache:@"comic_top_list" result:result];
            [comicTopsArray addObjectsFromArray:tempTopsArray];
        }
    } else {
        [UIUtility showSystemError:self.view];
    }
    [table reloadData];
}



- (void)retrieveShowTopsData
{
    if (umengPageName) {
        [MobClick endLogPageView:umengPageName];
    }
    umengPageName = POPULAR_SHOW_TOP_LIST;
    [MobClick beginLogPageView:umengPageName];
    //Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:@"show_top_list"];
    if(cacheResult != nil){
        [self parseShowTopsData:cacheResult];
    }  else {
        [myHUD showProgressBar:self.view];
    }
    showReloads = 2;
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [myHUD hide];
        [UIUtility showNetWorkError:self.view];
    } else {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: @"1", @"page_num", [NSNumber numberWithInt:10], @"page_size", nil];
        [[AFServiceAPIClient sharedClient] getPath:kPathShowTops parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [self parseShowTopsData:result];
            [myHUD hide];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
            [myHUD hide];
            [UIUtility showDetailError:self.view error:error];
        }];
    }
}

- (void)parseShowTopsData:(id)result
{
    [showTopsArray removeAllObjects];
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        NSArray *tempTopsArray = [result objectForKey:@"tops"];
        if(tempTopsArray.count > 0){
            showTopicId = [[[tempTopsArray objectAtIndex:0] objectForKey:@"id"] integerValue];
            NSArray *tempArray = [[tempTopsArray objectAtIndex:0] objectForKey:@"items"];
            if(tempArray.count > 0) {
                [[CacheUtility sharedCache] putInCache:@"show_top_list" result:result];
                [showTopsArray addObjectsFromArray:tempArray];
            }
            if (tempArray.count < 10) {
                 showPullToRefreshManager_.canLoadMore = NO;
            }
            else{
                showPullToRefreshManager_.canLoadMore = YES;
            }
        }
    } else {
        [UIUtility showSystemError:self.view];
    }
    [self loadTable];
}

- (void)reloadTableViewDataSource{
    showReloads = 2;
//    -    [[CacheUtility sharedCache]removeObjectForKey: @"lunbo_list"];
//    -    [[CacheUtility sharedCache]removeObjectForKey: @"movie_top_list"];
//    -    [[CacheUtility sharedCache]removeObjectForKey: @"tv_top_list"];
//    -    [[CacheUtility sharedCache]removeObjectForKey: @"show_top_list"];
//    -    [[CacheUtility sharedCache]removeObjectForKey: @"comic_top_list"];
    [self retrieveLunboData];
    if(topType == MOVIE_TOP){
        [self retrieveMovieTopsData];
    } else if(topType == DRAMA_TOP){
        [self retrieveTvTopsData];
    } else if(topType == COMIC_TOP){
        [self retrieveComicTopsData];
    } else if(topType == SHOW_TOP){
        [self retrieveShowTopsData];
    }
    _reloading = YES;
}


- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:table];
	
}

- (void)setAutoScrollTimer
{
    if (nil == timer)
    {
        timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(updateScrollView) userInfo:nil repeats:YES];
    }
}
- (void)cancelAutoScrollTimer
{
    if (timer)
    {
        [timer invalidate];
        timer = nil;
    }
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
    [table reloadData];
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

- (void)pulltoLoadMore {
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [UIUtility showNetWorkError:self.view];
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:0.0f];
        return;
    }
    if (topType == SHOW_TOP) {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:showReloads], @"page_num", [NSNumber numberWithInt:10], @"page_size", [NSNumber numberWithInt:showTopicId], @"top_id", nil];
        [[AFServiceAPIClient sharedClient] getPath:kPathShowTopItems parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            NSString *responseCode = [result objectForKey:@"res_code"];
            NSArray *tempTopsArray;
            if(responseCode == nil){
                tempTopsArray = [result objectForKey:@"items"];
                if(tempTopsArray.count > 0){
                    [showTopsArray addObjectsFromArray:tempTopsArray];
                    showReloads ++;
                }
            } else {
                
            }
            [self performSelector:@selector(loadTable) withObject:nil afterDelay:0.0f];
            if(tempTopsArray.count < 10){
                showPullToRefreshManager_.canLoadMore = NO;
            }
            else{
                 showPullToRefreshManager_.canLoadMore = YES;
                
            }
            [showPullToRefreshManager_ loadMoreCompleted];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            [self performSelector:@selector(loadTable) withObject:nil afterDelay:0.0f];
        }];
    }
    
}

- (void)refreshCompleted {
        [table reloadData];
        [showPullToRefreshManager_ refreshCompleted];
}

- (void)updateScrollView
{
    if(pageControl.currentPage >= pageControl.numberOfPages-1){
        [pageControl setCurrentPage:0];
    } else {
        pageControl.currentPage++;
    }
    [scrollView setContentOffset: CGPointMake(scrollView.bounds.size.width * pageControl.currentPage, scrollView.contentOffset.y) animated: YES] ;
}

- (void)pageControlClicked:(id)sender
{
	DDPageControl *thePageControl = (DDPageControl *)sender ;
	[scrollView setContentOffset: CGPointMake(scrollView.bounds.size.width * thePageControl.currentPage, scrollView.contentOffset.y) animated: YES] ;
}


- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
        [showPullToRefreshManager_ scrollViewBegin];
}


- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    if(aScrollView.tag == 11270014){
        [self cancelAutoScrollTimer];
        CGFloat pageWidth = scrollView.bounds.size.width ;
        float fractionalPage = scrollView.contentOffset.x / pageWidth ;
        NSInteger nearestNumber = lround(fractionalPage) ;
        
        if (pageControl.currentPage != nearestNumber)
        {
            pageControl.currentPage = nearestNumber ;
            // if we are dragging, we want to update the page control directly during the drag
            if (scrollView.dragging)
                [pageControl updateCurrentPageDisplay] ;
        }
    } else {
        [_refreshHeaderView egoRefreshScrollViewDidScroll:aScrollView];
        if(topType == SHOW_TOP){
            [showPullToRefreshManager_ scrollViewScrolled:aScrollView];
        }         
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)aScrollView
{
	if(aScrollView.tag == 11270014){
        [pageControl updateCurrentPageDisplay];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)aScrollView willDecelerate:(BOOL)decelerate {
    if(aScrollView.tag == 11270014){
    } else {
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:aScrollView];
        if(topType == SHOW_TOP){
           [showPullToRefreshManager_ scrollViewEnd:aScrollView];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)ascrollView
{
    if(ascrollView.tag == 1011){
        UIView *cellView = ascrollView.superview;
        UIButton *leftScrollBtn = (UIButton *)[cellView viewWithTag:5011];
        UIButton *rightScrollBtn = (UIButton *)[cellView viewWithTag:5012];
        if (ascrollView.contentOffset.x > 10) {
            [leftScrollBtn setEnabled:YES];
            [rightScrollBtn setEnabled:NO];
        } else {
            [leftScrollBtn setEnabled:NO];
            [rightScrollBtn setEnabled:YES];
        }
    }
    else if(ascrollView.tag == 11270014)
    {
        [self setAutoScrollTimer];
    }
}


- (void)movieListBtnClicked:(UIButton *)sender
{
    [[AppDelegate instance].rootViewController.stackScrollViewController removeViewToViewInSlider:AdViewController.class];
    BOOL isReachable = [[AppDelegate instance] performSelector:@selector(isParseReachable)];
    if(!isReachable) {
        [UIUtility showNetWorkError:self.view];
    }
    topType = MOVIE_TOP;
    [self initTopButtonImage];
    [self retrieveMovieTopsData];
}

- (void)dramaListBtnClicked:(UIButton *)sender
{
    [[AppDelegate instance].rootViewController.stackScrollViewController removeViewToViewInSlider:AdViewController.class];
    BOOL isReachable = [[AppDelegate instance] performSelector:@selector(isParseReachable)];
    if(!isReachable) {
        [UIUtility showNetWorkError:self.view];
    }
    topType = DRAMA_TOP;
    [self initTopButtonImage];
    [self retrieveTvTopsData];
}

- (void)showListBtnClicked:(UIButton *)sender
{
    [[AppDelegate instance].rootViewController.stackScrollViewController removeViewToViewInSlider:AdViewController.class];

    BOOL isReachable = [[AppDelegate instance] performSelector:@selector(isParseReachable)];
    if(!isReachable) {
        [UIUtility showNetWorkError:self.view];
    }
    topType = SHOW_TOP;
    [self initTopButtonImage];
    [self retrieveShowTopsData];
}

- (void)comicListBtnClicked:(UIButton *)sender
{
    [[AppDelegate instance].rootViewController.stackScrollViewController removeViewToViewInSlider:AdViewController.class];

    BOOL isReachable = [[AppDelegate instance] performSelector:@selector(isParseReachable)];
    if(!isReachable) {
        [UIUtility showNetWorkError:self.view];
    }
    topType = COMIC_TOP;
    [self initTopButtonImage];
    [self retrieveComicTopsData];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        return 1;
    } else {
        if (topType == MOVIE_TOP) {
            return movieTopsArray.count;
        } else if (topType == DRAMA_TOP){
            return tvTopsArray.count;
        } else if (topType == COMIC_TOP){
            return comicTopsArray.count;
        } else if (topType == SHOW_TOP){
            return showTopsArray.count;
        } else {
            return 0;
        }
    }
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if(indexPath.section == 0){
        static NSString *CellIdentifier = @"topImageCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            [cell setSelectionStyle:UITableViewCellEditingStyleNone];
            UIImageView *lunboPlaceholder = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, table.frame.size.width, TOP_IMAGE_HEIGHT)];
            lunboPlaceholder.image = [UIImage imageNamed:@"top_image_placeholder"];
            [cell.contentView addSubview:lunboPlaceholder];
            
            scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 4, table.frame.size.width+6, TOP_IMAGE_HEIGHT - 8)];
            scrollView.tag = 11270014;
            scrollView.delegate = self;
            
            
            CGSize size = scrollView.frame.size;
            for (int i=0; i < 5; i++) {
                UIImageView *temp = [[UIImageView alloc]init];
                temp.tag = 9001 + i;
                temp.frame = CGRectMake(size.width * i, 0, size.width-7, size.height);
                
                UIButton *tempBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                tempBtn.frame = temp.frame;
                tempBtn.tag = 9021 + i;
                [tempBtn addTarget:self action:@selector(lunboImageClicked:) forControlEvents:UIControlEventTouchUpInside];
                [scrollView addSubview:tempBtn];
                [scrollView addSubview:temp];
            }
            scrollView.layer.zPosition = 1;
            [scrollView setContentSize:CGSizeMake(size.width * 5, size.height)];
            scrollView.pagingEnabled = YES;
            scrollView.showsHorizontalScrollIndicator = NO;
            [cell.contentView addSubview:scrollView];
            
            UIImageView *pageControllerBg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"page_controller_bg"]];
            pageControllerBg.frame = CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y + scrollView.frame.size.height - 20, scrollView.frame.size.width, 20);
            pageControllerBg.layer.zPosition = 2;
            [cell.contentView addSubview:pageControllerBg];
            [pageControllerBg bringSubviewToFront:scrollView];
            
            pageControl = [[DDPageControl alloc] init] ;
            [pageControl setCenter: CGPointMake(self.view.center.x - 8, pageControllerBg.center.y)] ;
            pageControl.layer.zPosition = 3;
            [pageControl setNumberOfPages: 5] ;
            [pageControl setCurrentPage: 0] ;
            [pageControl addTarget: self action: @selector(pageControlClicked:) forControlEvents: UIControlEventValueChanged] ;
            [pageControl setDefersCurrentPageDisplay: YES] ;
            [pageControl setType: DDPageControlTypeOnFullOffEmpty] ;
            [pageControl setOnColor: CMConstants.yellowColor];
            [pageControl setOffColor: [UIColor colorWithRed:202/255.0 green:195/255.0 blue:170/255.0 alpha: 1.0f]];
            
            [pageControl setIndicatorDiameter: 8.0f] ;
            [pageControl setIndicatorSpace: 9.0f] ;
            [cell.contentView addSubview:pageControl];
        }
        for (int i = 0; i < 5 && i < lunboArray.count; i++){
            UIImageView *temp = (UIImageView *)[scrollView viewWithTag:9001 + i];
            NSDictionary *lunboItem = [lunboArray objectAtIndex:i];
            [temp setImageWithURL:[NSURL URLWithString:[lunboItem objectForKey:@"ipad_pic"]] placeholderImage:[UIImage imageNamed:@"show_placeholder"]];
        }
    } else {
        if (topType == MOVIE_TOP) {
            cell = [self getMovieCell:tableView cellForRowAtIndexPath:indexPath];
        } else if(topType == DRAMA_TOP){
            cell = [self getDramaCell:tableView cellForRowAtIndexPath:indexPath];
        } else if(topType == COMIC_TOP){
            cell = [self getComicCell:tableView cellForRowAtIndexPath:indexPath];
        } else if (topType == SHOW_TOP){
            cell = [self getShowCell:tableView cellForRowAtIndexPath:indexPath];
        }
    }
    return cell;
}

- (UITableViewCell *)getMovieCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"movieContentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellEditingStyleNone];
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(38, 13, 200, 30)];
        [titleLabel setTextColor:CMConstants.textColor];
        [titleLabel setFont:[UIFont systemFontOfSize:13]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        titleLabel.tag = 4011;
        [cell.contentView addSubview:titleLabel];
        
        UIScrollView *cellScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(32, 28, 450, NORMAL_VIDEO_HEIGHT + 75 - 28)];
        cellScrollView.backgroundColor = [UIColor clearColor];
        cellScrollView.tag = 1011;
        cellScrollView.delegate = self;
        for (int i=0; i < MOVIE_NUMBER; i++) {
            UIImageView *placeHolderImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"video_bg_placeholder"]];
            placeHolderImage.frame = CGRectMake(6 + (MOVIE_POSTER_WIDTH+12+8) * i, 2, MOVIE_POSTER_WIDTH + 8, MOVIE_POSTER_HEIGHT + 4);
            placeHolderImage.tag = 8011;
            [cellScrollView addSubview:placeHolderImage];
            
            UIButton *tempBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            tempBtn.tag = 2011 + i;
            UIImageView *movieImage = [[UIImageView alloc]init];
            movieImage.tag = 6011 + i;
            movieImage.frame = CGRectMake(placeHolderImage.frame.origin.x + 4, 6, MOVIE_POSTER_WIDTH, MOVIE_POSTER_HEIGHT);
            tempBtn.frame = movieImage.frame;
            [tempBtn setBackgroundImage:[UIUtility createImageWithColor:[UIColor colorWithRed:255/255.0 green:164/255.0 blue:5/255.0 alpha:0.4]] forState:UIControlStateHighlighted];
            [tempBtn addTarget:self action:@selector(movieImageClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cellScrollView addSubview:movieImage];
            [cellScrollView addSubview:tempBtn];
            
            UILabel *tempLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, NORMAL_VIDEO_HEIGHT + 9, NORMAL_VIDEO_WIDTH, 30)];
            [tempLabel setTextAlignment:NSTextAlignmentCenter];
            [tempLabel setTextColor:CMConstants.textColor];
            [tempLabel setBackgroundColor:[UIColor clearColor]];
            [tempLabel setFont:[UIFont systemFontOfSize:13]];
            tempLabel.center = CGPointMake(tempBtn.center.x, tempLabel.center.y);
            tempLabel.tag = 3011 + i;
            [cellScrollView addSubview:tempLabel];
        }
        
        UIImageView *titleImage1 = [[UIImageView alloc]initWithFrame:CGRectMake(10, MOVIE_POSTER_HEIGHT + 11, (NORMAL_VIDEO_WIDTH+5)*6 - 18, 26)];
        titleImage1.image = [[UIImage imageNamed:@"name_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 2, 0, 2)];
        [cellScrollView addSubview:titleImage1];
        
        UIImageView *titleImage2 = [[UIImageView alloc]initWithFrame:CGRectMake((NORMAL_VIDEO_WIDTH+5)*6 - 10 + 20, MOVIE_POSTER_HEIGHT + 11, (NORMAL_VIDEO_WIDTH+5)*6 - 18, 26)];
        titleImage2.image = [[UIImage imageNamed:@"name_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 2, 0, 2)];
        [cellScrollView addSubview:titleImage2];
        
        [cellScrollView setContentSize:CGSizeMake(cellScrollView.frame.size.width * 2, NORMAL_VIDEO_HEIGHT)];
        cellScrollView.pagingEnabled = YES;
        cellScrollView.showsHorizontalScrollIndicator = NO;
        [cell.contentView addSubview:cellScrollView];
        
        UIButton *leftScrollBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        leftScrollBtn.frame = CGRectMake(10, cellScrollView.frame.origin.y+30, 20, 70);
        [leftScrollBtn setImage:[UIImage imageNamed:@"left_scroll_btn"] forState:UIControlStateNormal];
        [leftScrollBtn setImage:[UIImage imageNamed:@"left_scroll_btn_disabled"] forState:UIControlStateDisabled];
        [leftScrollBtn setImage:[UIImage imageNamed:@"left_scroll_btn_pressed"] forState:UIControlStateHighlighted];
        leftScrollBtn.tag = 5011;
        [leftScrollBtn addTarget:self action:@selector(scrollBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:leftScrollBtn];
        
        UIButton *rightScrollBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rightScrollBtn.frame = CGRectMake(cellScrollView.frame.origin.x + cellScrollView.frame.size.width, cellScrollView.frame.origin.y+30, 20, 70);
        [rightScrollBtn setImage:[UIImage imageNamed:@"right_scroll_btn"] forState:UIControlStateNormal];
        [rightScrollBtn setImage:[UIImage imageNamed:@"right_scroll_btn_disabled"] forState:UIControlStateDisabled];
        [rightScrollBtn setImage:[UIImage imageNamed:@"right_scroll_btn_pressed"] forState:UIControlStateHighlighted];
        rightScrollBtn.tag = 5012;
        [rightScrollBtn addTarget:self action:@selector(scrollBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:rightScrollBtn];
        
    }
    if (indexPath.row < movieTopsArray.count) {
        NSDictionary *item = [movieTopsArray objectAtIndex:indexPath.row];
        UIScrollView *cellScrollView = (UIScrollView *)[cell viewWithTag:1011];
        [cellScrollView setContentOffset:CGPointZero];
        UIButton *leftScrollBtn = (UIButton *)[cell viewWithTag:5011];
        UIButton *rightScrollBtn = (UIButton *)[cell viewWithTag:5012];
        [leftScrollBtn setEnabled:NO];
        [rightScrollBtn setEnabled:YES];
        NSArray *subitemArray = [item objectForKey:@"items"];
        
        //add code by huokun at 13/03/21 for BUG#398
        //根据网络回掉数据，设置scrollView的ContentSize
        for (int i=0; i < subitemArray.count; i++)
        {
            UIImageView *contentImage = (UIImageView *)[cell viewWithTag:6011 + i];
            NSDictionary *subitem = [subitemArray objectAtIndex:i];
            [contentImage setImageWithURL:[NSURL URLWithString:[subitem objectForKey:@"prod_pic_url"]] ];
            UILabel *tempLabel = (UILabel *)[cellScrollView viewWithTag:3011 + i];
            tempLabel.text = [subitem objectForKey:@"prod_name"];
            
            UIImageView *placeHolderImage = (UIImageView *)[cellScrollView viewWithTag:8011 + i];
            [placeHolderImage setHidden:NO];
            UIButton *tempBtn = (UIButton *)[cellScrollView viewWithTag:2011 + i];
            [tempBtn setHidden:NO];
            [tempLabel setHidden:NO];
            [contentImage setHidden:NO];
        }
        for (int i=subitemArray.count; i < DRAMA_NUMBER; i++)
        {
            UIImageView *placeHolderImage = (UIImageView *)[cellScrollView viewWithTag:8011 + i];
            [placeHolderImage setHidden:YES];
            
            UIButton *tempBtn = (UIButton *)[cellScrollView viewWithTag:2011 + i];
            [tempBtn setHidden:YES];
            
            UILabel *tempLabel = (UILabel *)[cellScrollView viewWithTag:3011 + i];
            [tempLabel setHidden:YES];
            
            UIImageView *contentImage = (UIImageView *)[cell viewWithTag:6011 + i];
            [contentImage setHidden:YES];
        }
        cellScrollView.contentSize = CGSizeMake((MOVIE_POSTER_WIDTH + 8 + 12) * subitemArray.count, NORMAL_VIDEO_HEIGHT);
        //add code end
        
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:4011];
        [titleLabel setText:[item objectForKey:@"name"]];
        [titleLabel sizeToFit];
    }
    return cell;
}

- (UITableViewCell *)getDramaCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"dramaContentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellEditingStyleNone];
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(38, 13, 200, 30)];
        [titleLabel setTextColor:CMConstants.textColor];
        [titleLabel setFont:[UIFont systemFontOfSize:13]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        titleLabel.tag = 4011;
        [cell.contentView addSubview:titleLabel];
        
        UIScrollView *cellScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(32, 28, 450, NORMAL_VIDEO_HEIGHT + 75 - 28)];
        cellScrollView.backgroundColor = [UIColor clearColor];
        cellScrollView.tag = 1011;
        cellScrollView.delegate = self;
        for (int i=0; i < DRAMA_NUMBER; i++) {
            UIImageView *placeHolderImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"video_bg_placeholder"]];
            placeHolderImage.frame = CGRectMake(6 + (MOVIE_POSTER_WIDTH+12+8) * i, 2, MOVIE_POSTER_WIDTH + 8, MOVIE_POSTER_HEIGHT + 4);
            placeHolderImage.tag = 8011;
            [cellScrollView addSubview:placeHolderImage];
            
            UIButton *tempBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            tempBtn.tag = 2011 + i;
            UIImageView *movieImage = [[UIImageView alloc]init];
            movieImage.tag = 6011 + i;
            movieImage.frame = CGRectMake(placeHolderImage.frame.origin.x + 4, 6, MOVIE_POSTER_WIDTH, MOVIE_POSTER_HEIGHT);
            tempBtn.frame = movieImage.frame;
            [tempBtn setBackgroundImage:[UIUtility createImageWithColor:[UIColor colorWithRed:255/255.0 green:164/255.0 blue:5/255.0 alpha:0.4]] forState:UIControlStateHighlighted];
            [tempBtn addTarget:self action:@selector(dramaImageClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cellScrollView addSubview:movieImage];
            [cellScrollView addSubview:tempBtn];
            
            UILabel *tempLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, NORMAL_VIDEO_HEIGHT + 9, NORMAL_VIDEO_WIDTH, 30)];
            [tempLabel setTextAlignment:NSTextAlignmentCenter];
            [tempLabel setTextColor:CMConstants.textColor];
            [tempLabel setBackgroundColor:[UIColor clearColor]];
            [tempLabel setFont:[UIFont systemFontOfSize:13]];
            tempLabel.center = CGPointMake(tempBtn.center.x, tempLabel.center.y);
            tempLabel.tag = 3011 + i;
            [cellScrollView addSubview:tempLabel];
        }
        
        UIImageView *titleImage1 = [[UIImageView alloc]initWithFrame:CGRectMake(10, MOVIE_POSTER_HEIGHT + 11, (NORMAL_VIDEO_WIDTH+5)*6 - 18, 30)];
        titleImage1.image = [[UIImage imageNamed:@"name_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 2, 5, 2)];
        [cellScrollView addSubview:titleImage1];
        
        UIImageView *titleImage2 = [[UIImageView alloc]initWithFrame:CGRectMake((NORMAL_VIDEO_WIDTH+5)*6 - 10 + 20, MOVIE_POSTER_HEIGHT + 11, (NORMAL_VIDEO_WIDTH+5)*6 - 18, 30)];
        titleImage2.image = [[UIImage imageNamed:@"name_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 2, 5, 2)];
        [cellScrollView addSubview:titleImage2];
        
        [cellScrollView setContentSize:CGSizeMake(cellScrollView.frame.size.width * 2, NORMAL_VIDEO_HEIGHT)];
        cellScrollView.pagingEnabled = YES;
        cellScrollView.showsHorizontalScrollIndicator = NO;
        [cell.contentView addSubview:cellScrollView];
        
        UIButton *leftScrollBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        leftScrollBtn.frame = CGRectMake(10, cellScrollView.frame.origin.y+30, 23, 70);
        [leftScrollBtn setImage:[UIImage imageNamed:@"left_scroll_btn"] forState:UIControlStateNormal];
        [leftScrollBtn setImage:[UIImage imageNamed:@"left_scroll_btn_disabled"] forState:UIControlStateDisabled];
        [leftScrollBtn setImage:[UIImage imageNamed:@"left_scroll_btn_pressed"] forState:UIControlStateHighlighted];
        leftScrollBtn.tag = 5011;
        [leftScrollBtn addTarget:self action:@selector(scrollBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:leftScrollBtn];
        
        UIButton *rightScrollBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rightScrollBtn.frame = CGRectMake(cellScrollView.frame.origin.x + cellScrollView.frame.size.width, cellScrollView.frame.origin.y+30, 23, 70);
        [rightScrollBtn setImage:[UIImage imageNamed:@"right_scroll_btn"] forState:UIControlStateNormal];
        [rightScrollBtn setImage:[UIImage imageNamed:@"right_scroll_btn_disabled"] forState:UIControlStateDisabled];
        [rightScrollBtn setImage:[UIImage imageNamed:@"right_scroll_btn_pressed"] forState:UIControlStateHighlighted];
        rightScrollBtn.tag = 5012;
        [rightScrollBtn addTarget:self action:@selector(scrollBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:rightScrollBtn];
    }
    if (indexPath.row < tvTopsArray.count) {
        NSDictionary *item = [tvTopsArray objectAtIndex:indexPath.row];
        UIScrollView *cellScrollView = (UIScrollView *)[cell viewWithTag:1011];
        [cellScrollView setContentOffset:CGPointZero];
        UIButton *leftScrollBtn = (UIButton *)[cell viewWithTag:5011];
        UIButton *rightScrollBtn = (UIButton *)[cell viewWithTag:5012];
        [leftScrollBtn setEnabled:NO];
        [rightScrollBtn setEnabled:YES];
        NSArray *subitemArray = [item objectForKey:@"items"];
        
        //add code by huokun at 13/03/21 for BUG#398
        //根据网络回掉数据，设置scrollView的ContentSize
        for (int i=0; i < subitemArray.count; i++)
        {
            UIImageView *contentImage = (UIImageView *)[cell viewWithTag:6011 + i];
            NSDictionary *subitem = [subitemArray objectAtIndex:i];
            [contentImage setImageWithURL:[NSURL URLWithString:[subitem objectForKey:@"prod_pic_url"]]];
            UILabel *tempLabel = (UILabel *)[cellScrollView viewWithTag:3011 + i];
            tempLabel.text = [subitem objectForKey:@"prod_name"];
        
            UIImageView *placeHolderImage = (UIImageView *)[cellScrollView viewWithTag:8011 + i];
            [placeHolderImage setHidden:NO];
            UIButton *tempBtn = (UIButton *)[cellScrollView viewWithTag:2011 + i];
            [tempBtn setHidden:NO];
            [tempLabel setHidden:NO];
            [contentImage setHidden:NO];
        }
        for (int i=subitemArray.count; i < DRAMA_NUMBER; i++)
        {
            UIImageView *placeHolderImage = (UIImageView *)[cellScrollView viewWithTag:8011 + i];
            [placeHolderImage setHidden:YES];
            
            UIButton *tempBtn = (UIButton *)[cellScrollView viewWithTag:2011 + i];
            [tempBtn setHidden:YES];
            
            UILabel *tempLabel = (UILabel *)[cellScrollView viewWithTag:3011 + i];
            [tempLabel setHidden:YES];
            
            UIImageView *contentImage = (UIImageView *)[cell viewWithTag:6011 + i];
            [contentImage setHidden:YES];
        }
        cellScrollView.contentSize = CGSizeMake((MOVIE_POSTER_WIDTH + 8 + 12) * subitemArray.count, NORMAL_VIDEO_HEIGHT);
        //add code end
        
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:4011];
        [titleLabel setText:[item objectForKey:@"name"]];
        [titleLabel sizeToFit];
    }
    return cell;
}


- (UITableViewCell *)getComicCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"comicContentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellEditingStyleNone];
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(38, 13, 200, 30)];
        [titleLabel setTextColor:CMConstants.textColor];
        [titleLabel setFont:[UIFont systemFontOfSize:13]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        titleLabel.tag = 4011;
        [cell.contentView addSubview:titleLabel];
        
        UIScrollView *cellScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(32, 28, 450, NORMAL_VIDEO_HEIGHT + 75 - 28)];
        cellScrollView.backgroundColor = [UIColor clearColor];
        cellScrollView.tag = 1011;
        cellScrollView.delegate = self;
        for (int i=0; i < DRAMA_NUMBER; i++) {
            UIImageView *placeHolderImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"video_bg_placeholder"]];
            placeHolderImage.frame = CGRectMake(6 + (MOVIE_POSTER_WIDTH+12+8) * i, 2, MOVIE_POSTER_WIDTH + 8, MOVIE_POSTER_HEIGHT + 4);
            placeHolderImage.tag = 8011 + i;
            [cellScrollView addSubview:placeHolderImage];
            
            UIButton *tempBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            tempBtn.tag = 2011 + i;
            UIImageView *movieImage = [[UIImageView alloc]init];
            movieImage.tag = 6011 + i;
            movieImage.frame = CGRectMake(placeHolderImage.frame.origin.x + 4, 6, MOVIE_POSTER_WIDTH, MOVIE_POSTER_HEIGHT);
            tempBtn.frame = movieImage.frame;
            [tempBtn setBackgroundImage:[UIUtility createImageWithColor:[UIColor colorWithRed:255/255.0 green:164/255.0 blue:5/255.0 alpha:0.4]] forState:UIControlStateHighlighted];
            [tempBtn addTarget:self action:@selector(comicImageClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cellScrollView addSubview:movieImage];
            [cellScrollView addSubview:tempBtn];
            
            UILabel *tempLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, NORMAL_VIDEO_HEIGHT + 9, NORMAL_VIDEO_WIDTH, 30)];
            [tempLabel setTextAlignment:NSTextAlignmentCenter];
            [tempLabel setTextColor:CMConstants.textColor];
            [tempLabel setBackgroundColor:[UIColor clearColor]];
            [tempLabel setFont:[UIFont systemFontOfSize:13]];
            tempLabel.center = CGPointMake(tempBtn.center.x, tempLabel.center.y);
            tempLabel.tag = 3011 + i;
            [cellScrollView addSubview:tempLabel];
        }
        
        UIImageView *titleImage1 = [[UIImageView alloc]initWithFrame:CGRectMake(10, MOVIE_POSTER_HEIGHT + 9, (NORMAL_VIDEO_WIDTH+5)*6 - 18, 30)];
        titleImage1.image = [[UIImage imageNamed:@"name_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 2, 5, 2)];
        [cellScrollView addSubview:titleImage1];
        
        UIImageView *titleImage2 = [[UIImageView alloc]initWithFrame:CGRectMake((NORMAL_VIDEO_WIDTH+5)*6 - 10 + 20, MOVIE_POSTER_HEIGHT + 9, (NORMAL_VIDEO_WIDTH+5)*6 - 18, 30)];
        titleImage2.image = [[UIImage imageNamed:@"name_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 2, 5, 2)];
        [cellScrollView addSubview:titleImage2];
        
        [cellScrollView setContentSize:CGSizeMake(cellScrollView.frame.size.width * 2, NORMAL_VIDEO_HEIGHT)];
        cellScrollView.pagingEnabled = YES;
        cellScrollView.showsHorizontalScrollIndicator = NO;
        [cell.contentView addSubview:cellScrollView];
        
        UIButton *leftScrollBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        leftScrollBtn.frame = CGRectMake(10, cellScrollView.frame.origin.y+30, 23, 70);
        [leftScrollBtn setImage:[UIImage imageNamed:@"left_scroll_btn"] forState:UIControlStateNormal];
        [leftScrollBtn setImage:[UIImage imageNamed:@"left_scroll_btn_disabled"] forState:UIControlStateDisabled];
        [leftScrollBtn setImage:[UIImage imageNamed:@"left_scroll_btn_pressed"] forState:UIControlStateHighlighted];
        leftScrollBtn.tag = 5011;
        [leftScrollBtn addTarget:self action:@selector(scrollBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:leftScrollBtn];
        
        UIButton *rightScrollBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rightScrollBtn.frame = CGRectMake(cellScrollView.frame.origin.x + cellScrollView.frame.size.width, cellScrollView.frame.origin.y+30, 23, 70);
        [rightScrollBtn setImage:[UIImage imageNamed:@"right_scroll_btn"] forState:UIControlStateNormal];
        [rightScrollBtn setImage:[UIImage imageNamed:@"right_scroll_btn_disabled"] forState:UIControlStateDisabled];
        [rightScrollBtn setImage:[UIImage imageNamed:@"right_scroll_btn_pressed"] forState:UIControlStateHighlighted];
        rightScrollBtn.tag = 5012;
        [rightScrollBtn addTarget:self action:@selector(scrollBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:rightScrollBtn];
    }
    if (indexPath.row < comicTopsArray.count) {
        NSDictionary *item = [comicTopsArray objectAtIndex:indexPath.row];
        UIScrollView *cellScrollView = (UIScrollView *)[cell viewWithTag:1011];
        [cellScrollView setContentOffset:CGPointZero];
        UIButton *leftScrollBtn = (UIButton *)[cell viewWithTag:5011];
        UIButton *rightScrollBtn = (UIButton *)[cell viewWithTag:5012];
        [leftScrollBtn setEnabled:NO];
        [rightScrollBtn setEnabled:YES];
        NSArray *subitemArray = [item objectForKey:@"items"];
        
        //add code by huokun at 13/03/21 for BUG#398
        //根据网络回掉数据，设置scrollView的ContentSize
        for (int i=0; i < subitemArray.count; i++)
        {
            UIImageView *contentImage = (UIImageView *)[cell viewWithTag:6011 + i];
            NSDictionary *subitem = [subitemArray objectAtIndex:i];
            [contentImage setImageWithURL:[NSURL URLWithString:[subitem objectForKey:@"prod_pic_url"]]];
            UILabel *tempLabel = (UILabel *)[cellScrollView viewWithTag:3011 + i];
            tempLabel.text = [subitem objectForKey:@"prod_name"];
            
            UIImageView *placeHolderImage = (UIImageView *)[cellScrollView viewWithTag:8011 + i];
            [placeHolderImage setHidden:NO];
            UIButton *tempBtn = (UIButton *)[cellScrollView viewWithTag:2011 + i];
            [tempBtn setHidden:NO];
            [tempLabel setHidden:NO];
            [contentImage setHidden:NO];
        }
        for (int i=subitemArray.count; i < DRAMA_NUMBER; i++)
        {
            UIImageView *placeHolderImage = (UIImageView *)[cellScrollView viewWithTag:8011 + i];
            [placeHolderImage setHidden:YES];
            
            UIButton *tempBtn = (UIButton *)[cellScrollView viewWithTag:2011 + i];
            [tempBtn setHidden:YES];
            
            UILabel *tempLabel = (UILabel *)[cellScrollView viewWithTag:3011 + i];
            [tempLabel setHidden:YES];
            
            UIImageView *contentImage = (UIImageView *)[cell viewWithTag:6011 + i];
            [contentImage setHidden:YES];
        }
        cellScrollView.contentSize = CGSizeMake((MOVIE_POSTER_WIDTH + 8 + 12) * subitemArray.count, NORMAL_VIDEO_HEIGHT);
        //add code end
        
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:4011];
        [titleLabel setText:[item objectForKey:@"name"]];
        [titleLabel sizeToFit];
    }
    return cell;
}

- (UITableViewCell *)getShowCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"showContentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImageView *placeHolderImage = [[UIImageView alloc]initWithFrame:CGRectMake(8, 3, SHOW_LOGO_WEIGHT + 8, SHOW_LOGO_HEIGHT + 8)];
        placeHolderImage.image = [UIImage imageNamed:@"show_placeholder"];
        [cell.contentView addSubview:placeHolderImage];
        
        UIImageView *tempImage = [[UIImageView alloc]initWithFrame:CGRectMake(12, 8, SHOW_LOGO_WEIGHT, SHOW_LOGO_HEIGHT)];
        tempImage.tag = 1031;
        [cell.contentView addSubview:tempImage];
        
        UIImageView *overLayImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"show_overlay"]];
        overLayImage.frame = CGRectMake(tempImage.frame.origin.x, 6 + SHOW_LOGO_HEIGHT-35 , tempImage.frame.size.width, 38);
        overLayImage.tag = 2131;
        [cell.contentView addSubview:overLayImage];
        
        UIButton *tempBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        tempBtn.frame = tempImage.frame;
        tempBtn.tag = 2031;
        [tempBtn addTarget:self action:@selector(showImageClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:tempBtn];
        
        UILabel *tempNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(tempImage.frame.origin.x + 12, overLayImage.frame.origin.y + 8, tempImage.frame.size.width *0.6, 20)];
        [tempNameLabel setTextColor:[UIColor whiteColor]];
        [tempNameLabel setBackgroundColor:[UIColor clearColor]];
        [tempNameLabel setFont:[UIFont boldSystemFontOfSize:15]];
        tempNameLabel.tag = 3031;
        [cell.contentView addSubview:tempNameLabel];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(200, overLayImage.frame.origin.y + 8, overLayImage.frame.size.width-195, 20)];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        titleLabel.textAlignment = NSTextAlignmentRight;
        [titleLabel setFont:[UIFont systemFontOfSize:14]];
        titleLabel.tag = 4031;
        [cell.contentView addSubview:titleLabel];
    }
    if (indexPath.row < showTopsArray.count) {
        NSDictionary *item = [showTopsArray objectAtIndex:indexPath.row];
        UIImageView *tempImage = (UIImageView *)[cell viewWithTag:1031];
        [tempImage setImageWithURL:[NSURL URLWithString:[item objectForKey:@"prod_pic_url"]]];
        
        UILabel *tempNameLabel = (UILabel *)[cell viewWithTag:3031];
        [tempNameLabel setText:[item objectForKey:@"prod_name"]];
        //    [tempNameLabel sizeToFit];
        
        UIImageView *overLayImage = (UIImageView *)[cell viewWithTag:2131];
        if(selectedRowNumber == indexPath.row && lastSelectedOverlay == overLayImage){
            overLayImage.image = [UIImage imageNamed:@"show_overlay_pressed"];
        } else {
            overLayImage.image = [UIImage imageNamed:@"show_overlay"];
        }
              
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:4031];
        NSString *titleText = (NSString *)[item objectForKey:@"cur_item_name"];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [titleLabel setText:[NSString stringWithFormat:@"%@", titleText]];
    }
    return cell;
}

- (void)movieImageClicked:(UIButton *)btn
{
    CGPoint point = btn.center;
    point = [table convertPoint:point fromView:btn.superview];
    NSIndexPath* indexPath = [table indexPathForRowAtPoint:point];
    
    if (indexPath.row >= 0 && indexPath.row < movieTopsArray.count) {
        NSArray *items = [[movieTopsArray objectAtIndex:indexPath.row] objectForKey:@"items"];
        if(btn.tag - 2011 < items.count){
            NSDictionary *item = [items objectAtIndex:btn.tag - 2011];
            [self showDetailScreen:item];
        }
    }
}

- (void)dramaImageClicked:(UIButton *)btn
{
    CGPoint point = btn.center;
    point = [table convertPoint:point fromView:btn.superview];
    NSIndexPath* indexPath = [table indexPathForRowAtPoint:point];
    
    if (indexPath.row >= 0 && indexPath.row < tvTopsArray.count) {
        NSArray *items = [[tvTopsArray objectAtIndex:indexPath.row] objectForKey:@"items"];
        if(btn.tag - 2011 < items.count){
            NSDictionary *item = [items objectAtIndex:btn.tag - 2011];
            [self showDetailScreen:item];
        }
    }
}

- (void)comicImageClicked:(UIButton *)btn
{
    CGPoint point = btn.center;
    point = [table convertPoint:point fromView:btn.superview];
    NSIndexPath* indexPath = [table indexPathForRowAtPoint:point];
    
    if (indexPath.row >= 0 && indexPath.row < comicTopsArray.count) {
        NSArray *items = [[comicTopsArray objectAtIndex:indexPath.row] objectForKey:@"items"];
        if(btn.tag - 2011 < items.count){
            NSDictionary *item = [items objectAtIndex:btn.tag - 2011];
            [self showDetailScreen:item];
        }
    }
}

- (void)showImageClicked:(UIButton *)btn
{
    CGPoint point = btn.center;
    point = [table convertPoint:point fromView:btn.superview];
    NSIndexPath* indexPath = [table indexPathForRowAtPoint:point];
    selectedRowNumber = indexPath.row;
    if(lastSelectedOverlay != nil){
        lastSelectedOverlay.image = [UIImage imageNamed:@"show_overlay"];
    }
    UIImageView *overlay = (UIImageView *)[[btn superview]viewWithTag:btn.tag + 100];
    overlay.image = [UIImage imageNamed:@"show_overlay_pressed"];
    lastSelectedOverlay = overlay;
    if (indexPath.row < showTopsArray.count) {
        NSDictionary *item = [showTopsArray objectAtIndex:indexPath.row];
        [self showDetailScreen:item];
    }
}


- (void)scrollBtnClicked:(UIButton *)btn
{
    CGPoint point = btn.center;
    point = [table convertPoint:point fromView:btn.superview];
    NSIndexPath* indexPath = [table indexPathForRowAtPoint:point];
    UITableViewCell *cell = [table cellForRowAtIndexPath:indexPath];
    UIScrollView *cellScrollView = (UIScrollView *)[cell viewWithTag:1011];
    if(cellScrollView == nil){
        cellScrollView = (UIScrollView *)[cell viewWithTag:1021];
    }
    UIButton *leftBtn = (UIButton *)[cell viewWithTag:5011];
    UIButton *rightBtn = (UIButton *)[cell viewWithTag:5012];
    if (btn.tag == 5011) {
        [cellScrollView setContentOffset: CGPointZero animated:YES];
        [leftBtn setEnabled:NO];
        [rightBtn setEnabled:YES];
    } else {
        [cellScrollView setContentOffset: CGPointMake(cellScrollView.frame.size.width, 0) animated:YES];
        [leftBtn setEnabled:YES];
        [rightBtn setEnabled:NO];
    }
}

- (void)lunboImageClicked:(UIButton *)btn
{
    [timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:5]];
    int index = btn.tag - 9021;
    NSDictionary *item = [lunboArray objectAtIndex:index];
    NSString *type = [NSString stringWithFormat:@"%@", [item objectForKey:@"type"]];
    
    //add code by huokun at 13/04/18 for 『获取轮播图位置』
    NSString * pageNum = (NSString *)[[ContainerUtility sharedInstance] attributeForKey:KWXCODENUM];
    if ((index + 1) == [pageNum intValue])
    {
        //显示二维码页面
        UIImageView * wxCode = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"erweima.png"]];
        wxCode.frame = CGRectMake(0, 0, 263, 272);
        [[AppDelegate instance].rootViewController addTopView:wxCode];
        return;
    }
    //add code end
    
    if ([type isEqualToString:@"0"]) {
        [self showDetailScreen:item];
    } else if ([type isEqualToString:@"1"]) {
        ListViewController *viewController = [[ListViewController alloc] init];
        viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
        NSString *topId = [NSString stringWithFormat:@"%@", [item objectForKey: @"prod_id"]];
        viewController.topId = topId;
        viewController.listTitle = [item objectForKey: @"prod_name"];
        viewController.type = [[NSString stringWithFormat:@"%@", [item objectForKey:@"prod_type"]]intValue];
        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:YES];
    }
    
}

- (void)showDetailScreen:(NSDictionary *)item
{
    int prodType = [[item objectForKey:@"prod_type"] integerValue];
    if(prodType == MOVIE_TYPE){
        MovieDetailViewController *viewController = [[MovieDetailViewController alloc] initWithNibName:@"MovieDetailViewController" bundle:nil];
        viewController.fromViewController = self;
        viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
        viewController.prodId = [NSString stringWithFormat:@"%@", [item objectForKey:@"prod_id"]];
        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE  removePreviousView:YES];
    } else if(prodType == DRAMA_TYPE || prodType == COMIC_TYPE){
        DramaDetailViewController *viewController = [[DramaDetailViewController alloc] initWithNibName:@"DramaDetailViewController" bundle:nil];
        viewController.fromViewController = self;
        viewController.prodId = [NSString stringWithFormat:@"%@", [item objectForKey:@"prod_id"]];
        viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:YES];
    } else if(prodType == SHOW_TYPE){
        ShowDetailViewController *viewController = [[ShowDetailViewController alloc] initWithNibName:@"ShowDetailViewController" bundle:nil];
        viewController.fromViewController = self;
        viewController.prodId = [NSString stringWithFormat:@"%@", [item objectForKey:@"prod_id"]];
        viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        return TOP_IMAGE_HEIGHT;
    } else {
        if (topType == SHOW_TOP) {
            return SHOW_LOGO_HEIGHT + 10;
        } else {
            return NORMAL_VIDEO_HEIGHT + 65;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return 0;
    } else {
        return 70;
    }
}

- (void)initTopButtonImage
{
    [movieListBtn setBackgroundImage:[UIImage imageNamed:@"movie_top_pressed"] forState:UIControlStateNormal];
    [movieListBtn setBackgroundImage:[UIImage imageNamed:@"movie_top_pressed"] forState:UIControlStateHighlighted];
    [dramaListBtn setBackgroundImage:[UIImage imageNamed:@"drama_top"] forState:UIControlStateNormal];
    [dramaListBtn setBackgroundImage:[UIImage imageNamed:@"drama_top_pressed"] forState:UIControlStateHighlighted];
    [comicListBtn setBackgroundImage:[UIImage imageNamed:@"comic_top"] forState:UIControlStateNormal];
    [comicListBtn setBackgroundImage:[UIImage imageNamed:@"comic_top_pressed"] forState:UIControlStateHighlighted];
    [showListBtn setBackgroundImage:[UIImage imageNamed:@"show_top"] forState:UIControlStateNormal];
    [showListBtn setBackgroundImage:[UIImage imageNamed:@"show_top_pressed"] forState:UIControlStateHighlighted];
    if (topType == MOVIE_TOP) {
        [movieListBtn setBackgroundImage:[UIImage imageNamed:@"movie_top_pressed"] forState:UIControlStateNormal];
        [dramaListBtn setBackgroundImage:[UIImage imageNamed:@"drama_top"] forState:UIControlStateNormal];
        [showListBtn setBackgroundImage:[UIImage imageNamed:@"show_top"] forState:UIControlStateNormal];
        [comicListBtn setBackgroundImage:[UIImage imageNamed:@"comic_top"] forState:UIControlStateNormal];
    } else if(topType == DRAMA_TOP){
        [movieListBtn setBackgroundImage:[UIImage imageNamed:@"movie_top"] forState:UIControlStateNormal];
        [dramaListBtn setBackgroundImage:[UIImage imageNamed:@"drama_top_pressed"] forState:UIControlStateNormal];
        [showListBtn setBackgroundImage:[UIImage imageNamed:@"show_top"] forState:UIControlStateNormal];
        [comicListBtn setBackgroundImage:[UIImage imageNamed:@"comic_top"] forState:UIControlStateNormal];
    } else if(topType == COMIC_TOP){
        [movieListBtn setBackgroundImage:[UIImage imageNamed:@"movie_top"] forState:UIControlStateNormal];
        [dramaListBtn setBackgroundImage:[UIImage imageNamed:@"drama_top"] forState:UIControlStateNormal];
        [comicListBtn setBackgroundImage:[UIImage imageNamed:@"comic_top_pressed"] forState:UIControlStateNormal];
        [showListBtn setBackgroundImage:[UIImage imageNamed:@"show_top"] forState:UIControlStateNormal];
    } else if(topType == SHOW_TOP){
        [movieListBtn setBackgroundImage:[UIImage imageNamed:@"movie_top"] forState:UIControlStateNormal];
        [dramaListBtn setBackgroundImage:[UIImage imageNamed:@"drama_top"] forState:UIControlStateNormal];
        [showListBtn setBackgroundImage:[UIImage imageNamed:@"show_top_pressed"] forState:UIControlStateNormal];
        [comicListBtn setBackgroundImage:[UIImage imageNamed:@"comic_top"] forState:UIControlStateNormal];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (customHeaderView) {
        return customHeaderView;
    } else {
        customHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width, 64)];
        UIImageView *bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, customHeaderView.frame.size.width, customHeaderView.frame.size.height)];
        bgImageView.center = CGPointMake(customHeaderView.center.x - 8, customHeaderView.center.y);
        bgImageView.image = [UIImage imageNamed:@"top_header_bg"];
        [customHeaderView addSubview:bgImageView];
        
        int segmentLength = (customHeaderView.frame.size.width-8)/4;
        
        movieListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        movieListBtn.frame = CGRectMake(0, 6, VIDEO_BUTTON_WIDTH, VIDEO_BUTTON_HEIGHT);
        movieListBtn.center = CGPointMake(segmentLength*0.5, movieListBtn.center.y);
        movieListBtn.tag = 1001;
        [movieListBtn addTarget:self action:@selector(movieListBtnClicked:) forControlEvents:UIControlEventTouchDown];
        [customHeaderView addSubview:movieListBtn];
        
        dramaListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        dramaListBtn.frame = CGRectMake(0, 6, VIDEO_BUTTON_WIDTH, VIDEO_BUTTON_HEIGHT);
        dramaListBtn.center = CGPointMake(segmentLength*1.5, dramaListBtn.center.y);
        dramaListBtn.tag = 1002;
        [dramaListBtn addTarget:self action:@selector(dramaListBtnClicked:) forControlEvents:UIControlEventTouchDown];
        [customHeaderView addSubview:dramaListBtn];
        
        comicListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        comicListBtn.frame = CGRectMake(0, 6, VIDEO_BUTTON_WIDTH, VIDEO_BUTTON_HEIGHT);
        comicListBtn.center = CGPointMake(segmentLength*2.5, comicListBtn.center.y);
        comicListBtn.tag = 1003;
        [comicListBtn addTarget:self action:@selector(comicListBtnClicked:) forControlEvents:UIControlEventTouchDown];
        [customHeaderView addSubview:comicListBtn];
        
        showListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        showListBtn.frame = CGRectMake(0, 6, VIDEO_BUTTON_WIDTH, VIDEO_BUTTON_HEIGHT);
        showListBtn.center = CGPointMake(segmentLength*3.5, showListBtn.center.y);
        showListBtn.tag = 1004;
        [showListBtn addTarget:self action:@selector(showListBtnClicked:) forControlEvents:UIControlEventTouchDown];
        [customHeaderView addSubview:showListBtn];
        [self initTopButtonImage];
        return customHeaderView;
    }
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


@end
