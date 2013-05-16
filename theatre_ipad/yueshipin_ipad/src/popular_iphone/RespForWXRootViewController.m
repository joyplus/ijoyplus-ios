//
//  RespForWeChatViewController.m
//  yueshipin
//
//  Created by 08 on 13-4-2.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "RespForWXRootViewController.h"
#import "UIUtility.h"
#import "MBProgressHUD.h"
#import "CacheUtility.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "ContainerUtility.h"
#import "CMConstants.h"
#import "Reachability.h"

@interface RespForWXRootViewController ()

- (void)getHotData;
- (void)getFavData;
- (void)getRecData;

-(void)search:(NSString *)searchStr;

@end

@implementation RespForWXRootViewController
@synthesize delegate;
#pragma mark -
#pragma mark - lifeCycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    _strHotId = nil;
    searchBar_ = nil;
    _viewRespForWX = nil;
    _tableSearchHistory = nil;
    _arrHistory = nil;
}

- (void)loadView
{
    [super loadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"悅视频";
    
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_common.png"]];
    bg.userInteractionEnabled = YES;
    bg.frame = CGRectMake(0, 0, 320, kFullWindowHeight - 20 - 44);
    [self.view addSubview:bg];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 55, 44);
    backButton.backgroundColor = [UIColor clearColor];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"back_f.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
        
    _arrHistory = [[CacheUtility sharedCache] loadFromCache:@"serach_history"];
    
    UIImageView *imagview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_sou_suo"]];
    imagview.frame = CGRectMake(0, 0, self.view.bounds.size.width, 42);
    [self.view addSubview:imagview];
    
    searchBar_ = [[UISearchBar alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2-147, 6, 294, 30)];
    searchBar_.tintColor = [UIColor clearColor];
    searchBar_.placeholder = @"请输入片名/导演/主演";
    [[searchBar_.subviews objectAtIndex:0]removeFromSuperview];
    UITextField *searchField;
    NSUInteger numViews = [searchBar_.subviews count];
    for(int i = 0; i < numViews; i++)
    {
        if([[searchBar_.subviews objectAtIndex:i] isKindOfClass:[UITextField class]]) {
            searchField = [searchBar_.subviews objectAtIndex:i];
        }
        if([[searchBar_.subviews objectAtIndex:i] isKindOfClass:[UIButton class]])
        {
            [(UIButton *)[searchBar_.subviews objectAtIndex:i] setBackgroundImage:[UIImage imageNamed:@"sousuo_qu_xiao.png"] forState:UIControlStateNormal];
            [(UIButton *)[searchBar_.subviews objectAtIndex:i] setBackgroundImage:[UIImage imageNamed:@"sousuo_qu_xiao_s.png"] forState:UIControlStateHighlighted];
        }
    }
    
    if(!(searchField == nil))
    {
        //[searchField.leftView setHidden:YES];
        [searchField setBackground: [[UIImage imageNamed:@"rebo_sousuo_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(3, 2, 3, 2)] ];
        [searchField setBorderStyle:UITextBorderStyleNone];
    }
    searchBar_.delegate = self;
    [self.view addSubview:searchBar_];
    
    _tableSearchHistory = [[UITableView alloc] initWithFrame:CGRectMake(0, 41, self.view.bounds.size.width, 150)
                                                       style:UITableViewStylePlain];
    _tableSearchHistory.backgroundColor = [UIColor clearColor];
    _tableSearchHistory.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableSearchHistory.dataSource = self;
    _tableSearchHistory.delegate = self;
    
    
    _viewRespForWX = [[RespForWXRootView alloc] initWithFrame:\
                                    CGRectMake(0, \
                                               41, 320,\
                                               bg.frame.size.height -41)];
    _viewRespForWX.delegate = self;
    [self.view addSubview:_viewRespForWX];
    
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:@"movie_top_list"];

    NSString *responseCode = [cacheResult objectForKey:@"res_code"];
    if(responseCode == nil)
    {
        NSArray * resultArr = [cacheResult objectForKey:@"tops"];
        if (resultArr.count > 0)
        {
            NSDictionary *item = [resultArr objectAtIndex:0];
            _strHotId = [item objectForKey:@"id"];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //获取网络数据
    if (SEGMENT_VIEW_TYPE == _viewRespForWX.viewType)
    {
        if (DATA_TYPE_HOT == _viewRespForWX.dataType)
        {
            [self getHotData];
        }
        else if (DATA_TYPE_FAV == _viewRespForWX.dataType)
        {
            [self getFavData];
        }
        else
        {
            [self getRecData];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - private
- (void)back:(id)sender
{
    if (delegate && [delegate respondsToSelector:@selector(backButtonClick)])
    {
        [delegate backButtonClick];
    }
}

- (void)getHotData
{   
    MBProgressHUD *tempHUD;
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:[NSString stringWithFormat:@"top_detail_list%@", _strHotId]];
    if(cacheResult != nil)
    {
        NSString *responseCode = [cacheResult objectForKey:@"res_code"];
        if(responseCode == nil)
        {
            NSArray *tempTopsArray = [cacheResult objectForKey:@"items"];
            if(tempTopsArray.count > 0)
            {
                [[CacheUtility sharedCache] putInCache:[NSString stringWithFormat:@"top_detail_list%@", _strHotId] result:cacheResult];
                
                [_viewRespForWX refreshTableView:tempTopsArray];
            }
        }
        else
        {
            [UIUtility showSystemError:self.view];
        }
    }
    else
    {
        if(tempHUD == nil)
        {
            tempHUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:tempHUD];
            tempHUD.labelText = @"加载中...";
            tempHUD.opacity = 0.5;
            [tempHUD show:YES];
        }
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: @"1", @"page_num", [NSNumber numberWithInt:20], @"page_size", _strHotId, @"top_id", nil];
        [[AFServiceAPIClient sharedClient] getPath:kPathTopItems parameters:parameters success:^(AFHTTPRequestOperation *operation, id result)
         {
             NSString *responseCode = [result objectForKey:@"res_code"];
             if(responseCode == nil)
             {
                 NSArray *tempTopsArray = [result objectForKey:@"items"];
                 if(tempTopsArray.count > 0)
                 {
                     [[CacheUtility sharedCache] putInCache:[NSString stringWithFormat:@"top_detail_list%@", _strHotId] result:result];
                     
                     [_viewRespForWX refreshTableView:tempTopsArray];
                 }
             }
             else
             {
                 [UIUtility showSystemError:self.view];
             }
             [tempHUD hide:YES];
             
         } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
             [tempHUD hide:YES];
         }];
        
    }
}

- (void)getFavData
{
    MBProgressHUD*tempHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:tempHUD];
    tempHUD.labelText = @"加载中...";
    tempHUD.opacity = 0.5;
    [tempHUD show:YES];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:(NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId], @"userid", @"1", @"page_num", [NSNumber numberWithInt:20], @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathUserFavorities parameters:parameters success:^(AFHTTPRequestOperation *operation, id result)
    {
        NSString *responseCode = [result objectForKey:@"res_code"];
        [tempHUD hide:YES];
        if(responseCode == nil)
        {
            NSArray *tempTopsArray = [result objectForKey:@"favorities"];
            [_viewRespForWX refreshTableView:tempTopsArray];
            [tempHUD hide:YES];
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error)
    {
        [_viewRespForWX refreshTableView:nil];
        [tempHUD hide:YES];
    }];
}

- (void)getRecData
{
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:@"watch_record"];
    if(cacheResult != nil)
    {
        @try
        {
            NSString *responseCode = [cacheResult objectForKey:@"res_code"];
            if(responseCode == nil)
            {
                [[CacheUtility sharedCache] putInCache:@"watch_record" result:cacheResult];
                [_viewRespForWX refreshTableView:[cacheResult objectForKey:@"histories"]];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"MineViewCintroller line:312 Exception: %@", exception);
        }
        
    }
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:(NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId], @"userid", @"1", @"page_num", [NSNumber numberWithInt:10], @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathPlayHistory parameters:parameters success:^(AFHTTPRequestOperation *operation, id result)
    {
        [[CacheUtility sharedCache] putInCache:@"watch_record" result:result];
        [_viewRespForWX refreshTableView:[result objectForKey:@"histories"]];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error)
     {
         [_viewRespForWX refreshTableView:nil];
    }];
}

-(void)search:(NSString *)searchStr
{
    NSMutableArray * historyArr = [NSMutableArray arrayWithArray:[[CacheUtility sharedCache] loadFromCache:@"serach_history"]];
    
    BOOL isHave = NO;
    for (NSString *str in historyArr)
    {
        if ([str isEqualToString:searchStr])
        {
            isHave = YES;
            break;
        }
    }
    if (!isHave)
    {
        [historyArr addObject:searchStr];
    }
    [[CacheUtility sharedCache] putInCache:@"serach_history" result:historyArr];
    
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([hostReach currentReachabilityStatus] == NotReachable)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"网络异常，请检查网络。"
                                                       delegate:self
                                              cancelButtonTitle:@"我知道了"
                                              otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    MBProgressHUD  *tempHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:tempHUD];
    tempHUD.labelText = @"加载中...";
    tempHUD.opacity = 0.5;
    [tempHUD show:YES];
    NSString *searchKey = [searchStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:searchKey, @"keyword", @"1", @"page_num", [NSNumber numberWithInt:20], @"page_size", @"1,2,3,131", @"type", nil];
    
    [[AFServiceAPIClient sharedClient] postPath:kPathSearch parameters:parameters success:^(AFHTTPRequestOperation *operation, id result)
     {
         NSString *responseCode = [result objectForKey:@"res_code"];
         if(responseCode == nil)
         {
             NSArray * searchResult = [result objectForKey:@"results"];
             [_viewRespForWX refreshTableView:searchResult];
         }
         
         [tempHUD hide:YES];
     } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error)
     {
         [_viewRespForWX refreshTableView:nil];
         [tempHUD hide:YES];
     }];
    
    [searchBar_ resignFirstResponder];
    if (_tableSearchHistory.superview)
    {
        [_tableSearchHistory removeFromSuperview];
    }
    
    for (id view in searchBar_.subviews)
    {
        if ([view isKindOfClass:[UIButton class]])
        {
            ((UIButton *)view).enabled = YES;
        }
    }
    
}

#pragma mark -
#pragma mark - RespForWXDetailViewControllerDelegate

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)RespVideoContent:(NSDictionary *)data
{
    if (delegate && [delegate respondsToSelector:@selector(shareVideoResp:)])
    {
        [delegate shareVideoResp:data];
    }
    if (delegate && [delegate respondsToSelector:@selector(removeRespForWXRootView)])
    {
        [delegate removeRespForWXRootView];
    }
}

#pragma mark -
#pragma mark - RespForWXRootViewDelegate
- (void)segmentBtnClicked:(NSInteger)type
{
    switch (type)
    {
        case DATA_TYPE_HOT:
        {
            [self getHotData];
        }
            break;
            
        case DATA_TYPE_FAV:
        {
            [self getFavData];
        }
            break;
            
        case DATA_TYPE_REC:
        {
            [self getRecData];
        }
            break;
        default:
            break;
    }
}

- (void)gotoMoviewDetail:(NSDictionary *)data
{
    RespForWXDetailViewController * ctrl = [[RespForWXDetailViewController alloc] init];
    ctrl.dicDataSource = data;
    ctrl.delegate = self;
    [self.navigationController pushViewController:ctrl animated:YES];
}

#pragma mark -
#pragma mark - SearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self search:searchBar.text];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    if (!_tableSearchHistory.superview)
    {
        [self.view addSubview:_tableSearchHistory];
        [_tableSearchHistory reloadData];
    }
    
    [_viewRespForWX setViewType:SEARCH_VIEW_TYPE];
    
    [searchBar setShowsCancelButton:YES animated:YES];
    for (id view in searchBar.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            [(UIButton *)view  setBackgroundImage:[UIImage imageNamed:@"sousuo_qu_xiao.png"] forState:UIControlStateNormal];
            [(UIButton *)view setBackgroundImage:[UIImage imageNamed:@"sousuo_qu_xiao_s.png"] forState:UIControlStateHighlighted];
            [(UIButton *)view setTitle:nil forState:UIControlStateNormal];
            [(UIButton *)view setTitle:nil forState:UIControlStateHighlighted];
        }
    }
    
    
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    if (_tableSearchHistory.superview)
    {
        [_tableSearchHistory removeFromSuperview];
    }
    
    if ([searchBar isFirstResponder])
    {
        [searchBar resignFirstResponder];
        for (id view in searchBar.subviews) {
            if ([view isKindOfClass:[UIButton class]]) {
                ((UIButton *)view).enabled = YES;
            }
        }
    }
    [searchBar setShowsCancelButton:NO animated:YES];
    [_viewRespForWX setViewType:SEGMENT_VIEW_TYPE];
    searchBar_.text = nil;
}

#pragma mark -
#pragma mark - TableViewDelegate & TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrHistory.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"historyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UIImageView *line = nil;
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1];
    }
    for (UIView *view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }
    cell.textLabel.text = [_arrHistory objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 29, self.view.bounds.size.width, 1)];
    line.backgroundColor = [UIColor clearColor];
    line.image = [UIImage imageNamed:@"fengexian.png"];
    [cell.contentView addSubview:line];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self search:[_arrHistory objectAtIndex:indexPath.row]];
    if (_tableSearchHistory.superview)
    {
        [_tableSearchHistory removeFromSuperview];
    }
}

@end
