//
//  SearchHistoryListViewController.m
//  yueshipin
//
//  Created by joyplus1 on 13-4-8.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "SearchHistoryListViewController.h"
#import "CommonHeader.h"

@interface SearchHistoryListViewController ()


@end

@implementation SearchHistoryListViewController
@synthesize historyArray;
@synthesize parentDelegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.layer.borderWidth = 1;
    self.view.layer.borderColor = CMConstants.tableBorderColor.CGColor;
    self.tableView.separatorColor = CMConstants.tableBorderColor;
    self.tableView.backgroundColor = [UIColor clearColor];
    UIImageView *bgImage = [[UIImageView alloc]initWithFrame:self.view.frame];
    bgImage.image = [UIImage imageNamed:@"search_history_bg@2x.jpg"];
    [self.tableView setBackgroundView:bgImage];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return historyArray.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    if (indexPath.row < historyArray.count) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [[historyArray objectAtIndex:indexPath.row] objectForKey:@"content"]];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.textColor = CMConstants.grayColor;
    }
    if (indexPath.row == historyArray.count) {
        UIButton *clearAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        clearAllBtn.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 35);
        [clearAllBtn setTitle:@"删除历史记录" forState:UIControlStateNormal];
        [clearAllBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [clearAllBtn setBackgroundImage:[UIImage imageNamed:@"clear"] forState:UIControlStateNormal];
        [clearAllBtn setBackgroundImage:[UIImage imageNamed:@"clear_pressed"] forState:UIControlStateHighlighted];
        [clearAllBtn addTarget:self action:@selector(clearAllHistory) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:clearAllBtn];
    }
    return cell;
}

- (void)clearAllHistory
{
    [historyArray removeAllObjects];
    [[ContainerUtility sharedInstance] setAttribute:historyArray forKey:@"search_history"];
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, 0);
    [self.parentDelegate clearSearchBarContent];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (historyArray.count > 0 && indexPath.row < historyArray.count){
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleNone;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [historyArray removeObjectAtIndex:indexPath.row];
        [[ContainerUtility sharedInstance] setAttribute:historyArray forKey:@"search_history"];
        if (historyArray.count > 0) {
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, (historyArray.count+1) * 35);
        } else {
            tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, 0);
        }
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < historyArray.count) {
        [self.parentDelegate historyCellClicked:[[historyArray objectAtIndex:indexPath.row] objectForKey:@"content"]];
    }
    if (indexPath.row == historyArray.count) {
        // do nothing
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.parentDelegate resignFirstRespond];
}

@end
