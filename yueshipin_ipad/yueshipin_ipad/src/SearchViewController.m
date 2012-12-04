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

#define TABLE_VIEW_WIDTH 370
#define MIN_BUTTON_WIDTH 45
#define MAX_BUTTON_WIDTH 355
#define BUTTON_HEIGHT 33
#define BUTTON_TITLE_GAP 13

@interface SearchViewController ()

@end

@implementation SearchViewController
@synthesize menuViewControllerDelegate;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super init]) {
		[self.view setFrame:frame];
        [self.view setBackgroundColor:[UIColor clearColor]];
        backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 24)];
        [backgroundView setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:backgroundView];
        
        bgImage = [[UIImageView alloc]initWithFrame:backgroundView.frame];
        bgImage.image = [UIImage imageNamed:@"left_background"];
        [backgroundView addSubview:bgImage];
        
        menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        menuBtn.frame = CGRectMake(17, 33, 29, 42);
        [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu_btn"] forState:UIControlStateNormal];
        [menuBtn addTarget:self action:@selector(menuBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:menuBtn];
        
        topImage = [[UIImageView alloc]initWithFrame:CGRectMake(80, 40, 140, 35)];
        topImage.image = [UIImage imageNamed:@"search_title"];
        [self.view addSubview:topImage];
        
        sBar = [[CustomSearchBar alloc]initWithFrame:CGRectMake(80, 115, 370, 38)];
        sBar.delegate = self;
        [self.view addSubview:sBar];
        
        table = [[UITableView alloc] initWithFrame:CGRectMake(80, 170, 370, 210) style:UITableViewStylePlain];
        [table setBackgroundColor:[UIColor clearColor]];
        [table setSeparatorColor:CMConstants.tableBorderColor];
		[table setDelegate:self];
		[table setDataSource:self];
        [table setScrollEnabled:NO];
        table.layer.borderWidth = 1;
        table.layer.borderColor = CMConstants.tableBorderColor.CGColor;
        table.tableFooterView = [[UIView alloc] init];
        [self.view addSubview:table];
        
        hotKeyArray = [[NSMutableArray alloc]initWithCapacity:10];
        hotKeyIndex = [[NSMutableArray alloc]initWithCapacity:10];
        hotKeyBtnWidth = [[NSMutableDictionary alloc]initWithCapacity:10];
        
        removePreviousView = YES;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    historyArray = (NSMutableArray *)[[ContainerUtility sharedInstance] attributeForKey:@"search_history"];
    if(historyArray == nil){
        historyArray = [[NSMutableArray alloc]initWithCapacity:LOCAL_KEYS_NUMBER];
    }
    NSArray *sortedArray = [historyArray sortedArrayUsingComparator:^(id a, id b) {
        NSDate *first = [DateUtility dateFromFormatString:[(NSMutableDictionary*)a objectForKey:@"last_search_date"] formatString: @"yyyy-MM-dd HH:mm:ss"] ;
        NSDate *second = [DateUtility dateFromFormatString:[(NSMutableDictionary*)b objectForKey:@"last_search_date"] formatString: @"yyyy-MM-dd HH:mm:ss"];
        return [second compare:first];
    }];
    historyArray = [[NSMutableArray alloc]initWithCapacity:LOCAL_KEYS_NUMBER];
    for(NSDictionary *item in sortedArray){
        NSMutableDictionary *cloneItem = [[NSMutableDictionary alloc]initWithDictionary:item];
        [historyArray addObject:cloneItem];
    }
    table.frame = CGRectMake(80, 170, 370, historyArray.count * 40 + 210);
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:@"hotkeys_list"];
    if(cacheResult != nil){
        [self parseData:cacheResult];
    }
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

- (void)parseData:(id)result{
    NSArray *keyArray = (NSArray *)[result objectForKey:@"topKeywords"];
    if(keyArray != nil && keyArray.count > 0){
        [[CacheUtility sharedCache] putInCache:@"hotkeys_list" result:result];
        [hotKeyArray removeAllObjects];
        [hotKeyArray addObjectsFromArray:keyArray];
        int length = 0;
        int index = 0;
        [hotKeyIndex removeAllObjects];
        [hotKeyIndex addObject:[NSNumber numberWithInt:0]];
        while (index < hotKeyArray.count-1) {
            for(int i = index; i < hotKeyArray.count; i++){
                length += [self calculateBtnWidth:[[hotKeyArray objectAtIndex:i] valueForKey:@"content"]];
                index = i;
                if(length > TABLE_VIEW_WIDTH) {
                    length = 0;
                    if(i > 0){
                        [hotKeyIndex addObject:[NSNumber numberWithInt:i]];
                    }
                    break;
                }
            }
        }
        [hotKeyIndex addObject:[NSNumber numberWithInt:hotKeyArray.count]];
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
	// Do any additional setup after loading the view.
}

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
            [hotKeyBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
            [hotKeyBtn setTitleColor:[CMConstants textColor] forState:UIControlStateNormal];
            [hotKeyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            [hotKeyBtn setBackgroundImage:[UIImage imageNamed:@"label"] forState:UIControlStateNormal];
            [hotKeyBtn setBackgroundImage:[UIImage imageNamed:@"label_pressed"] forState:UIControlStateHighlighted];
            [hotKeyBtn addTarget:self action:@selector(hotKeyBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:hotKeyBtn];
        }
    } else {
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, MAX_BUTTON_WIDTH, 25)];
        [name setTextColor:CMConstants.textBlueColor];
        [name setText:[[historyArray objectAtIndex:indexPath.row] valueForKey:@"content" ]];
        [name sizeToFit];
        [name setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:name];
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
    int index = btn.tag - 2001;
    [self search:[[hotKeyArray objectAtIndex:index] objectForKey:@"content"]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 1){
        NSString *keyword = [[historyArray objectAtIndex:indexPath.row] objectForKey:@"content"];
        [self addKeyToLocalHistory:keyword];
        table.frame = CGRectMake(80, 170, 370, historyArray.count * 40 + 210);
        [table reloadData];
        [self search:keyword];
    }
}

- (void)menuBtnClicked
{
    [self.menuViewControllerDelegate menuButtonClicked];
}


- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    table.frame = CGRectMake(80, 170, 370, historyArray.count * 40 + 210);
    [table reloadData];
    [self search:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [searchBar resignFirstResponder];
    table.frame = CGRectMake(80, 170, 370, historyArray.count * 40 + 210);
    [table reloadData];
    [self search:searchBar.text];
}

- (void)search:(NSString *)keyword
{
    [self closeMenu];
    [self addKeyToLocalHistory:keyword];
    [sBar resignFirstResponder];
    SearchListViewController *viewController = [[SearchListViewController alloc] init];
    viewController.keyword = keyword;
    viewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
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

@end
