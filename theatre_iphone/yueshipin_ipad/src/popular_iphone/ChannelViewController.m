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
#define BUNDING_HEIGHT 30
#define BUNDING_BUTTON_TAG 20001
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
@synthesize pullToRefreshManager = _pullToRefreshManager;
@synthesize refreshHeaderView = _refreshHeaderView;
@synthesize progressHUD = _progressHUD;
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
    
//    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [rightButton addTarget:self action:@selector(setting:) forControlEvents:UIControlEventTouchUpInside];
//    rightButton.frame = CGRectMake(0, 0, 55, 44);
//    rightButton.backgroundColor = [UIColor clearColor];
//    [rightButton setImage:[UIImage imageNamed:@"scan_btn.png"] forState:UIControlStateNormal];
//    [rightButton setImage:[UIImage imageNamed:@"scan_btn_f.png"] forState:UIControlStateHighlighted];
//    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
//    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
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
    _videoTypeSeg.hidden = YES;
    [self.view addSubview: _videoTypeSeg];
    
    _filtrateView = [[FiltrateView alloc] initWithFrame:CGRectMake(0, 42, 320, 108)];
    _filtrateView.delegate = self;
    _filtrateView.hidden = YES;
    [self.view addSubview:_filtrateView];
    
    _tableList = [[UITableView alloc] initWithFrame:CGRectMake(0, 42, 320, kCurrentWindowHeight -44-42-48) style:UITableViewStylePlain];
    _tableList.dataSource = self;
    _tableList.delegate = self;
    _tableList.backgroundColor = [UIColor clearColor];
    _tableList.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableList];
    
    
    _pullToRefreshManager = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:480.0f tableView:_tableList withClient:self];
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *egoRefreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - _tableList.bounds.size.height, self.view.frame.size.width, _tableList.bounds.size.height)];
        egoRefreshTableHeaderView.backgroundColor = [UIColor clearColor];
        egoRefreshTableHeaderView.delegate = self;
        [_tableList addSubview:egoRefreshTableHeaderView];
        _refreshHeaderView = egoRefreshTableHeaderView;
    }
    
    _progressHUD  = [[MBProgressHUD alloc] initWithView:self.view];
    _progressHUD.labelText = @"加载中...";
    _progressHUD.opacity = 0.5;
    [self.view addSubview:_progressHUD];
     
    [self initDefaultParameters];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(managerTVBunding)
                                                 name:@"bundingTVSucceeded"
                                               object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
   [super viewWillAppear:animated];
   [self managerTVBunding];
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

-(void)closeFiltrateView{
   _filtrateView.hidden = YES;
}

-(void)showSegmentControl:(UIButton *)btn{
    btn.selected = !btn.selected;
    if (btn.selected) {
        _videoTypeSeg.hidden = NO;
        [self.view bringSubviewToFront:_videoTypeSeg];
    }
    else{
        _videoTypeSeg.hidden = YES;
    }
    [_videoTypeSeg setSelectAtIndex:typeSelectIndex_];
    
}
#pragma mark -
#pragma mark - videoTypeSegmentDelegate
-(void)videoTypeSegmentDidSelectedAtIndex:(int)index{
    typeSelectIndex_ = index;
    _videoTypeSeg.hidden = YES;
    _filtrateView.hidden = YES;
    titleButton_.selected = NO;
    switch (index) {
        case 0:
            [_segV setSegmentControl:TYPE_MOVIE];
            videoType_ = TYPE_MOVIE;
            [titleButton_ setTitle:@"电影" forState:UIControlStateNormal];
            [titleButton_ setTitle:@"电影" forState:UIControlStateHighlighted];
            break;
        case 1:
            [_segV setSegmentControl:TYPE_TV];
            videoType_ = TYPE_TV;
            [titleButton_ setTitle:@"电视剧" forState:UIControlStateNormal];
            [titleButton_ setTitle:@"电视剧" forState:UIControlStateHighlighted];
            break;
        case 2:
            [_segV setSegmentControl:TYPE_COMIC];
            videoType_ = TYPE_COMIC;
            [titleButton_ setTitle:@"动漫" forState:UIControlStateNormal];
            [titleButton_ setTitle:@"动漫" forState:UIControlStateHighlighted];
            break;
        case 3:
            [_segV setSegmentControl:TYPE_SHOW];
            videoType_ = TYPE_SHOW;
            [titleButton_ setTitle:@"综艺" forState:UIControlStateNormal];
            [titleButton_ setTitle:@"综艺" forState:UIControlStateHighlighted];
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
    NSString *area = [_parameters objectForKey:@"area"];
    NSString *subType = [_parameters objectForKey:@"sub_type"];
    NSString *year = [_parameters objectForKey:@"year"];
    NSLog(@"地区: %@\n 类型: %@\n 年份: %@\n ",area,subType,year);
    
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

-(void)moreSelectWithType:(int)type withCurrentKey:(NSString *)currentKey{;
    _filtrateView.hidden = NO;
    [_filtrateView setViewWithType:type];
    [_filtrateView setFiltrateViewCurrentKey:currentKey];
    [self.view bringSubviewToFront:_filtrateView];
}

-(void)didTapOnSegmentView{
    [self closeFiltrateView];
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

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView{
   [_refreshHeaderView egoRefreshScrollViewDidScroll:aScrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)aScrollView willDecelerate:(BOOL)decelerate {
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:aScrollView];
    [_pullToRefreshManager tableViewReleased];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	isLoading_ = YES;
    [_parameters setObject:@"1" forKey:@"page_num"];
    [self sendHttpRequest:_parameters];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1.0];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return isLoading_;
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; 
	
}

#pragma mark -
#pragma mark MNMBottomPullToRefreshManager Methods
- (void)MNMBottomPullToRefreshManagerClientReloadTable{
    int loadCount = [[_parameters objectForKey:@"page_num"] intValue];
    loadCount++;
    [_parameters setObject:[NSString stringWithFormat:@"%d",loadCount] forKey:@"page_num"];
    [[AFServiceAPIClient sharedClient] getPath:kPathFilter parameters:_parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSArray *itemsArr = [result objectForKey:@"results"];
        [_dataArr addObjectsFromArray:itemsArr];
        [self reloadTableList];
        if ([itemsArr count]<12) {
            [_pullToRefreshManager setPullToRefreshViewVisible:NO];
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
    }];

}

-(void)reloadTableList{
    [_tableList reloadData];
    [_pullToRefreshManager tableViewReloadFinished];
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	isLoading_ = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableList];
	
}
#pragma mark -
#pragma mark - SendHttpRequest
-(void)sendHttpRequest:(NSDictionary *)parameters{
    NSString *area = [parameters objectForKey:@"area"];
    NSString *subType = [parameters objectForKey:@"sub_type"];
    NSString *year = [parameters objectForKey:@"year"];
    NSLog(@"地区: %@\n 类型: %@\n 年份: %@\n ",area,subType,year);
    NSString *cacheKey = [NSString stringWithFormat:@"%@%@%@",subType,area,year];
    id result =  [[CacheUtility sharedCache] loadFromCache:cacheKey];
    if (result != nil) {
        [self analyzeData:result];
        [self reloadTableList];
    }
    else{
      [_progressHUD show:YES];
    }
    
    [[AFServiceAPIClient sharedClient] getPath:kPathFilter parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        [[CacheUtility sharedCache] putInCache:cacheKey result:result];
        [_progressHUD setHidden:YES];
        [self analyzeData:result];
        [self reloadTableList];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        [_progressHUD setHidden:YES];
    }];
}

-(void)analyzeData:(id)result{
    if (_dataArr == nil) {
        _dataArr = [NSMutableArray arrayWithCapacity:5];
    }
    else{
        [_dataArr removeAllObjects];
    }
    
    NSArray *itemsArr = [result objectForKey:@"results"];
    [_dataArr addObjectsFromArray:itemsArr];
    
    
}

#pragma mark -
#pragma mark - TVBunding
-(void)showBundingView{
    UIButton *btn = (UIButton *)[self.view viewWithTag:BUNDING_BUTTON_TAG];
    if (btn == nil) {
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 320, BUNDING_HEIGHT+1);
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
