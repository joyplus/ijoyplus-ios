//
//  allListViewController.m
//  yueshipin
//
//  Created by 08 on 12-12-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "allListViewController.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "AllListViewCell.h"
#import "UIImageView+WebCache.h"
#import "ListDetailViewController.h"
#import "MBProgressHUD.h"
#import "CacheUtility.h"
#import "IphoneSettingViewController.h"
#import "SearchPreViewController.h"
#define pageSize 20
#define MOVIE_TYPE 9001
@interface allListViewController ()

@end

@implementation allListViewController
@synthesize listArray = listArray_;
@synthesize tableList = tableList_;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)parseTopsListData:(id)result
{
    self.listArray = [[NSMutableArray alloc]initWithCapacity:pageSize];
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        NSArray *tempTopsArray = [result objectForKey:@"tops"];
        if(tempTopsArray.count > 0){
           [[CacheUtility sharedCache] putInCache:@"top_list" result:result];
            [ self.listArray addObjectsFromArray:tempTopsArray];
        }
    }
    else {
      
    }
    
    [self.tableList reloadData];
}


-(void)loadData{
    MBProgressHUD *tempHUD;
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:@"top_list"];
    if(cacheResult != nil){
        [self parseTopsListData:cacheResult];
    } else {
        if(tempHUD == nil){
            tempHUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:tempHUD];
            tempHUD.labelText = @"加载中...";
            tempHUD.opacity = 0.5;
            [tempHUD show:YES];
        }
    }

    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: @"1", @"page_num", [NSNumber numberWithInt:pageSize], @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathTops parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        [self parseTopsListData:result];
        [tempHUD hide:YES];
        
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        if(self.listArray == nil){
            self.listArray = [[NSMutableArray alloc]initWithCapacity:10];
        }
        [tempHUD hide:YES];
    }];


}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"悦单";
    UIBarButtonItem * leftButton = [[UIBarButtonItem alloc]
                                     
                                     initWithTitle:@"搜素"
                                     
                                     style:UIBarButtonItemStyleDone
                                     
                                     target:self
                                     
                                     action:@selector(search:)];
    leftButton.image=[UIImage imageNamed:@"left_button.png"];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    UIBarButtonItem * rightButton = [[UIBarButtonItem alloc]
                                     
                                     initWithTitle:@"设置"
                                     
                                     style:UIBarButtonItemStyleDone
                                     
                                     target:self
                                     
                                     action:@selector(setting:)];
    rightButton.image=[UIImage imageNamed:@"right_button.png"];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    self.tableList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 380) style:UITableViewStylePlain];
    self.tableList.dataSource = self;
    self.tableList.delegate = self;
    self.tableList.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableList];
    [self loadData];
}

-(void)search:(id)sender{
    SearchPreViewController *searchViewCotroller = [[SearchPreViewController alloc] init];
    [self.navigationController pushViewController:searchViewCotroller animated:YES];

}

-(void)setting:(id)sender{
    IphoneSettingViewController *iphoneSettingViewController = [[IphoneSettingViewController alloc] init];
    [self.navigationController pushViewController:iphoneSettingViewController animated:YES];

}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.listArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    AllListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[AllListViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];   
    }
    NSDictionary *item = [self.listArray objectAtIndex:indexPath.row];
    NSMutableArray *items = [item objectForKey:@"items"];
    cell.label.text = [item objectForKey:@"name"];
    cell.label1.text = [[items objectAtIndex:0] objectForKey:@"prod_name" ];
    cell.label2.text = [[items objectAtIndex:1] objectForKey:@"prod_name" ];
    cell.label3.text = [[items objectAtIndex:2] objectForKey:@"prod_name" ];
    cell.label4.text = [[items objectAtIndex:3] objectForKey:@"prod_name" ];
    cell.label5.text = [[items objectAtIndex:4] objectForKey:@"prod_name" ];
    [cell.imageView setImageWithURL:[NSURL URLWithString:[item objectForKey:@"pic_url"]] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 130;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *item = [self.listArray objectAtIndex:indexPath.row];
    NSMutableArray *items = [item objectForKey:@"items"];
    ListDetailViewController *listDetailViewController = [[ListDetailViewController alloc] initWithStyle:UITableViewStylePlain];
    listDetailViewController.listArr = items;
    listDetailViewController.Type = MOVIE_TYPE;
    [self.navigationController pushViewController:listDetailViewController animated:YES];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
