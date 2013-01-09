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
#import "MediaPlayerViewController.h"
#import "ProgramViewController.h"
#import "UIImage+Scale.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "ProgramNavigationController.h"
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
    [self.navigationController.navigationBar setBackgroundImage:[UIImage scaleFromImage:[UIImage imageNamed:@"top_bg_common.png"] toSize:CGSizeMake(320, 44)] forBarMetrics:UIBarMetricsDefault];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 40, 30);
    backButton.backgroundColor = [UIColor clearColor];
    [backButton setImage:[UIImage imageNamed:@"top_return_common.png"]forState:UIControlStateNormal];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
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
    if (type_ == 0) {
        cell.textLabel.text = [infoDic objectForKey:@"name"];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        [cell.titleLab removeFromSuperview];
        [cell.actors removeFromSuperview];
        
        [cell.date removeFromSuperview];
        cell.play.tag = indexPath.row;
        [cell.play addTarget:self action:@selector(continuePlay:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if (type_ == 1) {
        cell.titleLab.text = [infoDic objectForKey:@"content_name"];
        cell.actors.text =[NSString stringWithFormat:@"主演：%@",[infoDic objectForKey:@"stars"]] ;
        cell.date.text = [NSString stringWithFormat:@"年代：%@",[infoDic objectForKey:@"publish_date"]];
        [cell.play removeFromSuperview];
    }
    else if (type_ == 2){
        NSDictionary *item = [(NSMutableArray *)[infoDic objectForKey:@"items"] objectAtIndex:0];
        cell.titleLab.text = [infoDic objectForKey:@"name"];
        cell.actors.text = [item objectForKey:@"prod_name"];
        cell.date.text = @"...";
        [cell.play removeFromSuperview];
    
    }
    
    
    return cell;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (type_ == 2){
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete){
        NSDictionary *infoDic = [listArr_ objectAtIndex:indexPath.row];
        NSString *topicId = [infoDic objectForKey:@"topic_id"];
        
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:topicId, @"topic_id", nil];
        [[AFServiceAPIClient sharedClient] postPath:kPathTopDelete parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            NSString *responseCode = [result objectForKey:@"res_code"];
            if([responseCode isEqualToString:kSuccessResCode]){
                [listArr_ removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
            else {
                [UIUtility showSystemError:self.view];
            }
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            [UIUtility showSystemError:self.view];
        }];
           
    }
}

-(void)continuePlay:(id)sender{
    int num = ((UIButton *)sender).tag;
    NSDictionary *item = [listArr_ objectAtIndex:num];
    if([[item objectForKey:@"play_type"] isEqualToString:@"1"]){
        MediaPlayerViewController *viewController = [[MediaPlayerViewController alloc]initWithNibName:@"MediaPlayerViewController" bundle:nil];
        viewController.videoUrl = [item objectForKey:@"videoUrl"];
        viewController.type = [[NSString stringWithFormat:@"%@", [item objectForKey:@"type"]] integerValue];
        viewController.name = [item objectForKey:@"name"];
        viewController.subname = [item objectForKey:@"subname"];
        [self presentViewController:viewController animated:YES completion:nil];
    } else {
        ProgramViewController *viewController = [[ProgramViewController alloc]initWithNibName:@"ProgramViewController" bundle:nil];
        viewController.programUrl = [item objectForKey:@"videoUrl"];
        viewController.title = [item objectForKey:@"name"];
        viewController.subname = [item objectForKey:@"subname"];
        viewController.type = [[NSString stringWithFormat:@"%@", [item objectForKey:@"type"]] integerValue];
        viewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        ProgramNavigationController *pro = [[ProgramNavigationController alloc] initWithRootViewController:viewController];
        [self presentViewController:pro animated:YES completion:nil];
       // [self presentViewController:[[UINavigationController alloc] initWithRootViewController:viewController] animated:YES completion:nil];
    }
  
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
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
