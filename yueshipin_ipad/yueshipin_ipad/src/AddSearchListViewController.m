//
//  ListViewController.m
//  yueshipin_ipad
//
//  Created by zhang zhipeng on 12-11-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "AddSearchListViewController.h"
#import "MovieDetailViewController.h"
#import "DramaDetailViewController.h"
#import "ShowDetailViewController.h"
#import "SSCheckBoxView.h"

#define LEFT_GAP 50

@interface AddSearchListViewController (){
    UITableView *table;
    UIImageView *bgImage;
    UIImageView *titleImage;
    NSMutableArray *videoArray;
    NSMutableSet *checkboxes;
    UIButton *closeBtn;
    UIButton *addBtn;
    UIImageView *lineImage;
}

@end

@implementation AddSearchListViewController
@synthesize keyword;

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
    titleImage.image = [UIImage imageNamed:@"add_video_title"];
    [self.view addSubview:titleImage];
    
    lineImage = [[UIImageView alloc]initWithFrame:CGRectMake(LEFT_GAP, 80, 400, 2)];
    lineImage.image = [UIImage imageNamed:@"dividing"];
    [self.view addSubview:lineImage];
    
    closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(470, 20, 40, 42);
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
    [closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    
    addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(LEFT_GAP, 100, 62, 39);
    [addBtn setBackgroundImage:[UIImage imageNamed:@"add_video"] forState:UIControlStateNormal];
    [addBtn setBackgroundImage:[UIImage imageNamed:@"add_video_pressed"] forState:UIControlStateHighlighted];
    [addBtn addTarget:self action:@selector(addBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addBtn];
    
    table = [[UITableView alloc]initWithFrame:CGRectMake(25, 140, 460, self.view.frame.size.height - 350)];
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor = [UIColor clearColor];
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.showsVerticalScrollIndicator = NO;
    [self.view addSubview:table];
    
    checkboxes = [[NSMutableSet alloc]initWithCapacity:10];
}

- (void)viewWillAppear:(BOOL)animated
{
    if(videoArray.count > 0){        
    } else {
        [self getResult];        
    }
}



- (void)getResult
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:self.keyword, @"keyword", @"1", @"page_num", @"10", @"page_size", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathSearch parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        videoArray = [[NSMutableArray alloc]initWithCapacity:10];
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *searchResult = [result objectForKey:@"results"];
            if(searchResult != nil && searchResult.count > 0){
                [videoArray addObjectsFromArray:searchResult];
            }
            [table reloadData];
        } else {
            
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_MB_PROGRESS_BAR object:self userInfo:nil];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        videoArray = [[NSMutableArray alloc]initWithCapacity:10];
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_MB_PROGRESS_BAR object:self userInfo:nil];
    }];
}


- (void)parseVideoData:(id)result
{
    videoArray = [[NSMutableArray alloc]initWithCapacity:10];
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        NSArray *videos = [result objectForKey:@"recommends"];
        if(videos != nil && videos.count > 0){
            [[CacheUtility sharedCache] putInCache:@"my_recommend_list" result:result];
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
        
        SSCheckBoxView *checkbox = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(10, 65, 30, 30) style:kSSCheckBoxViewStyleBox checked:NO];
        checkbox.tag = 8001;
        [checkbox setStateChangedTarget:self selector:@selector(checkBoxViewChangedState:)];
        [cell.contentView addSubview:checkbox];
    }
    NSDictionary *item = [videoArray objectAtIndex:indexPath.row];
    UIImageView *contentImage = (UIImageView *)[cell viewWithTag:1001];
    [contentImage setImageWithURL:[NSURL URLWithString:[item objectForKey:@"prod_pic_url"]] placeholderImage:[UIImage imageNamed:@""]];
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:2001];
    nameLabel.text = [item objectForKey:@"prod_name"];
    
    UILabel *directorNameLabel = (UILabel *)[cell viewWithTag:4001];
    directorNameLabel.text = [item objectForKey:@"director"];
    
    UILabel *actorLabel = (UILabel *)[cell viewWithTag:5001];
    actorLabel.text = [item objectForKey:@"star"];
    
    SSCheckBoxView *checkbox = (SSCheckBoxView *)[cell viewWithTag:8001];
    NSString *prodId = [NSString stringWithFormat:@"%@", [item objectForKey:@"prod_id"]];
    if([checkboxes containsObject:prodId]){
        [checkbox setChecked:YES];
    } else {
        [checkbox setChecked:NO];
    }
    [checkbox setValue:prodId];
    
    UILabel *scoreLabel = (UILabel *)[cell viewWithTag:4001];
    scoreLabel.text = [NSString stringWithFormat:@"%@ 分", [item objectForKey:@"score"]];
     
    UILabel *dingNumberLabel = (UILabel *)[cell viewWithTag:6001];
    dingNumberLabel.text = [NSString stringWithFormat:@"%@", [item objectForKey:@"support_num"]];
    
    UILabel *collectionNumberLabel = (UILabel *)[cell viewWithTag:7001];
    collectionNumberLabel.text = [NSString stringWithFormat:@"%@", [item objectForKey:@"favority_num"]];
    
    return cell;
}

- (void) checkBoxViewChangedState:(SSCheckBoxView *)cbv
{
    if(cbv.checked){
        if(![checkboxes containsObject:[cbv value]]){
            [checkboxes addObject:[cbv value]];
        }
    } else {
        if([checkboxes containsObject:[cbv value]]){
            [checkboxes removeObject:[cbv value]];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 160;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [table deselectRowAtIndexPath:indexPath animated:YES];
//    NSDictionary *item = [videoArray objectAtIndex:indexPath.row];
//    NSString *type = [NSString stringWithFormat:@"%@", [item objectForKey:@"prod_type"]];
//    NSString *prodId = [NSString stringWithFormat:@"%@", [item objectForKey:@"prod_id"]];
//    if([type isEqualToString:@"1"]){
//        MovieDetailViewController *viewController = [[MovieDetailViewController alloc] initWithNibName:@"MovieDetailViewController" bundle:nil];
//        viewController.prodId = prodId;
//        viewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
//        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE];
//    } else if([type isEqualToString:@"2"]){
//        DramaDetailViewController *viewController = [[DramaDetailViewController alloc] initWithNibName:@"DramaDetailViewController" bundle:nil];
//        viewController.prodId = prodId;
//        viewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
//        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE];
//    } else {
//        ShowDetailViewController *viewController = [[ShowDetailViewController alloc] initWithNibName:@"ShowDetailViewController" bundle:nil];
//        viewController.prodId = prodId;
//        viewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
//        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE];
//    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)addBtnClicked
{
    NSMutableString *prodIds = [[NSMutableString alloc]init];
    for(NSString *id in checkboxes){
        [prodIds appendFormat:@"%@,", id];
    }
    [prodIds appendString:@"0"];
    NSString *topicId = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kTopicId];
    if(topicId == nil){
        [[AppDelegate instance].rootViewController showFailureModalView:1.5];
    }
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: topicId, @"topic_id", prodIds, @"prod_id", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathAddItem parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if([responseCode isEqualToString:kSuccessResCode]){
            [[AppDelegate instance].rootViewController showSuccessModalView:1.5];
            
        } else {
            [[AppDelegate instance].rootViewController showFailureModalView:1.5];
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        [UIUtility showSystemError:self.view];
    }];
}
@end
