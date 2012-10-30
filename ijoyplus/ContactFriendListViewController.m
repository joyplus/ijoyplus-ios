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
#import "CustomBackButton.h"
#import "CustomCellBlackBackground.h"
#import "CustomCellBackground.h"
#import "CMConstants.h"
#import "CustomColoredAccessory.h"
#import "StringUtility.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "PhoneNumberCell.h"
#import "ContainerUtility.h"
#import "HomeViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface ContactFriendListViewController (){
    NSMutableArray *itemsArray;
    NSMutableArray *joinedFriendArray;
    NSMutableArray *joinedFriendUserId;
    NSMutableArray *unjoinedFriendArray;
    UIToolbar *keyboardToolbar;
    MBProgressHUD *HUD;
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
    itemsArray = nil;
    joinedFriendArray = nil;
    unjoinedFriendArray = nil;
    self.sourceType = nil;
    itemsArray = nil;
    keyboardToolbar = nil;
    HUD = nil;
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
    CustomBackButton *backButton = [[CustomBackButton alloc] initWith:[UIImage imageNamed:@"back-button"] highlight:[UIImage imageNamed:@"back-button"] leftCapWidth:14.0 text:NSLocalizedString(@"back", nil)];
    [backButton addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
	
    [self.sBar setText:self.keyword];
    self.sBar.delegate = self;
    
    
    if (keyboardToolbar == nil) {
        keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 38.0f)];
        keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
        UIBarButtonItem *spaceBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                      target:nil
                                                                                      action:nil];
        
        UIBarButtonItem *doneBarItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"done", @"")
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self
                                                                       action:@selector(resignKeyboard:)];
        [doneBarItem setBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        
        [keyboardToolbar setItems:[NSArray arrayWithObjects:spaceBarItem, doneBarItem, nil]];
        
        self.phoneNumberCell.inputField.tag = 1;
        self.phoneNumberCell.inputField.inputAccessoryView = keyboardToolbar;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideProgressBar) name:@"top_segment_clicked" object:nil];
    [self uploadAddressBook];
}


- (void)uploadAddressBook
{
    NSMutableArray *addressBookTemp = [NSMutableArray array];
    ABAddressBookRef addressBooks = ABAddressBookCreate();
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBooks);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBooks);
    
    NSMutableString *friendIds = [[NSMutableString alloc]init];
    for (int i = 0; i < nPeople; i++)
    {
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
        CFStringRef abFullName = ABRecordCopyCompositeName(person);
        ABMutableMultiValueRef phoneMulti = ABRecordCopyValue(person, kABPersonPhoneProperty);
        if (ABMultiValueGetCount(phoneMulti) > 0) {
            CFStringRef cfString = ABMultiValueCopyValueAtIndex(phoneMulti, 0);
            NSString *phoneNumber = (__bridge NSString*)cfString;
            NSString *validatedPhoneNumber = [self validatePhoneNumber:phoneNumber];
            if(validatedPhoneNumber != nil){
                [friendIds appendFormat:@"%@,", validatedPhoneNumber];
                NSDictionary *contact = [NSDictionary dictionaryWithObjectsAndKeys: (__bridge NSString*)abFullName, @"name", validatedPhoneNumber, @"number", nil];
                [addressBookTemp addObject:contact];
            }
            validatedPhoneNumber = nil;
            phoneNumber = nil;
            CFRelease(cfString);
        }
        CFRelease(phoneMulti);
        CFRelease(abFullName);
    }
    [friendIds appendString:@"0"];
    CFRelease(allPeople);
    CFRelease(addressBooks);
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: @"5", @"source_type", friendIds, @"source_ids", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathGenUserThirdPartyUsers parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if([responseCode isEqualToString:kSuccessResCode]){
            joinedFriendArray  = [[NSMutableArray alloc]initWithCapacity:10];
            joinedFriendUserId  = [[NSMutableArray alloc]initWithCapacity:10];
            unjoinedFriendArray  = [[NSMutableArray alloc]initWithCapacity:100];
            NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: self.sourceType, @"source_type", nil];
            [[AFServiceAPIClient sharedClient] getPath:kPathUserThirdPartyUsers parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
                NSString *responseCode = [result objectForKey:@"res_code"];
                if(responseCode == nil){
                    NSArray *item = [result objectForKey:@"users"];
                    itemsArray = [[NSMutableArray alloc]initWithCapacity:10];
                    [itemsArray addObjectsFromArray:item];
                    for(NSDictionary *contact in addressBookTemp){
                        BOOL exists = NO;
                        for(NSDictionary *user in item){
                            if([[user objectForKey:@"thirdpart_id"] isEqualToString:[contact objectForKey:@"number"]]){
                                [joinedFriendUserId addObject:[user objectForKey:@"friend_id"]];
                                exists = YES;
                                break;
                            }
                        }
                        if(exists){
                            [joinedFriendArray addObject:contact];
                        } else {
                            [unjoinedFriendArray addObject:contact];
                        }
                    }
                    [self.tableView reloadData];
                } else {
                    
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
            } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"%@", error);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
            }];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
        }
        
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
    }];
}

- (void) hideProgressBar
{
    [HUD hide:YES afterDelay:0.3];
}

- (NSString *)validatePhoneNumber:(NSString *)phoneNumber
{
    
    NSString *validatePhoneNumber = [[[phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""]
                                      stringByReplacingOccurrencesOfString:@"-" withString:@""]
                                     stringByReplacingOccurrencesOfString:@"+86" withString:@""];
    NSRange range = {0, 1};
    if(![[validatePhoneNumber substringWithRange:range] isEqualToString:@"0"] && [validatePhoneNumber length] == 11){
        return validatePhoneNumber;
    } else {
        return nil;
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathUserView parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSString *phoneNumber = [result valueForKey:@"phone"];
            if(![StringUtility stringIsEmpty:phoneNumber]){
                self.phoneNumberCell.inputField.text = phoneNumber;
            }
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    if(itemsArray == nil){
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        HUD.opacity = 0;
        [HUD show:YES];
    }
}

- (void)closeSelf
{
    [self uploadMyContactNumber];
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
    } else if(section == 1){
        return joinedFriendArray.count;
    } else{
        return unjoinedFriendArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"contactListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
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
    }
    switch (indexPath.section) {
        case 0:
        {
            self.phoneNumberCell.inputField.placeholder = @"本机号码";
            return self.phoneNumberCell;
        }
        case 1:
        {
            cell.textLabel.text = [[joinedFriendArray objectAtIndex:indexPath.row] valueForKey:@"name"];
            cell.detailTextLabel.text = @"+关注";
            cell.detailTextLabel.textColor = [UIColor colorWithRed:6/255.0 green:131/255.0 blue:239/255.0 alpha:1.0];
            break;
        }
        case 2:
        {
            cell.textLabel.text = [[unjoinedFriendArray objectAtIndex:indexPath.row] valueForKey:@"name"];
            cell.detailTextLabel.text = @"邀请";
            cell.detailTextLabel.textColor = [UIColor colorWithRed:10/255.0 green:126/255.0 blue:32/255.0 alpha:1.0];
            break;
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        return 80;
    } else {
        return 44;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section > 0){
        UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,24)];
        customView.backgroundColor = [UIColor blackColor];
        UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bgwithline"]];
        imageView.frame = customView.frame;
        [customView addSubview:imageView];
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.font = [UIFont boldSystemFontOfSize:14];
        
        if(section == 1){
            headerLabel.text = @"好友列表";
        } else {
            headerLabel.text = @"邀请好友";
        }
        headerLabel.textColor = [UIColor lightGrayColor];
        [headerLabel sizeToFit];
        headerLabel.center = CGPointMake(headerLabel.frame.size.width/2 + 10, customView.frame.size.height/2);
        [customView addSubview:headerLabel];
        return customView;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0){
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
    if (joinedFriendArray.count > 0){
        if(indexPath.section == 0){
            HomeViewController *viewController = [[HomeViewController alloc]initWithNibName:@"HomeViewController" bundle:nil];
            viewController.userid = [joinedFriendUserId objectAtIndex:indexPath.row];
            [self.navigationController pushViewController:viewController animated:YES];
        } else {
            FriendDetailViewController *viewController = [[FriendDetailViewController alloc]initWithNibName:@"FriendDetailViewController" bundle:nil];
            viewController.friendInfo = [unjoinedFriendArray objectAtIndex:indexPath.row];
            [self.navigationController pushViewController:viewController animated:YES];
        }
    } else {
        FriendDetailViewController *viewController = [[FriendDetailViewController alloc]initWithNibName:@"FriendDetailViewController" bundle:nil];
        viewController.friendInfo = [unjoinedFriendArray objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:viewController animated:YES];
    }
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


- (void)resignKeyboard:(id)sender
{
    [self uploadMyContactNumber];
    [self.phoneNumberCell.inputField resignFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self uploadMyContactNumber];
    [self resignKeyboard:nil];
    return YES;
}

- (void)uploadMyContactNumber
{
    if ([StringUtility stringIsEmpty:self.phoneNumberCell.inputField.text]){
        return;
    }
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: self.phoneNumberCell.inputField.text, @"phone", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathAccountBindPhone parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if([responseCode isEqualToString:kSuccessResCode]){
            [[ContainerUtility sharedInstance]setAttribute:self.phoneNumberCell.inputField.text forKey:kPhoneNumber];
        } else {
            
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
    
}

@end
