//
//  RegisterViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-18.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "RegisterViewController.h"
#import "CustomBackButtonHolder.h"
#import "CustomBackButton.h"
#import "UIUtility.h"
#import "CMConstants.h"

@interface RegisterViewController () {
    UIButton *registerBtn;
}

- (void)closeSelf;
- (void)initRegisterBtn;
- (void)registerAction;

@end

@implementation RegisterViewController
@synthesize emailCell;
@synthesize passwordCell;
@synthesize confirmPasswordCell;
@synthesize nicknameCell;
@synthesize delegate;

- (void)viewDidUnload
{
    [self setNicknameCell:nil];
    [self setEmailCell:nil];
    [self setPasswordCell:nil];
    [self setConfirmPasswordCell:nil];
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
    self.title = NSLocalizedString(@"register", nil);
    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    CustomBackButtonHolder *backButtonHolder = [[CustomBackButtonHolder alloc]initWithViewController:self];
    CustomBackButton* backButton = [backButtonHolder getBackButton:NSLocalizedString(@"go_back", nil)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor clearColor];
    [self initRegisterBtn];
}

- (void)initRegisterBtn
{
    registerBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [registerBtn setFrame:CGRectMake(0, 0, self.view.frame.size.width - 20, 44)];
    [registerBtn setTitle:NSLocalizedString(@"register", nil) forState:UIControlStateNormal];
    [registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [registerBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [UIUtility addTextShadow:registerBtn.titleLabel];
    registerBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|
    UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [registerBtn setBackgroundImage:[[UIImage imageNamed:@"reg_btn_normal"]stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
    [registerBtn setBackgroundImage:[[UIImage imageNamed:@"reg_btn_active"]stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
    [registerBtn addTarget:self action:@selector(registerAction)forControlEvents:UIControlEventTouchUpInside];
    registerBtn.layer.cornerRadius = 10;
    registerBtn.layer.masksToBounds = YES;
}

- (void)registerAction
{
    [self.delegate closeChild];
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
    if(section == 2){
        return 1;
    } else if (section == 1){
        return 3;
    } else{
        return 4;
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
        UIImageView *lineView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"line"]];
        lineView.frame = CGRectMake(0, cell.frame.size.height - 1, cell.frame.size.width - 20, 1);
        if(indexPath.row == 0){
            cell.textLabel.text = NSLocalizedString(@"sina_weibo", nil);
            [cell.contentView addSubview:lineView];
        } else if(indexPath.row == 1){
            cell.textLabel.text = NSLocalizedString(@"tencent_weibo", nil);
            [cell.contentView addSubview:lineView];
        } else if(indexPath.row == 2){
            cell.textLabel.text = NSLocalizedString(@"renren", nil);
            [cell.contentView addSubview:lineView];
        } else if(indexPath.row == 3){
            cell.textLabel.text = NSLocalizedString(@"douban", nil);
        }
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    } else if(indexPath.section == 1){
        if(indexPath.row == 0){
            nicknameCell.titleLabel.placeholder = NSLocalizedString(@"nick_name", nil);
            return nicknameCell;
        } else if(indexPath.row == 1){
            emailCell.titleLabel.placeholder = NSLocalizedString(@"email", nil);
            return emailCell;
        } else if(indexPath.row == 2){
            passwordCell.titleLabel.placeholder = NSLocalizedString(@"password", nil);
            return passwordCell;
        } else if(indexPath.row == 3){
            confirmPasswordCell.titleLabel.placeholder = NSLocalizedString(@"confirm_password", nil);
            return confirmPasswordCell;
        }
    } else {
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"registerBtnCell"];
        UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
        backView.backgroundColor = [UIColor clearColor];
        cell.backgroundView = backView;
        [cell.contentView addSubview:registerBtn];
        return cell;
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
    if(section == 2){
        return 5;
    } else {
        return 25;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section == 2){
        return nil;
    }
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,25)];
    customView.backgroundColor = [UIColor clearColor];
    
    //    // create the label objects
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, customView.frame.size.width, customView.frame.size.height)];
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)closeSelf
{
    UIViewController *viewController = [self.navigationController popViewControllerAnimated:YES];
    if(viewController == nil){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
