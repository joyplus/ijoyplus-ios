//
//  HomeViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-20.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "VideoViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DDPageControl.h"
#import "MovieDetailViewController.h"
#import "DramaDetailViewController.h"
#import "ShowDetailViewController.h"
#import "ListViewController.h"
#import "SubsearchViewController.h"
#import "CommonHeader.h"
#import "CategoryUtility.h"
#import "CategoryItem.h"

@interface VideoViewController ()

@property (nonatomic, strong)NSString *typePrefix;

@end

@implementation VideoViewController
@synthesize topCategoryView;
@synthesize hightLightCategoryArray;
@synthesize yearCategoryArray, regionCategoryArray, categoryArray;
@synthesize subcategoryView;
@synthesize videoArray;
@synthesize categoryType, regionType, yearType, lastSelectCategoryKey, lastSelectRegionKey, lastSelectYearKey;
@synthesize videoType;
@synthesize typePrefix;

- (void)viewDidUnload{
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (id)initWithFrame:(CGRect)frame {
    if (videoType == MOVIE_TYPE) {
        typePrefix = @"movie";
    } else if(videoType == DRAMA_TYPE){
        typePrefix = @"drama";
    } else if(videoType == COMIC_TYPE){
        typePrefix = @"comic";
    } else if(videoType == SHOW_TYPE){
        typePrefix = @"show";
    }

    if (self = [super init]) {
		[self.view setFrame:frame];
        [self.view setBackgroundColor:[UIColor clearColor]];
        
        UITapGestureRecognizer *hideSubcategoryViewGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideSubcategoryView)];
        [hideSubcategoryViewGesture setNumberOfTapsRequired:1];
        [self.view addGestureRecognizer:hideSubcategoryViewGesture];
        
        sloganImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"slogan"]];
        sloganImageView.frame = CGRectMake(15, 36, 261, 42);
        [self.view addSubview:sloganImageView];
        
        topCategoryView = [[UIView alloc]initWithFrame:CGRectMake(5, 90, self.view.frame.size.width-15, 50)];
        [topCategoryView setBackgroundColor:[UIColor yellowColor]];
        UIImageView *topCatBgImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, topCategoryView.frame.size.width, 45)];
        topCatBgImage.image = [UIImage imageNamed:@"top_category_bg"];
        [topCategoryView addSubview:topCatBgImage];
        
        UIView *sliderView = [[UIView alloc]initWithFrame:CGRectMake(5, 0, 50, 45)];
        sliderView.backgroundColor = CMConstants.yellowColor;
        sliderView.tag = SLIDER_VIEW_TAG;
        sliderView.layer.cornerRadius = 5;
        sliderView.layer.masksToBounds = YES;
        [topCategoryView addSubview:sliderView];
        hightLightCategoryArray = [CategoryUtility getHightlightCategoryByType:videoType];
        for (int i = 0; i < hightLightCategoryArray.count; i++) {
            UIButton *tempBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            tempBtn.frame = CGRectMake(5 + i * 50, 0, 50, 45);
            [tempBtn setBackgroundImage:nil forState:UIControlStateNormal];
            [tempBtn setBackgroundImage:nil forState:UIControlStateHighlighted];
            [tempBtn setBackgroundImage:nil forState:UIControlStateSelected];
            CategoryItem *tempItem = [hightLightCategoryArray objectAtIndex:i];
            [tempBtn setTitle:tempItem.label forState:UIControlStateNormal];
            if (i == 0) {
                [tempBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            } else {
                [tempBtn setTitleColor:CMConstants.grayColor forState:UIControlStateNormal];
            }
            [tempBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            tempBtn.tag = 1101 + i;
            [tempBtn addTarget:self action:@selector(categoryBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [topCategoryView addSubview:tempBtn];
        }
        [self.view addSubview:topCategoryView];
        
        table = [[UITableView alloc] initWithFrame:CGRectMake(9, 150, self.view.frame.size.width - 18, self.view.frame.size.height - 170) style:UITableViewStylePlain];
        [table setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        [table setBackgroundColor:[UIColor yellowColor]];
		[table setDelegate:self];
		[table setDataSource:self];
        [table setBackgroundColor:[UIColor clearColor]];
        [table setShowsVerticalScrollIndicator:NO];
		[table setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        table.tableFooterView = [[UIView alloc] init];
		[self.view addSubview:table];
        
        pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:480.0f tableView:table withClient:self];
        
        if (_refreshHeaderView == nil) {
            EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - table.bounds.size.height, self.view.frame.size.width, table.bounds.size.height)];
            view.backgroundColor = [UIColor clearColor];
            view.delegate = self;
            [table addSubview:view];
            _refreshHeaderView = view;
            
        }
        [_refreshHeaderView refreshLastUpdatedDate];
    }
    return self;
}

- (void)moreBtnClicked:(UIButton *)btn
{
    if (subcategoryView == nil || subcategoryView.hidden) {
        [self showSubcategoryView];
    } else {
        [self hideSubcategoryView];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    videoArray = [[NSMutableArray alloc]initWithCapacity:20];
    categoryType = @"";
    regionType = @"";
    yearType = @"";
    pageSize = 40;
    lastSelectYearKey = @"all";
    lastSelectRegionKey = @"all";
    lastSelectCategoryKey = @"all";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (videoArray.count == 0) {
        [self retrieveData];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (umengPageName) {
        [MobClick endLogPageView:umengPageName];
    }
}

- (void)retrieveData
{
    BOOL isReachable = [[AppDelegate instance] performSelector:@selector(isParseReachable)];
    if(!isReachable) {
        [UIUtility showNetWorkError:self.view];
    }
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:[NSString stringWithFormat:@"%@_list%@%@%@", typePrefix, categoryType, regionType, yearType]];
    if(cacheResult != nil){
        [self parseData:cacheResult];
    } else {
        if(isReachable) {
            [myHUD showProgressBar:self.view];
        }
    }
    reloads_ = 1;
    if([[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: @"1", @"page_num", [NSNumber numberWithInt:pageSize], @"page_size", [NSNumber numberWithInt:videoType], @"type", categoryType, @"sub_type", regionType, @"area", yearType, @"year", nil];
        [[AFServiceAPIClient sharedClient] getPath:kPathFilter parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [self parseData:result];
            [myHUD hide];
            reloads_++;
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
            [myHUD hide];
            [UIUtility showSystemError:self.view];
        }];
    }
}

- (void)parseData:(id)result
{
    [videoArray removeAllObjects];
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        NSArray *tempTopsArray = [result objectForKey:@"results"];
        if(tempTopsArray.count > 0){
            [[CacheUtility sharedCache] putInCache:[NSString stringWithFormat:@"%@_list%@%@%@", typePrefix, categoryType, regionType, yearType] result:result];
            [videoArray addObjectsFromArray:tempTopsArray];
        }
        if(tempTopsArray.count < pageSize){
            [pullToRefreshManager_ setPullToRefreshViewVisible:NO];
        } else {
            [pullToRefreshManager_ setPullToRefreshViewVisible:YES];
        }
    } else {
        [UIUtility showSystemError:self.view];
    }
    [self loadTable];
}

- (void)hideSubcategoryView
{
    subcategoryView.alpha = 0;
    for (UIView *subview in subcategoryView.subviews) {
        subview.alpha = 0;
    }
    [subcategoryView setHidden:YES];
    [subcategoryView removeFromSuperview];
}

- (void)loadTable {
    [table reloadData];
    [pullToRefreshManager_ tableViewReloadFinished];
}


- (void)reloadTableViewDataSource{
    reloads_ = 2;
    [self retrieveData];
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

- (void)categoryBtnClicked:(UIButton *)btn
{
    int num = btn.tag - 1101;
    if (subcategoryView && !subcategoryView.hidden && num != hightLightCategoryArray.count - 1) {
        [self hideSubcategoryView];
    }
    for (int i = 0; i < hightLightCategoryArray.count; i++) {
        UIButton *tempBtn = (UIButton *)[topCategoryView viewWithTag:1101 + i];
        if (tempBtn.tag == btn.tag) {
            [tempBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        } else {
            [tempBtn setTitleColor:[UIColor colorWithRed:132/255.0 green:132/255.0 blue:129/255.0 alpha:1] forState:UIControlStateNormal];
        }
    }
    if (num < hightLightCategoryArray.count) {
        CategoryItem *item = [hightLightCategoryArray objectAtIndex:num];
        [self composeFilterCondition:item multipleCondition:NO];
        [self moveSliderView:num];
        if (num == hightLightCategoryArray.count - 1) {
            [self showSubcategoryView];
        } else {
            [self changeLastSelectIndex:item];
            [self retrieveData];
        }
    }
}

- (void)changeLastSelectIndex:(CategoryItem *)item
{
    if (item.subtype == NO_TYPE) {
        lastSelectCategoryKey = @"all";
        lastSelectRegionKey = @"all";
        lastSelectYearKey = @"all";
    } else if (item.subtype == CATEGORY_TYPE) {
        lastSelectRegionKey = @"all";
        lastSelectCategoryKey = item.key;
        lastSelectYearKey = @"all";
    } else if(item.subtype == REGION_TYPE) {
        lastSelectCategoryKey = @"all";
        lastSelectRegionKey = item.key;
        lastSelectYearKey = @"all";
    }
}

- (void)composeFilterCondition:(CategoryItem *)item multipleCondition:(BOOL)multipleCondition
{
    if (item.subtype == NO_TYPE) { //当用户点击全部时
        categoryType = @"";
        regionType = @"";
        yearType = @"";
    } else if (item.subtype == ALL_CATEGORY){
        categoryType = @"";
    } else if (item.subtype == ALL_REGION){
        regionType = @"";
    } else if (item.subtype == ALL_YEAR) {
        yearType = @"";
    } else if (item.subtype == CATEGORY_TYPE) {
        categoryType = item.value;
        if (!multipleCondition) {
            regionType = @"";
            yearType = @"";
        }
    } else if (item.subtype == REGION_TYPE) {
        regionType = item.value;
        if (!multipleCondition) {
            categoryType = @"";
            yearType = @"";
        }
    } else if (item.subtype == YEAR_TYPE) {
        yearType = item.value;
        if (!multipleCondition) {
            categoryType = @"";
            regionType = @"";
        }
    }
}

- (void)showSubcategoryView
{
    if (subcategoryView == nil) {
        subcategoryView = [[UIView alloc]initWithFrame:CGRectMake(10, 130, 500, 350)];
        subcategoryView.alpha = 0;
        [subcategoryView setBackgroundColor:[UIColor whiteColor]];
        if (categoryArray == nil) {
            categoryArray = [CategoryUtility getCategoryByType:self.videoType];
        }
        if (regionCategoryArray == nil) {
            regionCategoryArray = [CategoryUtility getRegionTypeByType:self.videoType];
        }
        if (yearCategoryArray == nil) {
            yearCategoryArray = [CategoryUtility getYearTypeByType:self.videoType];
        }
        
        UILabel *categoryLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 50, 40, 45)];
        categoryLabel.textColor = CMConstants.grayColor;
        [categoryLabel setFont:[UIFont systemFontOfSize:15]];
        categoryLabel.text = @"类型";
        [subcategoryView addSubview:categoryLabel];
        
        for (int i = 0; i < categoryArray.count; i++) {
            CategoryItem *tempItem = [categoryArray objectAtIndex:i];
            UIButton *tempBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            tempBtn.frame = CGRectMake(70 + (i%8) * 51, categoryLabel.frame.origin.y + (i/8) * 50, 50, 45);
            [tempBtn setBackgroundImage:nil forState:UIControlStateNormal];
            [tempBtn setBackgroundImage:nil forState:UIControlStateHighlighted];
            [tempBtn setBackgroundImage:nil forState:UIControlStateSelected];
            tempBtn.titleLabel.font = [UIFont systemFontOfSize:15];
            [tempBtn setTitle:tempItem.label forState:UIControlStateNormal];
            [tempBtn setTitleColor:CMConstants.grayColor forState:UIControlStateNormal];
            
            tempBtn.tag = 1201 + i;
            [tempBtn addTarget:self action:@selector(subcategoryBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [subcategoryView addSubview:tempBtn];
        }
        
        UILabel *regionLabel = [[UILabel alloc]initWithFrame:CGRectMake(categoryLabel.frame.origin.x, 200, categoryLabel.frame.size.width, categoryLabel.frame.size.height)];
        regionLabel.textColor = CMConstants.grayColor;
        [regionLabel setFont:[UIFont systemFontOfSize:15]];
        regionLabel.text = @"地区";
        [subcategoryView addSubview:regionLabel];
        for (int i = 0; i < regionCategoryArray.count; i++) {
            CategoryItem *tempItem = [regionCategoryArray objectAtIndex:i];
            UIButton *tempBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            tempBtn.frame = CGRectMake(70 + (i%8) * 51, regionLabel.frame.origin.y, 50, 45);
            [tempBtn setBackgroundImage:nil forState:UIControlStateNormal];
            [tempBtn setBackgroundImage:nil forState:UIControlStateHighlighted];
            [tempBtn setBackgroundImage:nil forState:UIControlStateSelected];
            tempBtn.titleLabel.font = [UIFont systemFontOfSize:15];
            [tempBtn setTitle:tempItem.label forState:UIControlStateNormal];
            [tempBtn setTitleColor:CMConstants.grayColor forState:UIControlStateNormal];
            if ([lastSelectRegionKey isEqualToString:tempItem.key]) {
                [tempBtn setTitleColor:CMConstants.yellowColor forState:UIControlStateNormal];
            } else {
                [tempBtn setTitleColor:CMConstants.yellowColor forState:UIControlStateHighlighted];
            }
            tempBtn.tag = 1301 + i;
            [tempBtn addTarget:self action:@selector(subcategoryBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [subcategoryView addSubview:tempBtn];
        }
        
        UILabel *yearLabel = [[UILabel alloc]initWithFrame:CGRectMake(categoryLabel.frame.origin.x, 250, categoryLabel.frame.size.width, categoryLabel.frame.size.height)];
        yearLabel.contentMode = UIControlContentVerticalAlignmentCenter;
        yearLabel.textColor = CMConstants.grayColor;
        [yearLabel setFont:[UIFont systemFontOfSize:15]];
        yearLabel.text = @"年份";
        [subcategoryView addSubview:yearLabel];
        for (int i = 0; i < yearCategoryArray.count; i++) {
            CategoryItem *tempItem = [yearCategoryArray objectAtIndex:i];
            UIButton *tempBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            tempBtn.frame = CGRectMake(70 + (i%8) * 51, yearLabel.frame.origin.y + (i/8) * 50, 50, 45);
            [tempBtn setBackgroundImage:nil forState:UIControlStateNormal];
            [tempBtn setBackgroundImage:nil forState:UIControlStateHighlighted];
            [tempBtn setBackgroundImage:nil forState:UIControlStateSelected];
            tempBtn.titleLabel.font = [UIFont systemFontOfSize:15];
            [tempBtn setTitle:tempItem.label forState:UIControlStateNormal];
            tempBtn.tag = 1401 + i;
            [tempBtn addTarget:self action:@selector(subcategoryBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [subcategoryView addSubview:tempBtn];
        }
        for (UIView *subview in subcategoryView.subviews) {
            subview.alpha = 0;
        }
    }
    for (int i = 0; i < categoryArray.count; i++) {
        UIButton *tempBtn = (UIButton *)[subcategoryView viewWithTag:1201+i];
        CategoryItem *tempItem = [categoryArray objectAtIndex:i];
        if ([lastSelectCategoryKey isEqualToString:tempItem.key]) {
            [tempBtn setTitleColor:CMConstants.yellowColor forState:UIControlStateNormal];
        } else {
            [tempBtn setTitleColor:CMConstants.grayColor forState:UIControlStateNormal];
            [tempBtn setTitleColor:CMConstants.yellowColor forState:UIControlStateHighlighted];
        }
    }
    for (int i = 0; i < regionCategoryArray.count; i++) {
        UIButton *tempBtn = (UIButton *)[subcategoryView viewWithTag:1301+i];
        CategoryItem *tempItem = [regionCategoryArray objectAtIndex:i];
        if ([lastSelectRegionKey isEqualToString:tempItem.key]) {
            [tempBtn setTitleColor:CMConstants.yellowColor forState:UIControlStateNormal];
        } else {
            [tempBtn setTitleColor:CMConstants.grayColor forState:UIControlStateNormal];
            [tempBtn setTitleColor:CMConstants.yellowColor forState:UIControlStateHighlighted];
        }
    }
    for (int i = 0; i < yearCategoryArray.count; i++) {
        UIButton *tempBtn = (UIButton *)[subcategoryView viewWithTag:1401+i];
        CategoryItem *tempItem = [yearCategoryArray objectAtIndex:i];
        if ([lastSelectYearKey isEqualToString:tempItem.key]) {
            [tempBtn setTitleColor:CMConstants.yellowColor forState:UIControlStateNormal];
        } else {
            [tempBtn setTitleColor:CMConstants.grayColor forState:UIControlStateNormal];
            [tempBtn setTitleColor:CMConstants.yellowColor forState:UIControlStateHighlighted];
        }
    }
    [self.view addSubview:subcategoryView];
    [subcategoryView setHidden:NO];
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
        for (UIView *subview in subcategoryView.subviews) {
            subview.alpha = 1;
        }
        subcategoryView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)subcategoryBtnClicked:(UIButton *)btn
{
    CategoryItem *item;
    if (btn.tag < 1300) {//category
        if (btn.tag - 1201 < categoryArray.count) {
            item = [categoryArray objectAtIndex:btn.tag - 1201];
            lastSelectCategoryKey = item.key;
        }
        for (int i = 0; i < categoryArray.count; i++) {
            UIButton *tempBtn = (UIButton *)[subcategoryView viewWithTag:1201 + i];
            if (tempBtn == btn) {
                [tempBtn setTitleColor:CMConstants.yellowColor forState:UIControlStateNormal];
            } else {
                [tempBtn setTitleColor:CMConstants.grayColor forState:UIControlStateNormal];
            }
        }
    } else if (btn.tag > 1400) {// year
        if (btn.tag - 1401 < yearCategoryArray.count) {
            item = [yearCategoryArray objectAtIndex:btn.tag - 1401];
            lastSelectYearKey = item.key;
        }
        for (int i = 0; i < yearCategoryArray.count; i++) {
            UIButton *tempBtn = (UIButton *)[subcategoryView viewWithTag:1401 + i];
            if (tempBtn == btn) {
                [tempBtn setTitleColor:CMConstants.yellowColor forState:UIControlStateNormal];
            } else {
                [tempBtn setTitleColor:CMConstants.grayColor forState:UIControlStateNormal];
            }
        }
    } else {// region
        if (btn.tag - 1301 < regionCategoryArray.count) {
            item = [regionCategoryArray objectAtIndex:btn.tag - 1301];
            lastSelectRegionKey = item.key;
        }
        for (int i = 0; i < regionCategoryArray.count; i++) {
            UIButton *tempBtn = (UIButton *)[subcategoryView viewWithTag:1301 + i];
            if (tempBtn == btn) {
                [tempBtn setTitleColor:CMConstants.yellowColor forState:UIControlStateNormal];
            } else {
                [tempBtn setTitleColor:CMConstants.grayColor forState:UIControlStateNormal];
            }
        }
    }
    [self composeFilterCondition:item multipleCondition:YES];
    [self retrieveData];
}

- (void)moveSliderView:(int)num
{
    UIView *sliderView = [topCategoryView viewWithTag:SLIDER_VIEW_TAG];
    if (sliderView) {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
            sliderView.frame = CGRectMake(5 + num * 50, 0, sliderView.frame.size.width, sliderView.frame.size.height);
        } completion:^(BOOL finished) {
            
        }];
    }
}

#pragma mark -
#pragma mark MNMBottomPullToRefreshManagerClient

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    [pullToRefreshManager_ tableViewScrolled];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    [pullToRefreshManager_ tableViewReleased];
}

- (void)MNMBottomPullToRefreshManagerClientReloadTable {
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [UIUtility showNetWorkError:self.view];
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:2.0f];
        return;
    }
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:reloads_], @"page_num", [NSNumber numberWithInt:pageSize], @"page_size", [NSNumber numberWithInt:videoType], @"type", categoryType, @"sub_type", regionType, @"area", yearType, @"year", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathFilter parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        NSArray *tempTopsArray;
        if(responseCode == nil){
            tempTopsArray = [result objectForKey:@"results"];
            if(tempTopsArray.count > 0){
                [videoArray addObjectsFromArray:tempTopsArray];
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

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ceil(videoArray.count / 5.0);
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    static NSString *CellIdentifier = @"topImageCell";
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellEditingStyleNone];
        for (int i=0; i < 5; i++) {
            UIButton *tempBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImageView *movieImage = [[UIImageView alloc]init];
            movieImage.tag = 6011 + i;
            movieImage.frame = CGRectMake(13 + (VIDEO_LOGO_WIDTH+22) * i, 5, VIDEO_LOGO_WIDTH, VIDEO_LOGO_HEIGHT);
            tempBtn.frame = movieImage.frame;
            tempBtn.tag = 2011 + i;
            [tempBtn addTarget:self action:@selector(imageClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:movieImage];
            [cell.contentView addSubview:tempBtn];
            
            UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(movieImage.frame.origin.x, movieImage.frame.origin.y + movieImage.frame.size.height, movieImage.frame.size.width, 25)];
            nameLabel.contentMode = UIViewContentModeTop;
            [nameLabel setTextAlignment:NSTextAlignmentCenter];
            [nameLabel setTextColor:[UIColor blackColor]];
            [nameLabel setBackgroundColor:[UIColor clearColor]];
            [nameLabel setFont:[UIFont systemFontOfSize:13]];
            nameLabel.tag = 3011 + i;
            [cell.contentView addSubview:nameLabel];
            
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y + nameLabel.frame.size.height-10, nameLabel.frame.size.width, 20)];
            [titleLabel setTextColor:CMConstants.grayColor];
            [titleLabel setFont:[UIFont systemFontOfSize:11]];
            titleLabel.contentMode = UIViewContentModeTop;
            [titleLabel setTextAlignment:NSTextAlignmentCenter];
            [titleLabel setBackgroundColor:[UIColor clearColor]];
            titleLabel.tag = 4011 + i;
            [cell.contentView addSubview:titleLabel];
        }
        
        
        //        UIImageView *lineImage = [[UIImageView alloc]initWithFrame:CGRectMake(10, VIDEO_LOGO_HEIGHT + 40 - 2, 450, 2)];
        //        lineImage.image = [UIImage imageNamed:@"dividing"];
        //        [self.view addSubview:lineImage];
        //        [cell.contentView addSubview:lineImage];
    }
    if (indexPath.row < ceil(videoArray.count/5.0)) {
        int i = 0;
        for (i = 0; i < fmin(videoArray.count - 5 * indexPath.row, 5); i++) {
            //                if(selectedRowNumber == indexPath.row && lastPressedBtn == tempBtn){
            //                    [tempBtn setBackgroundImage:[UIImage imageNamed:@"moviecard_pressed"] forState:UIControlStateNormal];
            //                } else {
            //                    [tempBtn setBackgroundImage:[UIImage imageNamed:@"moviecard"] forState:UIControlStateNormal];
            //                }
            
            UIImageView *contentImage = (UIImageView *)[cell viewWithTag:6011 + i];
            NSDictionary *item = [videoArray objectAtIndex: 5 * indexPath.row + i];
            [contentImage setImageWithURL:[NSURL URLWithString:[item objectForKey:@"prod_pic_url"]] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
            UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:3011 + i];
            nameLabel.text = [item objectForKey:@"prod_name"];
            //                if(selectedRowNumber == indexPath.row && lastPressedLabel == tempLabel){
            //                    tempLabel.textColor = [UIColor whiteColor];
            //                } else {
            //                    tempLabel.textColor = [UIColor blackColor];
            //                }
            UILabel *titleLabel = (UILabel *)[cell viewWithTag:4011 + i];
            titleLabel.text = [NSString stringWithFormat:@"更新至第%@集", [item objectForKey:@"cur_episode"]];
        }
        if (i < 5) {
            for (int j = i; j < 5; j++) {
                UIImageView *contentImage = (UIImageView *)[cell viewWithTag:6011 + j];
                contentImage.image = nil;
                UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:3011 + j];
                nameLabel.text = @"";
                UILabel *titleLabel = (UILabel *)[cell viewWithTag:4011 + j];
                titleLabel.text = @"";
            }
        }
        
    }
    return cell;
}

- (void)showDetailScreen:(NSDictionary *)item
{
    NSString *prodType = [NSString stringWithFormat:@"%@", [item objectForKey:@"prod_type"]];
    if([prodType isEqualToString:[NSString stringWithFormat:@"%i", MOVIE_TYPE]]){
        MovieDetailViewController *viewController = [[MovieDetailViewController alloc] initWithNibName:@"MovieDetailViewController" bundle:nil];
        viewController.fromViewController = self;
        viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
        viewController.prodId = [NSString stringWithFormat:@"%@", [item objectForKey:@"prod_id"]];
        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE  removePreviousView:YES];
    } else if([prodType isEqualToString:[NSString stringWithFormat:@"%i", DRAMA_TYPE]] || [prodType isEqualToString:[NSString stringWithFormat:@"%i", COMIC_TYPE]]){
        DramaDetailViewController *viewController = [[DramaDetailViewController alloc] initWithNibName:@"DramaDetailViewController" bundle:nil];
        viewController.fromViewController = self;
        viewController.prodId = [NSString stringWithFormat:@"%@", [item objectForKey:@"prod_id"]];
        viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:YES];
    } else if([prodType isEqualToString:[NSString stringWithFormat:@"%i", SHOW_TYPE]]){
        ShowDetailViewController *viewController = [[ShowDetailViewController alloc] initWithNibName:@"ShowDetailViewController" bundle:nil];
        viewController.fromViewController = self;
        viewController.prodId = [NSString stringWithFormat:@"%@", [item objectForKey:@"prod_id"]];
        viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:YES];
    }
}

- (void)updatePressedBtn:(UIButton *)btn pressedLabel:(UILabel *)pressedLabel selectedRow:(NSInteger)selectedRow
{
    //    if(lastPressedBtn != nil){
    //        lastPressedLabel.textColor = [UIColor blackColor];
    //        [lastPressedBtn setBackgroundImage:[UIImage imageNamed:@"moviecard"] forState:UIControlStateNormal];
    //    }
    //    pressedLabel.textColor = [UIColor whiteColor];
    //    [btn setBackgroundImage:[UIImage imageNamed:@"moviecard_pressed"] forState:UIControlStateNormal];
    //    lastPressedLabel = pressedLabel;
    //    selectedRowNumber = selectedRow;
    //    lastPressedBtn = btn;
    //    lastSelectedListImage = nil;
    //    lastSelectedOverlay = nil;
}

- (void)imageClicked:(UIButton *)btn
{
    CGPoint point = btn.center;
    point = [table convertPoint:point fromView:btn.superview];
    NSIndexPath* indexPath = [table indexPathForRowAtPoint:point];
    if (indexPath.row < ceil(videoArray.count/5.0)) {
        UILabel *titleLabel = (UILabel *)[[btn superview] viewWithTag:btn.tag + 1000];
        [self updatePressedBtn:btn pressedLabel:titleLabel selectedRow:indexPath.row];
        int num = indexPath.row * 5 + btn.tag - 2011;
        if (num < videoArray.count) {
            NSDictionary *item = [videoArray objectAtIndex:num];
            [self showDetailScreen:item];
        }
        
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return VIDEO_LOGO_HEIGHT + 40;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


@end
