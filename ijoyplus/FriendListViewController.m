//
//  SearchFilmResultViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-10.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "FriendListViewController.h"
#import "UIImageView+WebCache.h"
#import "FriendDetailViewController.h"
#import "CustomBackButtonHolder.h"
#import "CustomBackButton.h"
#import "CustomCellBlackBackground.h"
#import "CustomCellBackground.h"
#import "CMConstants.h"
#import "CustomColoredAccessory.h"

@interface FriendListViewController (){
     NSMutableArray *itemsArray;
}
- (void)closeSelf;
@end

@implementation FriendListViewController

@synthesize keyword;
@synthesize sBar;

- (void)viewDidUnload
{
    [self setSBar:nil];
    [super viewDidUnload];
    self.keyword = nil;
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
    self.title = NSLocalizedString(@"search", nil);
    CustomBackButtonHolder *backButtonHolder = [[CustomBackButtonHolder alloc]initWithViewController:self];
    CustomBackButton* backButton = [backButtonHolder getBackButton:NSLocalizedString(@"go_back", nil)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
	
    [self.sBar setText:self.keyword];
    self.sBar.delegate = self;
    
    [self.tableView setBackgroundColor:[UIColor clearColor]];
}

- (void)closeSelf
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    itemsArray = [[NSMutableArray alloc]initWithCapacity:10];
    
    NSMutableArray *items1 = [[NSMutableArray alloc]initWithCapacity:20];
    [items1 addObject:@"用户名称"];
    NSMutableDictionary *itemDic1 = [[NSMutableDictionary alloc]initWithCapacity:10];
    [itemDic1 setValue:items1 forKey:@"joined_friend"];
    [itemsArray addObject:itemDic1];
    
    NSMutableArray *items2 = [[NSMutableArray alloc]initWithCapacity:20];
    [items2 addObject:@"用户名称"];
    [items2 addObject:@"用户名称"];
    NSMutableDictionary *itemDic2 = [[NSMutableDictionary alloc]initWithCapacity:10];
    [itemDic2 setValue:items2 forKey:@"unjoined_friend"];
    [itemsArray addObject:itemDic2];
    
    NSMutableArray *items3 = [[NSMutableArray alloc]initWithCapacity:20];
    [items3 addObject:@"用户名称"];
    [items3 addObject:@"用户名称"];
    NSMutableDictionary *itemDic3 = [[NSMutableDictionary alloc]initWithCapacity:10];
    [itemDic3 setValue:items3 forKey:@"watched_friend"];
    [itemsArray addObject:itemDic3];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return itemsArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableDictionary *item = [itemsArray objectAtIndex:section];
    NSEnumerator *keys = item.keyEnumerator;
    NSString *key = [keys nextObject];
    NSMutableArray *array = [item objectForKey:key];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    NSMutableDictionary *item = [itemsArray objectAtIndex:indexPath.section];
    switch (indexPath.section) {
        case 0:
        {
            NSArray *friendArray = [item objectForKey:@"joined_friend"];
            cell.textLabel.text = [friendArray objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = @"+关注";
            cell.detailTextLabel.textColor = [UIColor colorWithRed:6/255.0 green:131/255.0 blue:239/255.0 alpha:1.0];
            break;
        }
        case 1:
        {
            NSArray *friendArray = [item objectForKey:@"unjoined_friend"];
            cell.textLabel.text = [friendArray objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = @"邀请";
            cell.detailTextLabel.textColor = [UIColor colorWithRed:10/255.0 green:126/255.0 blue:32/255.0 alpha:1.0];
            break;
        }
        case 2:
        {
            NSArray *friendArray = [item objectForKey:@"watched_friend"];
            cell.textLabel.text = [friendArray objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = @"已关注";
            cell.detailTextLabel.textColor = [UIColor lightGrayColor];
            break;
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    CustomColoredAccessory *accessory = [CustomColoredAccessory accessoryWithColor:[UIColor lightGrayColor]];
    accessory.highlightedColor = [UIColor whiteColor];
    cell.accessoryView = accessory;
    UIView *backgroundView;
    if(indexPath.row % 2 == 0){
        backgroundView = [[CustomCellBlackBackground alloc]init];
    } else {
        backgroundView = [[CustomCellBackground alloc]init];
    }
    [cell setBackgroundView:backgroundView];
    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSMutableDictionary *item = [itemsArray objectAtIndex:section];
    NSEnumerator *keys = item.keyEnumerator;
    NSString *key = [keys nextObject];
    NSArray *array = [item objectForKey:key];
    if(array.count > 0){
        UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,24)];
        customView.backgroundColor = [UIColor blackColor];
        UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bgwithline"]];
        imageView.frame = customView.frame;
        [customView addSubview:imageView];
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.font = [UIFont boldSystemFontOfSize:12];
        
        headerLabel.text =  [NSString stringWithFormat:NSLocalizedString(key, nil), self.keyword, nil];
        headerLabel.textColor = [UIColor lightGrayColor];
        [headerLabel sizeToFit];
        headerLabel.center = CGPointMake(headerLabel.frame.size.width/2 + 10, customView.frame.size.height/2);
        [customView addSubview:headerLabel];
        return customView;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
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
    [self.sBar resignFirstResponder];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    FriendDetailViewController *viewController = [[FriendDetailViewController alloc]initWithNibName:@"FriendDetailViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
}

@end
