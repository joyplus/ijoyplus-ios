//
//  ShowListViewController.m
//  yueshipin_ipad
//
//  Created by zhang zhipeng on 12-11-25.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "ShowListViewController.h"

@interface ShowListViewController ()

@end

@implementation ShowListViewController
@synthesize listData;
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
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view setBackgroundColor:[UIColor clearColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    self.listData = nil;
    [super viewDidUnload];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 5, 350, 20)];
//        nameLabel.backgroundColor = [UIColor clearColor];
//        nameLabel.tag = 1001;
//        nameLabel.font = [UIFont systemFontOfSize:15];
//        [cell.contentView addSubview:nameLabel];
        
        UIButton *nameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        nameBtn.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 30);
        nameBtn.tag = 1001;
        [nameBtn setBackgroundImage:[UIImage imageNamed:@"tab_show"] forState:UIControlStateNormal];
        [nameBtn setBackgroundImage:[UIImage imageNamed:@"tab_show_pressed"] forState:UIControlStateHighlighted];
        nameBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [nameBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [nameBtn setTitleColor:CMConstants.grayColor forState:UIControlStateHighlighted];
        [nameBtn addTarget:self action:@selector(nameBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        nameBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [nameBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
        [cell.contentView addSubview:nameBtn];
    }
    NSDictionary *item =  [listData objectAtIndex:indexPath.row];
    UIButton *nameBtn = (UIButton *)[cell viewWithTag:1001];
    NSString *name = [NSString stringWithFormat:@"%@", [item objectForKey:@"name"]];
    if ([item objectForKey:@"name"] == nil) {
        name = @"";
    }
    [nameBtn setTitle:name forState:UIControlStateNormal];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 32;
}

- (void)nameBtnClicked:(UIButton *)btn{
    CGPoint point = btn.center;
    point = [self.tableView convertPoint:point fromView:btn.superview];
    NSIndexPath* indexPath = [self.tableView indexPathForRowAtPoint:point];
    [self.parentDelegate playVideoCallback:indexPath.row];
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

@end
