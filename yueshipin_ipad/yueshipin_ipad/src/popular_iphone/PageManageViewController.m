//
//  PageManageViewController.m
//  yueshipin
//
//  Created by 08 on 12-12-25.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "PageManageViewController.h"
#import "sortedViewController.h"
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
    
	// Do any additional setup after loading the view.
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 380)];
    self.scrollView.contentSize = CGSizeMake(320*PAGE_NUM, 380);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    NSArray *titlesArr = [NSArray arrayWithObjects:@"热播电视剧",@"热播电影",@"热播综艺", nil];
    for (int i = 0; i < PAGE_NUM; i++) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(320*i, 0, 320, 30)];
        titleLabel.text = [titlesArr objectAtIndex:i];
        titleLabel.backgroundColor = [UIColor redColor];
        [self.scrollView addSubview:titleLabel];
        
    }
    
    self.tvTableList = [[UITableView alloc] initWithFrame:CGRectMake(0, 30,320 , 330) style:UITableViewStylePlain];
    self.tvTableList.dataSource = self;
    self.tvTableList.delegate = self;
    self.tvTableList.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tvTableList.tag = TV_TYPE;
    [self.scrollView addSubview:self.tvTableList];
    
    self.movieTableList = [[UITableView alloc] initWithFrame:CGRectMake(320, 30,320 , 330) style:UITableViewStylePlain];
    self.movieTableList.dataSource = self;
    self.movieTableList.delegate = self;
    self.movieTableList.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.movieTableList.tag = MOVIE_TYPE;
    [self.scrollView addSubview:self.movieTableList];
    
    self.showTableList = [[UITableView alloc] initWithFrame:CGRectMake(640, 30,320 , 330) style:UITableViewStylePlain];
    self.showTableList.dataSource = self;
    self.showTableList.delegate = self;
    self.showTableList.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.showTableList.tag = SHOW_TYPE;
    [self.scrollView addSubview:self.showTableList];
    
    [self.view addSubview:self.scrollView];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(125, 327, 70, 26)];
    self.pageControl.numberOfPages = PAGE_NUM;
    self.pageControl.currentPage = 0;
    [self.pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.pageControl];
    
    [self loadTVTopsData];
    [self loadMovieTopsData];
    [self loadShowTopsData];
    
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
            NSDictionary *item = [self.showListArr objectAtIndex:indexPath.row];
            cell.nameLabel.text = [item objectForKey:@"cur_item_name"];
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
    
    int tableViewTag = tableView.tag;
    if (tableViewTag == TV_TYPE) {
        NSDictionary *item = [self.tvListArr objectAtIndex:indexPath.row];
        NSMutableArray *items = [item objectForKey:@"items"];
        ListDetailViewController *listDetailViewController = [[ListDetailViewController alloc] initWithStyle:UITableViewStylePlain];
        listDetailViewController.listArr = items;
        listDetailViewController.Type = TV_TYPE;
        [self.navigationController pushViewController:listDetailViewController animated:YES];
    }
    else if (tableViewTag == MOVIE_TYPE){
        NSDictionary *item = [self.movieListArr objectAtIndex:indexPath.row];
        NSMutableArray *items = [item objectForKey:@"items"];
        ListDetailViewController *listDetailViewController = [[ListDetailViewController alloc] initWithStyle:UITableViewStylePlain];
        listDetailViewController.listArr = items;
        listDetailViewController.Type = MOVIE_TYPE;
        [self.navigationController pushViewController:listDetailViewController animated:YES];
    }
    else if (tableViewTag == SHOW_TYPE){
        NSDictionary *item = [self.showListArr objectAtIndex:indexPath.row];
        IphoneShowDetailViewController *detailViewController = [[IphoneShowDetailViewController alloc] initWithStyle:UITableViewStylePlain];
        detailViewController.infoDic = item;
        detailViewController.videoType = SHOW_TYPE; 
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
    self.pageControl.currentPage = page;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
