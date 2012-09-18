//
//  RegisterViewController.h
//  ijoyplus
//
//  Created by joyplus1 on 12-9-18.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NicknameCell.h"
#import "EmailCell.h"
#import "PasswordCell.h"
#import "ConfirmPasswordCell.h"

@interface RegisterViewController : UITableViewController
@property (strong, nonatomic) IBOutlet NicknameCell *nicknameCell;
@property (strong, nonatomic) IBOutlet EmailCell *emailCell;
@property (strong, nonatomic) IBOutlet PasswordCell *passwordCell;
@property (strong, nonatomic) IBOutlet ConfirmPasswordCell *confirmPasswordCell;

@end
