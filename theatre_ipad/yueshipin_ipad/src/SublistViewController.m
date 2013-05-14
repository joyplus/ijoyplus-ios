//
//  ShowListViewController.m
//  yueshipin_ipad
//
//  Created by zhang zhipeng on 12-11-25.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "SublistViewController.h"
#import "CustomColoredAccessory.h"
#import "ListViewController.h"

@interface SublistViewController ()

@end

@implementation SublistViewController
@synthesize listData;
@synthesize videoDelegate;

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.listData = nil;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.layer.borderWidth = 1;
    self.tableView.layer.borderColor = CMConstants.tableBorderColor.CGColor;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
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
    return listData.count > 5 ? 5 : listData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        CustomColoredAccessory *accessory = [CustomColoredAccessory accessoryWithColor:[UIColor blackColor]];
        accessory.highlightedColor = [UIColor whiteColor];
        cell.accessoryView = accessory;
        
//        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 5, cell.bounds.size.width+100, 30)];
//        nameLabel.backgroundColor = [UIColor redColor];
//        nameLabel.textColor = CMConstants.grayColor;
//        nameLabel.tag = 1001;
//        nameLabel.font = [UIFont systemFontOfSize:14];
//        [cell.contentView addSubview:nameLabel];
        
        UIImageView *devidingLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, 28, self.tableView.frame.size.width, 2)];
        devidingLine.image = [UIImage imageNamed:@"dividing"];
        [cell.contentView addSubview:devidingLine];
    }
    
    for (UIView *view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }
    
    UIButton * nameBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width - 50, 30)];
    nameBtn.backgroundColor = [UIColor clearColor];
    [nameBtn setTitleColor:CMConstants.grayColor forState:UIControlStateNormal];
    [nameBtn setTitleColor:CMConstants.yellowColor forState:UIControlStateHighlighted];
    nameBtn.tag = indexPath.row;
    nameBtn.titleLabel.textAlignment = UITextAlignmentLeft;
    
    nameBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [cell.contentView addSubview:nameBtn];
    [nameBtn addTarget:self
                action:@selector(buttonClicked:)
      forControlEvents:UIControlEventTouchUpInside];
    
    NSDictionary *item =  [listData objectAtIndex:indexPath.row];
    NSString * title = [item objectForKey:@"t_name"];
    [nameBtn setTitle:[NSString stringWithFormat:@"%@",title]
               forState:UIControlStateNormal];
    CGSize tSize = [title sizeWithFont:[UIFont systemFontOfSize:14]];
    [nameBtn setTitleEdgeInsets:UIEdgeInsetsMake(5, 10, 5, nameBtn.frame.size.width - 10 - tSize.width)];
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    [videoDelegate showSublistView:indexPath.row];
}

- (void)buttonClicked:(UIButton *)btn
{
    [videoDelegate showSublistView:btn.tag];
}

@end
