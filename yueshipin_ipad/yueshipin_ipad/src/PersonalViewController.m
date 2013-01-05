//
//  SettingsViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-20.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "PersonalViewController.h"
#import "CustomSearchBar.h"
#import "DingListViewController.h"
#import "CollectionListViewController.h"
#import "CreateListOneViewController.h"
#import "TopicListViewController.h"
#import "WatchRecordCell.h"
#import "MediaPlayerViewController.h"
#import "ProgramViewController.h"


#define TABLE_VIEW_WIDTH 370
#define MIN_BUTTON_WIDTH 45
#define MAX_BUTTON_WIDTH 355
#define BUTTON_HEIGHT 33
#define BUTTON_TITLE_GAP 13

@interface PersonalViewController (){
    UIView *backgroundView;
    UIButton *menuBtn;
    UIImageView *topImage;
    UIImageView *bgImage;
   
    UITableView *table;
    
    UIImageView *avatarImage;
    
    UILabel *nameLabel;
    UIButton *editBtn;
    
    UIImageView *personalImage;
    
    UILabel *supportLabel;
    UIButton *supportBtn;
    UILabel *collectionLabel;
    UIButton *collectionBtn;
    UILabel *listLabel;
    UIButton *listBtn;
    
    UIImageView *myRecordImage;
    UIButton *createBtn;
    UIButton *importDoubanBtn;
    
    UIImageView *tableBgImage;
    
    NSArray *sortedwatchRecordArray;
    int tableHeight;
    
    BOOL accessed;
}

@end

@implementation PersonalViewController
@synthesize menuViewControllerDelegate;
@synthesize userId;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PERSONAL_VIEW_REFRESH object:nil];
    self.userId = nil;
    backgroundView = nil;
    menuBtn = nil;
    topImage = nil;
    bgImage = nil;
    table = nil;
    avatarImage = nil;
    nameLabel = nil;
    editBtn = nil;
    personalImage = nil;
    supportLabel = nil;
    supportBtn = nil;
    collectionLabel = nil;
    collectionBtn = nil;
    listLabel = nil;
    listBtn = nil;
    myRecordImage = nil;
    createBtn = nil;
    importDoubanBtn = nil;
    tableBgImage = nil;    
    sortedwatchRecordArray = nil;
}
- (id)initWithFrame:(CGRect)frame {
    if (self = [super init]) {
		[self.view setFrame:frame];
        [self.view setBackgroundColor:[UIColor clearColor]];
        backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 24)];
        [backgroundView setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:backgroundView];
        
        bgImage = [[UIImageView alloc]initWithFrame:backgroundView.frame];
        bgImage.image = [UIImage imageNamed:@"left_background"];
        [backgroundView addSubview:bgImage];
        
        menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        menuBtn.frame = CGRectMake(0, 28, 60, 60);
        [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu_btn"] forState:UIControlStateNormal];
        [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu_btn_pressed"] forState:UIControlStateHighlighted];
        [menuBtn addTarget:self action:@selector(menuBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:menuBtn];
        
        topImage = [[UIImageView alloc]initWithFrame:CGRectMake(80, 40, 187, 36)];
        topImage.image = [UIImage imageNamed:@"my_title"];
        [self.view addSubview:topImage];
        
        personalImage = [[UIImageView alloc]initWithFrame:CGRectMake(60, 164, 404, 102)];
        personalImage.image = [UIImage imageNamed:@"my_summary_bg"];
        [self.view addSubview:personalImage];
        
        avatarImage = [[UIImageView alloc]initWithFrame:CGRectMake(80, 110, 70, 70)];
        avatarImage.layer.borderWidth = 1;
        avatarImage.layer.borderColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1].CGColor;
        avatarImage.layer.cornerRadius = 5;
        avatarImage.layer.masksToBounds = YES;
        [self.view addSubview:avatarImage];
        
        nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(165, 130, 260, 22)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.font = [UIFont systemFontOfSize:20];
        [self.view addSubview:nameLabel];
        
//        editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        editBtn.frame = CGRectMake(430, 122, 25, 27);
//        [editBtn setBackgroundImage:[UIImage imageNamed:@"edit_btn"] forState:UIControlStateNormal];
//        [editBtn addTarget:self action:@selector(editNameBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:editBtn];
        
        supportLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 228, 100, 30)];
        supportLabel.backgroundColor = [UIColor clearColor];
        supportLabel.textColor = CMConstants.titleBlueColor;
        supportLabel.text = @"0";
        supportLabel.textAlignment = NSTextAlignmentCenter;
        supportLabel.font = [UIFont boldSystemFontOfSize:22];
        [self.view addSubview:supportLabel];        
        supportBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        supportBtn.frame = CGRectMake(90, 180, 88, 87);
        supportBtn.tag = 1001;
        [supportBtn addTarget:self action:@selector(summaryBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:supportBtn];
        
        collectionLabel = [[UILabel alloc]initWithFrame:CGRectMake(80 + supportLabel.frame.size.width + 34, 228, 100, 30)];
        collectionLabel.textColor = CMConstants.titleBlueColor;
        collectionLabel.textAlignment = NSTextAlignmentCenter;
        collectionLabel.backgroundColor = [UIColor clearColor];
        collectionLabel.font = [UIFont boldSystemFontOfSize:22];
        collectionLabel.text = @"0";
        [self.view addSubview:collectionLabel];
        collectionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        collectionBtn.frame = CGRectMake(90 + supportLabel.frame.size.width + 34, 180, 88, 87);
        collectionBtn.tag = 1002;
        [collectionBtn addTarget:self action:@selector(summaryBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:collectionBtn];
        
        listLabel = [[UILabel alloc]initWithFrame:CGRectMake(80 + (supportLabel.frame.size.width + 33)*2, 228, 100, 30)];
        listLabel.textAlignment = NSTextAlignmentCenter;
        listLabel.textColor = CMConstants.titleBlueColor;
        listLabel.backgroundColor = [UIColor clearColor];
        listLabel.font = [UIFont boldSystemFontOfSize:22];
        listLabel.text = @"0";
        [self.view addSubview:listLabel];
        listBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        listBtn.frame = CGRectMake(90 + (supportLabel.frame.size.width + 33)*2, 180, 88, 87);
        listBtn.tag = 1003;
        [listBtn addTarget:self action:@selector(summaryBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:listBtn];
        
        myRecordImage = [[UIImageView alloc]initWithFrame:CGRectMake(60, 283, 95, 25)];
        myRecordImage.image = [UIImage imageNamed:@"my_record"];
        [self.view addSubview:myRecordImage];
        
        createBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        createBtn.frame = CGRectMake(210, 282, 104, 31);
        createBtn.frame = CGRectMake(358, 282, 104, 31);
        [createBtn setBackgroundImage:[UIImage imageNamed:@"create_list"] forState:UIControlStateNormal];
        [createBtn setBackgroundImage:[UIImage imageNamed:@"create_list_pressed"] forState:UIControlStateHighlighted];
        [createBtn addTarget:self action:@selector(createBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:createBtn];
        
        importDoubanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        importDoubanBtn.frame = CGRectMake(320, 282, 142, 31);
        [importDoubanBtn setBackgroundImage:[UIImage imageNamed:@"import_douban"] forState:UIControlStateNormal];
        [importDoubanBtn setBackgroundImage:[UIImage imageNamed:@"import_douban_pressed"] forState:UIControlStateHighlighted];
        [importDoubanBtn addTarget:self action:@selector(importDoubanBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:importDoubanBtn];

        table = [[UITableView alloc] initWithFrame:CGRectMake(60, 325, 400, 370) style:UITableViewStylePlain];
        [table setBackgroundColor:[UIColor whiteColor]];
        [table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        table.layer.borderWidth  = 1;
        table.layer.borderColor = CMConstants.tableBorderColor.CGColor;
        table.tableFooterView = [[UIView alloc] init];
		[table setDelegate:self];
		[table setDataSource:self];
        [table setScrollEnabled:NO];
        [self.view addSubview:table];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData:) name:PERSONAL_VIEW_REFRESH object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.userId = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId];
    NSString *avatarUrl = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserAvatarUrl];
    [avatarImage setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:[UIImage imageNamed:@"self_icon"]];
    nameLabel.text = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserNickName];
    NSArray *watchRecordArray = (NSArray *)[[CacheUtility sharedCache]loadFromCache:@"watch_record"];
    sortedwatchRecordArray = [watchRecordArray sortedArrayUsingComparator:^(NSDictionary *a, NSDictionary *b) {
        NSDate *first = [DateUtility dateFromFormatString:[a objectForKey:@"createDateStr"] formatString: @"yyyy-MM-dd HH:mm:ss"] ;
        NSDate *second = [DateUtility dateFromFormatString:[b objectForKey:@"createDateStr"] formatString: @"yyyy-MM-dd HH:mm:ss"];
        return [second compare:first];
    }];
    table.frame = CGRectMake(60, 325, 400, tableHeight);
    [table reloadData];
    if (!accessed) {
        accessed = YES;
        [self parseResult];
    }
    
}

- (void)parseResult
{
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:[NSString stringWithFormat:@"PersonalData%@", self.userId]];
    if(cacheResult != nil){
        [self parseResultData:cacheResult];
    }
    if([[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: self.userId, @"userid", nil];
        [[AFServiceAPIClient sharedClient] getPath:kPathUserView parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [self parseResultData:result];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
            [UIUtility showSystemError:self.view];
        }];
    }
}

- (void)parseResultData:(id)result
{
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        [[CacheUtility sharedCache] putInCache:[NSString stringWithFormat:@"PersonalData%@", self.userId] result:result];
        supportLabel.text = [NSString stringWithFormat:@"%@", [result objectForKey:@"support_num"]];
//        sharelabel.text = [NSString stringWithFormat:@"%@", [result objectForKey:@"share_num"]];
        collectionLabel.text = [NSString stringWithFormat:@"%@", [result objectForKey:@"favority_num"]];
        listLabel.text = [NSString stringWithFormat:@"%@", [result objectForKey:@"tops_num"]];
    }
}

- (void)refreshData:(NSNotification *)notification
{
    [self parseResult];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return sortedwatchRecordArray.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    WatchRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[WatchRecordCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *movieNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 10, 280, 15)];
        movieNameLabel.backgroundColor = [UIColor clearColor];
        movieNameLabel.textColor = [UIColor blackColor];
        movieNameLabel.tag = 1001;
        movieNameLabel.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:movieNameLabel];
        
        UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        playButton.tag = 1002;
        [playButton addTarget:self action:@selector(playBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:playButton];
        
        UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 35, 280, 15)];
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.textColor = CMConstants.grayColor;
        contentLabel.tag = 1003;
        contentLabel.font = [UIFont systemFontOfSize:15];
        [contentLabel setNumberOfLines:0];
        [cell.contentView addSubview:contentLabel];
    }
    NSDictionary *item =  [sortedwatchRecordArray objectAtIndex:indexPath.row];
    UILabel *movieNameLabel = (UILabel *)[cell viewWithTag:1001];
    movieNameLabel.text = [item objectForKey:@"name"];
    
    UILabel *contentLabel = (UILabel *)[cell viewWithTag:1003];
    contentLabel.text = [self composeContent:item];
    CGSize size = [self calculateContentSize:contentLabel.text width:280];
    [contentLabel setFrame:CGRectMake(contentLabel.frame.origin.x, contentLabel.frame.origin.y, size.width, size.height)];
    
    UIButton *playButton = (UIButton *)[cell viewWithTag:1002];
    NSNumber *playbackTime = (NSNumber *)[item objectForKey:@"playbackTime"];
    NSNumber *duration = (NSNumber *)[item objectForKey:@"duration"];
    if(duration.doubleValue - playbackTime.doubleValue < 3){
        [playButton setBackgroundImage:[UIImage imageNamed:@"replay"] forState:UIControlStateNormal];
        [playButton setBackgroundImage:[UIImage imageNamed:@"replay_pressed"] forState:UIControlStateHighlighted];
    } else {
        [playButton setBackgroundImage:[UIImage imageNamed:@"continue"] forState:UIControlStateNormal];
        [playButton setBackgroundImage:[UIImage imageNamed:@"continue_pressed"] forState:UIControlStateHighlighted];
    }
    playButton.frame = CGRectMake(300, (size.height + 40 - 26)/2.0, 74, 26);
    
    return cell;
}

- (void)playBtnClicked:(UIButton *)btn
{
    CGPoint point = btn.center;
    point = [table convertPoint:point fromView:btn.superview];
    NSIndexPath* indexPath = [table indexPathForRowAtPoint:point];
    NSDictionary *item = [sortedwatchRecordArray objectAtIndex:indexPath.row];
    if([[item objectForKey:@"play_type"] isEqualToString:@"1"]){
        MediaPlayerViewController *viewController = [[MediaPlayerViewController alloc]initWithNibName:@"MediaPlayerViewController" bundle:nil];
        viewController.videoUrl = [item objectForKey:@"videoUrl"];
        viewController.type = [[NSString stringWithFormat:@"%@", [item objectForKey:@"type"]] integerValue];
        viewController.name = [item objectForKey:@"name"];
        viewController.subname = [item objectForKey:@"subname"];
        [[AppDelegate instance].rootViewController pesentMyModalView:viewController];
    } else {
        ProgramViewController *viewController = [[ProgramViewController alloc]initWithNibName:@"ProgramViewController" bundle:nil];
        viewController.programUrl = [item objectForKey:@"videoUrl"];
        viewController.title = [item objectForKey:@"name"];
        viewController.subname = [item objectForKey:@"subname"];
        viewController.type = [[NSString stringWithFormat:@"%@", [item objectForKey:@"type"]] integerValue];
        viewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        [[AppDelegate instance].rootViewController pesentMyModalView:[[UINavigationController alloc]initWithRootViewController:viewController]];
    }
}

- (NSString *)composeContent:(NSDictionary *)item
{
    NSString *content;
    NSNumber *number = (NSNumber *)[item objectForKey:@"playbackTime"];
    if ([[item objectForKey:@"type"] isEqualToString:@"1"]) {
        content = [NSString stringWithFormat:@"已观看到 %@", [TimeUtility formatTimeInSecond:number.doubleValue]];
    } else if ([[item objectForKey:@"type"] isEqualToString:@"2"]) {
        content = [NSString stringWithFormat:@"已观看到第%@集 %@", [item objectForKey:@"subname"], [TimeUtility formatTimeInSecond:number.doubleValue]];
    } else if ([[item objectForKey:@"type"] isEqualToString:@"3"]) {
        content = [NSString stringWithFormat:@"已观看《%@》 %@", [item objectForKey:@"subname"], [TimeUtility formatTimeInSecond:number.doubleValue]];
    }
    return content;
}

- (CGSize)calculateContentSize:(NSString *)content width:(int)width
{
    CGSize constraint = CGSizeMake(width, 20000.0f);
    CGSize size = [content sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    return size;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        tableHeight = 0;
    }
    NSDictionary *item =  [sortedwatchRecordArray objectAtIndex:indexPath.row];
    NSString *content = [self composeContent:item];
    CGSize size = [self calculateContentSize:content width:280];
    tableHeight += size.height + 40;
   return size.height + 40;
}

- (void)menuBtnClicked
{
    [self.menuViewControllerDelegate menuButtonClicked];
}

- (void)summaryBtnClicked:(UIButton *)sender
{
    [self closeMenu];
    for(int i = 0; i < 4; i++){
        UIButton *btn = (UIButton *)[self.view viewWithTag:1001 + i];
        [btn setBackgroundImage:nil forState:UIControlStateNormal];
        [btn setBackgroundImage:nil forState:UIControlStateHighlighted];
    }
    [sender setBackgroundImage:[UIImage imageNamed:@"selected_bg"] forState:UIControlStateNormal];
    [sender setBackgroundImage:[UIImage imageNamed:@"selected_bg"] forState:UIControlStateHighlighted];
    if(sender.tag == 1001){
        DingListViewController *viewController = [[DingListViewController alloc] init];
        viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:YES];
    } else if(sender.tag == 1002){
        CollectionListViewController *viewController = [[CollectionListViewController alloc] init];
        viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:YES];
    } else if(sender.tag == 1003){
        Reachability *hostReach = [Reachability reachabilityForInternetConnection];
        if([hostReach currentReachabilityStatus] == NotReachable) {
            [UIUtility showNetWorkError:self.view];
            return;
        }
        TopicListViewController *viewController = [[TopicListViewController alloc] init];
        viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:YES];
    } 
}


- (void)createBtnClicked:(id)sender
{
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([hostReach currentReachabilityStatus] == NotReachable) {
        [UIUtility showNetWorkError:self.view];
        return;
    }
    [self closeMenu];
    CreateListOneViewController *viewController = [[CreateListOneViewController alloc]initWithNibName:@"CreateListOneViewController" bundle:nil];
    viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
    [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:YES];
}
@end
