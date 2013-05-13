//
//  PageManageViewController.m
//  yueshipin
//
//  Created by 08 on 12-12-25.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "PageManageViewController.h"
#import "SortedViewCell.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "UIImageView+WebCache.h"
#import "ListDetailViewController.h"
#import "ShowListViewCell.h"
#import "IphoneShowDetailViewController.h"
#import "CacheUtility.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "SearchPreViewController.h"
#import "IphoneSettingViewController.h"
#import "UIImage+Scale.h"
#import "CommonMotheds.h"
#import "UnbundingViewController.h"
#import "ContainerUtility.h"
#import "IntroductionView.h"
#import "DatabaseManager.h"
#define PAGE_NUM 4
#define TV_TYPE 9000
#define MOVIE_TYPE 9001
#define SHOW_TYPE 9002
#define COMIC_TYPE  (9003)
#define PAGESIZE 10
#define TOP_SEGMENT_VIEW_TAG    (123456)
enum
{
    TYPE_BUNDING_TV = 1,
    TYPE_UNBUNDING
};

@interface PageManageViewController ()
- (void)setViewType:(NSInteger)type;
@end

@implementation PageManageViewController
@synthesize movieTableList = movieTableList_;
@synthesize tvTableList = tvTableList_;
@synthesize showTableList = showTableList_;
@synthesize scrollView = scrollView_;
@synthesize pageControl = pageControl_;
@synthesize tvListArr = tvListArr_;
@synthesize movieListArr = movieListArr_;
@synthesize showListArr = showListArr_;
@synthesize movieBtn = movieBtn_;
@synthesize tvBtn = tvBtn_;
@synthesize showBtn = showBtn_;
@synthesize slider = slider_;
@synthesize pageMGIcon = pageMGIcon_;
@synthesize refreshHeaderViewForMovieList = refreshHeaderViewForMovieList_;
@synthesize refreshHeaderViewForShowList = refreshHeaderViewForShowList_;
@synthesize refreshHeaderViewForTvList = refreshHeaderViewForTvList_;
@synthesize showTopId = showTopId_;
@synthesize pullToRefreshManager = pullToRefreshManager_;
@synthesize refreshHeaderViewForComicList = refreshHeaderViewForComicList_;
@synthesize comicTableList = comicTableList_;
@synthesize comicListArr = comicListArr_;
@synthesize comicBtn = comicBtn_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dataBaseChanged{
    MBProgressHUD *tempHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:tempHUD];
    tempHUD.labelText = @"缓存数据迁移中...";
    tempHUD.opacity = 0.5;
    [tempHUD show:YES];
    
    @try {
        [DatabaseManager transferFinishedDownloadFiles];//iphone 数据库迁移；
    }
    @catch (NSException *exception) {
        NSLog(@"DatabaseManager error:%@",exception.description);
    }
    [tempHUD hide:YES];
}

-(void)loadTVTopsData{

    MBProgressHUD *tempHUD;
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:@"tv_top_list"];
    if(cacheResult != nil){
        self.tvListArr = [[NSMutableArray alloc]initWithCapacity:PAGESIZE];
        NSString *responseCode = [cacheResult objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *tempTopsArray = [cacheResult objectForKey:@"tops"];
            if(tempTopsArray.count > 0){

                [ self.tvListArr addObjectsFromArray:tempTopsArray];
            }
        }
                
        [self.tvTableList reloadData];
    }
    else {
        if(tempHUD == nil){
            tempHUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.tvTableList reloadData];
            [self.view addSubview:tempHUD];
            tempHUD.labelText = @"加载中...";
            tempHUD.opacity = 0.5;
            [tempHUD show:YES];
        }
        
        
    }

    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%d",tvLoadCount_], @"page_num", [NSNumber numberWithInt:PAGESIZE], @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathTvTops parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        self.tvListArr = [[NSMutableArray alloc]initWithCapacity:PAGESIZE];
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *tempTopsArray = [result objectForKey:@"tops"];
            if(tempTopsArray.count > 0){
               [[CacheUtility sharedCache] putInCache:@"tv_top_list" result:result];
                [ self.tvListArr addObjectsFromArray:tempTopsArray];
            }
        }
        else {
            
        }
        
       [self loadTable:TV_TYPE];
        [tempHUD hide:YES];
        
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        if(self.tvListArr == nil){
            self.tvListArr = [[NSMutableArray alloc]initWithCapacity:10];
        }
        [tempHUD hide:YES];
        [CommonMotheds showInternetError:error inView:self.view];
    }];
    
    }

-(void)loadMovieTopsData{
     
    MBProgressHUD *tempHUD;
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:@"movie_top_list"];
    if(cacheResult != nil){
        self.movieListArr = [[NSMutableArray alloc]initWithCapacity:PAGESIZE];
        NSString *responseCode = [cacheResult objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *tempTopsArray = [cacheResult objectForKey:@"tops"];
            if(tempTopsArray.count > 0){
                
                [ self.movieListArr addObjectsFromArray:tempTopsArray];
            }
        }
        
        [self.movieTableList reloadData];
    }
    else {
        if(tempHUD == nil){
            tempHUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.movieTableList reloadData];
            [self.view addSubview:tempHUD];
            tempHUD.labelText = @"加载中...";
            tempHUD.opacity = 0.5;
            [tempHUD show:YES];
        } 
    }

    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%d",movieLoadCount_], @"page_num", [NSNumber numberWithInt:PAGESIZE], @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathMoiveTops parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        self.movieListArr = [[NSMutableArray alloc]initWithCapacity:PAGESIZE];
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *tempTopsArray = [result objectForKey:@"tops"];
            if(tempTopsArray.count > 0){
                [[CacheUtility sharedCache] putInCache:@"movie_top_list" result:result];
                [ self.movieListArr addObjectsFromArray:tempTopsArray];
            }
        }
        else {
            
        }
        [self loadTable:MOVIE_TYPE];
         [tempHUD hide:YES];
        
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        if(self.movieListArr == nil){
            self.movieListArr = [[NSMutableArray alloc]initWithCapacity:10];
        }
         [tempHUD hide:YES];
        [CommonMotheds showInternetError:error inView:self.view];
    }];
        
}

-(void)loadShowTopsData{
    MBProgressHUD *tempHUD;
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:@"show_top_list"];
    if(cacheResult != nil){
        self.showListArr = [[NSMutableArray alloc]initWithCapacity:PAGESIZE];
        NSString *responseCode = [cacheResult objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *tempTopsArray = [cacheResult objectForKey:@"tops"];
            if(tempTopsArray.count > 0){
                NSArray *tempArray = [[tempTopsArray objectAtIndex:0] objectForKey:@"items"];
                [ self.showListArr addObjectsFromArray:tempArray];
            }
        }
        
        [showTableList_ reloadData];
    }
    else {
        if(tempHUD == nil){
            tempHUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:tempHUD];
            tempHUD.labelText = @"加载中...";
            tempHUD.opacity = 0.5;
            [tempHUD show:YES];
        }
    }
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"page_num", [NSNumber numberWithInt:PAGESIZE], @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathShowTops parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        self.showListArr = [[NSMutableArray alloc]initWithCapacity:PAGESIZE];
        NSString *responseCode = [result objectForKey:@"res_code"];
        
        if(responseCode == nil){
            NSArray *tempTopsArray = [result objectForKey:@"tops"];
            
            if(tempTopsArray.count > 0){
                [[CacheUtility sharedCache] putInCache:@"show_top_list" result:result];
                NSArray *tempArray = [[tempTopsArray objectAtIndex:0] objectForKey:@"items"];
                showTopId_ = [[tempTopsArray objectAtIndex:0] objectForKey:@"id"];
                
                if(tempArray.count > 0) {
                    [self.showListArr addObjectsFromArray:tempArray];
                }
            }
        }
        
        [self loadTable:SHOW_TYPE];
        [tempHUD hide:YES];
        
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        if(self.showListArr == nil){
            self.showListArr = [[NSMutableArray alloc]initWithCapacity:10];
        }
        [self loadTable:SHOW_TYPE];
        [tempHUD hide:YES];
        [CommonMotheds showInternetError:error inView:self.view];
    }];
    
    
}

-(void)loadMoreShowTopsData{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:showTopId_,@"top_id",[NSNumber numberWithInt:showLoadCount_], @"page_num", [NSNumber numberWithInt:PAGESIZE], @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:@"/joyplus-service/index.php/show_top_items" parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        
        if(responseCode == nil){
            NSArray *tempTopsArray = [result objectForKey:@"items"];
            if(tempTopsArray.count > 0){
                [self.showListArr addObjectsFromArray:tempTopsArray];

            }
            
            if(tempTopsArray.count < PAGESIZE){
                [pullToRefreshManager_ setPullToRefreshViewVisible:NO];
            }
        }
        
        [self loadTable:SHOW_TYPE];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [self loadTable:SHOW_TYPE];
        
    }];
    
    
}

-(void)loadComicTopsData
{
    MBProgressHUD *tempHUD;
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:@"comic_top_list"];
    if(cacheResult != nil){
        self.comicListArr = [[NSMutableArray alloc]initWithCapacity:PAGESIZE];
        NSString *responseCode = [cacheResult objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *tempTopsArray = [cacheResult objectForKey:@"tops"];
            if(tempTopsArray.count > 0){
                
                [ self.comicListArr addObjectsFromArray:tempTopsArray];
            }
        }
        [self.comicTableList reloadData];
    }
    else {
        if(tempHUD == nil){
            tempHUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.comicTableList reloadData];
            [self.view addSubview:tempHUD];
            tempHUD.labelText = @"加载中...";
            tempHUD.opacity = 0.5;
            [tempHUD show:YES];
        }
        
        
    }
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%d",comicLoadCount_], @"page_num", [NSNumber numberWithInt:PAGESIZE], @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathComicTops parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        self.comicListArr = [[NSMutableArray alloc]initWithCapacity:PAGESIZE];
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *tempTopsArray = [result objectForKey:@"tops"];
            if(tempTopsArray.count > 0){
                [[CacheUtility sharedCache] putInCache:@"comic_top_list" result:result];
                [ self.comicListArr addObjectsFromArray:tempTopsArray];
            }
        }
        else {
            
        }
        
        [self loadTable:COMIC_TYPE];
        [tempHUD hide:YES];
        
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        if(self.comicListArr == nil){
            self.comicListArr = [[NSMutableArray alloc]initWithCapacity:10];
        }
        [tempHUD hide:YES];
    }];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self dataBaseChanged];
    
//    UILabel *titleText = [[UILabel alloc] initWithFrame: CGRectMake(90, 0, 40, 40)];
//    titleText.backgroundColor = [UIColor clearColor];
//    titleText.textColor=[UIColor whiteColor];
//    [titleText setFont:[UIFont boldSystemFontOfSize:18.0]];
//    [titleText setText:@"悦榜"];
//    self.navigationItem.titleView=titleText;
    self.title = @"悦榜";
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, 55, 44);
    leftButton.backgroundColor = [UIColor clearColor];
    [leftButton setImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage imageNamed:@"search_f.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton addTarget:self action:@selector(setting:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(0, 0, 55, 44);
    rightButton.backgroundColor = [UIColor clearColor];
    [rightButton setImage:[UIImage imageNamed:@"scan_btn.png"] forState:UIControlStateNormal];
    [rightButton setImage:[UIImage imageNamed:@"scan_btn_f.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    [super viewDidLoad];
    UIImageView *backGround = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_common.png"]];
    backGround.frame = CGRectMake(0, 0, 320, kFullWindowHeight);
    [self.view addSubview:backGround];
	// Do any additional setup after loading the view.
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 37, 320, kCurrentWindowHeight-88-37)];
    self.scrollView.contentSize = CGSizeMake(320*PAGE_NUM, kCurrentWindowHeight-88-30);
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    self.scrollView.bounces = NO;
    self.scrollView.tag = 1127;

    UIImageView *scrBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab2_10_bg.png"]];
    scrBg.userInteractionEnabled = YES;
    scrBg.frame = CGRectMake(0, 0, 320, 37);
    scrBg.tag = TOP_SEGMENT_VIEW_TAG;
    movieBtn_ = [UIButton buttonWithType:UIButtonTypeCustom];
    [movieBtn_ setImage:[UIImage imageNamed:@"List_movie.png"] forState:UIControlStateNormal];
    [movieBtn_ setImage:[UIImage imageNamed:@"List_movie.png"] forState:UIControlStateHighlighted];
    [movieBtn_ setImage:[UIImage imageNamed:@"List_movie_pressed.png"] forState:UIControlStateHighlighted | UIControlStateSelected];
    [movieBtn_ setImage:[UIImage imageNamed:@"List_movie_pressed.png"] forState:UIControlStateSelected];
    movieBtn_.frame = CGRectMake(0, 7, 80, 30);
    movieBtn_.tag = 0;
    [movieBtn_ addTarget:self action:@selector(buttonChange:) forControlEvents:UIControlEventTouchUpInside];
     movieBtn_.backgroundColor = [UIColor clearColor];
     movieBtn_.adjustsImageWhenHighlighted = NO;
    movieBtn_.selected = YES;
    [movieBtn_ setImageEdgeInsets:UIEdgeInsetsMake(5, 10, 5, 10)];
    
    tvBtn_ = [UIButton buttonWithType:UIButtonTypeCustom];
    [tvBtn_ setImage:[UIImage imageNamed:@"List_series.png"] forState:UIControlStateNormal];
    [tvBtn_ setImage:[UIImage imageNamed:@"List_series.png"] forState:UIControlStateHighlighted];
    [tvBtn_ setImage:[UIImage imageNamed:@"List_series_pressed.png"] forState:UIControlStateHighlighted | UIControlStateSelected];
    [tvBtn_ setImage:[UIImage imageNamed:@"List_series_pressed.png"] forState:UIControlStateSelected];
    tvBtn_.frame = CGRectMake(80, 7, 80, 30);
    tvBtn_.tag = 1;
    [tvBtn_ addTarget:self action:@selector(buttonChange:) forControlEvents:UIControlEventTouchUpInside];
    tvBtn_.backgroundColor = [UIColor clearColor];
    tvBtn_.adjustsImageWhenHighlighted = NO;
    [tvBtn_ setImageEdgeInsets:UIEdgeInsetsMake(5, 10, 5, 10)];
    
    comicBtn_ = [UIButton buttonWithType:UIButtonTypeCustom];
    [comicBtn_ setImage:[UIImage imageNamed:@"List_comic.png"] forState:UIControlStateNormal];
    [comicBtn_ setImage:[UIImage imageNamed:@"List_comic.png"] forState:UIControlStateHighlighted];
    [comicBtn_ setImage:[UIImage imageNamed:@"List_comic_pressed.png"] forState:UIControlStateHighlighted | UIControlStateSelected];
    [comicBtn_ setImage:[UIImage imageNamed:@"List_comic_pressed.png"] forState:UIControlStateSelected];
    comicBtn_.frame = CGRectMake(160, 7, 80, 30);
    comicBtn_.tag = 2;
    [comicBtn_ addTarget:self action:@selector(buttonChange:) forControlEvents:UIControlEventTouchUpInside];
    comicBtn_.backgroundColor = [UIColor clearColor];
    comicBtn_.adjustsImageWhenHighlighted = NO;
    [comicBtn_ setImageEdgeInsets:UIEdgeInsetsMake(5, 10, 5, 10)];
    
    showBtn_ = [UIButton buttonWithType:UIButtonTypeCustom];
    [showBtn_ setImage:[UIImage imageNamed:@"List_show.png"] forState:UIControlStateNormal];
    [showBtn_ setImage:[UIImage imageNamed:@"List_show.png"] forState:UIControlStateHighlighted];
    [showBtn_ setImage:[UIImage imageNamed:@"List_show_pressed.png"] forState:UIControlStateHighlighted | UIControlStateSelected];
    [showBtn_ setImage:[UIImage imageNamed:@"List_show_pressed.png"] forState:UIControlStateSelected];
    showBtn_.frame = CGRectMake(240, 7, 80, 30);
    showBtn_.tag = 3;
    [showBtn_ addTarget:self action:@selector(buttonChange:) forControlEvents:UIControlEventTouchUpInside];
    showBtn_.backgroundColor = [UIColor clearColor];
    showBtn_.adjustsImageWhenHighlighted = NO;
    [showBtn_ setImageEdgeInsets:UIEdgeInsetsMake(5, 10, 5, 10)];
    
    //
    
    slider_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab2_10_s.png"]];
    slider_.frame = CGRectMake(10, 35, 60, 2);
    
    pageMGIcon_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab2_10_s_icon.png"]];
    pageMGIcon_.frame = CGRectMake(8, 3, 15, 24);
    [scrBg addSubview:movieBtn_];
    [scrBg addSubview:tvBtn_];
    [scrBg addSubview:showBtn_];
    [scrBg addSubview:comicBtn_];
    //[scrBg addSubview:pageMGIcon_];
    [scrBg addSubview:slider_];
    scrBg.backgroundColor = [UIColor clearColor];
    [self.view addSubview:scrBg];
    
    self.tvTableList = [[UITableView alloc] initWithFrame:CGRectMake(320, 0,320 , kCurrentWindowHeight-122) style:UITableViewStylePlain];
    self.tvTableList.backgroundColor = [UIColor clearColor];
    self.tvTableList.dataSource = self;
    self.tvTableList.delegate = self;
    self.tvTableList.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tvTableList.tag = TV_TYPE;
    [self.scrollView addSubview:self.tvTableList];
    
    self.movieTableList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,320 , kCurrentWindowHeight-122) style:UITableViewStylePlain];
    self.movieTableList.backgroundColor = [UIColor clearColor];
    self.movieTableList.dataSource = self;
    self.movieTableList.delegate = self;
    self.movieTableList.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.movieTableList.tag = MOVIE_TYPE;
    [self.scrollView addSubview:self.movieTableList];
    
    self.showTableList = [[UITableView alloc] initWithFrame:CGRectMake(960, 0,320 , kCurrentWindowHeight-122) style:UITableViewStylePlain];
    self.showTableList.backgroundColor = [UIColor clearColor];
    self.showTableList.dataSource = self;
    self.showTableList.delegate = self;
    self.showTableList.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.showTableList.tag = SHOW_TYPE;
    [self.scrollView addSubview:self.showTableList];
    
    self.comicTableList = [[UITableView alloc] initWithFrame:CGRectMake(640, 0,320 , kCurrentWindowHeight-122) style:UITableViewStylePlain];
    self.comicTableList.backgroundColor = [UIColor clearColor];
    self.comicTableList.dataSource = self;
    self.comicTableList.delegate = self;
    self.comicTableList.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.comicTableList.tag = COMIC_TYPE;
    [self.scrollView addSubview:self.comicTableList];
    
    [self.view addSubview:self.scrollView];
    
    //添加上，下拉刷新控件
    
    if (refreshHeaderViewForMovieList_ == nil) {
        refreshHeaderViewForMovieList_ = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - movieTableList_.bounds.size.height, self.view.frame.size.width, movieTableList_.bounds.size.height)];
        refreshHeaderViewForMovieList_.backgroundColor = [UIColor clearColor];
        refreshHeaderViewForMovieList_.delegate = self;
        [movieTableList_ addSubview:refreshHeaderViewForMovieList_];
        //[refreshHeaderViewForMovieList_ refreshLastUpdatedDate];
        movieLoadCount_ = 1;
    }

    if (refreshHeaderViewForTvList_ == nil) {
        refreshHeaderViewForTvList_ = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - tvTableList_.bounds.size.height, self.view.frame.size.width, tvTableList_.bounds.size.height)];
        refreshHeaderViewForTvList_.backgroundColor = [UIColor clearColor];
        refreshHeaderViewForTvList_.delegate = self;
        [tvTableList_ addSubview:refreshHeaderViewForTvList_];
        //[refreshHeaderViewForTvList_ refreshLastUpdatedDate];
        tvLoadCount_ = 1;
    }

    if (refreshHeaderViewForShowList_ == nil) {
        refreshHeaderViewForShowList_ = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0.0f -showTableList_.bounds.size.height, self.view.frame.size.width, showTableList_.bounds.size.height)];
        refreshHeaderViewForShowList_.backgroundColor = [UIColor clearColor];
        refreshHeaderViewForShowList_.delegate = self;
        [showTableList_ addSubview:refreshHeaderViewForShowList_];
        //[refreshHeaderViewForShowList_ refreshLastUpdatedDate];
        showLoadCount_ = 1;
    }
    
    if (nil == refreshHeaderViewForComicList_)
    {
        refreshHeaderViewForComicList_ = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0.0f -showTableList_.bounds.size.height, self.view.frame.size.width, showTableList_.bounds.size.height)];
        refreshHeaderViewForComicList_.backgroundColor = [UIColor clearColor];
        refreshHeaderViewForComicList_.delegate = self;
        [comicTableList_ addSubview:refreshHeaderViewForComicList_];
        //[refreshHeaderViewForComicList_ refreshLastUpdatedDate];
        comicLoadCount_ = 1;
    }
    
    pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:480 tableView:showTableList_ withClient:self];
    
    if (nil == bundingTipsView)
    {
        bundingTipsView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bunding_tv.png"]highlightedImage:[UIImage imageNamed:@"bunding_tv_s.png"]];
        bundingTipsView.frame = CGRectMake(0, 0, 320, 34);
        [self.view addSubview:bundingTipsView];
        bundingTipsView.backgroundColor = [UIColor clearColor];
        
        bundingTipsView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                                    action:@selector(TopImageTaped)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.numberOfTouchesRequired = 1;
        [bundingTipsView addGestureRecognizer:tapGesture];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(managerTVBunding)
                                                 name:@"bundingTVSucceeded"
                                               object:nil];
    
    
    //新手引导
    if ([CommonMotheds isFirstTimeRun]) {
        [self showIntroductionView];
    }
    if ([CommonMotheds isVersionUpdate]) {
        [self showIntroductionView];
    }
}


-(void)showIntroductionView{
    CGSize size = [UIApplication sharedApplication].delegate.window.bounds.size;
    IntroductionView *inView = [[IntroductionView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    [inView show];
}
-(void)viewWillAppear:(BOOL)animated{
    [CommonMotheds showNetworkDisAbledAlert:self.view];
    if (0 == self.movieListArr.count)
    {
        [self loadMovieTopsData];
    }
    if (0 == self.tvListArr.count)
    {
        [self loadTVTopsData];
    }
    if (0 == self.showListArr.count)
    {
        [self loadShowTopsData];
    }
    if (0 == self.comicListArr.count)
    {
        [self loadComicTopsData];
    }
    
    [self managerTVBunding];
    
}
- (void)viewDidUnload{
    [super viewDidUnload];
    self.tvListArr = nil;
    self.movieListArr = nil;;
    self.showListArr = nil;
    self.comicTableList = nil;
    self.comicListArr = nil;
    self.tvTableList = nil;
    self.movieTableList = nil;
    self.showTableList = nil;
    self.refreshHeaderViewForMovieList = nil;
    self.refreshHeaderViewForTvList = nil;
    self.refreshHeaderViewForShowList = nil;
    self.refreshHeaderViewForComicList = nil;
}
-(void)buttonChange:(UIButton *)btn{
    int page = btn.tag;
    
    if (btn.selected)
    {
        return;
    }
    
    movieBtn_ == btn ? (movieBtn_.selected = YES) : (movieBtn_.selected = NO);
    tvBtn_ == btn ? (tvBtn_.selected = YES) : (tvBtn_.selected = NO);
    showBtn_ == btn ? (showBtn_.selected = YES) : (showBtn_.selected = NO);
    comicBtn_ == btn ? (comicBtn_.selected = YES) : (comicBtn_.selected = NO);
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.1f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    slider_.frame = CGRectMake(page*80 + 10, 35, 60, 2);
    [UIView commitAnimations];
    [self.scrollView setContentOffset:CGPointMake(320.0f * page, 0.0f) animated:YES];

}
-(void)search:(id)sender{
    SearchPreViewController *searchViewCotroller = [[SearchPreViewController alloc] init];
    searchViewCotroller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchViewCotroller animated:YES];
    
}

-(void)setting:(id)sender
{
    UIImageView * scanView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"scan_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 0, 342.5, 0)]];
    scanView.frame = CGRectMake(0, 0, 320, (kCurrentWindowHeight - 44));
    scanView.backgroundColor = [UIColor clearColor];
    
    DimensionalCodeScanViewController * reader = [DimensionalCodeScanViewController new];
    reader.supportedOrientationsMask = ZBarOrientationMask(UIInterfaceOrientationPortrait);
    reader.showsZBarControls = NO;
    reader.showsHelpOnFail = NO;
    reader.showsCameraControls = NO;
    reader.cameraOverlayView = scanView;
    ZBarImageScanner *scanner = reader.scanner;
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    reader.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:reader
                                         animated:YES];
}

- (void)managerTVBunding
{
    NSString *userId = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:@"kUserId"];
    NSDictionary * data = (NSDictionary *)[[ContainerUtility sharedInstance] attributeForKey:[NSString stringWithFormat:@"%@_isBunding",userId]];
    NSNumber *isbunding = [data objectForKey:KEY_IS_BUNDING];
    if (![isbunding boolValue] || nil == isbunding)
    {
        [self setViewType:TYPE_UNBUNDING];
    }
    else
    {
        [self setViewType:TYPE_BUNDING_TV];
    }
}

- (void)TopImageTaped
{
    UnbundingViewController *ubCtrl = [[UnbundingViewController alloc] init];
    [self.navigationController pushViewController:ubCtrl animated:YES];
}

- (void)setViewType:(NSInteger)type
{
    /*
     self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 30, 320, kCurrentWindowHeight-88-30)];
     self.scrollView.contentSize = CGSizeMake(320*PAGE_NUM, kCurrentWindowHeight-88-30);
     */
    
    UIImageView * topView = (UIImageView *)[self.view viewWithTag:TOP_SEGMENT_VIEW_TAG];
    
    CGRect scrollRect = scrollView_.frame;
    CGRect topRect = topView.frame;
    
    CGRect movieRect = movieTableList_.frame;
    CGRect tvRect = tvTableList_.frame;
    CGRect showRect = showTableList_.frame;
    CGRect comicRect = comicTableList_.frame;
    
    if (TYPE_BUNDING_TV == type)
    {
        bundingTipsView.hidden = NO;
        
        scrollRect.origin.y = 71;
        scrollRect.size.height = kCurrentWindowHeight - 125 - 34;
        scrollView_.contentSize = CGSizeMake(320*PAGE_NUM, kCurrentWindowHeight - 125 - 34);
        topRect.origin.y = 34;
        
        movieRect.size.height = (kCurrentWindowHeight - 130 - 34);
        tvRect.size.height = (kCurrentWindowHeight - 130 - 34);
        showRect.size.height = (kCurrentWindowHeight - 130 - 34);
        comicRect.size.height = (kCurrentWindowHeight - 130 - 34);
        
    }
    else if (TYPE_UNBUNDING == type)
    {
        bundingTipsView.hidden = YES;
        
        scrollRect.origin.y = 37;
        scrollRect.size.height = kCurrentWindowHeight - 125;
        scrollView_.contentSize = CGSizeMake(320*PAGE_NUM, kCurrentWindowHeight - 125);
        topRect.origin.y = 0;
        
        movieRect.size.height = (kCurrentWindowHeight - 130);
        tvRect.size.height = (kCurrentWindowHeight - 130);
        showRect.size.height = (kCurrentWindowHeight - 130);
        comicRect.size.height = (kCurrentWindowHeight - 130);
    }
    
    topView.frame = topRect;
    scrollView_.frame = scrollRect;
    movieTableList_.frame = movieRect;
    tvTableList_.frame = tvRect;
    showTableList_.frame = showRect;
    comicTableList_.frame = comicRect;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag == TV_TYPE) {
        return [tvListArr_ count];
    }
    else if(tableView.tag == MOVIE_TYPE){
        return [movieListArr_ count];
    }
    else if(tableView.tag == SHOW_TYPE){
        return [showListArr_ count];
    }
    else if (COMIC_TYPE == tableView.tag)
    {
        return comicListArr_.count;
    }
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    switch (tableView.tag) {
        case TV_TYPE:{
            SortedViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[SortedViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            NSDictionary *item = [self.tvListArr objectAtIndex:indexPath.row];
            NSMutableArray *items = [item objectForKey:@"items"];
            for (int i = 0; i< [items count];i++) {
                switch (i) {
                    case 0:
                        cell.labelOne.text = [[items objectAtIndex:0] objectForKey:@"prod_name" ];
                        break;
                    case 1:
                        cell.labelTwo.text = [[items objectAtIndex:1] objectForKey:@"prod_name" ];
                        break;
                    case 2:
                        cell.labelThree.text = [[items objectAtIndex:2] objectForKey:@"prod_name" ];
                        break;
                    default:
                        break;
                }
            }
            cell.title.text = [item objectForKey:@"name"];
            [cell.imageview setImageWithURL:[NSURL URLWithString:[item objectForKey:@"pic_url"]] /*placeholderImage:[UIImage imageNamed:@"video_placeholder"]*/];
            return cell;
        }
        case MOVIE_TYPE:{
            SortedViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[SortedViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            NSDictionary *item = [self.movieListArr objectAtIndex:indexPath.row];
            NSMutableArray *items = [item objectForKey:@"items"];
            for (int i = 0; i< [items count];i++) {
                switch (i) {
                    case 0:
                        cell.labelOne.text = [[items objectAtIndex:0] objectForKey:@"prod_name" ];
                        break;
                    case 1:
                        cell.labelTwo.text = [[items objectAtIndex:1] objectForKey:@"prod_name" ];
                        break;
                    case 2:
                        cell.labelThree.text = [[items objectAtIndex:2] objectForKey:@"prod_name" ];
                        break;
                    default:
                        break;
                }
            }

            cell.title.text = [item objectForKey:@"name"];
            [cell.imageview setImageWithURL:[NSURL URLWithString:[item objectForKey:@"pic_url"]] /*placeholderImage:[UIImage imageNamed:@"video_placeholder"]*/];
            return cell;
        }
        case SHOW_TYPE:{
            ShowListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[ShowListViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            NSDictionary *item = [self.showListArr objectAtIndex:indexPath.row];
            cell.nameLabel.text = [item objectForKey:@"prod_name"];
            cell.latest.text = [NSString stringWithFormat:@"更新至：%@",[item objectForKey:@"cur_item_name"]];
           [cell.imageView setImageWithURL:[NSURL URLWithString:[item objectForKey:@"prod_pic_url"]] placeholderImage:[UIImage imageNamed:@"picture_bg.png"]];
        
            return cell;
        }
        case COMIC_TYPE:{
            SortedViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[SortedViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            NSDictionary *item = [self.comicListArr objectAtIndex:indexPath.row];
            NSMutableArray *items = [item objectForKey:@"items"];
            for (int i = 0; i< [items count];i++) {
                switch (i) {
                    case 0:
                        cell.labelOne.text = [[items objectAtIndex:0] objectForKey:@"prod_name" ];
                        break;
                    case 1:
                        cell.labelTwo.text = [[items objectAtIndex:1] objectForKey:@"prod_name" ];
                        break;
                    case 2:
                        cell.labelThree.text = [[items objectAtIndex:2] objectForKey:@"prod_name" ];
                        break;
                    default:
                        break;
                }
            }
            cell.title.text = [item objectForKey:@"name"];
            [cell.imageview setImageWithURL:[NSURL URLWithString:[item objectForKey:@"pic_url"]] /*placeholderImage:[UIImage imageNamed:@"video_placeholder"]*/];
            return cell;
        }
        default:
            break;
    }
    
    return nil;    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == SHOW_TYPE){
        return 94;
    }
    else{
      return 130;
    }
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [CommonMotheds showNetworkDisAbledAlert:self.view];
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
    int tableViewTag = tableView.tag;
    if (tableViewTag == TV_TYPE) {
        NSDictionary *item = [self.tvListArr objectAtIndex:indexPath.row];
        ListDetailViewController *listDetailViewController = [[ListDetailViewController alloc] initWithStyle:UITableViewStylePlain];
        listDetailViewController.title = [item objectForKey:@"name"];
        listDetailViewController.topicId = [item objectForKey:@"id"];
        listDetailViewController.Type = TV_TYPE;
        listDetailViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:listDetailViewController animated:YES];
    }
    else if (tableViewTag == MOVIE_TYPE){
        NSDictionary *item = [self.movieListArr objectAtIndex:indexPath.row];
        ListDetailViewController *listDetailViewController = [[ListDetailViewController alloc] initWithStyle:UITableViewStylePlain];
        listDetailViewController.title = [item objectForKey:@"name"];
        listDetailViewController.topicId = [item objectForKey:@"id"];
        listDetailViewController.hidesBottomBarWhenPushed = YES;
        listDetailViewController.Type = MOVIE_TYPE;
        [self.navigationController pushViewController:listDetailViewController animated:YES];
    }
    else if (tableViewTag == SHOW_TYPE){
        NSDictionary *item = [self.showListArr objectAtIndex:indexPath.row];
        IphoneShowDetailViewController *detailViewController = [[IphoneShowDetailViewController alloc] initWithStyle:UITableViewStylePlain];
        detailViewController.infoDic = item;
        detailViewController.videoType = SHOW_TYPE;
        detailViewController.title = [item objectForKey:@"prod_name"];
         detailViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detailViewController animated:YES];
    
    }
    else if (COMIC_TYPE == tableViewTag)
    {
        NSDictionary *item = [self.comicListArr objectAtIndex:indexPath.row];
        ListDetailViewController *listDetailViewController = [[ListDetailViewController alloc] initWithStyle:UITableViewStylePlain];
        listDetailViewController.title = [item objectForKey:@"name"];
        listDetailViewController.topicId = [item objectForKey:@"id"];
        listDetailViewController.hidesBottomBarWhenPushed = YES;
        listDetailViewController.Type = MOVIE_TYPE;
        [self.navigationController pushViewController:listDetailViewController animated:YES];
    }

}

#pragma mark -
#pragma mark ScrollViewDelegate Methods
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    switch (scrollView.tag){
        case 1127:{
            CGFloat pageWidth = self.view.frame.size.width;
            CGPoint offset = scrollView.contentOffset;
            
            int page = ceil(offset.x / pageWidth);
            if (page > 3) {
                page = 3;
            }
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.1f];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            slider_.frame = CGRectMake(page*80 + 10, 35, 60, 2);
            [UIView commitAnimations];
            
            movieBtn_.selected = NO;
            tvBtn_.selected = NO;
            showBtn_.selected = NO;
            comicBtn_.selected = NO;
            switch (page) {
                case 0:{
                    movieBtn_.selected = YES;
                    pageMGIcon_.frame = CGRectMake(8, 3, 15, 24);
                    break;
                }
                case 1:{
                    tvBtn_.selected = YES;
                    pageMGIcon_.frame = CGRectMake(88, 3, 15, 24);
                    break;
                }
                case 2:{
                    comicBtn_.selected = YES;
                    pageMGIcon_.frame = CGRectMake(168, 3, 15, 24);
                    break;
                }
                case 3:
                {
                    showBtn_.selected = YES;
                    pageMGIcon_.frame = CGRectMake(248, 3, 15, 24);
                    break;
                }
                default:
                    break;
                    
            }
        }
    }
}


- (void)scrollViewDidEndDragging:(UIScrollView *)aScrollView willDecelerate:(BOOL)decelerate {
  
    switch (aScrollView.tag) {
        case MOVIE_TYPE:{
            [refreshHeaderViewForMovieList_ egoRefreshScrollViewDidEndDragging:aScrollView];
            break;
        }
        case TV_TYPE:{
            [refreshHeaderViewForTvList_ egoRefreshScrollViewDidEndDragging:aScrollView];
            break;
        }
        case SHOW_TYPE:{
            [refreshHeaderViewForShowList_ egoRefreshScrollViewDidEndDragging:aScrollView];
            break;
        }
        case COMIC_TYPE:{
            [refreshHeaderViewForComicList_ egoRefreshScrollViewDidEndDragging:aScrollView];
            break;
        }
        
        default:
            break;
    }
    
    [pullToRefreshManager_ tableViewReleased];
    
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [CommonMotheds showNetworkDisAbledAlert:self.view];
    if (view == refreshHeaderViewForMovieList_) {
        [self loadMovieTopsData];
    }
    else if (view == refreshHeaderViewForTvList_){
        [self loadTVTopsData];
    }
    else if (view == refreshHeaderViewForShowList_){
        showLoadCount_ = 1;
        [self loadShowTopsData];
        [pullToRefreshManager_ setPullToRefreshViewVisible:YES];
    }
    else if (view == refreshHeaderViewForComicList_)
    {
        [self loadComicTopsData];
    }
    
    
	reloading_ = YES;
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1.0];

	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return reloading_; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	reloading_ = NO;
	[refreshHeaderViewForMovieList_ egoRefreshScrollViewDataSourceDidFinishedLoading:movieTableList_];
    [refreshHeaderViewForTvList_ egoRefreshScrollViewDataSourceDidFinishedLoading:tvTableList_];
    [refreshHeaderViewForShowList_ egoRefreshScrollViewDataSourceDidFinishedLoading:showTableList_];
	[refreshHeaderViewForComicList_ egoRefreshScrollViewDataSourceDidFinishedLoading:comicTableList_];
}


#pragma mark -
#pragma mark MNMBottomPullToRefreshManagerClientReloadTable Methods
- (void)MNMBottomPullToRefreshManagerClientReloadTable {
    [CommonMotheds showNetworkDisAbledAlert:self.view];
    showLoadCount_++;
    [self loadMoreShowTopsData];
    
}

- (void)loadTable:(int)type {
    
    if (type == MOVIE_TYPE) {
        [movieTableList_ reloadData];
    }
    else if (type == TV_TYPE){
        [tvTableList_ reloadData];
    }
    else if (type == SHOW_TYPE){
        [showTableList_ reloadData];
    }
    else if (COMIC_TYPE == type)
    {
        [comicTableList_ reloadData];
    }
    [pullToRefreshManager_ tableViewReloadFinished];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - dealloc
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"bundingTVSucceeded"
                                                  object:nil];
}
@end
