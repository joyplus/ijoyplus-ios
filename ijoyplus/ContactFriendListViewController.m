//
//  SearchFilmResultViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-10.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "ContactFriendListViewController.h"
#import "UIImageView+WebCache.h"
#import "FriendDetailViewController.h"
#import "CustomBackButtonHolder.h"
#import "CustomBackButton.h"
#import "CustomCellBlackBackground.h"
#import "CustomCellBackground.h"
#import "CMConstants.h"
#import "CustomColoredAccessory.h"
#import "StringUtility.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "PhoneNumberCell.h"

@interface ContactFriendListViewController (){
    NSMutableArray *itemsArray;
    //    EGORefreshTableHeaderView *_refreshHeaderView;
    //	BOOL _reloading;
    //    MNMBottomPullToRefreshManager *pullToRefreshManager_;
    //    NSUInteger reloads_;
    //    int pageSize;
}
@property (strong, nonatomic) IBOutlet PhoneNumberCell *phoneNumberCell;
- (void)closeSelf;
@end

@implementation ContactFriendListViewController
@synthesize phoneNumberCell;
@synthesize keyword;
@synthesize sBar;
@synthesize sourceType;

- (void)viewDidUnload
{
    [self setPhoneNumberCell:nil];
    [super viewDidUnload];
    [self setSBar:nil];
    self.keyword = nil;
    //    _refreshHeaderView = nil;
    //    pullToRefreshManager_ = nil;
    self.sourceType = nil;
    itemsArray = nil;
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
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    CustomBackButtonHolder *backButtonHolder = [[CustomBackButtonHolder alloc]initWithViewController:self];
    CustomBackButton* backButton = [backButtonHolder getBackButton:NSLocalizedString(@"go_back", nil)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
	
    [self.sBar setText:self.keyword];
    self.sBar.delegate = self;
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: kAppKey, @"app_key", self.sourceType, @"source_type", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathUserThirdPartyUsers parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *item = [result objectForKey:@"users"];
            itemsArray = [[NSMutableArray alloc]initWithCapacity:100];
            if(item.count > 0){
                [itemsArray addObjectsFromArray:item];
                [self.tableView reloadData];
            }
        } else {
            
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)closeSelf
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return 1;
    } else {
        return 1;
    }
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
            self.phoneNumberCell.inputField.placeholder = @"本机号码";
            return self.phoneNumberCell;
        }
        case 1:
        {
            NSArray *friendArray = [item objectForKey:@"joined_friend"];
            cell.textLabel.text = [friendArray objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = @"+关注";
            cell.detailTextLabel.textColor = [UIColor colorWithRed:6/255.0 green:131/255.0 blue:239/255.0 alpha:1.0];
            break;
        }
        case 2:
        {
            NSArray *friendArray = [item objectForKey:@"unjoined_friend"];
            cell.textLabel.text = [friendArray objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = @"邀请";
            cell.detailTextLabel.textColor = [UIColor colorWithRed:10/255.0 green:126/255.0 blue:32/255.0 alpha:1.0];
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
    if(section > 0){
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
        
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        return 0;
    }
    return 24;
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
