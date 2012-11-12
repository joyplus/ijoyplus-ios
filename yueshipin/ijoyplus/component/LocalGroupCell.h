//
//  LocalGroupCell.h
//  ijoyplus
//
//  Created by joyplus1 on 12-11-9.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocalGroupCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *cellBtn;
@property (weak, nonatomic) IBOutlet UIImageView *cellImage;

@property (weak, nonatomic) IBOutlet UILabel *cellTitle;

@end
