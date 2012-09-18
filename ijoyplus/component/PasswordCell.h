//
//  PasswordCell.h
//  ijoyplus
//
//  Created by joyplus1 on 12-9-18.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTextField.h"

@interface PasswordCell : UITableViewCell
@property (weak, nonatomic) IBOutlet CustomTextField *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

@end
