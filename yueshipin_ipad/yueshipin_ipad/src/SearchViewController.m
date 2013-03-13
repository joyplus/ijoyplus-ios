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

@interface SearchViewController (){
    UIButton *lastPressedBtn;
    UIButton *clearAllBtn;
    BOOL accessed;
}

@end

@implementation SearchViewController

- (void)viewDidUnload
{
    [super viewDidUnload];
    topImage = nil;
    bgImage = nil;
    sBar = nil;
    table = nil;
    hotKeyArray = nil;
    [hotKeyIndex removeAllObjects];
    hotKeyIndex = nil;
    [hotKeyBtnWidth removeAllObjects];
    hotKeyBtnWidth = nil;
    clearAllBtn = nil;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super init]) {
		[self.view setFrame:frame];
        [self.view setBackgroundColor:[UIColor clearColor]];
        
        bgImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 24)];
        bgImage.image = [UIImage imageNamed:@"left_background"];
        [self.view addSubview:bgImage];
        
        leftWidth = 80;
        [self.view addSubview:menuBtn];
        
        topImage = [[UIImageView alloc]initWithFrame:CGRectMake(leftWidth, 40, 140, 35)];
        topImage.image = [UIImage imageNamed:@"search_title"];
        [self.view addSubview:topImage];
        
        sBar = [[CustomSearchBar alloc]initWithFrame:CGRectMake(leftWidth, 115, 372, 38)];
        sBar.placeholder = @"请输入片名/导演/主演";
        sBar.delegate = self;
        [self.view addSubview:sBar];
        
        table = [[UITableView alloc] initWithFrame:CGRectMake(leftWidth, 170, 370, 210) style:UITableViewStylePlain];
        [table setBackgroundColor:[UIColor clearColor]];
        [table setSeparatorColor:CMConstants.tableBorderColor];
		[table setDelegate:self];
		[table setDataSource:self];
        [table setScrollEnabled:NO];
        table.layer.borderWidth = 1;
        table.layer.borderColor = CMConstants.tableBorderColor.CGColor;
        table.tableFooterView = [[UIView alloc] init];
        [self.view addSubview:table];
        
        clearAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        clearAllBtn.frame = CGRectMake(350, table.frame.origin.y + table.frame.size.height + 10, 102, 33);
        [clearAllBtn setBackgroundImage:[UIImage imageNamed:@"clear"] forState:UIControlStateNormal];
        [clearAllBtn setBackgroundImage:[UIImage imageNamed:@"clear_pressed"] forState:UIControlStateHighlighted];
        [clearAllBtn addTarget:self action:@selector(clearAllHistory) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:clearAllBtn];
        
        hotKeyArray = [[NSMutableArray alloc]initWithCapacity:10];
        hotKeyIndex = [[NSMutableArray alloc]initWithCapacity:10];
        hotKeyBtnWidth = [[NSMutableDictionary alloc]initWithCapacity:10];
        
        removePreviousView = YES;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([AppDelegate instance].closed) {
        [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu_btn"] forState:UIControlStateNormal];
    } else {
        [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu_btn_pressed"] forState:UIControlStateNormal];
    }
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
    if(historyArray.count>0){
        table.frame = CGRectMake(80, 170, 370, historyArray.count * 40 + 210);
    } else {
        table.frame = CGRectMake(80, 170, 370, 210);
    }
    clearAllBtn.frame = CGRectMake(clearAllBtn.frame.origin.x, table.frame.origin.y + table.frame.size.height + 10, 102, 33);
    if(historyArray.count > 0){
        [clearAllBtn setHidden:NO];
    } else {
        [clearAllBtn setHidden:YES];
    }
    if (!accessed) {
        accessed = YES;
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
    [table reloadData];
    [MobClick beginLogPageView:SEARCH];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:SEARCH];
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
                if(length > 350) {
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
    closeMenuRecognizer.delegate = self;
    [self.view addGestureRecognizer:closeMenuRecognizer];
    [self.view addGestureRecognizer:swipeCloseMenuRecognizer];
    [self.view addGestureRecognizer:openMenuRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]){
        return NO;
    } else if([NSStringFromClass([touch.view class]) isEqualToString:@"UIButton"]){
        return NO;
    } else {
        return YES;
    }
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
            [hotKeyBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [hotKeyBtn setTitleColor:[CMConstants grayColor] forState:UIControlStateNormal];
            [hotKeyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            [hotKeyBtn setBackgroundImage:[UIImage imageNamed:@"label"] forState:UIControlStateNormal];
            [hotKeyBtn setBackgroundImage:[UIImage imageNamed:@"label_pressed"] forState:UIControlStateHighlighted];
            if(lastPressedBtn.tag == hotKeyBtn.tag){
                [hotKeyBtn setBackgroundImage:[UIImage imageNamed:@"label_pressed"] forState:UIControlStateNormal];
                [hotKeyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
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

- (void)clearAllHistory
{
    [historyArray removeAllObjects];
    [[ContainerUtility sharedInstance] setAttribute:historyArray forKey:@"search_history"];
    table.frame = CGRectMake(80, 170, 370, 210);
    [table reloadData];
    if(historyArray.count > 0){
        [clearAllBtn setHidden:NO];
    } else {
        [clearAllBtn setHidden:YES];
    }
    clearAllBtn.frame = CGRectMake(clearAllBtn.frame.origin.x, table.frame.origin.y + table.frame.size.height + 10, 102, 33);
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
    if(lastPressedBtn != nil){
        [lastPressedBtn setBackgroundImage:[UIImage imageNamed:@"label"] forState:UIControlStateNormal];
        [lastPressedBtn setTitleColor:[CMConstants grayColor] forState:UIControlStateNormal];
    }
    [btn setBackgroundImage:[UIImage imageNamed:@"label_pressed"] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    lastPressedBtn = btn;
    int index = btn.tag - 2001;
    [self search:[[hotKeyArray objectAtIndex:index] objectForKey:@"content"]];
    table.frame = CGRectMake(80, 170, 370, historyArray.count * 40 + 210);
    [table reloadData];
    clearAllBtn.frame = CGRectMake(clearAllBtn.frame.origin.x, table.frame.origin.y + table.frame.size.height + 10, 102, 33);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 1 && indexPath.row < historyArray.count){
        NSString *keyword = [[historyArray objectAtIndex:indexPath.row] objectForKey:@"content"];
        [self search:keyword];
        lastPressedBtn = nil;
        table.frame = CGRectMake(80, 170, 370, historyArray.count * 40 + 210);
        [table reloadData];
        clearAllBtn.frame = CGRectMake(clearAllBtn.frame.origin.x, table.frame.origin.y + table.frame.size.height + 10, 102, 33);
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self search:searchBar.text];
    table.frame = CGRectMake(80, 170, 370, historyArray.count * 40 + 210);
    lastPressedBtn = nil;
    [table reloadData];
    clearAllBtn.frame = CGRectMake(clearAllBtn.frame.origin.x, table.frame.origin.y + table.frame.size.height + 10, 102, 33);
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    if(searchBar.text.length > 0){
        [searchBar resignFirstResponder];
        [self search:searchBar.text];
        table.frame = CGRectMake(80, 170, 370, historyArray.count * 40 + 210);
        lastPressedBtn = nil;
        [table reloadData];
        clearAllBtn.frame = CGRectMake(clearAllBtn.frame.origin.x, table.frame.origin.y + table.frame.size.height + 10, 102, 33);
    }
}

- (void)search:(NSString *)keyword
{
    BOOL isReachable = [[AppDelegate instance] performSelector:@selector(isParseReachable)];
    if(!isReachable) {
        [UIUtility showNetWorkError:self.view];
        return;
    }
    keyword = [keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    sBar.text = keyword;
    [self closeMenu];
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
    if(historyArray.count > 0){
        [clearAllBtn setHidden:NO];
    } else {
        [clearAllBtn setHidden:YES];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section > 0 && historyArray.count > 0 && indexPath.row < historyArray.count){
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleNone;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section > 0){
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            [historyArray removeObjectAtIndex:indexPath.row];
            [[ContainerUtility sharedInstance] setAttribute:historyArray forKey:@"search_history"];
            if (historyArray.count > 0) {
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                table.frame = CGRectMake(80, 170, 370, historyArray.count * 40 + 210);
                [clearAllBtn setHidden:NO];
            } else {
                table.frame = CGRectMake(80, 170, 370, 210);
                [tableView reloadData];
                [clearAllBtn setHidden:YES];
            }
            clearAllBtn.frame = CGRectMake(clearAllBtn.frame.origin.x, table.frame.origin.y + table.frame.size.height + 10, 102, 33);
        }
    }
}


@end
