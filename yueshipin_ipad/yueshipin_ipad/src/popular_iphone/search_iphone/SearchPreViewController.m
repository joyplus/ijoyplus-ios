//
//  SearchPreViewController.m
//  yueshipin
//
//  Created by 08 on 12-12-27.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "SearchPreViewController.h"
#import "IphoneSearchViewController.h"
#import "UIImage+Scale.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "CacheUtility.h"
#import "ListDetailViewCell.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import <QuartzCore/QuartzCore.h> 
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"
#import "IphoneMovieDetailViewController.h"
#import "TVDetailViewController.h"
#import "IphoneShowDetailViewController.h"
#import "CommonMotheds.h"
#define SEARCH_HISTORY @"serach_history"
#define HISTORY_LIST 9999
#define RESULT_LIST 99999
#define PAGESIZE 20
@interface SearchPreViewController ()

@end

@implementation SearchPreViewController
@synthesize searchBar = searchBar_;
@synthesize hotView = hotView_;
@synthesize tableList = tableList_;
@synthesize searchResultList = searchResultList_;
@synthesize listArr = listArr_;
@synthesize searchResults = searchResults_;
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
    self.title = @"搜索";
    
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_common.png"]];
    bg.userInteractionEnabled = YES;
    bg.frame = CGRectMake(0, 0, 320, kFullWindowHeight);
    [self.view addSubview:bg];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 55, 44);
    backButton.backgroundColor = [UIColor clearColor];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"back_f.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    hotView_ = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 73)];
    hotView_.image = [UIImage imageNamed:@"sou_suo_hot"];
    [self.view addSubview:hotView_];
    
	// Do any additional setup after loading the view.
//    UIImageView *imagview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_sou_suo"]];
//    imagview.frame = CGRectMake(0, 0, self.view.bounds.size.width, 41);
//    [self.view addSubview:imagview];
    searchBar_ = [[UISearchBar alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2-140, 0, 280, 40)];
    searchBar_.backgroundColor = [UIColor clearColor];
    searchBar_.tintColor = [UIColor clearColor];
    searchBar_.placeholder = @" 请输入片名/导演/主演";
    [[searchBar_.subviews objectAtIndex:0]removeFromSuperview];
    UITextField *searchField;
    NSUInteger numViews = [searchBar_.subviews count];
    for(int i = 0; i < numViews; i++) {
        if([[searchBar_.subviews objectAtIndex:i] isKindOfClass:[UITextField class]]) {
            searchField = [searchBar_.subviews objectAtIndex:i];
        }
        if([[searchBar_.subviews objectAtIndex:i] isKindOfClass:[UIButton class]]){
            
            [(UIButton *)[searchBar_.subviews objectAtIndex:i] setBackgroundImage:[UIImage imageNamed:@"sousuo_qu_xiao.png"] forState:UIControlStateNormal];
            [(UIButton *)[searchBar_.subviews objectAtIndex:i] setBackgroundImage:[UIImage imageNamed:@"sousuo_qu_xiao_s.png"] forState:UIControlStateHighlighted];
            
        }
    }
    
    if(!(searchField == nil)) {
        //[searchField.leftView setHidden:YES];
        [searchField setBackground: [[UIImage imageNamed:@"shuru_kuang_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 20, 10, 20)] ];
        [searchField setBorderStyle:UITextBorderStyleNone];
    }
    searchBar_.delegate = self;
    [self.view addSubview:searchBar_];
    
    for (int i = 0; i < 10; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(18+(i%2)*140, 92+(i/2)*45, 125, 20);
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btn.tag= 100+i;
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRed:29/255.0 green:103/255.0 blue:196/255.0 alpha:1] forState:UIControlStateHighlighted];
        [btn setBackgroundColor:nil];
        [btn addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }

    
    [self intHotKeyWords];
    [self initDataArr];

    tableList_ = [[UITableView alloc] initWithFrame:CGRectMake(0, 41, self.view.bounds.size.width, 160) style:UITableViewStylePlain];
    tableList_.backgroundColor = [UIColor clearColor];
    tableList_.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableList_.dataSource = self;
    tableList_.delegate = self;
    tableList_.tag = HISTORY_LIST;
    
    searchResultList_ = [[UITableView alloc] initWithFrame:CGRectMake(0, 41, self.view.bounds.size.width, kCurrentWindowHeight -85) style:UITableViewStylePlain];
    searchResultList_.backgroundColor = [UIColor clearColor];
    searchResultList_.separatorStyle = UITableViewCellSeparatorStyleNone;
    searchResultList_.dataSource = self;
    searchResultList_.delegate = self;
    searchResultList_.tag = RESULT_LIST;  
}
-(void)initDataArr{
 listArr_ = [[CacheUtility sharedCache] loadFromCache:SEARCH_HISTORY];
}
-(void)intHotKeyWords{
     [CommonMotheds showNetworkDisAbledAlert:self.view];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:10], @"num", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathSearchTopKeywords parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *hotkeyArr = [result objectForKey:@"topKeywords"];
            for (int i = 0;i<[hotkeyArr count] ; i++) {
                UIButton *btn = (UIButton *)[self.view viewWithTag:100+i];
                [btn setTitle:[[hotkeyArr objectAtIndex:i] objectForKey:@"content"] forState:UIControlStateNormal];
            }
        }
        
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
 
}
-(void)selected:(id)sender{
    [self hiddeViews];
    UIButton *btn = (UIButton *)sender;
    searchBar_.text = btn.titleLabel.text;
    [searchBar_ setShowsCancelButton:YES animated:NO];
    
    for (id view in searchBar_.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            [(UIButton *)view  setBackgroundImage:[UIImage imageNamed:@"sousuo_qu_xiao.png"] forState:UIControlStateNormal];
            [(UIButton *)view setBackgroundImage:[UIImage imageNamed:@"sousuo_qu_xiao_s.png"] forState:UIControlStateHighlighted];
            [(UIButton *)view setTitle:nil forState:UIControlStateNormal];
            [(UIButton *)view setTitle:nil forState:UIControlStateHighlighted];        }
    }

    [self search:btn.titleLabel.text];
    
    
}
-(void)hiddeViews{
    for (int i = 0;i<10 ; i++) {
        UIView *view = [self.view viewWithTag:100+i];
        if (view != nil) {
            view.hidden = YES;
        }   
    }
    hotView_.hidden = YES;
   
}

-(void)showViews{
    for (int i = 0;i<10 ; i++) {
        UIView *view = [self.view viewWithTag:100+i];
        if (view != nil) {
            view.hidden = NO;
        }
    }
     hotView_.hidden = NO;
}
-(void)search:(NSString *)searchStr{
 
    NSMutableArray *historyArr = [NSMutableArray arrayWithCapacity:10];
    NSArray *arr = [[CacheUtility sharedCache] loadFromCache:SEARCH_HISTORY];
    [historyArr addObjectsFromArray:arr];
    BOOL isHave = NO;
    for (int i = 0; i< historyArr.count; i ++)
    {
        NSString *str = [historyArr objectAtIndex:i];
        if ([str isEqualToString:searchStr]) {
            isHave = YES;
            [historyArr exchangeObjectAtIndex:i withObjectAtIndex:(historyArr.count - 1)];
            break;
        }
    }
    
    if (!isHave) {
      [historyArr addObject:searchStr];
    }
    [[CacheUtility sharedCache] putInCache:SEARCH_HISTORY result:historyArr ];
    listArr_ = historyArr;
    [tableList_ reloadData];

    [self loadSearchData:searchStr];
    [self.view addSubview:searchResultList_];
    [searchResultList_ reloadData];
    [searchBar_ resignFirstResponder];
    [tableList_ removeFromSuperview];
    [self hiddeViews];
    searchBar_.text = searchStr;
    for (id view in searchBar_.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            ((UIButton *)view).enabled = YES;
        }
    }
    
}
-(void)clearHistory{
 [[CacheUtility sharedCache] putInCache:SEARCH_HISTORY result:[NSMutableArray array]];
 [listArr_ removeAllObjects];
 [tableList_ reloadData];
}

-(void)loadSearchData:(NSString *)searchStr{
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([hostReach currentReachabilityStatus] == NotReachable){
        [UIUtility showNetWorkError:self.view];
        return;
    }
    
    MBProgressHUD  *tempHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:tempHUD];
    tempHUD.labelText = @"加载中...";
    tempHUD.opacity = 0.5;
    [tempHUD show:YES];
    NSString *searchKey = [searchStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:searchKey, @"keyword", @"1", @"page_num", [NSNumber numberWithInt:PAGESIZE], @"page_size", @"1,2,3,131", @"type", nil];
    
    [[AFServiceAPIClient sharedClient] postPath:kPathSearch parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        searchResults_ = [[NSMutableArray alloc]initWithCapacity:10];
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *searchResult = [result objectForKey:@"results"];
            if(searchResult != nil && searchResult.count > 0){
                [searchResults_ addObjectsFromArray:searchResult];
            }
            else{
                [self showFailureView:1];
                
            }
        }
        
        [searchResultList_  reloadData];
        [tempHUD hide:YES];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        searchResults_ = [[NSMutableArray alloc]initWithCapacity:10];
        [tempHUD hide:YES];
        
    }];
    
    
}
- (void)showFailureView:(float)closeTime
{
    
     UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2-100, 150, 200, 40)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:18];
    label.text = @"抱歉，未找到相关影片！";
    label.textColor = [UIColor blackColor];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.textAlignment = NSTextAlignmentCenter;
    label.alpha = 1;
    label.layer.cornerRadius = 5;
    label.tag =19999;
    [self.view addSubview:label];

}
- (void)removeOverlay
{
    for(UIView *view in self.view.subviews ){
        if (view.tag == 19999) {
            [view removeFromSuperview];
            break;
        }
        
    }
    
}
-(void)back:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self search:searchBar.text];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    if ([listArr_ count] > 0) {
      [self.view addSubview:tableList_];
    }
    
    [searchResultList_ removeFromSuperview ];
    [self hiddeViews];
    [self removeOverlay];
    searchBar_.text = nil;
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
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    if ([searchBar isFirstResponder]) {
        [searchBar resignFirstResponder];
        for (id view in searchBar.subviews) {
            if ([view isKindOfClass:[UIButton class]]) {
                ((UIButton *)view).enabled = YES;
            }
        }
        
        //if ([searchResults_ count] == 0) {
            [tableList_ removeFromSuperview];
            [self showViews];
            [searchBar setShowsCancelButton:NO animated:YES];
            searchBar_.text = nil;
        //}
    }
    else{
        [searchResultList_ removeFromSuperview];
        [searchResults_ removeAllObjects];
        [self showViews];
        [searchBar setShowsCancelButton:NO animated:YES];
        searchBar_.text = nil;
    }
    [self removeOverlay];
    [tableList_ removeFromSuperview];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag == HISTORY_LIST) {
        if ([listArr_ count]>0) {
            return [listArr_ count]+1;
        }
        else{
            return 0;
        }
    }
    else if (tableView.tag == RESULT_LIST){
       return [searchResults_ count];
    }
    return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == HISTORY_LIST) {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        UIImageView *line = nil;
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1];
        }
        for (UIView *view in cell.contentView.subviews) {
                [view removeFromSuperview];
        }
        if (indexPath.row == [listArr_ count]) {
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
        else if(indexPath.row < [listArr_ count]){
            int count = [listArr_ count];
            cell.textLabel.text = [listArr_ objectAtIndex:count-1-indexPath.row];
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 29, self.view.bounds.size.width, 1)];
            line.backgroundColor = [UIColor clearColor];
            line.image = [UIImage imageNamed:@"sousuo_bg_fen_ge_xian"];
            [cell.contentView addSubview:line];
        }
        return cell;

    }
    else if (tableView.tag == RESULT_LIST){
        static NSString *CellIdentifier = @"Cell-Result";
        ListDetailViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[ListDetailViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        NSDictionary *item = [searchResults_ objectAtIndex:indexPath.row];
        cell.label.text = [item objectForKey:@"prod_name"];
        cell.actors.text = [NSString stringWithFormat:@"主演：%@",[item objectForKey:@"star"]];
        cell.area.text = [NSString stringWithFormat:@"地区：%@",[item objectForKey:@"area"]];
        [cell.imageview setImageWithURL:[NSURL URLWithString:[item objectForKey:@"prod_pic_url"]] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
        NSString *supportNum = [item objectForKey:@"support_num"];
        [cell.support setTitle:[NSString stringWithFormat:@"%@",supportNum] forState:UIControlStateDisabled];
        NSString *addFavNum = [item objectForKey:@"favority_num"];
        [cell.addFav setTitle:[NSString stringWithFormat:@"%@",addFavNum] forState:UIControlStateDisabled];
        cell.score.text = [NSString stringWithFormat:@"%@",[item objectForKey:@"score"]];
        return cell;


    }
    return nil;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == HISTORY_LIST) {
//        if (indexPath.row == [listArr_ count]) {
//            return 40;
//        }
        return 30;
    }
    else if (tableView.tag == RESULT_LIST){
        return 112.0;
    }
    return 0;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == HISTORY_LIST) {
        if (indexPath.row == [listArr_ count]) {
            return;
        }
        int count = [listArr_ count];
        NSString *str =  [listArr_ objectAtIndex:count-1-indexPath.row];
        [self search:str];
    }
    else if (tableView.tag == RESULT_LIST){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        NSDictionary *item = [searchResults_ objectAtIndex:indexPath.row];
        NSString *typeStr = [item objectForKey:@"prod_type"];
        if ([typeStr isEqualToString:@"1"]) {
            IphoneMovieDetailViewController *detailViewController = [[IphoneMovieDetailViewController alloc] init];
            detailViewController.infoDic = [searchResults_ objectAtIndex:indexPath.row];
            [self.navigationController pushViewController:detailViewController animated:YES];
        }
        else if ([typeStr isEqualToString:@"2"]||[typeStr isEqualToString:@"131"]){
            TVDetailViewController *detailViewController = [[TVDetailViewController alloc] init];
            detailViewController.infoDic = [searchResults_ objectAtIndex:indexPath.row];
            [self.navigationController pushViewController:detailViewController animated:YES];
        }
        else if ([typeStr isEqualToString:@"3"]){
            IphoneShowDetailViewController *detailViewController = [[IphoneShowDetailViewController alloc] init];
            detailViewController.infoDic = [searchResults_ objectAtIndex:indexPath.row];
            [self.navigationController pushViewController:detailViewController animated:YES];
        }

    }

}

- (void)viewDidUnload{
    [super viewDidUnload];
    searchBar_ = nil;
    hotView_ = nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
