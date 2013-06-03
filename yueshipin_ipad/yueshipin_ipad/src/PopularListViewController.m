//
//  HomeViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-20.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "PopularListViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DDPageControl.h"
#import "MovieDetailViewController.h"
#import "DramaDetailViewController.h"
#import "ShowDetailViewController.h"
#import "ListViewController.h"
#import "SubsearchViewController.h"
#import "CommonHeader.h"
#import "ContainerUtility.h"
#import "AppDelegate.h"

#define TOP_IMAGE_HEIGHT 170
#define LIST_LOGO_WIDTH 223
#define LIST_LOGO_HEIGHT 184
#define VIDEO_BUTTON_WIDTH 250
#define VIDEO_BUTTON_HEIGHT 52
#define TOP_SOLGAN_HEIGHT 93

@interface PopularListViewController (){
    UIScrollView *scrollView;
    UIImageView *sloganImageView;
    UITableView *table;
    DDPageControl *pageControl;
    NSArray *lunboArray;
    PullRefreshManagerClinet *pullToRefreshManager_;
    NSUInteger reloads_;
    NSUInteger dramaReloads;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    int pageSize;
    
    NSTimer *timer;
    
    UIButton *lastPressedBtn;
    UILabel *lastPressedLabel;
    int selectedRowNumber;
    
    UIImageView *lastSelectedListImage;
    UIImageView *lastSelectedOverlay;
    
    NSString *umengPageName;
}
@property (nonatomic, strong) UIView *customHeaderView;
@property (nonatomic, strong) UIButton *movieListBtn;
@property (nonatomic, strong) UIButton *dramaListBtn;
@property (nonatomic) TopicType topicType; // 1: 电影悦榜 2: 电视剧悦榜
@property (nonatomic, strong) NSMutableArray *movieTopsArray;
@property (nonatomic, strong) NSMutableArray *tvTopsArray;

- (void)setAutoScrollTimer;
- (void)cancelAutoScrollTimer;

@end

@implementation PopularListViewController
@synthesize customHeaderView, movieListBtn, dramaListBtn, topicType;
@synthesize movieTopsArray, tvTopsArray;

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
        sloganImageView.frame = CGRectMake(15, 36, 261, 42);
        [self.view addSubview:sloganImageView];
        
        table = [[UITableView alloc] initWithFrame:CGRectMake(3, 92, self.view.frame.size.width - 16, self.view.frame.size.height - TOP_SOLGAN_HEIGHT) style:UITableViewStylePlain];
        [table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
		[table setDelegate:self];
		[table setDataSource:self];
        [table setBackgroundColor:[UIColor clearColor]];
        [table setShowsVerticalScrollIndicator:NO];
		//[table setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
		[self.view addSubview:table];
        
        pullToRefreshManager_ = [[PullRefreshManagerClinet alloc] initWithTableView:table];
        pullToRefreshManager_.delegate = self;
        [pullToRefreshManager_  setShowHeaderView:NO];
        reloads_ = 2;
        dramaReloads = 2;
        
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
    [[AppDelegate instance].rootViewController showIntroModalView:SHOW_MENU_INTRO_YUEDAN introImage:[UIImage imageNamed:@"menu_intro"]];
    
    if (0 == lunboArray.count)
    {
        [self retrieveLunboData];
    }
    if (0 == movieTopsArray.count || 0 == tvTopsArray.count)
    {
        [self retrieveTopsListData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    umengPageName = POPULAR_MOVIE_LIST;
    //[self retrieveLunboData];
    timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(updateScrollView) userInfo:nil repeats:YES];
    
    pageSize = 20;
    topicType = MOVIE_TOPIC;
    movieTopsArray = [[NSMutableArray alloc]initWithCapacity:pageSize];
    tvTopsArray = [[NSMutableArray alloc]initWithCapacity:pageSize];
    //[self retrieveTopsListData];
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

- (void)retrieveTopsListData
{
    if (umengPageName) {
        [MobClick endLogPageView:umengPageName];
    }
    if (topicType == MOVIE_TOPIC) {
        umengPageName = POPULAR_MOVIE_LIST;
    } else if(topicType == DRAMA_TOPIC){
        umengPageName = POPULAR_TV_LIST;
    }
    umengPageName = POPULAR_MOVIE_LIST;
    [MobClick beginLogPageView:umengPageName];
    //Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    id cacheResult = [[CacheUtility sharedCache] loadFromCache: [NSString stringWithFormat: @"top_list_%i", topicType]];
    if(cacheResult != nil){
        [self parseTopsListData:cacheResult];
    } else {
        [myHUD showProgressBar:self.view];
    }
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [myHUD hide];
        [UIUtility showNetWorkError:self.view];
    } else {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: @"1", @"page_num", [NSNumber numberWithInt:pageSize], @"page_size", [NSNumber numberWithInt:topicType], @"topic_type", nil];
        [[AFServiceAPIClient sharedClient] getPath:kPathTops parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [self parseTopsListData:result];
            [myHUD hide];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
            [myHUD hide];
            [UIUtility showDetailError:self.view error:error];
        }];
    }
}


- (void)reloadTableViewDataSource{
    reloads_ = 2;
    dramaReloads = 2;
    [self retrieveLunboData];
	if(topicType == MOVIE_TOPIC){
        [self retrieveTopsListData];
//        [pullToRefreshManager_ setPullToRefreshViewVisible:YES];
//        [dramaPullToRefreshManager_ setPullToRefreshViewVisible:NO];
    } else if(topicType == DRAMA_TOPIC){
//        [pullToRefreshManager_ setPullToRefreshViewVisible:NO];
//        [dramaPullToRefreshManager_ setPullToRefreshViewVisible:NO];
        [self retrieveTopsListData];
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
	
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

-(void)pulltoLoadMore{
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [UIUtility showNetWorkError:self.view];
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:0.0f];
        return;
    }
    NSNumber *pageNumber;
    if (topicType == MOVIE_TOPIC) {
        pageNumber = [NSNumber numberWithInt:reloads_];
    } else if(topicType == DRAMA_TOPIC){
        pageNumber = [NSNumber numberWithInt:dramaReloads];
    }
    NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!%@",pageNumber);
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: pageNumber, @"page_num", [NSNumber numberWithInt:pageSize], @"page_size", [NSNumber numberWithInt:topicType], @"topic_type", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathTops parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        NSArray *tempTopsArray;
        if(responseCode == nil){
            tempTopsArray = [result objectForKey:@"tops"];
            if(tempTopsArray.count > 0){
                if (topicType ==  MOVIE_TOPIC) {
                    [movieTopsArray addObjectsFromArray:tempTopsArray];
                    reloads_ ++;
                } else if (topicType == DRAMA_TOPIC){
                    [tvTopsArray addObjectsFromArray:tempTopsArray];
                    dramaReloads ++;
                }
            }
        } else {
            
        }
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:0.0f];
        if (tempTopsArray.count < pageSize) {
            pullToRefreshManager_.canLoadMore = NO;
        }
        else{
            pullToRefreshManager_.canLoadMore = YES;
        }
        [pullToRefreshManager_ loadMoreCompleted];
        //        if(topicType ==  MOVIE_TOPIC && tempTopsArray.count < pageSize){
        //            [pullToRefreshManager_ setPullToRefreshViewVisible:NO];
        //        } else if(topicType ==  DRAMA_TOPIC && tempTopsArray.count < pageSize){
        //            [dramaPullToRefreshManager_ setPullToRefreshViewVisible:NO];
        //        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:0.0f];
    }];


}

- (void)parseTopsListData:(id)result
{
    if (topicType == MOVIE_TOPIC) {
        [movieTopsArray removeAllObjects];
    } else if(topicType == DRAMA_TOPIC){
        [tvTopsArray removeAllObjects];
    }
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        NSArray *tempTopsArray = [result objectForKey:@"tops"];
        if(tempTopsArray.count > 0){
            [[CacheUtility sharedCache] putInCache:[NSString stringWithFormat: @"top_list_%i", topicType] result:result];
            if (topicType == MOVIE_TOPIC) {
                [movieTopsArray addObjectsFromArray:tempTopsArray];
            } else if (topicType == DRAMA_TOPIC){
                [tvTopsArray addObjectsFromArray:tempTopsArray];
            }
            if (tempTopsArray.count < pageSize) {
                pullToRefreshManager_.canLoadMore = NO;
            }
            else{
                 pullToRefreshManager_.canLoadMore = YES;
            }
        }
    } else {
        [UIUtility showSystemError:self.view];
    }
    [self loadTable];
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

- (void) scrollViewWillBeginDragging:(UIScrollView *)ascrollView
{
    if (ascrollView.tag == 11270014) {
        return;
    }
    [pullToRefreshManager_ scrollViewBegin];
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
//        if(topicType == MOVIE_TOPIC){
//            [pullToRefreshManager_ tableViewScrolled];
//        } else if(topicType == DRAMA_TOPIC){
//            [dramaPullToRefreshManager_ tableViewScrolled];
//        }
          [pullToRefreshManager_ scrollViewScrolled:aScrollView];
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
//        if(topicType == MOVIE_TOPIC){
//            [pullToRefreshManager_ tableViewReleased];
//        } else if(topicType == DRAMA_TOPIC){
//            [dramaPullToRefreshManager_ tableViewReleased];
//        }
        [pullToRefreshManager_ scrollViewEnd:aScrollView];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)ascrollView
{
    if(ascrollView.tag == 11270014)
    {
        [self setAutoScrollTimer];
    }
}


- (void)movieListBtnClicked:(UIButton *)sender
{
    [[AppDelegate instance].rootViewController.stackScrollViewController removeViewToViewInSlider:AdViewController.class];
//    [pullToRefreshManager_ setPullToRefreshViewVisible:YES];
//    [dramaPullToRefreshManager_ setPullToRefreshViewVisible:NO];
    BOOL isReachable = [[AppDelegate instance] performSelector:@selector(isParseReachable)];
    if(!isReachable) {
        [UIUtility showNetWorkError:self.view];
    }
    topicType = MOVIE_TOPIC;
    [self initTopButtonImage];
    //[self loadTable];
    [self retrieveTopsListData];
}

- (void)dramaListBtnClicked:(UIButton *)sender
{
    [[AppDelegate instance].rootViewController.stackScrollViewController removeViewToViewInSlider:AdViewController.class]; 
//    [pullToRefreshManager_ setPullToRefreshViewVisible:NO];
//    [dramaPullToRefreshManager_ setPullToRefreshViewVisible:YES];
    BOOL isReachable = [[AppDelegate instance] performSelector:@selector(isParseReachable)];
    if(!isReachable) {
        [UIUtility showNetWorkError:self.view];
    }
    topicType = DRAMA_TOPIC;
    [self initTopButtonImage];
    [self retrieveTopsListData];
//    if (tvTopsArray.count > 0) {
//        [self loadTable];
//    } else {
//        [self retrieveTopsListData];
//    }
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
        if (topicType == MOVIE_TOPIC) {
            return movieTopsArray.count / 2;
        } else {
            return tvTopsArray.count / 2;
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
        cell = [self getListCell:tableView cellForRowAtIndexPath:indexPath];
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
        UIImageView *imageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(25, 0, LIST_LOGO_WIDTH, LIST_LOGO_HEIGHT)];
        imageView1.image = [UIImage imageNamed:@"briefcard_blue"];
        [cell.contentView addSubview:imageView1];
        
        UIImageView *selectedImage1 = [[UIImageView alloc]initWithFrame:CGRectMake(27, LIST_LOGO_HEIGHT - 36, LIST_LOGO_WIDTH - 4, 33)];
        selectedImage1.image = [UIImage imageNamed:@"gray_bg"];
        selectedImage1.tag = 3101;
        [cell.contentView addSubview:selectedImage1];
        
        UIImageView *placeHolderImage1 = [[UIImageView alloc]init];
        placeHolderImage1.image = [UIImage imageNamed:@"video_bg_placeholder"];
        placeHolderImage1.frame = CGRectMake(36, 16, 95, 128);
        [cell.contentView addSubview:placeHolderImage1];
        
        UIImageView *contentImage1 = [[UIImageView alloc]initWithFrame:CGRectMake(40, 20, 87, 120)];
        contentImage1.tag = 2001;
        [cell.contentView addSubview:contentImage1];
        
        UIImageView *hotImage1 = [[UIImageView alloc]initWithFrame:CGRectMake(25 + LIST_LOGO_WIDTH - 38, -3, 42, 42)];
        hotImage1.tag = 1111;
        [cell.contentView addSubview:hotImage1];
        
        UIButton *imageBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        imageBtn1.frame = imageView1.frame;
        [imageBtn1 addTarget:self action:@selector(imageBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        imageBtn1.tag = 3001;
        [cell.contentView addSubview:imageBtn1];
        
        UILabel *nameLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(imageView1.frame.origin.x + 18, LIST_LOGO_HEIGHT - 31, 200, 20)];
        [nameLabel1 setBackgroundColor:[UIColor clearColor]];
        [nameLabel1 setTextColor:[UIColor whiteColor]];
        [nameLabel1 setFont:[UIFont boldSystemFontOfSize:15]];
        nameLabel1.tag = 6001;
        [cell.contentView addSubview:nameLabel1];
        
        UIImageView *imageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(24 + LIST_LOGO_WIDTH + 18, 0, LIST_LOGO_WIDTH, LIST_LOGO_HEIGHT)];
        imageView2.image = [UIImage imageNamed:@"briefcard_blue"];
        [cell.contentView addSubview:imageView2];
        
        UIImageView *selectedImage2 = [[UIImageView alloc]initWithFrame:CGRectMake(26 + LIST_LOGO_WIDTH + 18, LIST_LOGO_HEIGHT - 36, LIST_LOGO_WIDTH - 4, 33)];
        selectedImage2.image = [UIImage imageNamed:@"gray_bg"];
        selectedImage2.tag = 3102;
        [cell.contentView addSubview:selectedImage2];
        
        UIImageView *placeHolderImage2 = [[UIImageView alloc]init];
        placeHolderImage2.image = [UIImage imageNamed:@"video_bg_placeholder"];
        placeHolderImage2.frame = CGRectMake(18 + LIST_LOGO_WIDTH + 35, 16, 95, 128);
        [cell.contentView addSubview:placeHolderImage2];
        
        UIImageView *contentImage2 = [[UIImageView alloc]initWithFrame:CGRectMake(22 + LIST_LOGO_WIDTH + 35, 20, 87, 120)];
        contentImage2.tag = 2002;
        [cell.contentView addSubview:contentImage2];
        
        UIImageView *hotImage2 = [[UIImageView alloc]initWithFrame:CGRectMake(263 + LIST_LOGO_WIDTH - 36, -3, 42, 42)];
        hotImage2.tag = 1112;
        [cell.contentView addSubview:hotImage2];
        
        UIButton *imageBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
        imageBtn2.frame = imageView2.frame;
        [imageBtn2 addTarget:self action:@selector(imageBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        imageBtn2.tag = 3002;
        [cell.contentView addSubview:imageBtn2];
        
        UILabel *nameLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(imageView2.frame.origin.x + 18, LIST_LOGO_HEIGHT - 31, 200, 20)];
        [nameLabel2 setBackgroundColor:[UIColor clearColor]];
        [nameLabel2 setTextColor:[UIColor whiteColor]];
        [nameLabel2 setFont:[UIFont boldSystemFontOfSize:15]];
        nameLabel2.tag = 7001;
        [cell.contentView addSubview:nameLabel2];
        
        for(int i = 0; i < 3; i++){
            UIView *dotView1 = [UIUtility getDotView:6];
            dotView1.center = CGPointMake(119, 58 + 18 * i);
            [imageView1 addSubview:dotView1];
            
            UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(150, 47 + i * 18, 80, 20)];
            [label1 setBackgroundColor:[UIColor clearColor]];
            [label1 setTextColor:CMConstants.grayColor];
            [label1 setFont:[UIFont systemFontOfSize:13]];
            label1.tag = 4001 + i;
            [cell.contentView addSubview:label1];
            
            UIView *dotView11 = [UIUtility getDotView:4];
            dotView11.center = CGPointMake(130 + 6 * i, 115);
            [imageView1 addSubview:dotView11];
            
            UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(388, 47 + i * 18, 80, 20)];
            [label2 setBackgroundColor:[UIColor clearColor]];
            [label2 setTextColor:CMConstants.grayColor];
            [label2 setFont:[UIFont systemFontOfSize:13]];
            label2.tag = 5001 + i;
            [cell.contentView addSubview:label2];
            
            UIView *dotView2 = [UIUtility getDotView:6];
            dotView2.center = CGPointMake(117, 58 + 18 * i);
            [imageView2 addSubview:dotView2];
            
            UIView *dotView22 = [UIUtility getDotView:4];
            dotView22.center = CGPointMake(130 + 6 * i, 115);
            [imageView2 addSubview:dotView22];
        }
    }
    if ((topicType == MOVIE_TOPIC && indexPath.row * 2 + 1 < movieTopsArray.count) || (topicType == DRAMA_TOPIC && indexPath.row * 2 + 1 < tvTopsArray.count)) {
        NSDictionary *item1, *item2;
        if (topicType == MOVIE_TOPIC) {
            item1 = [movieTopsArray objectAtIndex:indexPath.row * 2];
            item2 = [movieTopsArray objectAtIndex:indexPath.row * 2 + 1];
        } else {
            item1 = [tvTopsArray objectAtIndex:indexPath.row * 2];
            item2 = [tvTopsArray objectAtIndex:indexPath.row * 2 + 1];
        }
        
        UIImageView *contentImage1 = (UIImageView *)[cell viewWithTag:2001];
        [contentImage1 setImageWithURL:[NSURL URLWithString:[item1 objectForKey:@"pic_url"]]];
        
        UIImageView *hotImage1 = (UIImageView *)[cell viewWithTag:1111];
        NSString *hotFlag1 = [NSString stringWithFormat:@"%@", [item1 objectForKey:@"toptype"]];
        if([hotFlag1 isEqualToString:@"1"]){
            hotImage1.image = [UIImage imageNamed:@"hot_signal"];
        } else {
            hotImage1.image = nil;
        }
        
        UIImageView *contentImage2 = (UIImageView *)[cell viewWithTag:2002];
        [contentImage2 setImageWithURL:[NSURL URLWithString:[item2 objectForKey:@"pic_url"]]];
        
        UIImageView *hotImage2 = (UIImageView *)[cell viewWithTag:1112];
        NSString *hotFlag2 = [NSString stringWithFormat:@"%@", [item2 objectForKey:@"toptype"]];
        if([hotFlag2 isEqualToString:@"1"]){
            hotImage2.image = [UIImage imageNamed:@"hot_signal"];
        } else {
            hotImage2.image = nil;
        }
        
        UILabel *nameLabel1 = (UILabel *)[cell viewWithTag:6001];
        nameLabel1.text = [item1 objectForKey:@"name"];
        UILabel *nameLabel2 = (UILabel *)[cell viewWithTag:7001];
        nameLabel2.text = [item2 objectForKey:@"name"];
        
        NSArray *subitems1 = [item1 objectForKey:@"items"];
        for(int i = 0; i < fmin(subitems1.count, 3); i++){
            UILabel *label1 = (UILabel *)[cell viewWithTag:(4001 + i)];
            label1.text = [[subitems1 objectAtIndex:i]objectForKey:@"prod_name"];
        }
        
        NSArray *subitems2 = [item2 objectForKey:@"items"];
        for(int i = 0; i < fmin(subitems2.count, 3); i++){
            UILabel *label2 = (UILabel *)[cell viewWithTag:(5001 + i)];
            label2.text = [[subitems2 objectAtIndex:i]objectForKey:@"prod_name"];
        }
        
        UIImageView *imageView1 = (UIImageView *)[cell viewWithTag:3101];
        UIImageView *imageView2 = (UIImageView *)[cell viewWithTag:3102];
        if(indexPath.row == selectedRowNumber){
            if(imageView1 == lastSelectedListImage){
                imageView1.image = [UIImage imageNamed:@"yellow_bg"];
            } else if(imageView2 == lastSelectedListImage){
                imageView2.image = [UIImage imageNamed:@"yellow_bg"];
            } else {
                imageView1.image = [UIImage imageNamed:@"gray_bg"];
                imageView2.image = [UIImage imageNamed:@"gray_bg"];
            }
        } else {
            imageView1.image = [UIImage imageNamed:@"gray_bg"];
            imageView2.image = [UIImage imageNamed:@"gray_bg"];
        }
    }
    return cell;
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
    
    if ([type isEqualToString:@"0"])
    {
        [self showDetailScreen:item];
    }
    else if ([type isEqualToString:@"1"])
    {
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
    NSString *prodType = [NSString stringWithFormat:@"%@", [item objectForKey:@"prod_type"]];
    if([prodType isEqualToString:@"1"]){
        MovieDetailViewController *viewController = [[MovieDetailViewController alloc] initWithNibName:@"MovieDetailViewController" bundle:nil];
        viewController.fromViewController = self;
        viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
        viewController.prodId = [NSString stringWithFormat:@"%@", [item objectForKey:@"prod_id"]];
        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE  removePreviousView:YES];
    } else if([prodType isEqualToString:@"2"] || [prodType isEqualToString:@"131"]){
        DramaDetailViewController *viewController = [[DramaDetailViewController alloc] initWithNibName:@"DramaDetailViewController" bundle:nil];
        viewController.fromViewController = self;
        viewController.prodId = [NSString stringWithFormat:@"%@", [item objectForKey:@"prod_id"]];
        viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:YES];
    } else if([prodType isEqualToString:@"3"]){
        ShowDetailViewController *viewController = [[ShowDetailViewController alloc] initWithNibName:@"ShowDetailViewController" bundle:nil];
        viewController.fromViewController = self;
        viewController.prodId = [NSString stringWithFormat:@"%@", [item objectForKey:@"prod_id"]];
        viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:YES];
    }
}

- (void)imageBtnClicked:(UIButton *)btn
{
    CGPoint point = btn.center;
    point = [table convertPoint:point fromView:btn.superview];
    NSIndexPath* indexPath = [table indexPathForRowAtPoint:point];
    
    if(lastSelectedListImage != nil){
        lastSelectedListImage.image = [UIImage imageNamed:@"gray_bg"];
    }
    UIImageView *listBgImage = (UIImageView *)[[btn superview] viewWithTag:btn.tag + 100];
    listBgImage.image = [UIImage imageNamed:@"yellow_bg"];
    lastSelectedListImage = listBgImage;
    selectedRowNumber = indexPath.row;
    lastPressedBtn = nil;
    lastPressedLabel = nil;
    lastSelectedOverlay = nil;
    
    ListViewController *viewController = [[ListViewController alloc] init];
    viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
    NSDictionary *item;
    if (topicType == MOVIE_TOPIC) {        
        item = [movieTopsArray objectAtIndex:floor(indexPath.row * 2.0) + btn.tag - 3001];
    } else if(topicType == DRAMA_TOPIC){
        item = [tvTopsArray objectAtIndex:floor(indexPath.row * 2.0) + btn.tag - 3001];
    }
    NSString *topId = [NSString stringWithFormat:@"%@", [item objectForKey: @"id"]];
    viewController.topId = topId;
    viewController.listTitle = [item objectForKey: @"name"];
    [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:YES];
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        return TOP_IMAGE_HEIGHT;
    } else {
        return LIST_LOGO_HEIGHT + 10;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return 0;
    } else {
        return 64;
    }
}

- (void)initTopButtonImage
{
    [movieListBtn setBackgroundImage:[UIImage imageNamed:@"movie_list_selected"] forState:UIControlStateNormal];
    [movieListBtn setBackgroundImage:[UIImage imageNamed:@"movie_list_selected"] forState:UIControlStateHighlighted];
    [dramaListBtn setBackgroundImage:[UIImage imageNamed:@"drama_list"] forState:UIControlStateNormal];
    [dramaListBtn setBackgroundImage:[UIImage imageNamed:@"drama_list_selected"] forState:UIControlStateHighlighted];
    if (topicType == MOVIE_TOPIC) {
        [movieListBtn setBackgroundImage:[UIImage imageNamed:@"movie_list_selected"] forState:UIControlStateNormal];
        [dramaListBtn setBackgroundImage:[UIImage imageNamed:@"drama_list"] forState:UIControlStateNormal];
    } else if(topicType == DRAMA_TOPIC){
        [movieListBtn setBackgroundImage:[UIImage imageNamed:@"movie_list"] forState:UIControlStateNormal];
        [dramaListBtn setBackgroundImage:[UIImage imageNamed:@"drama_list_selected"] forState:UIControlStateNormal];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (customHeaderView) {
        return customHeaderView;
    } else {
        customHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width, 64)];
        UIImageView *bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, customHeaderView.frame.size.width, customHeaderView.frame.size.height)];
        bgImageView.center = CGPointMake(customHeaderView.center.x - 8, customHeaderView.center.y);
        bgImageView.image = [UIImage imageNamed:@"popular_header_bg"];
        [customHeaderView addSubview:bgImageView];
        
        movieListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        movieListBtn.frame = CGRectMake(20, 6, VIDEO_BUTTON_WIDTH, VIDEO_BUTTON_HEIGHT);
        movieListBtn.tag = 1001;
        [movieListBtn addTarget:self action:@selector(movieListBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [customHeaderView addSubview:movieListBtn];
        
        dramaListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        dramaListBtn.frame = CGRectMake(250, 6, VIDEO_BUTTON_WIDTH, VIDEO_BUTTON_HEIGHT);
        dramaListBtn.tag = 1001;
        [dramaListBtn addTarget:self action:@selector(dramaListBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [customHeaderView addSubview:dramaListBtn];
        [self initTopButtonImage];
        return customHeaderView;
    }
}



#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


@end
