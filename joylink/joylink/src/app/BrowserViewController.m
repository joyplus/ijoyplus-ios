//
//  GroupImageViewController.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-21.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "BrowserViewController.h"
#import "CommonHeader.h"
#import "BookMarkViewController.h"
#import "AppListViewController.h"
#import "JSONKit.h"
#import "MouseRemoteViewController.h"

#define LOCAL_KEYS_NUMBER 20

@interface BrowserViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)UITextField *urlField;
@property (nonatomic, strong)NSString *searchStr;
@property (nonatomic, strong)UITableView *table;
@end

@implementation BrowserViewController
@synthesize urlField;
@synthesize searchStr;
@synthesize table;
@synthesize appInfo;

- (void)viewDidUnload
{
    [super viewDidUnload];
    urlField = nil;
    searchStr = nil;
    table = nil;
    appInfo = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    [self addMenuView:-NAVIGATION_BAR_HEIGHT];
    [self addContententView:0];
    [self showMenuBtnForNavController];
    self.title = @"浏览器";
    [self showBackBtnForNavController];
    [self addAddressView];
    
    table = [[UITableView alloc]initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - NAVIGATION_BAR_HEIGHT)];
    table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    table.separatorColor = [UIColor colorWithRed:52/255.0 green:52/255.0 blue:52/255.0 alpha:1];
    table.backgroundColor = [UIColor clearColor];
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor = [UIColor clearColor];
    table.showsVerticalScrollIndicator = NO;
    table.tableFooterView = [[UIView alloc] init];
    [self addInContentView:table];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(urlFieldChanged) name:UITextFieldTextDidChangeNotification object:nil];
    
    NSNumber *addedDefault = (NSNumber *)[[ContainerUtility sharedInstance]attributeForKey:@"added_default_favorite"];
    if (addedDefault == nil || !addedDefault.boolValue) {
        NSDictionary *mark1 = [NSDictionary dictionaryWithObjectsAndKeys:@"www.baidu.com", @"url", @"百度", @"name", nil];
        NSDictionary *mark2 = [NSDictionary dictionaryWithObjectsAndKeys:@"www.showkey.tv", @"url", @"Showkey官网", @"name", nil];
        NSDictionary *mark3 = [NSDictionary dictionaryWithObjectsAndKeys:@"www.7po.com/forum-345-1.html", @"url", @"Showkey讨论", @"name", nil];
        NSDictionary *mark4 = [NSDictionary dictionaryWithObjectsAndKeys:@"http://hao.360.cn/", @"url", @"360导航", @"name", nil];
        NSArray *oldbookmarkList = (NSArray *)[[ContainerUtility sharedInstance]attributeForKey:BOOK_MARK_LIST];
        NSMutableArray *newBookmarkList = [[NSMutableArray alloc]initWithCapacity:10];
        [newBookmarkList addObject:mark1];
        [newBookmarkList addObject:mark2];
        [newBookmarkList addObject:mark3];
        [newBookmarkList addObject:mark4];
        [newBookmarkList addObjectsFromArray:oldbookmarkList];
        [[ContainerUtility sharedInstance] setAttribute:newBookmarkList forKey:BOOK_MARK_LIST];
        [[ContainerUtility sharedInstance] setAttribute:[NSNumber numberWithBool:YES] forKey:@"added_default_favorite"];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIButton *imageBtn = (UIButton *)[self.navigationController.navigationBar viewWithTag:REFRESH_BTN_TAG];
    [imageBtn setHidden:YES];
    [table reloadData];
}

- (void)addAddressView
{
    UIView *container = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, NAVIGATION_BAR_HEIGHT)];
    [container setBackgroundColor:[UIColor colorWithRed:27/255.0 green:27/255.0 blue:27/255.0 alpha:1]];
    [self addInContentView:container];
    
    urlField = [[UITextField alloc]initWithFrame:CGRectMake(10, 7, container.frame.size.width - 60, 30)];
    urlField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    urlField.clearsOnBeginEditing = YES;
    urlField.borderStyle = UITextBorderStyleRoundedRect;
    urlField.placeholder = @"请输入网址";
    urlField.delegate = self;
    urlField.font = [UIFont systemFontOfSize:14];
    urlField.backgroundColor = [UIColor colorWithRed:241/255.0 green:241/255.0 blue:241/255.0 alpha:1];
    urlField.keyboardType = UIKeyboardTypeURL;
    urlField.returnKeyType = UIReturnKeyGo;
    [urlField becomeFirstResponder];
    [container addSubview:urlField];
    
    UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    editBtn.frame = CGRectMake(self.view.frame.size.width - 46, 4, 37, 37);
    [editBtn setBackgroundImage:[UIImage imageNamed:@"fav"] forState:UIControlStateNormal];
    [editBtn setBackgroundImage:[UIImage imageNamed:@"fav_active"] forState:UIControlStateHighlighted];
    [editBtn addTarget:self action:@selector(editBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:editBtn];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *historyArray = (NSArray *)[[ContainerUtility sharedInstance]attributeForKey:USER_INPUT_URL_HISTORY];
    return historyArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *cellBg = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
        cellBg.tag = 4001;
        cellBg.backgroundColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:20/255.0 alpha:0.5];
        [cell.contentView addSubview:cellBg];
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 42, 7, 30, 30)];
        imageView.tag = 1001;
        [cell.contentView addSubview:imageView];
        
        UIButton *imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [imageBtn setFrame:CGRectMake(0, 0, 40, 40)];
        [imageBtn addTarget:self action:@selector(imageClicked:)forControlEvents:UIControlEventTouchUpInside];
        imageBtn.tag = 3001;
        imageBtn.center = imageView.center;
        [cell.contentView addSubview:imageBtn];
        
        UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 180, 44)];
        name.tag = 2001;
        name.font = [UIFont systemFontOfSize:15];
        name.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:name];        
    }
    NSArray *historyArray = (NSArray *)[[ContainerUtility sharedInstance]attributeForKey:USER_INPUT_URL_HISTORY];
    if (indexPath.row < historyArray.count) {
        NSDictionary *item = [historyArray objectAtIndex:indexPath.row];
        UIImageView *imageView  = (UIImageView *)[cell viewWithTag:1001];
        UILabel *name  = (UILabel *)[cell viewWithTag:2001];
        UILabel *cellBg  = (UILabel *)[cell viewWithTag:4001];
        name.text = [NSString stringWithFormat:@"%@", [item objectForKey:@"content"]];
        if ([self checkInFavorite:name.text]) {
            name.textColor = CMConstants.textColor;
            [imageView setImage:[UIImage imageNamed:@"star_active"]];
            [cellBg setHidden:NO];
        } else {
            name.textColor = [UIColor whiteColor];
            [imageView setImage:[UIImage imageNamed:@"star"]];
            [cellBg setHidden:YES];
        }
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UILabel *name = (UILabel *)[cell viewWithTag:2001];
    urlField.text = name.text;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [urlField resignFirstResponder];
}

- (void)imageClicked:(UIButton *)btn
{
    [urlField resignFirstResponder];
    CGPoint point = btn.center;
    point = [table convertPoint:point fromView:btn.superview];
    NSIndexPath* indexPath = [table indexPathForRowAtPoint:point];
    UITableViewCell *cell = [table cellForRowAtIndexPath:indexPath];
    UIImageView *imageView  = (UIImageView *)[cell viewWithTag:1001];
    UILabel *name = (UILabel *)[cell viewWithTag:2001];
    UILabel *cellBg  = (UILabel *)[cell viewWithTag:4001];
    if([self checkInFavorite:name.text]){
        [self performSelectorInBackground:@selector(removeFromBookmarkList:) withObject:name.text];
        [imageView setImage:[UIImage imageNamed:@"star"]];
        [cellBg setHidden:NO];
    } else {
        [self performSelectorInBackground:@selector(addIntoBookmarkList:) withObject:name.text];
        [imageView setImage:[UIImage imageNamed:@"star_active"]];
        [cellBg setHidden:YES];
    }
}

- (void)removeFromBookmarkList:(NSString *)httpUrl
{
    NSArray *oldbookmarkList = (NSArray *)[[ContainerUtility sharedInstance]attributeForKey:BOOK_MARK_LIST];
    NSString *urlstr = [httpUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([[urlstr lowercaseString] hasPrefix:@"http://"]) {
        urlstr = [urlstr substringFromIndex:7];
    }
    NSMutableArray *newBookmarkList = [[NSMutableArray alloc]initWithCapacity:10];
    for(NSDictionary *item in oldbookmarkList){
        NSString *url = [item objectForKey:@"url"];
        if ([url isEqualToString: urlstr]){
            continue;
        } else {
            [newBookmarkList addObject:item];
        }
    }
    [[ContainerUtility sharedInstance] setAttribute:newBookmarkList forKey:BOOK_MARK_LIST];
    [table reloadData];
}

- (void)addIntoBookmarkList:(NSString *)httpUrl
{
    NSArray *oldbookmarkList = (NSArray *)[[ContainerUtility sharedInstance]attributeForKey:BOOK_MARK_LIST];
    NSString *urlstr = [httpUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([[urlstr lowercaseString] hasPrefix:@"http://"]) {
        urlstr = [urlstr substringFromIndex:7];
    }
    NSMutableArray *newBookmarkList = [[NSMutableArray alloc]initWithCapacity:10];
    [newBookmarkList addObjectsFromArray:oldbookmarkList];
    BOOL exists = NO;
    for(NSDictionary *item in oldbookmarkList){
        NSString *url = [item objectForKey:@"url"];
        if ([url isEqualToString: urlstr]){
            exists = YES;
            break;
        }
    }
    NSString *currentDateString = [DateUtility formatDateWithString:[NSDate date] formatString: @"yyyy-MM-dd HH:mm:ss"];
    NSDictionary *item = [NSDictionary dictionaryWithObjectsAndKeys:urlstr, @"url", currentDateString, @"add_date", nil];
    if (!exists) {
        [newBookmarkList addObject:item];
    }
    [[ContainerUtility sharedInstance] setAttribute:newBookmarkList forKey:BOOK_MARK_LIST];
    [table reloadData];
}

- (void)backButtonClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length > 0) {        
        self.searchStr = [textField text];
        [textField resignFirstResponder];
        [self performSelectorInBackground:@selector(goBtnClicked) withObject:nil];
    }
    return YES;
}

- (void)goBtnClicked
{
    [self addKeyToLocalHistory:urlField.text];
    [[AppDelegate instance] closePreviousApp];
    [AppDelegate instance].lastApp = appInfo;    
    [self performSelectorOnMainThread:@selector(openBrowser:) withObject:urlField.text waitUntilDone:YES];
}

- (void)openBookmark:(NSString *)url
{
    if (![appInfo isEqualToDictionary:[AppDelegate instance].lastApp]) {        
        [[AppDelegate instance] closePreviousApp];
        [AppDelegate instance].lastApp = appInfo;
    }
    [self openBrowser:url];
}

- (void)openBrowser:(NSString *)url
{
    RemoteAction *action = [ActionFactory getMessageAction:BROWSER_REQUEST_URL];
    [action trigger:url];
    RemoteViewController *viewController = [[MouseRemoteViewController alloc]init];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)addKeyToLocalHistory:(NSString *)key
{
    NSString *urlstr = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([[urlstr lowercaseString] hasPrefix:@"http://"]) {
        urlstr = [urlstr substringFromIndex:7];
    }
    NSArray *array = (NSArray *)[[ContainerUtility sharedInstance] attributeForKey:USER_INPUT_URL_HISTORY];
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
        if([content isEqualToString:urlstr]){
            newItem = item;
            break;
        }
    }
    NSString *currentDateString = [DateUtility formatDateWithString:[NSDate date] formatString: @"yyyy-MM-dd HH:mm:ss"];
    if(newItem != nil){
        [newItem setValue:currentDateString forKey:@"last_search_date"];
    } else {
        newItem = [[NSMutableDictionary alloc]initWithCapacity:2];
        [newItem setValue:urlstr forKey:@"content"];
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
    NSMutableArray *historyArray = [[NSMutableArray alloc]initWithCapacity:LOCAL_KEYS_NUMBER];
    NSArray *sortedArray = [newHistoryArray sortedArrayUsingComparator:^(id a, id b) {
        NSDate *first = [DateUtility dateFromFormatString:[(NSMutableDictionary*)a objectForKey:@"last_search_date"] formatString: @"yyyy-MM-dd HH:mm:ss"] ;
        NSDate *second = [DateUtility dateFromFormatString:[(NSMutableDictionary*)b objectForKey:@"last_search_date"] formatString: @"yyyy-MM-dd HH:mm:ss"];
        return [second compare:first];
    }];
    [historyArray addObjectsFromArray:sortedArray];
    [[ContainerUtility sharedInstance]setAttribute:newHistoryArray forKey:USER_INPUT_URL_HISTORY];
    [table reloadData];
}

- (void)urlFieldChanged
{
//    if ([urlField.text length] != 0) {
//		ddList._searchText = urlField.text;
//		[self setDDListHidden:NO];
//		[ddList updateData];
//	}
//	else {
//		[self setDDListHidden:YES];
//	}
}

- (void)hideKeyBoard
{
    [urlField resignFirstResponder];
}

- (BOOL)checkInFavorite:(NSString *)name
{
    NSArray *bookmarkList = (NSArray *)[[ContainerUtility sharedInstance]attributeForKey:BOOK_MARK_LIST];
    BOOL exists = NO;
    for(NSDictionary *item in bookmarkList){
        NSString *url = [item objectForKey:@"url"];
        if ([url isEqualToString: name]){
            exists = YES;
            break;
        }
    }
    return exists;
}

- (void)editBtnClicked
{
    BookMarkViewController *viewController = [[BookMarkViewController alloc]init];
    viewController.httpUrl = urlField.text;
    viewController.delegate = self;
    [self.navigationController pushViewController:viewController animated:YES];
    [self hideKeyBoard];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle==UITableViewCellEditingStyleDelete)
    {
        [self removeFromHistroy:indexPath.row];
        [table reloadData];
    }
}

- (void)removeFromHistroy:(int)row
{
    NSArray *oldHistory = (NSArray *)[[ContainerUtility sharedInstance]attributeForKey:USER_INPUT_URL_HISTORY];
    NSMutableArray *newHistory = [[NSMutableArray alloc]initWithCapacity:10];
    for(int i = 0; i < oldHistory.count; i++){
        if (i == row && i < oldHistory.count){
            continue;
        } else {
            [newHistory addObject:[oldHistory objectAtIndex:i]];
        }
    }
    [[ContainerUtility sharedInstance] setAttribute:newHistory forKey:USER_INPUT_URL_HISTORY];
}


@end
