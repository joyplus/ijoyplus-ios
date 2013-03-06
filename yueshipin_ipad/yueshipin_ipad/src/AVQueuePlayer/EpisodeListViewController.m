//
//  GroupImageViewController.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-21.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "EpisodeListViewController.h"
#import "CommonHeader.h"

@interface EpisodeListViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation EpisodeListViewController
@synthesize table;
@synthesize currentNum;
@synthesize episodeArray;
@synthesize type;
@synthesize delegate;

- (void)viewDidUnload
{
    [super viewDidUnload];
    table = nil;
    episodeArray = nil;
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
    self.view.layer.borderColor = [UIColor colorWithRed:49/255.0 green:49/255.0 blue:49/255.0 alpha:0.6].CGColor;
    self.view.layer.borderWidth = 2;
    self.view.backgroundColor = [UIColor colorWithRed:10/255.0 green:10/255.0 blue:10/255.0 alpha:0.6];
    table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, EPISODE_TABLE_WIDTH, fmin(10, episodeArray.count) * EPISODE_TABLE_CELL_HEIGHT)];
    table.separatorColor = [UIColor colorWithRed:13/255.0 green:13/255.0 blue:13/255.0 alpha:1];
    table.backgroundColor = [UIColor clearColor];
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor = [UIColor clearColor];
    table.showsVerticalScrollIndicator = NO;
    [self.view addSubview:table];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return episodeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = [UIFont systemFontOfSize:18];
        nameLabel.tag = 1001;
        nameLabel.frame = CGRectMake(5, 5, EPISODE_TABLE_WIDTH - 10, EPISODE_TABLE_CELL_HEIGHT - 10);
        [cell.contentView addSubview:nameLabel];
    }
    UILabel *nameLabel  = (UILabel *)[cell viewWithTag:1001];
    if (type == 2) {
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.text = [NSString stringWithFormat:@"第%@集", [self.episodeArray objectAtIndex:indexPath.row]];
    } else if(type == 3){
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.text = [NSString stringWithFormat:@"%@", [self.episodeArray objectAtIndex:indexPath.row]];
    }
    if (indexPath.row == currentNum) {
        nameLabel.textColor = [UIColor colorWithRed:255/255.0 green:145/255.0 blue:0 alpha:1];
    } else {
        nameLabel.textColor = [UIColor colorWithRed:144/255.0 green:144/255.0 blue:144/255.0 alpha:1];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return EPISODE_TABLE_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [table deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row != currentNum && indexPath.row < episodeArray.count) {
        currentNum = indexPath.row;
        [table reloadData];
        [table scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        [delegate playOneEpisode:indexPath.row];
    }    
}


@end
