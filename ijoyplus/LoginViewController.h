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
#import "BottomTabViewController.h"

@interface LoginViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIButton *loginBtn;
@property (strong, nonatomic) IBOutlet UsernameCell *usernameCell;
@property (strong, nonatomic) IBOutlet LoginPasswordCell *loginPasswordCell;
- (IBAction)loginAction:(id)sender;
- (IBAction)sinaLogin:(id)sender;
- (IBAction)tecentLogin:(id)sender;

@end
