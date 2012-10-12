//
//  LoginViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-18.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "LoginViewController.h"
#import "UIUtility.h"
#import "CustomBackButtonHolder.h"
#import "CustomBackButton.h"
#import "CMConstants.h"
#import "BottomTabViewController.h"
#import "AppDelegate.h"
#import "RegisterViewController.h"
#import "SinaLoginViewController.h"
#import "TecentViewController.h"
#import "ContainerUtility.h"
#import "StringUtility.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "SFHFKeychainUtils.h"

#define FIELDS_COUNT 2


@interface LoginViewController (){
    UIToolbar *keyboardToolbar;
    MBProgressHUD *HUD;
}

- (void)closeSelf;
- (void)registerAction;
@end

@implementation LoginViewController
@synthesize table;
@synthesize scrollView;
@synthesize loginBtn;
@synthesize usernameCell;
@synthesize loginPasswordCell;

- (void)viewDidUnload
{
    keyboardToolbar = nil;
    HUD = nil;
    [self setScrollView:nil];
    [self setTable:nil];
    [self setUsernameCell:nil];
    [self setLoginPasswordCell:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"login", nil);
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    CustomBackButtonHolder *backButtonHolder = [[CustomBackButtonHolder alloc]initWithViewController:self];
    CustomBackButton* backButton = [backButtonHolder getBackButton:NSLocalizedString(@"go_back", nil)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    UIBarButtonItem *registerBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"register", nil) style:UIBarButtonSystemItemSearch target:self action:@selector(registerAction)];
    self.navigationItem.rightBarButtonItem = registerBtn;
    
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, 480)];
    [self initLoginBtn];
    self.table.delegate = self;
    self.table.dataSource = self;
    self.table.backgroundColor = [UIColor yellowColor];
    self.table.separatorColor = [UIColor clearColor];
    self.table.backgroundColor = [UIColor clearColor];
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
        
        [previousBarItem setBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [nextBarItem setBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [doneBarItem setBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        
        [keyboardToolbar setItems:[NSArray arrayWithObjects:previousBarItem, nextBarItem, spaceBarItem, doneBarItem, nil]];
        
        usernameCell.titleField.tag = 1;
        usernameCell.titleField.delegate = self;
        loginPasswordCell.titleField.tag = 2;
        loginPasswordCell.titleField.delegate = self;
        usernameCell.titleField.inputAccessoryView = keyboardToolbar;
        loginPasswordCell.titleField.inputAccessoryView = keyboardToolbar;
    }
}

- (void)initLoginBtn
{
    [self.loginBtn setTitle:NSLocalizedString(@"login", nil) forState:UIControlStateNormal];
    [self.loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.loginBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [UIUtility addTextShadow:loginBtn.titleLabel];
    [self.loginBtn setBackgroundImage:[[UIImage imageNamed:@"log_btn_normal"]stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
    [self.loginBtn setBackgroundImage:[[UIImage imageNamed:@"log_btn_active"]stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
    self.loginBtn.layer.cornerRadius = 10;
    self.loginBtn.layer.masksToBounds = YES;
    self.loginBtn.layer.zPosition = 1;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            usernameCell.titleField.placeholder = NSLocalizedString(@"username", nil);
            return usernameCell;
        } else if(indexPath.row == 1){
            loginPasswordCell.titleField.placeholder = NSLocalizedString(@"password", nil);
            return loginPasswordCell;
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,30)];
    customView.backgroundColor = [UIColor clearColor];
    
    //    // create the label objects
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, customView.frame.size.width, customView.frame.size.height)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:15];
    headerLabel.text =  NSLocalizedString(@"user_login", nil);
    headerLabel.textColor = [UIColor whiteColor];
    [headerLabel sizeToFit];
    [customView addSubview:headerLabel];
    
    return customView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [self.table deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)closeSelf
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)registerAction
{
    RegisterViewController *viewController = [[RegisterViewController alloc]initWithNibName:@"RegisterViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)loginAction:(id)sender {
    [self resignKeyboard:nil];
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
    HUD.labelText = NSLocalizedString(@"message.logginInProgress", nil);
    [HUD showWhileExecuting:@selector(saveTask) onTarget:self withObject:nil animated:YES];
}

- (void)saveTask
{
    sleep(1);
    NSString *strEmailId = usernameCell.titleField.text;
    NSString *strPassword = loginPasswordCell.titleField.text;
    
    if ([self validateEmpty:NSLocalizedString(@"message.emailempty", nil) content:strEmailId] || ![self IsValidEmail:strEmailId] || [self validateEmpty:NSLocalizedString(@"message.passwordempty", nil) content:strPassword]) {
        return;
    }
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                kAppKey, @"app_key",
                                strEmailId, @"username",
                                strPassword, @"password",
                                nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathAccountLogin parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        HUD.mode = MBProgressHUDModeCustomView;
        [self.view addSubview:HUD];
        if([responseCode isEqualToString:kSuccessResCode]){
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"complete.png"]];
            HUD.labelText = NSLocalizedString(@"message.signinsuccess", nil);
            [HUD showWhileExecuting:@selector(postLogin) onTarget:self withObject:nil animated:YES];
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
        HUD.labelText = NSLocalizedString(@"message.systemfailure", nil);
        HUD.minSize = CGSizeMake(135.f, 135.f);
        [HUD show:YES];
        [HUD hide:YES afterDelay:2];
    }];   
}

- (void)showError
{
    sleep(1.5);
}

- (void)postLogin
{
    sleep(1);
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                kAppKey, @"app_key",
                                nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathUserView parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            [[ContainerUtility sharedInstance]setAttribute:[result valueForKey:@"nickname"] forKey:kUserName];
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {

    }];
    [SFHFKeychainUtils storeUsername:kUserId andPassword:loginPasswordCell.titleField.text forServiceName:@"login" updateExisting:YES error:nil];
    [[ContainerUtility sharedInstance]setAttribute:usernameCell.titleField.text forKey:kUserId];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [[ContainerUtility sharedInstance]setAttribute:[NSNumber numberWithBool:YES] forKey:kUserLoggedIn];
    [appDelegate refreshRootView];
}

- (IBAction)sinaLogin:(id)sender {
    SinaLoginViewController *viewController = [[SinaLoginViewController alloc]init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)tecentLogin:(id)sender {
    TecentViewController *viewController = [[TecentViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
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
        UITextField *previousField = (UITextField *)[self.table viewWithTag:previousTag];
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
        UITextField *nextField = (UITextField *)[self.table viewWithTag:nextTag];
        [nextField becomeFirstResponder];
    }
}

- (id)getFirstResponder
{
    if([usernameCell.titleField isFirstResponder]){
        return usernameCell.titleField;
    }
    if([loginPasswordCell.titleField isFirstResponder]){
        return loginPasswordCell.titleField;
    }
    
    return nil;
}

- (void)animateView:(NSUInteger)tag
{
    CGRect rect = self.view.frame;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    rect.origin.y = -44.0f * 4;
    self.view.frame = rect;
    [UIView commitAnimations];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self resignKeyboard:nil];
    return YES;
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
