//
//  CommentCell.h
//  ijoyplus
//
//  Created by joyplus1 on 12-9-11.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *avatarBtn;
@property (weak, nonatomic) IBOutlet UIImageView *separatorImageBottom;

@end
