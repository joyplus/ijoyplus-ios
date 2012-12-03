//
//  ListViewController.m
//  yueshipin_ipad
//
//  Created by zhang zhipeng on 12-11-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "CollectionListViewController.h"
#import "MovieDetailViewController.h"
#import "DramaDetailViewController.h"
#import "ShowDetailViewController.h"

@interface CollectionListViewController (){
    UITableView *table;
    UIImageView *bgImage;
    UIImageView *titleImage;
    NSMutableArray *videoArray;
}

@end

@implementation CollectionListViewController

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
    titleImage.image = [UIImage imageNamed:@"collect_title"];
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
    if(videoArray.count > 0){        
    } else {
        [self retrieveTopsListData];        
    }
}


- (void)retrieveTopsListData
{       
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:@"my_collection_list"];
    if(cacheResult != nil){
        [self parseVideoData:cacheResult];
    }
    if([[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%i", 1], @"page_num", @"30", @"page_size", nil];
        [[AFServiceAPIClient sharedClient] getPath:kPathUserFavorities parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
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
        NSArray *videos = [result objectForKey:@"favorities"];
        if(videos != nil && videos.count > 0){
            [[CacheUtility sharedCache] putInCache:@"my_collection_list" result:result];
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
        imageView.image = [UIImage imageNamed:@"movie_frame"];
        [cell.contentView addSubview:imageView];
        
        UIImageView *contentImage = [[UIImageView alloc]initWithFrame:CGRectMake(44, 12, 94, 138)];
        contentImage.image = [UIImage imageNamed:@"test_movie"];
        contentImage.tag = 1001;
        [cell.contentView addSubview:contentImage];
        
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(160, 12, 306, 25)];
        nameLabel.text = @"暮光之城";
        nameLabel.font = [UIFont boldSystemFontOfSize:20];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.tag = 2001;
        [cell.contentView addSubview:nameLabel];
        
//        for (int i = 0; i < 5; i++){
//            UIImageView *startImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"empty_star"]];
//            startImage.frame = CGRectMake(160 + (16 + 5) * i, 48, 16, 16);
//            startImage.tag = 3001 + i;
//            [cell.contentView addSubview:startImage];
//        }
        
        UILabel *scoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(160, 45, 45, 20)];
        scoreLabel.tag = 3001;
        scoreLabel.text = @"0 分";
        scoreLabel.backgroundColor = [UIColor clearColor];
        scoreLabel.font = [UIFont boldSystemFontOfSize:15];
        scoreLabel.textColor = CMConstants.textBlueColor;
        [cell.contentView addSubview:scoreLabel];
        UIImageView *doubanLogo = [[UIImageView alloc]initWithFrame:CGRectMake(210, 50, 15, 15)];
        doubanLogo.image = [UIImage imageNamed:@"douban"];
        [cell.contentView addSubview:doubanLogo];
        
        UILabel *directorLabel = [[UILabel alloc]initWithFrame:CGRectMake(160, 75, 150, 25)];
        directorLabel.text = @"导演：";
        [directorLabel sizeToFit];
        directorLabel.font = [UIFont systemFontOfSize:13];
        directorLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:directorLabel];
        
        UILabel *directorNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(205, 75, 180, 25)];
        directorNameLabel.font = [UIFont boldSystemFontOfSize:13];
        directorNameLabel.backgroundColor = [UIColor clearColor];
        directorNameLabel.tag = 4001;
        [cell.contentView addSubview:directorNameLabel];
        
        UILabel *actorLabel = [[UILabel alloc]initWithFrame:CGRectMake(160, 100, 150, 25)];
        actorLabel.text = @"主演：";
        [actorLabel sizeToFit];
        actorLabel.font = [UIFont systemFontOfSize:13];
        actorLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:actorLabel];
        
        UILabel *actorName1Label = [[UILabel alloc]initWithFrame:CGRectMake(205, 100, 180, 25)];
        actorName1Label.font = [UIFont systemFontOfSize:13];
        actorName1Label.backgroundColor = [UIColor clearColor];
        actorName1Label.tag = 5001;
        [cell.contentView addSubview:actorName1Label];
        
        
        UIImageView *dingNumberImage = [[UIImageView alloc]initWithFrame:CGRectMake(160, 130, 75, 24)];
        dingNumberImage.image = [UIImage imageNamed:@"pushinguser"];
        [cell.contentView addSubview:dingNumberImage];
        
        UILabel *dingNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(165, 130, 40, 24)];
        dingNumberLabel.textAlignment = NSTextAlignmentCenter;
        dingNumberLabel.backgroundColor = [UIColor clearColor];
        dingNumberLabel.font = [UIFont systemFontOfSize:13];
        dingNumberLabel.tag = 6001;
        [cell.contentView addSubview:dingNumberLabel];
        
        UIImageView *collectioNumber = [[UIImageView alloc]initWithFrame:CGRectMake(250, 130, 84, 24)];
        collectioNumber.image = [UIImage imageNamed:@"collectinguser"];
        [cell.contentView addSubview:collectioNumber];
        
        UILabel *collectionNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(255, 130, 40, 24)];
        collectionNumberLabel.textAlignment = NSTextAlignmentCenter;
        collectionNumberLabel.backgroundColor = [UIColor clearColor];
        collectionNumberLabel.font = [UIFont systemFontOfSize:13];
        collectionNumberLabel.tag = 7001;
        [cell.contentView addSubview:collectionNumberLabel];
        
        UIImageView *devidingLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, 158, table.frame.size.width, 2)];
        devidingLine.image = [UIImage imageNamed:@"dividing"];
        [cell.contentView addSubview:devidingLine];        
    }
    NSDictionary *item = [videoArray objectAtIndex:indexPath.row];
    UIImageView *contentImage = (UIImageView *)[cell viewWithTag:1001];
    [contentImage setImageWithURL:[NSURL URLWithString:[item objectForKey:@"content_pic_url"]] placeholderImage:[UIImage imageNamed:@""]];
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:2001];
    nameLabel.text = [item objectForKey:@"content_name"];
    
    UILabel *directorNameLabel = (UILabel *)[cell viewWithTag:5001];
    directorNameLabel.text = [item objectForKey:@"directors"];
    
    UILabel *actorLabel = (UILabel *)[cell viewWithTag:4001];
    actorLabel.text = [item objectForKey:@"stars"];
    
    UILabel *scoreLabel = (UILabel *)[cell viewWithTag:3001];
    scoreLabel.text = [NSString stringWithFormat:@"%@ 分", [item objectForKey:@"score"]];
    
    UILabel *dingNumberLabel = (UILabel *)[cell viewWithTag:6001];
    dingNumberLabel.text = [NSString stringWithFormat:@"%@", [item objectForKey:@"support_num"]];
    
    UILabel *collectionNumberLabel = (UILabel *)[cell viewWithTag:7001];
    collectionNumberLabel.text = [NSString stringWithFormat:@"%@", [item objectForKey:@"favority_num"]];
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 160;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"commitEditingStyle");
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [videoArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    
}
 

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [table deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *item = [videoArray objectAtIndex:indexPath.row];
    NSString *type = [NSString stringWithFormat:@"%@", [item objectForKey:@"content_type"]];
    NSString *prodId = [NSString stringWithFormat:@"%@", [item objectForKey:@"content_id"]];
    if([type isEqualToString:@"1"]){
        MovieDetailViewController *viewController = [[MovieDetailViewController alloc] initWithNibName:@"MovieDetailViewController" bundle:nil];
        viewController.prodId = prodId;
        viewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:NO];
    } else if([type isEqualToString:@"2"]){
        DramaDetailViewController *viewController = [[DramaDetailViewController alloc] initWithNibName:@"DramaDetailViewController" bundle:nil];
        viewController.prodId = prodId;
        viewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:NO];
    } else {
        ShowDetailViewController *viewController = [[ShowDetailViewController alloc] initWithNibName:@"ShowDetailViewController" bundle:nil];
        viewController.prodId = prodId;
        viewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:NO];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
