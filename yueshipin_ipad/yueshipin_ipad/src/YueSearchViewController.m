//
//  YueSearchViewController.m
//  yueshipin
//
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "YueSearchViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AFYueSearchAPIClient.h"
#import "YueSearchWebViewController.h"

#define YUE_SEARCH_URL  (@"http://www.lesou.org/search.php?wd=")
#define SEARCH_HISTORY  (@"yueSou_History")

@interface YueSearchViewController ()
@property (nonatomic, strong) CustomSearchBar * sBar;
@property (nonatomic, strong) NSMutableArray *  hotkeysArray;
@property (nonatomic, strong) NSMutableArray * searchHistoryArray;
@property int curPage;
- (void)initMainView;
- (void)getHotKey;
- (void)searchWithKey:(NSString *)key;
- (NSString *)fileName:(NSString *)tStr;
- (void)showHotKeysView:(NSMutableArray *)data;
@end

@implementation YueSearchViewController
@synthesize sBar,hotkeysArray,curPage,searchHistoryArray;
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
    curPage = 0;
    hotkeysArray = [[NSMutableArray alloc] init];
    searchHistoryArray = [[NSMutableArray alloc] initWithArray:[[CacheUtility sharedCache] loadFromCache:SEARCH_HISTORY]];
    [self initMainView];
    //[self getHotKey];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getHotKey];
    //[historyTable reloadData];
}

#pragma  mark - private
- (void)initMainView
{
    //bg image
    UIImageView * image = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 942, 750)];
    image.image = [UIImage imageNamed:@"yueSearch_back"];
    [self.view addSubview:image];
    
    //bg Button
    UIButton * bgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bgBtn.frame = self.view.frame;
    [self.view addSubview:bgBtn];
    [bgBtn addTarget:self
              action:@selector(bgBtnClick:)
    forControlEvents:UIControlEventTouchDown];
    bgBtn.backgroundColor = [UIColor clearColor];
    
    //top image
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 36, 260, 42)];
    imageView.image = [UIImage imageNamed:@"yueSearch_title"];
    [self.view addSubview:imageView];
    
    //search Bar
    sBar = [[CustomSearchBar alloc]initWithFrame:CGRectMake(170, 114, 585, 38)];
    sBar.placeholder = @"乐搜资源:请输入影片名称搜索";
    sBar.delegate = self;
    [self.view addSubview:sBar];
    
    UIImageView * bgImage = [[UIImageView alloc] initWithFrame:CGRectMake(80, 190, 784, 502)];
    bgImage.image = [UIImage imageNamed:@"search_hot"];
    [self.view addSubview:bgImage];
    
    
    historyTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    historyTable.frame = CGRectMake(170, 152, 513, 0);
    historyTable.backgroundColor = [UIColor whiteColor];
    historyTable.delegate = self;
    historyTable.dataSource = self;
    [self.view addSubview:historyTable];
    
}

- (void)showHotKeysView:(NSMutableArray *)data
{
    if (searchView)
    {
        [searchView removeFromSuperview];
        searchView = nil;
    }
    searchView = [[YueSearchView alloc] initWithFrame:CGRectMake(80, 190, 784, 502)];
    searchView.backgroundColor = [UIColor clearColor];
    searchView.info = data;
    searchView.delegate = self;
    [self.view addSubview:searchView];
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
                                                     [hotkeysArray addObject:name];
                                             }
                                             NSMutableArray * info = [[NSMutableArray alloc] init];
                                             int max = hotkeysArray.count < 10 ? hotkeysArray.count : NUM_PER_PAGE;
                                             for (int i = 0;i < max; i++)
                                             {
                                                 [info addObject:[hotkeysArray objectAtIndex:i]];
                                             }
                                             [self showHotKeysView:info];
                                         } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog(@"fail");
                                         }];
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

- (void)bgBtnClick:(id)sender
{
    [self setSearchHistoryHidden:YES];
    [sBar resignFirstResponder];
}

- (void)searchWithKey:(NSString *)key
{
    [self addSearchKey:key];
    
    [self setSearchHistoryHidden:YES];
    
    NSString * url = [NSString stringWithFormat:@"%@%@",YUE_SEARCH_URL,key];
    YueSearchWebViewController * webView = [[YueSearchWebViewController alloc] initWithUrl:url];
    [[AppDelegate instance].rootViewController pesentMyModalView:[[UINavigationController alloc]initWithRootViewController:webView]];
}

- (void)setSearchHistoryHidden:(BOOL)isHidden
{
    //352 (170, 114, 585, 38)
    [sBar resignFirstResponder];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
        CGFloat height;
        if (isHidden)
        {
            height = 0;
        }
        else
        {
            height = (searchHistoryArray.count == 0 ? 0 : (searchHistoryArray.count + 1) * 35);
            height = (height >= 244 ? 244 : height);
        }
        historyTable.frame = CGRectMake(170, 152, 513, height);
        [self.view bringSubviewToFront:historyTable];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)addSearchKey:(NSString *)key
{
    BOOL isHave = NO;
    for (int i = 0; i< searchHistoryArray.count; i ++)
    {
        NSString *str = [searchHistoryArray objectAtIndex:i];
        if ([str isEqualToString:key]) {
            isHave = YES;
            [searchHistoryArray exchangeObjectAtIndex:i withObjectAtIndex:(searchHistoryArray.count - 1)];
            break;
        }
    }
    
    if (!isHave) {
        [searchHistoryArray addObject:key];
    }
    [[CacheUtility sharedCache] putInCache:SEARCH_HISTORY result:searchHistoryArray];
    [historyTable reloadData];
}

- (void)clearHistory
{
    //[historyTable removeFromSuperview];
    [searchHistoryArray removeAllObjects];
    [self setSearchHistoryHidden:YES];
    [[CacheUtility sharedCache] putInCache:SEARCH_HISTORY result:[NSMutableArray array]];
}

#pragma mark - YueSearchViewDelegate
- (void)showNextPage
{
    
    if (sBar.isFirstResponder)
    {
        [sBar resignFirstResponder];
        [self setSearchHistoryHidden:YES];
        return;
    }
    
    [UIView animateWithDuration:0.6 animations:^(void){
        searchView.alpha = 0.1;
    }completion:^(BOOL finished){
        [searchView removeFromSuperview];
        searchView = nil;
        
        curPage ++;
        if (curPage * NUM_PER_PAGE >= hotkeysArray.count)
        {
            curPage = -1;
            [self showNextPage];
        }
        else
        {
            NSMutableArray * info = [[NSMutableArray alloc] init];
            NSInteger max;
            if (hotkeysArray.count - curPage * NUM_PER_PAGE > NUM_PER_PAGE)
            {
                max = curPage * NUM_PER_PAGE + 10;
            }
            else
            {
                max = hotkeysArray.count;
            }
            for (int i = curPage*NUM_PER_PAGE; i < max; i ++)
            {
                [info addObject:[hotkeysArray objectAtIndex:i]];
            }
            [self showHotKeysView:info];
        }
        
    }];
}


- (void)keyWordClicked:(NSString *)keyWord
{
    [self searchWithKey:keyWord];
}

#pragma mark - SearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self setSearchHistoryHidden:NO];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    if(searchBar.text.length > 0){
        [searchBar resignFirstResponder];
        [self searchWithKey:searchBar.text];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger number = (searchHistoryArray.count == 0 ? 0 : searchHistoryArray.count + 1);
    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    if (indexPath.row < searchHistoryArray.count) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [searchHistoryArray objectAtIndex:searchHistoryArray.count - 1 - indexPath.row]];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.textColor = CMConstants.grayColor;
    }
    if (indexPath.row == searchHistoryArray.count) {
        UIButton *clearAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        clearAllBtn.frame = CGRectMake(0, 0, tableView.frame.size.width, 35);
        [clearAllBtn setTitle:@"删除历史记录" forState:UIControlStateNormal];
        [clearAllBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [clearAllBtn setBackgroundImage:[UIImage imageNamed:@"clear"] forState:UIControlStateNormal];
        [clearAllBtn setBackgroundImage:[UIImage imageNamed:@"clear_pressed"] forState:UIControlStateHighlighted];
        [clearAllBtn addTarget:self action:@selector(clearHistory) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:clearAllBtn];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (searchHistoryArray.count > 0 && indexPath.row < searchHistoryArray.count){
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleNone;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [searchHistoryArray removeObjectAtIndex:indexPath.row];
        [[ContainerUtility sharedInstance] setAttribute:searchHistoryArray forKey:SEARCH_HISTORY];
        if (searchHistoryArray.count > 0) {
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            CGFloat height = searchHistoryArray.count >= 6 ? 244 : (searchHistoryArray.count + 1) * 35; 
            tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, height);
        } else {
            tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, 0);
        }
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < searchHistoryArray.count) {
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        [self searchWithKey:cell.textLabel.text];
        //[self.parentDelegate historyCellClicked:[[historyArray objectAtIndex:indexPath.row] objectForKey:@"content"]];
    }
    if (indexPath.row == searchHistoryArray.count) {
        // do nothing
    }
}


@end
