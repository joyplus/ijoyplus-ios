//
//  LocalGroupViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-11-9.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "LocalGroupViewController.h"
#import "LocalGroupCell.h"
#import "GroupViewController.h"
#import "CustomBackButton.h"

@interface LocalGroupViewController (){
    CustomBackButton *backButton;
}

@end

@implementation LocalGroupViewController

- (void)viewDidUnload {
    [super viewDidUnload];
    backButton = nil;
}

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
    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    
    backButton = [[CustomBackButton alloc] initWith:[UIImage imageNamed:@"back-button"] highlight:[UIImage imageNamed:@"back-button"] leftCapWidth:14.0 text:NSLocalizedString(@"back", nil)];
    [backButton addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
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
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"localGroupCell";
    LocalGroupCell *cell = (LocalGroupCell*) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LocalShareCellFactory" owner:self options:nil];
        cell = (LocalGroupCell *)[nib objectAtIndex:1];
    }
    
    if(indexPath.row == 0){
        cell.cellTitle.text = @"分享我的照片";
        [cell.cellBtn addTarget:self action:@selector(photoCellClicked:) forControlEvents:UIControlEventTouchUpInside];
    } else if(indexPath.row == 1){
        cell.cellTitle.text = @"分享我的音乐";
//        [self.musicCell.cellBtn addTarget:self action:@selector(musicCellClicked:) forControlEvents:UIControlEventTouchUpInside];
    } else if(indexPath.row == 2){
        cell.cellTitle.text = @"分享我的视频";
        [cell.cellBtn addTarget:self action:@selector(videoCellClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (void)videoCellClicked:(id)sender
{
    GroupViewController *viewController = [[GroupViewController alloc]initWithNibName:@"GroupViewController" bundle:nil];
    viewController.meidaType = 2;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)photoCellClicked:(id)sender
{
    GroupViewController *viewController = [[GroupViewController alloc]initWithNibName:@"GroupViewController" bundle:nil];
    viewController.meidaType = 1;
    [self.navigationController pushViewController:viewController animated:YES];
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)closeSelf
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
