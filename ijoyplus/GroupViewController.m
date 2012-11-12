//
//  VideoGoupViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-11-9.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "GroupViewController.h"
#import "GroupListCell.h"
#import "CustomBackButton.h"
#import "CustomColoredAccessory.h"
#import "MediaGridViewController.h"

@interface GroupViewController (){
    CustomBackButton *backButton;
}


@end

@implementation GroupViewController

@synthesize meidaType;

- (void)viewDidUnload
{
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
    [self loadLocalMediaFiles:self.meidaType];
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
    return groupMediaArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    GroupListCell *cell = (GroupListCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LocalShareCellFactory" owner:self options:nil];
        cell = (GroupListCell *)[nib objectAtIndex:0];
    }
    GroupMediaObject *media = [groupMediaArray objectAtIndex:indexPath.row];
    cell.listImageView.image = media.groupImage;
    cell.groupNameLabel.text = media.groupName;
    cell.numLabel.text = [NSString stringWithFormat:@"(%i)", media.itemNum];
    if(indexPath.row == 0){
        cell.showTopImage = YES;
    }    
    CustomColoredAccessory *accessory = [CustomColoredAccessory accessoryWithColor:[UIColor lightGrayColor]];
    accessory.highlightedColor = [UIColor whiteColor];
    cell.accessoryView = accessory;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MediaGridViewController *viewController = [[MediaGridViewController alloc]initWithNibName:@"MediaGridViewController" bundle:nil];
    GroupMediaObject *media = [groupMediaArray objectAtIndex:indexPath.row];
    viewController.mediaArray = media.mediaObjectArray;
    viewController.mediaType = self.meidaType;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)closeSelf
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
