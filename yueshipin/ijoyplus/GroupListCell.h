//
//  GroupListCell.h
//  ijoyplus
//
//  Created by joyplus1 on 12-11-9.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *listImageView;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UIImageView *separatorImageBottom;
@property (weak, nonatomic) IBOutlet UIImageView *separatorImageTop;
@property (assign, nonatomic) BOOL showTopImage;

@end
