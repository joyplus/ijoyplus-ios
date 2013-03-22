//
//  FindViewController.m
//  yueshipin
//
//  Created by 08 on 13-1-5.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "FindViewController.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "MBProgressHUD.h"
#import "SearchResultsViewCell.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Scale.h"
#import <QuartzCore/QuartzCore.h> 
#import "AppDelegate.h"
#import "Reachability.h"
#import "CommonMotheds.h"
#define PAGESIZE 20
@interface FindViewController ()

@end

@implementation FindViewController
@synthesize searchBar = searchBar_;
@synthesize tableList = tableList_;
@synthesize searchResults = searchResults_;
@synthesize selectedArr = selectedArr_;
@synthesize topicId = topicId_;
@synthesize rightButtonItem = rightButtonItem_;
@synthesize type = type_;
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
    self.title = @"搜索";
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_common.png"]];
    bg.frame = CGRectMake(0, 0, 320, 480);
    [self.view addSubview:bg];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 40, 30);
    backButton.backgroundColor = [UIColor clearColor];
    [backButton setImage:[UIImage imageNamed:@"top_return_common.png"] forState:UIControlStateNormal];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton addTarget:self action:@selector(Done:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(0, 0, 37, 30);
    [rightButton setImage:[UIImage imageNamed:@"top_icon_common_writing_complete"] forState:UIControlStateNormal];
    [rightButton setImage:[UIImage imageNamed:@"top_icon_common_writing_complete_s"] forState:UIControlStateHighlighted];
    rightButtonItem_ = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = nil;
    
    UIImageView *imagview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_sou_suo"]];
    imagview.frame = CGRectMake(0, 0, self.view.bounds.size.width, 41);
    [self.view addSubview:imagview];
    searchBar_ = [[UISearchBar alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2-140, 0, 280, 41)];
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
        [searchField.leftView setHidden:YES];
        [searchField setBackground: [UIImage imageNamed:@"my_search_sou_suo_kuang"] ];
        [searchField setBorderStyle:UITextBorderStyleNone];
    }
    searchBar_.delegate = self;
    [self.view addSubview:searchBar_];
    
    tableList_ = [[UITableView alloc] initWithFrame:CGRectMake(0, 42, 320, kCurrentWindowHeight-85) style:UITableViewStylePlain];
    tableList_.dataSource = self;
    tableList_.delegate = self;
    tableList_.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableList_];
    
}

-(void)back:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)Search{
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([hostReach currentReachabilityStatus] == NotReachable){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"网络异常，请检查网络。" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    MBProgressHUD  *tempHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:tempHUD];
    tempHUD.labelText = @"加载中...";
    tempHUD.opacity = 0.5;
    [tempHUD show:YES];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:searchBar_.text, @"keyword", @"1", @"page_num", [NSNumber numberWithInt:PAGESIZE], @"page_size",[NSNumber numberWithInt:type_], @"type", nil];
    
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
        
        [tableList_ reloadData];
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
    //label.center = CGPointMake(self.view.bounds.size.width/2,self.view.bounds.size.height/2-100);
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


-(void)Done:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Update CreateMyListTwoViewController" object:selectedArr_];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar_ resignFirstResponder];
    [self Search];
    [searchBar setShowsCancelButton:NO animated:YES];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [self removeOverlay];
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
    [searchBar setShowsCancelButton:NO animated:NO];
    [searchBar resignFirstResponder];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [searchResults_ count];
}




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 95;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    SearchResultsViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SearchResultsViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *item = [searchResults_ objectAtIndex:indexPath.row];
    cell.label.text = [item objectForKey:@"prod_name"];
    cell.actors.text = [NSString stringWithFormat:@"主演：%@",[item objectForKey:@"star"]];
    cell.area.text = [NSString stringWithFormat:@"地区：%@",[item objectForKey:@"area"]];
    [cell.imageview setImageWithURL:[NSURL URLWithString:[item objectForKey:@"prod_pic_url"]] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
    NSString *type = [item objectForKey:@"prod_type" ];
    if ([type isEqualToString:@"1" ]) {
        cell.type.text = @"类型：电影";
    }
    else if ([type isEqualToString:@"2" ]){
     cell.type.text = @"类型：电视剧";
    }
    if ([selectedArr_ containsObject:item]) {
        cell.addImageView.image = [UIImage imageNamed:@"list_icon_add_pressed.png"];
    }
    else{
        cell.addImageView.image = [UIImage imageNamed:@"list_icon_add.png"];
    }

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
  NSDictionary *item = [searchResults_ objectAtIndex:indexPath.row];
    if (![selectedArr_ containsObject:item]) {
        [selectedArr_ addObject:item];
    }
    if ([selectedArr_ count] == 0) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    else{
    
        self.navigationItem.rightBarButtonItem = rightButtonItem_;
    }
    [self.tableList reloadData];
    [self addBtnClicked];
}

- (void)addBtnClicked
{
    if (![CommonMotheds isNetworkEnbled]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"网络异常，请检查网络。" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    NSMutableString *prodIds = [[NSMutableString alloc]init];
    for(NSDictionary *item in selectedArr_){
       NSString *idStr = [item objectForKey:@"prod_id"];
        [prodIds appendFormat:@"%@,", idStr];
    }
    NSString *prodIdStr;
    if(prodIds.length > 0){
        prodIdStr = [prodIds substringToIndex:prodIds.length - 1];
    } else {
        return;
    }
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: topicId_, @"topic_id", prodIdStr, @"prod_id", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathAddItem parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if([responseCode isEqualToString:kSuccessResCode]){
            NSLog(@"succeed");
        } else {
            NSLog(@"fail");
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
