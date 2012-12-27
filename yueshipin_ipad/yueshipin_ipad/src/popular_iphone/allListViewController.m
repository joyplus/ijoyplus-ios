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
#define pageSize 20
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
           
            [ self.listArray addObjectsFromArray:tempTopsArray];
        }
    }
    else {
      
    }
    
    [self.tableList reloadData];
}


-(void)loadData{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: @"1", @"page_num", [NSNumber numberWithInt:pageSize], @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathTops parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        [self parseTopsListData:result];
        
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        if(self.listArray == nil){
            self.listArray = [[NSMutableArray alloc]initWithCapacity:10];
        }
    }];


}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"悦单";
	
    [self loadData];
    
    self.tableList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 380) style:UITableViewStylePlain];
    self.tableList.dataSource = self;
    self.tableList.delegate = self;
    [self.view addSubview:self.tableList];
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
    NSDictionary *test = [items objectAtIndex:0] ;
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
    [self.navigationController pushViewController:listDetailViewController animated:YES];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
