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
#define PAGE_NUM 3
#define TV_TYPE 9000
#define MOVIE_TYPE 9001
#define SHOW_TYPE 9002
#define PAGESIZE 20

@interface PageManageViewController ()

@end

@implementation PageManageViewController
@synthesize scrollView = scrollView_;
@synthesize pageControl = pageControl_;
@synthesize tvListArr = tvListArr_;
@synthesize movieListArr = movieListArr_;
@synthesize showListArr = showListArr_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//- (void)parseTopsListData:(id)result
//{
//    self.listArr = [[NSMutableArray alloc]initWithCapacity:PAGESIZE];
//    NSString *responseCode = [result objectForKey:@"res_code"];
//    if(responseCode == nil){
//        NSArray *tempTopsArray = [result objectForKey:@"tops"];
//        if(tempTopsArray.count > 0){
//            
//            [ self.listArr addObjectsFromArray:tempTopsArray];
//        }
//    }
//    else {
//        
//    }
//    
//}


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

    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: @"1", @"page_num", [NSNumber numberWithInt:PAGESIZE], @"page_size", nil];
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
        
        [self.tvTableList reloadData];
        [tempHUD hide:YES];
        
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        if(self.tvListArr == nil){
            self.tvListArr = [[NSMutableArray alloc]initWithCapacity:10];
        }
        [tempHUD hide:YES];
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

    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: @"1", @"page_num", [NSNumber numberWithInt:PAGESIZE], @"page_size", nil];
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
        [self.movieTableList reloadData];
         [tempHUD hide:YES];
        
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        if(self.movieListArr == nil){
            self.movieListArr = [[NSMutableArray alloc]initWithCapacity:10];
        }
         [tempHUD hide:YES];
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
                [ self.showListArr addObjectsFromArray:tempTopsArray];
            }
        }
        
        [self.showTableList reloadData];
    }
    else {
        if(tempHUD == nil){
            tempHUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.showTableList reloadData];
            [self.view addSubview:tempHUD];
            tempHUD.labelText = @"加载中...";
            tempHUD.opacity = 0.5;
            [tempHUD show:YES];
        }
    }

    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: @"1", @"page_num", [NSNumber numberWithInt:PAGESIZE], @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathShowTops parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        self.showListArr = [[NSMutableArray alloc]initWithCapacity:PAGESIZE];
        NSString *responseCode = [result objectForKey:@"res_code"];
        
        if(responseCode == nil){
            NSArray *tempTopsArray = [result objectForKey:@"tops"];
            if(tempTopsArray.count > 0){
                NSArray *tempArray = [[tempTopsArray objectAtIndex:0] objectForKey:@"items"];
                if(tempArray.count > 0) {
                    [[CacheUtility sharedCache] putInCache:@"show_top_list" result:result];
                    [self.showListArr addObjectsFromArray:tempArray];
                }
            }
        }
        else {
            
        }
        [self.showTableList reloadData];
        [tempHUD hide:YES];
        
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        if(self.showListArr == nil){
            self.showListArr = [[NSMutableArray alloc]initWithCapacity:10];
        }
        [tempHUD hide:YES];
    }];
    
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILabel *titleText = [[UILabel alloc] initWithFrame: CGRectMake(90, 0, 40, 40)];
    titleText.backgroundColor = [UIColor clearColor];
    titleText.textColor=[UIColor whiteColor];
    [titleText setFont:[UIFont boldSystemFontOfSize:18.0]];
    [titleText setText:@"悦榜"];
    self.navigationItem.titleView=titleText;
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, 40, 30);
    leftButton.backgroundColor = [UIColor clearColor];
    [leftButton setImage:[UIImage imageNamed:@"top_search_common.png"] forState:UIControlStateNormal];
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton addTarget:self action:@selector(setting:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(0, 0, 40, 30);
    rightButton.backgroundColor = [UIColor clearColor];
    [rightButton setImage:[UIImage imageNamed:@"top_setting_common.png"] forState:UIControlStateNormal];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
	// Do any additional setup after loading the view.
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 380)];
    self.scrollView.contentSize = CGSizeMake(320*PAGE_NUM, 380);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    
    for (int i = 0; i < PAGE_NUM; i++) {
        UIImageView *titleName = titleName = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 90, 18)];
        if (i == 0) {
            titleName.image = [UIImage imageNamed:@"top_biao_ti_xiao_1.png"];
        }
        else if(i == 1){
            titleName.image = [UIImage imageNamed:@"top_biao_ti_xiao_2.png"];
        
        }
        else if (i == 2){
            titleName.image = [UIImage imageNamed:@"top_biao_ti_xiao_3.png"];
        }
        
        UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab2_biao_ti_top.png"]];
        titleView.frame = CGRectMake(320*i, 0, 320, 30);
        [titleView addSubview:titleName];
        [self.scrollView addSubview:titleView];
        
    }
    
    self.tvTableList = [[UITableView alloc] initWithFrame:CGRectMake(320, 30,320 , 350) style:UITableViewStylePlain];
    self.tvTableList.dataSource = self;
    self.tvTableList.delegate = self;
    self.tvTableList.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tvTableList.tag = TV_TYPE;
    [self.scrollView addSubview:self.tvTableList];
    
    self.movieTableList = [[UITableView alloc] initWithFrame:CGRectMake(0, 30,320 , 350) style:UITableViewStylePlain];
    self.movieTableList.dataSource = self;
    self.movieTableList.delegate = self;
    self.movieTableList.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.movieTableList.tag = MOVIE_TYPE;
    [self.scrollView addSubview:self.movieTableList];
    
    self.showTableList = [[UITableView alloc] initWithFrame:CGRectMake(640, 30,320 , 350) style:UITableViewStylePlain];
    self.showTableList.dataSource = self;
    self.showTableList.delegate = self;
    self.showTableList.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.showTableList.tag = SHOW_TYPE;
    [self.scrollView addSubview:self.showTableList];
    
    [self.view addSubview:self.scrollView];
    
    UIView *pageColBg = [[UIView alloc] initWithFrame:CGRectMake(125, 328, 70, 26)];
    
    pageColBg.backgroundColor = [UIColor colorWithRed:75/255.0 green:75/255.0 blue:75/255.0 alpha: 1.0f];
    pageColBg.alpha = 0.5;
    [self.view addSubview:pageColBg];
    pageControl_ = [[DDPageControl alloc] init] ;
    [pageControl_ setCenter: CGPointMake(pageColBg.center.x, pageColBg.center.y)] ;
    [pageControl_ setNumberOfPages: 3] ;
    [pageControl_ setCurrentPage: 0] ;
    [pageControl_ addTarget: self action: @selector(changePage:) forControlEvents: UIControlEventValueChanged] ;
    [pageControl_ setDefersCurrentPageDisplay: YES] ;
    [pageControl_ setType: DDPageControlTypeOnFullOffEmpty] ;
    [pageControl_ setOnColor: [UIColor colorWithRed:24/255.0 green:112/255.0 blue:195/255.0 alpha: 1.0f]] ;

    [pageControl_ setOffColor: [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha: 1.0f]] ;
    
    [pageControl_ setIndicatorDiameter: 7.0f] ;
    [pageControl_ setIndicatorSpace: 8.0f] ;
    [self.view addSubview:pageControl_];
    
    [self loadMovieTopsData];
    [self loadTVTopsData];
    [self loadShowTopsData];
    
}

-(void)search:(id)sender{
    SearchPreViewController *searchViewCotroller = [[SearchPreViewController alloc] init];
    [self.navigationController pushViewController:searchViewCotroller animated:YES];
    
}

-(void)setting:(id)sender{
    IphoneSettingViewController *iphoneSettingViewController = [[IphoneSettingViewController alloc] init];
    [self.navigationController pushViewController:iphoneSettingViewController animated:YES];
    
}

- (void)viewWillAppear:(BOOL)animated{
    //self.tabBarController.tabBar.hidden = NO;
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
            cell.labelOne.text = [[items objectAtIndex:0] objectForKey:@"prod_name"];
            cell.labelTwo.text = [[items objectAtIndex:1] objectForKey:@"prod_name"];
            cell.labelThree.text = [[items objectAtIndex:2] objectForKey:@"prod_name"];
            cell.title.text = [item objectForKey:@"name"];
            [cell.imageview setImageWithURL:[NSURL URLWithString:[item objectForKey:@"pic_url"]] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
            return cell;
        }
        case MOVIE_TYPE:{
            SortedViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[SortedViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            NSDictionary *item = [self.movieListArr objectAtIndex:indexPath.row];
            NSMutableArray *items = [item objectForKey:@"items"];
            cell.labelOne.text = [[items objectAtIndex:0] objectForKey:@"prod_name"];
            cell.labelTwo.text = [[items objectAtIndex:1] objectForKey:@"prod_name"];
            cell.labelThree.text = [[items objectAtIndex:2] objectForKey:@"prod_name"];
            cell.title.text = [item objectForKey:@"name"];
            [cell.imageview setImageWithURL:[NSURL URLWithString:[item objectForKey:@"pic_url"]] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
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
           [cell.imageView setImageWithURL:[NSURL URLWithString:[item objectForKey:@"prod_pic_url"]] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
        
            return cell;
        }
        default:
            break;
    }
    
    return nil;    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 130;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
    int tableViewTag = tableView.tag;
    if (tableViewTag == TV_TYPE) {
        NSDictionary *item = [self.tvListArr objectAtIndex:indexPath.row];
        NSMutableArray *items = [item objectForKey:@"items"];
        ListDetailViewController *listDetailViewController = [[ListDetailViewController alloc] initWithStyle:UITableViewStylePlain];
        listDetailViewController.listArr = items;
        listDetailViewController.title = [item objectForKey:@"name"];
        listDetailViewController.Type = TV_TYPE;
        listDetailViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:listDetailViewController animated:YES];
    }
    else if (tableViewTag == MOVIE_TYPE){
        NSDictionary *item = [self.movieListArr objectAtIndex:indexPath.row];
        NSMutableArray *items = [item objectForKey:@"items"];
        ListDetailViewController *listDetailViewController = [[ListDetailViewController alloc] initWithStyle:UITableViewStylePlain];
        listDetailViewController.listArr = items;
        listDetailViewController.title = [item objectForKey:@"name"];
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

}


-(void)changePage:(UIPageControl *)PageControl {
    int whichPage = PageControl.currentPage;

    [UIView beginAnimations:nil context:NULL];

    [UIView setAnimationDuration:0.3f];

    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];

    [self.scrollView setContentOffset:CGPointMake(320.0f * whichPage, 0.0f) animated:YES];

    [UIView commitAnimations];

}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.view.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    [pageControl_ setCurrentPage: page] ;
    [pageControl_ updateCurrentPageDisplay] ;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
