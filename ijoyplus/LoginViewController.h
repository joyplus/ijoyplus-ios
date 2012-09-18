//
//  LoginViewController.h
//  ijoyplus
//
//  Created by joyplus1 on 12-9-18.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UsernameCell.h"
#import "LoginPasswordCell.h"

@interface LoginViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIButton *loginBtn;
@property (strong, nonatomic) IBOutlet UsernameCell *usernameCell;
@property (strong, nonatomic) IBOutlet LoginPasswordCell *loginPasswordCell;
- (IBAction)forgotPassword:(id)sender;
- (IBAction)loginAction:(id)sender;

@end
