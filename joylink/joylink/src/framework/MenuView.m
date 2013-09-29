//
//  MenuView.m
//  joylink
//
//  Created by joyplus1 on 13-4-27.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "MenuView.h"
#import "CommonHeader.h"

#define CELL_HEIGHT NAVIGATION_BAR_HEIGHT

@interface MenuView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)UITableView *table;
@property (nonatomic)int lastSelectedIndex;
@end

@implementation MenuView
@synthesize table;
@synthesize lastSelectedIndex;
@synthesize menuDelegate;

- (id)init
{
    CGRect frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 130, 0, 130, [UIScreen mainScreen].bounds.size.height);
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"menu_background"]];
        table = [[UITableView alloc]initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, frame.size.width, frame.size.height)];
        table.separatorStyle = UITableViewCellSeparatorStyleNone;
        table.backgroundColor = [UIColor clearColor];
        table.delegate = self;
        table.dataSource = self;
        table.backgroundColor = [UIColor clearColor];
        table.showsVerticalScrollIndicator = NO;
        [self addSubview:table];
        [table reloadData];
    }
    return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return 11;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, 60, CELL_HEIGHT)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.tag = 1101;
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.highlightedTextColor = CMConstants.menuTextColor;
        [cell.contentView addSubview:nameLabel];
    }
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cell_background"]];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:1101];
    if (indexPath.row == 0) {
        nameLabel.text = @"首页";
        [cell setSelectedBackgroundView:view];
    } else if(indexPath.row == 1){
        nameLabel.text = @"遥控器";
        [cell setSelectedBackgroundView:view];
    } else if(indexPath.row == 2){
        nameLabel.text = @"鼠标";
        [cell setSelectedBackgroundView:view];
    } else if(indexPath.row == 8 && ![CommonMethod isIphone5]){
        [cell setSelectedBackgroundView:view];
        nameLabel.text = @"设置";
    } else if(indexPath.row == 10 && [CommonMethod isIphone5]){
        nameLabel.text = @"设置";
        [cell setSelectedBackgroundView:view];
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < 3 || (indexPath.row == 8 && ![CommonMethod isIphone5]) || (indexPath.row == 10 && [CommonMethod isIphone5])) {
        UITableViewCell *lastCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lastSelectedIndex inSection:0]];
        UILabel *nameLabel = (UILabel *)[lastCell viewWithTag:1101];
        nameLabel.highlighted = NO;
        
        lastSelectedIndex = indexPath.row;
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        nameLabel = (UILabel *)[cell viewWithTag:1101];
        nameLabel.highlighted = NO;
        
        if (menuDelegate && [menuDelegate respondsToSelector:@selector(closeMenu)]) {
            [menuDelegate closeMenu];
        }        
        if (indexPath.row == 0) {
            [menuDelegate homeMenuClicked];
        } else if(indexPath.row == 1){
            [menuDelegate remoteMenuClicked];
        } else if(indexPath.row == 2){
            [menuDelegate mouseMenuClicked];
        } else if(indexPath.row == 8 && ![CommonMethod isIphone5]){
            [menuDelegate settingsMenuClicked];
        } else if(indexPath.row == 10 && [CommonMethod isIphone5]){
            [menuDelegate settingsMenuClicked];
        }
    }
}

@end
