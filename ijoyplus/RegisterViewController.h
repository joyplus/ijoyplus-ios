//
//  LoginViewController.h
//  ijoyplus
//
//  Created by joyplus1 on 12-9-18.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NicknameCell.h"
#import "EmailCell.h"
#import "PasswordCell.h"
#import "BottomTabViewController.h"

@interface RegisterViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIButton *loginBtn;
@property (strong, nonatomic) IBOutlet NicknameCell *nicknameCell;
@property (strong, nonatomic) IBOutlet EmailCell *emailCell;
@property (strong, nonatomic) IBOutlet PasswordCell *passwordCell;

- (IBAction)loginAction:(id)sender;
- (IBAction)sinaLogin:(id)sender;
- (IBAction)tecentLogin:(id)sender;

@end
