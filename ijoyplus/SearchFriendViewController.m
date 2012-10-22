//
//  SearchFriendViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-25.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "SearchFriendViewController.h"
#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "CustomBackButton.h"
#import "FriendListViewController.h"
#import "SinaLoginViewController.h"
#import "TecentViewController.h"
#import "ContainerUtility.h"
#import "PopularUserViewController.h"
#import "ContactFriendListViewController.h"
#import "StringUtility.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "CacheUtility.h"
#import "UIUtility.h"

@interface SearchFriendViewController ()

@end

@implementation SearchFriendViewController

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
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    CustomBackButton *backButton = [[CustomBackButton alloc] initWith:[UIImage imageNamed:@"back-button"] highlight:[UIImage imageNamed:@"back-button"] leftCapWidth:14.0 text:NSLocalizedString(@"back", nil)];
    [backButton addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.tableView.separatorColor = [UIColor clearColor];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    self.title = NSLocalizedString(@"search_friend", nil);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return 1;
    } else{
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    UIImageView *lineView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"line"]];
    lineView.frame = CGRectMake(0, cell.frame.size.height - 1, cell.frame.size.width - 20, 1);
    if(indexPath.section == 0 && indexPath.row == 0){
        cell.textLabel.text = NSLocalizedString(@"daren_recommand", nil);
    } else if(indexPath.section == 1 && indexPath.row == 0){
        cell.textLabel.text = NSLocalizedString(@"sina_weibo_friend", nil);
        [cell.contentView addSubview:lineView];
        //    } else if(indexPath.section == 1 && indexPath.row == 1){
        //        cell.textLabel.text = NSLocalizedString(@"tencent_weibo_friend", nil);
        //        [cell.contentView addSubview:lineView];
    } else if(indexPath.section == 1 && indexPath.row == 1){
        cell.textLabel.text = NSLocalizedString(@"phone_contact_friend", nil);
    }
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
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
    if(indexPath.section == 0){
        PopularUserViewController *viewController = [[PopularUserViewController alloc]initWithNibName:@"PopularUserViewController" bundle:nil];
        viewController.fromController = @"SearchFriendViewController";
        [self.navigationController pushViewController:viewController animated:YES];
    } else if(indexPath.section == 1){
        if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
            [UIUtility showNetWorkError:self.view];
            return;
        }
        if(indexPath.row == 0){
            if([WBEngine sharedClient].isLoggedIn && ![WBEngine sharedClient].isAuthorizeExpired){
                [self processSinaData];
            } else{
                SinaLoginViewController *viewController = [[SinaLoginViewController alloc]init];
                viewController.fromController = @"SearchFriendViewController";
                [self.navigationController pushViewController:viewController animated:YES];
            }
            //        } else if(indexPath.row == 1){
            //            NSNumber *num = (NSNumber *)[[ContainerUtility sharedInstance]attributeForKey:kTencentUserLoggedIn];
            //            if([num boolValue]){
            //                FriendListViewController *viewController = [[FriendListViewController alloc]initWithNibName:@"FriendListViewController" bundle:nil];
            //                viewController.sourceType = @"2";
            //                [self.navigationController pushViewController:viewController animated:YES];
            //            } else{
            //                TecentViewController *viewController = [[TecentViewController alloc] init];
            //                viewController.fromController = @"SearchFriendViewController";
            //                [self.navigationController pushViewController:viewController animated:YES];
            //            }
        } else {
            if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
                [UIUtility showNetWorkError:self.view];
                return;
            }
            [self uploadAddressBook];
        }
    }
}

- (void)closeSelf
{
    UIViewController *viewController = [self.navigationController popViewControllerAnimated:YES];
    if(viewController == nil){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
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
    [[ContainerUtility sharedInstance]setAttribute:addressBookTemp forKey:@"address_book"];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: kAppKey, @"app_key", @"5", @"source_type", friendIds, @"source_ids", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathGenUserThirdPartyUsers parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            
        } else {
            
        }
        ContactFriendListViewController *viewController = [[ContactFriendListViewController alloc]initWithNibName:@"ContactFriendListViewController" bundle:nil];
        viewController.sourceType = @"5";
        [self.navigationController pushViewController:viewController animated:YES];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
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

- (void)processSinaData {
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                [[WBEngine sharedClient] accessToken], @"access_token",
                                [[WBEngine sharedClient] userID], @"uid",
                                nil];
    [[AFSinaWeiboAPIClient sharedClient] getPath:@"friendships/friends/bilateral.json" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *sinaFriends = [responseObject valueForKeyPath:@"users"];
        [[CacheUtility sharedCache]setSinaFriends:sinaFriends];
        NSMutableString *friendIds = [[NSMutableString alloc]init];
        for (NSDictionary *friendData in sinaFriends) {
            [friendIds appendFormat:@"%@,", [[friendData objectForKey:@"id"] stringValue]];
        }
        [friendIds appendString:@"0"];
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: kAppKey, @"app_key", @"1", @"source_type", friendIds, @"source_ids", nil];
        [[AFServiceAPIClient sharedClient] postPath:kPathGenUserThirdPartyUsers parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            NSString *responseCode = [result objectForKey:@"res_code"];
            if(responseCode == nil){
                
            } else {
                
            }
            FriendListViewController *viewController = [[FriendListViewController alloc]initWithNibName:@"FriendListViewController" bundle:nil];
            viewController.sourceType = @"1";
            [self.navigationController pushViewController:viewController animated:YES];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
        }];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
    
}

@end
