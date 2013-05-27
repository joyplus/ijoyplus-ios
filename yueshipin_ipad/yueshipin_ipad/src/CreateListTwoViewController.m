//
//  CreateListTwoViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-28.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "CreateListTwoViewController.h"
#import "CommonHeader.h"
#import "AddSearchViewController.h"
#import "VideoDetailViewController.h"
#import "MovieDetailViewController.h"
#import "DramaDetailViewController.h"
#import "ShowDetailViewController.h"

@interface CreateListTwoViewController (){
    UIImageView *bgImage;
    UITableView *table;
    NSMutableArray *topsArray;
}

@end

@implementation CreateListTwoViewController
@synthesize titleContent;
@synthesize topId;
@synthesize type;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    self.titleContent = nil;
    self.topId = nil;
    [self setTitleLabel:nil];
    [self setAddBtn:nil];
    [self setDeleteBtn:nil];
    [self setCloseBtn:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MY_LIST_VIEW_REFRESH object:nil];
    [super viewDidUnload];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.bgImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.frame.size.height)];
    self.bgImage.image = [UIImage imageNamed:@"left_background@2x.jpg"];
    self.bgImage.layer.zPosition = -1;
    [self.view addSubview:self.bgImage];
    self.titleLabel.frame = CGRectMake(LEFT_WIDTH, 45, 310, 27);
    self.titleLabel.font = [UIFont boldSystemFontOfSize:23];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = CMConstants.textColor;
    self.titleLabel.layer.shadowColor = [UIColor colorWithRed:141/255.0 green:182/255.0 blue:213/255.0 alpha:1].CGColor;
    self.titleLabel.layer.shadowOffset = CGSizeMake(1, 1);
   
    self.closeBtn.frame = CGRectMake(456, 0, 50, 50);
    [self.closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [self.closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
    [self.closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.addBtn.frame = CGRectMake(195, 50, 100, 75);//CGRectMake(LEFT_WIDTH - 10, 90, 100, 75);
    [self.addBtn setBackgroundImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [self.addBtn setBackgroundImage:[UIImage imageNamed:@"add_pressed"] forState:UIControlStateHighlighted];
    [self.addBtn addTarget:self action:@selector(addBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.deleteBtn.frame = CGRectMake(312, 50, 140, 75);//CGRectMake(LEFT_WIDTH + self.addBtn.frame.size.width + 10, 90, 140, 75);
    [self.deleteBtn setBackgroundImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    [self.deleteBtn setBackgroundImage:[UIImage imageNamed:@"delete_pressed"] forState:UIControlStateHighlighted];
    [self.deleteBtn addTarget:self action:@selector(deleteBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    table = [[UITableView alloc]initWithFrame:CGRectMake(LEFT_WIDTH, 120, 420, self.view.frame.size.height - 415)];
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor = [UIColor clearColor];
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.showsVerticalScrollIndicator = NO;
    [self.view addSubview:table];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData:) name:MY_LIST_VIEW_REFRESH object:nil];
    
    [self.view addGestureRecognizer:self.swipeRecognizer];
}

- (void)refreshData:(NSNotification *)notification
{
    [self retrieveTopsListData];
    [table reloadData];
}


- (void)viewWillAppear:(BOOL)animated
{
    self.titleLabel.text = self.titleContent;
    [self retrieveTopsListData];  
    [MobClick beginLogPageView:CREATE_LIST_STEP2];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:CREATE_LIST_STEP2];
}

- (void)addBtnClicked
{
    AddSearchViewController *viewController = [[AddSearchViewController alloc] initWithFrame:CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.frame.size.height)];
    viewController.topId = self.topId;
    viewController.backToViewController = self;
    viewController.type = self.type;
    [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:NO];
}

- (void)deleteBtnClicked
{
    if(topsArray.count > 0)
    {
        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil
                                                           message:@"删除悦单也会同时移除悦单中的影片，确定要删除吗？"
                                                          delegate:self
                                                 cancelButtonTitle:@"取消"
                                                 otherButtonTitles:@"确定", nil];
        [alertView show];
    }
    else
    {
        [self deleteList];
    }
}


- (void)deleteList
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: self.topId, @"topic_id", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathTopDelete parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if([responseCode isEqualToString:kSuccessResCode]){
//            [[NSNotificationCenter defaultCenter] postNotificationName:PERSONAL_VIEW_REFRESH object:nil];
            [[AppDelegate instance].rootViewController showSuccessModalView:1.5];
            [[AppDelegate instance].rootViewController.stackScrollViewController removeViewInSlider];
        } else {
            [[AppDelegate instance].rootViewController showFailureModalView:1.5];
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
       [UIUtility showDetailError:self.view error:error];
    }];
}


- (void)retrieveTopsListData
{
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:[NSString stringWithFormat:@"top_detail_list%@", self.topId]];
    if(cacheResult != nil){
        [self parseTopsListData:cacheResult];
    } else {
        [myHUD showProgressBar:self.view];
    }
    if([[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: @"1", @"page_num", [NSNumber numberWithInt:10], @"page_size", self.topId, @"top_id", nil];
        [[AFServiceAPIClient sharedClient] getPath:kPathTopItems parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [self parseTopsListData:result];
            [myHUD hide];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
            topsArray = [[NSMutableArray alloc]initWithCapacity:10];
            [myHUD hide];
            [UIUtility showSystemError:self.view];
        }];
    }
}

- (void)parseTopsListData:(id)result
{
    topsArray = [[NSMutableArray alloc]initWithCapacity:10];
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        NSArray *tempTopsArray = [result objectForKey:@"items"];
        if(tempTopsArray.count > 0){
            [[CacheUtility sharedCache] putInCache:[NSString stringWithFormat:@"top_detail_list%@", self.topId] result:result];
            [topsArray addObjectsFromArray:tempTopsArray];
        }
    } else {
        [UIUtility showSystemError:self.view];
    }
    [table reloadData];
}

#pragma mark -
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex > 0)
    {
        [self deleteList];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return topsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        UIImageView *placeHolderImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, (120-NORMAL_VIDEO_HEIGHT-8) / 2, NORMAL_VIDEO_WIDTH + 8, NORMAL_VIDEO_HEIGHT+ 8)];
        placeHolderImage.image = [UIImage imageNamed:@"video_bg_placeholder"];
        [cell.contentView addSubview:placeHolderImage];
        
        UIImageView *contentImage = [[UIImageView alloc]initWithFrame:CGRectMake(4, (120-NORMAL_VIDEO_HEIGHT) / 2 + 1.5, NORMAL_VIDEO_WIDTH, NORMAL_VIDEO_HEIGHT)];
        contentImage.tag = 1001;
        [cell.contentView addSubview:contentImage];
        
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(contentImage.frame.origin.x + contentImage.frame.size.width + 20, contentImage.frame.origin.y, 250, 30)];
        nameLabel.font = CMConstants.titleFont;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.tag = 2001;
        [cell.contentView addSubview:nameLabel];
        
        UILabel *scoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(nameLabel.frame.origin.x + nameLabel.frame.size.width, nameLabel.frame.origin.y, 45, 30)];
        scoreLabel.tag = 4001;
        scoreLabel.text = @"0 分";
        scoreLabel.backgroundColor = [UIColor clearColor];
        scoreLabel.font = [UIFont boldSystemFontOfSize:15];
        scoreLabel.textColor = CMConstants.scoreBlueColor;
        scoreLabel.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:scoreLabel];
        UIImageView *doubanLogo = [[UIImageView alloc]initWithFrame:CGRectMake(scoreLabel.frame.origin.x + scoreLabel.frame.size.width, scoreLabel.frame.origin.y + 10, 15, 15)];
        doubanLogo.image = [UIImage imageNamed:@"douban"];
        [cell.contentView addSubview:doubanLogo];
        
        UILabel *directorLabel = [[UILabel alloc]initWithFrame:CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y + 30, 150, 25)];
        directorLabel.text = @"导演：";
        directorLabel.textColor = CMConstants.grayColor;
        directorLabel.font = [UIFont systemFontOfSize:13];
        directorLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:directorLabel];
        
        UILabel *directorNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(nameLabel.frame.origin.x + 40, directorLabel.frame.origin.y, 250, 25)];
        directorNameLabel.font = [UIFont systemFontOfSize:13];
        directorNameLabel.textColor = CMConstants.grayColor;
        directorNameLabel.backgroundColor = [UIColor clearColor];
        directorNameLabel.tag = 6001;
        [cell.contentView addSubview:directorNameLabel];
        
        UILabel *actorLabel = [[UILabel alloc]initWithFrame:CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y + 50, 150, 25)];
        actorLabel.text = @"主演：";
        actorLabel.textColor = CMConstants.grayColor;
        actorLabel.font = [UIFont systemFontOfSize:13];
        actorLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:actorLabel];
        
        UILabel *actorName1Label = [[UILabel alloc]initWithFrame:CGRectMake(nameLabel.frame.origin.x + 40, actorLabel.frame.origin.y, 250, 25)];
        actorName1Label.font = [UIFont systemFontOfSize:13];
        actorName1Label.textColor = CMConstants.grayColor;
        actorName1Label.backgroundColor = [UIColor clearColor];
        actorName1Label.tag = 7001;
        [cell.contentView addSubview:actorName1Label];
        
        UIImageView *dingNumberImage = [[UIImageView alloc]initWithFrame:CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y + 80, 16, 16)];
        dingNumberImage.image = [UIImage imageNamed:@"pushinguser"];
        [cell.contentView addSubview:dingNumberImage];
        
        UILabel *dingNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(nameLabel.frame.origin.x + 20, nameLabel.frame.origin.y + 80, 40, 18)];
        dingNumberLabel.backgroundColor = [UIColor clearColor];
        dingNumberLabel.font = [UIFont systemFontOfSize:13];
        dingNumberLabel.tag = 5001;
        [cell.contentView addSubview:dingNumberLabel];
        
        UIImageView *collectioNumber = [[UIImageView alloc]initWithFrame:CGRectMake(nameLabel.frame.origin.x + 70, nameLabel.frame.origin.y + 80, 16, 16)];
        collectioNumber.image = [UIImage imageNamed:@"collectinguser"];
        [cell.contentView addSubview:collectioNumber];
        
        UILabel *collectionNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(nameLabel.frame.origin.x + 90, nameLabel.frame.origin.y + 78, 40, 18)];
        collectionNumberLabel.backgroundColor = [UIColor clearColor];
        collectionNumberLabel.font = [UIFont systemFontOfSize:13];
        collectionNumberLabel.tag = 8001;
        [cell.contentView addSubview:collectionNumberLabel];
        
        UIImageView *devidingLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, 118, table.frame.size.width, 2)];
        devidingLine.image = [UIImage imageNamed:@"dividing"];
        [cell.contentView addSubview:devidingLine];
    }
    NSDictionary *item = [topsArray objectAtIndex:indexPath.row];
    UIImageView *contentImage = (UIImageView *)[cell viewWithTag:1001];
    [contentImage setImageWithURL:[NSURL URLWithString:[item objectForKey:@"prod_pic_url"]] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:2001];
    nameLabel.text = [item objectForKey:@"prod_name"];
    
    UILabel *directorNameLabel = (UILabel *)[cell viewWithTag:6001];
    directorNameLabel.text = [item objectForKey:@"directors"];
    
    UILabel *actorLabel = (UILabel *)[cell viewWithTag:7001];
    actorLabel.text = [item objectForKey:@"stars"];
    
    UILabel *scoreLabel = (UILabel *)[cell viewWithTag:4001];
    scoreLabel.text = [NSString stringWithFormat:@"%@ 分", [item objectForKey:@"score"]];
    
    UILabel *dingNumberLabel = (UILabel *)[cell viewWithTag:5001];
    dingNumberLabel.text = [NSString stringWithFormat:@"%@", [item objectForKey:@"support_num"]];
    
    UILabel *collectionNumberLabel = (UILabel *)[cell viewWithTag:8001];
    collectionNumberLabel.text = [NSString stringWithFormat:@"%@", [item objectForKey:@"favority_num"]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(topsArray.count > 0){
        [table deselectRowAtIndexPath:indexPath animated:YES];
        NSDictionary *item = [topsArray objectAtIndex:indexPath.row];
        NSString *prodtype = [NSString stringWithFormat:@"%@", [item objectForKey:@"prod_type"]];
        NSString *prodId = [NSString stringWithFormat:@"%@", [item objectForKey:@"prod_id"]];
        if([prodtype isEqualToString:@"1"]){
            MovieDetailViewController *viewController = [[MovieDetailViewController alloc] initWithNibName:@"MovieDetailViewController" bundle:nil];
            viewController.prodId = prodId;
//            viewController.fromViewController = self;
            viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
            [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:NO moveToLeft:NO];
        } else if([prodtype isEqualToString:@"2"]){
            DramaDetailViewController *viewController = [[DramaDetailViewController alloc] initWithNibName:@"DramaDetailViewController" bundle:nil];
            viewController.prodId = prodId;
//            viewController.fromViewController = self;
            viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
            [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:NO moveToLeft:NO];
        } else if([prodtype isEqualToString:@"3"]){
            ShowDetailViewController *viewController = [[ShowDetailViewController alloc] initWithNibName:@"ShowDetailViewController" bundle:nil];
            viewController.prodId = prodId;
//            viewController.fromViewController = self;
            viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
            [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:NO moveToLeft:NO];
        }
//        self.moveToLeft = NO;
    }
}

- (void)closeBtnClicked
{
    [[AppDelegate instance].rootViewController.stackScrollViewController removeViewToViewInSlider:VideoDetailViewController.class];
}

@end
