//
//  SettingsViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-20.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "SearchViewController.h"
#import "CustomSearchBar.h"

#define TABLE_VIEW_WIDTH 370
#define MIN_BUTTON_WIDTH 45
#define MAX_BUTTON_WIDTH 355
#define BUTTON_HEIGHT 33
#define BUTTON_TITLE_GAP 13

@interface SearchViewController (){
    UIView *backgroundView;
    UIButton *menuBtn;
    UIImageView *topImage;
    UIImageView *bgImage;
    CustomSearchBar *sBar;
    UITableView *table;
    
    NSMutableArray *historyArray;
    NSMutableArray *hotKeyArray;
    
    NSMutableArray *hotKeyIndex;
    
    NSMutableDictionary *hotKeyBtnWidth;
}

@end

@implementation SearchViewController
@synthesize menuViewControllerDelegate;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super init]) {
		[self.view setFrame:frame];
        [self.view setBackgroundColor:[UIColor clearColor]];
        backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 24)];
        [backgroundView setBackgroundColor:[UIColor yellowColor]];
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
        topImage.image = [UIImage imageNamed:@"search_top_image"];
        [self.view addSubview:topImage];
        
        sBar = [[CustomSearchBar alloc]initWithFrame:CGRectMake(80, 115, 370, 38)];
        sBar.delegate = self;
        [self.view addSubview:sBar];
        
        table = [[UITableView alloc] initWithFrame:CGRectMake(80, 170, 370, 500) style:UITableViewStylePlain];
        [table setBackgroundColor:[UIColor clearColor]];
        [table setSeparatorStyle:UITableViewCellSelectionStyleNone];
		[table setDelegate:self];
		[table setDataSource:self];
        [table setScrollEnabled:NO];
        [self.view addSubview:table];
        
        historyArray = (NSMutableArray *)[[ContainerUtility sharedInstance] attributeForKey:@"search_history"];
        if(historyArray == nil){
            historyArray = [[NSMutableArray alloc]initWithCapacity:LOCAL_KEYS_NUMBER];
        }
        hotKeyArray = [[NSMutableArray alloc]initWithCapacity:10];
        hotKeyIndex = [[NSMutableArray alloc]initWithCapacity:10];
        hotKeyBtnWidth = [[NSMutableDictionary alloc]initWithCapacity:10];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
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
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:10], @"num", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathSearchTopKeywords parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *keyArray = (NSArray *)[result objectForKey:@"topKeywords"];
            if(keyArray != nil && keyArray.count > 0){
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
            [table reloadData];
        } else {
            
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    [table reloadData];
}

- (int)calculateBtnWidth:(NSString *)btnTitle
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, MAX_BUTTON_WIDTH -  2 * BUTTON_TITLE_GAP, 25)];
    label.text = btnTitle;
    [label sizeToFit];
    int btnWidth = label.frame.size.width + 2 * BUTTON_TITLE_GAP;
    NSLog(@"%@ => %i", btnTitle, btnWidth);
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
    [cell setSelectionStyle:UITableViewCellEditingStyleNone];
    if(indexPath.section == 0){
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
            UIButton *hotKeyBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            int btnWidth = [[hotKeyBtnWidth valueForKey:content] intValue];
            hotKeyBtn.frame = CGRectMake(btnPositionX, btnPositionY, btnWidth, BUTTON_HEIGHT);
            [hotKeyBtn setTitle:content forState:UIControlStateNormal];
            [cell.contentView addSubview:hotKeyBtn];
        }
    } else {
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
        return (hotKeyIndex.count - 1) * 40 + 20;
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
    [view addSubview:imageView];
    
    UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 100, 25)];
    [name setTextColor:CMConstants.textBlueColor];
    if(section == 0){
        [name setText:@"热 门 搜 索"];
    } else {
        [name setText:@"历 史 记 录"];
    }
    [name sizeToFit];
    [name setBackgroundColor:[UIColor clearColor]];
    [view addSubview:name];
    return view;
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
    [self addKeyToLocalHistory:sBar.text];
    [searchBar resignFirstResponder];
    [table reloadData];
    //    [itemsArray removeAllObjects];
    //    [self showProgressBar];
    //    [self getResult];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [self addKeyToLocalHistory:sBar.text];
    [searchBar resignFirstResponder];
    [table reloadData];
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
    [historyArray addObjectsFromArray:newHistoryArray];
    [[ContainerUtility sharedInstance]setAttribute:newHistoryArray forKey:@"search_history"];
}

@end
