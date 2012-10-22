//
//  FillFormViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-21.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "FillFormViewController.h"
#import "CustomBackButton.h"
#import "AppDelegate.h"
#import "ContainerUtility.h"
#import "CMConstants.h"
#import "CacheUtility.h"
#import "WBEngine.h"
#import "PopularUserViewController.h"
#import "MBProgressHUD.h"
#import "NetWorkUtility.h"
#import "StringUtility.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "SFHFKeychainUtils.h"

#define FIELDS_COUNT 3


@interface FillFormViewController (){
    UIToolbar *keyboardToolbar;
    MBProgressHUD *HUD;
}

- (void)finishRegister;
- (void)closeSelf;
@end

@implementation FillFormViewController
@synthesize passwordCell;
@synthesize emailCell;
@synthesize nicknameCell;
@synthesize thirdPartyType;
@synthesize thirdPartyId;

- (void)viewDidUnload
{
    keyboardToolbar = nil;
    [self setPasswordCell:nil];
    [self setEmailCell:nil];
    [self setNicknameCell:nil];
    HUD = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    self.title = NSLocalizedString(@"fill_form_title", nil);
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    [self.navigationItem setHidesBackButton:YES];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"next_step", nil) style:UIBarButtonSystemItemSearch target:self action:@selector(finishRegister)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    // Keyboard toolbar
    if (keyboardToolbar == nil) {
        keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 38.0f)];
        keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
        
        UIBarButtonItem *previousBarItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"previous", @"")
                                                                            style:UIBarButtonItemStyleBordered
                                                                           target:self
                                                                           action:@selector(previousField:)];
        
        UIBarButtonItem *nextBarItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"next", @"")
                                                                        style:UIBarButtonItemStyleBordered
                                                                       target:self
                                                                       action:@selector(nextField:)];
        
        UIBarButtonItem *spaceBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                      target:nil
                                                                                      action:nil];
        
        UIBarButtonItem *doneBarItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"done", @"")
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self
                                                                       action:@selector(resignKeyboard:)];
        
        [keyboardToolbar setItems:[NSArray arrayWithObjects:previousBarItem, nextBarItem, spaceBarItem, doneBarItem, nil]];
        
        nicknameCell.titleLabel.tag = 1;
        nicknameCell.titleLabel.delegate = self;
        nicknameCell.titleLabel.inputAccessoryView = keyboardToolbar;
        emailCell.titleLabel.tag = 2;
        emailCell.titleLabel.delegate = self;
        emailCell.titleLabel.inputAccessoryView = keyboardToolbar;
        passwordCell.titleLabel.tag = 3;
        passwordCell.titleLabel.inputAccessoryView = keyboardToolbar;
        passwordCell.titleLabel.delegate = self;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    if(indexPath.row == 0){
        nicknameCell.titleLabel.placeholder = NSLocalizedString(@"nick_name", nil);
        return nicknameCell;
    } else if(indexPath.row == 1){
        emailCell.titleLabel.placeholder = NSLocalizedString(@"email", nil);
        return emailCell;
    } else if(indexPath.row == 2){
        passwordCell.titleLabel.placeholder = NSLocalizedString(@"password", nil);
        return passwordCell;
    }
    
    return nil;
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,30)];
    customView.backgroundColor = [UIColor clearColor];
    
    //    // create the label objects
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, customView.frame.size.width, customView.frame.size.height)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:15];
    headerLabel.text =  NSLocalizedString(@"fill_form", nil);
    headerLabel.textColor = [UIColor whiteColor];
    [headerLabel sizeToFit];
    [customView addSubview:headerLabel];
    
    return customView;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)closeSelf
{
    [[CacheUtility sharedCache] clear];
    [[ContainerUtility sharedInstance] clear];
    [[WBEngine sharedClient]logOut];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)resignKeyboard:(id)sender
{
    id firstResponder = [self getFirstResponder];
    if ([firstResponder isKindOfClass:[UITextField class]]) {
        [firstResponder resignFirstResponder];
        [self animateBackView];
    }
}

- (void)previousField:(id)sender
{
    id firstResponder = [self getFirstResponder];
    if ([firstResponder isKindOfClass:[UITextField class]]) {
        NSUInteger tag = [firstResponder tag];
        NSUInteger previousTag = tag == 1 ? 1 : tag - 1;
        [self checkBarButton:previousTag];
        [self animateView:previousTag];
        UITextField *previousField = (UITextField *)[self.tableView viewWithTag:previousTag];
        [previousField becomeFirstResponder];
    }
}

- (void)nextField:(id)sender
{
    id firstResponder = [self getFirstResponder];
    if ([firstResponder isKindOfClass:[UITextField class]]) {
        NSUInteger tag = [firstResponder tag];
        NSUInteger nextTag = tag == FIELDS_COUNT ? FIELDS_COUNT : tag + 1;
        [self checkBarButton:nextTag];
        [self animateView:nextTag];
        UITextField *nextField = (UITextField *)[self.tableView viewWithTag:nextTag];
        [nextField becomeFirstResponder];
    }
}

- (id)getFirstResponder
{
    NSUInteger index = 1;
    while (index <= FIELDS_COUNT) {
        UITextField *textField = (UITextField *)[self.view viewWithTag:index];
        if ([textField isFirstResponder]) {
            return textField;
        }
        index++;
    }
    
    return nil;
}

- (void)animateView:(NSUInteger)tag
{
    //    CGRect rect = self.view.frame;
    //    [UIView beginAnimations:nil context:NULL];
    //    [UIView setAnimationDuration:0.3];
    //
    //    if (tag > 5) {
    //        rect.origin.y = -44.0f * 5 - 15;
    //    } else {
    //        rect.origin.y = -44.0f * 5;
    //    }
    //    self.view.frame = rect;
    //    [UIView commitAnimations];
}

- (void)animateBackView
{
    CGRect rect = self.view.frame;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    rect.origin.y = 0.0f;
    self.view.frame = rect;
    [UIView commitAnimations];
}

- (void)checkBarButton:(NSUInteger)tag
{
    UIBarButtonItem *previousBarItem = (UIBarButtonItem *)[[keyboardToolbar items] objectAtIndex:0];
    UIBarButtonItem *nextBarItem = (UIBarButtonItem *)[[keyboardToolbar items] objectAtIndex:1];
    
    [previousBarItem setEnabled:tag == 1 ? NO : YES];
    [nextBarItem setEnabled:tag == FIELDS_COUNT ? NO : YES];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSUInteger tag = [textField tag];
    [self animateView:tag];
    [self checkBarButton:tag];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}
- (void)finishRegister {
    [self resignFirstResponder];
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.minSize = CGSizeMake(135.f, 135.f);
    
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = NSLocalizedString(@"message.networkError", nil);
        [HUD show:YES];
        [HUD hide:YES afterDelay:2];
        return;
    }
    HUD.labelText = NSLocalizedString(@"message.registerInProgress", nil);
    [HUD showWhileExecuting:@selector(saveTask) onTarget:self withObject:nil animated:YES];
}

- (void)saveTask
{
    sleep(1);
    NSString *strEmailId = emailCell.titleLabel.text;
    NSString *strPassword = passwordCell.titleLabel.text;
    NSString *strNickname = nicknameCell.titleLabel.text;
    
    if ([self validateEmpty:NSLocalizedString(@"message.nicknameempty", nil) content:strNickname] || [self validateEmpty:NSLocalizedString(@"message.emailempty", nil) content:strEmailId] || ![self IsValidEmail:strEmailId] || [self validateEmpty:NSLocalizedString(@"message.passwordempty", nil) content:strPassword]) {
        return;
    }
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: kAppKey, @"app_key", strEmailId, @"username", strPassword, @"password", strNickname, @"nickname", self.thirdPartyId, @"source_id", self.thirdPartyType, @"source_type", nil];
    
    [[AFServiceAPIClient sharedClient] postPath:kPathAccountUpdateProfile parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        HUD.mode = MBProgressHUDModeCustomView;
        [self.view addSubview:HUD];
        if([responseCode isEqualToString:kSuccessResCode]){
            NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                        kAppKey, @"app_key",
                                        nil];
            [[AFServiceAPIClient sharedClient] getPath:kPathUserView parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
                NSString *responseCode = [result objectForKey:@"res_code"];
                if(responseCode == nil){
                    [[ContainerUtility sharedInstance]setAttribute:[result valueForKey:@"id"] forKey:kUserId];
                }
            } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                
            }];
            [SFHFKeychainUtils storeUsername:kUserName andPassword:passwordCell.titleLabel.text forServiceName:kUserLoginService updateExisting:YES error:nil];
            [[ContainerUtility sharedInstance]setAttribute:emailCell.titleLabel.text forKey:kUserName];
            [[ContainerUtility sharedInstance]setAttribute:nicknameCell.titleLabel.text forKey:kUserNickName];
            [[ContainerUtility sharedInstance] setAttribute:[NSNumber numberWithBool:YES] forKey:kUserLoggedIn];
            [self postRegister];
        } else {
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
            NSString *msg = [NSString stringWithFormat:@"msg_%@", responseCode];
            HUD.labelText = NSLocalizedString(msg, nil);
            [HUD showWhileExecuting:@selector(showError) onTarget:self withObject:nil animated:YES];
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
        HUD.mode = MBProgressHUDModeCustomView;
        [self.view addSubview:HUD];
        HUD.labelText = @"Network error, please try again!";
        HUD.minSize = CGSizeMake(135.f, 135.f);
        [HUD show:YES];
        [HUD hide:YES afterDelay:2];
    }];
}

- (void)showError
{
    sleep(2);
}


- (void)postRegister
{
    sleep(2);
    PopularUserViewController *viewController = [[PopularUserViewController alloc]initWithNibName:@"PopularUserViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (BOOL) IsValidEmail:(NSString*) checkString {
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    //NSString *laxString = @".+@.+\.[A-Za-z]{2}[A-Za-z]*";
    //NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stricterFilterString];
    if(![emailTest evaluateWithObject:checkString]){
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = NSLocalizedString(@"message.invalidMailAddress", nil);
        sleep(1);
        return NO;
    }else{
        return YES;
        
    }
    return YES;
}

- (BOOL) validateEmpty: (NSString *) title content:(NSString *)content{
    if ([StringUtility stringIsEmpty:content]) {
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = title;
        sleep(2);
        return YES;
    } else {
        return NO;
    }
}
@end
