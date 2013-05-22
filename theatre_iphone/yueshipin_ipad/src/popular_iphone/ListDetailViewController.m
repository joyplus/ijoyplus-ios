//
//  ListDetailViewController.m
//  yueshipin
//
//  Created by 08 on 12-12-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "ListDetailViewController.h"
#import "ListDetailViewCell.h"
#import "UIImageView+WebCache.h"
#import "IphoneMovieDetailViewController.h"
#import "TVDetailViewController.h"
#import "UIImage+Scale.h"
#import "CacheUtility.h"
#import "UIUtility.h"
#import "MBProgressHUD.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "CommonMotheds.h"
#define TV_TYPE 9000
#define MOVIE_TYPE 9001
#define SHOW_TYPE 9002
@interface ListDetailViewController ()

@end

@implementation ListDetailViewController
@synthesize listArr = listArr_;
@synthesize Type = Type_;
@synthesize topicId = topicId_;
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
    [super viewDidLoad];
    UIImageView *backGround = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_common.png"]];
    backGround.frame = CGRectMake(0, 0, 320, kFullWindowHeight);
//    [self.view addSubview:backGround];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 55, 44);
    backButton.backgroundColor = [UIColor clearColor];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"back_f.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    self.navigationItem.hidesBackButton = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = backGround;
    
    listArr_ = [[NSMutableArray alloc]initWithCapacity:10];
    [self initTopicData:self.topicId];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(reFreshAddFav) name:@"REFRESH_FAV" object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(reFreshDing) name:@"REFRESH_SUPPORT" object:nil];
}

-(void)reFreshAddFav{
   
   [self initTopicData:self.topicId];
   [self.tableView reloadData];

}
-(void)reFreshDing{
   [self initTopicData:self.topicId];
   [self.tableView reloadData];
}
- (void)viewWillAppear:(BOOL)animated {

    [CommonMotheds showNetworkDisAbledAlert:self.view];
    
}
-(void)initTopicData:(NSString *)topicId{
    MBProgressHUD *tempHUD;
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:[NSString stringWithFormat:@"top_detail_list%@", self.topicId]];
    if(cacheResult != nil){
        NSString *responseCode = [cacheResult objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *tempTopsArray = [cacheResult objectForKey:@"items"];
            if(tempTopsArray.count > 0){
                [[CacheUtility sharedCache] putInCache:[NSString stringWithFormat:@"top_detail_list%@", self.topicId] result:cacheResult];
                [listArr_ removeAllObjects];
                if ([tempTopsArray count] >10) {
                    for (int i = 0; i < 10;i++) {
                        NSDictionary *dic = [tempTopsArray objectAtIndex:i];
                        [listArr_ addObject:dic];
                    }
                }
                else{
                    [listArr_ addObjectsFromArray:tempTopsArray];
                }
                
            }
            }
        else {
            [UIUtility showSystemError:self.view];
        }
        [self.tableView reloadData];
    }
    else {
        if(tempHUD == nil){
            tempHUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:tempHUD];
            tempHUD.labelText = @"加载中...";
            tempHUD.opacity = 0.5;
            [tempHUD show:YES];
        }

    }
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: @"1", @"page_num", [NSNumber numberWithInt:20], @"page_size", self.topicId, @"top_id", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathTopItems parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *tempTopsArray = [result objectForKey:@"items"];
            if(tempTopsArray.count > 0){
                [[CacheUtility sharedCache] putInCache:[NSString stringWithFormat:@"top_detail_list%@", self.topicId] result:result];
                [listArr_ removeAllObjects];
                if ([tempTopsArray count] >10) {
                    for (int i = 0; i < 10;i++) {
                        NSDictionary *dic = [tempTopsArray objectAtIndex:i];
                        [listArr_ addObject:dic];
                    }
                }
                else{
                 [listArr_ addObjectsFromArray:tempTopsArray];
                }
            }
            
        } else {
            [UIUtility showSystemError:self.view];
        }
        [tempHUD hide:YES];
        [self.tableView reloadData];

    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        [tempHUD hide:YES];
        [UIUtility showDetailError:self.view error:error];
    }];
    


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
    return [self.listArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    ListDetailViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
       cell = [[ListDetailViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];   
    }
    NSDictionary *item = [self.listArr objectAtIndex:indexPath.row];
    cell.label.text = [item objectForKey:@"prod_name"];
    cell.score.text = [NSString stringWithFormat:@"%@分",[item objectForKey:@"score"]];
    cell.actors.text = [NSString stringWithFormat:@"主演：%@",[item objectForKey:@"stars"]];
    cell.area.text = [NSString stringWithFormat:@"地区：%@",[item objectForKey:@"area"]];
    [cell.imageview setImageWithURL:[NSURL URLWithString:[item objectForKey:@"prod_pic_url"]] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
    [cell.support setTitle:[NSString stringWithFormat:@"%@",[item objectForKey:@"support_num"]] forState:UIControlStateDisabled];
    [cell.addFav setTitle:[NSString stringWithFormat:@"%@",[item objectForKey:@"favority_num"]] forState:UIControlStateDisabled];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 112.0;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [CommonMotheds showNetworkDisAbledAlert:self.view];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = [self.listArr objectAtIndex:indexPath.row];
    NSString *type = [dic objectForKey:@"prod_type"];
    if ([type isEqualToString:@"2"]||[type isEqualToString:@"131"]) {
        TVDetailViewController *detailViewController = [[TVDetailViewController alloc] init];
        detailViewController.infoDic = [self.listArr objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
    else if ([type isEqualToString:@"1"]){
        IphoneMovieDetailViewController *detailViewController = [[IphoneMovieDetailViewController alloc] init];
        detailViewController.infoDic = [self.listArr objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
    
}
-(void)back:(id)sender{

    [self.navigationController popViewControllerAnimated:YES];
}

@end
