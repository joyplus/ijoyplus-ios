//
//  mineViewController.m
//  yueshipin
//
//  Created by 08 on 12-12-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "MineViewController.h"
#import "RecordListCell.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "IphoneSettingViewController.h"
#import "MoreListViewController.h"
#import "IphoneMovieDetailViewController.h"
#import "ContainerUtility.h"
#import "CMConstants.h"
#import "UIImageView+WebCache.h"
#import "CacheUtility.h"
#import "CreateMyListOneViewController.h"
#import "CreateMyListTwoViewController.h"
#import "DateUtility.h"
#import "MediaPlayerViewController.h"
#import "ProgramViewController.h"
#import "UIImage+Scale.h"
#import "SearchPreViewController.h"
#define RECORD_TYPE 0
#define Fav_TYPE  1
#define MYLIST_TYPE 2
#define PAGESIZE 20
@interface MineViewController ()

@end

@implementation MineViewController
@synthesize segControl = segControl_;
@synthesize bgView = bgView_;
@synthesize sortedwatchRecordArray = sortedwatchRecordArray_;
@synthesize favArr = favArr_;
@synthesize favShowArr = favShowArr_;
@synthesize myListArr = myListArr_;
@synthesize recordTableList = recordTableList_;
@synthesize favTableList = favTableList_;
@synthesize moreView = moreView_;
@synthesize moreButton = moreButton_;
@synthesize avatarImage = avatarImage_;
@synthesize userId = userId_;
@synthesize myTableList = myTableList_;
@synthesize button1 = button1_;
@synthesize button2 = button2_;
@synthesize button3 = button3_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)loadMyFavsData{
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: @"1", @"page_num", [NSNumber numberWithInt:PAGESIZE], @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathUserFavorities parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        self.favArr = [[NSMutableArray alloc]initWithCapacity:PAGESIZE];
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *tempTopsArray = [result objectForKey:@"favorities"];
            if(tempTopsArray.count > 0){
                
                [ self.favArr addObjectsFromArray:tempTopsArray];
            }
        }
        else {
            
        }

    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        if(self.favArr == nil){
            self.favArr = [[NSMutableArray alloc]initWithCapacity:10];
        }
    }];
    
}

-(void)loadPersonalData{

    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: @"1", @"page_num", [NSNumber numberWithInt:PAGESIZE], @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathUserTopics parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *tempArr = [result objectForKey:@"tops"];
            if(tempArr != nil && tempArr.count > 0){
                [myListArr_ addObjectsFromArray:tempArr];
                [myTableList_ reloadData];
            }
            
        }
        
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
       
       
    }];



}

- (void)parseResultData:(id)result
{
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        [[CacheUtility sharedCache] putInCache:[NSString stringWithFormat:@"PersonalData%@", userId_] result:result];

    }
}
-(UIImage *)scaleFromImage:(UIImage *)image toSize:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self loadMyFavsData];
    
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_common.png"]];
    bg.frame = CGRectMake(0, 0, 320, 480);
    [self.view addSubview:bg];
    
    UILabel *titleText = [[UILabel alloc] initWithFrame: CGRectMake(90, 0, 60, 50)];
    titleText.backgroundColor = [UIColor clearColor];
    titleText.textColor=[UIColor whiteColor];
    [titleText setFont:[UIFont boldSystemFontOfSize:18.0]];
    [titleText setText:@"悦视频"];
    self.navigationItem.titleView=titleText;
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, 40, 30);
    leftButton.backgroundColor = [UIColor clearColor];
    [leftButton setImage:[UIImage scaleFromImage:[UIImage imageNamed:@"top_search_common.png"] toSize:CGSizeMake(19, 18)] forState:UIControlStateNormal];
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton addTarget:self action:@selector(setting:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(0, 0, 40, 30);
    rightButton.backgroundColor = [UIColor clearColor];
    [rightButton setImage:[UIImage scaleFromImage:[UIImage imageNamed:@"top_setting_common.png"] toSize:CGSizeMake(19, 18)] forState:UIControlStateNormal];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    button1_ = [UIButton buttonWithType:UIButtonTypeCustom];
    button1_.frame = CGRectMake(12, 40, 99, 51);
    button1_.selected = YES;
    button1_.tag = 100;
    [button1_ addTarget:self action:@selector(Selectbutton:) forControlEvents:UIControlEventTouchUpInside];
    [button1_ setBackgroundImage:[self scaleFromImage:[UIImage imageNamed:@"tab3_page1_icon.png"] toSize:CGSizeMake(99, 52)] forState:UIControlStateNormal];
    [button1_ setBackgroundImage:[self scaleFromImage:[UIImage imageNamed:@"tab3_page1_icon_s.png"]toSize:CGSizeMake(99, 52)]forState:UIControlStateSelected];
    button2_ = [UIButton buttonWithType:UIButtonTypeCustom];
    [button2_ addTarget:self action:@selector(Selectbutton:) forControlEvents:UIControlEventTouchUpInside];
    [button2_ setBackgroundImage:[self scaleFromImage:[UIImage imageNamed:@"tab3_page1_icon2.png"] toSize:CGSizeMake(99, 52)] forState:UIControlStateNormal];
    [button2_ setBackgroundImage:[self scaleFromImage:[UIImage imageNamed:@"tab3_page1_icon2_s.png"]toSize:CGSizeMake(99, 52)]forState:UIControlStateSelected];
    button2_.frame = CGRectMake(111, 40, 99, 51);
    button2_.tag = 101;
    button3_ = [UIButton buttonWithType:UIButtonTypeCustom];
    [button3_ addTarget:self action:@selector(Selectbutton:) forControlEvents:UIControlEventTouchUpInside];
    [button3_ setBackgroundImage:[self scaleFromImage:[UIImage imageNamed:@"tab3_page1_icon3.png"] toSize:CGSizeMake(99, 52)] forState:UIControlStateNormal];
    [button3_ setBackgroundImage:[self scaleFromImage:[UIImage imageNamed:@"tab3_page1_icon3_s.png"]toSize:CGSizeMake(99, 52)]forState:UIControlStateSelected];
    button3_.frame = CGRectMake(210, 40, 99, 51);
    button3_.tag = 102;
     
    [self.view addSubview:button1_];
    [self.view addSubview:button2_];
    [self.view addSubview:button3_];
    
    [self Selectbutton:button1_];
//    NSArray *itemsArr = [NSArray arrayWithObjects:@"播放纪录",@"我的收藏",@"我的悦单", nil];
//    self.segControl = [[UISegmentedControl alloc] initWithItems:itemsArr];
//    self.segControl.frame = CGRectMake(12, 40, 296, 51);
//    self.segControl.tintColor =  [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
//    self.segControl.segmentedControlStyle = UISegmentedControlStyleBar;
//    [self.segControl setImage:[self scaleFromImage:[UIImage imageNamed:@"tab3_page1_icon.png"] toSize:CGSizeMake(99, 52)] forSegmentAtIndex:0];
//    [self.segControl setImage:[self scaleFromImage:[UIImage imageNamed:@"tab3_page1_icon.png"] toSize:CGSizeMake(99, 52)] forSegmentAtIndex:1];
//    [self.segControl setImage:[self scaleFromImage:[UIImage imageNamed:@"tab3_page1_icon.png"] toSize:CGSizeMake(99, 52)] forSegmentAtIndex:2];
//    [self.segControl addTarget:self action:@selector(Selectbutton:) forControlEvents:UIControlEventValueChanged];
//    self.segControl.selectedSegmentIndex = 0;
//    [self.view addSubview:self.segControl];
        
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(12, 98, 296, 180)];
    self.bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.bgView];
    
    self.recordTableList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 296, 180) style:UITableViewStylePlain];
    self.recordTableList.dataSource = self;
    self.recordTableList.delegate = self;
    self.recordTableList.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.recordTableList.tag = RECORD_TYPE;
    self.recordTableList.scrollEnabled = NO;
    
    self.favTableList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 296, 180) style:UITableViewStylePlain];
    self.favTableList.dataSource = self;
    self.favTableList.delegate = self;
    self.favTableList.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.favTableList.tag = Fav_TYPE;
    self.favTableList.scrollEnabled = NO;
    
    myTableList_ = [[UITableView alloc] initWithFrame:CGRectMake(0, 37, 296, 150) style:UITableViewStylePlain];
    myTableList_.dataSource = self;
    myTableList_.delegate = self;
    myTableList_.separatorStyle = UITableViewCellSeparatorStyleNone;
    myTableList_.tag = MYLIST_TYPE;
    myTableList_.scrollEnabled = NO;
    
    
    moreView_ = [[UIView alloc] initWithFrame:CGRectMake(12, 293, 296, 45)];
    moreView_.backgroundColor = [UIColor whiteColor];
    moreButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton_ addTarget:self action:@selector(seeMore:) forControlEvents:UIControlEventTouchUpInside];
    [moreButton_ setFrame:CGRectMake(5, 7, 284, 30)];
    [moreView_ addSubview:moreButton_];
    
    createList_ = [UIButton buttonWithType:UIButtonTypeCustom];
    createList_.frame = CGRectMake(5, 7, 284, 30);
    [createList_ addTarget:self action:@selector(createList:) forControlEvents:UIControlEventTouchUpInside];
    [createList_ setBackgroundImage:[UIImage imageNamed:@"icon_new wyatt single.png"] forState:UIControlStateNormal];
    [createList_ setBackgroundImage:[UIImage imageNamed:@"icon_new wyatt single_s.png"] forState:UIControlStateHighlighted];
    
    userId_ = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId];
    avatarImage_ = [[UIImageView alloc] initWithFrame:CGRectMake(22, 12, 43, 43)];
    NSString *avatarUrl = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserAvatarUrl];
    [avatarImage_ setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:[UIImage imageNamed:@"self_icon"]];
    [self.view addSubview:avatarImage_];
    
    nameLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(75, 18, 200, 14)];
    nameLabel_.font = [UIFont systemFontOfSize:15];
    nameLabel_.text = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserNickName];
    nameLabel_.backgroundColor = [UIColor clearColor];
    [self.view addSubview:nameLabel_];
    
    [self loadPersonalData];
    
    NSArray *watchRecordArray = (NSArray *)[[CacheUtility sharedCache]loadFromCache:@"watch_record"];
    sortedwatchRecordArray_ = [watchRecordArray sortedArrayUsingComparator:^(NSDictionary *a, NSDictionary *b) {
        NSDate *first = [DateUtility dateFromFormatString:[a objectForKey:@"createDateStr"] formatString: @"yyyy-MM-dd HH:mm:ss"] ;
        NSDate *second = [DateUtility dateFromFormatString:[b objectForKey:@"createDateStr"] formatString: @"yyyy-MM-dd HH:mm:ss"];
        return [second compare:first];
    }];
    
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(addDone:) name:@"Update MineViewController" object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(refreshFav) name:@"refreshFav" object:nil];
    
}
-(void)refreshFav{
    [self loadMyFavsData];
    [favTableList_ reloadData];
}
-(void)search:(id)sender{
    SearchPreViewController *searchViewCotroller = [[SearchPreViewController alloc] init];
    searchViewCotroller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchViewCotroller animated:YES];
    
}
-(void)addDone:(id)sender{
    NSMutableDictionary *dic = [(NSNotification *)sender object];
    if (myListArr_ == nil) {
        myListArr_ = [[NSMutableArray alloc]initWithCapacity:10];
    }
    [myListArr_ addObject:dic];
    
    [myTableList_ reloadData];

}
-(void)createList:(id)sender{
    CreateMyListOneViewController *createMyListOneViewController = [[CreateMyListOneViewController alloc] init];
    createMyListOneViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:createMyListOneViewController animated:YES];

}
-(void)seeMore:(id)sender{
    if (button1_.selected) {
        MoreListViewController *moreListViewController = [[MoreListViewController alloc] initWithStyle:UITableViewStylePlain];
        moreListViewController.listArr = sortedwatchRecordArray_;
        moreListViewController.type = RECORD_TYPE;
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:moreListViewController] animated:YES completion:nil];
    }
    else if (button2_.selected) {
        MoreListViewController *moreListViewController = [[MoreListViewController alloc] initWithStyle:UITableViewStylePlain];
        moreListViewController.listArr = favArr_;
        moreListViewController.type = Fav_TYPE;
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:moreListViewController] animated:YES completion:nil];
    }
    else if(button3_.selected){
        MoreListViewController *moreListViewController = [[MoreListViewController alloc] initWithStyle:UITableViewStylePlain];
        moreListViewController.listArr = myListArr_;
         moreListViewController.type = MYLIST_TYPE;
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:moreListViewController] animated:YES completion:nil];
    
    }

}


-(void)setting:(id)sender{
    IphoneSettingViewController *settingViewController = [[IphoneSettingViewController alloc] init];
    settingViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:settingViewController animated:YES];

}

-(void)Selectbutton:(id)sender{
    [self.recordTableList removeFromSuperview];
    [self.favTableList removeFromSuperview];
    [self.myTableList removeFromSuperview];
    button1_.selected = NO;
    button2_.selected = NO;
    button3_.selected = NO;
    //UISegmentedControl *mySegmentedControl=(UISegmentedControl *)sender;
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        //播放纪录
        case 100:{
            button1_.selected = YES;
                if ([self.sortedwatchRecordArray count] <= 3) {
                    [moreView_ removeFromSuperview];
                }
                else {
                    [moreButton_ setBackgroundImage:[UIImage imageNamed:@"tab3_page1_see.png"] forState:UIControlStateNormal];
                    [moreButton_ setBackgroundImage:[UIImage imageNamed:@"tab3_page1_see_s.png"] forState:UIControlStateHighlighted];
                    [self.view addSubview:moreView_];
                }
                [createList_ removeFromSuperview];
                [myTableList_ removeFromSuperview];
                [self.bgView addSubview:self.recordTableList];
                [self.recordTableList reloadData];
            break;
        }
        //我的收藏
        case 101:{
            button2_.selected = YES;
            if ([self.favArr count] <= 3) {
                favShowArr_ = [NSArray arrayWithArray:self.favArr];
                [moreView_ removeFromSuperview];
            }
            else {
                favShowArr_ = [NSArray arrayWithObjects:[self.favArr objectAtIndex:0],[self.favArr objectAtIndex:1],[self.favArr objectAtIndex:2], nil];
                [moreButton_ setBackgroundImage:[UIImage imageNamed:@"tab3_page2_see.png"] forState:UIControlStateNormal];
                [moreButton_ setBackgroundImage:[UIImage imageNamed:@"tab3_page2_see_s.png"] forState:UIControlStateHighlighted];
                [self.view addSubview:moreView_];
            }
            [createList_ removeFromSuperview];
            [myTableList_ removeFromSuperview];
            [self.bgView addSubview:self.favTableList];
            [self.favTableList reloadData];
            break;
        }
        //我的悦单
        case 102:{
            button3_.selected = YES;
            if ([myListArr_ count] <= 2) {
              
                [moreView_ removeFromSuperview];
            }
            else {
               
                [moreButton_ setBackgroundImage:[UIImage imageNamed:@"tab3_page3_see.png"] forState:UIControlStateNormal];
                [moreButton_ setBackgroundImage:[UIImage imageNamed:@"tab3_page3_see_s.png"] forState:UIControlStateHighlighted];
                [self.view addSubview:moreView_];
            }
            [self.bgView addSubview:createList_];
            [self.bgView addSubview:myTableList_];
            break;
        }
        default:
            break;
    }

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag == RECORD_TYPE) {
        if ([sortedwatchRecordArray_ count] <= 3) {
            return [sortedwatchRecordArray_ count];
        }
        else{
            return 3;
        }
    }
    if (tableView.tag == Fav_TYPE) {
        return [favShowArr_ count];
    }
    if (tableView.tag == MYLIST_TYPE) {
        if ([myListArr_ count] <= 2) {
            return [myListArr_ count];
        }
        else{
            return 2;
        }
    }
    
    return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    RecordListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[RecordListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (tableView.tag == RECORD_TYPE) {
      
        NSDictionary *infoDic = [sortedwatchRecordArray_ objectAtIndex:indexPath.row];
        cell.textLabel.text = [infoDic objectForKey:@"name"];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        [cell.titleLab removeFromSuperview];
        [cell.actors removeFromSuperview];
        [cell.date removeFromSuperview];
        cell.play.tag = indexPath.row;
        [cell.play addTarget:self action:@selector(continuePlay:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    else if (tableView.tag == Fav_TYPE){
        NSDictionary *infoDic = [favShowArr_ objectAtIndex:indexPath.row];
        cell.titleLab.text = [infoDic objectForKey:@"content_name"];
        cell.actors.text =[NSString stringWithFormat:@"主演：%@",[infoDic objectForKey:@"stars"]] ;
        cell.date.text = [NSString stringWithFormat:@"年代：%@",[infoDic objectForKey:@"publish_date"]];
        [cell.play  removeFromSuperview];
        
    }
    else if (tableView.tag == MYLIST_TYPE){
    
        NSDictionary *infoDic = [myListArr_ objectAtIndex:indexPath.row];
        NSDictionary *item = [(NSMutableArray *)[infoDic objectForKey:@"items"] objectAtIndex:0];
        cell.titleLab.text = [infoDic objectForKey:@"name"];
        cell.actors.text = [item objectForKey:@"prod_name"];
        cell.date.text = @"...";
        [cell.play  removeFromSuperview];
    
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == Fav_TYPE){
        IphoneMovieDetailViewController *detailViewController = [[IphoneMovieDetailViewController alloc] init];
        detailViewController.infoDic = [favShowArr_ objectAtIndex:indexPath.row];
        detailViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detailViewController animated:YES];
        
    }
    else if(tableView.tag == MYLIST_TYPE){
        NSDictionary *infoDic = [myListArr_ objectAtIndex:indexPath.row];
        NSMutableArray *items = (NSMutableArray *)[infoDic objectForKey:@"items"];
        CreateMyListTwoViewController *createMyListTwoViewController = [[CreateMyListTwoViewController alloc] init];
        createMyListTwoViewController.listArr = items;
        createMyListTwoViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:createMyListTwoViewController animated:YES];
        
    
    }


}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == MYLIST_TYPE) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete){
        NSDictionary *infoDic = [myListArr_ objectAtIndex:indexPath.row];
        NSString *topicId = [infoDic objectForKey:@"topic_id"];
        
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:topicId, @"topic_id", nil];
        [[AFServiceAPIClient sharedClient] postPath:kPathTopDelete parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            NSString *responseCode = [result objectForKey:@"res_code"];
            if([responseCode isEqualToString:kSuccessResCode]){
                [myListArr_ removeObjectAtIndex:indexPath.row];
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
    NSDictionary *item = [sortedwatchRecordArray_ objectAtIndex:num];
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
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:viewController] animated:YES completion:nil];
    }

    

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
