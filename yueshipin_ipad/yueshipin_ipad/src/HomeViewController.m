//
//  HomeViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-20.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "HomeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DDPageControl.h"
#import "MovieDetailViewController.h"
#import "DramaDetailViewController.h"
#import "ShowDetailViewController.h"
#import "ListViewController.h"
#import "SubsearchViewController.h"


#define BOTTOM_IMAGE_HEIGHT 20
#define TOP_IMAGE_HEIGHT 167
#define LIST_LOGO_WIDTH 220
#define LIST_LOGO_HEIGHT 180
#define VIDEO_BUTTON_WIDTH 119
#define VIDEO_BUTTON_HEIGHT 29
#define TOP_SOLGAN_HEIGHT 93
#define MOVIE_LOGO_HEIGHT 133
#define MOVIE_LOGO_WEIGHT 83
#define DRAMA_LOGO_HEIGHT 145
#define DRAMA_LOGO_WEIGHT 83
#define SHOW_LOGO_HEIGHT 125
#define SHOW_LOGO_WEIGHT 486

#define MOVIE_NUMBER 10
#define DRAMA_NUMBER 10

@interface HomeViewController (){
    UIView *backgroundView;
    UIButton *menuBtn;
    UIImageView *sloganImageView;
    UIButton *searchBtn;
    UIView *contentView;
    UITableView *table;
    UIScrollView *scrollView;
    DDPageControl *pageControl;
    UIButton *listBtn;
    UIButton *movieBtn;
    UIButton *dramaBtn;
    UIButton *showBtn;
    UIImageView *bottomImageView;
    UIImageView *bgImage;
    NSMutableArray *topsArray;
    NSMutableArray *tvTopsArray;
    NSMutableArray *movieTopsArray;
    NSMutableArray *showTopsArray;
    NSArray *lunboArray;
    int videoType; // 0: 悦单 1: 电影 2: 电视剧 3: 综艺
    MNMBottomPullToRefreshManager *pullToRefreshManager_;
    NSUInteger reloads_;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    int pageSize;
}

@end

@implementation HomeViewController
@synthesize menuViewControllerDelegate;

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
        backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 24)];
        [backgroundView setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:backgroundView];
        
        bgImage = [[UIImageView alloc]initWithFrame:backgroundView.frame];
        bgImage.image = [UIImage imageNamed:@"left_background"];
        [backgroundView addSubview:bgImage];
        
		menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [menuBtn setBackgroundColor:[UIColor clearColor]];
        menuBtn.frame = CGRectMake(0, 28, 60, 60);
        [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu_btn"] forState:UIControlStateNormal];
        [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu_btn_pressed"] forState:UIControlStateHighlighted];
        [menuBtn addTarget:self action:@selector(menuBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [backgroundView addSubview:menuBtn];
        
        sloganImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"slogan"]];
        sloganImageView.frame = CGRectMake(80, 36, 265, 42);
        [backgroundView addSubview:sloganImageView];
        
        searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        searchBtn.frame = CGRectMake(440, 48, 42, 30);
        [searchBtn setBackgroundImage:[UIImage imageNamed:@"searchicon_btn"] forState:UIControlStateNormal];
        [searchBtn setBackgroundImage:[UIImage imageNamed:@"searchicon_pressed_btn"] forState:UIControlStateHighlighted];
        [searchBtn addTarget:self action:@selector(searchBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [backgroundView addSubview:searchBtn];
        
        table = [[UITableView alloc] initWithFrame:CGRectMake(8, 92, backgroundView.frame.size.width - 18, backgroundView.frame.size.height - TOP_SOLGAN_HEIGHT - BOTTOM_IMAGE_HEIGHT) style:UITableViewStylePlain];
        [table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
		[table setDelegate:self];
		[table setDataSource:self];
        [table setBackgroundColor:[UIColor clearColor]];
        [table setShowsVerticalScrollIndicator:NO];
		[table setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
		[backgroundView addSubview:table];
        
        bottomImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 8, self.view.frame.size.width, 20)];
        [backgroundView addSubview:bottomImageView];
        
        pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:480.0f tableView:table withClient:self];
        reloads_ = 2;
        if (_refreshHeaderView == nil) {
            EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - table.bounds.size.height, self.view.frame.size.width, table.bounds.size.height)];
            view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"back_up2"]];
            view.delegate = self;
            [table addSubview:view];
            _refreshHeaderView = view;
            
        }
        [_refreshHeaderView refreshLastUpdatedDate];
	}
    return self;
}

- (void)loadTable {
    [table reloadData];
    [pullToRefreshManager_ tableViewReloadFinished];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self retrieveLunboData];
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(updateScrollView) userInfo:nil repeats:YES];
    
    pageSize = 20;
    videoType = 0;
    [self retrieveTopsListData];
}

- (void)retrieveLunboData
{
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:@"lunbo_list"];
    if(cacheResult != nil){
        [self parseLunboData:cacheResult];
    }
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([hostReach currentReachabilityStatus] != NotReachable) {
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

- (void)retrieveTopsListData
{
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:@"top_list"];
    if(cacheResult != nil){
        [self parseTopsListData:cacheResult];
    }
    if([hostReach currentReachabilityStatus] == NotReachable) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_MB_PROGRESS_BAR object:self userInfo:nil];
        [UIUtility showNetWorkError:self.view];
    } else {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: @"1", @"page_num", [NSNumber numberWithInt:pageSize], @"page_size", nil];
        [[AFServiceAPIClient sharedClient] getPath:kPathTops parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [self parseTopsListData:result];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
            if(topsArray == nil){
                topsArray = [[NSMutableArray alloc]initWithCapacity:10];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_MB_PROGRESS_BAR object:self userInfo:nil];
            [UIUtility showSystemError:self.view];
        }];
    }
}

- (void)reloadTableViewDataSource{
    reloads_ = 2;
    [self retrieveLunboData];
	if(videoType == 0){
        [self retrieveTopsListData];
        [pullToRefreshManager_ setPullToRefreshViewVisible:YES];
    } else if(videoType == 1){
        [self retrieveMovieTopsData];
    } else if(videoType == 2){
        [self retrieveTvTopsData];
    } else if(videoType == 3){
        [self retrieveShowTopsData];
    }
    _reloading = YES;
}


- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:table];
	
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

- (void)MNMBottomPullToRefreshManagerClientReloadTable {
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [UIUtility showNetWorkError:self.view];
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:0.0f];
        return;
    }
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:reloads_], @"page_num", [NSNumber numberWithInt:pageSize], @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathTops parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        NSArray *tempTopsArray;
        if(responseCode == nil){
            tempTopsArray = [result objectForKey:@"tops"];
            if(tempTopsArray.count > 0){
                [topsArray addObjectsFromArray:tempTopsArray];
                reloads_ ++;
            }
        } else {
            
        }
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:0.0f];
        if(tempTopsArray.count < pageSize){
            [pullToRefreshManager_ setPullToRefreshViewVisible:NO];
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:0.0f];
    }];
}

- (void)parseTopsListData:(id)result
{
    topsArray = [[NSMutableArray alloc]initWithCapacity:pageSize];
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        NSArray *tempTopsArray = [result objectForKey:@"tops"];
        if(tempTopsArray.count > 0){
            [[CacheUtility sharedCache] putInCache:@"top_list" result:result];
            [topsArray addObjectsFromArray:tempTopsArray];
        }
    } else {
        [UIUtility showSystemError:self.view];
    }
    [self loadTable];
    [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_MB_PROGRESS_BAR object:self userInfo:nil];
}


- (void)retrieveMovieTopsData
{
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:@"movie_top_list"];
    if(cacheResult != nil){
        [self parseMovieTopsData:cacheResult];
    }
    if([hostReach currentReachabilityStatus] == NotReachable) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_MB_PROGRESS_BAR object:self userInfo:nil];
        [UIUtility showNetWorkError:self.view];
    } else {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: @"1", @"page_num", [NSNumber numberWithInt:10], @"page_size", nil];
        [[AFServiceAPIClient sharedClient] getPath:kPathMoiveTops parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [self parseMovieTopsData:result];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
            movieTopsArray = [[NSMutableArray alloc]initWithCapacity:10];
            [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_MB_PROGRESS_BAR object:self userInfo:nil];
            [UIUtility showSystemError:self.view];
        }];
    }
}

- (void)parseMovieTopsData:(id)result
{
    movieTopsArray = [[NSMutableArray alloc]initWithCapacity:10];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_MB_PROGRESS_BAR object:self userInfo:nil];
}


- (void)retrieveTvTopsData
{
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:@"tv_top_list"];
    if(cacheResult != nil){
        [self parseTvTopsData:cacheResult];
    }
    if([hostReach currentReachabilityStatus] == NotReachable) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_MB_PROGRESS_BAR object:self userInfo:nil];
        [UIUtility showNetWorkError:self.view];
    } else {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: @"1", @"page_num", [NSNumber numberWithInt:10], @"page_size", nil];
        [[AFServiceAPIClient sharedClient] getPath:kPathTvTops parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [self parseTvTopsData:result];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
            tvTopsArray = [[NSMutableArray alloc]initWithCapacity:10];
            [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_MB_PROGRESS_BAR object:self userInfo:nil];
            [UIUtility showSystemError:self.view];
        }];
    }
}

- (void)parseTvTopsData:(id)result
{
    tvTopsArray = [[NSMutableArray alloc]initWithCapacity:10];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_MB_PROGRESS_BAR object:self userInfo:nil];
}


- (void)retrieveShowTopsData
{
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:@"show_top_list"];
    if(cacheResult != nil){
        [self parseShowTopsData:cacheResult];
    }
    if([hostReach currentReachabilityStatus] == NotReachable) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_MB_PROGRESS_BAR object:self userInfo:nil];
        [UIUtility showNetWorkError:self.view];
    } else {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: nil];
        [[AFServiceAPIClient sharedClient] getPath:kPathShowTops parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [self parseShowTopsData:result];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
            showTopsArray = [[NSMutableArray alloc]initWithCapacity:10];
            [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_MB_PROGRESS_BAR object:self userInfo:nil];
            [UIUtility showSystemError:self.view];
        }];
    }
}

- (void)parseShowTopsData:(id)result
{
    showTopsArray = [[NSMutableArray alloc]initWithCapacity:10];
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        NSArray *tempTopsArray = [result objectForKey:@"tops"];
        if(tempTopsArray.count > 0){
            NSArray *tempArray = [[tempTopsArray objectAtIndex:0] objectForKey:@"items"];
            if(tempArray.count > 0) {
                [[CacheUtility sharedCache] putInCache:@"show_top_list" result:result];
                [showTopsArray addObjectsFromArray:tempArray];
            }
        }
    } else {
        [UIUtility showSystemError:self.view];
    }
    [table reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_MB_PROGRESS_BAR object:self userInfo:nil];
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

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    if(aScrollView.tag == 11270014){
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
        if(videoType == 0)
            [pullToRefreshManager_ tableViewScrolled];
        
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
        if(videoType == 0)
            [pullToRefreshManager_ tableViewReleased];
    }
}


- (void)listBtnClicked:(UIButton *)sender
{
    videoType = 0;
    [self initTopButtonImage];
    [self loadTable];
}

- (void)movieBtnClicked:(UIButton *)sender
{
    videoType = 1;
    [self initTopButtonImage];
    [self retrieveMovieTopsData];
}

- (void)dramaBtnClicked:(UIButton *)sender
{
    videoType = 2;
    [self initTopButtonImage];
    [self retrieveTvTopsData];
}

- (void)showBtnClicked:(UIButton *)sender
{
    videoType = 3;
    [self initTopButtonImage];
    [self retrieveShowTopsData];
}

- (void)menuBtnClicked
{
    [self.menuViewControllerDelegate menuButtonClicked];
}

- (void)searchBtnClicked
{
    [self closeMenu];
    SubsearchViewController *viewController = [[SubsearchViewController alloc] initWithFrame:CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.frame.size.height)];
    [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:YES];
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
        if (videoType == 0) {
            return topsArray.count / 2;
        } else if(videoType == 1){
            return movieTopsArray.count;
        } else if(videoType == 2){
            return tvTopsArray.count;
        } else {
            return showTopsArray.count;
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
            UIImageView *lunboPlaceholder = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, TOP_IMAGE_HEIGHT)];
            lunboPlaceholder.image = [UIImage imageNamed:@"top_image_placeholder"];
            [cell.contentView addSubview:lunboPlaceholder];
            
            scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 4, self.view.frame.size.width- 12, TOP_IMAGE_HEIGHT - 8)];
            scrollView.tag = 11270014;
            scrollView.delegate = self;
            
            
            CGSize size = scrollView.frame.size;
            for (int i=0; i < 5; i++) {
                UIImageView *temp = [[UIImageView alloc]init];
                temp.tag = 9001 + i;
                temp.frame = CGRectMake(size.width * i, 0, size.width, size.height);
                
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
            
            pageControl = [[DDPageControl alloc] init] ;
            [pageControl setCenter: CGPointMake(self.view.center.x + LEFT_MENU_DIPLAY_WIDTH, TOP_IMAGE_HEIGHT + 10)] ;
            [pageControl setNumberOfPages: 5] ;
            [pageControl setCurrentPage: 0] ;
            [pageControl addTarget: self action: @selector(pageControlClicked:) forControlEvents: UIControlEventValueChanged] ;
            [pageControl setDefersCurrentPageDisplay: YES] ;
            [pageControl setType: DDPageControlTypeOnFullOffEmpty] ;
            [pageControl setOnColor: [UIColor colorWithRed:160/255.0 green:180/255.0 blue:195/255.0 alpha: 1.0f]] ;
            [pageControl setOffColor: [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha: 1.0f]] ;
            
            [pageControl setIndicatorDiameter: 7.0f] ;
            [pageControl setIndicatorSpace: 8.0f] ;
            [cell.contentView addSubview:pageControl];
        }
        for (int i = 0; i < 5; i++){
            UIImageView *temp = (UIImageView *)[scrollView viewWithTag:9001 + i];
            NSDictionary *lunboItem = [lunboArray objectAtIndex:i];
            [temp setImageWithURL:[NSURL URLWithString:[lunboItem objectForKey:@"ipad_pic"]] placeholderImage:[UIImage imageNamed:@"lunbo_placeholder"]];
        }
    } else {
        if (videoType == 0) {
            cell = [self getListCell:tableView cellForRowAtIndexPath:indexPath];
        } else if(videoType == 1){
            cell = [self getMovieCell:tableView cellForRowAtIndexPath:indexPath];
        } else if(videoType == 2){
            cell = [self getDramaCell:tableView cellForRowAtIndexPath:indexPath];
        } else {
            cell = [self getShowCell:tableView cellForRowAtIndexPath:indexPath];
        }
    }
    return cell;
}

- (UITableViewCell *)getListCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"listContentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellEditingStyleNone];
        UIImageView *contentImage1 = [[UIImageView alloc]initWithFrame:CGRectMake(40, 20, 87, 120)];
        contentImage1.tag = 2001;
        [cell.contentView addSubview:contentImage1];
        
        UIImageView *imageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(22, 0, LIST_LOGO_WIDTH, LIST_LOGO_HEIGHT)];
        imageView1.image = [UIImage imageNamed:@"briefcard_orange"];
        [cell.contentView addSubview:imageView1];
        
        UIImageView *hotImage1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"hot_signal"]];
        hotImage1.frame = CGRectMake(3, 3, 62, 62);
        [imageView1 addSubview:hotImage1];
        
        UIButton *imageBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        imageBtn1.frame = imageView1.frame;
        [imageBtn1 addTarget:self action:@selector(imageBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        imageBtn1.tag = 3001;
        [cell.contentView addSubview:imageBtn1];
        
        UILabel *nameLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(imageView1.frame.origin.x + 18, LIST_LOGO_HEIGHT - 35, 180, 20)];
        [nameLabel1 setBackgroundColor:[UIColor clearColor]];
        [nameLabel1 setTextColor:[UIColor whiteColor]];
        [nameLabel1 setFont:[UIFont boldSystemFontOfSize:15]];
        nameLabel1.tag = 6001;
        [cell.contentView addSubview:nameLabel1];
        
        UIImageView *contentImage2 = [[UIImageView alloc]initWithFrame:CGRectMake(22 + LIST_LOGO_WIDTH + 35, 20, 87, 120)];
        contentImage2.tag = 2002;
        [cell.contentView addSubview:contentImage2];
        
        UIImageView *imageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(22 + LIST_LOGO_WIDTH + 18, 0, LIST_LOGO_WIDTH, LIST_LOGO_HEIGHT)];
        imageView2.image = [UIImage imageNamed:@"briefcard_blue"];
        [cell.contentView addSubview:imageView2];
        
        UIImageView *hotImage2 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"hot_signal"]];
        hotImage2.frame = CGRectMake(3, 3, 62, 62);
        [imageView2 addSubview:hotImage2];
        
        UIButton *imageBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
        imageBtn2.frame = imageView2.frame;
        [imageBtn2 addTarget:self action:@selector(imageBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        imageBtn2.tag = 3002;
        [cell.contentView addSubview:imageBtn2];
        
        UILabel *nameLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(imageView2.frame.origin.x + 18, LIST_LOGO_HEIGHT - 35, 180, 20)];
        [nameLabel2 setBackgroundColor:[UIColor clearColor]];
        [nameLabel2 setTextColor:[UIColor whiteColor]];
        [nameLabel2 setFont:[UIFont boldSystemFontOfSize:15]];
        nameLabel2.tag = 7001;
        [cell.contentView addSubview:nameLabel2];
        
        UIImageView *typeImage1 = [[UIImageView alloc]initWithFrame:CGRectMake(150, 23, 40, 20)];
        typeImage1.tag = 8001;
        [cell.contentView addSubview:typeImage1];
        
        UIImageView *typeImage2 = [[UIImageView alloc]initWithFrame:CGRectMake(388, 23, 40, 20)];
        typeImage2.tag = 8002;
        [cell.contentView addSubview:typeImage2];
        
        for(int i = 0; i < 3; i++){
            UIView *dotView1 = [UIUtility getDotView:6];
            dotView1.center = CGPointMake(120, 58 + 18 * i);
            [imageView1 addSubview:dotView1];
            
            UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(150, 47 + i * 18, 80, 20)];
            [label1 setBackgroundColor:[UIColor clearColor]];
            [label1 setTextColor:CMConstants.grayColor];
            [label1 setFont:[UIFont systemFontOfSize:12]];
            label1.tag = 4001 + i;
            [cell.contentView addSubview:label1];
            
            UIView *dotView11 = [UIUtility getDotView:4];
            dotView11.center = CGPointMake(130 + 6 * i, 115);
            [imageView1 addSubview:dotView11];
            
            UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(388, 47 + i * 18, 80, 20)];
            [label2 setBackgroundColor:[UIColor clearColor]];
            [label2 setTextColor:CMConstants.grayColor];
            [label2 setFont:[UIFont systemFontOfSize:12]];
            label2.tag = 5001 + i;
            [cell.contentView addSubview:label2];
            
            UIView *dotView2 = [UIUtility getDotView:6];
            dotView2.center = CGPointMake(120, 58 + 18 * i);
            [imageView2 addSubview:dotView2];
            
            UIView *dotView22 = [UIUtility getDotView:4];
            dotView22.center = CGPointMake(130 + 6 * i, 115);
            [imageView2 addSubview:dotView22];
        }
    }
    NSDictionary *item1 = [topsArray objectAtIndex:indexPath.row * 2];
    NSDictionary *item2 = [topsArray objectAtIndex:indexPath.row * 2 + 1];
    
    UIImageView *contentImage1 = (UIImageView *)[cell viewWithTag:2001];
    [contentImage1 setImageWithURL:[NSURL URLWithString:[item1 objectForKey:@"pic_url"]] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
    
    UIImageView *contentImage2 = (UIImageView *)[cell viewWithTag:2002];
    [contentImage2 setImageWithURL:[NSURL URLWithString:[item2 objectForKey:@"pic_url"]] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
    
    UILabel *nameLabel1 = (UILabel *)[cell viewWithTag:6001];
    nameLabel1.text = [item1 objectForKey:@"name"];
    [nameLabel1 sizeToFit];
    UILabel *nameLabel2 = (UILabel *)[cell viewWithTag:7001];
    nameLabel2.text = [item2 objectForKey:@"name"];
    [nameLabel2 sizeToFit];
    
    NSString *type = [NSString stringWithFormat:@"%@", [item1 objectForKey:@"prod_type"]];
    UIImageView *typeImage1 = (UIImageView *)[cell viewWithTag:8001];
    if([type isEqualToString:@"1"]){
        typeImage1.image = [UIImage imageNamed:@"movie_type"];
    } else if([type isEqualToString:@"2"]){
        typeImage1.image = [UIImage imageNamed:@"drama_type"];
    } else {
        typeImage1.image = [UIImage imageNamed:@"show_type"];
    }
    
    UIImageView *typeImage2 = (UIImageView *)[cell viewWithTag:8002];
    type = [NSString stringWithFormat:@"%@", [item2 objectForKey:@"prod_type"]];
    if([type isEqualToString:@"1"]){
        typeImage2.image = [UIImage imageNamed:@"movie_type"];
    } else if([type isEqualToString:@"2"]){
        typeImage2.image = [UIImage imageNamed:@"drama_type"];
    } else {
        typeImage2.image = [UIImage imageNamed:@"show_type"];
    }
    
    NSArray *subitems1 = [item1 objectForKey:@"items"];
    NSArray *subitems2 = [item2 objectForKey:@"items"];
    for(int i = 0; i < 3; i++){
        UILabel *label1 = (UILabel *)[cell viewWithTag:(4001 + i)];
        label1.text = [[subitems1 objectAtIndex:i]objectForKey:@"prod_name"];
        UILabel *label2 = (UILabel *)[cell viewWithTag:(5001 + i)];
        label2.text = [[subitems2 objectAtIndex:i]objectForKey:@"prod_name"];
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
        UIScrollView *cellScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(12, 32, 450, MOVIE_LOGO_HEIGHT + 10)];
        cellScrollView.tag = 1011;
        for (int i=0; i < MOVIE_NUMBER; i++) {
            UIButton *tempBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImageView *movieImage = [[UIImageView alloc]init];
            movieImage.tag = 6011 + i;
            if(i == 5){
                tempBtn.frame = CGRectMake(12 + (MOVIE_LOGO_WEIGHT+5) * i, 0, MOVIE_LOGO_WEIGHT, MOVIE_LOGO_HEIGHT);
                movieImage.frame = CGRectMake(16 + (MOVIE_LOGO_WEIGHT+5) * i, 5, MOVIE_POSTER_WIDTH, MOVIE_POSTER_HEIGHT);
            } else {
                tempBtn.frame = CGRectMake(6 + (MOVIE_LOGO_WEIGHT+5) * i, 0, MOVIE_LOGO_WEIGHT, MOVIE_LOGO_HEIGHT);
                movieImage.frame = CGRectMake(10 + (MOVIE_LOGO_WEIGHT+5) * i, 5, MOVIE_POSTER_WIDTH, MOVIE_POSTER_HEIGHT);
            }
            [tempBtn setBackgroundImage:[UIImage imageNamed:@"moviecard"] forState:UIControlStateNormal];
            [tempBtn setBackgroundImage:[UIImage imageNamed:@"moviecard_pressed"] forState:UIControlStateHighlighted];
            tempBtn.tag = 2011 + i;
            [tempBtn addTarget:self action:@selector(movieImageClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cellScrollView addSubview:movieImage];
            [cellScrollView addSubview:tempBtn];
            
            UILabel *tempLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, MOVIE_LOGO_WEIGHT*0.8, 30)];
            [tempLabel setTextAlignment:NSTextAlignmentCenter];
            [tempLabel setTextColor:[UIColor blackColor]];
            [tempLabel setBackgroundColor:[UIColor clearColor]];
            [tempLabel setFont:[UIFont systemFontOfSize:13]];
            tempLabel.center = CGPointMake(tempBtn.center.x, 20 + MOVIE_LOGO_HEIGHT * 0.7);
            tempLabel.tag = 3011 + i;
            [cellScrollView addSubview:tempLabel];
        }
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(22, 12, 200, 30)];
        [titleLabel setTextColor:[UIColor blackColor]];
        [titleLabel setFont:[UIFont systemFontOfSize:15]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        titleLabel.tag = 4011;
        [cell.contentView addSubview:titleLabel];
        
        [cellScrollView setContentSize:CGSizeMake((MOVIE_LOGO_WEIGHT+5) * MOVIE_NUMBER + 12, MOVIE_LOGO_HEIGHT)];
        cellScrollView.pagingEnabled = YES;
        cellScrollView.showsHorizontalScrollIndicator = NO;
        [cell.contentView addSubview:cellScrollView];
        
        UIButton *scrollBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        scrollBtn.frame = CGRectMake(cellScrollView.frame.origin.x + cellScrollView.frame.size.width, cellScrollView.frame.origin.y, 23, MOVIE_LOGO_HEIGHT);
        [scrollBtn setImage:[UIImage imageNamed:@"scroll_btn"] forState:UIControlStateNormal];
        [scrollBtn setImage:[UIImage imageNamed:@"scroll_btn_pressed"] forState:UIControlStateHighlighted];
        scrollBtn.tag = 5011;
        [scrollBtn addTarget:self action:@selector(scrollBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:scrollBtn];
    }
    NSDictionary *item = [movieTopsArray objectAtIndex:indexPath.row];
    UIScrollView *cellScrollView = (UIScrollView *)[cell viewWithTag:1011];
    cellScrollView.contentOffset = CGPointMake(0, 0);
    NSArray *subitemArray = [item objectForKey:@"items"];
    for(int i = 0; i < subitemArray.count; i++){
        UIImageView *contentImage = (UIImageView *)[cell viewWithTag:6011 + i];
        NSDictionary *subitem = [subitemArray objectAtIndex:i];
        [contentImage setImageWithURL:[NSURL URLWithString:[subitem objectForKey:@"prod_pic_url"]] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
        UILabel *tempLabel = (UILabel *)[cellScrollView viewWithTag:3011 + i];
        tempLabel.text = [subitem objectForKey:@"prod_name"];
    }
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:4011];
    [titleLabel setText:[item objectForKey:@"name"]];
    [titleLabel sizeToFit];
    return cell;
}

- (UITableViewCell *)getDramaCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"dramaContentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellEditingStyleNone];
        UIScrollView *cellScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(12, 32, 450, MOVIE_LOGO_HEIGHT + 10)];
        cellScrollView.tag = 1021;
        for (int i=0; i < DRAMA_NUMBER; i++) {
            UIButton *tempBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImageView *movieImage = [[UIImageView alloc]init];
            movieImage.tag = 6021 + i;
            if(i == 5){
                tempBtn.frame = CGRectMake(12 + (MOVIE_LOGO_WEIGHT+5) * i, 0, MOVIE_LOGO_WEIGHT, MOVIE_LOGO_HEIGHT);
                movieImage.frame = CGRectMake(16 + (MOVIE_LOGO_WEIGHT+5) * i, 5, MOVIE_POSTER_WIDTH, MOVIE_POSTER_HEIGHT);
            } else {
                tempBtn.frame = CGRectMake(6 + (MOVIE_LOGO_WEIGHT+5) * i, 0, MOVIE_LOGO_WEIGHT, MOVIE_LOGO_HEIGHT);
                movieImage.frame = CGRectMake(10 + (MOVIE_LOGO_WEIGHT+5) * i, 5, MOVIE_POSTER_WIDTH, MOVIE_POSTER_HEIGHT);
            }
            [tempBtn setImage:[UIImage imageNamed:@"moviecard"] forState:UIControlStateNormal];
            [tempBtn setImage:[UIImage imageNamed:@"moviecard_pressed"] forState:UIControlStateHighlighted];
            tempBtn.tag = 2021 + i;
            [tempBtn addTarget:self action:@selector(dramaImageClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cellScrollView addSubview:movieImage];
            [cellScrollView addSubview:tempBtn];
            
            UILabel *tempLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, MOVIE_LOGO_WEIGHT*0.8, 30)];
            [tempLabel setTextAlignment:NSTextAlignmentCenter];
            [tempLabel setTextColor:[UIColor blackColor]];
            [tempLabel setBackgroundColor:[UIColor clearColor]];
            [tempLabel setFont:[UIFont systemFontOfSize:13]];
            tempLabel.center = CGPointMake(tempBtn.center.x, 20 + MOVIE_LOGO_HEIGHT * 0.7);
            tempLabel.tag = 3021 + i;
            [cellScrollView addSubview:tempLabel];
            
            
        }
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(22, 12, 200, 30)];
        [titleLabel setTextColor:[UIColor blackColor]];
        [titleLabel setFont:[UIFont systemFontOfSize:15]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        titleLabel.tag = 4021;
        [cell.contentView addSubview:titleLabel];
        
        [cellScrollView setContentSize:CGSizeMake((MOVIE_LOGO_WEIGHT+5) * DRAMA_NUMBER + 12, MOVIE_LOGO_HEIGHT)];
        cellScrollView.pagingEnabled = YES;
        cellScrollView.showsHorizontalScrollIndicator = NO;
        [cell.contentView addSubview:cellScrollView];
        
        UIButton *scrollBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        scrollBtn.frame = CGRectMake(cellScrollView.frame.origin.x + cellScrollView.frame.size.width, cellScrollView.frame.origin.y, 23, MOVIE_LOGO_HEIGHT);
        [scrollBtn setImage:[UIImage imageNamed:@"scroll_btn"] forState:UIControlStateNormal];
        [scrollBtn setImage:[UIImage imageNamed:@"scroll_btn_pressed"] forState:UIControlStateHighlighted];
        scrollBtn.tag = 5021;
        [scrollBtn addTarget:self action:@selector(scrollBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:scrollBtn];
    }
    NSDictionary *item = [tvTopsArray objectAtIndex:indexPath.row];
    UIScrollView *cellScrollView = (UIScrollView *)[cell viewWithTag:1021];
    cellScrollView.contentOffset = CGPointMake(0, 0);
    NSArray *subitemArray = [item objectForKey:@"items"];
    for(int i = 0; i < subitemArray.count; i++){
        UIImageView *contentImage = (UIImageView *)[cell viewWithTag:6021 + i];
        NSDictionary *subitem = [subitemArray objectAtIndex:i];
        [contentImage setImageWithURL:[NSURL URLWithString:[subitem objectForKey:@"prod_pic_url"]] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
        UILabel *tempLabel = (UILabel *)[cellScrollView viewWithTag:3021 + i];
        tempLabel.text = [subitem objectForKey:@"prod_name"];
    }
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:4021];
    [titleLabel setText:[item objectForKey:@"name"]];
    [titleLabel sizeToFit];
    return cell;
}

- (UITableViewCell *)getShowCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"showContentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImageView *tempImage = [[UIImageView alloc]initWithFrame:CGRectMake(12, 5, SHOW_LOGO_WEIGHT, SHOW_LOGO_HEIGHT)];
        tempImage.tag = 1031;
        [cell.contentView addSubview:tempImage];
        
        UIImageView *overLayImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"show_overlay"]];
        overLayImage.frame = CGRectMake(tempImage.frame.origin.x, 5 + SHOW_LOGO_HEIGHT-38 , tempImage.frame.size.width-6, 38);
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
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, overLayImage.frame.origin.y + 8, overLayImage.frame.size.width, 20)];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        titleLabel.textAlignment = NSTextAlignmentRight;
        [titleLabel setFont:[UIFont systemFontOfSize:14]];
        titleLabel.tag = 4031;
        [cell.contentView addSubview:titleLabel];
    }
    NSDictionary *item = [showTopsArray objectAtIndex:indexPath.row];
    UIImageView *tempImage = (UIImageView *)[cell viewWithTag:1031];
    [tempImage setImageWithURL:[NSURL URLWithString:[item objectForKey:@"prod_pic_url"]] placeholderImage:[UIImage imageNamed:@"show_placeholder"]];
    
    UILabel *tempNameLabel = (UILabel *)[cell viewWithTag:3031];
    [tempNameLabel setText:[item objectForKey:@"prod_name"]];
    [tempNameLabel sizeToFit];
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:4031];
    NSString *titleText = (NSString *)[item objectForKey:@"cur_item_name"];
    if(titleText.length > 20){
        [titleLabel setText:[NSString stringWithFormat:@"更新至：%@", [titleText substringToIndex:20]]];
    } else {
        [titleLabel setText:[NSString stringWithFormat:@"更新至：%@", titleText]];
    }
    return cell;
}

- (void)scrollBtnClicked:(UIButton *)sender
{
    UIButton *btn = (UIButton *)sender;
    CGPoint point = btn.center;
    point = [table convertPoint:point fromView:btn.superview];
    NSIndexPath* indexPath = [table indexPathForRowAtPoint:point];
    UITableViewCell *cell = [table cellForRowAtIndexPath:indexPath];
    UIScrollView *cellScrollView = (UIScrollView *)[cell viewWithTag:1011];
    if(cellScrollView == nil){
        cellScrollView = (UIScrollView *)[cell viewWithTag:1021];
    }
    [cellScrollView setContentOffset: CGPointMake(cellScrollView.bounds.size.width, 0) animated: YES] ;
}

- (void)lunboImageClicked:(UIButton *)btn
{
    [self closeMenu];
    int index = btn.tag - 9021;
    [self showDetailScreen:[lunboArray objectAtIndex:index]];
    
}

- (void)showDetailScreen:(NSDictionary *)item
{
    NSString *prodType = [NSString stringWithFormat:@"%@", [item objectForKey:@"prod_type"]];
    if([prodType isEqualToString:@"1"]){
        MovieDetailViewController *viewController = [[MovieDetailViewController alloc] initWithNibName:@"MovieDetailViewController" bundle:nil];
        viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
        viewController.prodId = [NSString stringWithFormat:@"%@", [item objectForKey:@"prod_id"]];
        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE  removePreviousView:YES];
    } else if([prodType isEqualToString:@"2"]){
        DramaDetailViewController *viewController = [[DramaDetailViewController alloc] initWithNibName:@"DramaDetailViewController" bundle:nil];
        viewController.prodId = [NSString stringWithFormat:@"%@", [item objectForKey:@"prod_id"]];
        viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:YES];
    } else if([prodType isEqualToString:@"3"]){
        ShowDetailViewController *viewController = [[ShowDetailViewController alloc] initWithNibName:@"ShowDetailViewController" bundle:nil];
        viewController.prodId = [NSString stringWithFormat:@"%@", [item objectForKey:@"prod_id"]];
        viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:YES];
    }
}

- (void)movieImageClicked:(UIButton *)sender
{
    [self closeMenu];
    UIButton *btn = (UIButton *)sender;
    CGPoint point = btn.center;
    point = [table convertPoint:point fromView:btn.superview];
    NSIndexPath* indexPath = [table indexPathForRowAtPoint:point];
    
    NSArray *items = [[movieTopsArray objectAtIndex:indexPath.row] objectForKey:@"items"];
    if(btn.tag - 2011 < items.count){
        NSDictionary *item = [items objectAtIndex:btn.tag - 2011];
        [self showDetailScreen:item];
    }
}

- (void)dramaImageClicked:(UIButton *)sender
{
    [self closeMenu];
    UIButton *btn = (UIButton *)sender;
    CGPoint point = btn.center;
    point = [table convertPoint:point fromView:btn.superview];
    NSIndexPath* indexPath = [table indexPathForRowAtPoint:point];
    
    NSArray *items = [[tvTopsArray objectAtIndex:indexPath.row] objectForKey:@"items"];
    if(btn.tag - 2021 < items.count){
        NSDictionary *item = [items objectAtIndex:btn.tag - 2021];
        [self showDetailScreen:item];
    }
}

- (void)showImageClicked:(UIButton *)sender
{
    [self closeMenu];
    UIButton *btn = (UIButton *)sender;
    CGPoint point = btn.center;
    point = [table convertPoint:point fromView:btn.superview];
    NSIndexPath* indexPath = [table indexPathForRowAtPoint:point];
    NSDictionary *item = [showTopsArray objectAtIndex:indexPath.row];
    [self showDetailScreen:item];
}

- (void)imageBtnClicked:(UIButton *)sender
{
    [self closeMenu];
    UIButton *btn = (UIButton *)sender;
    CGPoint point = btn.center;
    point = [table convertPoint:point fromView:btn.superview];
    NSIndexPath* indexPath = [table indexPathForRowAtPoint:point];
    ListViewController *viewController = [[ListViewController alloc] init];
    viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
    NSDictionary *item = [topsArray objectAtIndex:floor(indexPath.row * 2.0) + btn.tag - 3001];
    NSString *topId = [NSString stringWithFormat:@"%@", [item objectForKey: @"id"]];
    viewController.topId = topId;
    viewController.listTitle = [item objectForKey: @"name"];
    [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:YES];
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        return TOP_IMAGE_HEIGHT + 16;
    } else {
        if (videoType == 0) {
            return LIST_LOGO_HEIGHT + 10;
        } else if(videoType == 1){
            return MOVIE_LOGO_HEIGHT + 40;
        } else if(videoType == 2){
            return MOVIE_LOGO_HEIGHT + 40;
        } else {
            return SHOW_LOGO_HEIGHT + 10;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return 0;
    } else {
        return 40;
    }
}

- (void)initTopButtonImage
{
    [listBtn setBackgroundImage:[UIImage imageNamed:@"list_btn"] forState:UIControlStateNormal];
    [listBtn setBackgroundImage:[UIImage imageNamed:@"list_btn_pressed"] forState:UIControlStateHighlighted];
    [movieBtn setBackgroundImage:[UIImage imageNamed:@"movie_btn"] forState:UIControlStateNormal];
    [movieBtn setBackgroundImage:[UIImage imageNamed:@"movie_btn_pressed"] forState:UIControlStateHighlighted];
    [dramaBtn setBackgroundImage:[UIImage imageNamed:@"drama_btn"] forState:UIControlStateNormal];
    [dramaBtn setBackgroundImage:[UIImage imageNamed:@"drama_btn_pressed"] forState:UIControlStateHighlighted];
    [showBtn setBackgroundImage:[UIImage imageNamed:@"show_btn"] forState:UIControlStateNormal];
    [showBtn setBackgroundImage:[UIImage imageNamed:@"show_btn_pressed"] forState:UIControlStateHighlighted];
    if (videoType == 0) {
        [listBtn setBackgroundImage:[UIImage imageNamed:@"list_btn_pressed"] forState:UIControlStateNormal];
    } else if(videoType == 1){
        [movieBtn setBackgroundImage:[UIImage imageNamed:@"movie_btn_pressed"] forState:UIControlStateNormal];
    } else if(videoType == 2){
        [dramaBtn setBackgroundImage:[UIImage imageNamed:@"drama_btn_pressed"] forState:UIControlStateNormal];
    } else {
        [showBtn setBackgroundImage:[UIImage imageNamed:@"show_btn_pressed"] forState:UIControlStateNormal];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width, 40)];
    customView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
    if(listBtn == nil){
        listBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        listBtn.frame = CGRectMake(12, 0, VIDEO_BUTTON_WIDTH, VIDEO_BUTTON_HEIGHT);
        listBtn.tag = 1001;
        [listBtn addTarget:self action:@selector(listBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        movieBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        movieBtn.frame = CGRectMake(12 + VIDEO_BUTTON_WIDTH + 6, 0, VIDEO_BUTTON_WIDTH, VIDEO_BUTTON_HEIGHT);
        movieBtn.tag = 1002;
        [movieBtn addTarget:self action:@selector(movieBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        dramaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        dramaBtn.frame = CGRectMake(12 + (VIDEO_BUTTON_WIDTH + 6)*2, 0, VIDEO_BUTTON_WIDTH, VIDEO_BUTTON_HEIGHT);
        dramaBtn.tag = 1003;
        [dramaBtn addTarget:self action:@selector(dramaBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        showBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        showBtn.frame = CGRectMake(12 + (VIDEO_BUTTON_WIDTH + 6)*3, 0, VIDEO_BUTTON_WIDTH, VIDEO_BUTTON_HEIGHT);
        showBtn.tag = 1004;
        [showBtn addTarget:self action:@selector(showBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self initTopButtonImage];
    [customView addSubview:listBtn];
    [customView addSubview:movieBtn];
    [customView addSubview:dramaBtn];
    [customView addSubview:showBtn];
    
    return customView;
}



#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


@end
