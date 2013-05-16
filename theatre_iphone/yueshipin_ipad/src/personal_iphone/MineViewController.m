//
//  mineViewController.m
//  yueshipin
//
//  Created by 08 on 12-12-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "MineViewController.h"
#import "RecordListCell.h"
#import "IphoneSettingViewController.h"
#import "MoreListViewController.h"
#import "IphoneMovieDetailViewController.h"
#import "CreateMyListOneViewController.h"
#import "CreateMyListTwoViewController.h"
#import "UIImage+Scale.h"
#import "SearchPreViewController.h"
#import "ProgramNavigationController.h"
#import "TVDetailViewController.h"
#import "IphoneShowDetailViewController.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "SinaWeibo.h"
#import "AppDelegate.h"
#import "CommonHeader.h"
#import "IphoneWebPlayerViewController.h"
#import "CustomNavigationViewController.h"
#import "CustomNavigationViewControllerPortrait.h"
#import "Reachability.h"
#import "CommonMotheds.h"
#import <Parse/Parse.h>
#import "MyListCell.h"
#define RECORD_TYPE 0
#define Fav_TYPE  1
#define MYLIST_TYPE 2
#define PAGESIZE 20
@interface MineViewController ()

@property (nonatomic, strong)NSMutableArray *subnameArray;
@property (nonatomic, strong) UIButton *clickedBtn;
@end

@implementation MineViewController

@synthesize bgView = bgView_;
@synthesize sortedwatchRecordArray = sortedwatchRecordArray_;
@synthesize favArr = favArr_;
@synthesize favShowArr = favShowArr_;
@synthesize myListArr = myListArr_;
@synthesize recordTableList = recordTableList_;
@synthesize favTableList = favTableList_;
@synthesize moreButton = moreButton_;
@synthesize avatarImage = avatarImage_;
@synthesize userId = userId_;
@synthesize myTableList = myTableList_;
@synthesize button1 = button1_;
@synthesize button2 = button2_;
@synthesize button3 = button3_;
@synthesize noRecord = noRecord_;
@synthesize noFav = noFav_;
@synthesize noPersonalList = noPersonalList_;
@synthesize subnameArray;
@synthesize clickedBtn;
@synthesize typeLabel = typeLabel_;
@synthesize clearRecord = clearRecord_;
@synthesize scrollBg;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)loadMyFavsData{
    MBProgressHUD*tempHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:tempHUD];
    tempHUD.labelText = @"加载中...";
    tempHUD.opacity = 0.5;
    [tempHUD show:YES];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:(NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId], @"userid", @"1", @"page_num", [NSNumber numberWithInt:10], @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathUserFavorities parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        self.favArr = [[NSMutableArray alloc]initWithCapacity:PAGESIZE];
        NSString *responseCode = [result objectForKey:@"res_code"];
        [tempHUD hide:YES];
        if(responseCode == nil){
            NSArray *tempTopsArray = [result objectForKey:@"favorities"];
            if(tempTopsArray.count > 0){
                
                [ self.favArr addObjectsFromArray:tempTopsArray];
            }
        }
        if (!button2_.enabled) {
            [self refreshMineViewWithTag:button2_.tag];
        }
        
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        if(self.favArr == nil){
            self.favArr = [[NSMutableArray alloc]initWithCapacity:10];
        }
        [tempHUD hide:YES];
        [CommonMotheds showInternetError:error inView:self.view];
    }];
    
}

-(void)loadPersonalData{
    MBProgressHUD*tempHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:tempHUD];
    tempHUD.labelText = @"加载中...";
    tempHUD.opacity = 0.5;
    [tempHUD show:YES];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:(NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId], @"userid", @"1", @"page_num", [NSNumber numberWithInt:20], @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathUserTopics parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        myListArr_  = [NSMutableArray arrayWithCapacity:10];
        [tempHUD hide:YES];
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *tempArr = [result objectForKey:@"tops"];
            if(tempArr != nil && tempArr.count > 0){
                [myListArr_ addObjectsFromArray:tempArr];
                
            }
            
            if (!button3_.enabled) {
                [self refreshMineViewWithTag:button3_.tag];
            }
        }
        
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
       
      [tempHUD hide:YES];
      [CommonMotheds showInternetError:error inView:self.view];
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
    
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_common.png"]];
    bg.frame = CGRectMake(0, 0, 320, kCurrentWindowHeight);
    [self.view addSubview:bg];
    
    scrollBg = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, kCurrentWindowHeight-44-48)];
    scrollBg.backgroundColor = [UIColor clearColor];
    scrollBg.contentSize = CGSizeMake(320, 500);
    [self.view addSubview:scrollBg];
    
    UILabel *titleText = [[UILabel alloc] initWithFrame: CGRectMake(220, 0, 80, 50)];
    titleText.backgroundColor = [UIColor clearColor];
    titleText.textColor=[UIColor whiteColor];
    [titleText setFont:[UIFont boldSystemFontOfSize:20.0]];
    [titleText setText:@"个人主页"];
    titleText.shadowColor = [UIColor colorWithRed:121.0/255 green:64.0/255 blue:0 alpha:1];
    titleText.center = self.navigationItem.titleView.center;
    self.navigationItem.titleView=titleText;
    
//    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [leftButton addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
//    leftButton.frame = CGRectMake(0, 0, 55, 44);
//    leftButton.backgroundColor = [UIColor clearColor];
//    [leftButton setImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateNormal];
//    [leftButton setImage:[UIImage imageNamed:@"search_f.png"] forState:UIControlStateHighlighted];
//    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
//    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton addTarget:self action:@selector(setting:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(0, 0, 55, 44);
    rightButton.backgroundColor = [UIColor clearColor];
    [rightButton setImage:[UIImage imageNamed:@"settings.png"] forState:UIControlStateNormal];
    [rightButton setImage:[UIImage imageNamed:@"settings_f.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    UIImageView *buttonBgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_shang_bg.png"]];
    buttonBgView.frame = CGRectMake(10, 50, 300, 66);
    [scrollBg addSubview:buttonBgView];
    
    button1_ = [UIButton buttonWithType:UIButtonTypeCustom];
    button1_.frame = CGRectMake(12, 71, 95, 40);
    button1_.tag = 100;
    [button1_ addTarget:self action:@selector(Selectbutton:) forControlEvents:UIControlEventTouchUpInside];
    [button1_ setBackgroundImage:[UIImage imageNamed:@"tab3_page1_icon.png"] forState:UIControlStateNormal];
    [button1_ setBackgroundImage:[UIImage imageNamed:@"tab3_page1_icon_s.png"] forState:UIControlStateHighlighted];
    [button1_ setBackgroundImage:[UIImage imageNamed:@"tab3_page1_icon_s.png"]forState:UIControlStateDisabled];
    button1_.enabled = NO;
    button1_.adjustsImageWhenDisabled = NO;

    button2_ = [UIButton buttonWithType:UIButtonTypeCustom];
    [button2_ addTarget:self action:@selector(Selectbutton:) forControlEvents:UIControlEventTouchUpInside];
    [button2_ setBackgroundImage:[UIImage imageNamed:@"tab3_page1_icon2.png"] forState:UIControlStateNormal];
    [button2_ setBackgroundImage:[UIImage imageNamed:@"tab3_page1_icon2_s.png"] forState:UIControlStateHighlighted];
    [button2_ setBackgroundImage:[UIImage imageNamed:@"tab3_page1_icon2_s.png"]forState:UIControlStateDisabled];
    button2_.frame = CGRectMake(self.view.frame.size.width/2-48, 71, 95, 40);
    button2_.tag = 101;
    button2_.adjustsImageWhenDisabled = NO;
    
    button3_ = [UIButton buttonWithType:UIButtonTypeCustom];
    [button3_ addTarget:self action:@selector(Selectbutton:) forControlEvents:UIControlEventTouchUpInside];
    [button3_ setBackgroundImage:[UIImage imageNamed:@"tab3_page1_icon3.png"] forState:UIControlStateNormal];
    [button3_ setBackgroundImage:[UIImage imageNamed:@"tab3_page1_icon3_s.png"] forState:UIControlStateHighlighted];
    [button3_ setBackgroundImage:[UIImage imageNamed:@"tab3_page1_icon3_s.png"]forState:UIControlStateDisabled];
    button3_.frame = CGRectMake(212, 71, 95, 40);
    button3_.tag = 102;
    button3_.adjustsImageWhenDisabled = NO;
     
    [scrollBg addSubview:button1_];
    [scrollBg addSubview:button2_];
    [scrollBg addSubview:button3_];
    
    typeLabel_ = [[UIImageView alloc] initWithFrame:CGRectMake(10, 131, 48, 13)];
    typeLabel_.image = [UIImage imageNamed:@"bifangjilu"];
    [scrollBg addSubview:typeLabel_];
    
    clearRecord_ = [[UIButton alloc] initWithFrame:CGRectMake(245, 124, 64, 22)];
    [clearRecord_ addTarget:self action:@selector(clearMyRecord) forControlEvents:UIControlEventTouchUpInside];
    [clearRecord_ setBackgroundImage:[UIImage imageNamed:@"icon_qingchu.png"] forState:UIControlStateNormal];
    [clearRecord_ setBackgroundImage:[UIImage imageNamed:@"icon_qingchu_s.png"] forState:UIControlStateHighlighted];
    clearRecord_.hidden = NO;
    [scrollBg addSubview:clearRecord_];
    
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(10, 156, 300, 222)];
    self.bgView.backgroundColor = [UIColor clearColor];
    bgView_.layer.borderWidth = 1;
    bgView_.layer.borderColor = [[UIColor colorWithRed:231/255.0 green:230/255.0 blue:225/255.0 alpha: 1.0f] CGColor];
    [scrollBg addSubview:self.bgView];
    
    noFav_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noFav.png"]];
    noFav_.frame = CGRectMake(self.view.frame.size.width/2-87, 106, 174, 12);
    
    noRecord_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noRecored.png"]];
    noRecord_.frame = CGRectMake(self.view.frame.size.width/2-87, 106, 174, 12);
    
    noPersonalList_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noPersonalList.png"]];
    noPersonalList_.frame = CGRectMake(self.view.frame.size.width/2-87, 106, 174, 12);
     
    self.recordTableList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 296, 42*6) style:UITableViewStylePlain];
    self.recordTableList.dataSource = self;
    self.recordTableList.delegate = self;
    self.recordTableList.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.recordTableList.tag = RECORD_TYPE;
    self.recordTableList.scrollEnabled = NO;
    self.recordTableList.backgroundColor = [UIColor clearColor];
    
    self.favTableList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 296, 74*3) style:UITableViewStylePlain];
    self.favTableList.dataSource = self;
    self.favTableList.delegate = self;
    self.favTableList.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.favTableList.tag = Fav_TYPE;
    self.favTableList.scrollEnabled = NO;
    self.favTableList.backgroundColor = [UIColor clearColor];
    
    myTableList_ = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 296, 74*3) style:UITableViewStylePlain];
    myTableList_.dataSource = self;
    myTableList_.delegate = self;
    myTableList_.separatorStyle = UITableViewCellSeparatorStyleNone;
    myTableList_.tag = MYLIST_TYPE;
    myTableList_.scrollEnabled = NO;
    myTableList_.backgroundColor = [UIColor clearColor];
    
    moreButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton_ addTarget:self action:@selector(seeMore:) forControlEvents:UIControlEventTouchUpInside];
    [moreButton_ setFrame:CGRectMake(245, 395, 64, 22)];
    [scrollBg addSubview:moreButton_];
    
    createList_ = [UIButton buttonWithType:UIButtonTypeCustom];
    createList_.frame = CGRectMake(245, 124, 64, 22);
    [createList_ addTarget:self action:@selector(createList:) forControlEvents:UIControlEventTouchUpInside];
    [createList_ setBackgroundImage:[UIImage imageNamed:@"icon_new wyatt single.png"] forState:UIControlStateNormal];
    [createList_ setBackgroundImage:[UIImage imageNamed:@"icon_new wyatt single_s.png"] forState:UIControlStateHighlighted];
    
    userId_ = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId];
    avatarImage_ = [[UIImageView alloc] initWithFrame:CGRectMake(11, 8, 33, 33)];
    avatarImage_.layer.borderWidth = 1;
    avatarImage_.layer.borderColor = [[UIColor colorWithRed:231/255.0 green:230/255.0 blue:225/255.0 alpha: 1.0f] CGColor];
    NSString *avatarUrl = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserAvatarUrl];
    [avatarImage_ setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:[UIImage imageNamed:@"self_icon"]];
    [scrollBg addSubview:avatarImage_];
    
    nameLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(55, 25, 200, 14)];
    nameLabel_.font = [UIFont systemFontOfSize:15];
    nameLabel_.text = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserNickName];
    nameLabel_.backgroundColor = [UIColor clearColor];
    [scrollBg addSubview:nameLabel_];
    
    //加载数据
    if ([sortedwatchRecordArray_ count]>0) {
        [self.bgView addSubview:recordTableList_];
    }
    else{
        [self.bgView setFrame:CGRectMake(12, 98, 296,0)];
        [self.bgView addSubview:noRecord_];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSinaWeibo) name:@"SINAWEIBOCHANGED" object:nil];
    
}
- (void)viewDidUnload{
    [super viewDidUnload];
    [subnameArray removeAllObjects];
    subnameArray = nil;
    clickedBtn = nil;
    bgView_ = nil;
    recordTableList_ = nil;
    favTableList_ = nil;
    myTableList_ = nil;
    moreButton_ = nil;
    avatarImage_ = nil;
    nameLabel_ = nil;
    createList_ = nil;
    noRecordBg_ = nil;
    button2_ = nil;
    button3_ = nil;
    noRecord_ = nil;
    noFav_ = nil;
    noPersonalList_ = nil;

}
- (void)viewWillAppear:(BOOL)animated{
    [CommonMotheds showNetworkDisAbledAlert:self.view];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    
    //request person data
    if (NO == button1_.enabled)
    {
        [self loadRecordData];
    }
    else if (NO == button2_.enabled)
    {
        [self loadMyFavsData];
    }
    else if (NO == button3_.enabled)
    {
        [self loadPersonalData];
    }
}


-(void)refreshSinaWeibo{
    NSString *avatarUrl = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserAvatarUrl];
    [avatarImage_ setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:[UIImage imageNamed:@"self_icon"]];
    nameLabel_.text = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserNickName];
}
- (void)loadRecordData
{
    MBProgressHUD*tempHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:tempHUD];
    tempHUD.labelText = @"加载中...";
    tempHUD.opacity = 0.5;
    [tempHUD show:YES];
    
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:@"watch_record"];
    if(cacheResult != nil){
        @try {
            [self parseWatchResultData:cacheResult];
        }
        @catch (NSException *exception) {
             NSLog(@"MineViewCintroller line:312 Exception: %@", exception); 
        }
        
    }
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:(NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId], @"userid", @"1", @"page_num", [NSNumber numberWithInt:10], @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathPlayHistory parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        [tempHUD hide:YES];
        [self parseWatchResultData:result];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        [tempHUD hide:YES];
        NSLog(@"%@", error);
       [CommonMotheds showInternetError:error inView:self.view];
    }];
    
}

- (void)parseWatchResultData:(id)result
{
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        [[CacheUtility sharedCache] putInCache:@"watch_record" result:result];
        NSArray *tempArr = (NSArray *)[result objectForKey:@"histories"];
        sortedwatchRecordArray_ =[NSMutableArray arrayWithArray:tempArr];
        for (NSDictionary *item in sortedwatchRecordArray_) {
            NSString *prodId = [item objectForKey:@"prod_id"];
            NSString *playNum = [item objectForKey:@"prod_subname"];
            NSString *videoType = [item objectForKey:@"prod_type"];
            if ([videoType isEqualToString:@"2"]) {
                [[CacheUtility sharedCache]putInCache:[NSString stringWithFormat:@"drama_epi_%@", prodId] result:[NSNumber numberWithInt:[playNum intValue]-1]];
            }
            
            int playbackTime = [[item objectForKey:@"playback_time"] intValue];
            int duration = [item objectForKey:@"duration"];
            if ((duration - playbackTime)>5) {
                [[CacheUtility sharedCache] putInCache:[NSString stringWithFormat:@"%@_%@",prodId,playNum] result:[NSNumber numberWithInt:playbackTime] ];
            }
            else{
                [[CacheUtility sharedCache] putInCache:[NSString stringWithFormat:@"%@_%@",prodId,playNum] result:[NSNumber numberWithInt:0] ];
            }
        }
        if (sortedwatchRecordArray_.count > 0) {
            [noRecord_ removeFromSuperview];
            clearRecord_.hidden = NO;
        }
        else{
            clearRecord_.hidden = YES;
        }
        if (!button1_.enabled) {
            [self refreshMineViewWithTag:button1_.tag];
        }
        
    }
}

-(void)search:(id)sender{
    SearchPreViewController *searchViewCotroller = [[SearchPreViewController alloc] init];
    searchViewCotroller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchViewCotroller animated:YES];
    
}

-(void)createList:(id)sender{
    CreateMyListOneViewController *createMyListOneViewController = [[CreateMyListOneViewController alloc] init];
    createMyListOneViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:createMyListOneViewController animated:YES];

}
-(void)seeMore:(id)sender{
    if (![CommonMotheds isNetworkEnbled]) {
        [UIUtility showNetWorkError:self.view];
        return;
    }
    if (!button1_.enabled) {
        MoreListViewController *moreListViewController = [[MoreListViewController alloc] initWithStyle:UITableViewStylePlain];
        if ([sortedwatchRecordArray_ count]>10) {
            NSMutableArray *temParr = [NSMutableArray arrayWithCapacity:10];
            for (int i = 0; i<10; i++) {
                [temParr addObject:[sortedwatchRecordArray_ objectAtIndex:i]];
            }
            moreListViewController.listArr = temParr;
        }
        else{
            moreListViewController.listArr = sortedwatchRecordArray_;
        }
        moreListViewController.type = RECORD_TYPE;
        [self presentViewController:[[CustomNavigationViewControllerPortrait alloc] initWithRootViewController:moreListViewController] animated:YES completion:nil];
    }
    else if (!button2_.enabled) {
        MoreListViewController *moreListViewController = [[MoreListViewController alloc] initWithStyle:UITableViewStylePlain];
        moreListViewController.listArr = favArr_;
        moreListViewController.type = Fav_TYPE;
        [self presentViewController:[[CustomNavigationViewControllerPortrait alloc] initWithRootViewController:moreListViewController] animated:YES completion:nil];
    }
    else if(!button3_.enabled){
        MoreListViewController *moreListViewController = [[MoreListViewController alloc] initWithStyle:UITableViewStylePlain];
        moreListViewController.listArr = myListArr_;
         moreListViewController.type = MYLIST_TYPE;
        [self presentViewController:[[CustomNavigationViewControllerPortrait alloc] initWithRootViewController:moreListViewController] animated:YES completion:nil];
    
    }

}


-(void)setting:(id)sender{
    IphoneSettingViewController *settingViewController = [[IphoneSettingViewController alloc] init];
    settingViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:settingViewController animated:YES];

}

-(void)Selectbutton:(id)sender{
    [CommonMotheds showNetworkDisAbledAlert:self.view];
    
    [self.recordTableList removeFromSuperview];
    [self.favTableList removeFromSuperview];
    [self.myTableList removeFromSuperview];
    [createList_ removeFromSuperview];
    [self.bgView setFrame:CGRectMake(12, 156, 296, 0)];
    [noRecord_ removeFromSuperview];
    [noFav_ removeFromSuperview];
    [noPersonalList_ removeFromSuperview];
    [moreButton_ removeFromSuperview];
    [moreButton_ setFrame:CGRectMake(245, 395, 64, 22)];
    button1_.enabled = YES;
    button2_.enabled = YES;
    button3_.enabled = YES;

    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        //播放纪录
        case 100:{
            button1_.enabled = NO;
            typeLabel_.image = [UIImage imageNamed:@"bifangjilu"];
            clearRecord_.hidden = NO;
            [self loadRecordData];
            break;
        }
        //我的收藏
        case 101:{
            button2_.enabled = NO;
           clearRecord_.hidden = YES;
            typeLabel_.image = [UIImage imageNamed:@"wodeshoucang"];
            [self loadMyFavsData];
            break;
        }
        //我的悦单
        case 102:{
            typeLabel_.image = [UIImage imageNamed:@"wodeyuedan"];
            clearRecord_.hidden = YES;
            button3_.enabled = NO;
            [self loadPersonalData];
            
            break;
        }
        default:
            break;
    }

}

- (void)refreshMineViewWithTag:(NSInteger)tag
{
    [self.recordTableList removeFromSuperview];
    [self.favTableList removeFromSuperview];
    [self.myTableList removeFromSuperview];
    switch (tag) {
        case 100:
        {
            if ([self.sortedwatchRecordArray count] <= 5) {
                
                [self.bgView setFrame:CGRectMake(12, 156, 296, 42*[sortedwatchRecordArray_ count])];
            }
            else {
                [self.bgView setFrame:CGRectMake(12, 156, 296, 42*5)];
                [moreButton_ setFrame:CGRectMake(245, 380, 64, 22)];
                [moreButton_ setBackgroundImage:[UIImage imageNamed:@"tab3_page1_see.png"] forState:UIControlStateNormal];
                [moreButton_ setBackgroundImage:[UIImage imageNamed:@"tab3_page1_see_s.png"] forState:UIControlStateHighlighted];
                [scrollBg addSubview:moreButton_];
            }
            
            if ([sortedwatchRecordArray_ count] == 0) {
                [self.bgView addSubview:noRecord_];
            }
            else{
                [self.bgView addSubview:self.recordTableList];
                [self.recordTableList reloadData];
            }
        }
            break;
        case 101:
        {
            if ([self.favArr count] <= 3) {
                [self.bgView setFrame:CGRectMake(12, 156, 296, 74*[favArr_ count])];

            }
            else {
                [self.bgView setFrame:CGRectMake(12, 156, 296, 74*3)];
                [moreButton_ setBackgroundImage:[UIImage imageNamed:@"tab3_page2_see.png"] forState:UIControlStateNormal];
                [moreButton_ setBackgroundImage:[UIImage imageNamed:@"tab3_page2_see_s.png"] forState:UIControlStateHighlighted];
                [scrollBg addSubview:moreButton_];
            }
            
            if ([favArr_ count]==0) {
                [self.bgView addSubview:noFav_];
            }
            else{
                [noFav_ removeFromSuperview];
                [self.bgView addSubview:self.favTableList];
                [self.favTableList reloadData];
            }
            
        }
            break;
        case 102:
        {
            if ([myListArr_ count] <= 3) {
                if ([myListArr_ count]== 0){
                    [self.bgView setFrame:CGRectMake(12, 156, 296, 0)];
                    [self.bgView addSubview:noPersonalList_];
                }
                else{
                    [noPersonalList_ removeFromSuperview];
                    [self.bgView setFrame:CGRectMake(12, 156, 296,74*[myListArr_ count])];
                    
                }
                
            
            }
            else {
                 [noPersonalList_ removeFromSuperview];
                [self.bgView setFrame:CGRectMake(12, 156, 296, 74*3)];
                [moreButton_ setBackgroundImage:[UIImage imageNamed:@"tab3_page3_see.png"] forState:UIControlStateNormal];
                [moreButton_ setBackgroundImage:[UIImage imageNamed:@"tab3_page3_see_s.png"] forState:UIControlStateHighlighted];
                [scrollBg addSubview:moreButton_];
            }
            
            
            [scrollBg addSubview:createList_];
            [self.bgView addSubview:myTableList_];
            [myTableList_ reloadData];
        }
            break;
            
        default:
            break;
    }
    
}

-(void)clearMyRecord{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"确定清除播放记录？" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    alert.tag = 10002;
    [alert show];
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag == RECORD_TYPE) {
        if ([sortedwatchRecordArray_ count] <= 5) {
            return [sortedwatchRecordArray_ count];
        }
        else{
            return 5;
        }
    }
    if (tableView.tag == Fav_TYPE) {
        if ([favArr_ count] <= 3) {
            return [favArr_ count];
        }
        else{
            return 3;
        }

    }
    if (tableView.tag == MYLIST_TYPE) {
        if ([myListArr_ count] <= 3) {
            if ([myListArr_ count] == 0) {
                return 0;
            }
            else{
               return [myListArr_ count];
            }
           
        }
        else{
            return 3;
        }
    }
    
    return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
        
    if (tableView.tag == RECORD_TYPE) {
        RecordListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[RecordListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }

        NSDictionary *infoDic = [sortedwatchRecordArray_ objectAtIndex:indexPath.row];
        cell.titleLab.text = [infoDic objectForKey:@"prod_name"];
        cell.titleLab.frame = CGRectMake(10, 5, 220, 15);

        cell.actors.text  = [self composeContent:infoDic];
        cell.actors.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [cell.actors setFrame:CGRectMake(12, 20, 200, 15)];
     
        [cell.date removeFromSuperview];
        cell.play.tag = indexPath.row;
        cell.play.hidden = NO;
        [cell.play addTarget:self action:@selector(continuePlay:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    else if (tableView.tag == Fav_TYPE){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        NSDictionary *infoDic = [favArr_ objectAtIndex:indexPath.row];
        
//        UIImageView *frame = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"listFrame.png"]];
//        frame.frame = CGRectMake(10, 7, 43, 64);
//        [cell.contentView addSubview:frame];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(11, 8, 40, 60)];
        [imageView setImageWithURL:[NSURL URLWithString:[infoDic objectForKey:@"content_pic_url"]] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
        [cell.contentView addSubview:imageView];
        
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(70, 8, 170, 15)];
        titleLab.font = [UIFont systemFontOfSize:14];
        titleLab.textColor = [UIColor colorWithRed:110.0/255 green:110.0/255 blue:110.0/255 alpha:1.0];
        titleLab.text = [infoDic objectForKey:@"content_name"];
        titleLab.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:titleLab];
        
        UILabel *actors = [[UILabel alloc] initWithFrame:CGRectMake(70, 26, 170, 15)];
        actors.text = [NSString stringWithFormat:@"主演：%@",[infoDic objectForKey:@"stars"]] ;
        actors.font = [UIFont systemFontOfSize:12];
        actors.textColor = [UIColor grayColor];
        actors.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:actors];
        
       UILabel *date = [[UILabel alloc] initWithFrame:CGRectMake(70, 40, 200, 15)];
        date.text = [NSString stringWithFormat:@"年代：%@",[infoDic objectForKey:@"publish_date"]];
        date.font = [UIFont systemFontOfSize:12];
        date.textColor = [UIColor grayColor];
        date.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:date];
        
    
        UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fengexian.png"]];
        line.frame = CGRectMake(0,73, 320, 1);
        [cell.contentView addSubview:line];
        
        UIView *selectedBg = [[UIView alloc] initWithFrame:cell.frame];
        selectedBg.backgroundColor = [UIColor colorWithRed:185.0/255 green:185.0/255 blue:174.0/255 alpha:0.4];
        cell.selectedBackgroundView = selectedBg;
        return cell;
    }
    else if (tableView.tag == MYLIST_TYPE){
        NSDictionary *infoDic = [myListArr_ objectAtIndex:indexPath.row];
        MyListCell *cell = [[MyListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell initCell:infoDic];
        
        UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fengexian.png"]];
        line.frame = CGRectMake(0, 73, cell.frame.size.width, 1);
        [cell.contentView addSubview:line];
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == RECORD_TYPE) {
        return 42;
    }
    return 74;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [CommonMotheds showNetworkDisAbledAlert:self.view];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView.tag == RECORD_TYPE) {
        NSDictionary *dic = [sortedwatchRecordArray_ objectAtIndex:indexPath.row];
        NSString *type = [dic objectForKey:@"prod_type"];
        if ([type isEqualToString:@"1"]) {
            IphoneMovieDetailViewController *detailViewController = [[IphoneMovieDetailViewController alloc] init];
            detailViewController.infoDic = dic;
            detailViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:detailViewController animated:YES];
        }
        else if ([type isEqualToString:@"2"]||[type isEqualToString:@"131"]){
            TVDetailViewController *detailViewController = [[TVDetailViewController alloc] init];
            detailViewController.infoDic = dic;
            detailViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:detailViewController animated:YES];}
        
        else if ([type isEqualToString:@"3"]){
            IphoneShowDetailViewController *detailViewController = [[IphoneShowDetailViewController alloc] init];
            detailViewController.infoDic = dic;
            detailViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:detailViewController animated:YES];
            
        }

    }
    else if (tableView.tag == Fav_TYPE){
        NSDictionary *dic = [favArr_ objectAtIndex:indexPath.row];
        NSString *type = [dic objectForKey:@"content_type"];
        if ([type isEqualToString:@"1"]) {
            IphoneMovieDetailViewController *detailViewController = [[IphoneMovieDetailViewController alloc] init];
            detailViewController.infoDic = [favArr_ objectAtIndex:indexPath.row];
            detailViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:detailViewController animated:YES];
        }
        else if ([type isEqualToString:@"2"]){
            TVDetailViewController *detailViewController = [[TVDetailViewController alloc] init];
            detailViewController.infoDic = [favArr_ objectAtIndex:indexPath.row];
            detailViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:detailViewController animated:YES];}
        
        else if ([type isEqualToString:@"3"]){
            IphoneShowDetailViewController *detailViewController = [[IphoneShowDetailViewController alloc] init];
            detailViewController.infoDic = [favArr_ objectAtIndex:indexPath.row];
            detailViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:detailViewController animated:YES];
        
        }
        
        
    }
    else if(tableView.tag == MYLIST_TYPE){
        NSDictionary *infoDic = [myListArr_ objectAtIndex:indexPath.row];
        NSMutableArray *items = [NSMutableArray arrayWithArray:[infoDic objectForKey:@"items"]];
        CreateMyListTwoViewController *createMyListTwoViewController = [[CreateMyListTwoViewController alloc] init];
        createMyListTwoViewController.topicId = [infoDic objectForKey:@"id"];
        createMyListTwoViewController.listArr = items;
        createMyListTwoViewController.type = [[infoDic objectForKey:@"prod_type"] intValue];
        createMyListTwoViewController.infoDic = [NSMutableDictionary dictionaryWithDictionary:infoDic];
        createMyListTwoViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:createMyListTwoViewController animated:YES];
        
    
    }


}
- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == RECORD_TYPE) {
        RecordListCell *cell = (RecordListCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.play.hidden = YES;
        
    }
}

- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == RECORD_TYPE) {
        RecordListCell *cell = (RecordListCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.play.hidden = NO;
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

    return YES;
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete){

        [CommonMotheds showNetworkDisAbledAlert:self.view];
        switch (tableView.tag) {
            case RECORD_TYPE:
            {
                NSDictionary *infoDic = [sortedwatchRecordArray_ objectAtIndex:indexPath.row];
                NSString *topicId = [infoDic objectForKey:@"id"];
                NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: topicId, @"history_id", nil];
                [[AFServiceAPIClient sharedClient] postPath:kPathHiddenPlay parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
                    [sortedwatchRecordArray_ removeObjectAtIndex:indexPath.row];
                    [tableView reloadData];
                    [self Selectbutton:button1_];
                } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                }];
                break;
            }
            case Fav_TYPE:
            {
                NSDictionary *infoDic = [favArr_ objectAtIndex:indexPath.row];
                NSString *topicId = [infoDic objectForKey:@"content_id"];
                NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: topicId, @"prod_id", nil];
                int contentType = [[infoDic objectForKey:@"content_type"] integerValue];
                if (contentType == DRAMA_TYPE || contentType == COMIC_TYPE) {
                    [self unSubscribingToChannels:topicId];
                }
                [[AFServiceAPIClient sharedClient] postPath:kPathProgramUnfavority parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
                    [favArr_ removeObjectAtIndex:indexPath.row];
                    [tableView reloadData];
                    [self Selectbutton:button2_];
                } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                }];
                break;
            }
            case MYLIST_TYPE:
            {
                NSDictionary *infoDic = [myListArr_ objectAtIndex:indexPath.row];
                NSString *topicId = [infoDic objectForKey:@"id"];
                if (topicId == nil) {
                    topicId = [infoDic objectForKey:@"topic_id"];
                }
                
                NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:topicId, @"topic_id", nil];
                [[AFServiceAPIClient sharedClient] postPath:kPathTopDelete parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
                    NSString *responseCode = [result objectForKey:@"res_code"];
                    if([responseCode isEqualToString:kSuccessResCode]){
                        [myListArr_ removeObjectAtIndex:indexPath.row];
                      
                        [myTableList_ reloadData];
                        [self Selectbutton:button3_];
                    }
                    else {
                        [UIUtility showSystemError:self.view];
                    }
                } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                    [UIUtility showSystemError:self.view];
                }];

                break;
            }
            default:
                break;
        }    
        
    }
}

- (void)unSubscribingToChannels:(NSString *)Id
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    NSArray *channels = [NSArray arrayWithObjects:[NSString stringWithFormat:@"CHANNEL_PROD_%@",Id], nil];
    
    [currentInstallation removeObjectsInArray:channels forKey:@"channels"];
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if (succeeded)
        {
            NSLog(@"Successfully subscribed to channel!");
        }
        else
        {
            NSLog(@"Failed to subscribe to broadcast channel; Error: %@",error);
        }
    }];
}

- (NSString *)composeContent:(NSDictionary *)item
{
    NSString *content;
   
    NSNumber *number = (NSNumber *)[item objectForKey:@"playback_time"];
    if ([[NSString stringWithFormat:@"%@", [item objectForKey:@"prod_type"]] isEqualToString:@"1"]) {
        content = [NSString stringWithFormat:@"已观看到 %@", [TimeUtility formatTimeInSecond:number.doubleValue]];
    } else if ([[NSString stringWithFormat:@"%@", [item objectForKey:@"prod_type"]] isEqualToString:@"2"]) {
        int subNum = [[item objectForKey:@"prod_subname"] intValue];
        content = [NSString stringWithFormat:@"已观看到第%d集 %@", subNum, [TimeUtility formatTimeInSecond:number.doubleValue]];
    } else if ([[NSString stringWithFormat:@"%@", [item objectForKey:@"prod_type"]] isEqualToString:@"3"]) {
        //int subNum = [[item objectForKey:@"prod_subname"] intValue]+1;
        content = [NSString stringWithFormat:@"已观看 《%@》 %@",[item objectForKey:@"prod_subname"],[TimeUtility formatTimeInSecond:number.doubleValue]];
    }
    return content;
}
    



-(void)continuePlay:(id)sender{
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([hostReach currentReachabilityStatus] == NotReachable){
        [UIUtility showNetWorkError:self.view];
        return;
    }    
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isWifiReachable)]){
        clickedBtn = (UIButton *)sender;
        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil
                                                           message:@"播放视频会消耗大量流量，您确定要在非WiFi环境下播放吗？"
                                                          delegate:self
                                                 cancelButtonTitle:@"取消"
                                                 otherButtonTitles:@"确定", nil];
        alertView.tag = 10001;
        [alertView show];
    } else {
        [self willPlayVideo:sender];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10001) {
        if(buttonIndex == 1){
            [self willPlayVideo:clickedBtn];
        }
    }
    if (alertView.tag == 10002) {
            if (buttonIndex == 0) {
                if (![CommonMotheds isNetworkEnbled]) {
                    [UIUtility showNetWorkError:self.view];
                    return;
                }
                for (NSDictionary *dic in sortedwatchRecordArray_) {
                    NSString *type = [dic objectForKey:@"prod_type"];
                    NSString *prodId = [dic objectForKey:@"prod_id"];
                    NSString *subName = [dic objectForKey:@"prod_subname"];
                    if ([type isEqualToString:@"1"]) {
                        [[CacheUtility sharedCache] removeObjectForKey:[NSString stringWithFormat:@"%@_%d",prodId,0]];
                    }
                    else if([type isEqualToString:@"2"]|| [type isEqualToString:@"3"]){
                        [[CacheUtility sharedCache] removeObjectForKey:[NSString stringWithFormat:@"%@_%@",prodId,subName]];
                    }
                    
                }
                NSString *userId = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId];
                NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: userId, @"user_id", nil];
                [[AFServiceAPIClient sharedClient] postPath:kPathRemoveAllPlay parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
                    [self loadRecordData];
                } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                }];
                
            }
    }

}

- (void)willPlayVideo:(UIButton *)btn
{
    int num = btn.tag;
    NSDictionary *item = [sortedwatchRecordArray_ objectAtIndex:num];
    int type = [[item objectForKey:@"prod_type"] intValue];
    NSString *prodId = [item objectForKey:@"prod_id"];
    IphoneWebPlayerViewController *iphoneWebPlayerViewController = [[IphoneWebPlayerViewController alloc] init];
    iphoneWebPlayerViewController.videoType = type;
    iphoneWebPlayerViewController.prodId = prodId;
    iphoneWebPlayerViewController.isPlayFromRecord = YES;
    iphoneWebPlayerViewController.continuePlayInfo = item;
    [self presentViewController:[[CustomNavigationViewController alloc] initWithRootViewController:iphoneWebPlayerViewController] animated:YES completion:nil];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
