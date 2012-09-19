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

@interface LoginViewController ()

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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return 4;
    } else {
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        if(indexPath.row == 0){
            cell.textLabel.text = NSLocalizedString(@"sina_weibo", nil);
        } else if(indexPath.row == 1){
            cell.textLabel.text = NSLocalizedString(@"tencent_weibo", nil);
        } else if(indexPath.row == 2){
            cell.textLabel.text = NSLocalizedString(@"renren", nil);
        } else if(indexPath.row == 3){
            cell.textLabel.text = NSLocalizedString(@"douban", nil);
        }
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    } else if(indexPath.section == 1){
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
    if(section == 0){
        headerLabel.text =  NSLocalizedString(@"auth_login", nil);
    }else {
        headerLabel.text =  NSLocalizedString(@"register_user", nil);
    }
    headerLabel.textColor = [UIColor whiteColor];
    [headerLabel sizeToFit];
    [customView addSubview:headerLabel];
    
    return customView;
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

- (IBAction)forgotPassword:(id)sender {
}

- (IBAction)loginAction:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.userLoggedIn = YES;
    [appDelegate.window.rootViewController viewDidLoad];
//    BottomTabViewController *detailViewController = [[BottomTabViewController alloc] init];
//    UINavigationController *viewController =  [[UINavigationController alloc]initWithRootViewController:detailViewController];
//     = viewController;
//    [self presentModalViewController:viewController animated:YES];
}
@end
