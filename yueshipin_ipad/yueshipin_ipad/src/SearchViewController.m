//
//  SettingsViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-20.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "SearchViewController.h"
#import "CustomSearchBar.h"
#import "AddSearchListViewController.h"
#import "SearchListViewController.h"
#import "SearchHistoryListViewController.h"

#define TABLE_VIEW_WIDTH 370
#define MIN_BUTTON_WIDTH 45
#define MAX_BUTTON_WIDTH 355
#define BUTTON_HEIGHT 44
#define BUTTON_TITLE_GAP 13

@interface SearchViewController (){
    BOOL accessed;
}

@property (nonatomic, strong)SearchHistoryListViewController *historyViewController;

@end

@implementation SearchViewController
@synthesize historyViewController;

- (void)viewDidUnload
{
    [super viewDidUnload];
    topImage = nil;
    historyViewController = nil;
    bgImage = nil;
    sBar = nil;
    table = nil;
    hotKeyArray = nil;
    [hotKeyIndex removeAllObjects];
    hotKeyIndex = nil;
    [hotKeyBtnWidth removeAllObjects];
    hotKeyBtnWidth = nil;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super init]) {
		[self.view setFrame:frame];
        [self.view setBackgroundColor:[UIColor clearColor]];
        UIView *bgView = [[UIView alloc]initWithFrame:self.view.frame];
        [self.view addSubview:bgView];
        UITapGestureRecognizer *hideRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideSearchHistory)];
        hideRecognizer.numberOfTouchesRequired=1;
        [bgView addGestureRecognizer:hideRecognizer];
        
        leftWidth = 15;
        
        topImage = [[UIImageView alloc]initWithFrame:CGRectMake(leftWidth, 40, 260, 42)];
        topImage.image = [UIImage imageNamed:@"search_title"];
        [self.view addSubview:topImage];
        
        sBar = [[CustomSearchBar alloc]initWithFrame:CGRectMake(50, 115, 390, 38)];
        sBar.placeholder = @"请输入片名/导演/主演";
        sBar.delegate = self;
        [self.view addSubview:sBar];
       
        hotKeyArray = [[NSMutableArray alloc]initWithCapacity:10];
        UIImageView *hotKeyImage = [[UIImageView alloc]initWithFrame:CGRectMake(50, 200, 70, 16)];
        hotKeyImage.image = [UIImage imageNamed:@"hotkeys"];
        [self.view addSubview:hotKeyImage];
        
        removePreviousView = YES;
        
        
        historyViewController = [[SearchHistoryListViewController alloc]initWithStyle:UITableViewStylePlain];
        historyViewController.parentDelegate = self;
        historyViewController.view.frame = CGRectMake(50, sBar.frame.origin.y + sBar.frame.size.height, sBar.frame.size.width - 56, 0);
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!accessed) {
        accessed = YES;
        if([[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
            NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:10], @"num", nil];
            [[AFServiceAPIClient sharedClient] getPath:kPathSearchTopKeywords parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
                NSString *responseCode = [result objectForKey:@"res_code"];
                if(responseCode == nil){
                    [self parseData:result];
                }
                [table reloadData];
            } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                
            }];
        }
    } 
    [table reloadData];
    [MobClick beginLogPageView:SEARCH];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:SEARCH];
}

- (void)parseData:(id)result{
    NSArray *keyArray = (NSArray *)[result objectForKey:@"topKeywords"];
//    [[CacheUtility sharedCache] putInCache:@"hotkeys_list" result:result];
    if(keyArray != nil && keyArray.count > 0){
        [hotKeyArray removeAllObjects];
        [hotKeyArray addObjectsFromArray:keyArray];
        for (int i = 0; i < hotKeyArray.count; i++){
            NSDictionary *hotKey = [hotKeyArray objectAtIndex:i];
            NSString *content = [hotKey valueForKey:@"content"];            
            UIButton *hotKeyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            hotKeyBtn.frame = CGRectMake(50 + (i%2) * (180 + 20) , 245 + floor(i/2) * (BUTTON_HEIGHT), 180, BUTTON_HEIGHT);
            [hotKeyBtn setTitle:content forState:UIControlStateNormal];
            [hotKeyBtn setTag:2001 + i];
            [hotKeyBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
            [hotKeyBtn setTitleColor:[CMConstants grayColor] forState:UIControlStateNormal];
            [hotKeyBtn setTitleColor:[CMConstants yellowColor] forState:UIControlStateHighlighted];
            hotKeyBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [hotKeyBtn addTarget:self action:@selector(hotKeyBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:hotKeyBtn];
            [self.view addSubview:historyViewController.view];
        }
    }
}

- (int)calculateBtnWidth:(NSString *)btnTitle
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, MAX_BUTTON_WIDTH -  2 * BUTTON_TITLE_GAP, 25)];
    label.text = btnTitle;
    [label sizeToFit];
    int btnWidth = label.frame.size.width + 2 * BUTTON_TITLE_GAP;
    [hotKeyBtnWidth setValue:[NSNumber numberWithInt:btnWidth] forKey:btnTitle];
    return btnWidth;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)hideSearchHistory
{
    [sBar resignFirstResponder];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
        historyViewController.view.frame = CGRectMake(historyViewController.view.frame.origin.x, historyViewController.view.frame.origin.y, historyViewController.view.frame.size.width, 0);
    } completion:^(BOOL finished) {
        
    }];
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//    if([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]){
//        return NO;
//    } else if([NSStringFromClass([touch.view class]) isEqualToString:@"UIButton"]){
//        return NO;
//    } else {
//        return YES;
//    }
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        return 1;
    } else {
        return historyArray.count;
    }
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    if(indexPath.section == 0){
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        int btnPositionX = 6; // left gap
        int rowNumber = 0;
        for (int i = 0; i < hotKeyArray.count; i++) {
            NSString *content = [[hotKeyArray objectAtIndex:i] valueForKey:@"content"];
            if(i == [[hotKeyIndex objectAtIndex: rowNumber] intValue]){
                btnPositionX = 6;
                rowNumber++;
            }else {
                NSString *preContent = [[hotKeyArray objectAtIndex:i-1] valueForKey:@"content"];
                int preBtnWidth = [[hotKeyBtnWidth valueForKey:preContent] intValue];
                btnPositionX += preBtnWidth + 5; // 5: inner gap
            }
            int btnPositionY = 10 + (BUTTON_HEIGHT + 5)* (rowNumber-1); // 5: inner gap
            UIButton *hotKeyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            int btnWidth = [[hotKeyBtnWidth valueForKey:content] intValue];
            hotKeyBtn.frame = CGRectMake(btnPositionX, btnPositionY, btnWidth, BUTTON_HEIGHT);
            [hotKeyBtn setTitle:content forState:UIControlStateNormal];
            [hotKeyBtn setTag:2001 + i];
            [hotKeyBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [hotKeyBtn setTitleColor:[CMConstants grayColor] forState:UIControlStateNormal];
            [hotKeyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            [hotKeyBtn setBackgroundImage:[UIImage imageNamed:@"label"] forState:UIControlStateNormal];
            [hotKeyBtn setBackgroundImage:[UIImage imageNamed:@"label_pressed"] forState:UIControlStateHighlighted];
            [hotKeyBtn addTarget:self action:@selector(hotKeyBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:hotKeyBtn];
        }
    } else {
        if(indexPath.row < historyArray.count){
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
            UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, MAX_BUTTON_WIDTH, 25)];
            [name setTextColor:[UIColor blackColor]];
            [name setFont:[UIFont systemFontOfSize:14]];
            [name setText:[[historyArray objectAtIndex:indexPath.row] valueForKey:@"content" ]];
            [name sizeToFit];
            [name setBackgroundColor:[UIColor clearColor]];
            [cell.contentView addSubview:name];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        if(hotKeyArray.count > 0){
            return (hotKeyIndex.count - 1) * 40 + 10;
        } else {
            return 40;
        }
    } else {
        return 40;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TABLE_VIEW_WIDTH, 40)];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:view.frame];
    if(section == 0){
        imageView.image = [UIImage imageNamed:@"hotkeys"];
    } else {
        imageView.image = [UIImage imageNamed:@"history"];
    }
    [view addSubview:imageView];
    return view;
}

- (void)hotKeyBtnClicked:(UIButton *)btn
{
    [self hideSearchHistory];
    int index = btn.tag - 2001;
    [self search:[[hotKeyArray objectAtIndex:index] objectForKey:@"content"]];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    historyArray = (NSMutableArray *)[[ContainerUtility sharedInstance] attributeForKey:@"search_history"];
    if(historyArray == nil){
        historyArray = [[NSMutableArray alloc]initWithCapacity:LOCAL_KEYS_NUMBER];
    }
    NSArray *sortedArray = [historyArray sortedArrayUsingComparator:^(id a, id b) {
        NSDate *first = [DateUtility dateFromFormatString:[(NSMutableDictionary*)a objectForKey:@"last_search_date"] formatString: @"yyyy-MM-dd HH:mm:ss"] ;
        NSDate *second = [DateUtility dateFromFormatString:[(NSMutableDictionary*)b objectForKey:@"last_search_date"] formatString: @"yyyy-MM-dd HH:mm:ss"];
        if (first && second) {
            return [second compare:first];
        } else {
            return NSOrderedSame;
        }
    }];
    historyArray = [[NSMutableArray alloc]initWithCapacity:LOCAL_KEYS_NUMBER];
    for(NSDictionary *item in sortedArray){
        NSMutableDictionary *cloneItem = [[NSMutableDictionary alloc]initWithDictionary:item];
        [historyArray addObject:cloneItem];
    }
    historyViewController.historyArray = historyArray;
    [historyViewController.tableView reloadData];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
        historyViewController.view.frame = CGRectMake(historyViewController.view.frame.origin.x, historyViewController.view.frame.origin.y, historyViewController.view.frame.size.width, historyArray.count == 0 ? 0 : (historyArray.count+1) * 35);
    } completion:^(BOOL finished) {
        
    }];
    
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self search:searchBar.text];
    [table reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    if(searchBar.text.length > 0){
        [searchBar resignFirstResponder];
        [self search:searchBar.text];
    }
}

- (void)search:(NSString *)keyword
{
    [self hideSearchHistory];
    BOOL isReachable = [[AppDelegate instance] performSelector:@selector(isParseReachable)];
    if(!isReachable) {
        [UIUtility showNetWorkError:self.view];
        return;
    }
    keyword = [keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    sBar.text = keyword;
    [self addKeyToLocalHistory:keyword];
    [sBar resignFirstResponder];
    SearchListViewController *viewController = [[SearchListViewController alloc] init];
    viewController.keyword = keyword;
    viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
    [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:removePreviousView];
    
}

- (void)addKeyToLocalHistory:(NSString *)key
{
    NSArray *array = (NSArray *)[[ContainerUtility sharedInstance] attributeForKey:@"search_history"];
    NSMutableArray *newHistoryArray = [[NSMutableArray alloc]initWithCapacity:LOCAL_KEYS_NUMBER];
    for(NSDictionary *item in array){
        NSMutableDictionary *temp = [[NSMutableDictionary alloc]init];
        [temp setValue:[item objectForKey:@"content"] forKey:@"content"];
        [temp setValue:[item objectForKey:@"last_search_date"] forKey:@"last_search_date"];
        [newHistoryArray addObject:temp];
    }
    NSMutableDictionary *newItem;
    for(NSMutableDictionary *item in newHistoryArray){
        NSString *content = [item objectForKey:@"content"];
        if([content isEqualToString:key]){
            newItem = item;
            break;
        }
    }
    NSString *currentDateString = [DateUtility formatDateWithString:[NSDate date] formatString: @"yyyy-MM-dd HH:mm:ss"];
    if(newItem != nil){
        [newItem setValue:currentDateString forKey:@"last_search_date"];
    } else {
        newItem = [[NSMutableDictionary alloc]initWithCapacity:2];
        [newItem setValue:key forKey:@"content"];
        [newItem setValue:currentDateString forKey:@"last_search_date"];
        if(newHistoryArray.count >= LOCAL_KEYS_NUMBER){
            NSDate *minDate = [NSDate date];
            NSMutableDictionary *minItem;
            for(NSMutableDictionary *item in newHistoryArray){
                NSString *dateString = [item objectForKey:@"last_search_date"];
                NSDate *date = [DateUtility dateFromFormatString:dateString formatString: @"yyyy-MM-dd HH:mm:ss"];
                if([date isEarlierThanDate:minDate]){
                    minDate = date;
                    minItem = item;
                }
            }
            [newHistoryArray removeObject:minItem];
        }
        [newHistoryArray addObject:newItem];
    }
    historyArray = [[NSMutableArray alloc]initWithCapacity:LOCAL_KEYS_NUMBER];
    NSArray *sortedArray = [newHistoryArray sortedArrayUsingComparator:^(id a, id b) {
        NSDate *first = [DateUtility dateFromFormatString:[(NSMutableDictionary*)a objectForKey:@"last_search_date"] formatString: @"yyyy-MM-dd HH:mm:ss"] ;
        NSDate *second = [DateUtility dateFromFormatString:[(NSMutableDictionary*)b objectForKey:@"last_search_date"] formatString: @"yyyy-MM-dd HH:mm:ss"];
        return [second compare:first];
    }];
    [historyArray addObjectsFromArray:sortedArray];
    [[ContainerUtility sharedInstance]setAttribute:newHistoryArray forKey:@"search_history"];
}

- (void)clearSearchBarContent
{
    sBar.text = @"";
}

- (void)historyCellClicked:(NSString *)keyword
{
    [self search:keyword];
}

- (void)resignFirstRespond
{
    [sBar resignFirstResponder];
}

@end
