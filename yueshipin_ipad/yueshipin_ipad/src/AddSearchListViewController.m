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
#import "CreateListTwoViewController.h"

@interface AddSearchListViewController (){
    UITableView *table;
    UIImageView *titleImage;
    NSMutableArray *videoArray;
    NSMutableSet *checkboxes;
    UIButton *closeBtn;
    UIButton *addBtn;
    UIImageView *lineImage;
    MNMBottomPullToRefreshManager *pullToRefreshManager_;
    NSUInteger reloads_;
    int pageSize;
    UIButton *doneBtn;
}

@end

@implementation AddSearchListViewController
@synthesize keyword;
@synthesize topId;
@synthesize backToViewController;
@synthesize type;

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.keyword = nil;
    self.topId = nil;
    table = nil;
    titleImage = nil;
    [videoArray removeAllObjects];
    videoArray = nil;
    [checkboxes removeAllObjects];
    checkboxes = nil;
    closeBtn = nil;
    addBtn = nil;
    lineImage = nil;
    pullToRefreshManager_ = nil;
}

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
    self.bgImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.frame.size.height)];
    self.bgImage.image = [UIImage imageNamed:@"left_background@2x.jpg"];
    [self.view addSubview:self.bgImage];

    titleImage = [[UIImageView alloc]initWithFrame:CGRectMake(LEFT_WIDTH, 35, 107, 26)];
    titleImage.image = [UIImage imageNamed:@"add_video_title"];
    [self.view addSubview:titleImage];
    
    closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(456, 0, 50, 50);
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
    [closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    
    addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(LEFT_WIDTH, 80, 62, 31);
    [addBtn setBackgroundImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [addBtn setBackgroundImage:[UIImage imageNamed:@"add_pressed"] forState:UIControlStateHighlighted];
    [addBtn addTarget:self action:@selector(addBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [addBtn setHidden:YES];
    [self.view addSubview:addBtn];
    
    doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.frame = CGRectMake(addBtn.frame.origin.x + 72, 80, 62, 31);
    [doneBtn setBackgroundImage:[UIImage imageNamed:@"finish"] forState:UIControlStateNormal];
    [doneBtn setBackgroundImage:[UIImage imageNamed:@"finish_pressed"] forState:UIControlStateHighlighted];
    [doneBtn addTarget:self action:@selector(doneBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [doneBtn setHidden:YES];
    [self.view addSubview:doneBtn];
    
    table = [[UITableView alloc]initWithFrame:CGRectMake(LEFT_WIDTH, 120, 420, 580)];
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor = [UIColor clearColor];
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.showsVerticalScrollIndicator = NO;
    [self.view addSubview:table];
    
    checkboxes = [[NSMutableSet alloc]initWithCapacity:10];
    reloads_ = 2;
    pageSize = 10;
    pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:480.0f tableView:table withClient:self];
    [self loadTable];
    
    [self.view addGestureRecognizer:self.swipeRecognizer];
}

- (void)loadTable {
    [table reloadData];
    [pullToRefreshManager_ tableViewReloadFinished];
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
    [myHUD showProgressBar:self.view];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:self.keyword, @"keyword", @"1", @"page_num", [NSNumber numberWithInt:pageSize], @"page_size", [NSString stringWithFormat:@"%d", self.type], @"type", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathSearch parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        videoArray = [[NSMutableArray alloc]initWithCapacity:10];
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *searchResult = [result objectForKey:@"results"];
            if(searchResult != nil && searchResult.count > 0){
                [videoArray addObjectsFromArray:searchResult];
            }
            if(searchResult.count < pageSize){
                [pullToRefreshManager_ setPullToRefreshViewVisible:NO];
            }
        }
        if(videoArray.count > 0){
            [addBtn setHidden:NO];
            [doneBtn setHidden:NO];
        }
        [self loadTable];
        [myHUD hide];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        videoArray = [[NSMutableArray alloc]initWithCapacity:10];
        [myHUD hide];
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
    if(videoArray == nil){
        return 0;
    }
    if(videoArray.count == 0){
        return 1;
    }
    return videoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(videoArray.count > 0){
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(40, 8, 102, 146)];
            imageView.image = [UIImage imageNamed:@"movie_frame"];
            [cell.contentView addSubview:imageView];
            
            UIImageView *contentImage = [[UIImageView alloc]initWithFrame:CGRectMake(44, 12, 94, 138)];
            contentImage.tag = 1001;
            [cell.contentView addSubview:contentImage];
            
            UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(160, 12, 306, 25)];
            nameLabel.text = @"";
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
            scoreLabel.backgroundColor = [UIColor clearColor];
            scoreLabel.font = [UIFont boldSystemFontOfSize:15];
            scoreLabel.textColor = CMConstants.scoreBlueColor;
            [cell.contentView addSubview:scoreLabel];
            UIImageView *doubanLogo = [[UIImageView alloc]initWithFrame:CGRectMake(210, 50, 15, 15)];
            doubanLogo.image = [UIImage imageNamed:@"douban"];
            [cell.contentView addSubview:doubanLogo];
            
            UILabel *directorLabel = [[UILabel alloc]initWithFrame:CGRectMake(160, 75, 150, 25)];
            directorLabel.text = @"导演：";
            directorLabel.font = [UIFont systemFontOfSize:13];
            directorLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:directorLabel];
            
            UILabel *directorNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(205, 75, 200, 25)];
            directorNameLabel.font = [UIFont systemFontOfSize:13];
            directorNameLabel.backgroundColor = [UIColor clearColor];
            directorNameLabel.tag = 4001;
            [cell.contentView addSubview:directorNameLabel];
            
            UILabel *actorLabel = [[UILabel alloc]initWithFrame:CGRectMake(160, 100, 150, 25)];
            actorLabel.text = @"主演：";
            actorLabel.font = [UIFont systemFontOfSize:13];
            actorLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:actorLabel];
            
            UILabel *actorName1Label = [[UILabel alloc]initWithFrame:CGRectMake(205, 100, 200, 25)];
            actorName1Label.font = [UIFont systemFontOfSize:13];
            actorName1Label.backgroundColor = [UIColor clearColor];
            actorName1Label.tag = 5001;
            [cell.contentView addSubview:actorName1Label];
            
            
            UIImageView *dingNumberImage = [[UIImageView alloc]initWithFrame:CGRectMake(160, 130, 16, 16)];
            dingNumberImage.image = [UIImage imageNamed:@"pushinguser"];
            [cell.contentView addSubview:dingNumberImage];
            
            UILabel *dingNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(185, 125, 40, 24)];
            dingNumberLabel.backgroundColor = [UIColor clearColor];
            dingNumberLabel.font = [UIFont systemFontOfSize:13];
            dingNumberLabel.tag = 6001;
            [cell.contentView addSubview:dingNumberLabel];
            
            UIImageView *collectioNumber = [[UIImageView alloc]initWithFrame:CGRectMake(250, 130, 16, 16)];
            collectioNumber.image = [UIImage imageNamed:@"collectinguser"];
            [cell.contentView addSubview:collectioNumber];
            
            UILabel *collectionNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(275, 125, 40, 24)];
            collectionNumberLabel.backgroundColor = [UIColor clearColor];
            collectionNumberLabel.font = [UIFont systemFontOfSize:13];
            collectionNumberLabel.tag = 7001;
            [cell.contentView addSubview:collectionNumberLabel];
            
            UIImageView *devidingLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, 158, table.frame.size.width, 2)];
            devidingLine.image = [UIImage imageNamed:@"dividing"];
            [cell.contentView addSubview:devidingLine];
            
            SSCheckBoxView *checkbox = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(0, 65, 40, 40) style:kSSCheckBoxViewStyleBox checked:NO];
            checkbox.tag = 8001;
            [checkbox setStateChangedTarget:self selector:@selector(checkBoxViewChangedState:)];
            [cell.contentView addSubview:checkbox];
        }
        NSDictionary *item = [videoArray objectAtIndex:indexPath.row];
        UIImageView *contentImage = (UIImageView *)[cell viewWithTag:1001];
        [contentImage setImageWithURL:[NSURL URLWithString:[item objectForKey:@"prod_pic_url"]] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
        
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
        
        UILabel *scoreLabel = (UILabel *)[cell viewWithTag:3001];
        scoreLabel.text = [NSString stringWithFormat:@"%@ 分", [item objectForKey:@"score"]];
        
        UILabel *dingNumberLabel = (UILabel *)[cell viewWithTag:6001];
        dingNumberLabel.text = [NSString stringWithFormat:@"%@", [item objectForKey:@"support_num"]];
        
        UILabel *collectionNumberLabel = (UILabel *)[cell viewWithTag:7001];
        collectionNumberLabel.text = [NSString stringWithFormat:@"%@", [item objectForKey:@"favority_num"]];
        
        return cell;
    } else {
        static NSString *noRecordCellIdentifier = @"noRecordCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:noRecordCellIdentifier];
        if(cell == nil){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:noRecordCellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(140, 0, 300, 40)];
            [label setBackgroundColor:[UIColor clearColor]];
            label.textColor = CMConstants.grayColor;
            label.font = [UIFont systemFontOfSize: 16];
            if (self.type == 1) {
                label.text = @"很抱歉，没有找到相关电影！";
            } else if (self.type == 2) {
                label.text = @"很抱歉，没有找到相关电视剧！";
            } else {
                label.text = @"很抱歉，没有找到相关影片！";
            }
            [cell.contentView addSubview:label];
        }
        return cell;
    }
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
    //    [table deselectRowAtIndexPath:indexPath animated:YES];
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

- (void)addBtnClicked
{
    NSMutableString *prodIds = [[NSMutableString alloc]init];
    for(NSString *idStr in checkboxes){
        [prodIds appendFormat:@"%@,", idStr];
    }
    NSString *prodIdStr;
    if(prodIds.length > 0){
        prodIdStr = [prodIds substringToIndex:prodIds.length - 1];
    } else {
        return;
    }
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: self.topId, @"topic_id", prodIdStr, @"prod_id", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathAddItem parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if([responseCode isEqualToString:kSuccessResCode]){
            [[AppDelegate instance].rootViewController showSuccessModalView:2];
            [[NSNotificationCenter defaultCenter] postNotificationName:MY_LIST_VIEW_REFRESH object:nil];
//            [[NSNotificationCenter defaultCenter] postNotificationName:PERSONAL_VIEW_REFRESH object:nil];
        } else {
            [[AppDelegate instance].rootViewController showFailureModalView:1.5];
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        [UIUtility showSystemError:self.view];
    }];
}

- (void)doneBtnClicked
{
    [[AppDelegate instance].rootViewController.stackScrollViewController removeViewToViewInSlider:self.backToViewController.class];
}

#pragma mark -
#pragma mark MNMBottomPullToRefreshManagerClient

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [pullToRefreshManager_ tableViewScrolled];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [pullToRefreshManager_ tableViewReleased];
}

- (void)MNMBottomPullToRefreshManagerClientReloadTable {
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [UIUtility showNetWorkError:self.view];
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:2.0f];
        return;
    }
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:self.keyword, @"keyword", [NSNumber numberWithInt:reloads_], @"page_num", [NSNumber numberWithInt:pageSize], @"page_size", [NSString stringWithFormat:@"%d", self.type], @"type", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathSearch parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        NSArray *tempArray;
        if(responseCode == nil){
            tempArray = [result objectForKey:@"results"];
            if(tempArray.count > 0){
                [videoArray addObjectsFromArray:tempArray];
                reloads_ ++;
            }
        } else {
            
        }
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:0.0f];
        if(tempArray.count < pageSize){
            [pullToRefreshManager_ setPullToRefreshViewVisible:NO];
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:0.0f];
    }];
}
@end
