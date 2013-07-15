//
//  ChannelViewController.m
//  theatreiphone
//
//  Created by Rong on 13-5-13.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "ChannelViewController.h"
#import "SearchPreViewController.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "FiltrateCell.h"
#import "UIImageView+WebCache.h"
#import "TVDetailViewController.h"
#import "IphoneMovieDetailViewController.h"
#import "IphoneShowDetailViewController.h"
#import "CacheUtility.h"
#import "DimensionalCodeScanViewController.h"
#import "ContainerUtility.h"
#import "UnbundingViewController.h"
#import "UIUtility.h"
#import "IntroductionView.h"
#import "CommonMotheds.h"
#define BUNDING_HEIGHT 35
#define BUNDING_BUTTON_TAG 200001
extern NSComparator cmptr;
enum
{
    TYPE_BUNDING_TV = 1,
    TYPE_UNBUNDING
};
@implementation ChannelViewController
@synthesize titleButton = titleButton_;
@synthesize segV = _segV;
@synthesize videoTypeSeg = _videoTypeSeg;
@synthesize filtrateView = _filtrateView;
@synthesize tableList = _tableList;
@synthesize dataArr = _dataArr;
@synthesize parameters = _parameters;
@synthesize progressHUD = _progressHUD;
@synthesize pullRefreshManager = pullToRefreshManager_;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIImageView *backGround = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_common.png"]];
    backGround.frame = CGRectMake(0, 0, 320, kFullWindowHeight);
    [self.view addSubview:backGround];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, 55, 44);
    leftButton.backgroundColor = [UIColor clearColor];
    [leftButton setImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage imageNamed:@"search_f.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    self.navigationItem.hidesBackButton = YES;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton addTarget:self action:@selector(sort:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(0, 0, 55, 44);
    rightButton.backgroundColor = [UIColor clearColor];
    [rightButton setImage:[UIImage imageNamed:@"sort_iPhone.png"] forState:UIControlStateNormal];
    [rightButton setImage:[UIImage imageNamed:@"sort_iPhone_f.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    titleButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
    titleButton_.frame = CGRectMake(0, 0, 100, 60);
    titleButton_.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [titleButton_ setTitle:@"电影" forState:UIControlStateNormal];
    [titleButton_ setTitle:@"电影" forState:UIControlStateHighlighted];
    [titleButton_ setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [titleButton_ setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [titleButton_ setImage:[UIImage imageNamed:@"title_xiala"] forState:UIControlStateNormal];
    [titleButton_ setImage:[UIImage imageNamed:@"title_xiala"] forState:UIControlStateHighlighted];
    [titleButton_ setImage:[UIImage imageNamed:@"title_xiala"] forState:UIControlStateSelected];
    titleButton_.adjustsImageWhenHighlighted = NO;
    [titleButton_ setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 20)];
    [titleButton_ setImageEdgeInsets:UIEdgeInsetsMake(0, 65, 0, 0)];
    titleButton_.titleLabel.shadowOffset = CGSizeMake(0, 1);
    [titleButton_ setTitleShadowColor:[UIColor colorWithRed:121.0/255 green:64.0/255 blue:0 alpha:1]forState:UIControlStateNormal];
    [titleButton_ setTitleShadowColor:[UIColor colorWithRed:121.0/255 green:64.0/255 blue:0 alpha:1]forState:UIControlStateHighlighted];
    [titleButton_ setTitleShadowColor:[UIColor colorWithRed:121.0/255 green:64.0/255 blue:0 alpha:1]forState:UIControlStateSelected];
    [titleButton_ addTarget:self action:@selector(showSegmentControl:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = titleButton_;
    
    _segV = [[SegmentControlView alloc] initWithFrame:CGRectMake(0, 0, 320, 42)];
    _segV.delegate = self;
    [self.view addSubview:_segV];
    
    _videoTypeSeg = [[VideoTypeSegment alloc] initWithFrame:CGRectMake(0, 0, 320, 65)];
    _videoTypeSeg.delegate = self;
    [_videoTypeSeg dissmiss];
    [self.view addSubview: _videoTypeSeg];
    
    _filtrateView = [[FiltrateView alloc] initWithFrame:CGRectMake(0, 42, 320, 108)];
    _filtrateView.delegate = self;
    [_filtrateView dismissWithDuration:0];
    [self.view addSubview:_filtrateView];
    
    _tableList = [[UITableView alloc] initWithFrame:CGRectMake(0, 42, 320, kCurrentWindowHeight -44-42-48) style:UITableViewStylePlain];
    _tableList.dataSource = self;
    _tableList.delegate = self;
    _tableList.backgroundColor = [UIColor clearColor];
    _tableList.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableList];
    
    pullToRefreshManager_ = [[PullRefreshManagerClinet alloc] initWithTableView:_tableList];
    pullToRefreshManager_.delegate = self;
    
    _progressHUD  = [[MBProgressHUD alloc] initWithView:self.view];
    _progressHUD.labelText = @"加载中...";
    _progressHUD.opacity = 0.5;
    [self.view addSubview:_progressHUD];
     
    [self initDefaultParameters];
    
    
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
   [super viewWillAppear:animated];
   [self managerTVBunding];
    if (videoType_ == TYPE_MOVIE) {
        self.navigationItem.rightBarButtonItem.customView.hidden = NO;
    }
    else{
        self.navigationItem.rightBarButtonItem.customView.hidden = YES;
    }
}

-(void)initDefaultParameters{
    videoType_ = TYPE_MOVIE;
    _parameters = [NSMutableDictionary dictionaryWithCapacity:5];
    [_parameters setObject:@"1" forKey:@"page_num"];
    [_parameters setObject:[NSNumber numberWithInt:videoType_] forKey:@"type"];
    [_parameters setObject:[NSNumber numberWithInt:12] forKey:@"page_size"];
    [_parameters setObject:@"" forKey:@"sub_type"];
    [_parameters setObject:@"" forKey:@"area"];
    [_parameters setObject:@"" forKey:@"year"];
    [self sendHttpRequest:_parameters];
}
-(void)search:(id)sender{
    SearchPreViewController *searchViewCotroller = [[SearchPreViewController alloc] init];
    searchViewCotroller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchViewCotroller animated:YES];
}

-(void)sort:(UIButton *)btn
{
    btn.selected = !btn.selected;
    if (btn.selected) {
        [self showSortedSelctedView];
    }
    else{
        [self hiddenSortedSelectedView];
    }
    
}

-(void)showSortedSelctedView{
    UIImageView *bg = (UIImageView *)[self.view viewWithTag:19999];
    if (bg == nil) {
        bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iphoneSortBg"]];
        bg.frame = CGRectMake(210, 60, 102, 83);
        bg.tag = 19999;
        bg.userInteractionEnabled = YES;
        UIButton *sortByHot = [UIButton buttonWithType:UIButtonTypeCustom];
        sortByHot.frame = CGRectMake(4.5, 14, 93, 29);
        sortByHot.tag = 20001;
        [sortByHot addTarget:self action:@selector(sortTypePressed:) forControlEvents:UIControlEventTouchUpInside];
        [sortByHot setBackgroundImage:[UIImage imageNamed:@"sortByHot_iPhone"] forState:UIControlStateNormal];
        [sortByHot setBackgroundImage:[UIImage imageNamed:@"sortByHot_iPhone_s"] forState:UIControlStateHighlighted];
        [sortByHot setBackgroundImage:[UIImage imageNamed:@"sortByHot_iPhone_s"] forState:UIControlStateSelected];
        [bg addSubview:sortByHot];
        
        UIButton *sortByScore = [UIButton buttonWithType:UIButtonTypeCustom];
        sortByScore.frame =  CGRectMake(4.5, 52, 93, 29);
        sortByScore.tag = 20002;
        [sortByScore addTarget:self action:@selector(sortTypePressed:) forControlEvents:UIControlEventTouchUpInside];
        [sortByScore setBackgroundImage:[UIImage imageNamed:@"sortByScore_iphone"] forState:UIControlStateNormal];
        [sortByScore setBackgroundImage:[UIImage imageNamed:@"sortByScore_iphone_s"] forState:UIControlStateHighlighted];
        [sortByScore setBackgroundImage:[UIImage imageNamed:@"sortByScore_iphone_s"] forState:UIControlStateSelected];
        [bg addSubview:sortByScore];
        
        if (!sortedByScore_) {
            sortByHot.selected = YES;
            sortByScore.selected = NO;
        }
        else{
            sortByHot.selected = NO;
            sortByScore.selected = YES;
        }
        [self.navigationController.view addSubview:bg];
    }
}

-(void)hiddenSortedSelectedView{
    UIImageView *bg = (UIImageView *)[self.navigationController.view viewWithTag:19999];
    if (bg) {
        [bg removeFromSuperview];
    }
}

-(void)sortTypePressed:(UIButton *)btn{
    UIImageView *bg = (UIImageView *)[self.navigationController.view viewWithTag:19999];
    if (bg) {
        UIButton *sortByHot = (UIButton *)[bg viewWithTag:20001];
        UIButton *sortByScore = (UIButton *)[bg viewWithTag:20002];
        if (btn == sortByHot) {
            sortByHot.selected = YES;
            sortByScore.selected = NO;
            sortedByScore_ = NO;
            
        }
        else{
            sortByHot.selected = NO;
            sortByScore.selected = YES;
            sortedByScore_ = YES;
        }
        [self pulltoReFresh];
        [self hiddenSortedSelectedView];
        ((UIButton *)self.navigationItem.rightBarButtonItem.customView).selected = NO;
    }
    
}
-(void)closeFiltrateView{
   [_filtrateView dismissWithDuration:0.2];
}

-(void)showSegmentControl:(UIButton *)btn{
    btn.selected = !btn.selected;
    if (btn.selected) {
        [_videoTypeSeg show];
        [self.view bringSubviewToFront:_videoTypeSeg];
    }
    else{
        [_videoTypeSeg dissmiss];
    }
    [_videoTypeSeg setSelectAtIndex:typeSelectIndex_];
    
}
#pragma mark -
#pragma mark - videoTypeSegmentDelegate
-(void)videoTypeSegmentDidSelectedAtIndex:(int)index{
    typeSelectIndex_ = index;
     [_videoTypeSeg dissmiss];
     [_filtrateView dismissWithDuration:0.2];
    titleButton_.selected = NO;
    switch (index) {
        case 0:
            [_segV setSegmentControl:TYPE_MOVIE];
            videoType_ = TYPE_MOVIE;
            [titleButton_ setTitle:@"电影" forState:UIControlStateNormal];
            [titleButton_ setTitle:@"电影" forState:UIControlStateHighlighted];
             self.navigationItem.rightBarButtonItem.customView.hidden = NO; 
            break;
        case 1:
            [_segV setSegmentControl:TYPE_TV];
            videoType_ = TYPE_TV;
            [titleButton_ setTitle:@"电视剧" forState:UIControlStateNormal];
            [titleButton_ setTitle:@"电视剧" forState:UIControlStateHighlighted];
             self.navigationItem.rightBarButtonItem.customView.hidden = YES;
            break;
        case 2:
            [_segV setSegmentControl:TYPE_COMIC];
            videoType_ = TYPE_COMIC;
            [titleButton_ setTitle:@"动漫" forState:UIControlStateNormal];
            [titleButton_ setTitle:@"动漫" forState:UIControlStateHighlighted];
            self.navigationItem.rightBarButtonItem.customView.hidden = YES;
            break;
        case 3:
            [_segV setSegmentControl:TYPE_SHOW];
            videoType_ = TYPE_SHOW;
            [titleButton_ setTitle:@"综艺" forState:UIControlStateNormal];
            [titleButton_ setTitle:@"综艺" forState:UIControlStateHighlighted];
            self.navigationItem.rightBarButtonItem.customView.hidden = YES;
            break;
        default:
            break;
    }
    [_parameters setObject:[NSNumber numberWithInt:videoType_] forKey:@"type"];
    [_parameters setObject:@"" forKey:@"sub_type"];
    [_parameters setObject:@"" forKey:@"area"];
    [_parameters setObject:@"" forKey:@"year"];
    [self sendHttpRequest:_parameters];
}

#pragma mark -
#pragma mark - SegmentDelegate
-(void)segmentDidSelectedLabelStr:(NSString *)str withKey:(NSString *)key{
//    NSString *area = [_parameters objectForKey:@"area"];
//    NSString *subType = [_parameters objectForKey:@"sub_type"];
//    NSString *year = [_parameters objectForKey:@"year"];
//    NSLog(@"地区: %@\n 类型: %@\n 年份: %@\n ",area,subType,year);
    
    if ([key isEqualToString:@"sub_type"]) {
        [_parameters setObject:str forKey:@"sub_type"];
        [_parameters setObject:@"" forKey:@"area"];
    }
    else if([key  isEqualToString:@"area"]){
        [_parameters setObject:str forKey:@"area"];
        [_parameters setObject:@"" forKey:@"sub_type"];
    }
    [_parameters setObject:@"" forKey:@"year"];
    [self sendHttpRequest:_parameters];
}

-(void)moreSelectWithType:(int)type withCurrentKey:(NSString *)currentKey moreButton:(UIButton *)btn{;
    //_filtrateView.hidden = NO;
    [_filtrateView setViewWithType:type];
    [_filtrateView setFiltrateViewCurrentKey:currentKey];
    [self.view bringSubviewToFront:_filtrateView];
    moreButton_ = btn;
}

-(void)didTapOnSegmentViewButton:(UIButton *)btn{
    [self closeFiltrateView];
    moreButton_ = btn;
}
#pragma mark -
#pragma mark - FiltrateDelegate
-(void)filtrateWithVideoType:(int)type parameters:(NSMutableDictionary *)parameters{
    [_parameters setObject:[parameters objectForKey:@"sub_type"] forKey:@"sub_type"];
    [_parameters setObject:[parameters objectForKey:@"area"] forKey:@"area"];
    [_parameters setObject:[parameters objectForKey:@"year"] forKey:@"year"];
    [_parameters setObject:@"1" forKey:@"page_num"];
    [_parameters setObject:[NSNumber numberWithInt:type] forKey:@"type"];
    [_parameters setObject:[NSNumber numberWithInt:12] forKey:@"page_size"];
    [self sendHttpRequest:_parameters];
}


#pragma mark -
#pragma mark - UITableViewDelegate&DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;{
    int count = [_dataArr count];
    return (count%3 == 0) ? (count/3):(count/3+1);
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"CellIdentifier";
    FiltrateCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[FiltrateCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.delagate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    int row = indexPath.row;
    int location = 3*row;
    int count = [_dataArr count];
    int length = 0;
    if (location+2 >= [_dataArr count]) {
        length = count%3;
    }
    else{
        length = 3;
    }
    NSRange range = NSMakeRange(location, length);
    NSArray *oneRowItems = [_dataArr subarrayWithRange:range];
    for (int i = 0; i < [oneRowItems count]; i++) {
        NSDictionary *item = [oneRowItems objectAtIndex:i];
        NSString *pic_url = [item objectForKey:@"prod_pic_url"];
        switch (i) {
            case 0:{
                [cell.firstImageView setImageWithURL:[NSURL URLWithString:pic_url]];
                cell.firstLabel.text = [item objectForKey:@"prod_name"];
                break;
            }
            case 1:{
                [cell.secondImageView setImageWithURL:[NSURL URLWithString:pic_url]];
                cell.secondLabel.text = [item objectForKey:@"prod_name"];
                break;
            }
            case 2:{
                [cell.thirdImageView setImageWithURL:[NSURL URLWithString:pic_url]];
                cell.thirdLabel.text = [item objectForKey:@"prod_name"];
                break;
            }
            default:
                break;
        }
        
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 145;
}

#pragma mark -
#pragma mark - FiltrateCellDelegate

-(void)didSelectAtCell:(FiltrateCell *)cell inPosition:(int)position{
    NSIndexPath *indexPath = [_tableList indexPathForCell:cell];
    int row = indexPath.row;
    NSDictionary *item = [_dataArr objectAtIndex:row*3+position];
    NSString *type = [item objectForKey:@"prod_type"];
    if ([type isEqualToString:@"2"]||[type isEqualToString:@"131"]) {
        TVDetailViewController *detailViewController = [[TVDetailViewController alloc] init];
        detailViewController.infoDic = item;
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
    else if ([type isEqualToString:@"1"]){
        IphoneMovieDetailViewController *detailViewController = [[IphoneMovieDetailViewController alloc] init];
        detailViewController.infoDic = item;
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
    else if ([type isEqualToString:@"3"]){
        IphoneShowDetailViewController *detailViewController = [[IphoneShowDetailViewController alloc] init];
        detailViewController.infoDic = item;
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
    
}

#pragma mark -
#pragma mark - UIScrollviewDelegate
- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [pullToRefreshManager_ scrollViewBegin];
    
    titleButton_.selected = NO;
    [_videoTypeSeg dissmiss];
    moreButton_.selected = NO;
    [self closeFiltrateView];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [pullToRefreshManager_ scrollViewScrolled:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
     [pullToRefreshManager_ scrollViewEnd:scrollView];
}

-(void)reloadTableList{
    [_tableList reloadData];
    [pullToRefreshManager_ refreshCompleted];
}

#pragma mark -
#pragma mark - PullRefreshManagerClinetDelegate
-(void)pulltoReFresh{
    [_parameters setObject:@"1" forKey:@"page_num"];
    [self sendHttpRequest:_parameters];
}

-(void)pulltoLoadMore{
    int loadCount = [[_parameters objectForKey:@"page_num"] intValue];
    loadCount++;
    [_parameters setObject:[NSString stringWithFormat:@"%d",loadCount] forKey:@"page_num"];
    [[AFServiceAPIClient sharedClient] getPath:kPathFilter parameters:_parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSArray *itemsArr = [result objectForKey:@"results"];
        [_dataArr addObjectsFromArray:itemsArr];
        if (videoType_ == TYPE_MOVIE && sortedByScore_) {
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO comparator:cmptr];
            NSArray *tempArr = [NSArray arrayWithArray:_dataArr];
            NSArray *sortedArr = [tempArr sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            [_dataArr removeAllObjects];
            [_dataArr addObjectsFromArray:sortedArr];
        }
        
        if ([itemsArr count]<12) {
            pullToRefreshManager_.canLoadMore = NO;
        }
        else{
            pullToRefreshManager_.canLoadMore = YES;
        }
        [_tableList reloadData];
        [pullToRefreshManager_ loadMoreCompleted];
        
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        [self performSelector:@selector(reloadTableList) withObject:nil afterDelay:0.0f];
         [pullToRefreshManager_ loadMoreCompleted];
        [UIUtility showDetailError:self.view error:error];
    }];

}

#pragma mark -
#pragma mark - SendHttpRequest
-(void)sendHttpRequest:(NSDictionary *)parameters{
    NSString *area = [parameters objectForKey:@"area"];
    NSString *subType = [parameters objectForKey:@"sub_type"];
    NSString *year = [parameters objectForKey:@"year"];
//    NSLog(@"地区: %@\n 类型: %@\n 年份: %@\n ",area,subType,year);
    NSString *cacheKey = [NSString stringWithFormat:@"%d%@%@%@",videoType_,subType,area,year];
    id result =  [[CacheUtility sharedCache] loadFromCache:cacheKey];
    if (result != nil) {
        [self analyzeData:result];
        [_tableList reloadData];
    }
    else{
      [_progressHUD show:YES];
      [self analyzeData:result];
      [_tableList reloadData];
    }
    [[AFServiceAPIClient sharedClient] getPath:kPathFilter parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        [[CacheUtility sharedCache] putInCache:cacheKey result:result];
        [_progressHUD hide:YES];
        [self analyzeData:result];
        [self reloadTableList];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
         [_progressHUD hide:YES];
        [self reloadTableList];
    }];
}

-(void)reFreshViewController{
     [self pulltoReFresh];
}

-(void)analyzeData:(id)result{
    if (_dataArr == nil) {
        _dataArr = [NSMutableArray arrayWithCapacity:5];
    }
    else{
        [_dataArr removeAllObjects];
    }
    if (result != nil) {
        NSArray *itemsArr = [result objectForKey:@"results"];
        if (videoType_ == TYPE_MOVIE && sortedByScore_) {
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO comparator:cmptr];
            NSArray *sortedArr = [itemsArr sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            [_dataArr addObjectsFromArray:sortedArr];
        }
        else{
            [_dataArr addObjectsFromArray:itemsArr];
        }
        
        if ([itemsArr count]<12) {
            pullToRefreshManager_.canLoadMore = NO;
        }
        else{
            pullToRefreshManager_.canLoadMore = YES;
        }
    }
}

#pragma mark -
#pragma mark - TVBunding
-(void)showBundingView{
    UIButton *btn = (UIButton *)[self.view viewWithTag:BUNDING_BUTTON_TAG];
    if (btn == nil) {
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 320, BUNDING_HEIGHT);
        [btn setBackgroundImage:[UIImage imageNamed:@"bunding_tv.png"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"bunding_tv_s.png"] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(pushView) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = BUNDING_BUTTON_TAG;
        [self.view addSubview:btn];
    }
    btn.hidden = NO;
  
    _segV.frame = CGRectMake(0, BUNDING_HEIGHT, 320, 42);
    _filtrateView.frame = CGRectMake(0,42+BUNDING_HEIGHT, 320,108);
    _tableList.frame = CGRectMake(0, 42+BUNDING_HEIGHT, 320, kCurrentWindowHeight -44-42-48-BUNDING_HEIGHT);
}

-(void)dismissBundingView{
    UIButton *btn = (UIButton *)[self.view viewWithTag:BUNDING_BUTTON_TAG];
    btn.hidden = YES;
    
    _segV.frame = CGRectMake(0, 0, 320, 42);
    _filtrateView.frame = CGRectMake(0,42, 320,108);
    _tableList.frame = CGRectMake(0, 42, 320, kCurrentWindowHeight -44-42-48);
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

- (void)setViewType:(NSInteger)type
{
    if (TYPE_BUNDING_TV == type)
    {
        [self showBundingView];
        
    }
    else if (TYPE_UNBUNDING == type)
    {
        [self dismissBundingView];
    }
}

-(void)pushView{
    UnbundingViewController *ubCtrl = [[UnbundingViewController alloc] init];
    [self.navigationController pushViewController:ubCtrl animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
