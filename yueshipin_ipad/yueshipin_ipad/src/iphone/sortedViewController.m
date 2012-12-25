//
//  sortedViewController.m
//  yueshipin
//
//  Created by 08 on 12-12-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "sortedViewController.h"
#import "SortedViewCell.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "UIImageView+WebCache.h"
#import "ListDetailViewController.h"
#define pageSize 20
@interface sortedViewController ()

@end

@implementation sortedViewController
@synthesize listArr = listArr_;
@synthesize tableList = tableList_;
@synthesize type = type_;
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
    self.listArr = [[NSMutableArray alloc]initWithCapacity:pageSize];
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        NSArray *tempTopsArray = [result objectForKey:@"tops"];
        if(tempTopsArray.count > 0){
            
            [ self.listArr addObjectsFromArray:tempTopsArray];
        }
    }
    else {
        
    }
    
    [self.tableList reloadData];
}


-(void)loadData{
    NSString *path = nil;
    if (type_ == 0) {
        path = kPathTvTops;
    }
    else if (type_ == 1){
        path = kPathMoiveTops;
    }
    else if (type_ == 2){
        path = kPathShowTops;
    }
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: @"1", @"page_num", [NSNumber numberWithInt:pageSize], @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathTvTops parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        [self parseTopsListData:result];
        
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        if(self.listArr == nil){
            self.listArr = [[NSMutableArray alloc]initWithCapacity:10];
        }
    }];
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"悦榜";
    UIImageView *typeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    typeImageView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:typeImageView];
    [self loadData];
    self.tableList = [[UITableView alloc] initWithFrame:CGRectMake(0, 30, 320, 350)];
    self.tableList.dataSource = self;
    self.tableList.delegate = self;
    [self.view addSubview:self.tableList];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return [self.listArr count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *CellIdentifier = @"Cell";
    SortedViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SortedViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSDictionary *item = [self.listArr objectAtIndex:indexPath.row];
    cell.title.text = [item objectForKey:@"name"];
    [cell.imageview setImageWithURL:[NSURL URLWithString:[item objectForKey:@"pic_url"]] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
  
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 130;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *item = [self.listArr objectAtIndex:indexPath.row];
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
