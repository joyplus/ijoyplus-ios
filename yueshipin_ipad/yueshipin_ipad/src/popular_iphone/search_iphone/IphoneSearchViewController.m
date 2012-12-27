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
#import "ItemDetailViewController.h"
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
    searchBar_ = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    searchBar_.delegate = self;
    searchBar_.text = self.keyWords;
    [self.view addSubview:searchBar_];
    
    tableList_ = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, 330) style:UITableViewStylePlain];
    tableList_.dataSource = self;
    tableList_.delegate = self;
    [self.view addSubview:tableList_];
    
    [self loadSearchData];
}

-(void)loadSearchData{
    MBProgressHUD  *tempHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:tempHUD];
    tempHUD.labelText = @"加载中...";
    tempHUD.opacity = 0.5;
    [tempHUD show:YES];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:searchBar_.text, @"keyword", @"1", @"page_num", [NSNumber numberWithInt:PAGESIZE], @"page_size", @"1,2", @"type", nil];
    
    [[AFServiceAPIClient sharedClient] postPath:kPathSearch parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        searchResults_ = [[NSMutableArray alloc]initWithCapacity:10];
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *searchResult = [result objectForKey:@"results"];
            if(searchResult != nil && searchResult.count > 0){
                [searchResults_ addObjectsFromArray:searchResult];
            }
         }
        
        [tableList_ reloadData];
        [tempHUD hide:YES];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        searchResults_ = [[NSMutableArray alloc]initWithCapacity:10];
        [tempHUD hide:YES];
    }];


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
    cell.support.text = [NSString stringWithFormat:@"%@人顶",supportNum];
    NSString *addFavNum = [item objectForKey:@"favority_num"];
    cell.addFav.text = [NSString stringWithFormat:@"%@人收藏",addFavNum];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ItemDetailViewController *detailViewController = [[ItemDetailViewController alloc] init];
    detailViewController.infoDic = [searchResults_ objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:detailViewController animated:YES];
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 112.0;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar_ resignFirstResponder];
    [self loadSearchData];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
