//
//  MoreListViewController.m
//  yueshipin
//
//  Created by 08 on 12-12-26.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "MoreListViewController.h"
#import "RecordListCell.h"
#import "IphoneMovieDetailViewController.h"
#import "CreateMyListTwoViewController.h"

@interface MoreListViewController ()

@end

@implementation MoreListViewController
@synthesize listArr = listArr_;
@synthesize type = type_;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    if (type_ == 1) {
       self.title = @"我的收藏";  
    }
    else if (type_ == 2){
       self.title = @"我的悦单";  
        
    }

    UIBarButtonItem * leftButton = [[UIBarButtonItem alloc]
                                    
                                    initWithTitle:@"返回"
                                    
                                    style:UIBarButtonItemStyleBordered
                                    
                                    target:self
                                    
                                    action:@selector(back:)];
    leftButton.image=[UIImage imageNamed:@"top_return_common.png"];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [super viewDidLoad];

}
-(void)back:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [listArr_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    RecordListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier ];
    if (cell == nil) {
        cell = [[RecordListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSDictionary *infoDic = [listArr_ objectAtIndex:indexPath.row];
    if (type_ == 1) {
        cell.titleLab.text = [infoDic objectForKey:@"content_name"];
        cell.actors.text =[NSString stringWithFormat:@"主演：%@",[infoDic objectForKey:@"stars"]] ;
        cell.date.text = [NSString stringWithFormat:@"年代：%@",[infoDic objectForKey:@"publish_date"]];
    }
    else if (type_ == 2){
        NSDictionary *item = [(NSMutableArray *)[infoDic objectForKey:@"items"] objectAtIndex:0];
        cell.titleLab.text = [infoDic objectForKey:@"name"];
        cell.actors.text = [item objectForKey:@"prod_name"];
        cell.date.text = @"...";
    
    }
    
    
    return cell;
}


#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (type_ == 1) {
        IphoneMovieDetailViewController *detailViewController = [[IphoneMovieDetailViewController alloc] init];
        detailViewController.infoDic = [self.listArr objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
    else if (type_ == 2){
        NSDictionary *infoDic = [listArr_ objectAtIndex:indexPath.row];
        NSMutableArray *items = (NSMutableArray *)[infoDic objectForKey:@"items"];
        CreateMyListTwoViewController *createMyListTwoViewController = [[CreateMyListTwoViewController alloc] init];
        createMyListTwoViewController.listArr = items;
        [self.navigationController pushViewController:createMyListTwoViewController animated:YES];
    }
}

@end
