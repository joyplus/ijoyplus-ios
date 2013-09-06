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

@interface YueSearchViewController ()
@property (nonatomic, strong) CustomSearchBar * sBar;
@property (nonatomic, strong) NSMutableArray *  hotkeysArray;
@property int curPage;
- (void)initMainView;
- (void)getHotKey;
- (void)searchWithKey:(NSString *)key;
- (NSString *)fileName:(NSString *)tStr;
- (void)showHotKeysView:(NSMutableArray *)data;
@end

@implementation YueSearchViewController
@synthesize sBar,hotkeysArray,curPage;
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
    
    [self initMainView];
    [self getHotKey];
    
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
    [sBar resignFirstResponder];
}

- (void)searchWithKey:(NSString *)key
{
    NSString * url = [NSString stringWithFormat:@"%@%@",YUE_SEARCH_URL,key];
    YueSearchWebViewController * webView = [[YueSearchWebViewController alloc] initWithUrl:url];
    [[AppDelegate instance].rootViewController pesentMyModalView:[[UINavigationController alloc]initWithRootViewController:webView]];
}

#pragma mark - YueSearchViewDelegate
- (void)showNextPage
{
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

@end
