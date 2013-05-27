//
//  IphoneSearchViewController.m
//  yueshipin
//
//  Created by 08 on 12-12-27.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "IphoneSearchViewController.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "MBProgressHUD.h"
#import "ListDetailViewCell.h"
#import "UIImageView+WebCache.h"
#import "IphoneMovieDetailViewController.h"
#import "TVDetailViewController.h"
#import "IphoneShowDetailViewController.h"
#import "UIImage+Scale.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>  
#import "Reachability.h"
#define PAGESIZE 20
@interface IphoneSearchViewController ()

@end

@implementation IphoneSearchViewController
@synthesize searchBar = searchBar_;
@synthesize searchResults = searchResults_;
@synthesize tableList = tableList_;
@synthesize keyWords = keyWords_;
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
    self.title = @"搜索";
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_common.png"]];
    bg.frame = CGRectMake(0, 0, 320, kFullWindowHeight);
    [self.view addSubview:bg];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 49, 30);
    backButton.backgroundColor = [UIColor clearColor];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"back_f.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    searchBar_ = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    searchBar_.delegate = self;
    searchBar_.text = self.keyWords;
    searchBar_.tintColor = [UIColor whiteColor];
    searchBar_.placeholder = @"电影/电视剧/综艺";
    UITextField *searchField;
    NSUInteger numViews = [searchBar_.subviews count];
    for(int i = 0; i < numViews; i++) {
        if([[searchBar_.subviews objectAtIndex:i] isKindOfClass:[UITextField class]]) {
            searchField = [searchBar_.subviews objectAtIndex:i];
        }
    }
    if(!(searchField == nil)) {
        [searchField.leftView setHidden:YES];
        [searchField setBackground: [UIImage imageNamed:@"my_search_sou_suo_kuang.png"] ];
        [searchField setBorderStyle:UITextBorderStyleNone];
    }

    [self.view addSubview:searchBar_];
    
    tableList_ = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, kCurrentWindowHeight-88) style:UITableViewStylePlain];
    tableList_.dataSource = self;
    tableList_.delegate = self;
    tableList_.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableList_];
    
    [self loadSearchData];
}

-(void)back:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)loadSearchData{
   // Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [UIUtility showNetWorkError:self.view];
        return;
    }
    
    MBProgressHUD  *tempHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:tempHUD];
    tempHUD.labelText = @"加载中...";
    tempHUD.opacity = 0.5;
    [tempHUD show:YES];
    NSString *searchKey = [searchBar_.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:searchKey, @"keyword", @"1", @"page_num", [NSNumber numberWithInt:PAGESIZE], @"page_size", @"1,2,3,131", @"type", nil];
    
    [[AFServiceAPIClient sharedClient] postPath:kPathSearch parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        searchResults_ = [[NSMutableArray alloc]initWithCapacity:10];
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *searchResult = [result objectForKey:@"results"];
            if(searchResult != nil && searchResult.count > 0){
                [searchResults_ addObjectsFromArray:searchResult];
            }
            else{
                [self showFailureView:1];
            
            }
         }
        
        [tableList_ reloadData];
        [tempHUD hide:YES];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        searchResults_ = [[NSMutableArray alloc]initWithCapacity:10];
        [tempHUD hide:YES];
        [UIUtility showDetailError:self.view error:error];
    }];


}
- (void)showFailureView:(float)closeTime
{

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
    label.backgroundColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:13];
    label.text = @"抱歉，未找到相关影片！";
    label.textColor = [UIColor whiteColor];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.textAlignment = NSTextAlignmentCenter;
    label.center = self.view.center;
    label.alpha = 0.6;
    label.layer.cornerRadius = 5;
    label.center = self.view.center;
    label.tag =19999;
    [[AppDelegate instance].window addSubview:label];
    [NSTimer scheduledTimerWithTimeInterval:closeTime target:self selector:@selector(removeOverlay) userInfo:nil repeats:NO];
}
- (void)removeOverlay
{
    for(UIView *view in [AppDelegate instance].window.subviews ){
        if (view.tag == 19999) {
            [view removeFromSuperview];
            break;
        }
        
    }
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [searchResults_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
 
    static NSString *CellIdentifier = @"Cell";
    ListDetailViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ListDetailViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSDictionary *item = [searchResults_ objectAtIndex:indexPath.row];
    cell.label.text = [item objectForKey:@"prod_name"];
    cell.actors.text = [NSString stringWithFormat:@"主演：%@",[item objectForKey:@"star"]];
    cell.area.text = [NSString stringWithFormat:@"地区：%@",[item objectForKey:@"area"]];
    [cell.imageview setImageWithURL:[NSURL URLWithString:[item objectForKey:@"prod_pic_url"]] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
    NSString *supportNum = [item objectForKey:@"support_num"];
    [cell.support setTitle:[NSString stringWithFormat:@"%@",supportNum] forState:UIControlStateDisabled];
    NSString *addFavNum = [item objectForKey:@"favority_num"];
    [cell.addFav setTitle:[NSString stringWithFormat:@"%@",addFavNum] forState:UIControlStateDisabled];
    cell.score.text = [NSString stringWithFormat:@"%@",[item objectForKey:@"score"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
    NSDictionary *item = [searchResults_ objectAtIndex:indexPath.row];
    NSString *typeStr = [item objectForKey:@"prod_type"];
    if ([typeStr isEqualToString:@"1"]) {
        IphoneMovieDetailViewController *detailViewController = [[IphoneMovieDetailViewController alloc] init];
        detailViewController.infoDic = [searchResults_ objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
    else if ([typeStr isEqualToString:@"2"]||[typeStr isEqualToString:@"131"]){
        TVDetailViewController *detailViewController = [[TVDetailViewController alloc] init];
        detailViewController.infoDic = [searchResults_ objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
    else if ([typeStr isEqualToString:@"3"]){
        IphoneShowDetailViewController *detailViewController = [[IphoneShowDetailViewController alloc] init];
        detailViewController.infoDic = [searchResults_ objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
 
    
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 112.0;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar_ resignFirstResponder];
    [self loadSearchData];
    [searchBar setShowsCancelButton:NO animated:YES];
//    for (id view in searchBar.subviews) {
//        if ([view isKindOfClass:[UIButton class]]) {
//            [(UIButton *)view  setBackgroundImage:[UIImage imageNamed:@"cancelSearch.png"] forState:UIControlStateNormal];
//            [(UIButton *)view setBackgroundImage:[UIImage imageNamed:@"cancelSearch_s.png"] forState:UIControlStateHighlighted];
//            [(UIButton *)view setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//            ((UIButton *)view).titleLabel.font = [UIFont systemFontOfSize:13];
//            ((UIButton *)view).enabled = YES;
//        }
//    }
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:YES animated:YES];
    for (id view in searchBar.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            [(UIButton *)view  setBackgroundImage:[UIImage imageNamed:@"cancelSearch.png"] forState:UIControlStateNormal];
            [(UIButton *)view setBackgroundImage:[UIImage imageNamed:@"cancelSearch_s.png"] forState:UIControlStateHighlighted];
            [(UIButton *)view setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            ((UIButton *)view).titleLabel.font = [UIFont systemFontOfSize:13];
        }
    }

    
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    [searchBar setShowsCancelButton:NO animated:NO];
    [searchBar resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
