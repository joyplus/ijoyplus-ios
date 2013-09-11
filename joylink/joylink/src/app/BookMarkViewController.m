//
//  BookMarkViewController.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-28.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "BookMarkViewController.h"
#import "CommonHeader.h"

#define TABLE_CELL_HEIGHT 44

@interface BookMarkViewController ()<UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate>

@property (nonatomic, strong)UITableView *table;
@property (nonatomic, strong)NSArray *bookmarkList;
@end

@implementation BookMarkViewController
@synthesize table;
@synthesize delegate;
- (void)viewDidUnload
{
    [super viewDidUnload];
    table = nil;
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
    self.title = @"书签";
    [self showBackBtnForNavController];
    
    table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    table.separatorColor = [UIColor colorWithRed:52/255.0 green:52/255.0 blue:52/255.0 alpha:1];
    table.tableFooterView = [[UIView alloc] init];
    table.backgroundColor = [UIColor clearColor];
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor = [UIColor clearColor];
    table.showsVerticalScrollIndicator = NO;
    [self addInContentView:table];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *oldbookmarkList = (NSArray *)[[ContainerUtility sharedInstance]attributeForKey:BOOK_MARK_LIST];
    return oldbookmarkList.count;
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
        cellBg.hidden = YES;
        [cell.contentView addSubview:cellBg];
               
        UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 250, 44)];
        name.tag = 1001;
        name.font = [UIFont systemFontOfSize:15];
        name.backgroundColor = [UIColor clearColor];
        name.textColor = [UIColor whiteColor];
        [cell.contentView addSubview:name];
        
        UILabel *url = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 250, 44)];
        url.tag = 2001;
        url.font = [UIFont systemFontOfSize:15];
        url.backgroundColor = [UIColor clearColor];
        url.textColor = [UIColor whiteColor];
        [cell.contentView addSubview:url];
    }
    NSArray *oldbookmarkList = (NSArray *)[[ContainerUtility sharedInstance]attributeForKey:BOOK_MARK_LIST];
    if (indexPath.row < oldbookmarkList.count) {
        NSDictionary *item = [oldbookmarkList objectAtIndex:indexPath.row];
        NSString *name = [item objectForKey:@"name"];
        UILabel *nameLabel  = (UILabel *)[cell viewWithTag:1001];
        UILabel *url  = (UILabel *)[cell viewWithTag:2001];
        url.text = [NSString stringWithFormat:@"%@", [item objectForKey:@"url"]];
        if (name && name.length > 0) {
            nameLabel.text = name;
            [nameLabel setHidden:NO];
            [url setHidden:YES];
        } else {
            [nameLabel setHidden:YES];
            [url setHidden:NO];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TABLE_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [table cellForRowAtIndexPath:indexPath];
    UILabel *url  = (UILabel *)[cell viewWithTag:2001];
    [self.delegate openBookmark:url.text];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [table cellForRowAtIndexPath:indexPath];
    UILabel *name  = (UILabel *)[cell viewWithTag:2001];
    UILabel *cellBg  = (UILabel *)[cell viewWithTag:4001];
    name.textColor = CMConstants.textColor;
    [cellBg setHidden:NO];
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [table cellForRowAtIndexPath:indexPath];
    UILabel *name  = (UILabel *)[cell viewWithTag:2001];
    name.textColor = [UIColor whiteColor];
    UILabel *cellBg  = (UILabel *)[cell viewWithTag:4001];
    [cellBg setHidden:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle==UITableViewCellEditingStyleDelete)
    {
        UITableViewCell *cell = [table cellForRowAtIndexPath:indexPath];
        UILabel *name = (UILabel *)[cell viewWithTag:2001];
        [self removeFromBookmarkList:name.text];
        [table reloadData];
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
        if (url == nil || [url isEqualToString: urlstr]){
            continue;
        } else {
            [newBookmarkList addObject:item];
        }
    }
    [[ContainerUtility sharedInstance] setAttribute:newBookmarkList forKey:BOOK_MARK_LIST];
}

- (void)backButtonClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
