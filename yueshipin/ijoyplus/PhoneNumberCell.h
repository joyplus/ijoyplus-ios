//
//  PhoneNumberCell.h
//  ijoyplus
//
//  Created by joyplus1 on 12-10-12.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTextField.h"

@interface PhoneNumberCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet CustomTextField *inputField;

@end
