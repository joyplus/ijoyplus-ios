//
//  FillFormViewController.h
//  ijoyplus
//
//  Created by joyplus1 on 12-9-21.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NicknameCell.h"
#import "EmailCell.h"
#import "PasswordCell.h"


@interface FillFormViewController : UITableViewController<UITextFieldDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet PasswordCell *passwordCell;
@property (strong, nonatomic) IBOutlet EmailCell *emailCell;
@property (strong, nonatomic) IBOutlet NicknameCell *nicknameCell;
@property (strong, nonatomic) NSString *thirdPartyId;
@property (strong, nonatomic) NSString *thirdPartyType;

@end
