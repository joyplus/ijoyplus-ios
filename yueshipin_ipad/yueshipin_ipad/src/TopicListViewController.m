//
//  ListViewController.m
//  yueshipin_ipad
//
//  Created by zhang zhipeng on 12-11-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "TopicListViewController.h"
#import "MovieDetailViewController.h"
#import "DramaDetailViewController.h"
#import "ShowDetailViewController.h"
#import "ListViewController.h"
#import "MyListViewController.h"


@interface TopicListViewController (){
    UITableView *table;
    UIImageView *bgImage;
    UIImageView *titleImage;
    NSMutableArray *videoArray;
}

@end

@implementation TopicListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    bgImage = [[UIImageView alloc]initWithFrame:self.view.frame];
    bgImage.image = [UIImage imageNamed:@"detail_bg"];
    [self.view addSubview:bgImage];
    
    titleImage = [[UIImageView alloc]initWithFrame:CGRectMake(50, 35, 62, 26)];
    titleImage.image = [UIImage imageNamed:@"list_title"];
    [self.view addSubview:titleImage];
    
    table = [[UITableView alloc]initWithFrame:CGRectMake(25, 70, 460, self.view.frame.size.height - 350)];
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor = [UIColor clearColor];
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.showsVerticalScrollIndicator = NO;
    [self.view addSubview:table];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self retrieveTopsListData];        
}


- (void)retrieveTopsListData
{       
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:@"my_topic_list"];
    if(cacheResult != nil){
        [self parseVideoData:cacheResult];
    }
    if([[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%i", 1], @"page_num", @"30", @"page_size", nil];
        [[AFServiceAPIClient sharedClient] getPath:kPathUserTopics parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [self parseVideoData:result];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
            [videoArray removeAllObjects];
            [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_MB_PROGRESS_BAR object:self userInfo:nil];
        }];
    }
}

- (void)parseVideoData:(id)result
{
    videoArray = [[NSMutableArray alloc]initWithCapacity:10];
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        NSArray *videos = [result objectForKey:@"tops"];
        if(videos != nil && videos.count > 0){
            [[CacheUtility sharedCache] putInCache:@"my_topic_list" result:result];
            [videoArray addObjectsFromArray:videos];
        }
    }
    [table reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_MB_PROGRESS_BAR object:self userInfo:nil];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return videoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(40, 8, 102, 146)];
        imageView.image = [UIImage imageNamed:@"moviecard_list"];
        [cell.contentView addSubview:imageView];
        
        UIImageView *contentImage = [[UIImageView alloc]initWithFrame:CGRectMake(50, 13, 83, 124)];
        contentImage.tag = 1001;
        [cell.contentView addSubview:contentImage];
        
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(160, 12, 306, 25)];
        nameLabel.font = [UIFont boldSystemFontOfSize:18];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.tag = 2001;
        [cell.contentView addSubview:nameLabel];
        
        int posx = 165;
        UIView *dotView1 = [UIUtility getDotView:6];
        dotView1.center = CGPointMake(posx, 55);
        dotView1.tag = 3001;
        [cell.contentView addSubview:dotView1];
        
        UIView *dotView2 = [UIUtility getDotView:6];
        dotView2.center = CGPointMake(posx+140, 55);
        dotView2.tag = 3002;
        [cell.contentView addSubview:dotView2];
        
        UIView *dotView3 = [UIUtility getDotView:6];
        dotView3.center = CGPointMake(posx, 80);
        dotView3.tag = 3003;
        [cell.contentView addSubview:dotView3];
        
        UIView *dotView4 = [UIUtility getDotView:6];
        dotView4.center = CGPointMake(posx+140, 80);
        dotView4.tag = 3004;
        [cell.contentView addSubview:dotView4];
        
        UIView *dotView5 = [UIUtility getDotView:6];
        dotView5.center = CGPointMake(posx, 105);
        dotView5.tag = 3005;
        [cell.contentView addSubview:dotView5];
        
        UIView *dotView6 = [UIUtility getDotView:6];
        dotView6.center = CGPointMake(posx+140, 105);
        dotView6.tag = 3006;
        [cell.contentView addSubview:dotView6];
        
        UIView *dotView7 = [UIUtility getDotView:6];
        dotView7.center = CGPointMake(posx, 130);
        dotView7.tag = 3007;
        [cell.contentView addSubview:dotView7];
        
        for (int i = 0; i < 3; i++){
            UIView *dotView8 = [UIUtility getDotView:4];
            dotView8.center = CGPointMake(posx+140 + i * 6, 130);
            dotView8.tag = 3008 + i;
            [cell.contentView addSubview:dotView8];
        }
        
        UILabel *name1 = [[UILabel alloc]initWithFrame:CGRectMake(posx+15, 40, 110, 25)];
        name1.font =[UIFont systemFontOfSize:14];
        name1.backgroundColor = [UIColor yellowColor];
        [name1 setTextColor:[UIColor lightGrayColor]];
        name1.tag = 4001;
        [cell.contentView addSubview:name1];
        
        UILabel *name2 = [[UILabel alloc]initWithFrame:CGRectMake(posx+155, 40, 110, 25)];
        name2.font = [UIFont systemFontOfSize:14];
        name2.backgroundColor = [UIColor yellowColor];
        [name2 setTextColor:[UIColor lightGrayColor]];
        name2.tag = 4002;
        [cell.contentView addSubview:name2];
        
        UILabel *name3 = [[UILabel alloc]initWithFrame:CGRectMake(posx+15, 65, 110, 25)];
        name3.font =[UIFont systemFontOfSize:14];
        name3.backgroundColor = [UIColor yellowColor];
        [name3 setTextColor:[UIColor lightGrayColor]];
        name3.tag = 4003;
        [cell.contentView addSubview:name3];
        
        UILabel *name4 = [[UILabel alloc]initWithFrame:CGRectMake(posx+155, 65, 110, 25)];
        name4.font =[UIFont systemFontOfSize:14];
        name4.backgroundColor = [UIColor yellowColor];
        [name4 setTextColor:[UIColor lightGrayColor]];
        name4.tag = 4004;
        [cell.contentView addSubview:name4];
        
        UILabel *name5 = [[UILabel alloc]initWithFrame:CGRectMake(posx+15, 85, 110, 25)];
        name5.font =[UIFont systemFontOfSize:14];
        name5.backgroundColor = [UIColor yellowColor];
        [name5 setTextColor:[UIColor lightGrayColor]];
        name5.tag = 4005;
        [cell.contentView addSubview:name5];
        
        UILabel *name6 = [[UILabel alloc]initWithFrame:CGRectMake(posx+155, 85, 110, 25)];
        name6.font =[UIFont systemFontOfSize:14];
        name6.backgroundColor = [UIColor yellowColor];
        [name6 setTextColor:[UIColor lightGrayColor]];
        name6.tag = 4006;
        [cell.contentView addSubview:name6];
        
        UILabel *name7 = [[UILabel alloc]initWithFrame:CGRectMake(posx+15, 110, 110, 25)];
        name7.font =[UIFont systemFontOfSize:14];
        name7.backgroundColor = [UIColor yellowColor];
        [name7 setTextColor:[UIColor lightGrayColor]];
        name7.tag = 4007;
        [cell.contentView addSubview:name7];
        
        UIImageView *devidingLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, 158, table.frame.size.width, 2)];
        devidingLine.image = [UIImage imageNamed:@"dividing"];
        [cell.contentView addSubview:devidingLine];        
    }
    NSDictionary *item = [videoArray objectAtIndex:indexPath.row];
    UIImageView *contentImage = (UIImageView *)[cell viewWithTag:1001];
    [contentImage setImageWithURL:[NSURL URLWithString:[item objectForKey:@"pic_url"]] placeholderImage:[UIImage imageNamed:@""]];
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:2001];
    nameLabel.text = [item objectForKey:@"name"];

    NSArray *videos = [item objectForKey:@"items"];
    for(int i = 0; i < 7; i++){
        UIView *dotView =  (UIView *)[cell viewWithTag:3001 + i];
        UILabel *label = (UILabel *)[cell viewWithTag:4001 + i];
        if(i < videos.count){
            label.text = [[videos objectAtIndex:i] objectForKey:@"prod_name"];
        } else {
            label.text = @"";
            dotView.backgroundColor = [UIColor clearColor];
        }
    }
    if(videos.count <= 7){
        for (int i = 0; i < 3; i++){
            UIView *dotView8 = (UIView *)[cell viewWithTag:3008 + i];
            dotView8.backgroundColor = [UIColor clearColor];
        }
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 160;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [table deselectRowAtIndexPath:indexPath animated:YES];
    MyListViewController *viewController = [[MyListViewController alloc] init];
    viewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    NSDictionary *item = [videoArray objectAtIndex:indexPath.row];
    NSString *topId = [NSString stringWithFormat:@"%@", [item objectForKey: @"id"]];
    viewController.topId = topId;
    viewController.listTitle = [item objectForKey: @"name"];
    [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
