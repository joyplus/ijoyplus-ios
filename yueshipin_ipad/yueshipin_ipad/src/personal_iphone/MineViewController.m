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
@synthesize noRecord = noRecord_;
@synthesize noFav = noFav_;
@synthesize noPersonalList = noPersonalList_;

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
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:(NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId], @"userid", @"1", @"page_num", [NSNumber numberWithInt:20], @"page_size", nil];
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
            [self Selectbutton:button2_];
        }
        [favTableList_ reloadData];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        if(self.favArr == nil){
            self.favArr = [[NSMutableArray alloc]initWithCapacity:10];
        }
        [tempHUD hide:YES];
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
                [myTableList_ reloadData];
            }
            
        }
        
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
       
       [tempHUD hide:YES];
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
    [leftButton setImage:[UIImage imageNamed:@"top_search_common.png"] forState:UIControlStateNormal];
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton addTarget:self action:@selector(setting:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(0, 0, 40, 30);
    rightButton.backgroundColor = [UIColor clearColor];
    [rightButton setImage:[UIImage imageNamed:@"top_setting_common.png"] forState:UIControlStateNormal];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    button1_ = [UIButton buttonWithType:UIButtonTypeCustom];
    button1_.frame = CGRectMake(12, 40, 99, 51);
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
    button2_.frame = CGRectMake(111, 40, 99, 51);
    button2_.tag = 101;
    button2_.adjustsImageWhenDisabled = NO;
    
    button3_ = [UIButton buttonWithType:UIButtonTypeCustom];
    [button3_ addTarget:self action:@selector(Selectbutton:) forControlEvents:UIControlEventTouchUpInside];
    [button3_ setBackgroundImage:[UIImage imageNamed:@"tab3_page1_icon3.png"] forState:UIControlStateNormal];
    [button3_ setBackgroundImage:[UIImage imageNamed:@"tab3_page1_icon3_s.png"] forState:UIControlStateHighlighted];
    [button3_ setBackgroundImage:[UIImage imageNamed:@"tab3_page1_icon3_s.png"]forState:UIControlStateDisabled];
    button3_.frame = CGRectMake(210, 40, 99, 51);
    button3_.tag = 102;
    button3_.adjustsImageWhenDisabled = NO;
     
    [self.view addSubview:button1_];
    [self.view addSubview:button2_];
    [self.view addSubview:button3_];
    
   [self Selectbutton:button1_];
        
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(12, 98, 296, 180)];
    self.bgView.backgroundColor = [UIColor whiteColor];
    bgView_.layer.borderWidth = 1;
    bgView_.layer.borderColor = [[UIColor colorWithRed:231/255.0 green:230/255.0 blue:225/255.0 alpha: 1.0f] CGColor];
    [self.view addSubview:self.bgView];
    
    noFav_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noFav.png"]];
    noFav_.frame = CGRectMake(0, 0, 296, 180);
    
    noRecord_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noRecored.png"]];
    noRecord_.frame = CGRectMake(0, 0, 296, 180);
    
    noPersonalList_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noPersonalList.png"]];
    noPersonalList_.frame = CGRectMake(0, 45, 296, 180);
     
    self.recordTableList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 296, 180) style:UITableViewStylePlain];
    self.recordTableList.dataSource = self;
    self.recordTableList.delegate = self;
    self.recordTableList.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.recordTableList.tag = RECORD_TYPE;
    self.recordTableList.scrollEnabled = NO;
    self.recordTableList.backgroundColor = [UIColor clearColor];
    
    self.favTableList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 296, 180) style:UITableViewStylePlain];
    self.favTableList.dataSource = self;
    self.favTableList.delegate = self;
    self.favTableList.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.favTableList.tag = Fav_TYPE;
    self.favTableList.scrollEnabled = NO;
    self.favTableList.backgroundColor = [UIColor clearColor];
    
    myTableList_ = [[UITableView alloc] initWithFrame:CGRectMake(0, 37, 296, 180) style:UITableViewStylePlain];
    myTableList_.dataSource = self;
    myTableList_.delegate = self;
    myTableList_.separatorStyle = UITableViewCellSeparatorStyleNone;
    myTableList_.tag = MYLIST_TYPE;
    myTableList_.scrollEnabled = NO;
    myTableList_.backgroundColor = [UIColor clearColor];
    
    
    moreView_ = [[UIView alloc] initWithFrame:CGRectMake(12, 290, 296, 45)];
    moreView_.backgroundColor = [UIColor whiteColor];
    moreView_.layer.borderWidth = 1;
    moreView_.layer.borderColor = [[UIColor colorWithRed:231/255.0 green:230/255.0 blue:225/255.0 alpha: 1.0f] CGColor];
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
    avatarImage_.layer.borderWidth = 1;
    avatarImage_.layer.borderColor = [[UIColor colorWithRed:231/255.0 green:230/255.0 blue:225/255.0 alpha: 1.0f] CGColor];
    NSString *avatarUrl = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserAvatarUrl];
    [avatarImage_ setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:[UIImage imageNamed:@"self_icon"]];
    [self.view addSubview:avatarImage_];
    
    nameLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(75, 18, 200, 14)];
    nameLabel_.font = [UIFont systemFontOfSize:15];
    nameLabel_.text = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserNickName];
    nameLabel_.backgroundColor = [UIColor clearColor];
    [self.view addSubview:nameLabel_];
    
    //加载数据
    [self loadMyFavsData];
    [self loadPersonalData];
    [self loadRecordData];
    if ([sortedwatchRecordArray_ count]>0) {
        [self.bgView addSubview:recordTableList_];
    }
    else{
        [self.bgView setFrame:CGRectMake(12, 98, 296, 60*[sortedwatchRecordArray_ count])];
        [self.bgView addSubview:noRecord_];
    }
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(addDone:) name:@"Update MineViewController" object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(refreshFav) name:@"REFRESH_FAV" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordListReload) name:WATCH_HISTORY_REFRESH object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSinaWeibo) name:@"SINAWEIBOCHANGED" object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
}


-(void)refreshSinaWeibo{
    NSString *avatarUrl = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserAvatarUrl];
    [avatarImage_ setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:[UIImage imageNamed:@"self_icon"]];
    nameLabel_.text = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserNickName];
    [self loadMyFavsData];
    [self loadPersonalData];
    [self loadRecordData];
}
- (void)loadRecordData
{
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
        [self parseWatchResultData:result];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
       
    }];
    
}

- (void)parseWatchResultData:(id)result
{
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        [[CacheUtility sharedCache] putInCache:@"watch_record" result:result];
        sortedwatchRecordArray_ =[NSMutableArray arrayWithArray:(NSArray *)[result objectForKey:@"histories"]];
        //if(sortedwatchRecordArray_.count > 0){
            //if (!button1_.enabled) {
            [self Selectbutton:button1_];
           // }
            [recordTableList_ reloadData];
            
           
        //}
    }
}

-(void)recordListReload{
    [self loadRecordData];
    if (!button1_.enabled) {
        [self Selectbutton:button1_];
    }
    [recordTableList_ reloadData];
    

}
-(void)refreshFav{
    [self loadMyFavsData];
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
    [self Selectbutton:button3_];

}
-(void)createList:(id)sender{
    CreateMyListOneViewController *createMyListOneViewController = [[CreateMyListOneViewController alloc] init];
    createMyListOneViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:createMyListOneViewController animated:YES];

}
-(void)seeMore:(id)sender{
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

    [self.recordTableList removeFromSuperview];
    [self.favTableList removeFromSuperview];
    [self.myTableList removeFromSuperview];
    [createList_ removeFromSuperview];
    [self.bgView setFrame:CGRectMake(12, 98, 296, 180)];
    [moreView_ setFrame:CGRectMake(12, 290, 296, 45)];
    [noRecord_ removeFromSuperview];
    [noFav_ removeFromSuperview];
    [noPersonalList_ removeFromSuperview];
    
    button1_.enabled = YES;
    button2_.enabled = YES;
    button3_.enabled = YES;

    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        //播放纪录
        case 100:{
            button1_.enabled = NO;
                if ([self.sortedwatchRecordArray count] <= 3) {
                    
                    [moreView_ removeFromSuperview];
                    [self.bgView setFrame:CGRectMake(12, 98, 296, 60*[sortedwatchRecordArray_ count])];
                }
                else {
                    [moreButton_ setBackgroundImage:[UIImage imageNamed:@"tab3_page1_see.png"] forState:UIControlStateNormal];
                    [moreButton_ setBackgroundImage:[UIImage imageNamed:@"tab3_page1_see_s.png"] forState:UIControlStateHighlighted];
                    [self.view addSubview:moreView_];
                }

                if ([sortedwatchRecordArray_ count] == 0) {
                    [self.bgView addSubview:noRecord_];
                }
                else{
                    [self.bgView addSubview:self.recordTableList];
                    [self.recordTableList reloadData];
                }
                    
                
            break;
        }
        //我的收藏
        case 101:{
            button2_.enabled = NO;
            if ([self.favArr count] <= 3) {
                [self.bgView setFrame:CGRectMake(12, 98, 296, 60*[favArr_ count])];
                [moreView_ removeFromSuperview];
            }
            else {
                [moreButton_ setBackgroundImage:[UIImage imageNamed:@"tab3_page2_see.png"] forState:UIControlStateNormal];
                [moreButton_ setBackgroundImage:[UIImage imageNamed:@"tab3_page2_see_s.png"] forState:UIControlStateHighlighted];
               
                [self.view addSubview:moreView_];
            }

            if ([favArr_ count]==0) {
                [self.bgView addSubview:noFav_];
            }
            else{
                [self.bgView addSubview:self.favTableList];
                [self.favTableList reloadData];
            }
            
           
            break;
        }
        //我的悦单
        case 102:{
            button3_.enabled = NO;
            if ([myListArr_ count] <= 3) {
                if ([myListArr_ count]== 0){
                    [self.bgView setFrame:CGRectMake(12, 98, 296, 44)];
                    [self.bgView addSubview:noPersonalList_];
                }
                else{
                    [self.bgView setFrame:CGRectMake(12, 98, 296, 37+ 60*[myListArr_ count])];
                }
                
                [moreView_ removeFromSuperview];
            }
            else {
                [self.bgView setFrame:CGRectMake(12, 98, 296, 37+ 60*3)];
                [moreButton_ setBackgroundImage:[UIImage imageNamed:@"tab3_page3_see.png"] forState:UIControlStateNormal];
                [moreButton_ setBackgroundImage:[UIImage imageNamed:@"tab3_page3_see_s.png"] forState:UIControlStateHighlighted];
                [moreView_ setFrame:CGRectMake(12, 320, 296, 45)];
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

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSDictionary *infoDic = [sortedwatchRecordArray_ objectAtIndex:indexPath.row];
        cell.titleLab.text = [infoDic objectForKey:@"prod_name"];
        cell.titleLab.frame = CGRectMake(10, 24, 220, 15);

        cell.actors.text  = [self composeContent:infoDic];
        [cell.actors setFrame:CGRectMake(12, 40, 200, 15)];
     
        [cell.date removeFromSuperview];
        cell.play.tag = indexPath.row;
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
        
        UIImageView *frame = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"listFrame.png"]];
        frame.frame = CGRectMake(14, 6, 39, 49);
        [cell.contentView addSubview:frame];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 7, 36, 45)];
        [imageView setImageWithURL:[NSURL URLWithString:[infoDic objectForKey:@"content_pic_url"]] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
        [cell.contentView addSubview:imageView];
        
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(70, 8, 170, 15)];
        titleLab.font = [UIFont systemFontOfSize:14];
        titleLab.text = [infoDic objectForKey:@"content_name"];
        titleLab.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:titleLab];
        
        UILabel *actors = [[UILabel alloc] initWithFrame:CGRectMake(70, 26, 170, 15)];
        actors.text = [NSString stringWithFormat:@"主演：%@",[infoDic objectForKey:@"stars"]] ;
        actors.font = [UIFont systemFontOfSize:12];
        actors.textColor = [UIColor grayColor];
        actors.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:actors];
        
       UILabel *date = [[UILabel alloc] initWithFrame:CGRectMake(70, 38, 200, 15)];
        date.text = [NSString stringWithFormat:@"年代：%@",[infoDic objectForKey:@"publish_date"]];
        date.font = [UIFont systemFontOfSize:12];
        date.textColor = [UIColor grayColor];
        date.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:date];
        
               
        UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_fen_ge_xian.png"]];
        line.frame = CGRectMake(0, 59, 320, 1);
        [cell.contentView addSubview:line];
        return cell;
    }
    else if (tableView.tag == MYLIST_TYPE){
        RecordListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[RecordListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }

    
        NSDictionary *infoDic = [myListArr_ objectAtIndex:indexPath.row];
        NSMutableArray *items = (NSMutableArray *)[infoDic objectForKey:@"items"];
        cell.titleLab.text = [infoDic objectForKey:@"name"];
        if (items != nil && [items count] != 0) {
            NSDictionary *item = [items objectAtIndex:0];
            cell.actors.text = [item objectForKey:@"prod_name"];
            [cell.actors setFrame:CGRectMake(12, 33, 200, 15)];
            cell.date.text = @"...";
            [cell.date setFrame:CGRectMake(14, 42, 200, 15)];
        }
       
        [cell.play  removeFromSuperview];
        return cell;
    
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
    if (tableView.tag == Fav_TYPE){
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
        createMyListTwoViewController.listArr = items;
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

        switch (tableView.tag) {
            case RECORD_TYPE:
            {
                NSDictionary *infoDic = [sortedwatchRecordArray_ objectAtIndex:indexPath.row];
                NSString *topicId = [infoDic objectForKey:@"prod_id"];
                NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: topicId, @"prod_id", nil];
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

- (NSString *)composeContent:(NSDictionary *)item
{
    NSString *content;
   
    NSNumber *number = (NSNumber *)[item objectForKey:@"playback_time"];
    if ([[NSString stringWithFormat:@"%@", [item objectForKey:@"prod_type"]] isEqualToString:@"1"]) {
        content = [NSString stringWithFormat:@"已观看到 %@", [TimeUtility formatTimeInSecond:number.doubleValue]];
    } else if ([[NSString stringWithFormat:@"%@", [item objectForKey:@"prod_type"]] isEqualToString:@"2"]) {
        int subNum = [[item objectForKey:@"prod_subname"] intValue]+1;
        content = [NSString stringWithFormat:@"已观看到第%d集 %@", subNum, [TimeUtility formatTimeInSecond:number.doubleValue]];
    } else if ([[NSString stringWithFormat:@"%@", [item objectForKey:@"prod_type"]] isEqualToString:@"3"]) {
        //int subNum = [[item objectForKey:@"prod_subname"] intValue]+1;
        content = [NSString stringWithFormat:@"已观看 %@", [TimeUtility formatTimeInSecond:number.doubleValue]];
    }
    return content;
}
    



-(void)continuePlay:(id)sender{
    MBProgressHUD*tempHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:tempHUD];
    tempHUD.labelText = @"加载中...";
    tempHUD.opacity = 0.5;
    [tempHUD show:YES];
    int num = ((UIButton *)sender).tag;
    NSDictionary *item = [sortedwatchRecordArray_ objectAtIndex:num];
    int type = [[item objectForKey:@"prod_type"] intValue];
    NSString *prodId = [item objectForKey:@"prod_id"];

    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:prodId, @"prod_id", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathProgramView parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        [tempHUD hide:YES];
        NSDictionary *videoInfo = nil;
        if (type == 1) {
         videoInfo = (NSDictionary *)[result objectForKey:@"movie"];
        }
        else if(type == 2){
         videoInfo = (NSDictionary *)[result objectForKey:@"tv"];
        }
        else if (type == 3){
         videoInfo = (NSDictionary *)[result objectForKey:@"show"];
        }
        IphoneWebPlayerViewController *iphoneWebPlayerViewController = [[IphoneWebPlayerViewController alloc] init];
        iphoneWebPlayerViewController.playNum = [[item objectForKey:@"prod_subname"] intValue];
        iphoneWebPlayerViewController.nameStr = [item objectForKey:@"prod_name"];
        iphoneWebPlayerViewController.episodesArr =  [videoInfo objectForKey:@"episodes"];
        iphoneWebPlayerViewController.videoType = type;
        iphoneWebPlayerViewController.prodId = prodId;
        iphoneWebPlayerViewController.playBackTime = (NSNumber *)[item objectForKey:@"playback_time"];
        [self presentViewController:[[CustomNavigationViewController alloc] initWithRootViewController:iphoneWebPlayerViewController] animated:YES completion:nil];
            
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
       [tempHUD hide:YES];
    }];

    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
