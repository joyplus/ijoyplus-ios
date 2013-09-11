//
//  BookMarkViewController.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-28.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "BookMarkViewController.h"
#import "CommonHeader.h"

#define TABLE_CELL_HEIGHT 55

@interface BookMarkViewController ()<UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate>

@property (nonatomic, strong)UITableView *table;
@property (nonatomic, strong)UIView *container;
@property (nonatomic, strong)UIView *tableContainer;
@property (nonatomic, strong)NSArray *bookmarkList;
@property (nonatomic, strong)NSString *bookmarkTitle;
@property (nonatomic, strong)UIWebView *webView;
@end

@implementation BookMarkViewController
@synthesize table;
@synthesize container;
@synthesize tableContainer;
@synthesize httpUrl;
@synthesize bookmarkList;
@synthesize bookmarkTitle;
@synthesize webView;

- (void)viewDidUnload
{
    [super viewDidUnload];
    container = nil;
    table = nil;
    tableContainer = nil;
    bookmarkList = nil;
    bookmarkTitle = nil;
    httpUrl = nil;
    webView.delegate = nil;
    [webView loadRequest: nil];
    [webView removeFromSuperview];
    webView = nil;
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
	[super showNavigationBar:@"书签"];
    [self addRemoteToolBar];
    [self addBookmarkToolBar];
    
    bookmarkList = (NSArray *)[[ContainerUtility sharedInstance]attributeForKey:BOOK_MARK_LIST];
    [self addBookmarkList];
    [self showToolbar];
    
    bookmarkTitle = @"未知网站";
    webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 1, 1)];
//    [webView setHidden:YES];
    webView.delegate = self;
    NSURL *url = [NSURL URLWithString:httpUrl];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [webView loadRequest:requestObj];
    [self.view addSubview:webView];
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)awebView
{
    bookmarkTitle = [awebView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (void)webViewDidFinishLoad:(UIWebView *)awebView {
	bookmarkTitle = [awebView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	bookmarkTitle = @"未知网站";
}

- (void)addRemoteToolBar
{
    UIToolbar *remoteToolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, self.bounds.size.width, TOOLBAR_HEIGHT)];
    [remoteToolBar setNeedsDisplay];
    [self.view addSubview:remoteToolBar];
    
    UIButton *firstButton = [UIButton buttonWithType:UIButtonTypeCustom];
    firstButton.frame = CGRectMake(10, 0, 40, 40);
    [firstButton setBackgroundImage:[UIImage imageNamed:@"menu_icon_blue"] forState:UIControlStateNormal];
    [firstButton setBackgroundImage:[UIImage imageNamed:@"menu_icon_blue_pressed"] forState:UIControlStateHighlighted];
    [firstButton addTarget:self action:@selector(firstButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [remoteToolBar addSubview:firstButton];
    
    UIButton *secondButton = [UIButton buttonWithType:UIButtonTypeCustom];
    secondButton.frame = CGRectMake(60, 0, 40, 40);
    [secondButton setBackgroundImage:[UIImage imageNamed:@"home_icon_blue"] forState:UIControlStateNormal];
    [secondButton setBackgroundImage:[UIImage imageNamed:@"home_icon_blue_pressed"] forState:UIControlStateHighlighted];
    [secondButton addTarget:self action:@selector(secondButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [remoteToolBar addSubview:secondButton];
    
    UIButton *thirdButton = [UIButton buttonWithType:UIButtonTypeCustom];
    thirdButton.frame = CGRectMake(110, 0, 40, 40);
    [thirdButton setBackgroundImage:[UIImage imageNamed:@"back_icon_blue"] forState:UIControlStateNormal];
    [thirdButton setBackgroundImage:[UIImage imageNamed:@"back_icon_blue_pressed"] forState:UIControlStateHighlighted];
    [thirdButton addTarget:self action:@selector(thirdButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [remoteToolBar addSubview:thirdButton];
    
    UIButton *fourthButton = [UIButton buttonWithType:UIButtonTypeCustom];
    fourthButton.frame = CGRectMake(170, 0, 40, 40);
    [fourthButton setBackgroundImage:[UIImage imageNamed:@"keyboard_icon"] forState:UIControlStateNormal];
    [fourthButton setBackgroundImage:[UIImage imageNamed:@"keyboard_icon_pressed"] forState:UIControlStateHighlighted];
    [fourthButton addTarget:self action:@selector(fourthButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [remoteToolBar addSubview:fourthButton];
    
    UIButton *fifthButton = [UIButton buttonWithType:UIButtonTypeCustom];
    fifthButton.frame = CGRectMake(220, 0, 40, 40);
    [fifthButton setBackgroundImage:[UIImage imageNamed:@"setting_icon"] forState:UIControlStateNormal];
    [fifthButton setBackgroundImage:[UIImage imageNamed:@"setting_icon_pressed"] forState:UIControlStateHighlighted];
    [fifthButton addTarget:self action:@selector(fourthButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [remoteToolBar addSubview:fifthButton];
    
    UIButton *sixthButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sixthButton.frame = CGRectMake(270, 0, 40, 40);
    [sixthButton setBackgroundImage:[UIImage imageNamed:@"mark_icon"] forState:UIControlStateNormal];
    [sixthButton setBackgroundImage:[UIImage imageNamed:@"mark_icon_pressed"] forState:UIControlStateHighlighted];
    [sixthButton addTarget:self action:@selector(fourthButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [remoteToolBar addSubview:sixthButton];
}


- (void)addBookmarkToolBar
{
    container = [[UIView alloc]initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT * 2 - 5, self.bounds.size.width, 50)];
    [container setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:container];
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(5, 10, 204, 35);
    [addBtn setBackgroundImage:[UIImage imageNamed:@"add_bt"] forState:UIControlStateNormal];
    [addBtn setBackgroundImage:[UIImage imageNamed:@"add_bt_pressed"] forState:UIControlStateHighlighted];
    [addBtn addTarget:self action:@selector(addBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:addBtn];
    
    UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    editBtn.frame = CGRectMake(self.bounds.size.width - 64, 10, 59, 35);
    [editBtn setBackgroundImage:[UIImage imageNamed:@"edit_bt"] forState:UIControlStateNormal];
    [editBtn setBackgroundImage:[UIImage imageNamed:@"edit_bt_pressed"] forState:UIControlStateHighlighted];
    [editBtn addTarget:self action:@selector(editBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:editBtn];
}


- (void)addBookmarkList
{
    int hight = bookmarkList.count * TABLE_CELL_HEIGHT + 10;
    if (bookmarkList.count == 0) {
        hight = 0;
    } else {
        hight = fmin(hight, 5 * TABLE_CELL_HEIGHT + 10);
    }
    tableContainer = [[UIView alloc]initWithFrame:CGRectMake(5, container.frame.origin.y + container.frame.size.height + 5, self.bounds.size.width-10, hight - 5)];
    [tableContainer setBackgroundColor:CMConstants.whiteBackgroundColor];
    tableContainer.layer.cornerRadius = 5;
    tableContainer.layer.masksToBounds = YES;
    [self.view addSubview:tableContainer];
    
    table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, tableContainer.frame.size.width, tableContainer.frame.size.height - 10) style:UITableViewStylePlain];
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.tableFooterView = [[UIView alloc] init];
    table.backgroundColor = [UIColor clearColor];
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor = [UIColor clearColor];
    table.showsVerticalScrollIndicator = NO;
    [tableContainer addSubview:table];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return bookmarkList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.contentView.backgroundColor = [UIColor clearColor];
        UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(10, 3, 200, 30)];
        name.font = [UIFont systemFontOfSize:15];
        name.backgroundColor = [UIColor clearColor];
        name.textColor = CMConstants.textGreyColor;
        name.tag = 1001;
        [cell.contentView addSubview:name];
        
        UILabel *urlLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 32, 200, 20)];
        urlLabel.font = [UIFont systemFontOfSize:12];
        urlLabel.backgroundColor = [UIColor clearColor];
        urlLabel.textColor = [UIColor lightGrayColor];
        urlLabel.tag = 1002;
        [cell.contentView addSubview:urlLabel];
        
        UIImageView *separator = [[UIImageView alloc]initWithFrame:CGRectMake(0, TABLE_CELL_HEIGHT - 2, self.bounds.size.width, 2)];
        separator.image = [UIImage imageNamed:@"divider_640"];
        [cell.contentView addSubview:separator];
    }
    NSDictionary *bookmark = [bookmarkList objectAtIndex:indexPath.row];
    UILabel *name = (UILabel *)[cell viewWithTag:1001];
    name.text = [NSString stringWithFormat:@"%@", [bookmark objectForKey:@"name"]];
    
    UILabel *urlLabel = (UILabel *)[cell viewWithTag:1002];
    urlLabel.text = [NSString stringWithFormat:@"%@", [bookmark objectForKey:@"url"]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TABLE_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [table deselectRowAtIndexPath:indexPath animated:YES];

}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle==UITableViewCellEditingStyleDelete)
    {
        NSMutableArray *newBookmarkList = [[NSMutableArray alloc]initWithCapacity:bookmarkList.count];
        [newBookmarkList addObjectsFromArray:bookmarkList];
        [newBookmarkList removeObjectAtIndex:indexPath.row];
        bookmarkList = newBookmarkList;
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [[ContainerUtility sharedInstance] setAttribute:bookmarkList forKey:BOOK_MARK_LIST];
        [table reloadData];
        
        [self changeTableViewContainerHeight:bookmarkList.count];
    }
}

- (void)addBtnClicked
{
    NSArray *oldbookmarkList = (NSArray *)[[ContainerUtility sharedInstance]attributeForKey:BOOK_MARK_LIST];
    NSString *urlstr = [httpUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([[urlstr lowercaseString] hasPrefix:@"http://"]) {
        urlstr = [urlstr substringFromIndex:7];
    }
    NSMutableArray *newBookmarkList = [[NSMutableArray alloc]initWithCapacity:10];
    BOOL exists;
    for(NSDictionary *item in oldbookmarkList){
        NSString *url = [item objectForKey:@"url"];
        if ([url isEqualToString: urlstr]){
            exists = YES;
            break;
        }
    }
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.opacity = 0.5;
    if (exists){
        HUD.labelText = @"该书签已存在。";
    } else {
        NSDictionary *item = [NSDictionary dictionaryWithObjectsAndKeys:urlstr, @"url", bookmarkTitle, @"name", nil];
        [newBookmarkList addObject:item];
        [newBookmarkList addObjectsFromArray:oldbookmarkList];
        [[ContainerUtility sharedInstance] setAttribute:newBookmarkList forKey:BOOK_MARK_LIST];
        bookmarkList = newBookmarkList;
        [table reloadData];
        
        [self changeTableViewContainerHeight:bookmarkList.count];

        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = @"添加成功";
    }
    [HUD show:YES];
    [HUD hide:YES afterDelay:2];
}

- (void)changeTableViewContainerHeight:(int)rowNum
{
    int hight = rowNum * TABLE_CELL_HEIGHT + 10;
    if (rowNum == 0) {
        hight = 0;
    } else {
        hight = fmin(hight, 5 * TABLE_CELL_HEIGHT + 10);
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [tableContainer setFrame:CGRectMake(tableContainer.frame.origin.x, tableContainer.frame.origin.y, tableContainer.frame.size.width, hight - 5)];
    [table setFrame:CGRectMake(table.frame.origin.x, table.frame.origin.y, table.frame.size.width, hight)];
    [UIView commitAnimations];
}

- (void)editBtnClicked:(UIButton *)editBtn
{
    [table setEditing:!table.editing animated:YES];
    if(table.editing) {
        [editBtn setBackgroundImage:[UIImage imageNamed:@"finish_bt"] forState:UIControlStateNormal];
        [editBtn setBackgroundImage:[UIImage imageNamed:@"finish_bt_pressed"] forState:UIControlStateHighlighted];
    } else {
        [editBtn setBackgroundImage:[UIImage imageNamed:@"edit_bt"] forState:UIControlStateNormal];
        [editBtn setBackgroundImage:[UIImage imageNamed:@"edit_bt_pressed"] forState:UIControlStateHighlighted];
    }
}

- (void)backButtonClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)homeButtonClicked
{
    [self dismissViewControllerAnimated:NO completion:^{
        [super homeButtonClicked];
    }];
}

@end
