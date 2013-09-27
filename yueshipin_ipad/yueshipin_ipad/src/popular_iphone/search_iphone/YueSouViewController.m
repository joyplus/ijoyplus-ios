//
//  YueSouViewController.m
//  yueshipin
//
//  Created by huokun on 13-9-9.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "YueSouViewController.h"
#import "CommonHeader.h"
#import "AFYueSearchAPIClient.h"
#import "YueSouWebViewController.h"

#define YUE_SEARCH_URL          ([AppDelegate instance].internetSearchUrl)//(@"http://www.lesou.org/search.php?wd=")
#define EXPLAIN_YUESOU_STRING   (@"悦搜的搜索结果将以网页形式展示,您可以在影片详情页面点击\"转屏推电视\",将大片投放到电视上观看!")

#define HISTORY_LIST    (1132)
#define SEARCH_HISTORY  (@"yueSou_History")
#define HOTKEY_CACHE    (@"yueSou_hotkey")

@interface YueSouViewController ()
@property (nonatomic, strong) NSMutableArray * hotkeysArray;
@property (nonatomic, strong) NSMutableArray * searchHistory;
- (void)search:(NSString *)key;
@end

@implementation YueSouViewController
@synthesize hotkeysArray,searchHistory;
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
	// Do any additional setup after loading the view.
    
    self.title = @"悦搜";
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 55, 44);
    backButton.backgroundColor = [UIColor clearColor];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"back_f.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_common.png"]];
    bg.userInteractionEnabled = YES;
    bg.frame = CGRectMake(0, 0, 320, kFullWindowHeight);
    [self.view addSubview:bg];
    
    UIImageView * topImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"YueSou_explain"]];
    topImage.frame = CGRectMake(0, 0, 320, 70);
    [self.view addSubview:topImage];
    
    UIImageView *imagview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_sou_suo"]];
    imagview.frame = CGRectMake(0, 0, self.view.bounds.size.width, 42);
    [self.view addSubview:imagview];
    searchBar_ = [[UISearchBar alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2-147, 6, 294, 29)];
    searchBar_.backgroundColor = [UIColor clearColor];
    searchBar_.tintColor = [UIColor clearColor];
    searchBar_.placeholder = @" 请输入片名/导演/主演";
    //[[searchBar_.subviews objectAtIndex:0]removeFromSuperview];
    UITextField *searchField;
    NSUInteger numViews = [searchBar_.subviews count];
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
    {
        //[searchBar_ setBackgroundImage:[UIImage imageNamed:@"shuru_kuang_bg.png"] forBarMetrics:UIBarMetricsDefault];
        for (UIView *subView in searchBar_.subviews){
            for (UIView *secLeveSubView in subView.subviews){
                if ([secLeveSubView isKindOfClass:[UITextField class]])
                {
                    searchField = (UITextField *)secLeveSubView;
                    break;
                }
                else if ([secLeveSubView isKindOfClass:[UIView class]])
                {
                    [secLeveSubView removeFromSuperview];
                }
            }
        }
        [searchField setBackground: [[UIImage imageNamed:@"shuru_kuang_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 13,14, 13)] ];
    }
    else
    {
        [[searchBar_.subviews objectAtIndex:0]removeFromSuperview];
        numViews = [searchBar_.subviews count];
        for(int i = 0; i < numViews; i++) {
            if([[searchBar_.subviews objectAtIndex:i] isKindOfClass:[UITextField class]]) {
                searchField = [searchBar_.subviews objectAtIndex:i];
            }
            if([[searchBar_.subviews objectAtIndex:i] isKindOfClass:[UIButton class]]){
                
                //            [(UIButton *)[searchBar_.subviews objectAtIndex:i] setBackgroundImage:[UIImage imageNamed:@"sousuo_qu_xiao.png"] forState:UIControlStateNormal];
                //            [(UIButton *)[searchBar_.subviews objectAtIndex:i] setBackgroundImage:[UIImage imageNamed:@"sousuo_qu_xiao_s.png"] forState:UIControlStateHighlighted];0
                
            }
        }
        if(!(searchField == nil)) {
            //[searchField.leftView setHidden:YES];
            [searchField setBackground: [[UIImage imageNamed:@"shuru_kuang_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 13,14, 13)] ];
            [searchField setBorderStyle:UITextBorderStyleNone];
        }
    }
    searchBar_.delegate = self;
    [self.view addSubview:searchBar_];
    
    UILabel * text_yuesou = [[UILabel alloc] initWithFrame:CGRectMake(20, 70, 280, 65)];
    text_yuesou.backgroundColor = [UIColor clearColor];
    text_yuesou.numberOfLines = 0;
    text_yuesou.text = EXPLAIN_YUESOU_STRING;
    text_yuesou.textColor = [UIColor grayColor];
    text_yuesou.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:text_yuesou];
    
    UIImageView * common = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"commonViewed"]];
    common.frame = CGRectMake(0, 135, 320, 30);
    common.backgroundColor = [UIColor clearColor];
    [self.view addSubview:common];
    
    table_ = [[UITableView alloc] initWithFrame:CGRectMake(10, 172, 300, kCurrentWindowHeight - 172 - 44 - 10)
                                          style:UITableViewStylePlain];
    table_.delegate = self;
    table_.dataSource = self;
    table_.backgroundColor = [UIColor clearColor];
    table_.separatorColor = [UIColor clearColor];
    [self.view addSubview:table_];
    table_.showsVerticalScrollIndicator = NO;
    
    historyTable_ = [[UITableView alloc] initWithFrame:CGRectMake(0, 41, self.view.bounds.size.width, kCurrentWindowHeight-216-44-42)
                                                 style:UITableViewStylePlain];
    historyTable_.backgroundColor = [UIColor whiteColor];
    historyTable_.separatorStyle = UITableViewCellSeparatorStyleNone;
    historyTable_.dataSource = self;
    historyTable_.delegate = self;
    historyTable_.tag = HISTORY_LIST;
    
    hotkeysArray = [[NSMutableArray alloc] initWithArray:[[CacheUtility sharedCache] loadFromCache:HOTKEY_CACHE]];
    searchHistory = [[NSMutableArray alloc] initWithArray:[[CacheUtility sharedCache] loadFromCache:SEARCH_HISTORY]];
    
    [self getHotKey];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - private
- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)fileName:(NSString *)tStr
{
    NSRange firstRange = [tStr rangeOfString:@"["];
    NSRange lastRange = [tStr rangeOfString:@"]"];
    if (firstRange.location == NSNotFound
        || lastRange.location == NSNotFound)
    {
        return nil;
    }
    NSRange targetRange = NSMakeRange(firstRange.location + 1, lastRange.location - firstRange.location - 1);
    return [tStr substringWithRange:targetRange];
}

- (void)getHotKey
{
    [[AFYueSearchAPIClient sharedClient] getPath:@"/GetPopularVod"
                                      parameters:nil
                                         success:^(AFHTTPRequestOperation *operation, id result) {
                                             [hotkeysArray removeAllObjects];
                                             NSArray * hotkeys = [result objectForKey:@"resources"];
                                             for (NSDictionary * dic in hotkeys)
                                             {
                                                 NSString * name = [self fileName:[dic objectForKey:@"name"]];
                                                 if (name)
                                                 {
                                                     //NSLog(@"%@",name);
                                                     [hotkeysArray addObject:name];
                                                 }
                                             }
                                             [[CacheUtility sharedCache] putInCache:HOTKEY_CACHE result:hotkeysArray];
                                             [table_ reloadData];
                                         } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog(@"fail");
                                         }];
}

- (void)search:(NSString *)key
{
    [historyTable_ removeFromSuperview];
    [searchBar_ resignFirstResponder];
    searchBar_.text = nil;
    [searchBar_ setShowsCancelButton:NO animated:NO];
    
    BOOL isHave = NO;
    for (int i = 0; i< searchHistory.count; i ++)
    {
        NSString *str = [searchHistory objectAtIndex:i];
        if ([str isEqualToString:key]) {
            isHave = YES;
            [searchHistory exchangeObjectAtIndex:i withObjectAtIndex:(searchHistory.count - 1)];
            break;
        }
    }
    
    if (!isHave) {
        [searchHistory addObject:key];
    }
    [[CacheUtility sharedCache] putInCache:SEARCH_HISTORY result:searchHistory];
    
    NSString * url = [YUE_SEARCH_URL stringByReplacingOccurrencesOfString:@"@" withString:key];
    //NSString * url = [NSString stringWithFormat:@"%@%@",YUE_SEARCH_URL,key];
    YueSouWebViewController * ctrl = [[YueSouWebViewController alloc] initWithUrl:url title:key];
    [self.navigationController pushViewController:ctrl animated:YES];
}

- (void)clearHistory
{
    [historyTable_ removeFromSuperview];
    [searchHistory removeAllObjects];
    [[CacheUtility sharedCache] putInCache:SEARCH_HISTORY result:[NSMutableArray array]];
}

#pragma mark - tableView delegate&&datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == HISTORY_LIST)
    {
        return searchHistory.count + 1;
    }
    NSInteger number = hotkeysArray.count % 2 == 0 ? hotkeysArray.count/2 : hotkeysArray.count/2 + 1;
    return number;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView.tag == HISTORY_LIST)
    {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        UIImageView *line = nil;
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1];
        }
        for (UIView *view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }
        if (indexPath.row == [searchHistory count]) {
            UIButton *clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [clearBtn setBackgroundImage:[UIImage imageNamed:@"sousuo_qing_chu"] forState:UIControlStateNormal];
            [clearBtn setBackgroundImage:[UIImage imageNamed:@"sousuo_qing_chu_"] forState:UIControlStateHighlighted];
            clearBtn.frame = CGRectMake(0, 0, cell.frame.size.width, 30);
            [clearBtn addTarget:self action:@selector(clearHistory) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:clearBtn];
            line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 39, self.view.bounds.size.width, 1)];
            line.backgroundColor = [UIColor clearColor];
            line.image = [UIImage imageNamed:@"sousuo_bg_fen_ge_xian"];
            [cell.contentView addSubview:line];
            cell.textLabel.text = nil;
            return cell;
        }
        else if(indexPath.row < [searchHistory count]){
            int count = [searchHistory count];
            cell.textLabel.text = [searchHistory objectAtIndex:count-1-indexPath.row];
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.backgroundColor = [UIColor clearColor];
            line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 29, self.view.bounds.size.width, 1)];
            line.backgroundColor = [UIColor clearColor];
            line.image = [UIImage imageNamed:@"sousuo_bg_fen_ge_xian"];
            [cell.contentView addSubview:line];
        }
        cell.backgroundColor = [UIColor clearColor];
        UIView *selectedBg = [[UIView alloc] initWithFrame:cell.frame];
        selectedBg.backgroundColor = [UIColor colorWithRed:185.0/255 green:185.0/255 blue:174.0/255 alpha:0.4];
        cell.selectedBackgroundView = selectedBg;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    static NSString *CellIdentifier = @"CellIdentifier";
    YueSouViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[YueSouViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    
    NSInteger first = indexPath.row * 2;
    NSInteger second = indexPath.row * 2 + 1;
    NSMutableDictionary * info = [NSMutableDictionary dictionary];
    [info setObject:[NSString stringWithFormat:@"%d",first + 1] forKey:KEY_FIRST_NUMBER];
    [info setObject:[hotkeysArray objectAtIndex:first] forKey:KEY_FIRST_NAME];
    if (hotkeysArray.count > second)
    {
        [info setObject:[NSString stringWithFormat:@"%d",second + 1] forKey:KEY_SECOND_NUMBER];
        [info setObject:[hotkeysArray objectAtIndex:second] forKey:KEY_SECOND_NAME];
    }
    
    [cell setViewInfo:info];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == HISTORY_LIST)
    {
        return 30.f;
    }
    return 60.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == HISTORY_LIST)
    {
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        [self search:cell.textLabel.text];
    }
}

#pragma mark - UISearchBarDeleagate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    [self search:searchBar.text];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
    if (0 < searchHistory.count)
    {
        [self.view addSubview:historyTable_];
    }
    [historyTable_ reloadData];
    [searchBar setShowsCancelButton:YES animated:YES];
    [searchBar setShowsCancelButton:YES animated:YES];
    for (UIView * view in searchBar.subviews) {
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
        {
            for (UIView * secSubView in view.subviews)
            {
                if ([secSubView isKindOfClass:[UIButton class]]) {
                    secSubView.frame = CGRectMake(232, -2, 54, 30);
                    [(UIButton *)secSubView setBackgroundImage:[UIImage imageNamed:@"sousuo_qu_xiao.png"] forState:UIControlStateNormal];
                    [(UIButton *)secSubView setBackgroundImage:[UIImage imageNamed:@"sousuo_qu_xiao_s.png"] forState:UIControlStateHighlighted];
                    [(UIButton *)secSubView setTitle:nil forState:UIControlStateNormal];
                    [(UIButton *)secSubView setTitle:nil forState:UIControlStateHighlighted];
                }
                else if ([secSubView isKindOfClass:[UITextField class]])
                {
                    secSubView.frame = CGRectMake(8, 0, 213, 28);
                }
            }
        }
        else
        {
            if ([view isKindOfClass:[UIButton class]]) {
                [(UIButton *)view setBackgroundImage:[UIImage imageNamed:@"sousuo_qu_xiao.png"] forState:UIControlStateNormal];
                [(UIButton *)view setBackgroundImage:[UIImage imageNamed:@"sousuo_qu_xiao_s.png"] forState:UIControlStateHighlighted];
                [(UIButton *)view setTitle:nil forState:UIControlStateNormal];
                [(UIButton *)view setTitle:nil forState:UIControlStateHighlighted];
            }
        }
        
    }
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    if ([searchBar isFirstResponder]) {
        [searchBar resignFirstResponder];
        for (id view in searchBar.subviews) {
            if ([view isKindOfClass:[UIButton class]]) {
                ((UIButton *)view).enabled = YES;
            }
        }
        
        [searchBar setShowsCancelButton:NO animated:YES];
        searchBar_.text = nil;
    }
    else{
        [searchBar setShowsCancelButton:NO animated:YES];
        searchBar_.text = nil;
    }
    [historyTable_ removeFromSuperview];
}

#pragma mark - YueSouViewCellDelegate
- (void)searchWithKeyWord:(NSString *)key
{
    [self search:key];
}

@end
